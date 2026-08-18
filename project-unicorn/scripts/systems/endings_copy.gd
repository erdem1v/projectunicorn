class_name EndingsCopy
extends RefCounted

# ============================================================================
# Ending newspaper copy system ("Ekonomi Postası").
# ============================================================================
# The single home for every ending's editorial text, so Erdem's voice pass is one
# read-through. Strings marked `# WORKING` are drafts pending that pass.
#
# WHY a static GDScript file (not JSON / not strings.csv): the lines are grammar-
# ASSEMBLED Turkish — a ledger line enters only if its field is populated, bankruptcy
# branches its whole layout on the phase, and Series A swaps headline sets on the
# signed terms. That is imperative logic JSON cannot express. TR is canonical; EN is
# out of scope for launch content (a later locale pass adds a parallel branch). The
# fixed RAIL chrome (SIRADA NE VAR?, WISHLIST'E EKLE…) lives in ENDING_* CSV keys —
# this file is ONLY the paper prose. Mirrors the EndingsSystem/VCPitchSystem static
# pattern; reads GameState + the ledger, writes nothing.
#
# EDITORIAL RULES (all enforced below): newspaper language not stat language; NO raw
# day count in prose (calendar framing via _span_phrase); NO cash figures / "$" in
# PROSE (origin-aware founding clause) — the stat_cells row is the ONE sanctioned "$"
# surface: it is an infographic, not prose (mockup grammar, 2026-07-29); investment
# figures in prose stay spelled-out ("milyon dolar"); quote attribution goes to the
# CROWD never to one person (no "danışman"/"mentor"); no em-dash, no emoji, no English
# finance terms ("Series A" is a proper noun; stat LABELS may use the ruled loanwords
# already in game vocabulary: MRR, pitch — never ARR).

# --- Tuning / working constants (single surface) ---
const FF_MAX_EQUITY := 18          # Founder-Friendly ceiling (inclusive): equity <= 18 AND no veto
const MIN_LEDGER_LINES := 4
const MAX_LEDGER_LINES := 6
const YEAR_DAYS := 350             # >= → "bir yıla yakın" framing
const ISSUE_PERIOD_DAYS := 7       # weekly paper: masthead "SAYI N" = run day / 7  # WORKING
const ENGRAVING_DIR := "res://assets/endings/"

# Turkish title-case month names. Do NOT derive by lowercasing MONTH_NAMES_TR — Godot's
# case ops are not Turkish-locale-aware ("NİSAN".to_lower() mangles the dotted İ).
const MONTHS_TR_TITLE := ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
	"Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
const NUM_TR := ["sıfır", "bir", "iki", "üç", "dört", "beş", "altı", "yedi", "sekiz",
	"dokuz", "on", "on bir", "on iki"]

# Faz-1 quiet-closure generic masthead pool (the player is NOT the headline). Picked
# deterministically by hash(company) so a debug re-trigger is stable. # WORKING
const GENERIC_HEADLINES := [
	{"headline": "Rakip Girişim Yeni Yatırım Turunu Kapattı",
	 "subhead": "\"Bu çeyrek yatırım iştahının canlı kaldığı görülüyor.\" değerlendirmesi sektörde konuşuluyor."},
	{"headline": "Yatırımcılar Erken Aşamaya Bu Yıl Daha Temkinli",
	 "subhead": "Fonların ilk turlarda giderek daha seçici davrandığı belirtiliyor."},
	{"headline": "Pazar Raporu: Erken Aşamada Sağ Kalım Düşük",
	 "subhead": "Analistler, ilk yılını çıkaramayan şirket oranının yükseldiğini söylüyor."},
]


# ============================================================================
# Entry point
# ============================================================================

static func build(ending_id: String, ledger: Dictionary, ending_data: Dictionary) -> Dictionary:
	match ending_id:
		"series_a_close": return _series_a(ledger, ending_data)
		"acquisition": return _acquisition(ledger, ending_data)
		"bankruptcy": return _bankruptcy(ledger, ending_data)
		"brand_collapse": return _brand_collapse(ledger, ending_data)
		"vc_rejection_cascade": return _vc_cascade(ledger, ending_data)
		"profitable_bootstrap": return _bootstrap(ledger, ending_data)
		"running_on_fumes": return _fumes(ledger, ending_data)
		_:
			push_warning("[EndingsCopy] unknown ending_id: %s" % ending_id)
			var vs := _common(ending_id, String(ending_data.get("tone", "loss")), ledger, ending_data)
			vs.headline = String(ending_data.get("title", ""))
			vs.subhead = String(ending_data.get("frank_line", ""))
			return vs


# ============================================================================
# Per-ending builders
# ============================================================================

static func _series_a(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("series_a_close", "win", ledger, data)
	var company := _company(data)
	var equity := int(ledger.get("equity_pct", 0))
	var veto := bool(ledger.get("board_veto", false))
	var valuation := int(ledger.get("valuation_m", 0))
	var investment := int(ledger.get("investment_amount", 0))
	var seats := int(ledger.get("board_seats", 0))
	var founder_friendly := equity <= FF_MAX_EQUITY and not veto

	if founder_friendly:
		vs.variant = "founder_friendly"
		vs.headline = "%s Series A Turunu Kapattı" % company
		vs.subhead = "\"Temiz bir tur; kurucu masaya sağlam oturmuş.\" değerlendirmesi yatırım çevrelerinde dolaşıyor."  # WORKING
		vs.engraving_caption = "İmza töreninden bir an."
	else:
		vs.variant = "aggressive"
		vs.headline = "%s Series A'yı Kapattı, Kontrol El Değiştirdi" % company
		vs.subhead = "\"Para geldi, ama koltukların çoğu artık yatırımcının.\" yorumu bir fon yöneticisinin ağzından duyuldu."  # WORKING
		vs.engraving_caption = "Toplantı masasında yeni dengeler."

	var pool: Array = []
	if valuation > 0:
		pool.append("%s değerleme üzerinden %s yatırım alındı; karşılığında yüzde %d hisse verildi." % [
			_valuation_tr(valuation), _investment_tr(investment), equity])
	if seats > 0:
		var board := "Yönetim kurulunda yatırımcıya %s koltuk tanındı." % _num(seats)
		if veto:
			board += " Kritik kararlarda veto hakkı da verildi."
		pool.append(board)
	pool.append("%s, %s Series A kapısını araladı." % [_founding_clause(ledger), _span_phrase(_day(ledger))])
	if int(ledger.get("customers_signed", 0)) > 0:
		pool.append("Yolda %d kurumsal müşteri kazanıldı." % int(ledger.get("customers_signed", 0)))
	if int(ledger.get("employees", 0)) > 0:
		pool.append("Ekip %s kişilik bir kadroya ulaştı." % _num(int(ledger.get("employees", 0))))
	if int(ledger.get("pitches", 0)) > 1:
		pool.append("Birden fazla masaya oturuldu; imza sonunda geldi.")

	vs.ledger_lines = _assemble(pool, [
		"Sektör, turun ardında güçlü bir ürün hikâyesi görüyor.",
		"Yatırımın bu aşamada gelmesi, pazarın ilgisini koruduğunun işareti sayılıyor."])
	# Stat row (mockup: 4 big figures under the photo). Set per template. # WORKING
	vs.stat_cells = [
		_stat(UiTokens.format_money(investment), "YATIRIM"),
		_stat(UiTokens.format_money(valuation * 1_000_000), "DEĞERLEME"),
		_stat(str(int(ledger.get("employees", 0))), "ÇALIŞAN"),
		_stat(_pct(_founder_share(ledger)), "KURUCU HİSSESİ"),
	]
	return vs


static func _acquisition(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("acquisition", "soft_win", ledger, data)
	var company := _company(data)
	vs.headline = "%s El Değiştirdi: Ekip Kaldı, Bayrak İndi" % company
	vs.subhead = "\"Ne tam bir zafer ne de bir yenilgi; temkinli bir çıkış olarak okunuyor.\" değerlendirmesi sektörde konuşuluyor."  # WORKING
	vs.engraving_caption = "Devir sonrası boşalan bir çalışma masası."

	var pool: Array = []
	pool.append("%s, %s yeni bir çatının altına girdi." % [_founding_clause(ledger), _span_phrase(_day(ledger))])
	if int(ledger.get("customers_signed", 0)) > 0:
		pool.append("Devralınan defterde %d müşteri ilişkisi bulunuyordu." % int(ledger.get("customers_signed", 0)))
	if int(ledger.get("employees", 0)) > 0:
		pool.append("Ekibin %s kişilik çekirdeği alıcı şirkete geçti." % _num(int(ledger.get("employees", 0))))
	if int(ledger.get("product_ships", 0)) > 1:
		pool.append("Ürün, kapanışa kadar %d kez yeni sürümle güncellenmişti." % int(ledger.get("product_ships", 0)))
	if int(ledger.get("vc_rejections", 0)) > 0:
		pool.append("Bağımsız bir tur için birkaç kapı çalınmış, sonunda satış yolu seçilmişti.")

	vs.ledger_lines = _assemble(pool, [
		"Bu ölçekteki satışlar, sessiz ama sık rastlanan çıkışlar olarak görülüyor.",
		"Alıcı tarafın ekibe olan ilgisi, ürünün değerini teyit ediyor."])
	# No sale price exists in the ledger — survival/team figures instead. # WORKING
	vs.stat_cells = [
		_stat(_months_figure(_day(ledger)), "AYAKTA KALDIĞI AY"),
		_stat(str(int(ledger.get("customers_signed", 0))), "MÜŞTERİ"),
		_stat(str(int(ledger.get("employees", 0))), "ÇALIŞAN"),
		_stat(UiTokens.format_money(int(ledger.get("mrr", 0))), "MRR"),
	]
	return vs


static func _bankruptcy(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var phase := int(ledger.get("phase", 1))
	var vs := _common("bankruptcy", "loss", ledger, data)
	var company := _company(data)

	if phase <= 1:
		return _bankruptcy_quiet(ledger, data, vs)

	if phase == 2:
		vs.variant = "phase2_traction"
		vs.headline = "%s İçin Umut Veren Çıkış Yarıda Kaldı" % company
		vs.subhead = "\"İvmesi vardı; ama nakit yetişmedi.\" değerlendirmesi sektörde konuşuluyor."  # WORKING
		vs.engraving_caption = "Yarım kalmış bir ürün panosu."
	else:
		vs.variant = "phase3_hunt"
		vs.headline = "Series A Kapısındaki %s Kepenk İndirdi" % company
		vs.subhead = "\"Kapıya kadar geldi, eşiği geçemedi. Bu piyasa affetmiyor.\" yorumu yatırım çevrelerinde dolaşıyor."  # WORKING
		vs.engraving_caption = "Kapatılmış bir ofisin önünden geçenler."

	var pool: Array = []
	pool.append("%s, %s kepenk indirdi." % [_founding_clause(ledger), _span_phrase(_day(ledger))])
	if int(ledger.get("customers_signed", 0)) > 0:
		pool.append("Geride %d müşteri ilişkisi kaldı." % int(ledger.get("customers_signed", 0)))
	if int(ledger.get("customers_lost", 0)) > 0:
		pool.append("Son aylarda %d müşteri ilişkisi koptu." % int(ledger.get("customers_lost", 0)))
	if int(ledger.get("hires", 0)) > 0:
		pool.append("İşe alınan kadro dağıldı.")   # departures reads 0 today — frame on hires, never "1 istifa"
	if int(ledger.get("product_ships", 0)) > 1:
		pool.append("Ürün %d sürüme ulaşmıştı." % int(ledger.get("product_ships", 0)))
	if phase == 3 and int(ledger.get("pitches", 0)) > 0:
		pool.append("Yatırım için masalara oturuldu, ama imza gelmedi.")

	vs.ledger_lines = _assemble(pool, [
		"Nakit tükenmesinin çoğu kapanışın görünürdeki tek sebebi olduğu belirtiliyor.",
		"Benzer hikâyelerin çoğunda sorunun ürün değil, zamanlama olduğu konuşuluyor."])
	# Faz 2-3 only (the quiet faz-1 path returned above with no stat row). "$0" SON MRR
	# is editorially correct on a bankruptcy paper. # WORKING
	vs.stat_cells = [
		_stat(_months_figure(_day(ledger)), "AYAKTA KALDIĞI AY"),
		_stat(str(int(ledger.get("customers_signed", 0))), "MÜŞTERİ"),
		_stat(str(int(ledger.get("employees", 0))), "ÇALIŞAN"),
		_stat(UiTokens.format_money(int(ledger.get("mrr", 0))), "SON MRR"),
	]
	return vs


static func _bankruptcy_quiet(ledger: Dictionary, data: Dictionary, vs: Dictionary) -> Dictionary:
	# Faz-1 "iz bırakmadan": a generic sector story runs the masthead; the player's
	# closure is a small below-the-fold notice. No engraving, no ledger box.
	var company := _company(data)
	vs.variant = "phase1_quiet"
	vs.is_quiet_closure = true
	vs.is_generic_masthead = true
	vs.engraving_path = ""
	vs.engraving_caption = ""
	vs.ledger_lines = []
	var idx: int = abs(hash(company)) % GENERIC_HEADLINES.size()
	vs.headline = String(GENERIC_HEADLINES[idx].headline)
	vs.subhead = String(GENERIC_HEADLINES[idx].subhead)
	vs.quiet_notice = "Kısa Kısa: %s sessizce kapandı. Kurucusu yeni bir şey üzerinde çalıştığını söylüyor." % company  # WORKING
	return vs


static func _brand_collapse(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("brand_collapse", "loss", ledger, data)
	var company := _company(data)
	vs.headline = "İtibar Krizi %s'i Devirdi" % company
	vs.subhead = "\"Skandalı şirket değil, skandal şirketi yönetti.\" değerlendirmesi sektörde ortak kanaate dönüştü."  # WORKING
	vs.engraving_caption = "Kapanan bir ofisin karartılmış tabelası."

	var pool: Array = []
	pool.append("%s, %s güven kaybının altında kaldı." % [_founding_clause(ledger), _span_phrase(_day(ledger))])
	if int(ledger.get("customers_lost", 0)) > 0:
		pool.append("Kriz büyürken %d müşteri ilişkisi teker teker koptu." % int(ledger.get("customers_lost", 0)))
	pool.append("Marka değeri, toparlanamayacağı bir eşiğin altına indi.")
	if int(ledger.get("hires", 0)) > 0:
		pool.append("Kurulan kadro, kapanışın gölgesinde dağıldı.")

	vs.ledger_lines = _assemble(pool, [
		"Sektör, itibar krizlerinin çoğu zaman rakamlardan önce güveni tükettiğini hatırlatıyor.",
		"Benzer vakalarda toparlanmanın aylar sürdüğü, çoğu şirketin bunu bekleyemediği belirtiliyor."])
	# WORKING
	vs.stat_cells = [
		_stat(str(int(ledger.get("brand", 0))), "MARKA"),
		_stat(str(int(ledger.get("customers_lost", 0))), "KAYBEDİLEN MÜŞTERİ"),
		_stat(str(int(ledger.get("employees", 0))), "ÇALIŞAN"),
		_stat(UiTokens.format_money(int(ledger.get("mrr", 0))), "SON MRR"),
	]
	return vs


static func _vc_cascade(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("vc_rejection_cascade", "loss", ledger, data)
	var company := _company(data)
	vs.headline = "%s Yatırımcı Kapılarını Kapalı Buldu" % company
	vs.subhead = "\"Para bulamamak öldürmez; vazgeçilmiş görünmek öldürür.\" sözü yatırım çevrelerinde dolaşıyor."  # WORKING
	vs.engraving_caption = "Boş bir toplantı masası ve kapanmış klasörler."

	var pool: Array = []
	pool.append("%s, %s Series A turunu tamamlayamadı." % [_founding_clause(ledger), _span_phrase(_day(ledger))])
	if int(ledger.get("pitches", 0)) > 0:
		pool.append("Farklı masalarda görüşmeler yapıldı, ancak imza gelmedi.")
	if int(ledger.get("sheets_won", 0)) > 0:
		pool.append("Bir ara masaya teklif geldi, fakat sonuca bağlanamadı.")
	if int(ledger.get("customers_signed", 0)) > 0:
		pool.append("Ürünün %d kurumsal müşterisi vardı; bu bile turu açmaya yetmedi." % int(ledger.get("customers_signed", 0)))
	pool.append("İşleyen bir gelir vardı, ama yatırımcıyı ikna edecek ivme yakalanamadı.")

	vs.ledger_lines = _assemble(pool, [
		"Art arda gelen retlerin çoğu zaman şirketin kaderinden çok zamanlamayla ilgili olduğu konuşuluyor.",
		"Yatırım ikliminin daraldığı bir dönemde kapıların ağırlaştığı belirtiliyor."])
	# WORKING
	vs.stat_cells = [
		_stat(str(int(ledger.get("vc_rejections", 0))), "RET"),
		_stat(str(int(ledger.get("pitches", 0))), "PİTCH"),
		_stat(UiTokens.format_money(int(ledger.get("mrr", 0))), "MRR"),
		_stat(_months_figure(_day(ledger)), "AYAKTA KALDIĞI AY"),
	]
	return vs


static func _bootstrap(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("profitable_bootstrap", "win", ledger, data)
	var company := _company(data)
	vs.headline = "%s Kimseye El Açmadan Ayakta" % company
	vs.subhead = "\"Dışarıdan tek kuruş almadan büyüyen bir şirket bu piyasada nadir görülür.\" değerlendirmesi sektörde konuşuluyor."  # WORKING
	vs.engraving_caption = "Kendi imkânlarıyla kurulmuş bir çalışma odası."

	var pool: Array = []
	pool.append("%s, %s kendi ayakları üzerinde durmayı başardı." % [_founding_clause(ledger), _span_phrase(_day(ledger))])
	if int(ledger.get("customers_signed", 0)) > 0:
		pool.append("Yol boyunca %d müşteri kazanıldı ve defter dengede tutuldu." % int(ledger.get("customers_signed", 0)))
	if int(ledger.get("hires", 0)) > 0:
		pool.append("Kadro %s kişiye çıktı; hepsi kendi gelirinden ödendi." % _num(int(ledger.get("employees", 0))))
	if int(ledger.get("product_ships", 0)) > 1:
		pool.append("Ürün %d kez yenilendi." % int(ledger.get("product_ships", 0)))
	pool.append("Aylık gelir, gideri karşılayacak bir seviyeye taşındı.")

	vs.ledger_lines = _assemble(pool, [
		"Dışarıdan yatırım almadan büyümenin kontrolü kurucuda tuttuğu için giderek daha çok tercih edildiği belirtiliyor.",
		"Sektör, bu tür şirketlerin krizlere daha dayanıklı olduğunu hatırlatıyor."])
	# _founder_share reads 100 here — no signed terms on a bootstrap run. # WORKING
	vs.stat_cells = [
		_stat(UiTokens.format_money(int(ledger.get("mrr", 0))), "MRR"),
		_stat(str(int(ledger.get("customers_active", 0))), "MÜŞTERİ"),
		_stat(str(int(ledger.get("employees", 0))), "ÇALIŞAN"),
		_stat(_pct(_founder_share(ledger)), "KURUCU HİSSESİ"),
	]
	return vs


static func _fumes(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("running_on_fumes", "soft_loss", ledger, data)
	var company := _company(data)
	var phase := int(ledger.get("phase", 1))
	vs.headline = "%s İçin Süre Doldu, Zil Çalmadan Bitti" % company
	match phase:
		1: vs.subhead = "\"Daha ilk viraja gelmeden zaman tükendi.\" değerlendirmesi konuşuluyor."  # WORKING
		2: vs.subhead = "\"İvme vardı ama süre yetmedi.\" yorumu sektörde dolaşıyor."  # WORKING
		_: vs.subhead = "\"Series A kapısına kadar geldi, ama zaman kalmadı.\" değerlendirmesi yatırım çevrelerinde dolaşıyor."  # WORKING
	vs.engraving_caption = "Işıkları hâlâ yanan ama boşalmış bir ofis."

	var pool: Array = []
	pool.append("%s, %s belirlenen sürenin sonuna ancak yetişti." % [_founding_clause(ledger), _span_phrase(_day(ledger))])
	if int(ledger.get("customers_signed", 0)) > 0:
		pool.append("Geride %d müşteri ilişkisi ve tamamlanmamış bir hikâye kaldı." % int(ledger.get("customers_signed", 0)))
	if int(ledger.get("hires", 0)) > 0:
		pool.append("Kurulan kadro son güne kadar iş başındaydı.")
	# Bu satır KOŞULSUZDU: sıfır gelirli bir run'da bile "Gelir vardı" diyordu — üstelik
	# hemen yanında MRR $0 yazan istatistik hücresiyle aynı ekranda, ve _assemble havuzu
	# MIN_LEDGER_LINES'a tamamladığı için o yalan GARANTİLİ basılıyordu. Demo'nun dönüşüm
	# ekranı burası.
	# ELSE şart: satırı yalnızca koşullamak havuzu en kötü durumda 1 satır + 2 yedek = 3'e
	# düşürür ve gazete eksik dizilirdi. Her iki dal da tam bir satır ekler.
	if int(ledger.get("mrr", 0)) > 0 or int(ledger.get("customers_signed", 0)) > 0:
		pool.append("Gelir vardı, ama ne kâr ne de yeni bir tur için yeterliydi.")
	else:
		pool.append("Gelir hiç başlamadı; sayaç, ilk ödeme gelmeden doldu.")
	if int(ledger.get("product_ships", 0)) > 1:
		pool.append("Ürün %d sürüm görmüş, gelişmeye devam ediyordu." % int(ledger.get("product_ships", 0)))

	vs.ledger_lines = _assemble(pool, [
		"Sektör, çoğu şirketin zaferle yıkım arasındaki bu gri bölgede sonlandığını hatırlatıyor.",
		"Zamanında bir karar ya da bir turun hikâyeyi değiştirebileceği konuşuluyor."])
	# WORKING
	vs.stat_cells = [
		_stat(_months_figure(_day(ledger)), "AYAKTA KALDIĞI AY"),
		_stat(UiTokens.format_money(int(ledger.get("mrr", 0))), "MRR"),
		_stat(str(int(ledger.get("customers_active", 0))), "MÜŞTERİ"),
		_stat(str(int(ledger.get("employees", 0))), "ÇALIŞAN"),
	]
	return vs


# ============================================================================
# Assembly helpers (all pure)
# ============================================================================

static func _common(ending_id: String, tone: String, ledger: Dictionary, data: Dictionary) -> Dictionary:
	var company := _company(data)
	return {
		"ending_id": ending_id,
		"tone": tone,
		"is_win": tone == "win" or tone == "soft_win",
		"variant": "",
		"masthead": "EKONOMİ POSTASI",
		"date_line": _date_line(ledger),
		"headline": "",
		"subhead": "",
		"engraving_path": _engraving_path(ending_id, ledger),
		"engraving_caption": "",
		"ledger_title": "RAKAMLARLA %s" % _tr_upper(company),
		"ledger_lines": [],
		"stat_cells": [],
		"is_quiet_closure": false,
		"is_generic_masthead": false,
		"quiet_notice": "",
	}


static func _company(data: Dictionary) -> String:
	return String(data.get("company_name", GameState.company_name))


static func _day(ledger: Dictionary) -> int:
	return int(ledger.get("day", 0))


static func _num(n: int) -> String:
	if n >= 0 and n < NUM_TR.size():
		return NUM_TR[n]
	return str(n)


static func _stat(figure: String, label: String) -> Dictionary:
	# One stat-row cell: a big serif FIGURE over a small mono LABEL (mockup grammar).
	# Labels arrive pre-uppercased TR literals — tr_upper is only for derived text.
	return {"figure": figure, "label": label}


static func _months_figure(days: int) -> String:
	# Stat-row month count as DIGITS — the infographic surface, unlike _span_phrase
	# which frames the same span as prose (Rule 2 keeps raw day counts off the paper).
	return str(int(ceil(days / 30.0)))


static func _pct(n: int) -> String:
	# Turkish percent style: sign before the number ("%82" — mockup grammar).
	return "%%%d" % n


static func _founder_share(ledger: Dictionary) -> int:
	# Founder's remaining share after the signed round; run_equity_pct reads 0 unless a
	# term sheet was signed (bootstrap → 100). NOT GameState.get_founder_equity(): hires
	# carry no equity and the investor's dilution never enters CharacterRegistry, so that
	# read would say 100 on the very paper whose headline announces the round.
	# investor_equity_pct, not equity_pct: the founder really does own Frank's 4% less,
	# even though the newspaper's valuation sentence stays about the Series A alone.
	# Falls back to the Series-A field so an older ledger dict still reads correctly.
	return maxi(0, 100 - int(ledger.get("investor_equity_pct", ledger.get("equity_pct", 0))))


static func _span_phrase(days: int) -> String:
	# Rule 2: the paper never prints a raw day count — it frames time in calendar months.
	if days >= YEAR_DAYS:
		return "bir yıla yakın sürede"
	var m := int(ceil(days / 30.0))
	if m <= 1:
		return "bir aydan kısa sürede"
	return "%s aydan kısa sürede" % _num(m)


static func _founding_clause(ledger: Dictionary) -> String:
	# Rule 3: the paper can't know the treasury — the founding is described by origin,
	# never by a cash figure.
	match String(ledger.get("origin", "self_made")):
		"self_made": return "Kurucunun kendi birikimiyle kurduğu şirket"
		"heir": return "Aile sermayesiyle kurulan şirket"
		"corporate_refugee": return "Kurumsal bir geçmişin ardından kurulan şirket"
		_:
			return "%s ayında kurulan şirket" % _founding_month(ledger)


static func _founding_month(ledger: Dictionary) -> String:
	var m := int(ledger.get("start_month", 1))
	return MONTHS_TR_TITLE[clampi(m - 1, 0, 11)]


static func _date_line(ledger: Dictionary) -> String:
	# Masthead meta line: full calendar date + issue number ("14 KASIM 2027 · SAYI 214").
	# A date and an edition, never a day count — the raw count lives ONLY in the rail's
	# run-meta line (Rule 2). Ledger-driven (not GameState.day) so debug_all_view_states
	# renders deterministically. MONTH_NAMES_TR is already correct Turkish uppercase.
	var day := _day(ledger)
	var d: Dictionary = GameState.get_date_dict(day if day > 0 else -1)
	var issue := maxi(1, int(float(day) / ISSUE_PERIOD_DAYS))
	return "%d %s %d · SAYI %d" % [int(d.day), GameState.MONTH_NAMES_TR[int(d.month) - 1], int(d.year), issue]


static func _valuation_tr(valuation_m: int) -> String:
	return "%d milyon dolar" % valuation_m


static func _investment_tr(dollars: int) -> String:
	# Rule 4: spelled-out currency, no "$", no abbreviations. Round to nearest million
	# for headline-style figures (mockup: "4 milyon dolar").
	var m := int(round(dollars / 1_000_000.0))
	if m < 1:
		m = 1
	return "%d milyon dolar" % m


static func _engraving_path(ending_id: String, ledger: Dictionary) -> String:
	# One illustration per ending id (Series A variants share series_a_close.png). Faz-1
	# bankruptcy has NO art (a below-the-fold notice has no art slot).
	if ending_id == "bankruptcy" and int(ledger.get("phase", 1)) <= 1:
		return ""
	return ENGRAVING_DIR + ending_id + ".png"


static func _assemble(pool: Array, backups: Array) -> Array:
	# Include only populated pool lines; top up from field-independent sector backups
	# until >= MIN; cap at MAX. Guarantees the "Rakamlarla" box never reads sparse.
	var lines: Array = []
	for l in pool:
		if String(l) != "":
			lines.append(String(l))
	var i := 0
	while lines.size() < MIN_LEDGER_LINES and i < backups.size():
		lines.append(String(backups[i]))
		i += 1
	if lines.size() > MAX_LEDGER_LINES:
		lines = lines.slice(0, MAX_LEDGER_LINES)
	return lines


static func _tr_upper(s: String) -> String:
	# Turkish-safe uppercase for the ledger title — delegates to the single home
	# UiTokens.tr_upper ("PromptPilot" → "PROMPTPİLOT"; 2026-07-21 sweep addendum).
	return UiTokens.tr_upper(s)


# ============================================================================
# Debug — full copy matrix for the voice/layout gallery (no game states needed)
# ============================================================================

static func debug_all_view_states() -> Array:
	# Every template + variant against ONE synthetic rich ledger, so Erdem can voice-pass
	# and layout-check the whole surface at once. Each entry: {label, vs}.
	var ledger := {
		"day": 156, "phase": 3, "origin": "self_made", "start_month": 1, "start_year": 2026,
		"cash": 24000, "mrr": 6400, "peak_mrr": 8200, "brand": 30, "reputation": 10,
		"customers_active": 6, "customers_signed": 9, "customers_lost": 3, "customers_expanded": 2,
		"employees": 5, "hires": 4, "departures": 0,
		"product_version": 3, "product_ships": 3,
		"pitches": 2, "sheets_won": 1, "vc_rejections": 1, "pushes_attempted": 2, "pushes_won": 1,
		"investment_amount": 3_960_000, "valuation_m": 22, "equity_pct": 18, "board_seats": 1, "board_veto": false,
		"scandals_total": 1, "scandals_managed": 0,
	}
	var data := {"company_name": "PromptPilot", "founder_name": "Deniz", "tone": "loss"}
	var out: Array = []
	out.append({"label": "series_a · founder_friendly", "vs": build("series_a_close", ledger, data)})
	var agg := ledger.duplicate(); agg.equity_pct = 32; agg.board_veto = true; agg.board_seats = 2
	out.append({"label": "series_a · aggressive", "vs": build("series_a_close", agg, data)})
	out.append({"label": "acquisition", "vs": build("acquisition", ledger, data)})
	for p in [1, 2, 3]:
		var bl := ledger.duplicate(); bl.phase = p
		out.append({"label": "bankruptcy · faz %d" % p, "vs": build("bankruptcy", bl, data)})
	out.append({"label": "brand_collapse", "vs": build("brand_collapse", ledger, data)})
	out.append({"label": "vc_rejection_cascade", "vs": build("vc_rejection_cascade", ledger, data)})
	out.append({"label": "profitable_bootstrap", "vs": build("profitable_bootstrap", ledger, data)})
	for p in [1, 2, 3]:
		var fl := ledger.duplicate(); fl.phase = p
		out.append({"label": "running_on_fumes · faz %d" % p, "vs": build("running_on_fumes", fl, data)})
	return out
