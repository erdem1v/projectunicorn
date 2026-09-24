class_name B2BEventFactory
extends RefCounted

# WHAT IS LEFT OF IT, AND WHY THE NAME STAYS.
#
# This file used to build four synthetic GameEvents — retention, expansion, CS escalation and
# the three-branch customer request — and inject them past the event gate. All four are cards
# now (`customer.retention`, `customer.expansion`, `customer.cs_escalation`,
# `customer.request_{complaint,feature,renewal}`), so the builders are gone with the engine
# that needed them.
#
# `pick_request_kind` is not a builder. It is the SCORING RULE that decides what an account is
# most likely to be calling about, and it survives for the reason the port split the request
# card into three: the branch it chooses used to be invisible to content — it was picked at
# construction time, written into `last_request_kind`, and read by nothing. Now three cards
# read it through the `musteri.request_kind` seam and the branch is a condition the "why
# didn't this fire" panel can name.
#
# TranslationServer.translate, NOT tr(): every function in this file is `static`, and a static
# has no Object to translate through. Kept as a note because the lesson cost two smoke cases
# reporting "escalation not active" when the event was never built at all and nothing said why.

static func pick_request_kind(c: Customer) -> String:
	# İLGİLİLİK KURALI (Dünya İnandırıcılığı Fix 5): talebin TÜRÜ ilişkinin
	# DURUMUNDAN türer — memnuniyet/gizli tolerans dengesi, kırılmış söz, güven
	# defteri, risk izi, kıdem, açık söz ve karşılanmamış acı özelliği. Şirketin
	# sektörü/karakter çizgisi yalnız ÜSLUBU boyar (build_cs_request gövdeleri),
	# konuyu ASLA seçmez: tekstilciye satmak tekstil olayı üretmez. Eski gün
	# rotasyonu (round_no + phase) durumdan tamamen bağımsızdı — mutsuz hesap
	# özellik ister, mutlu hesap şikâyet ederdi.
	#
	# THE NO-REPEAT RULE aynen durur: aynı hesap aynı türü üst üste iki kez açmaz
	# (last_request_kind dışlaması, 2b). RNG yasağı da durur: skorlar tamsayı
	# aritmetiği, eşitlik bozucu hesabın kendi faz imzası.
	#
	# NOT: support_request_since_day burada OKUNMAZ — CustomerRepSystem talebi
	# factory'ye getirmeden önce o mandalı temizler; seçim anında değeri hep -1,
	# okuyan kod ölü koşul olurdu.
	var eligible: Array = []
	for k in B2BConstants.CS_REQUEST_KINDS:
		if k != c.last_request_kind:
			eligible.append(k)
	if eligible.is_empty():
		return B2BConstants.CS_KIND_FEATURE
	var scores: Dictionary = {}
	# Şikâyet: memnuniyet toleransa yaklaştıkça / güven kırıldıkça yükselir.
	var complaint: int = 2 * maxi(0, c.tolerance + 10 - c.satisfaction)
	if GameState.get_flag("b2b_broke_%s" % c.id, false):
		complaint += 30
	if c.trust_offset < -4.0:
		complaint += 15
	if c.risk_streak > 0 or c.churn_countdown >= 0:
		complaint += 10
	scores[B2BConstants.CS_KIND_COMPLAINT] = complaint
	# Yenileme: kıdem büyüdükçe sözleşme masası yaklaşır; sayaç/oyalama izi acilleştirir.
	var tenure_months: int = int(float(GameState.day - c.acquired_on_day) / 30.0)
	var renewal: int = 6 * tenure_months
	if c.churn_countdown >= 0:
		renewal += 20
	if c.retain_stalls > 0:
		renewal += 10
	scores[B2BConstants.CS_KIND_RENEWAL] = renewal
	# Özellik: taban istek + karşılanmamış acı özelliği + sağlıklı ilişkinin cesareti;
	# açık bir söz dururken ikinci özellik istemek doğal değildir.
	var feature: int = 20
	if c.pain_feature_id != "" and not ProductState.is_feature_live(c.pain_feature_id):
		feature += 25
	if c.satisfaction >= c.tolerance:
		feature += 10
	if PromiseRegistry.has_open_for(c.id):
		feature -= 25
	# HAYIR DİYEMEZ: hesabın SORUMLU temsilcisi "hayır" diyemiyorsa o hesap daha sık
	# özellik ister — söz olayları onun üzerinde birikir. Skor tamsayı ve RNG'siz
	# kalıyor (yukarıdaki RNG yasağı), çarpan yalnız sıralamayı kaydırıyor.
	if c.assigned_to != "":
		var rep: Character = CharacterRegistry.get_character(c.assigned_to)
		if rep != null and rep.status == HRConstants.STATUS_ACTIVE:
			feature = int(round(float(feature)
				* HRConstants.trait_mult(rep.traits, "promise_chance_mult")))
	scores[B2BConstants.CS_KIND_FEATURE] = feature
	var best: String = ""
	var best_score: int = -2147483648
	for k in eligible:
		if int(scores.get(k, 0)) > best_score:
			best = k
			best_score = int(scores.get(k, 0))
	var tied: Array = []
	for k in eligible:
		if int(scores.get(k, 0)) == best_score:
			tied.append(k)
	if tied.size() > 1:
		best = tied[c.cs_request_phase % tied.size()]
	return best


