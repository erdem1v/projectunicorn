class_name HRLedger
extends RefCounted

# EKİP → KADRO defteri — onaylı Terminal düzeni (Unicorn Skins 9b).
#
# Kart listesi EMEKLİ. Defter tam genişlikte tek bir tablodur: etiketli mono sütun
# başlıkları, altlarında ÇIPLAK RAKAMLAR. Kilitli reçetenin çekirdek kuralı bu —
# "hiçbir sayı, oyuncuya 'bu ne?' dedirtmeden durmaz".
#
# SÜTUN GENİŞLİKLERİ 1920'lik mockup'tan BİREBİR ölçüldü; eyeball yok:
#   ÇALIŞAN esnek · ROLLER·LİDERLİK 370 · GÖREV 260 · DENEYİM 140 · DURUM 160 ·
#   TRAIT 90 · MAAŞ 150 · MORAL 160 · ⋯ 44
#
# ROL AÇIKLAMASI SATIRDA DEĞİL: satır tek satır yüksekliğinde ve açıklama metni defteri
# üç katına çıkarırdı. HOVER TOOLTIP'te.
# TASARIM GENİŞLİKLERİ (1920'de çizildi). Toplamı 1374 + ÇALIŞAN hücresi — %125'te
# mantıksal viewport 1536'ya İNİYOR (content_scale_factor büyütmez, küçültür) ve
# MORAL sütunuyla ⋯ düğmesi ekranın dışına çıkıyordu.
const W_ROLES_WIDE := 370
const W_TASK_WIDE := 260
const W_EXPERIENCE_WIDE := 140
const W_STATE_WIDE := 160
const W_SALARY_WIDE := 150
const W_MORALE_WIDE := 160

# YOĞUN KADEME. top_bar._apply_density'nin aynı grameri: dar viewport'ta geniş
# sütunlar daralır ve HİÇBİR ŞEY DÜŞMEZ — her sütun içeriğini korur.
const W_ROLES_DENSE := 300
const W_TASK_DENSE := 232   # +52: MORAL çubuğunun geri verdiği pay buraya gitti (D5)
const W_EXPERIENCE_DENSE := 104
const W_STATE_DENSE := 140
const W_SALARY_DENSE := 118
const W_MORALE_DENSE := 124
const DENSE_BELOW := 1600   # mantıksal genişlik eşiği (top_bar ile aynı sayı)
# YUKARIDAKİ ESKİ NOT ("sütunları 100px daraltmak kesim yerini oynatmadı, demek ki
# sorun sayfa kabuğunda") YANLIŞTI ve 2026-08-22'de çürütüldü. Kesim yeri
# oynamadı çünkü SÜTUN BAŞLIĞI BU SABİTLERİ HİÇ OKUMUYORDU: `_dense` statik ve
# `false` doğuyor, başlık ise ölçümden ÖNCE kuruluyordu. Okumadığı bir sabiti
# daraltmak elbette hiçbir şeyi oynatmaz. İki onarım: ölçüm `_build_chrome`in başına
# taşındı ve başlık `_rebuild`de yeniden kuruluyor (hr_tab._rebuild_header).
# Kalan taşma MORAL çubuğunun sabit 150'sindeydi — o da kademeye bağlandı.

const W_TRAIT := 90
# `W_MENU` EMEKLİ (R1, 2026-08-22): ⋯ sütunu kalktı. Menüyü açan tek şey satırın
# kendisi ve çapa o karttir — 44px'lik bir düğme İKİNCİ bir çapa demekti ve iki yol
# gözünür biçimde farklı yerlerde menü açıyordu.

## Defter kurulurken bir kez ölçülür. Statik, çünkü çizim de statik ve başlık ile
## satırların AYNI sayıyı okuması şart — iki farklı genişlik iki farklı tablo demek.
static var _dense: bool = false


## Ev sahibi (hr_tab) defteri kurmadan ÖNCE çağırır.
static func measure(viewport_width: float) -> void:
	_dense = viewport_width > 0.0 and viewport_width < float(DENSE_BELOW)


static func w_roles() -> int:      return W_ROLES_DENSE if _dense else W_ROLES_WIDE
static func w_task() -> int:       return W_TASK_DENSE if _dense else W_TASK_WIDE
static func w_experience() -> int: return W_EXPERIENCE_DENSE if _dense else W_EXPERIENCE_WIDE
static func w_state() -> int:      return W_STATE_DENSE if _dense else W_STATE_WIDE
static func w_salary() -> int:     return W_SALARY_DENSE if _dense else W_SALARY_WIDE
static func w_morale() -> int:     return W_MORALE_DENSE if _dense else W_MORALE_WIDE

## Satırın aksiyon sözlüğü. ACTION_MENU satır (ve ⋯ düğmesi) tıklamasıdır: DÖRT kişi
## aksiyonunu taşıyan popover'ı açar. Eğitim 2026-08-22'de o menüye girdi — onaylı
## tasarımda satırda kendi düğmesi yok ve kişi başına bir karar olduğu için menü onun evi.
const ACTION_MENU := "menu"
const ACTION_RAISE := "raise"
const ACTION_FIRE := "fire"
const ACTION_TRAIN := "train"
const ACTION_PROMOTE := "promote"   # §13.3 dördüncü satır


## Sütun başlığı satırı. Bir kez, defterin en üstünde — her grupta tekrar ETMEZ
## (mockup böyle: başlık tablonun başlığıdır, bölümün değil).
static func column_header() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	row.custom_minimum_size = Vector2(0, 26)
	row.add_child(_head(tr_key("HR_COL_EMPLOYEE"), 0, HORIZONTAL_ALIGNMENT_LEFT))
	row.add_child(_head(tr_key("HR_COL_ROLES_LEADERSHIP"), w_roles()))
	row.add_child(_head(tr_key("HR_COL_TASK"), w_task()))
	row.add_child(_head(tr_key("HR_COL_EXPERIENCE"), w_experience()))
	row.add_child(_head(tr_key("HR_COL_STATE"), w_state()))
	row.add_child(_head(tr_key("HR_COL_TRAIT"), W_TRAIT))
	row.add_child(_head(tr_key("HR_COL_SALARY"), w_salary()))
	row.add_child(_head(tr_key("HR_COL_MORALE"), w_morale()))
	var wrap := PanelContainer.new()
	wrap.theme_type_variation = &"HeaderBand"
	wrap.add_child(row)
	return wrap


## Bir çalışan satırı. `refs` moral yerinde-boyama referanslarını doldurur
## (hr_tab'ın mevcut _morale_refs sözleşmesi korunuyor).
static func row(emp: Character, on_action: Callable, refs: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"LedgerRow"
	# HOVER = KENAR. Dolgu bayt-aynı kalır; yalnız çerçeve açılır. İki varyasyonun
	# content margin'leri de aynı, yoksa satır hover'da bir piksel zıplardı.
	card.mouse_entered.connect(func() -> void: card.theme_type_variation = &"LedgerRowHover")
	card.mouse_exited.connect(func() -> void: card.theme_type_variation = &"LedgerRow")
	card.gui_input.connect(_on_row_input.bind(emp.id, on_action, card))
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.tooltip_text = HRConstants.role_phase_hint(emp.role)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	card.add_child(row)

	var muted: bool = emp.status != HRConstants.STATUS_ACTIVE

	# --- ÇALIŞAN: baş harf rozeti + ad + yer rozeti + rol ---
	var who_cell := HBoxContainer.new()
	who_cell.add_theme_constant_override("separation", UiTokens.SPACE_L)
	who_cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	who_cell.add_child(UiFactory.make_avatar(UiFactory.initials_of(emp.character_name), 32))
	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", 2)
	who.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	# AD SATIRI YALNIZ AD (C3, 2026-08-21). BOŞTA / AŞIRI YÜK buradan DURUM sütununa
	# taşındı — Görevler sayfası (10b) ikisini de zaten orada çiziyordu, yani iki sayfa
	# aynı rozeti iki ayrı yerde gösteriyordu.
	who.add_child(UiFactory.make_label(emp.character_name, &"RowName"))
	who.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.role_label(emp.role)), &"MicroLabel"))
	who_cell.add_child(who)
	row.add_child(who_cell)

	# --- ROLLER · LİDERLİK: iki alan + hairline + Liderlik, hepsi beş yıldız ---
	row.add_child(HRUiShared.role_area_cell(emp, w_roles(), muted))

	# --- GÖREV: aktif sürümün adıyla, ya da alan ifadesiyle ---
	row.add_child(_task_cell(emp, muted))

	# --- DENEYİM: mini bar + % ---
	row.add_child(_experience_cell(emp, refs))

	# --- DURUM çipleri ---
	row.add_child(_state_cell(emp))

	# --- TRAIT: tek ikon, adı hover'da ---
	row.add_child(HRUiShared.trait_cell(emp.traits, W_TRAIT))

	# --- MAAŞ ---
	row.add_child(_num(HRUiShared.money(emp.monthly_salary), w_salary(), muted))

	# --- MORAL: bar + sayı (mevcut yerinde-boyama yolu korunuyor) ---
	var morale_cell := HRUiShared.morale_row(emp.morale, refs, false)
	morale_cell.custom_minimum_size = Vector2(w_morale(), 0)
	morale_cell.size_flags_horizontal = Control.SIZE_SHRINK_END
	row.add_child(morale_cell)


	_pass_clicks_through(row)
	return card


## Satırın İÇİ tıklamayı yutmasın. Godot'ta ProgressBar (deneyim ve moral barları)
## MOUSE_FILTER_STOP ile doğar, yani bir satırın tam ortasındaki iki geniş şeride
## tıklamak gui_input'a HİÇ ulaşmıyordu: satır "bazen açılıyor" gibi davranıyordu.
## Butonlar hariç her şey IGNORE'a çekiliyor — buton kendi tıklamasının sahibi.
## TOOLTIP TAŞIYAN düğümler de muaf: hover'ı yiyen bir IGNORE, 9f'in rozet
## baloncuklarını sessizce öldürürdü.
static func _pass_clicks_through(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			continue
		if child is Control:
			var c: Control = child
			if c.tooltip_text == "":
				c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_pass_clicks_through(child)


## Boş grup satırı — kesikli kenar + "Henüz kimse yok" + satır içi hayalet düğme.
static func empty_row(on_search: Callable) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"EmptyRow"
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var lbl := UiFactory.make_label(tr_key("HR_EMPTY_ROW"), &"EmptyRowLabel")
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(lbl)
	row.add_child(HRUiShared.action_button(tr_key("HR_SEARCH_START_INLINE"), on_search))
	card.add_child(row)
	return card


# --- hücreler ---------------------------------------------------------------

static func _head(text: String, width: int, align: int = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := UiFactory.make_label(text, &"ColumnHeader")
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if width > 0:
		l.custom_minimum_size = Vector2(width, 0)
	else:
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


static func _num(text: String, width: int, muted: bool) -> Label:
	var l := UiFactory.make_label(text, &"MetricValueInk")
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(width, 0)
	if muted:
		l.modulate = Color(1, 1, 1, 0.45)
	return l


## BOŞTA / AŞIRI YÜK — DURUM sütununun yer rozeti (C3). Hover açıklamaları 9f'ten
## birebir; ikisi de motorun türettiği okumalar, saklanan bayrak yok.
static func _placement_badge(emp: Character) -> Control:
	if HRSystem.is_overloaded(emp):
		var over: Control = UiFactory.make_state_chip(tr_key("HR_BADGE_OVERLOADED_JOBS"),
			UiTokens.ACCENT, UiTokens.AMBER_BG, UiTokens.ACCENT)
		over.tooltip_text = tr_key("HR_OVERLOAD_HINT")
		# §13.3: PASS, STOP DEĞİL. STOP tooltip'i çalıştırır ama satır tıklamasını YUTAR, ve
		# o tıklama menüyü açan TEK yol (hr_ledger.gd:44-46). Konvansiyon bir dosya ötede
		# yazılı ve trait ikonunda uygulanıyor (hr_ui_shared.gd:137-139).
		over.mouse_filter = Control.MOUSE_FILTER_PASS
		return over
	if HRSystem.is_idle(emp):
		var idle: Control = UiFactory.make_state_chip(tr_key("HR_BADGE_IDLE"),
			UiTokens.INK_DIM, Color(0, 0, 0, 0), UiTokens.SEPARATOR)
		idle.tooltip_text = tr_key("HR_IDLE_HINT")
		idle.mouse_filter = Control.MOUSE_FILTER_PASS   # §13.3 — bkz. yukarıdaki gerekçe
		return idle
	return null


## GÖREV hücresi (9b). Aktif bir sürümün üzerinde çalışıyorsa ÜRÜN ADIYLA yazılır —
## "Pulse v1'de çalışıyor" — çünkü oyuncunun kafasındaki şey o sürümdür, bir alan adı
## değil. Satış ve Müşteri İlişkileri ürüne bağlı olmadığı için orada alan ifadesi kalır;
## ürünsüz dönemde BÜTÜN sütun alan ifadesine düşer. Boştaki için tire.
## §12.2'nin iş cümleleri. Build, AKTİF SÜRÜMÜN ADIYLA okunur — "oyuncunun kafasındaki
## şey o sürümdür, bir alan adı değil" — ve ürün yokken alan-nötr bir cümleye düşer.
static func _job_sentence(job_id: String) -> String:
	if job_id == HRConstants.JOB_BUILD:
		var build: FeatureBuild = ProductSystem.get_active_build()
		if build != null:
			return tr_key("HR_TASK_ON_VERSION").format({
				"product": build.product_name,
				"version": int(GameState.get_flag("mvp_version", 1)),
			})
	return tr_key("HR_TASK_ON_JOB_%s" % job_id.to_upper())


## İki iş hâlinde KISA ETİKET — işin adından türetilir (§12.2).
static func _short_job_label(job_id: String) -> String:
	if job_id == HRConstants.JOB_BUILD:
		var build: FeatureBuild = ProductSystem.get_active_build()
		if build != null:
			return "%s v%d" % [build.product_name, int(GameState.get_flag("mvp_version", 1))]
	return HRConstants.job_label(job_id)


static func _task_cell(emp: Character, muted: bool) -> Control:
	# §12.2: GÖREV hücresi kişinin ne yaptığını CÜMLE olarak okur, iş id'si olarak değil.
	#   Tek iş  → o işin cümlesi (Pulse v1'de çalışıyor · Satışta görev alıyor · ...)
	#   İki iş  → iki cümle yerine iki KISA ETİKET, orta nokta ayracıyla; uzun cümle satırı taşırır
	#   Hiç iş  → Boşta (ayrı bir rozet DEĞİL, bu sütunun kendi metni)
	var text: String = tr_key("HR_TASK_NONE")
	var jobs: Array[String] = emp.assigned_job_ids
	if jobs.size() >= 2:
		var labels: Array[String] = []
		for job_id in jobs:
			labels.append(_short_job_label(String(job_id)))
		text = " · ".join(labels)
	elif jobs.size() == 1:
		text = _job_sentence(String(jobs[0]))
	var lbl := UiFactory.make_label(text, &"RowMeta", UiTokens.INK_MUTED)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(w_task(), 0)
	lbl.clip_text = true
	if muted:
		lbl.modulate = Color(1, 1, 1, 0.45)
	return lbl


## Hangi ALANIN deneyimi gösteriliyor: kişinin BUGÜN biriktirdiği alan, yani ilk
## atamasının alanı — HRSystem.tick_experience de aynı seçimi yapıyor, o yüzden çubuk
## gerçekten hareket eden sayaçtır. Boştaki kimse öğrenmiyor; sütun o zaman rolün anahtar
## alanını gösterir ve kıpırdamaz, ki "boşta duruyor" zaten kendi rozetiyle söyleniyor.
static func _experience_area(emp: Character) -> String:
	if not emp.assigned_jobs.is_empty():
		var assigned: String = String(emp.assigned_jobs[0])
		# Araştırma bir YETENEK değil, yalnız atanabilir bir slot — orada sayaç yok.
		if HRConstants.AREAS.has(assigned):
			return assigned
	return HRConstants.role_key_area(emp.role)


## DENEYİM hücresi: 4px iz + dolgu + altında yüzde.
static func _experience_cell(emp: Character, refs: Dictionary) -> Control:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(w_experience(), 0)
	box.add_theme_constant_override("separation", 3)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	# §5.1 TEK BAR. Alan başına sayaçlar emekli ve artık YAZILMIYOR — bu sütun onları
	# okumaya devam ettiği için herkeste %0 gösteriyordu. Bar hep 0–100 çizilir; değişen,
	# arkasındaki EŞİKTİR ve o kişinin gelişmişliğiyle büyür.
	var value: int = emp.experience_raw
	var threshold: int = maxi(emp.experience_threshold, 1)
	var pct: int = int(round(CharacterRegistry.experience_ratio(emp) * 100.0))
	var val := UiFactory.make_label(Fmt.percent(pct, 0), &"RowMeta")
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var bar := ProgressBar.new()
	bar.theme_type_variation = &"BuildProgress"
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(w_experience() - 24, 4)
	bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bar.max_value = threshold
	bar.value = value
	box.add_child(bar)
	box.add_child(val)
	refs["experience_bar"] = bar
	refs["experience_label"] = val
	return box


## DURUM sütunu (160px). En fazla bir çip: eğitim · izin · YENİ · dikkat rozeti · tire.
## EĞİTİME GÖNDER düğmesi buradan ÇIKTI (2026-08-22) — onaylı tasarımda satırda düğme
## yok, eğitim ⋯ menüsünün dördüncü satırı.
static func _state_cell(emp: Character) -> Control:
	# §13.3 TEK EV — bkz. HRUiShared.status_cell. Bu fonksiyon eskiden ALTI durumu kendi
	# çiziyordu ve HER İSABETTEN SONRA DÖNÜYORDU, yani §15.1'in adıyla verdiği örnek
	# ("aşırı yükten morali 35'in altına düşmüş bir çalışan HEM AŞIRI YÜK HEM Ayrılabilir
	# taşır") ikinci rozetini ASLA gösteremiyordu. Matris de kendi üç durumluk listesini
	# çiziyordu; aynı kişi iki sayfada iki farklı şey okuyordu.
	return HRUiShared.status_cell(emp, w_state())


## Amber çip. Kehribar SEMANTİK DEĞİL (marka aksanı) ve renk körü modunda yerinde kalır,
## o yüzden sabit token'dan okunur.
static func _amber_chip(text: String) -> Control:
	return UiFactory.make_state_chip(text, UiTokens.ACCENT, UiTokens.AMBER_BG, UiTokens.ACCENT)


## Satır tıklaması = kişi aksiyonları menüsü. SÖZLEŞME `(emp_id, action, anchor)` —
## sıra ve çapa şart, yoksa popover kendini konumlandıramaz.
static func _on_row_input(ev: InputEvent, emp_id: String, on_action: Callable, anchor: Control) -> void:
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		on_action.call(emp_id, ACTION_MENU, anchor)


## Statik bağlamda çeviri: tr() bir Object ister, burada yok.
static func tr_key(key: String) -> String:
	return TranslationServer.translate(key)
