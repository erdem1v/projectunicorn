class_name OdaLayout
extends RefCounted

# ============================================================================
# ODA yerleşim defteri — TEK ayar yüzeyi (ODA rework 2026-08-06; D4 standardı
# kalite turu v2'de eklendi).
# ============================================================================
# Sahne sanatı 3840×2160 (room_day / room_night); obje sprite'ları AYNI kanvasta
# ve artık SAHNE-HİZALI (2026-08-10 sanat migrasyonu): plaka ile her obje aynı
# kameradan render edildi, o yüzden RECTS[id] == REGIONS[id] / ART ve sprite
# plakadaki baked gölgesinin tam üstüne oturur. (Suluboya çağında sprite'lar
# merkezlenmiş hero render'lardı ve hedef rect elle ayarlanıyordu — artık değil.)
# Hedef aspect == region aspect bu yüzden HESAPLA değil YAPISAL (STRETCH_SCALE güvenli).
#
# ── D4 İÇERİK YERLEŞİM STANDARDI (Erdem, kalite turu v2 — bağlayıcı) ──────────
# 1. HOST-TÜRETİMLİ her bilgi yüzeyi (monitör camı, pano kartları, çerçeve
#    belgeleri, telefon camı) ev sahibi rect'inden SABİT ORAN + SABİT İÇ PAY ile
#    türetilir (rect_in / *_REL tabloları) — mutlak rect YAZILMAZ; host ile
#    yüzey yapısal olarak AYRIŞAMAZ.
# 2. SARMALAYICI ZORUNLU: her yüzey = düz Control (clip_contents=true, min-size
#    yaymaz — set_size'ın minimuma YUKARI clamp'i taşma üretemez) + içte
#    full-rect temalı panel. Clip SARMALAYICIDADIR (panelin kendi stylebox'ını
#    ancak o kırpar). Monitör dahil — muafiyet yok.
# 3. OKUNABİLİRLİK TABANI: MIN_READABLE_FONT_PX altına inen metin YASAK; içerik
#    seçilen skala adımlarıyla host'a sığmıyorsa METİN KÜÇÜLTÜLMEZ — dur ve
#    rapor et ("bu rect X'i okunaklı taşımıyor, asset büyümeli"); karar Erdem'e.
#
# TÜM DEĞERLER # WORKING: shot döngüsü (D7 kapıları) + Erdem F5 mühürler.
# Ayar = bu tablo; oda_view.gd'de koordinat sabiti ARANMAZ.
#
# Kadraj notları (sanat incelemesinden):
#   * Masa/duvar birleşimi ~y 0.76 (ölçüldü; suluboyada 0.63-0.68'di — yeni kadraj
#     masayı öne getirdi ve ölü zemini sıfırladı). Pano, çerçeve üçlüsü, pencere BOYALI.
#   * GECE sahnesinde lamba ışık havuzu hâlâ SOLDA baked (ölçülen merkez x 0.283,
#     y 0.893) → lamba hedefi ve kâğıt yuvaları ona oturuyor.
#   * frame_outer_N ölçümleri AHŞAP DAHİL dış kutudur (kalite turu bulgusu) —
#     belge rect'i FRAME_DOC_INSET ile içeri alınır, ahşap hep görünür kalır.

const ART := Vector2(3840, 2160)
const REGION_PAD := 24.0            # rim-glow shader kenar payı (kaynak px) — # WORKING
const MIN_READABLE_FONT_PX := 9     # tip skalasının MICRO adımı = mutlak okunabilirlik tabanı (D4.3)

# --- Obje sprite'ları: kaynak içerik-kutusu (px) + hedef (normalize) ---------
# Sanat migrasyonu (2026-08-10): suluboya oda emekli, prosedürel render geldi.
# Objeler ARTIK sahne-hizalı: plaka ve her obje katmanı AYNI kameradan, aynı
# 3840×2160 kanvasa render edildi, o yüzden RECTS[id] == REGIONS[id] / ART.
# Bu, aspect değişmezini (hedef aspect == region aspect) HESAPLA değil YAPISAL
# olarak sağlar ve sprite'ı plakaya baked gölgesinin tam üstüne oturtur.
# Değerler ölçüldü, tahmin edilmedi: REGIONS render'ın kendi alfa kanalından
# (alphaBounds), boyalı çapalar oda geometrisinin izdüşümünden. Kamera:
# pos (0.298, 1.35, 1.56) · yaw 0.38° · pitch −1.91° · fov 44 — suluboya odanın
# yerleşim sözleşmesine (aşağıdaki eski değerler) çözülerek bulundu.
# Defter: docs/design/oda_art_pipeline.md
#
# ── MÜHÜRLÜ SANAT TURU (2026-08-17) ───────────────────────────────────────────
# Yönetmen gündüz/gece render'larını mühürledi; sahne 2026-08-10'dakinden FARKLI.
# Kamera AYNI KALDI (yukarıdaki değer) — bilinçli: solver'ı serbest bırakmak onu
# pitch −9.05°'ye götürdü ve board_inner'ı sözleşmeden 214px sağa attı, yani tam
# tur-1 F5 reddinin hatasına geri döndü. Sebep ölçüldü: mühürlü sahne TELEFONU
# yarım metre sola taşıdı, RECTS.phone'daki hedef fiziksel olarak ULAŞILAMAZ
# hâle geldi ve solver onu kovalarken panoyu feda etti. Prop hedefi sıfırlandı
# (rig'de RIG_WEIGHT.phone = 0) ve kamera SABİTLENDİ.
# İki KAYNAK düzeltmesi yönetmen onayıyla yapıldı (rig'de uygulandı; office-room
# .html'e aynen yansıtılmalı):
#   * Mantar pano (0.62, 1.44) → (0.4155, 1.2855): sol 20.4cm + aşağı 15.4cm.
#     Mühürlü konum board_inner'ı y = −17'ye, yani KADRAJIN ÜSTÜNDEN DIŞARI
#     atıyordu; dikey düşüş tek başına yatay 220px'i kapatmıyor.
#   * Telefon yaw −16.04° → −2°: mühürlü yaw ekran dörtgenini 29.2° MAKASLI
#     paralelkenar yapıyordu, PHONE_GLASS_* ise DÖNMÜŞ DİKDÖRTGEN modelliyor.
#     −2°'de makas 0.17° (temiz dikdörtgen) ve cam alanı yine 1.27× kalıyor.
# Değişen tek REGION: phone. monitor/keyboard/mug/lamp bire bir aynı çıktı —
# kamera sabit olduğunun kanıtı.
#
# LAMBA: bu turda bir git-gel yaşandı ve GERİ ALINDI, kaydı burada duruyor çünkü
# dersi sabitlerden daha değerli. Mühürlü kaynak başı ışık havuzuna NİŞANLIYOR
# (layers.html'deki quaternion bloğu); onu portlayınca ağız kameraya döndü,
# aydınlanmayan iç yüzey objenin en büyük yüzeyi oldu ve lamba "kapüşonlu göz"
# gibi biçimsiz bir kütle olarak okundu. O noktada BELİRTİYİ tedavi ettim (içe
# krem astar + profili spline'a çevirme) ve lamba siyah olmaktan çıktı. Yönetmen
# haklı olarak durdurdu: lamba HER İKİ MODDA DÜZ SİYAHTIR, değişen tek şey
# AYDINLATMA, gece ampul yanar. Nişan bloğu bilinçli override ile alınmadı,
# astar/spline silindi ve REGIONS.lamp ilk assetteki (219, 1308, 200, 494)
# değerine BİREBİR döndü. Ders: pose/oryantasyon/materyal değiştiren bir
# kaynak-delta objenin OKUNUŞUNU değiştirir — sessizce portlanmaz, bildirilir.
#
# LAMBA NİŞANI (2026-08-18, Erdem kararı — yukarıdaki geri almanın DEVAMI değil,
# ayrı ve kasıtlı bir tasarım değişikliği): lambanın ağzı 28.6° azimuttaydı ama
# kendi ışık havuzu 95° azimutta — yani lamba KENDİ IŞIĞINDAN 66° sapmış
# duruyordu. yaw 85.156° havuzun merkezine tam nişan alır (artık sapma 0.000°).
# Yalnız döndürmek YETMEDİ: lamba yandan görünüşe geçince kol derinlik yerine
# GENİŞLİK kaplıyor, siluet 200→338px büyüyor ve sağ kenarı 0.1402'ye çıkıp
# PAPER_SLOTS'un (0.120) ÜSTÜNE biniyordu. Kâğıtları daraltmak yerine lamba
# 12cm sola alındı (x -0.92 → -1.04): sağ kenar 0.1005, kâğıtlara boşluk 0.0195
# — bugünkünden (0.0108) DAHA GENİŞ, yani şerit iyileşti. Sol kenar 48px, yani
# REGION_PAD 24'ün üstünde (padded_region tam 24'ten başlar — sınırda ama geçerli;
# lamba daha sola alınırsa bu KIRILIR, sonraki tur için uyarı).
# monitor/keyboard/mug/phone REGIONS'ları değişmedi — kamera yine sabit.
const REGIONS := {
	"monitor": Rect2(1051, 951, 935, 871),
	"keyboard": Rect2(1163, 1877, 541, 91),
	"lamp": Rect2(48, 1297, 338, 506),
	"mug": Rect2(2185, 1742, 174, 175),
	"phone": Rect2(1976, 1935, 126, 106),
}
const RECTS := {
	# Objeler — REGIONS / ART (aspect değişmezi yapısal):
	"monitor": Rect2(0.27370, 0.44028, 0.24349, 0.40324),
	"keyboard": Rect2(0.30286, 0.86898, 0.14089, 0.04213),  # YENİ katman: suluboyada klavye "pc" sprite'ının içindeydi
	"lamp": Rect2(0.01250, 0.60046, 0.08802, 0.23426),
	"mug": Rect2(0.56901, 0.80648, 0.04531, 0.08102),
	"phone": Rect2(0.51458, 0.89583, 0.03281, 0.04907),
	# Boyalı çapalar (hotspot / tur bölgeleri) — mesh köşelerinin izdüşümü:
	# Pano 2026-08-17'de 5-6px kaydı (kaynak düzeltmesi sözleşmeyi tam tutturmuyor,
	# kıl payı ıskalıyor). ÖLÇÜLEN değer yazıldı, sözleşme değeri değil: kural
	# "render'dan ölç, cetvelle bakma". Kaymanın kartlara etkisi yok — BOARD_REL'in
	# %4 iç payı 53px, kayma 6px.
	"board_outer": Rect2(0.3400, 0.0392, 0.3762, 0.4515),
	"board_inner": Rect2(0.3550, 0.0669, 0.3459, 0.3994),  # mantar yüzey — pano kartlarının HOST'u
	"frames_band": Rect2(0.0191, 0.0596, 0.2734, 0.1517),
	"window": Rect2(0.9000, 0.0, 0.1000, 0.8070),      # tıklanmaz — yalnız tur; camın ÖLÇÜLEN parlak bandı
	"papers_zone": Rect2(0.120, 0.836, 0.170, 0.142),  # hotspot değil; tur + kümeleme
	# ^ alt kenar 0.978: GÖRÜNÜR BANDIN (0.020..0.980) içinde kalmak zorunda.
	#   İlk taşımada 0.984 yazmıştım ve oda_anchors_stay_in_band case'i yakaladı.
	# Host'suz tek yüzey (place_clamped'in kalan tek kullanıcısı) — pano ile
	# pencere ARASINDAKİ boşluğa taşındı (pano sağ kenarı 0.7009, pencere 0.9000 —
	# pano kaynak düzeltmesiyle 0.7175'ten sola çekildi, boşluk BÜYÜDÜ):
	"overtime_chip": Rect2(0.745, 0.024, 0.130, 0.036),
	# LAMBA HALESİ KALDIRILDI (2026-08-18, Erdem): additive hale gece lamba
	# sprite'ının ÜSTÜNE biniyor ve düz siyah gövdeyi sütlü/yarı saydam
	# gösteriyordu — sanki lambanın kendisi parlıyormuş gibi. Gövde her iki
	# modda siyah kalır, gece yalnız AMPUL yanar; ışığı emissive ampul ile
	# plakaya baked havuz taşır. Node, token ve bu rect birlikte silindi.
	# Boyalı çerçeveler — DIŞ kutular (ahşap dahil):
	"frame_outer_0": Rect2(0.0191, 0.0596, 0.0668, 0.1512),
	"frame_outer_1": Rect2(0.1239, 0.0600, 0.0653, 0.1511),
	"frame_outer_2": Rect2(0.2286, 0.0604, 0.0639, 0.1509),
}

# --- D4 host-göreli tablolar (0..1, HOST rect'inin kesirleri) ----------------
# Pano kartları: sol kolon (hedef + pazar payı) / sağ kolon (post-it + tarihler);
# %4+ iç pay — hiçbir kart mantar yüzeyden taşamaz (sarmalayıcı klip emniyet).
const BOARD_REL := {
	# Sol kolon alt sınırı 0.80: monitör sprite'ı panonun sol-alt köşesini
	# örtüyor — kart monitörün ÜSTÜNE binemez (F5 turu 2, G1).
	"goal": Rect2(0.04, 0.05, 0.55, 0.26),
	"market": Rect2(0.04, 0.37, 0.55, 0.43),
	"postit": Rect2(0.63, 0.06, 0.33, 0.26),
	"dates": Rect2(0.63, 0.44, 0.33, 0.30),
}
# Monitör camı: monitor İÇERİK rect'ine göre (padded_target'a DEĞİL — pad payı
# camı kaydırır). Bezel içinde emniyetli inset (üst pay F5 turu 2'de büyüdü —
# CANLI çipi kenarda yarım kalıyordu).
# Sanat migrasyonunda YENİDEN TÜRETİLDİ: `screen` mesh'inin 8 dünya köşesi aynı
# kameradan izdüşürüldü ve monitör içerik-kutusuna oranlandı — göz kararı değil.
# Yüksekliğin 0.44'ten 0.62'ye çıkması gerçek: eski "monitor" sprite'ı klavyeyi
# de içeriyordu (pc_*.png), yeni monitör katmanı yalnız monitör.
# 2026-08-17 mühürlü sanat turunda AYNI YÖNTEMLE yeniden türetildi ve 5 ondalığa
# kadar AYNI çıktı (0.022676, 0.013814, 0.955390, 0.617586) — monitör de kamera da
# kımıldamadı. Bu, türetmenin tekrarlanabilir olduğunun bağımsız kanıtı.
# F5 turunda BİR KEZ daha değişti (~1px): rig'in `screen` mesh'i z=0.0148'deydi,
# mühürlü kaynak 0.017 diyor — rig eski bir sürümden kopyalanmış, fidelity düzeltildi.
# 2.2mm derinlik farkı camı kamera yönünde ~1px kaydırıyor. Değer yine ÖLÇÜM.
const MONITOR_GLASS_REL := Rect2(0.02144, 0.01339, 0.95672, 0.61844)
# Çerçeve belgesi: dış kutunun her kenardan içeri payı (ahşap + iç gölge görünür kalır).
const FRAME_DOC_INSET := Vector2(0.20, 0.15)
# Telefon camı ({merkez, boyut, açı} — AABB değil: kırpma DÖNMÜŞ sarmalayıcının
# yerel uzayında cama oturur).
# Sanat migrasyonunda ÜÇÜ DE YENİDEN TÜRETİLDİ (monitör camıyla aynı yöntem):
# telefonun `screen` mesh'inin üst yüzünün dört köşesi izdüşürüldü, açı UZUN
# kenardan okundu. Eski değerler suluboya çağındandı ve yeni sanatta YANLIŞTI —
# özellikle 31° dönme: gerçek yatış 6.5°, yani bildirim rozeti belirgin biçimde
# eğri oturuyordu. Yan fayda: cam 59×21'den 72×46 px'e çıktı (1080p, ×2.68 alan),
# çünkü eski 0.34 yükseklik oranı suluboyanın dik telefonuna göreydi; buradaki
# telefon masada YATIYOR ve ekranı görünen alanın çoğunu kaplıyor.
#
# 2026-08-17: ÜÇÜ DE YİNE değişti, çünkü mühürlü sahne telefonu hem taşıdı hem
# çevirdi. Buradaki asıl ders MODELİN SINIRI: bu üçlü DÖNMÜŞ DİKDÖRTGEN tanımlar,
# masaya yatık bir dörtgenin izdüşümü ise genel bir dörtgendir. Mühürlü yaw
# (−16.04°) makası 29.2°'ye çıkarıyordu ve dönmüş-dikdörtgen ARTIK OTURMUYORDU —
# rozet camın dışına taşardı. Çözüm rect'i küçültmek değil KAYNAĞI düzeltmek oldu
# (yaw → −2°, yönetmen onayı): makas 0.17°, yani cam pratikte eksen-hizalı.
# Kalan 6.2° "paralel-olmama" perspektif trapezidir ve yaw ile giderilemez —
# modelin kabul edilen artık hatası, bu satır onun kaydı.
const PHONE_GLASS_CENTER_REL := Vector2(0.5039, 0.4307)
const PHONE_GLASS_SIZE_REL := Vector2(0.8997, 0.8234)
const PHONE_GLASS_ANGLE_DEG := 0.63

# Masa kâğıdı slotları: {rect (x,y,w — h ipucu), rot (derece)} — klavyenin SOLU.
# Sanat migrasyonunda TAŞINDI (Erdem onayı 2026-08-10). Suluboya odada bu yuvalar
# klavyenin sol-altındaki AÇIK zemindeydi; gerçek 3B masada klavye tam oraya
# oturuyor (ölçüldü: klavye x 0.3029..0.4437, y 0.8690..0.9111) ve ilk iki yuva
# tuşların üstüne düşüyordu. Yeni şerit lamba ile klavye ARASINDAKİ açık masa:
# lamba sağ kenarı 0.1091, klavye sol kenarı 0.3029 — üçü de ölçümle temiz.
# Kaydırma ve dönme açıları korundu; genişlik 0.170→0.158 (şerit daha dar).
# Üçü de artık GÖRÜNÜR BANDIN İÇİNDE bitiyor (sonuncusu 0.978 < 0.980). Bu,
# devraldığım durumdan daha iyi: eski üçüncü yuva 0.988'de bitiyordu ve
# MAX_CROP notunun kendisi onun "bugün de kıl payı kırpıldığını" kabul ediyordu.
const PAPER_SLOTS := [
	{"rect": Rect2(0.120, 0.836, 0.158, 0.048), "rot": -1.5},
	{"rect": Rect2(0.132, 0.883, 0.158, 0.048), "rot": 1.0},
	{"rect": Rect2(0.124, 0.930, 0.158, 0.048), "rot": -0.5},
]


# --- KEEP_ASPECT_COVERED matematiği + EN-BOY TAVANI --------------------------

## Odanın en-boy tavanı — bir KIRPMA BÜTÇESİ olarak ifade edilir (MAX_CROP).
##
## Neden bir tavan gerekiyor: kompozisyon dikeyde 0.0'dan (pencere) 0.98'e
## (kâğıtlar) UZANIYOR, yani DİKEY KIRPMA BÜTÇESİ SIFIR. Saf COVER, viewport
## 16:9'dan genişledikçe tam da dikeyden kırpar. Ölçüldü (5120x1440 shot'ı):
## görünür bant [0.261, 0.739]'e iniyor ve üç çerçeve, kâğıtlar ve TELEFON
## tamamen ekran dışında kalıyor — üçü de tıklanabilir çapa, telefon mentor/olay
## yüzeyi. 3440x1440'ta bant [0.128, 0.872] ve çerçeveler ortadan ikiye bölünüyor.
##
## Tavan YALNIZ GENİŞ yönde uygulanır: 16:9 ve DAHA DAR (16:10, 4:3) viewport'lar
## bugünkü davranışı bire bir korur, yani mevcut kurulumlarda hiçbir gerileme yok.
## 16:10'un ~%5 yatay kırpması bilinçli kalıyor: yalnız pencere resminin sağ
## kenarına değiyor ve o çapa tıklanmaz (tur bölgesi).
## Değer NEDEN bir KIRPMA BÜTÇESİ, sabit bir en-boy değil: bütçe aşılana kadar
## hiçbir şey değişmez, aşıldığında oda bütçeyi SONUNA KADAR kullanır — geçiş
## yumuşaktır, eşikte görsel uçurum yoktur.
##
## Ve NEDEN 0.02: bu, 1920x1080'de CenterViewport'un zaten çalıştığı nokta
## (~1.851 oran, %1.94 kırpma), yukarı yuvarlanmış.
##
## GÜNCELLEME (sanat migrasyonu 2026-08-10): bu notun eski hali "kompozisyonun
## gerçek alt payı 0.012'dir (PAPER_SLOTS'un üçüncüsü 0.988'de biter) ve o yuva
## BUGÜN de kıl payı kırpılıyor" diyordu. ARTIK DOĞRU DEĞİL — kâğıt yuvaları
## taşınırken üçü de bandın içine alındı (sonuncusu 0.978 < 0.980), yani
## kompozisyonun alt payı tam olarak 0.020 ve hiçbir çapa kırpılmıyor.
## Bütçe 0.02'de KALIYOR: artık bir gerilemeyi tolere etmek için değil,
## kompozisyonun ölçülen sınırına birebir oturduğu için. Bandı daraltmak
## (0.012'ye çekmek) birincil çözünürlüğe yan şerit koyar — hâlâ kabul edilemez.
const MAX_CROP := 0.02


## Bütçenin izin verdiği en geniş oran. crop = 0.5 * (1 - A/r) → r = A / (1 - 2C).
static func max_room_aspect() -> float:
	return (ART.x / ART.y) / (1.0 - 2.0 * MAX_CROP)


## Viewport içinde odanın gerçekten çizildiği rect. Geniş ekranlarda ortalanır ve
## iki yanda boşluk bırakır (oda_view onu BG_ART plakasıyla doldurur).
static func room_rect(view: Vector2) -> Rect2:
	if view.y <= 0.0:
		return Rect2(Vector2.ZERO, view)
	var max_w: float = view.y * max_room_aspect()
	if view.x <= max_w:
		return Rect2(Vector2.ZERO, view)
	return Rect2(Vector2((view.x - max_w) * 0.5, 0.0), Vector2(max_w, view.y))


## TEK dönüşüm. Her çapa, her host-türetimli yüzey ve visible_band_y bundan
## türediği için tavanı BURAYA koymak hepsini birlikte taşır — tek çağrı sitesi
## değişmedi.
static func cover_transform(view: Vector2) -> Dictionary:
	var room: Rect2 = room_rect(view)
	var s: float = maxf(room.size.x / ART.x, room.size.y / ART.y)
	var drawn: Vector2 = ART * s
	return {"scale": s, "offset": room.position + (room.size - drawn) * 0.5}


static func place(n: Rect2, view: Vector2) -> Rect2:
	var t: Dictionary = cover_transform(view)
	var drawn: Vector2 = ART * float(t.scale)
	return Rect2(Vector2(t.offset) + n.position * drawn, n.size * drawn)


## D4.1: host piksel-rect'i içinde göreli rect → piksel-rect. Host-türetimli her
## yüzey yalnız bundan geçer; host kımıldarsa yüzey onunla kımıldar.
static func rect_in(host_px: Rect2, rel: Rect2) -> Rect2:
	return Rect2(host_px.position + rel.position * host_px.size, rel.size * host_px.size)


## Çerçeve belgesi: dış kutu → FRAME_DOC_INSET ile içerlek belge rect'i.
static func frame_doc_rect(outer_px: Rect2) -> Rect2:
	var inset: Vector2 = outer_px.size * FRAME_DOC_INSET
	return Rect2(outer_px.position + inset, outer_px.size - inset * 2.0)


static func visible_band_y(view: Vector2) -> Vector2:
	var t: Dictionary = cover_transform(view)
	var drawn_y: float = ART.y * float(t.scale)
	var crop: float = maxf(0.0, -float(t.offset.y)) / drawn_y
	return Vector2(crop, 1.0 - crop)


## Yalnız HOST'SUZ yüzeyler için (bugün tek kullanıcı: overtime_chip). Host-türetimli
## yüzeylerde KULLANILMAZ — bağımsız band-clamp host/yüzey ayrışmasını geri getirir.
static func place_clamped(n: Rect2, view: Vector2) -> Rect2:
	var band: Vector2 = visible_band_y(view)
	var r := n
	r.position.y = clampf(r.position.y, band.x + 0.005, band.y - r.size.y - 0.005)
	return place(r, view)


# --- AtlasTexture yardımcıları ----------------------------------------------

static func padded_region(id: String, imported_scale: float = 1.0) -> Rect2:
	var r: Rect2 = (REGIONS[id] as Rect2).grow(REGION_PAD)
	return Rect2(r.position * imported_scale, r.size * imported_scale)


static func padded_target(id: String) -> Rect2:
	var region: Rect2 = REGIONS[id] as Rect2
	var rect: Rect2 = RECTS[id] as Rect2
	var gx: float = REGION_PAD / region.size.x
	var gy: float = REGION_PAD / region.size.y
	return Rect2(
		rect.position - Vector2(rect.size.x * gx, rect.size.y * gy),
		rect.size * Vector2(1.0 + 2.0 * gx, 1.0 + 2.0 * gy))
