class_name CapacityBlock
extends VBoxContainer

# =============================================================================
# KAPASİTE bloğu — canlı ürün sayfasının altyapı yüzeyi.
#
# S8 BU BLOĞU ÇİZMİYOR. Onaylı kare canlı sayfada FİYATLANDIRMA · DESTEK · DURUM
# taşıyor; §10 ise altyapının canlıda okunmasını ŞART koşuyor (sağlayıcı, doluluk,
# yük, fatura, brüt marj). Blok bu yüzden S8'in KENDİ görsel dilinde çizildi ve
# hiçbir yeni gramer icat edilmedi: DURUM kartının etiket→değer satırı, SÜRÜMLER
# kartının bölüm başlığı, DESTEK kartının çubuğu. Yeni olan tek şey içerik.
#
# HİÇBİR SAYI BURADA HESAPLANMAZ. Doluluk, etkin kapasite, yük, fatura ve brüt
# marj InfraSystem'in kendi okumalarıdır; eşikler de öyle — bant kararını
# `capacity_state()` verir, bu dosya %80'i ya da %100'ü hiçbir yerde YAZMAZ
# (§18: UI kendi eşiğini kurmaz). Renk de türetilmez: durum → renk eşlemesi
# UiTokens.health_color'dan okunur, ki renk körü paleti bedavaya gelsin.
#
# KÖK VBox AMA İÇİNDE KART VAR: sınıf sözleşmesi VBoxContainer, S8'in dili ise
# kart. İkisi de korunuyor — kök bir yerleşim kabı, tek çocuğu CardPanel'li bir
# PanelContainer. Böylece blok hangi sütuna bırakılırsa bırakılsın S8 kartı gibi
# okunur ve ev sahibinin ayrıca sarmalamasına gerek kalmaz.
# =============================================================================

signal change_requested()

const BAR_H := 6


func _ready() -> void:
	add_theme_constant_override("separation", 0)
	# Seam sinyalleri (WRITE-THROUGH LAW): sağlayıcı/kapasite ProductState'in
	# set_infra_* seam'inden geçer ve `infra_changed` emit eder; brüt marj MRR'a
	# bağlı olduğu için ikinci dinleyici de gerekli. Ev sahibi ayrıca repaint()
	# çağırabilir — ikisi de aynı gövdeye iner.
	EventBus.infra_changed.connect(_on_infra_changed)
	EventBus.mrr_changed.connect(_on_mrr_changed)
	repaint()


func _on_infra_changed() -> void:
	repaint()


func _on_mrr_changed(_new_value: int) -> void:
	repaint()


## Router repaint zinciri (detail_view.repaint → buraya). Blok yerinde yeniden kurulur;
## içinde tutulan durum yok, o yüzden tam yeniden çizim en ucuz doğru yoldur.
func repaint() -> void:
	if not is_node_ready():
		return
	for c in get_children():
		remove_child(c)
		c.queue_free()

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", UiTokens.SPACE_M)

	var state: String = InfraSystem.capacity_state()
	body.add_child(_header(state))
	body.add_child(_provider_row())
	if state == InfraSystem.STATE_UNPROVISIONED:
		# Kapasite alınmamış ürün MEŞRU bir durumdur (§10 tabanı 0). Çubuk ve
		# oranlar çizilmez — çünkü ölçülecek bir şey yok — ama değiştirme kapısı durur.
		body.add_child(UiFactory.make_label(tr("PROD_CAPACITY_UNSET"), &"EmptyRowLabel"))
		add_child(UiFactory.make_card(body))
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
	# BRÜT MARJ — "MRR − sunucu faturası". İşaret→renk kararı token helper'ından.
	var margin: int = InfraSystem.gross_margin_monthly()
	_add_row(rows, tr("PROD_CAPACITY_MARGIN"), ProductUiShared.money_tr(margin),
		UiTokens.delta_color(margin), false)
	body.add_child(rows)

	add_child(UiFactory.make_card(body))


# --- parçalar -----------------------------------------------------------------

func _header(state: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var head := UiFactory.make_label(tr("PROD_CAPACITY"), &"SectionLabel")
	head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(head)
	if state == InfraSystem.STATE_OVER:
		# AŞIM rozeti — durum çipi, dolgusuz-renkli-kenar reçetesi (Terminal).
		row.add_child(UiFactory.make_state_chip(tr("PROD_CAPACITY_OVER_BADGE"),
			UiTokens.negative(), UiTokens.negative_bg(), UiTokens.negative_rule()))
	return row


func _provider_row() -> Control:
	# SAĞLAYICI ADI + DEĞİŞTİRME KAPISI. Değiştirme bedelsizdir ve her an açıktır
	# (§10), o yüzden düğme hiçbir koşulla kapanmaz. Amber DEĞİL: bu kartın taahhüt
	# rengi yok, karar bir sonraki yüzeyde veriliyor.
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
	change.pressed.connect(func() -> void: change_requested.emit())
	row.add_child(change)
	return row


func _occupancy_bar(state: String) -> Control:
	# DOLULUK ÇUBUĞU + YÜZDE. Bant kararı InfraSystem'in; buradaki tek iş onu renge
	# çevirmek ve o eşleme de UiTokens.health_color'ın (sign→renk bir daha icat edilmez).
	var color: Color = _state_color(state)
	var pct: int = InfraSystem.occupancy_pct()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var bar := ProgressBar.new()
	bar.theme_type_variation = &"BuildProgress"
	bar.show_percentage = false
	bar.min_value = 0.0
	bar.max_value = 100.0
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


func _state_color(state: String) -> Color:
	# ÜÇ BANT, ÜÇ SAĞLIK RENGİ. Eşikleri InfraSystem seçti; bu satır yalnız isimleri
	# eşliyor. `normal` yeşil olmak zorunda: ACCENT ile HEALTH_AMBER aynı hex
	# (#FFA028), yani "normal" amber çizilseydi sararma bandı ondan ayırt edilemezdi.
	# `if` zinciri, `match` DEĞİL: match deseni derleme-zamanı sabiti ister ve
	# buradaki üç ad başka bir sınıfın const'ı — eşiklerin evi orası olsun diye.
	if state == InfraSystem.STATE_OVER:
		return UiTokens.health_color(&"bad")
	if state == InfraSystem.STATE_AMBER:
		return UiTokens.health_color(&"warn")
	if state == InfraSystem.STATE_NORMAL:
		return UiTokens.health_color(&"healthy")
	return UiTokens.INK_DIM


func _add_row(host: VBoxContainer, label: String, value: String, value_color: Color,
		with_rule: bool) -> void:
	# S8'in DURUM satırı: etiket sola sönük, değer sağa kalın, altında saç teli.
	# Son satır kuralsızdır (kare öyle çiziyor) — kart kenarıyla çift çizgi olmasın.
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
