class_name B2BEventFactory
extends RefCounted

# The request-kind SCORING RULE: what an account is most likely calling about. The three
# request cards (`customer.request_{complaint,feature,renewal}`) read it through the
# `musteri.request_kind` seam, so the chosen branch is a condition the "why didn't this fire"
# panel can name.

static func pick_request_kind(c: Customer) -> String:
	# İLGİLİLİK KURALI: talebin TÜRÜ ilişkinin DURUMUNDAN türer — memnuniyet/gizli
	# tolerans dengesi, kırılmış söz, güven defteri, risk izi, kıdem, açık söz ve
	# karşılanmamış acı özelliği. Şirketin sektörü yalnız ÜSLUBU boyar (şikâyet kartındaki
	# `musteri.complaint_voice`), konuyu ASLA seçmez: tekstilciye satmak tekstil olayı üretmez.
	#
	# NO-REPEAT: aynı hesap aynı türü üst üste iki kez açmaz (last_request_kind dışlaması).
	# RNG YASAĞI: skorlar tamsayı aritmetiği, eşitlik bozucu hesabın kendi faz imzası.
	#
	# NOT: support_request_since_day burada OKUNMAZ — CustomerRepSystem talebi
	# factory'ye getirmeden önce o mandalı temizler; seçim anında değeri hep -1,
	# okuyan kod ölü koşul olurdu.
	#
	# Şikâyet: memnuniyet toleransa yaklaştıkça / güven kırıldıkça yükselir.
	var complaint: int = 2 * maxi(0, c.tolerance + 10 - c.satisfaction)
	if GameState.get_flag("b2b_broke_%s" % c.id, false):
		complaint += 30
	if c.trust_offset < -4.0:
		complaint += 15
	if c.risk_streak > 0 or c.churn_countdown >= 0:
		complaint += 10
	# Yenileme: kıdem büyüdükçe sözleşme masası yaklaşır; sayaç/oyalama izi acilleştirir.
	var tenure_months: int = int(float(GameState.day - c.acquired_on_day) / 30.0)
	var renewal: int = 6 * tenure_months
	if c.churn_countdown >= 0:
		renewal += 20
	if c.retain_stalls > 0:
		renewal += 10
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
	var scores: Dictionary = {
		B2BConstants.CS_KIND_COMPLAINT: complaint,
		B2BConstants.CS_KIND_RENEWAL: renewal,
		B2BConstants.CS_KIND_FEATURE: feature,
	}
	# Three distinct kinds, at most one excluded: never empty.
	var eligible: Array = B2BConstants.CS_REQUEST_KINDS.filter(
		func(k: String) -> bool: return k != c.last_request_kind)
	var best_score: int = eligible.map(func(k: String) -> int: return scores[k]).max()
	var tied: Array = eligible.filter(func(k: String) -> bool: return scores[k] == best_score)
	return tied[c.cs_request_phase % tied.size()]
