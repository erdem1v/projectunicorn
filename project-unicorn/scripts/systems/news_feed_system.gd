class_name NewsFeedSystem
extends RefCounted

# Haber akışı motoru (Dünya İnandırıcılığı Fix 4) — ticker'ın VERİ kaynağı.
# İngilizce placeholder havuzunun yerine, üç gerçek kaynaktan ağırlıklı akış:
#
#   Sektör (~%50)  — faz + subgenre etiketli küratörlü havuz (aşağıda)
#   Rakip  (~%30)  — RivalRegistry.get_market_snapshot'taki GERÇEK hareketlerden
#                    türetilir, asla uydurulmaz; ilgililik kapısından geçer
#   Biz    (≤%20)  — EventBus.headline_added kanalının pasif yakalanışı; SERT kapı:
#                    marka ne kadar parlarsa parlasın akışın beşte birini aşamaz
#                    (ticker dünyadır, bizim basın ofisimiz değil)
#
# Kablolama: TimeManager._tick_industry_events → daily_tick() (slot 7a — sales ve
# rivals SONRASI); TimeManager._ready → headline_added → on_headline_added.
# Kalıcı durum: GameState.news_feed (fields-not-systems; tek yazar bu dosya).
# RNG YASAK (ev kuralı) — tüm seçimler hash tabanlı deterministik aritmetik.
# Repeat yok: bir sektör satırı havuz tükenene dek tekrar etmez, sonra reshuffle.
#
# ODA/ticker tüketici sözleşmesi: get_stream() (en yeni önce) + get_lines_for_day(day)
# + EventBus.news_stream_changed (gün-sonu repaint kancası). Satır şekli:
#   {day: int, kind: "sektor"|"rakip"|"biz", src: String, txt: String}
# news_ticker.gd'nin {src, txt} vokabüleriyle bire bir uyumlu.
#
# # WORKING TR — bu dosyadaki tüm oyuncuya görünen metin çalışma metnidir; ses
# geçişi content fazında.

# --- Ayar yüzeyi (tümü WORKING; kalibrasyon seansı) ---------------------------
const TARGET_SEKTOR := 0.5
const TARGET_RAKIP := 0.3
const TARGET_BIZ := 0.2
const BIZ_HARD_CAP := 0.20          # (biz+1)/(toplam+1) bu oranı AŞAMAZ — sert kapı
const DAILY_LINES_MIN := 3
const DAILY_LINES_MAX := 5
const STREAM_CAP := 30
const BIZ_BUFFER_CAP := 10
# Aynı rakip bu kadar gün içinde ikinci kez haber OLMAZ. Gün bazlı cooldown,
# adet bazlı "son N rakip" değil: adet bazlısı, nitelikli rakip sayısı N'in
# altına düşünce kendini kilitliyordu (yeni emisyon yok → rotasyon yok →
# sonsuz dışlama; 90 günlük smoke bunu %93 sektörle yakaladı).
const RIVAL_COOLDOWN_DAYS := 2
# "Büyük hamle" eşiği, % puan — dev/yerleşik/holding ancak bunu aşarak haber olur.
# Pay modelinin (rival_registry._share_at) GERÇEK dağılımından türetildi; 10 alt-tür
# × 11 satır × 200 gün taraması haftalık hareketin İKİ banda ayrıldığını gösteriyor:
#   RUTİN  — büyüme terimi tam olarak seed × momentum × 0,028 ve hep aynı kalır;
#            tavanı 0,051 (lider startup) / 0,045 (lider yerleşik) / 0,015 (holding).
#   SIÇRAMA— wobble'ın hafta bloğu atladığı tek gün (gün 70); 0,061 (ma_doruk, id
#            global olduğu için HER koşuda aynı) ile 0,271 (startup) arasında.
# Eşik iki bandın ARASINA oturur: rutin hiçbir zaman "büyük" sayılmaz, gerçek sıçrama
# her zaman sayılır. Ölçülen kapı: yerleşik alt-türlerin 8/10'unda + holding her
# koşuda haber üretir. Bir tık aşağısı (0,05) rutini haber yapar, bir tık yukarısı
# (0,07) holdingi tamamen susturur — pencere dar ve bilerek dar.
# Eski değer 0,75'ti: modelin ürettiği EN BÜYÜK hamlenin ~3 katı, yerleşiğin
# realize maksimumunun ~6 katı — yani dal hiç açılmadı ve "heavy" satır hiç akmadı.
# DEV İSTİSNASI: TEMPLATE[0].momentum = 0 → pay eğrisi sabit → delta tam 0 → satır
# daha moved_recently kapısında elenir. Hiçbir eşik devi haber yapamaz; pay momentumu
# ile KALİTE momentumu aynı alan olduğundan (RivalCatalog.TEMPLATE, advance_all'ın
# "giants are static" garantisi) ayrı bir pay-momentumu alanı açılmadan devin haberi
# yoktur. Özel-durum yamamak yasak: yalan hareket üretir.
const RIVAL_BIG_MOVE_PCT := 0.06
const RIVAL_NEAR_BAND_PCT := 3.0    # startup, oyuncunun payına bu kadar yakınsa ilgilidir

# Kurgusal yayın adları (gerçek marka yok; Ekonomi Postası ending gazetesiyle
# aynı evren). Sektör + rakip satırlarının kaynak rozeti buradan seçilir.
const OUTLETS := ["Ekonomi Postası", "TeknoGündem", "Girişim Bülteni", "Sektör Telgrafı"]

# --- Sektör havuzu: {id, txt, phases: [1..3], pool: "ai"|"saas"|"any"} --------
# Faz 1 Bootstrap = tohum iklimi; Faz 2 Traction = değerleme/kanıt sohbeti;
# Faz 3 Series A Hunt = regülasyon + geç aşama iklimi. Loanword beyaz listesi
# (pitch, startup, demo, momentum, MRR, runway, churn + VC) dışında İngilizce yok.
const SEKTOR_POOL := [
	# --- Faz 1 — tohum iklimi (any) ---
	{"id": "s_seed_temkin", "txt": "Tohum yatırımcıları bu çeyrek temkinli; kapılar kapanmıyor ama yavaş açılıyor.", "phases": [1], "pool": "any"},
	{"id": "s_seed_istah", "txt": "Erken aşama iştahı canlı; melek ağları yeni dosya kabul ediyor.", "phases": [1], "pool": "any"},
	{"id": "s_demo_sezon", "txt": "Demo günü sezonu açıldı; yatırımcı takvimleri şimdiden dolu.", "phases": [1, 2], "pool": "any"},
	{"id": "s_kurucu_yorgun", "txt": "Kurucu tükenmişliği panellerde konuşuluyor; çözüm öneren yok.", "phases": [1, 2, 3], "pool": "any"},
	{"id": "s_maas_dalga", "txt": "Yazılımcı maaşları yine gündemde; küçük ekipler işe alımda zorlanıyor.", "phases": [1, 2], "pool": "any"},
	{"id": "s_ofis_tarti", "txt": "Uzaktan çalışma tartışması bitmedi; ofise dönüş çağrıları sertleşti.", "phases": [1, 2, 3], "pool": "any"},
	{"id": "s_bulut_fatura", "txt": "Bulut faturaları masada; altyapı maliyeti yeniden pazarlık konusu.", "phases": [1, 2], "pool": "any"},
	{"id": "s_hukuk_sirket", "txt": "Şirket kuruluş işlemleri kolaylaştı; girişim sayısı rekor kırıyor.", "phases": [1], "pool": "any"},
	{"id": "s_yurtdisi_fon", "txt": "Yabancı fonlar bölgeye bakıyor; köprü ofisler art arda açılıyor.", "phases": [1, 2], "pool": "any"},
	{"id": "s_banka_kredi", "txt": "Bankalar girişim kredisinde hâlâ ürkek; teminat şartları ağır.", "phases": [1], "pool": "any"},
	{"id": "s_kuluçka", "txt": "Kuluçka merkezleri kontenjan artırdı; başvuru yığılması var.", "phases": [1], "pool": "any"},
	{"id": "s_hackathon", "txt": "Hafta sonu maratonlarından çıkan ekipler yatırımcı radarında.", "phases": [1], "pool": "any"},
	# --- Faz 1-2 — ürün/pazar (ai) ---
	{"id": "s_ai_furya", "txt": "Yapay zeka furyası sürüyor; her sunumda aynı iki kelime.", "phases": [1, 2], "pool": "ai"},
	{"id": "s_ai_maliyet", "txt": "Model maliyetleri düşüyor; küçük ekipler için kapı aralanıyor.", "phases": [1, 2], "pool": "ai"},
	{"id": "s_ai_veri", "txt": "Eğitim verisi tartışması büyüyor; kim neyi kimden almış, belli değil.", "phases": [1, 2, 3], "pool": "ai"},
	{"id": "s_ai_yetenek", "txt": "Model ekipleri arasında transfer savaşı; maaşlar kulaktan kulağa.", "phases": [1, 2], "pool": "ai"},
	{"id": "s_ai_demo_hayal", "txt": "Gösterişli demo, zayıf ürün: alıcılar arayı fark etmeye başladı.", "phases": [1, 2], "pool": "ai"},
	{"id": "s_ai_donanim", "txt": "İşlemci kıtlığı gevşiyor; kapasite kiralamak yeniden makul.", "phases": [1, 2, 3], "pool": "ai"},
	# --- Faz 1-2 — ürün/pazar (saas) ---
	{"id": "s_saas_kobi", "txt": "KOBİ'lerin dijitalleşme harcaması artıyor; satıcılar sıraya girdi.", "phases": [1, 2], "pool": "saas"},
	{"id": "s_saas_yorgun", "txt": "Kurumsal yazılımda abonelik yorgunluğu; alıcılar sadeleşme istiyor.", "phases": [1, 2], "pool": "saas"},
	{"id": "s_saas_excel", "txt": "Orta ölçekli şirketlerin yarısı hâlâ tabloyla yönetiliyor; pazar bakir.", "phases": [1], "pool": "saas"},
	{"id": "s_saas_entegre", "txt": "Sistemler birbiriyle konuşmuyor; entegrasyon vaadi satış kapatıyor.", "phases": [1, 2], "pool": "saas"},
	{"id": "s_saas_ihale", "txt": "Kamu dijital ihaleleri yerli yazılımcıya açılıyor; şartname ağır.", "phases": [2, 3], "pool": "saas"},
	{"id": "s_saas_guvenlik", "txt": "Kurumsal alıcının ilk sorusu artık fiyat değil, güvenlik belgesi.", "phases": [2, 3], "pool": "saas"},
	# --- Faz 2 — değerleme/kanıt (any) ---
	{"id": "s_val_carpan", "txt": "Değerleme sohbetleri ısındı; çarpanlar yine masada.", "phases": [2], "pool": "any"},
	{"id": "s_kopru_tur", "txt": "Köprü turları çoğaldı; uzatma turu yeni normal sayılıyor.", "phases": [2], "pool": "any"},
	{"id": "s_tutundurma", "txt": "Yatırımcılar büyüme yerine tutundurma soruyor; sunum şablonları değişti.", "phases": [2], "pool": "any"},
	{"id": "s_mrr_esik", "txt": "Aylık gelir eşiği yatırım sohbetlerinin ilk sorusu oldu.", "phases": [2], "pool": "any"},
	{"id": "s_konsolide", "txt": "Pazarda birleşme fısıltıları; küçük oyuncular masaya oturuyor.", "phases": [2, 3], "pool": "any"},
	{"id": "s_kurumsal_alici", "txt": "Kurumsal satın alma ekipleri yavaşladı; satış döngüleri uzuyor.", "phases": [2, 3], "pool": "any"},
	{"id": "s_pilot_tuzak", "txt": "Bitmeyen pilot projeler tartışılıyor; bedava deneme kültürü sorgulanıyor.", "phases": [2], "pool": "any"},
	{"id": "s_ilk_yuz", "txt": "İlk yüz müşteri nasıl bulunur panelleri gişe rekoru kırıyor.", "phases": [1, 2], "pool": "any"},
	{"id": "s_churn_panel", "txt": "Churn panelde: kurumsal müşteri kolay gelmiyor, kolay da gitmiyor.", "phases": [2], "pool": "saas"},
	{"id": "s_ai_kanit", "txt": "Yapay zekada vitrin bitti, kanıt dönemi başladı; alıcılar sonuç istiyor.", "phases": [2, 3], "pool": "ai"},
	{"id": "s_ai_fiyat", "txt": "Yapay zeka ürünlerinde fiyatlama karmaşası; kimse ne sattığını bilmiyor.", "phases": [2], "pool": "ai"},
	{"id": "s_saas_yenileme", "txt": "Yıllık sözleşme yenilemeleri sertleşti; satın alma pazarlığı üç tur sürüyor.", "phases": [2, 3], "pool": "saas"},
	# --- Faz 3 — regülasyon + geç aşama (any) ---
	{"id": "s_veri_yerel", "txt": "Veri yerelliği taslağı yeniden gündemde; tedarikçi sözleşmeleri elden geçiyor.", "phases": [3], "pool": "any"},
	{"id": "s_seriesa_cita", "txt": "Series A çıtası yükseldi; masaya gelen dosya azaldı, kalitesi arttı.", "phases": [3], "pool": "any"},
	{"id": "s_geç_asama", "txt": "Geç aşama fonlar iştahlı; erken aşamada seçicilik sürüyor.", "phases": [3], "pool": "any"},
	{"id": "s_kur_dalga", "txt": "Kur dalgası bütçe planlarını bozdu; sözleşmeler yeniden fiyatlanıyor.", "phases": [2, 3], "pool": "any"},
	{"id": "s_denetim", "txt": "Yatırım alan şirketlerde bağımsız denetim şartı yaygınlaşıyor.", "phases": [3], "pool": "any"},
	{"id": "s_halka_arz", "txt": "Teknoloji halka arzları için pencere aralanıyor; bankalar dosya topluyor.", "phases": [3], "pool": "any"},
	{"id": "s_ai_regul", "txt": "Yapay zeka yönetmeliği taslağı sızdı; uyum maliyeti şimdiden konuşuluyor.", "phases": [3], "pool": "ai"},
	{"id": "s_ai_telif", "txt": "Üretilen içerikte telif davaları emsal arıyor; hukukçular bölünmüş durumda.", "phases": [3], "pool": "ai"},
	{"id": "s_saas_vergi", "txt": "Yazılım ihracatında vergi istisnası tartışması yeniden alevlendi.", "phases": [3], "pool": "saas"},
	{"id": "s_saas_konsol", "txt": "Kurumsal yazılımda satın alma dalgası; büyükler küçükleri topluyor.", "phases": [3], "pool": "saas"},
	{"id": "s_yetenek_göç", "txt": "Kıdemli mühendis göçü tersine döndü; dönüş paketleri konuşuluyor.", "phases": [3], "pool": "any"},
	{"id": "s_vc_rapor", "txt": "VC'lerin çeyrek raporları çıktı; portföy şişkin, çıkış az.", "phases": [2, 3], "pool": "any"},
]

# --- Rakip satır şablonları: {name} + {share} yer tutucularıyla (String.format) --
const RIVAL_UP_TEMPLATES := [
	"{name} pazar payını {share} bandına taşıdı; sessiz ama istikrarlı büyüyor.",
	"{name} yeni sürümünü duyurdu; payı {share} seviyesine oturdu.",
	"{name} bu hafta iki kurumsal anlaşma kapattı; pay {share} oldu.",
	"{name} fiyat kampanyasıyla alan kazanıyor; pazar payı {share}.",
]
const RIVAL_DOWN_TEMPLATES := [
	"{name} bu hafta pay kaybetti; koridorlarda indirim söylentisi dolaşıyor.",
	"{name} müşterilerinin yenileme pazarlığı sertleşti; payı {share} seviyesine geriledi.",
	"{name} kilit bir hesabını kaybetti; pazar payı {share} bandına indi.",
]


# --- Günlük kompozisyon ------------------------------------------------------

static func daily_tick() -> void:
	var nf: Dictionary = _ensure_state()
	var sub_id: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var snap: Dictionary = {}
	var player_pct: float = 0.0
	# Ship öncesi güvenli: ürün yokken rakip kaynağı susar, dünya (sektör) konuşur.
	if sub_id != "":
		snap = RivalRegistry.get_market_snapshot(sub_id)
		player_pct = float(snap["player_pct"])
	var rival_pool: Array = _rival_candidates(snap, player_pct, nf)
	var lines_today: int = DAILY_LINES_MIN \
		+ absi(hash("nf_count|%d" % GameState.day)) % (DAILY_LINES_MAX - DAILY_LINES_MIN + 1)
	for slot in lines_today:
		match _pick_source(nf, rival_pool):
			"rakip":
				_emit_rakip(nf, rival_pool)
			"biz":
				_emit_biz(nf)
			_:
				_emit_sektor(nf, slot)
	EventBus.news_stream_changed.emit()


static func on_headline_added(source: String, text: String) -> void:
	# "Biz" kaynağının pasif kulağı (TimeManager._ready bağlar). Buffer'a alınır;
	# akışa girişi daily_tick'in kota yürüyüşü ve sert kapı belirler.
	#
	# TAŞMA YÖNÜ (sözleşme): kuyruk dolduğunda EN YENİ satır düşer, en eski DEĞİL.
	# Sert kapı günde ~0,7 biz satırı boşaltır; otonom kapanışlar + ekip ayrılıkları
	# bundan hızlı üretir, yani kuyruk şişer ve taşma kaçınılmazdır — soru "kim
	# kaybeder" sorusudur. Yeni satır ticker'a ZATEN canlı düştü (news_ticker'ın
	# headline_added kulağı) ve MAX_LIVE_LINES penceresinde hâlâ duruyor; en eskinin
	# canlı penceresi çoktan kaydı, sıradaki arşiv yeri tek kalan şansıdır. Eskiyi
	# yemek duyuruyu tamamen siler, yeniyi bırakmak yalnız arşiv kaydını feda eder.
	# Boşaltmayı hızlandırmak alternatif DEĞİLDİR: "ticker dünyadır, bizim basın
	# ofisimiz değil" hükmünün kendisi o orandır (dosya başlığı).
	var nf: Dictionary = _ensure_state()
	var buffer: Array = nf["biz_buffer"]
	if buffer.size() >= BIZ_BUFFER_CAP:
		# Kayıp sessiz olmasın: sayaç, 90 günlük dökümde "kaç duyuru arşive hiç
		# giremedi"yi okunur kılar (kotanın gerçek maliyeti kalibrasyon verisidir).
		nf["biz_dropped"] = int(nf.get("biz_dropped", 0)) + 1
		return
	buffer.append({"src": source, "txt": text})


# --- Okuma API'si (ODA/ticker sözleşmesi) ------------------------------------

static func get_stream() -> Array:
	# En yeni önce, readonly kopya (get_sales_log sözleşmesiyle aynı).
	var nf: Dictionary = _ensure_state()
	var out: Array = (nf["stream"] as Array).duplicate(true)
	out.reverse()
	return out


static func get_lines_for_day(day: int) -> Array:
	var out: Array = []
	for line in _ensure_state()["stream"]:
		if int(line["day"]) == day:
			out.append(line.duplicate(true))
	return out


# --- İç mekanik --------------------------------------------------------------

static func _ensure_state() -> Dictionary:
	var nf: Dictionary = GameState.news_feed
	if nf.is_empty():
		nf["used_sektor"] = []
		nf["reshuffles"] = 0
		nf["counts"] = {"sektor": 0, "rakip": 0, "biz": 0}
		nf["biz_buffer"] = []
		nf["biz_dropped"] = 0      # kuyruk doluyken geri çevrilen milestone sayısı
		nf["recent_rivals"] = {}   # rival id -> son haber günü (cooldown penceresi)
		nf["stream"] = []
	return nf


static func _pick_source(nf: Dictionary, rival_pool: Array) -> String:
	# Deterministik kota yürüyüşü: kullanılabilir kaynaklar arasından, hedef orana
	# göre en aç olanı seçilir. Biz'in sert kapısı burada — hedefe değil TAVANA
	# bakar: bir sonraki satır biz olursa oran %20'yi aşacaksa biz seçilemez.
	var counts: Dictionary = nf["counts"]
	var total: float = float(int(counts["sektor"]) + int(counts["rakip"]) + int(counts["biz"]))
	var best: String = "sektor"
	var best_deficit: float = TARGET_SEKTOR - (float(counts["sektor"]) / maxf(total, 1.0))
	if not rival_pool.is_empty():
		var d: float = TARGET_RAKIP - (float(counts["rakip"]) / maxf(total, 1.0))
		if d > best_deficit:
			best = "rakip"
			best_deficit = d
	var biz_allowed: bool = not (nf["biz_buffer"] as Array).is_empty() \
		and float(int(counts["biz"]) + 1) / (total + 1.0) <= BIZ_HARD_CAP
	if biz_allowed:
		var d2: float = TARGET_BIZ - (float(counts["biz"]) / maxf(total, 1.0))
		if d2 > best_deficit:
			best = "biz"
			best_deficit = d2
	return best


static func _emit_sektor(nf: Dictionary, slot: int) -> void:
	var eligible: Array = _eligible_sektor(nf)
	if eligible.is_empty():
		# Havuz tükendi → reshuffle sözleşmesi: kullanılmışlar temizlenir, tur sayacı artar.
		nf["used_sektor"] = []
		nf["reshuffles"] = int(nf["reshuffles"]) + 1
		eligible = _eligible_sektor(nf)
	if eligible.is_empty():
		return   # içerik deliği (faz+pool kombinasyonuna hiç satır yok) — sessiz geç
	var idx: int = absi(hash("sektor|%d|%d|%d" % [GameState.day, slot, int(nf["reshuffles"])])) % eligible.size()
	var rec: Dictionary = eligible[idx]
	(nf["used_sektor"] as Array).append(String(rec["id"]))
	var counts: Dictionary = nf["counts"]
	counts["sektor"] = int(counts["sektor"]) + 1
	_append(nf, "sektor", OUTLETS[absi(hash(String(rec["id"]))) % OUTLETS.size()], String(rec["txt"]))


static func _eligible_sektor(nf: Dictionary) -> Array:
	var used: Array = nf["used_sektor"]
	var pool_key: String = GameState.subgenre   # "ai" | "saas" | "social"
	var out: Array = []
	for rec in SEKTOR_POOL:
		if not (rec["phases"] as Array).has(GameState.phase):
			continue
		var p: String = String(rec["pool"])
		if p != "any" and p != pool_key:
			continue
		if used.has(String(rec["id"])):
			continue
		out.append(rec)
	return out


static func _rival_candidates(snap: Dictionary, player_pct: float, nf: Dictionary) -> Array:
	# İLGİLİLİK KAPISI: yalnız bu hafta gerçekten kımıldayan VE oyuncuyu ilgilendiren
	# rakipler satır üretir. Dev/yerleşik/holding ancak BÜYÜK hamleyle haber olur
	# (devin rutin haberi gürültüdür, bastırılır); startup, oyuncunun payına yakınsa
	# ya da hamlesi büyükse haber olur. Satırlar YALNIZ snapshot'tan türetilir.
	if snap.is_empty():
		return []
	var recent: Dictionary = nf["recent_rivals"]
	var out: Array = []
	for row in snap["rivals"]:
		if not bool(row["moved_recently"]):
			continue
		if GameState.day - int(recent.get(String(row["id"]), -999)) < RIVAL_COOLDOWN_DAYS:
			continue
		var big: bool = float(row["delta_pct"]) >= RIVAL_BIG_MOVE_PCT
		var near: bool = absf(float(row["share_pct"]) - player_pct) <= RIVAL_NEAR_BAND_PCT
		var heavy: bool = String(row["tier"]) != "startup"
		if (heavy and big) or (not heavy and (near or big)):
			out.append(row)
	return out


static func _emit_rakip(nf: Dictionary, rival_pool: Array) -> void:
	if rival_pool.is_empty():
		return
	var row: Dictionary = rival_pool.pop_front()
	var recent: Dictionary = nf["recent_rivals"]
	recent[String(row["id"])] = GameState.day
	for rid in recent.keys():
		if GameState.day - int(recent[rid]) > RIVAL_COOLDOWN_DAYS * 4:
			recent.erase(rid)   # süresi çoktan dolmuş girdileri temizle (sözlük küçük kalsın)
	var templates: Array = RIVAL_UP_TEMPLATES if int(row["trend"]) >= 0 else RIVAL_DOWN_TEMPLATES
	var tmpl: String = templates[absi(hash("%s|%d" % [String(row["id"]), GameState.day])) % templates.size()]
	var txt: String = tmpl.format({
		"name": String(row["name"]),
		"share": RivalRegistry.format_share(float(row["share_pct"])),
	})
	var counts: Dictionary = nf["counts"]
	counts["rakip"] = int(counts["rakip"]) + 1
	_append(nf, "rakip", OUTLETS[absi(hash(String(row["id"]) + str(GameState.day))) % OUTLETS.size()], txt)


static func _emit_biz(nf: Dictionary) -> void:
	var buffer: Array = nf["biz_buffer"]
	if buffer.is_empty():
		return
	var item: Dictionary = buffer.pop_front()   # kronolojik: en eski milestone önce
	var counts: Dictionary = nf["counts"]
	counts["biz"] = int(counts["biz"]) + 1
	_append(nf, "biz", String(item["src"]), String(item["txt"]))


static func _append(nf: Dictionary, kind: String, src: String, txt: String) -> void:
	var stream: Array = nf["stream"]
	stream.append({"day": GameState.day, "kind": kind, "src": src, "txt": txt})
	while stream.size() > STREAM_CAP:
		stream.pop_front()
