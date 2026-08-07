class_name CompanyCatalog
extends RefCounted

# Company catalog — the SINGLE source of prospect/customer company fiction
# (Dünya İnandırıcılığı Fix 2). Replaces B2BConstants.SECTOR_COMPANIES (9 sectors
# × 3 names, four sectors sharing one 3-name fallback — the root of the "Beykoz
# appears everywhere" break). 13 sectors × 5 companies = 65, matching the full
# SECTOR_CONTACT / COMPLAINT_VOICE sector set so no sector ever falls through to
# a shared fallback again.
#
# # WORKING TR — background lines are working copy; Erdem voice-passes later.
#
# Fiction rules (task-locked):
#   - Mix: Turkish firms, Turkish-international hybrids, foreign firms operating
#     regionally. No joke names, no real trademarks. Names are proper nouns
#     (LANGUAGE INTEGRITY LAW exempts them); backgrounds are clean Turkish.
#   - `background` is ONE line of character (sector feel, size feel, temperament).
#     The event system may QUOTE it to color wording; it must never DRIVE an
#     event's subject (Fix 5 rule). UI may show it on a customer card.
#   - The smoke suite's synthetic "Testing" sector is deliberately absent —
#     hand-built fixtures stay outside the catalog.
#
# Naming note: two legacy pool names were live trademarks of real Turkish
# companies (Anadolu Sigorta, Anadolu Yatırım) and were replaced (Poyraz
# Sigorta, Argos Yatırım). Every other legacy name carried over unchanged.

const COMPANIES := {
	"Sigorta": [
		{"name": "Ege Sigorta", "background": "Bölgesel oyuncu; acente ağı geniş, evrak işi hâlâ kâğıtta."},
		{"name": "Poyraz Sigorta", "background": "Fiyat kırarak büyüdü, şimdi hasar dosyalarının altında eziliyor."},
		{"name": "Deniz Sigorta", "background": "Kurumsal müşteriye çalışır, temkinli; yeni tedarikçiyi zor kabul eder."},
		{"name": "Adriatic Assurance", "background": "Balkan pazarından bölgeye açıldı; merkez uzak, yerel ekip küçük."},
		{"name": "Vega Sigorta", "background": "Genç yönetim, poliçeyi telefondan satıyor; büyüme hızlı, süreç dağınık."},
	],
	"İnşaat": [
		{"name": "Kuzey İnşaat", "background": "Kamu ihalesiyle büyüdü; şantiyesi çok, merkez ofisi az."},
		{"name": "Anadolu Yapı", "background": "Aile şirketi, üçüncü kuşak yönetimde; dijitalleşmeye geç başladı."},
		{"name": "Marmara İnşaat", "background": "Konut projelerinde iddialı; nakit akışı gelgitli, karar tek adamda."},
		{"name": "Terra Yapı", "background": "Yabancı ortaklı; raporlama standardı yüksek, sabrı az."},
		{"name": "Donau Bau", "background": "Avusturyalı; altyapı projeleriyle geldi, kalıcı mı belli değil."},
	],
	"Lojistik": [
		{"name": "Deniz Lojistik", "background": "Liman çevresinde güçlü; filosu yaşlı, yazılımı daha yaşlı."},
		{"name": "Nordica Lojistik", "background": "İskandinav ortaklı; süreç disiplini yüksek, esnekliği düşük."},
		{"name": "Ege Kargo", "background": "Şehirlerarası dağıtımda eski toprak; el yazısı irsaliyeden yeni çıktı."},
		{"name": "Marmara Lojistik", "background": "Depoculuğa yeni girdi; büyüme iştahı yüksek, ekibi yorgun."},
		{"name": "Nordwind GmbH", "background": "Alman butik nakliyeci; bölge ofisi kendi kararını alamıyor."},
	],
	"Sağlık": [
		{"name": "Aras Klinik", "background": "Tek şubeli butik klinik; randevu defteri hâlâ resepsiyonda."},
		{"name": "Marmara Klinik", "background": "Zincirleşme yolunda; her şube kendi usulünce çalışıyor, merkez bunu dert etti."},
		{"name": "Bosphorus Sağlık", "background": "Yabancı hasta ağırlıklı; itibarına düşkün, hata payı tanımıyor."},
		{"name": "Vita Medikal", "background": "Cihaz satışından hizmete döndü; satışı güçlü, operasyonu zayıf."},
		{"name": "Medisa Grup", "background": "Bölge hastaneleriyle anlaşmalı; ihale takvimiyle yaşar, acelesi yoktur."},
	],
	"Üretim": [
		{"name": "Beykoz Üretim", "background": "Yan sanayi tedarikçisi; müşterisi ne derse o, kendi sistemi yok gibi."},
		{"name": "Trakya Fabrika", "background": "Vardiya düzeni oturmuş, veri toplamaz; ustabaşının hafızası veritabanıdır."},
		{"name": "Ege Metal", "background": "İhracat ağırlıklı; Avrupa müşterisi belge istedikçe yazılım ihtiyacı büyüyor."},
		{"name": "Vulkan Döküm", "background": "Ağır sanayi, ağır karar alır; ama imza atınca yıllarca kalır."},
		{"name": "Ferrum Endüstri", "background": "Makine parkı yeni, yönetim anlayışı eski; genç mühendisler sıkışmış durumda."},
	],
	"Perakende": [
		{"name": "Anadolu Market", "background": "Bölgesel market zinciri; kasa sayısı arttıkça kaos da arttı."},
		{"name": "Brightline Retail", "background": "Uluslararası zincirin bölge iştiraki; merkezle konuşmak ayrı bir proje."},
		{"name": "Kardelen Mağazacılık", "background": "Cadde mağazacılığında eski isim; AVM kiralarıyla boğuşuyor."},
		{"name": "Ekin Gıda Marketleri", "background": "İlçe pazarından zincire dönüştü; patron her şubeyi hâlâ tek tek arar."},
		{"name": "Modena Concept", "background": "Ev tekstili ve mobilya satar; sezon döngüsüne bağlı, stok takibi elde."},
	],
	"Emlak": [
		{"name": "Palmiye Holding", "background": "Turizm arazileriyle büyüdü; portföyü geniş, kayıt düzeni dar."},
		{"name": "Kıyı Gayrimenkul", "background": "Sahil projelerine odaklı; satışı hızlı, tapu sonrası ilgisi yavaş."},
		{"name": "Metrekare Danışmanlık", "background": "Genç ekip, şube modeliyle büyüyor; şube açtıkça standart kayboluyor."},
		{"name": "Vestera Holding", "background": "Yabancı fonlarla ortak proje geliştirir; rapor ister, hem de her hafta."},
		{"name": "Panorama Emlak", "background": "Üç şehirde ofisi var; danışmanlar kendi telefonuyla çalışır, merkez göremez."},
	],
	"Tekstil": [
		{"name": "Beykoz Tekstil", "background": "Aile şirketi; fason üretimden marka olmaya çalışıyor, sancılı."},
		{"name": "Menderes Dokuma", "background": "Havlu ve ev tekstili ihracatçısı; sipariş takibi faks kokan bir sistemde."},
		{"name": "İplikhane", "background": "Butik üretici; tasarımı güçlü, teslim tarihi zayıf."},
		{"name": "Nova Tekstil", "background": "Hızlı moda tedarikçisi; büyük müşteri ne isterse ona koşar, kendine vakti yok."},
		{"name": "Aegea Textile Group", "background": "Yunan ortaklı; iki ülkede üretim var, tek düzgün rapor yok."},
	],
	"Hukuk": [
		{"name": "Bosphorus Legal", "background": "Kurumsal müvekkil ağırlıklı; saat ücretiyle yaşar, verim onun için paradır."},
		{"name": "Kavanagh & Sons", "background": "İrlandalı butik ofisin bölge masası; usule düşkün, yeniliğe mesafeli."},
		{"name": "Aslan & Duru Hukuk", "background": "İki ortak, on avukat; dosya sayısı büyüdü, arşiv düzeni büyüyemedi."},
		{"name": "Meridyen Hukuk", "background": "Şirket birleşmelerinde isim yaptı; gizlilik takıntısı her aracı zorlaştırır."},
		{"name": "Lex Anadolu", "background": "Uluslararası ağın yerel üyesi; standartları dışarıdan, kadrosu içeriden."},
	],
	"Teknoloji": [
		{"name": "Nexus Yazılım", "background": "Kurumsal proje geliştirir; kendi ürünü yok, herkesinkini bilir."},
		{"name": "Piksel Teknoloji", "background": "Ajans kökenli; işi çok, faturası geç."},
		{"name": "Volt Sistemleri", "background": "Donanım ağırlıklı entegratör; yazılıma mecbur kaldıkça alışıyor."},
		{"name": "Atlas Bilişim", "background": "Kamu projeleriyle büyüdü; güvenlik şartnamesi her cümlede."},
		{"name": "Origo Labs", "background": "Genç ürün stüdyosu; hızlı dener, hızlı vazgeçer."},
	],
	"E-ticaret": [
		{"name": "Sepet Ticaret", "background": "Pazaryerinde büyüdü, kendi sitesine geçti; kampanya günleri kâbusu."},
		{"name": "Hızlı Pazar", "background": "Aynı gün teslimat iddiasında; operasyon bu iddiaya yetişemiyor."},
		{"name": "Vitrin Online", "background": "Niş kategoride lider; ekip küçük, her şey kurucunun telefonunda."},
		{"name": "Loka Store", "background": "Sosyal medyadan doğdu; markası güçlü, altyapısı emekleme döneminde."},
		{"name": "Adriatica Market", "background": "Balkanlara satış yapan bölgesel platform; gümrük ve iade derdi bitmez."},
	],
	"Medya": [
		{"name": "Kanal Medya", "background": "Yerel televizyondan dijitale döndü; arşivi altın, sistemi hurda."},
		{"name": "Punto Yayın", "background": "Dergi grubundan kalan çekirdek; az kadro, çok başlık."},
		{"name": "Ekran Prodüksiyon", "background": "Dizi seti kökenli; proje bazlı yaşar, düzenli gider sevmez."},
		{"name": "Anadolu Digital", "background": "Ajans ile içerik stüdyosu karışımı; müşteri raporu gecede biter, kendi raporu hiç."},
		{"name": "Nordlicht Studio", "background": "Alman yapım ortağıyla belgesel çeker; bütçe disiplini sıkı."},
	],
	"Finans": [
		{"name": "Kule Finans", "background": "Faktoring ağırlıklı; risk iştahı düşük, evrak iştahı yüksek."},
		{"name": "Argos Yatırım", "background": "Halka arz danışmanlığına soyundu; itibar hassasiyeti aşırı."},
		{"name": "Pusula Portföy", "background": "Varlıklı aile fonlarını yönetir; sessiz, sadık, yavaş."},
		{"name": "Helvetia Data AG", "background": "İsviçre merkezli finansal veri sağlayıcı; bölge ofisi üç kişi, beklentisi otuz kişilik."},
		{"name": "Lira Kapital", "background": "KOBİ finansmanına odaklı; regülasyon her ay kapıyı çalar."},
	],
}


# Lazy name→record index (record gains a "sector" key on first build).
static var _by_name: Dictionary = {}


static func _index() -> Dictionary:
	if _by_name.is_empty():
		for sector in COMPANIES:
			for rec in COMPANIES[sector]:
				_by_name[rec["name"]] = {"name": rec["name"], "sector": sector, "background": rec["background"]}
	return _by_name


static func all() -> Array:
	# Flattened [{name, sector, background}] — smoke integrity checks iterate this.
	var out: Array = []
	for sector in COMPANIES:
		for rec in COMPANIES[sector]:
			out.append({"name": rec["name"], "sector": sector, "background": rec["background"]})
	return out


static func names_for_sector(sector: String) -> Array:
	# Name strings only — the spawn picker's per-sector candidate list. Unknown
	# sector → empty array (no shared fallback: that was the old fiction break).
	var out: Array = []
	for rec in COMPANIES.get(sector, []):
		out.append(rec["name"])
	return out


static func background_for(company_name: String) -> String:
	# One-line character color for events/cards. Empty for names outside the
	# catalog (hand-built fixtures, legacy saves) — callers treat "" as "skip".
	var rec: Dictionary = _index().get(company_name, {})
	return String(rec.get("background", ""))


static func sector_for(company_name: String) -> String:
	var rec: Dictionary = _index().get(company_name, {})
	return String(rec.get("sector", ""))


static func count_by_sector() -> Dictionary:
	var out: Dictionary = {}
	for sector in COMPANIES:
		out[sector] = COMPANIES[sector].size()
	return out
