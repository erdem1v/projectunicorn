# Ürün Rev 7 · Faz A · görsel kabul notları (2026-10-01)

Resmî kareler `C1.png … C5.png` (1920×1080, `--product-shot=c1..c5`, TR). Referans: `docs/mockups/urun_rev7/*.png`
(tasarım kaynağından headless Edge ile basıldı). Ek kareler `extra/`: kart galerisi (`product7_shot_cards`), akış
(`flow_start/advance/plan_next`), 15 uç durum (`edge_*`), EN (`c1_en`, `c3_en`, `c5_en`), arayüz ölçeği 1.25
(`scale125_*`), 1600×900 (`s1600_*`), renk körü paleti (`cb_*`). Etkileşim MCP + OS-tıkla canlı oyunda doğrulandı.

## 1. Envanter eşleşmesi (C1-01 … C5-05)

| Öge | Durum | Not |
|---|---|---|
| C1-01 üst şerit | var | Ad serif, `CANLI v1.4`, `B2C · NOT & BİLGİ ARACI`, Geçmiş anahtarı, SPRINT \| ÇEYREK (kilitli ÇEYREK kilit ikonlu, mockup gibi), × başlık satırında |
| C1-02 ALANLAR | var | Amber bölüm başlığı + çizgi (task "gri" diyor, mockup amber: yerleşimde mockup) |
| C1-03 kapalı satır | var | Ad · balon çipi · ›; dilim + kelime; cümle |
| C1-04 açık satır | var | "4 · 1 yeni", "Rakip: mobil", ∨ (task "yukarı" diyor, mockup ∨) |
| C1-05 YAPILANLAR | var | Yapılmamış yetenek □□□ (sahip kararı, "—" yerine); "n/3 rakipte var" çipi, ipucunda rakip adları |
| C1-06 YAPILABİLECEKLER | var | İki soluk kart "Sprint 7/8" damgalı, iki kart + → |
| C1-07 SESLER | var | "4 ses · 1 yeni" + ›; açılınca liste ve YENİ damgası (`edge_voices_open`) |
| C1-08 diğer satırlar | var | Büyüme çip 1, Güven "!" kırmızımsı zemin, Gelir "Yok". 1920×1080'de Gelir satırı alt kenarda yarım: sol panel kayar (bkz. §4) |
| C1-09 orta başlık | var | SPRINT 7 · 2 hafta / BU SPRINT, kart renkli bölümlü çubuk, 10/12, KU (vurgulu) DE EC KA, uyarı çipi |
| C1-10 sprint kartları | var | Kesinti düzeltmesi 2, Kısa kayıt 3, Filtreli arama 5; Kısa kayıt hover kutusu "3 puan · Ece 1 hafta · Kaan 1 hafta" |
| C1-11 SPRINT SONUNDA | var | "Onboarding Zayıf → Yeterli · Güven ! kalkar · 3 ticket kapanır" (öngörü kipi: kelime, balon ikonu) |
| C1-12 liderin önerisi | var | "LİDERİN ÖNERİSİ · Deniz" (sahip: lead → lider) + italik cümle |
| C1-13 Beta kanalı | var | Kapalı \| Açık |
| C1-14 Sprinti başlat | var | Birincil düğme; boş sprintte pasif + "En az bir kart ekle" |
| C1-15 sağ panel | var | SPRINT 8 / SONRAKİ, gri "Rakip: mobil" bayrağı, iki "planlanan" kart. "Otomatik yedekleme" adı dar sütunda iki satır |
| C2-01 başlık | var | "Hafta 1/2"; çubukta bitmiş puan koyu (PRD/task; mockup C2 çubuğu C1 ile aynı çizmiş) |
| C2-02 faz noktaları | var | Tasarım · Geliştirme · Test (sahip: Kod → Geliştirme); dolu / amber halka / boş; avatarlar; bitmiş kartta yeşil tik |
| C2-03 karar satırı | var | DE · "Deniz:" · italik cümle · Karar ver → olay modalı açılıyor (MCP) |
| C2-04 DURUM | var | ✓ 1 kart bitti · ◎ 2 sürüyor · 💬 1 karar bekliyor |
| C2-05 SONRAKİ SÜRÜM | var | v1.5 · 1 hafta sonra; altında Beta kanalı |
| C2-06 sağ panel | var | C1 ile aynı |
| C3-01 CANLI v1.5 | var | |
| C3-02 sol panel okları | var | Onboarding ■□□ → ■■□ · Zayıf → Yeterli; Güven'de "!" yok |
| C3-03 sürüm notu | var | SÜRÜM NOTU · Sprint 7 sonu, v1.5 + CANLI, ÇIKANLAR, DEVREDEN (5 dilim, → Sprint 8), HIZ 8/12, SONUÇ ("Gerçekleşen:" öneki, PRD §2.3), BASIN "TeknoGündem · …", "Deniz · lider" |
| C3-04 alt | var | Beta kanalı · "Sprint 8 planına geç" (sahip: eksiz kalıp) |
| C3-05 sağ panel | var | "devreden" damgalı Filtreli arama (kalan 2) + planlananlar |
| C4-01 hedef şeridi | var | BU ÇEYREK ■ Onboarding · yeni kullanıcıların yarısı kalsın; 4 dolu kare + hedef işareti; "şu an 10'da 4" |
| C4-02 sol panel | var | Dar, kapalı, şevronsuz |
| C4-03 altı sütun | var | 7 BU SPRINT vurgulu 10/12; 8 PM 9/12 + Rakip: mobil; 9 PM 8/12; 10 PM 6/12; 11–12 kesikli boş. Mini kartlarda uzun ad iki satır |
| C4-04 düğmeler | var | Onayla / Düzenle her PM sütununda; Hepsini onayla sağ altta |
| C5-01 üst şerit | var | Fatura · CANLI v1.4 · B2B · FATURALAMA SAAS'I |
| C5-02 satırlar | var | Çekirdek, Onboarding, Entegrasyonlar (kırmızımsı), Güven açık ("!", Yapılanlar 3, Yapılabilecekler 2 soluk + 1 + →) |
| C5-03 Müşteriler | var | "Müşteriler · 3 talep"; Nordica satırı görünür, Palmiye ve Beykoz 1920×1080'de kaydırınca (bkz. §4) |
| C5-04 orta | var | Etki satırında talep ve "$12.000/yıl"; SPRINT SONUNDA iki "talebi zamanında"; lider "SSO gecikirse Nordica yenilemez." |
| C5-05 sağ | var | Kırmızı "Nordica · SSO · son tarih" bayrağı; planlanan e-Fatura entegrasyonu 5 (ad iki satır) |

## 2. Task §9 doğrulama listesi

| # | Durum | Kanıt |
|---|---|---|
| 1 | ✅ | §1 tablosu |
| 2 | ✅ | `scenes/tabs/product/SprintCard.tscn` tek sahne, `@export var state: State`; dokuz durum `extra/product7_shot_cards.png` |
| 3 | ✅ | MCP: Büyüme'ye tık → Onboarding kapandı, Büyüme açıldı; açık satır sol kaydırma alanında |
| 4 | ✅ | `flow_*` kareleri + MCP: Sprinti başlat → Hafta 1/2 → kapanış → sürüm notu; `TimeManager.is_clock_held()` true, 1x tuşu yutuldu; "Sprint 8 planına geç" → false |
| 5 | ✅ | MCP: "+" (Mobil giriş sprinte, 14/12 kırmızı, "devreder"), "→" (5 kullanıcıyla görüş Sprint 8'e), "↑" (İlk tur rehberi sprinte); sağ panel her durumda |
| 6 | ✅ | `edge_over_100` (14/12, devreder), `edge_over_125` (16/12, can_add false → "+" pasif); bölüm renkleri kart alan renkleri |
| 7 | ✅ | C2 |
| 8 | ✅ | MCP: Karar ver → olay modalı ("OYUN DURAKLATILDI") |
| 9 | ✅ | MCP: sonraki sütunda hover kutusu sütun içinde kalıyor; sığmazsa parçalar alt alta |
| 10 | ✅ | MCP: Geçmiş açık → sürüm listesi sol panelin üstünde, ızgara yerinde; boş hâl `edge_history_empty` |
| 11 | ✅ | PM yok: ÇEYREK pasif + "PM işe alınca" ipucu (MCP); açık hâl (fikstür): Onayla → ONAYLANDI, Düzenle → SPRINT görünümü, Hepsini onayla (MCP) |
| 12 | ✅ | C5 (fikstür B2B koşusu) |
| 13 | ✅ | 15 uç durum karesi, hepsi 0 hata |
| 14 | ✅ | `loc_residue` CLEAN (0 hit); sahnelerde metin yok |
| 15 | ⚠️ | Variation adları kullanıldı. Override'lar: renk körü kümesi (CANLI, uyarı çipi, "!", son tarih, kırmızı satır, Güçlü/Zayıf, taşma, tik, bitmiş faz) + duruma bağlı faz etiketi ve seviye kelimesi renkleri (`make_label` rengi) |
| 16 | ✅ | `s1600_*` ve `scale125_*`: yatay taşma yok, sol panel dikeyde kayar |
| 17 | ✅ | Bu klasör |

## 3. Task §10 Erdem'in bakacakları → kare

- Uzun etki satırı kesilmesi: `C5.png`, `extra/product7_shot_c5_en.png` (kesilme yok; dar sağ sütunda ad iki satır).
- Açık alan satırındaki kart ile orta kart aynı boy/hiza: `C1.png` (aynı sahne; aday kartta sağda damga/düğme sütunu var).
- Uyarı çipi ile avatarların çakışması: `C1.png`, `extra/scale125_c5.png`.
- Sürüm notunda v1.5 ve 8/12 ağırlığı: `C3.png` (DataMonoHero 32, DataMonoLarge 24).
- Çeyrek altı sütun 1600×900: `extra/s1600_c4.png`, `extra/scale125_c4.png`.
- PRD §8 ek: CB paletinde Güçlü/Zayıf, "!", CANLI: `extra/cb_c1.png`, `extra/cb_c2.png`, `extra/cb_c5.png`.

## 4. Mockup ile ekran farkı (ekran başına)

- **Hepsi:** Pencere 1424×960 (mockup 1560): BuildHUD 1920 tabanında x ≥ 1540'ta pencerenin üstünde çiziliyor.
  Sağ sütun bu yüzden daha dar; uzun adlar iki satıra iniyor. Kart 56 px / aralık 8 (task §6), mockup 51 / 4-6:
  satırlar biraz daha yüksek. Fontlar oyunun üçlüsü (JetBrains Mono, Plex Sans, Source Serif). Kapasite çubuğu köşeleri düz.
  Hover kutusunda mockup'taki küçük ok yok. Aktif faz etiketi kalın değil.
- **C1:** Gelir satırı alt kenarda yarım görünür (sol panel kaydırılır). Eksik öge yok.
- **C2:** Pencere boyu sabit, mockup içerik boyunda (alt boşluk). Eksik öge yok.
- **C3:** SONUÇ satırı "Gerçekleşen:" önekli (PRD). DEVREDEN başlığı üstündeki boşluk mockup'tan dar.
- **C4:** Mini kart adları iki satıra sarıyor (dar sütun). Eksik öge yok.
- **C5:** Müşteriler satırının Palmiye ve Beykoz kayıtları kaydırınca görünür. Eksik öge yok.
