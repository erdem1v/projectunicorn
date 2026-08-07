class_name OdaLayout
extends RefCounted

# ============================================================================
# ODA yerleşim defteri — TEK ayar yüzeyi (ODA rework 2026-08-06; D4 standardı
# kalite turu v2'de eklendi).
# ============================================================================
# Sahne sanatı 3840×2160 (LIGHT gündüz / DARK gece); obje sprite'ları AYNI
# kanvasta ama SAHNE-HİZALI DEĞİL — merkezlenmiş hero render'lar. Her obje,
# kaynak içerik-kutusundan (REGIONS, px) normalize hedef-rect'e (RECTS, 0..1)
# yerleştirilir. Hedef aspect == region aspect (STRETCH_SCALE güvenli).
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
#   * Masa/duvar birleşimi ~y 0.63-0.68; pano, çerçeve üçlüsü, pencere BOYALI.
#   * GECE sahnesinde lamba ışık havuzu SOLDA baked → lamba hedefi ona oturur.
#   * frame_outer_N ölçümleri AHŞAP DAHİL dış kutudur (kalite turu bulgusu) —
#     belge rect'i FRAME_DOC_INSET ile içeri alınır, ahşap hep görünür kalır.

const ART := Vector2(3840, 2160)
const REGION_PAD := 24.0            # rim-glow shader kenar payı (kaynak px) — # WORKING
const MIN_READABLE_FONT_PX := 9     # tip skalasının MICRO adımı = mutlak okunabilirlik tabanı (D4.3)

# --- Obje sprite'ları: kaynak içerik-kutusu (px) + hedef (normalize) ---------
const REGIONS := {
	"monitor": Rect2(1248, 378, 1348, 1428),
	"phone": Rect2(1069, 384, 1703, 1405),
	"lamp": Rect2(1482, 532, 845, 1162),
	"mug": Rect2(1450, 599, 1107, 1075),
}
const RECTS := {
	# Objeler (hedef aspect == region aspect):
	"monitor": Rect2(0.315, 0.375, 0.280, 0.527),
	"phone": Rect2(0.700, 0.735, 0.100, 0.147),
	"lamp": Rect2(0.100, 0.462, 0.130, 0.318),
	"mug": Rect2(0.630, 0.700, 0.062, 0.107),
	# Boyalı çapalar (hotspot / tur bölgeleri):
	"board_outer": Rect2(0.405, 0.042, 0.390, 0.418),
	"board_inner": Rect2(0.418, 0.058, 0.364, 0.386),  # mantar yüzey — pano kartlarının HOST'u
	"frames_band": Rect2(0.118, 0.060, 0.235, 0.155),
	"window": Rect2(0.868, 0.0, 0.132, 0.63),          # tıklanmaz — yalnız tur
	"papers_zone": Rect2(0.320, 0.790, 0.200, 0.190),  # hotspot değil; tur + kümeleme
	# Host'suz tek yüzey (pencere altı çipi — place_clamped'in kalan tek kullanıcısı):
	"overtime_chip": Rect2(0.688, 0.024, 0.130, 0.036),
	"lamp_glow": Rect2(0.137, 0.477, 0.160, 0.284),    # lamba başı halesi (merkez ~0.197, 0.537)
	# Boyalı çerçeveler — DIŞ kutular (ahşap dahil):
	"frame_outer_0": Rect2(0.127, 0.075, 0.051, 0.128),
	"frame_outer_1": Rect2(0.204, 0.073, 0.057, 0.130),
	"frame_outer_2": Rect2(0.285, 0.071, 0.059, 0.135),
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
const MONITOR_GLASS_REL := Rect2(0.07, 0.085, 0.855, 0.44)
# Çerçeve belgesi: dış kutunun her kenardan içeri payı (ahşap + iç gölge görünür kalır).
const FRAME_DOC_INSET := Vector2(0.20, 0.15)
# Telefon camı ({merkez, boyut, açı} — AABB değil: kırpma DÖNMÜŞ sarmalayıcının
# yerel uzayında cama oturur; açının işareti ilk shot'ta doğrulanır).
const PHONE_GLASS_CENTER_REL := Vector2(0.50, 0.50)
const PHONE_GLASS_SIZE_REL := Vector2(0.72, 0.34)
const PHONE_GLASS_ANGLE_DEG := 31.0

# Masa kâğıdı slotları: {rect (x,y,w — h ipucu), rot (derece)} — klavyenin sol-altı.
const PAPER_SLOTS := [
	{"rect": Rect2(0.300, 0.832, 0.170, 0.050), "rot": -1.5},
	{"rect": Rect2(0.316, 0.890, 0.170, 0.050), "rot": 1.0},
	{"rect": Rect2(0.307, 0.938, 0.170, 0.050), "rot": -0.5},
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
## Ve NEDEN 0.02, veri türevi değil: kompozisyonun gerçek alt payı 0.012'dir
## (PAPER_SLOTS'un üçüncüsü 0.988'de biter), ama 1920x1080'de CenterViewport
## zaten ~1.851 oranında ve %1.94 kırpıyor — yani üçüncü kâğıt yuvası BUGÜN de
## kıl payı kırpılıyor. Bütçeyi 0.012'ye çekmek, ÖNCEDEN VAR OLAN bir yerleşim
## meselesini düzeltmek uğruna BİRİNCİL çözünürlüğe şeritler koymak olurdu; bu
## daha büyük bir gerileme. 0.02 = bugünkü 16:9 çalışma noktası, yukarı yuvarlanmış.
## Kâğıt payı polish dalgasının işi — bu tavan onu ÇÖZMEZ, korur.
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
