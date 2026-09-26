class_name CapacityBlock
extends VBoxContainer

# =============================================================================
# KAPASİTE bloğu — canlı ürün sayfasının altyapı yüzeyi (§10: sağlayıcı, doluluk,
# yük, fatura, brüt marj canlıda okunmak ZORUNDA). Canlı sayfanın mevcut görsel
# dilini kullanır: DURUM kartının etiket→değer satırı, bölüm başlığı, DESTEK çubuğu.
#
# HİÇBİR SAYI BURADA HESAPLANMAZ. Doluluk, etkin kapasite, yük, fatura, brüt marj
# ve bant kararı InfraSystem'in okumalarıdır; bu dosya %80'i ya da %100'ü YAZMAZ
# (§18: UI kendi eşiğini kurmaz). Durum → renk eşlemesi UiTokens.health_color'dan,
# ki renk körü paleti bedavaya gelsin.
#
# Kök VBox, tek çocuğu kart: blok hangi sütuna bırakılırsa bırakılsın kart gibi
# okunur ve ev sahibinin ayrıca sarmalamasına gerek kalmaz.
# =============================================================================

signal change_requested()

const BAR_H := 6

## ÜÇ BANT, ÜÇ SAĞLIK RENGİ. `normal` yeşil olmak zorunda: ACCENT ile HEALTH_AMBER aynı
## hex, yani "normal" amber çizilseydi sararma bandı ondan ayırt edilemezdi.
const STATE_HEALTH := {
	InfraSystem.STATE_OVER: &"bad",
	InfraSystem.STATE_AMBER: &"warn",
	InfraSystem.STATE_NORMAL: &"healthy",
}


func _ready() -> void:
	add_theme_constant_override("separation", 0)
	# Sağlayıcı/kapasite seam'i `infra_changed` yayar. MRR ve gün sonu tazelemesi ev
	# sahibinin repaint zincirinden gelir.
	EventBus.infra_changed.connect(repaint)
	repaint()


## Blok yerinde yeniden kurulur; içinde tutulan durum yok, o yüzden tam yeniden çizim
## en ucuz doğru yoldur.
func repaint() -> void:
	if not is_node_ready():
		return
	for c in get_children():
		remove_child(c)
		c.queue_free()

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", UiTokens.SPACE_M)
	add_child(UiFactory.make_card(body))

	var state: String = InfraSystem.capacity_state()
	body.add_child(_header(state))
	body.add_child(_provider_row())
	if state == InfraSystem.STATE_UNPROVISIONED:
		# Kapasite alınmamış ürün MEŞRU bir durumdur (§10 tabanı 0): ölçülecek bir şey
		# yok, ama değiştirme kapısı durur.
		body.add_child(UiFactory.make_label(tr("PROD_CAPACITY_UNSET"), &"EmptyRowLabel"))
		return

	body.add_child(_occupancy_bar(state))
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 0)
	_add_row(rows, tr("PROD_CAPACITY_OCCUPANCY"), tr("PROD_CAPACITY_OF").format({
		"used": Fmt.group(InfraSystem.served_count()),
		"cap": Fmt.group(int(round(InfraSystem.effective_capacity())))}), UiTokens.INK, true)
	_add_row(rows, tr("PROD_CAPACITY_BILL"), " · ".join([
		tr("PROD_INFRA_UNITS_N").format({"n": InfraSystem.units()}),
		tr("PROD_INFRA_MONTHLY_BILL").format({
			"amount": ProductUiShared.money_tr(InfraSystem.monthly_bill())})]),
		UiTokens.INK, true)
	# YÜK — §10'un "yük = 1 + Σağırlık / 20" okuması. Ağır kademe yayınlamak kalıcı
	# bir işletme maliyetidir ve bu satır oyuncuya onu gösteren tek yerdir.
	_add_row(rows, tr("PROD_CAPACITY_LOAD"), tr("PROD_CAPACITY_LOAD_VALUE").format({
		"n": Fmt.number(InfraSystem.load_factor(), 2)}), UiTokens.INK, true)
	# BRÜT MARJ — "MRR − sunucu faturası".
	var margin: int = InfraSystem.gross_margin_monthly()
	_add_row(rows, tr("PROD_CAPACITY_MARGIN"), ProductUiShared.money_tr(margin),
		UiTokens.delta_color(margin), false)
	body.add_child(rows)


# --- parçalar -----------------------------------------------------------------

func _header(state: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var head := UiFactory.make_label(tr("PROD_CAPACITY"), &"SectionLabel")
	head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(head)
	if state == InfraSystem.STATE_OVER:
		row.add_child(UiFactory.make_state_chip(tr("PROD_CAPACITY_OVER_BADGE"),
			UiTokens.negative(), UiTokens.negative_bg(), UiTokens.negative_rule()))
	return row


func _provider_row() -> Control:
	# Sağlayıcı değiştirme bedelsizdir ve her an açıktır (§10): düğme hiçbir koşulla
	# kapanmaz. Amber DEĞİL: karar bir sonraki yüzeyde veriliyor.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var pid: String = InfraSystem.provider()
	var name := UiFactory.make_label(
		tr(InfraSystem.provider_name_key(pid)) if InfraSystem.is_provider(pid) else "—",
		&"RowName")
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(name)
	var change := Button.new()
	change.text = tr("PROD_INFRA_CHANGE")
	change.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	change.pressed.connect(change_requested.emit)
	row.add_child(change)
	return row


func _occupancy_bar(state: String) -> Control:
	var color: Color = UiTokens.health_color(STATE_HEALTH.get(state, &""))
	var pct: int = InfraSystem.occupancy_pct()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var bar := ProgressBar.new()
	bar.theme_type_variation = &"BuildProgress"
	bar.show_percentage = false
	# Çubuk %100'de DOLU DURUR; aşımın kendisini rakam ve renk söyler. Ölçeği
	# taşımak, aşımı çubuğun içinde görünmez kılardı.
	bar.value = float(clampi(pct, 0, 100))
	bar.custom_minimum_size = Vector2(0, BAR_H)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	HRUiShared.override_bar_fill(bar, color)
	row.add_child(bar)
	var value := UiFactory.make_label(Fmt.percent(pct, 0), &"RowName", color)
	value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(value)
	return row


func _add_row(host: VBoxContainer, label: String, value: String, value_color: Color,
		with_rule: bool) -> void:
	# DURUM satırı: etiket sola sönük, değer sağa kalın, altında saç teli. Son satır
	# kuralsızdır — kart kenarıyla çift çizgi olmasın.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var l := UiFactory.make_label(label, &"RowMeta", UiTokens.INK_DIM)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)
	var v := UiFactory.make_label(value, &"StepperValue", value_color)
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(v)
	var cell := VBoxContainer.new()
	cell.add_theme_constant_override("separation", UiTokens.SPACE_S)
	cell.add_child(row)
	if with_rule:
		cell.add_child(HRUiShared.hairline())
	host.add_child(cell)
