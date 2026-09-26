class_name OdaLayout
extends RefCounted

# ODA yerleşim defteri — odanın TEK ayar yüzeyi; oda_view.gd koordinat sabiti taşımaz.
#
# Sahne sanatı 3840×2160 (room_day / room_night); obje sprite'ları AYNI kameradan
# AYNI kanvasa render edildi (sahne-hizalı). Bu yüzden RECTS[id] == REGIONS[id] / ART,
# hedef aspect == region aspect yapısal olarak tutar (STRETCH_SCALE güvenli) ve sprite
# plakadaki baked gölgesinin tam üstüne oturur. REGIONS render'ın alfa kanalından,
# boyalı çapalar oda geometrisinin izdüşümünden ÖLÇÜLDÜ; sahne değişirse yeniden ölçülür.
#
# İÇERİK YERLEŞİM STANDARDI (bağlayıcı):
# 1. Host-türetimli her bilgi yüzeyi (monitör camı, pano kartları, çerçeve belgeleri,
#    telefon camı) ev sahibi rect'inden SABİT ORAN + SABİT İÇ PAY ile türetilir
#    (rect_in / *_REL tabloları) — mutlak rect yazılmaz; host ile yüzey ayrışamaz.
# 2. Her yüzey = düz Control sarmalayıcı (clip_contents=true, min-size yaymaz — set_size'ın
#    minimuma yukarı clamp'i taşma üretemez) + içte full-rect temalı panel. Clip
#    sarmalayıcıdadır (panelin kendi stylebox'ını ancak o kırpar). Monitör dahil.
# 3. Okunabilirlik tabanı 9px (tip skalasının MICRO adımı): içerik host'a sığmıyorsa metin
#    küçültülmez — asset büyümeli; karar Erdem'e.
#
# Kadraj notları:
#   * Masa/duvar birleşimi ~y 0.76. Pano, çerçeve üçlüsü, pencere BOYALI.
#   * Gece lamba ışık havuzu solda baked (merkez x 0.283, y 0.893) — kâğıt yuvaları ona oturur.
#   * frame_outer_N ahşap DAHİL dış kutudur; belge rect'i FRAME_DOC_INSET ile içeri alınır.
#   * Lamba sol kenarı (48px) REGION_PAD'in hemen üstünde: lamba daha sola alınırsa
#     padded_region kanvasın dışına taşar.

const ART := Vector2(3840, 2160)
const REGION_PAD := 24.0            # rim-glow shader kenar payı (kaynak px) — # WORKING

# Obje sprite'ları: kaynak içerik-kutusu (px, 3840-uzayı).
const REGIONS := {
	"monitor": Rect2(1051, 951, 935, 871),
	"keyboard": Rect2(1163, 1877, 541, 91),
	"lamp": Rect2(48, 1297, 338, 506),
	"mug": Rect2(2185, 1742, 174, 175),
	"phone": Rect2(1976, 1935, 126, 106),
}
const RECTS := {
	# Objeler — REGIONS / ART:
	"monitor": Rect2(0.27370, 0.44028, 0.24349, 0.40324),
	"keyboard": Rect2(0.30286, 0.86898, 0.14089, 0.04213),
	"lamp": Rect2(0.01250, 0.60046, 0.08802, 0.23426),
	"mug": Rect2(0.56901, 0.80648, 0.04531, 0.08102),
	"phone": Rect2(0.51458, 0.89583, 0.03281, 0.04907),
	# Boyalı çapalar (hotspot / tur bölgeleri) — mesh köşelerinin izdüşümü, render'dan ölçülür:
	"board_outer": Rect2(0.3400, 0.0392, 0.3762, 0.4515),
	"board_inner": Rect2(0.3550, 0.0669, 0.3459, 0.3994),  # mantar yüzey — pano kartlarının HOST'u
	"frames_band": Rect2(0.0191, 0.0596, 0.2734, 0.1517),
	"window": Rect2(0.9000, 0.0, 0.1000, 0.8070),      # tıklanmaz — yalnız tur; camın parlak bandı
	# Hotspot değil; tur + kümeleme. Alt kenar 0.978 görünür bandın (0.020..0.980) içinde kalmalı.
	"papers_zone": Rect2(0.120, 0.836, 0.170, 0.142),
	# Host'suz tek yüzey (place_clamped'in tek kullanıcısı): pano ile pencere arasındaki boşluk.
	"overtime_chip": Rect2(0.745, 0.024, 0.130, 0.036),
	# Boyalı çerçeveler — DIŞ kutular (ahşap dahil):
	"frame_outer_0": Rect2(0.0191, 0.0596, 0.0668, 0.1512),
	"frame_outer_1": Rect2(0.1239, 0.0600, 0.0653, 0.1511),
	"frame_outer_2": Rect2(0.2286, 0.0604, 0.0639, 0.1509),
}

# --- Host-göreli tablolar (0..1, HOST rect'inin kesirleri) --------------------
# Pano kartları: sol kolon (hedef + pazar payı) / sağ kolon (post-it + tarihler); %4+ iç pay.
# Sol kolon alt sınırı 0.80: monitör sprite'ı panonun sol-alt köşesini örtüyor.
const BOARD_REL := {
	"goal": Rect2(0.04, 0.05, 0.55, 0.26),
	"market": Rect2(0.04, 0.37, 0.55, 0.43),
	"postit": Rect2(0.63, 0.06, 0.33, 0.26),
	"dates": Rect2(0.63, 0.44, 0.33, 0.30),
}
# Monitör camı: monitor İÇERİK rect'ine göre (padded_target'a değil — pad camı kaydırır).
# `screen` mesh'inin köşeleri aynı kameradan izdüşürülüp içerik-kutusuna oranlandı.
const MONITOR_GLASS_REL := Rect2(0.02144, 0.01339, 0.95672, 0.61844)
# Çerçeve belgesi: dış kutunun her kenardan içeri payı (ahşap + iç gölge görünür kalır).
const FRAME_DOC_INSET := Vector2(0.20, 0.15)
# Telefon camı {merkez, boyut, açı} — AABB değil: kırpma DÖNMÜŞ sarmalayıcının yerel
# uzayında cama oturur. Masaya yatık ekranın izdüşümü aslında genel bir dörtgendir;
# dönmüş dikdörtgen modeli ancak ekran kenarları makassız kaldıkça (sahnede telefon
# yaw −2°, makas 0.17°) oturur. Kalan ~6° perspektif trapezi modelin kabul edilen artık hatasıdır.
const PHONE_GLASS_CENTER_REL := Vector2(0.5039, 0.4307)
const PHONE_GLASS_SIZE_REL := Vector2(0.8997, 0.8234)
const PHONE_GLASS_ANGLE_DEG := 0.63

# Masa kâğıdı slotları: {rect (x,y,w — h ipucu), rot (derece)} — lamba ile klavye
# arasındaki açık masa şeridi; üçü de görünür bandın içinde biter (sonuncusu 0.978).
const PAPER_SLOTS := [
	{"rect": Rect2(0.120, 0.836, 0.158, 0.048), "rot": -1.5},
	{"rect": Rect2(0.132, 0.883, 0.158, 0.048), "rot": 1.0},
	{"rect": Rect2(0.124, 0.930, 0.158, 0.048), "rot": -0.5},
]


# --- KEEP_ASPECT_COVERED matematiği + EN-BOY TAVANI --------------------------

## Odanın en-boy tavanı, bir KIRPMA BÜTÇESİ olarak.
##
## Kompozisyon dikeyde 0.0'dan (pencere) 0.98'e (kâğıtlar) uzanır; saf COVER geniş
## viewport'ta tam da dikeyden kırpar ve çerçeveler, kâğıtlar, telefon (hepsi tıklanabilir
## çapa) ekran dışına düşer. Tavan yalnız geniş yönde uygulanır: 16:9 ve daha dar
## viewport'lar tam cover kalır (16:10'un ~%5 yatay kırpması yalnız tıklanmayan pencereye
## değer). Bütçe aşılana kadar hiçbir şey değişmez, aşılınca oda bütçeyi sonuna kadar
## kullanır — eşikte görsel uçurum yok.
## 0.02: kompozisyonun alt payı tam bu (kâğıtlar 0.978'de biter) ve 1920x1080 kabuğu
## (~1.851 oran, %1.94 kırpma) içinde kalır; daha küçüğü birincil çözünürlüğe yan şerit koyar.
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


## TEK dönüşüm: her çapa, her host-türetimli yüzey ve visible_band_y bundan türer,
## o yüzden sanat ile çapalar yapısal olarak ayrışamaz.
static func cover_transform(view: Vector2) -> Dictionary:
	var room: Rect2 = room_rect(view)
	var s: float = maxf(room.size.x / ART.x, room.size.y / ART.y)
	return {"scale": s, "offset": room.position + (room.size - ART * s) * 0.5}


static func place(n: Rect2, view: Vector2) -> Rect2:
	var t: Dictionary = cover_transform(view)
	var drawn: Vector2 = ART * float(t.scale)
	return Rect2(Vector2(t.offset) + n.position * drawn, n.size * drawn)


## Host piksel-rect'i içinde göreli rect → piksel-rect. Host kımıldarsa yüzey onunla kımıldar.
static func rect_in(host_px: Rect2, rel: Rect2) -> Rect2:
	return Rect2(host_px.position + rel.position * host_px.size, rel.size * host_px.size)


## Çerçeve belgesi: dış kutu → FRAME_DOC_INSET ile içerlek belge rect'i.
static func frame_doc_rect(outer_px: Rect2) -> Rect2:
	var inset: Vector2 = outer_px.size * FRAME_DOC_INSET
	return Rect2(outer_px.position + inset, outer_px.size - inset * 2.0)


static func visible_band_y(view: Vector2) -> Vector2:
	var t: Dictionary = cover_transform(view)
	var crop: float = maxf(0.0, -float(t.offset.y)) / (ART.y * float(t.scale))
	return Vector2(crop, 1.0 - crop)


## Yalnız HOST'SUZ yüzeyler için. Host-türetimli yüzeylerde kullanılmaz — bağımsız
## band-clamp host/yüzey ayrışmasını geri getirir.
static func place_clamped(n: Rect2, view: Vector2) -> Rect2:
	var band: Vector2 = visible_band_y(view)
	var r := n
	r.position.y = clampf(r.position.y, band.x + 0.005, band.y - r.size.y - 0.005)
	return place(r, view)


# --- AtlasTexture yardımcıları ----------------------------------------------

## Region 3840-uzayında yazılı; import size_limit dokuyu küçültmüş olabilir, o yüzden
## gerçek doku genişliğine ölçeklenir (gece/gündüz varyantları ayrı ölçeklenebilir).
static func padded_region(id: String, tex: Texture2D) -> Rect2:
	var s: float = tex.get_width() / ART.x
	var r: Rect2 = (REGIONS[id] as Rect2).grow(REGION_PAD)
	return Rect2(r.position * s, r.size * s)


static func padded_target(id: String) -> Rect2:
	var region: Rect2 = REGIONS[id]
	var rect: Rect2 = RECTS[id]
	var g := Vector2(REGION_PAD / region.size.x, REGION_PAD / region.size.y) * rect.size
	return Rect2(rect.position - g, rect.size + g * 2.0)
