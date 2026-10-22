# Memnuniyet ve ekonomi simülasyonu (C_ICERIK_v3 §7)
Yazan: simülasyon ajanı · 2026-10-17 · Kaynak: `C_ICERIK_v3.md` (§3 gider, §4 bütçe kesintisi, §5 model, §7 simülasyon tanımı), `KALITE_v2.md` (U),
`ERDEM_CDQ_CEVAP.md` ile `ERDEM_CD_YORUM.md` (birebir), `C_ICERIK_v2.md` (§2.6 yenileme tutumu), araştırma `R9`, A'nın K5 bot kayıtları
(`docs/tasks/faz_ab/a_calisma/K5_runs/`: 8 B2B ve 8 B2C koşu, 104 hafta). Kod `f4a623b` (B2) üstünde okundu. Koda dokunulmadı, commit yok, Godot koşmadı;
yalnız `python -I`, standart kitaplık.

Betikler (repoda değil): `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/msim/`.
Yeniden koşturma §9'da.

Etiketler:
- **ölçüm:** K5 kaydından okunan ya da simülasyondan çıkan sayı.
- **tahmin:** bot kararları sabit tutularak yapılan hesap; oyun koşusu değil.
- **öneri:** kapı kaldığı için ayrı koşuyla gösterilen düzeltme. Modele girmedi; model olduğu gibi ölçüldü.
- **yorum:** belgede eksik ya da çelişkili yerde seçtiğim okuma; hepsi §7'de.

---

## 0. Erdem'e özet

1. **Kayma (ölçüm).** Eski kodda hesap imzada 50-52 ile açılıp haftada en çok 21 puan (ilk 4 hafta 35) gizli hedefe yürüyor. K5'te (2.769 hesap) hiç düzeltmeyen kolda hesapların %87'si ilk haftada en az 5 puan düşüyor; ortalama 52 → 44 → 42 (1. ve 4. hafta). Düzelten kollarda ortalama 58'e çıkıyor, ama %18-20'si yine ilk haftada en az 5 puan düşüyor.
2. **Nedensiz düşüş (M1): GEÇTİ.** K5'te 14.175 düşüş haftasının 1.450'si (dar tanım) ya da 337'si (geniş tanım) hiçbir adlı olaya bağlanamıyor. Yeni modelde 250 bin hesap-haftasında ve bütün senaryolarda sayı 0.
3. **İmza (M2, M10): GEÇTİ.** Yeni modelde hesap gerçek değerle açılıyor ve ilk 12 haftada altına inmiyor (2.197 imza, 0 istisna). Eski mekanizmada 2.256 imzanın 105'i iniyor (erken haftalarda %25). Kapı `fix_worst` imzalarının %86,4'ünü geçiriyor.
4. **Dikkat: ürün uyumu 100'e doyuyor.** Bot ürünü 30. haftada Series A çıtasını karşılıyor, imzaların %75'i U = 100. Düzelten kollarda ortalama memnuniyet 92-96 (kayıtta 62-63); yenilemede eşiğin 53-72 puan üstü. Tutum %100 "Zamma açık", kâğıt hiç gelmez. Bantlar yeniden ayarlanmalı (§2.10).
5. **Kayıp (M3, M4: GEÇTİ; M5: KALDI).** Düzelten kollarda kayıp 0 (kayıtta %3,7-6,8). Hiç düzeltmeyen kolda geç kayıp %1,4 ve %6,9 (hedef en az %10): hata terimi tavanı 60, U = 100 iken memnuniyet 40, eşik 30-38. Öneri: tavan 64 (%35 ve %59); M3 ve M4 değişmez (§5.1).
6. **Söz ve güncelleme (M6, M8: GEÇTİ).** Tutulmayan söz 13 haftada siliniyor (temsilcide 10); eşiğe 8 puan yakın hesap Risk'e giriyor, 20 uzak girmiyor; tutulan söz +6 kalıcı. Yaş terimi 26 / 52 / 104 haftada 0 / -6 / -12.
7. **Sunucu (M12: GEÇTİ).** Standart, 26-104. haftada gelirin %9,1'i (B2B) ve %9,8'i (B2C); Ekonomik yarısı, Kurumsal iki katı.
8. **Gider (M11: KALDI).** Araç ve servis kalkınca B2B'de en derin açık -41K'dan -13K'ya, 52. hafta net +9K'dan +143K'ya, evre 3 aylık net +27K'dan +89K'ya çıkıyor (tahmin). Bootstrap runway 6,7 ay, aynı. Maaş ×1,5 yetmiyor; dört koşul ancak ×2,2'de tutuyor. Servisin gerçek karşılığı müşteri temsilcisi maaşı: 38 temsilci, ayda yaklaşık $71K (tahmin).
9. **Kesinti ve bütçe (M7, M9: KALDI).** Kademe çarpanı tavandan önce uygulandığı için 9 hücrenin 3'ünde Ekonomik ile Standart yaklaşıyor; çarpanı tavandan sonra uygulamak 9 hücrenin 9'unu tutturuyor. Bakımlı üründe bütçe kesintisi yılda 5,8 olay ve hepsi küçülme: tam kayıp 0 (hedef %0,5-1,5).
10. **Kapılar:** 13'ten 8'i GEÇTİ (M1, M2, M3, M4, M6, M8, M10, M12), 4'ü KALDI (M5, M7, M9, M11), M13 karşılaştırma tablosu. Karar bekleyen beş nokta §5.5'te.

---

## 1. Kapı tablosu
Hedefler `C_ICERIK_v3.md` §7.4'ten. Her kapı tek tur; kalan kapıda model değişmedi, öneri §5'te ayrı koşu.

| Kapı | Senaryo ve hedef | Değer | Sonuç |
|---|---|---|---|
| M1 Nedensiz düşüş | tüm senaryolar; adlı olay olmayan haftada ≥1 puan düşüş = 0 | yeni: **0** (bot kolları 250 bin hesap-haftası, R9 12 hesap x 270 hafta, M2 2.256 hücre x 12 hafta, M6 12, M8 4). Eski kopya: bot 21 + M2 149 + M6 18. K5 gerçek: 1.450 (dar) / 337 (geniş) | **GEÇTİ** |
| M2 İlk 12 hafta | ürün ve hata sabit; imza değerinin altına inmez, imza ≥ eşik + 10 | yeni: 2.197 imza, altına inen 0, imzada en küçük (memnuniyet - eşik) 10; kapı reddi 59 / 2.256. Eski: 105 / 2.256 iniyor | **GEÇTİ** |
| M3 Hatasını düzelten | `fix_due` geç kayıp ≤ `fix_off` + 2 puan | due %0,0 / %0,0 ≤ off %0,0 + 2 (tohum 7 / 11) | **GEÇTİ** |
| M4 En kötüsünü düzelten | `fix_worst` geç ≤ off + 3; toplam ≤ off + 10 | geç %0,0 / %0,0; toplam %0,0 / %0,0 (off %0,0 / %0,0) | **GEÇTİ** |
| M5 Hiç düzeltmeyen | `fix_none` geç kayıp ≥ %10 ve ≥ 2 x off | %1,4 / %6,9 (kapısız %1,1 / %7,6) | **KALDI** (§5.1) |
| M6 Söz | 20. hafta söz; eşiğe uzaklık 8 ve 20 | tutulmayan: uzaklık 8'de Risk, 20'de yok; iz 13 hafta, temsilcide 10 (%23 kısa); geç tutulan 8 / 6 (%25 kısa); tutulan +6 kalıcı | **GEÇTİ** |
| M7 Kesinti kademesi | 104 hf x 2.000 koşu; her basamakta ≥ %25 az; Kurumsal ≥ 4 olay; %95 yük ≥ 1,3 x %70 | 9 hücrenin 3'ünde basamak koşulu bozuk; Kurumsal ≥ 4 yalnız tavandaki hata satırında (4,98; az hata 2,72); yük oranı 1,33 | **KALDI** (§5.2) |
| M8 Güncellenmeyen ürün | 26: 0; 52: -6; tavan -12; 52 haftada kayıp 0; yenilemede ≥ 2 basamak iner | yaş terimi 0 / -6 / -12; kayıp 0; tutum: 30. hafta donmasında tetiklenmedi (ürün çıtayı hâlâ karşılıyor), 20. hafta donmasında 3 basamak iner | **GEÇTİ** (koşullu, §2.8) |
| M9 Bütçe kesintisi | 330 hesap, 3 yıl; tam kayıp yılda %0,5-1,5; olayların ≥ yarısı küçülme | bakımlı havuz: 5,75 olay / yıl, tam kayıp 0 (%0,00), küçülme %100. Bakımsız havuz: %1,73 ve küçülme %1 | **KALDI** (alt sınır, §5.3) |
| M10 İmza kapısı | MVP sonrası 26 hafta, `fix_worst`; imza ≥ bugünün %80'i | %86,4 (146 / 169); kapının reddettiği %13,6 | **GEÇTİ** |
| M11 Gider ve runway | B2B ve B2C `fix_worst`; Bootstrap runway 6,7; B2B açık ≥ 25K ve hf > 30; 52. hf ≤ 80K; evre 3 ≤ 2 x bugün | runway 6,7 ay (10.000 / 1.500). A: açık -13K (hf 19) / -12K (hf 23); 52. hf +143K / +188K; evre 3 +89K / +119K (sınır 55K / 89K). B2C koşulları tutuyor | **KALDI** (§5.4) |
| M12 Fatura | Standart 26-104. hf B2B gelirin %8-12'si; Ekonomik ~yarı; Kurumsal ~iki kat | B2B Standart %9,1 / %9,0; Ekonomik %4,6 / %4,5; Kurumsal %18,2 / %17,9. B2C Standart %9,8 / %9,8 | **GEÇTİ** |
| M13 Eski-yeni karşılaştırma | aynı girdiler, iki model | §2.12 | bilgi |

---

## 2. Memnuniyet

### 2.1 Eski kod ne yapıyor (Erdem'in sorusu)
Kod gerçeği (ölçüm, dosya:satır):
- İmza değeri `max(eşik + 10, 50)` (`scripts/systems/sales_system.gd:367-368`, `b2b_constants.gd:19-20`). K5'te hesapların hepsi 50-52 ile açıldı.
- Hedef = gizli Kararlılık ekseni - min(0,3 x hesabın hatlarındaki açık hata, 20) + güven defteri (`b2b_sales_system.gd:140-152`, `b2b_constants.gd:58-59`).
- Kayma günde 3, tik 7 gün: tikte en çok **21 puan**; ilk 4 hafta çarpan 1,5 yukarı yuvarlanıp günde 5: tikte **35** (`b2b_sales_system.gd:87-118`, `b2b_constants.gd:30-31`).
  Fark ≤ 21 ise hesap **ertesi hafta** hedefine iniyor; 25 puanlık fark 2 hafta; 39 puanlık fark 2 hafta (21 + 18).
- İlk 4 hafta hedef en az eşik + 2 (`b2b_sales_system.gd:150-151`). Taban kalkınca hesap gizli hedefe iner: imza 50, 1. hafta 35 (taban), 4. hafta 24 (K5, `co_lead_8_1`).

K5 kaydından ölçüm (8 koşu, 2.769 hesap, `PROBE CUST`):

| Kol | hesap | imza → 1. hafta ortalama değişim | 1. haftada ≥5 düşen | 1. haftada ≥15 düşen | 1. haftada ≥5 yükselen | imza → 4. hafta ortalama değişim | 4. haftada ≥15 düşen |
|---|---|---|---|---|---|---|---|
| hiç düzeltmeyen (none) | 695 | -7,4 | 87% | 7% | 0% | -9,3 | 18% |
| en kötüsünü düzelten (worst) | 692 | +5,8 | 20% | 3% | 69% | +5,5 | 7% |
| vadesi gelen düzelten (due) | 693 | +6,9 | 18% | 3% | 71% | +6,7 | 6% |
| hata bedeli kapalı (off) | 689 | +7,6 | 18% | 3% | 71% | +7,7 | 6% |

Eski mekanizmanın Python kopyası kayıtla sınandı: kayıttaki hedef, güven ve eşikle `sat[d+1] = sat[d] + clamp(hedef - sat[d], ±21 ya da ±35)` hesabı yeniden koşuldu.

| Kol | tutan geçiş / toplam | oran |
|---|---|---|
| hiç düzeltmeyen (none) | 21982 / 22936 | 95,8% |
| en kötüsünü düzelten (worst) | 18401 / 28599 | 64,3% |
| vadesi gelen düzelten (due) | 18131 / 29493 | 61,5% |
| hata bedeli kapalı (off) | 29524 / 29809 | 99,0% |

`none` ve `off` kollarında kopya %96-99 tutuyor. `worst` ve `due`'da %61-64: bu kollarda `request_feature` kartı koşu başına yaklaşık 100 kez ateşleniyor ve `satisfaction_delta`'sı ile müşteri temsilcisinin yavaşlatması kopyada yok (§6). Kayma ve risk makinesi kopyada kayıtla aynı; fark kart ve temsilci katkısı.

### 2.2 Zaman serisi (S1)
Hesabın imzadan sonraki haftaya göre memnuniyeti: ortalama, parantezde p10. İki tohum birleşik; yeni model imza kapısı açık (kapıdan dönenler yok).
"Eski mekanizma, aynı U" kolunda gizli eksen yerine yeni modelin U'su kullanıldı (kontrollü karşılaştırma, `C_ICERIK_v3.md` §7.1 madde 8); eski eşik (33 / 42 / 51), eski kayma, eski taban.

| Kol | Model | hafta 0 | hafta 1 | hafta 4 | hafta 8 | hafta 12 | hafta 26 | hafta 52 |
|---|---|---|---|---|---|---|---|---|
| hiç düzeltmeyen (none) | K5 gerçek (eski kod, gizli eksen) | 52 (50) | 44 (40) | 42 (35) | 43 (40) | 44 (42) | 45 (43) | 46 (43) |
|  | Eski mekanizma, aynı U | 52 (50) | 77 (63) | 78 (67) | 79 (76) | 80 (77) | 80 (77) | 80 (78) |
|  | Yeni (imza kapısı açık) | 50 (40) | 48 (40) | 46 (37) | 44 (36) | 43 (35) | 39 (35) | 45 (42) |
| en kötüsünü düzelten (worst) | K5 gerçek (eski kod, gizli eksen) | 52 (50) | 58 (44) | 57 (40) | 60 (52) | 61 (53) | 63 (62) | 64 (62) |
|  | Eski mekanizma, aynı U | 52 (50) | 83 (64) | 93 (71) | 95 (90) | 97 (94) | 98 (95) | 97 (95) |
|  | Yeni (imza kapısı açık) | 91 (65) | 90 (68) | 91 (75) | 91 (87) | 92 (87) | 93 (90) | 91 (88) |
| vadesi gelen düzelten (due) | K5 gerçek (eski kod, gizli eksen) | 52 (50) | 58 (44) | 58 (42) | 60 (53) | 61 (53) | 63 (62) | 64 (62) |
|  | Eski mekanizma, aynı U | 52 (50) | 82 (63) | 93 (64) | 95 (88) | 97 (94) | 98 (96) | 98 (96) |
|  | Yeni (imza kapısı açık) | 91 (61) | 91 (63) | 91 (74) | 92 (89) | 93 (91) | 94 (92) | 92 (90) |
| hata bedeli kapalı (off) | K5 gerçek (eski kod, gizli eksen) | 51 (50) | 59 (44) | 59 (42) | 61 (54) | 62 (54) | 64 (63) | 65 (63) |
|  | Eski mekanizma, aynı U | 51 (50) | 83 (68) | 95 (74) | 97 (94) | 99 (96) | 99 (97) | 100 (98) |
|  | Yeni (imza kapısı açık) | 94 (68) | 94 (70) | 95 (75) | 96 (94) | 97 (94) | 97 (95) | 95 (93) |

Okuma:
- **K5 gerçek** satırı Erdem'in gördüğü şey: imza 52, 1. haftada düşüş, hedefe oturma (hiç düzeltmeyen kolda 44 → 42 → 46; düzelten kolda 58 → 64).
- **Eski mekanizma, aynı U**: hedef U olunca (botun ürünü 100'e doyuyor) kayma yukarı yürüyor: 52 → 83 → 93 → 97. Bu satır mekanizmanın hızını gösteriyor, eski modelin bugünkü seviyesini değil.
- **Yeni**: imza değeri hesabın gerçek değeri; sonra yalnız adlı satırlarla oynuyor. Hiç düzeltmeyen kolda yavaş iniş (50 → 48 → 46 → 44 → 43 → 39) her hafta "açık hata" satırının büyümesinden geliyor; 52. haftadaki 45 örneklem değişimi (o yaştaki hesaplar erken imzalayanlar, hata az iken imzalayanlar).
- Düzelten kollarda yeni modelde imzada ortalama 91-94: bot ürününün U'sundan; bu sayı §0 madde 4'ün konusu.

### 2.3 Kayıp ve yenilememe (S2)
Kayıp tanımı A'nın tanımı (`a_calisma/fix_tables.py:10,26`): erken = v1.0'dan sonraki ilk 20 hafta (hafta 7-27), geç = sonrası; yüzde = kayıp / (kayıp + dönem sonunda ayakta). Parantezde tohum 7 / tohum 11.
K5 gerçek satırları A'nın `K5_OLCUM.md` tablosuyla birebir aynı (ör. none, tohum 7: 26 ve %44,07; 36 ve %11,04).

| Kol | Model | Erken kayıp (adet, %) | Geç kayıp (adet, %) | Toplam % | Yenileme kararı | Yenilememe % | Bütçe kesintisi olayı | İmza kapısı reddi |
|---|---|---|---|---|---|---|---|---|
| hiç düzeltmeyen (none) | K5 gerçek (eski kod, gizli eksen) | 48 (44,1 / 37,9) | 93 (11,0 / 17,3) | 17,6 / 22,5 | - | - | - | - |
|  | Eski mekanizma, aynı U | 0 (0,0 / 0,0) | 0 (0,0 / 0,0) | 0,0 / 0,0 | 381 | 0,0 | 4 | - |
|  | Yeni (imza kapısı açık) | 0 (0,0 / 0,0) | 18 (1,4 / 6,9) | 1,4 / 6,9 | 268 | 1,5 | 4 | 270 / 707 |
| en kötüsünü düzelten (worst) | K5 gerçek (eski kod, gizli eksen) | 39 (27,1 / 39,7) | 1 (0,0 / 0,3) | 4,6 / 6,8 | - | - | - | - |
|  | Eski mekanizma, aynı U | 0 (0,0 / 0,0) | 0 (0,0 / 0,0) | 0,0 / 0,0 | 370 | 0,0 | 7 | - |
|  | Yeni (imza kapısı açık) | 0 (0,0 / 0,0) | 0 (0,0 / 0,0) | 0,0 / 0,0 | 347 | 0,0 | 7 | 23 / 705 |
| vadesi gelen düzelten (due) | K5 gerçek (eski kod, gizli eksen) | 28 (22,0 / 25,9) | 1 (0,0 / 0,3) | 3,7 / 4,5 | - | - | - | - |
|  | Eski mekanizma, aynı U | 0 (0,0 / 0,0) | 0 (0,0 / 0,0) | 0,0 / 0,0 | 367 | 0,0 | 8 | - |
|  | Yeni (imza kapısı açık) | 0 (0,0 / 0,0) | 0 (0,0 / 0,0) | 0,0 / 0,0 | 346 | 0,0 | 8 | 21 / 701 |
| hata bedeli kapalı (off) | K5 gerçek (eski kod, gizli eksen) | 25 (19,0 / 23,3) | 3 (0,6 / 0,3) | 3,8 / 4,3 | - | - | - | - |
|  | Eski mekanizma, aynı U | 0 (0,0 / 0,0) | 0 (0,0 / 0,0) | 0,0 / 0,0 | 376 | 0,0 | 7 | - |
|  | Yeni (imza kapısı açık) | 0 (0,0 / 0,0) | 0 (0,0 / 0,0) | 0,0 / 0,0 | 371 | 0,0 | 7 | 5 / 699 |

Okuma:
- Düzelten kollarda (worst, due, off) yeni modelde kayıp **0**; eski kayıt erken dönemde %19-40 kaybediyordu. O kayıp, hesabın imzadan sonra gizli hedefe inip eşiğin altına düşmesinden geliyordu. Yeni modelde hesap ya imzalamıyor (kapı) ya da kalıyor. Kapı kapalı koşuda aynı hesaplar imzalıyor ve `worst` tohum 7'de 4 erken kayıp veriyor (%6,8), diğer düzelten kollarda 0.
- Yenileme kararı: eski modelde yenileme akışı yok; "eski, aynı U" ve "yeni" satırları aynı C5 akışını (satışçı raporunun 1. seçeneği) koşuyor. Bütçe kesintisi olayı 4-8; `worst/due/off`'ta hepsi küçülme, `none`'da hepsi ayrılma (§2.11).
- `none` kolu yeni modelde %1,4 / %6,9 geç kayıp veriyor, "eski, aynı U"da 0: eski hata cezası en çok 20 idi, yeni 60.
- **Yenilememe oranı:** düzelten kollarda %0 (gerçek B2B yıllık kaybı %2-14, `C_ICERIK_v2.md` §2.6.1; ürün dışı pay yalnız bütçe kesintisi), `none`'da %1,5.

### 2.4 Nedensiz düşüş (M1)
Tanım (`C_ICERIK_v3.md` §7.1): düşüş = hesabın memnuniyeti bir önceki haftadan en az 1 puan düşük; **adlı olay** = o hafta sürüm (seviye değişimi), hata sayısı değişimi, kesinti, söz sonucu, istek teslimi, yenileme dönemi açılışı, güncelleme yaşı adımı, durum terimi değişimi.
Yeni modelde "o hafta değişen girdi" = ürün uyumu, hata terimi, bir defter satırı, durum terimi ya da yaş terimi. Eski kopyada = ürün uyumu, hesabın hata cezası, kesinti, söz ya da istek. K5 gerçek seride iki okuma: **dar** (hesabın kendi açık hata sayısı o gün değişti, söz sonuçlandı, istek teslim edildi) ve **geniş** (+ o gün herhangi bir sürüm çıktı).

| Kol | K5 gerçek: düşüş haftası | K5 gerçek: nedensiz (dar) | K5 gerçek: nedensiz (geniş) | Eski, aynı U: nedensiz | Yeni: nedensiz | Yeni: düşüş haftası (hepsi adlı) |
|---|---|---|---|---|---|---|
| hiç düzeltmeyen (none) | 1990 | 117 | 95 | 2 | 0 | 5735 |
| en kötüsünü düzelten (worst) | 5979 | 337 | 34 | 2 | 0 | 6052 |
| vadesi gelen düzelten (due) | 5708 | 508 | 71 | 4 | 0 | 8020 |
| hata bedeli kapalı (off) | 498 | 488 | 137 | 13 | 0 | 4310 |

Okuma:
- Yeni: 0. Düşüş haftaları var (haftada 1-2 puan, hata sayısı artarken) ama hepsinin yanında adı yazan bir girdi değişimi var. Bu sonuç yapı gereği: model hedef ve kayma taşımıyor. Sınanan şey, uygulamanın gizli bir kayma eklememesi; ölçek (1-330 hesap, 4 kol, iki tohum) ve uç durumlar bunu bozmuyor.
- K5 gerçek: düşüş haftalarının %10'u dar tanımda, %2,4'ü geniş tanımda adsız. `off` kolunda (hata bedeli kapalı) düşüşlerin neredeyse tamamı adsız (498 düşüşün 488'i): orada düşüşü tek başına gizli hedefin oynaması yapıyor.
- "Eski, aynı U" kolunda 21 adsız düşüş (4 kol toplamı): hedef yüksek olduğu için kayma yukarı yönde; adsızların 16'sı imzadan 1 hafta sonra (imza 50'den hedefe iniş), 5'i 4. haftada (taban kalkışı).

### 2.5 R9 oyuncu şekilleri, tek hesap (S4)
R9'un A / B / C / D şekilleri dört alana taşındı: A = botun gerçek yayın takvimi (`fix_worst`, tohum 7), B = takvim 20. haftada durur ve ürün dokunulmaz, C = A'nın takvimi, açık hata yoğunluğu hat başına 0,4'ten 3'e, D = 40'ta durur, 120'de A'nın 40. haftasından devam eder.
Olaylar R9'daki gibi: kesinti hf 40, 90, 150 (10 saat → -6), bozulan söz hf 50 (-12). İmza hf 10, 2★, sektör lojistik, 270 hafta, yenileme açık, kurucu sahip. Yeni eşik 33, eski eşik 42.

| Oyuncu | Model | hf 1 | hf 4 | hf 12 | hf 26 | hf 52 | hf 104 | hf 208 | ayrılma | nedensiz | en büyük düşüş |
|---|---|---|---|---|---|---|---|---|---|---|---|
| A düzenli | eski | 71 | 71 | 84 | 99 | 99 | 99 | 99 | - | 0 | -12 |
| A düzenli | yeni | 71 | 71 | 83 | 99 | 96 | 97 | 97 | - | 0 | -12 |
| B donmuş (20. haftada durur) | eski | 72 | 72 | 77 | 77 | 59 | - | - | hf 114 (yenilemedi) | 0 | -17 |
| B donmuş (20. haftada durur) | yeni | 72 | 72 | 77 | 77 | 54 | - | - | hf 114 (yenilemedi) | 0 | -17 |
| C hızlı ama özensiz | eski | 71 | 71 | 83 | 98 | 96 | 96 | 96 | - | 0 | -12 |
| C hızlı ama özensiz | yeni | 71 | 70 | 81 | 95 | 88 | 89 | 89 | - | 0 | -12 |
| D durgun (40'ta durur, 120'de döner) | eski | 71 | 71 | 84 | 99 | 99 | 93 | 99 | - | 0 | -12 |
| D durgun (40'ta durur, 120'de döner) | yeni | 71 | 71 | 83 | 99 | 96 | 78 | 97 | - | 0 | -12 |

| Oyuncu | Model | 1★ ayrılma | 2★ ayrılma | 3★ ayrılma |
|---|---|---|---|---|
| A düzenli | eski | - | - | - |
| A düzenli | yeni | - | - | - |
| B donmuş (20. haftada durur) | eski | - | hf 114 | hf 114 |
| B donmuş (20. haftada durur) | yeni | hf 114 | hf 114 | hf 114 |
| C hızlı ama özensiz | eski | - | - | - |
| C hızlı ama özensiz | yeni | - | - | - |
| D durgun (40'ta durur, 120'de döner) | eski | - | - | - |
| D durgun (40'ta durur, 120'de döner) | yeni | - | - | - |

Okuma:
- A: yeni modelde fark yenilemedeki "Zam -2" durum terimi (hf 52'de 96, eskide 99). C: açık hata satırı (3'e çıkan yoğunluk) hesabı 88-95'te tutuyor.
- D: 40-120 arası 80 hafta sessizlik; 104. haftada yaş terimi -12, "Zam -2" ve Series A çıtası okuması (U 100 → 93): 78. 120'de sürüm gelince yaş terimi siliniyor, 208. haftada 97.
- B donmuş: 54. haftada yenileme dönemi açılınca Traction çıtası okunuyor (ürün Çekirdek 0,6'da kalmış): ürün uyumu 77 → 60, memnuniyet 65 → 49 (adlı olay: yenileme dönemi açılışı). 106. haftada Series A çıtası (Çekirdek 1,5) okunuyor, hesap "Yenilemeyecek" çıkıp 114. haftada ayrılıyor. R9 gözlem 1 ("donmuş ürünün kaderini aile belirlemiyor, çıta belirliyor") bu modelde de tutuyor.
- Bot ürünü güçlü olduğu için eşik altı hafta yok; kaybedilen tek hesap B'dir. R9'un zayıf ürün satırları (C: 52-72) burada görülmüyor.

### 2.6 M2 İlk 12 hafta (ürün ve hata sabit)
Her imza haftası (7-100) için dünya o haftada donduruldu (alan seviyeleri, açık hata, beklenti sabit; olay yok), 1 / 2 / 3★ ve dört sektör (lojistik, inşaat, finans, teknoloji), `fix_worst` iki tohum. "Kapı reddi" yeni modelde adayın imzalamaması.

| Model | imza haftası | aday | kapı reddi | imzalayan | imza değerinin altına inen | 12. haftada ort. değişim | en düşük nokta - imza (ort.) | imzada en küçük (memnuniyet - eşik) |
|---|---|---|---|---|---|---|---|---|
| eski | 7-20 | 336 | 0 | 336 | 83 | 6,3 | -2,4 | 10 |
| eski | 21-40 | 480 | 0 | 480 | 22 | 31,1 | -0,4 | 10 |
| eski | 41-100 | 1440 | 0 | 1440 | 0 | 42,9 | 0,0 | 10 |
| yeni | 7-20 | 336 | 46 | 290 | 0 | 0,0 | 0,0 | 10 |
| yeni | 21-40 | 480 | 13 | 467 | 0 | 0,0 | 0,0 | 10 |
| yeni | 41-100 | 1440 | 0 | 1440 | 0 | 0,0 | 0,0 | 53 |

Okuma:
- Yeni: imza değerinin altına inen 0; imzada en küçük fark 10 (kapı tam o sınırda tutuyor); sonra hiç oynamıyor (12. haftada değişim 0,0). 7-20. haftada adayların %13,7'si, 21-40'ta %2,7'si kapıdan dönüyor; 41'den sonra 0.
- Eski: erken haftalarda imza edenlerin %25'i (336'dan 83'ü) imza değerinin altına iniyor; 21-40'ta %4,6. 41'den sonra hedef yüksek olduğu için hesap yukarı yürüyor (12. haftada +43): imza değeri hesabın gerçek değeriyle ilgisiz.

### 2.7 M6 Söz
Tek hesap, 2★, lojistik, dünya sabit (22. hafta, U 60'lar: +6 tavana çarpmasın), kesinti yok. Söz 20. haftada sonuçlanıyor (imzadan 20 hafta sonra). Eşiğe uzaklık 8 ve 20 puan: eşik, söz öncesi değerden bu kadar aşağı ayarlandı. Tutma kartı oynanmıyor (iki modelde de). Temsilci = Müşteri İlişkileri çıktısı 5 (`cs_dampen` 0,725).

| Model | hesap sahibi | söz | eşiğe uzaklık | memnuniyet hf 19 | hf 30 | en düşük nokta | Risk | sonuç | iz kaç haftada silindi | hf 80 |
|---|---|---|---|---|---|---|---|---|---|---|
| eski | kurucu | tutulmadı | 8 | 54 | 42 | 42 | Risk | ayrıldı (hf 32) | - | - |
| eski | kurucu | tutulmadı | 20 | 54 | 42 | 42 | - | - | 4 | 54 |
| eski | kurucu | geç tutuldu | 8 | 54 | 52 | 52 | - | - | 1 | 54 |
| eski | kurucu | geç tutuldu | 20 | 54 | 52 | 52 | - | - | 1 | 54 |
| eski | kurucu | tutuldu | 8 | 54 | 60 | 54 | - | - | 1 | 54 |
| eski | kurucu | tutuldu | 20 | 54 | 60 | 54 | - | - | 1 | 54 |
| eski | temsilci | tutulmadı | 8 | 54 | 42 | 42 | Risk | ayrıldı (hf 32) | - | - |
| eski | temsilci | tutulmadı | 20 | 54 | 42 | 42 | - | - | 4 | 54 |
| eski | temsilci | geç tutuldu | 8 | 54 | 52 | 52 | - | - | 1 | 54 |
| eski | temsilci | geç tutuldu | 20 | 54 | 52 | 52 | - | - | 1 | 54 |
| eski | temsilci | tutuldu | 8 | 54 | 60 | 54 | - | - | 1 | 54 |
| eski | temsilci | tutuldu | 20 | 54 | 60 | 54 | - | - | 1 | 54 |
| yeni | kurucu | tutulmadı | 8 | 46 | 34 | 34 | Risk | ayrıldı (hf 32) | 2 | - |
| yeni | kurucu | tutulmadı | 20 | 46 | 34 | 34 | - | - | 13 | 46 |
| yeni | kurucu | geç tutuldu | 8 | 46 | 43 | 43 | - | - | 8 | 46 |
| yeni | kurucu | geç tutuldu | 20 | 46 | 43 | 43 | - | - | 8 | 46 |
| yeni | kurucu | tutuldu | 8 | 46 | 52 | 52 | - | - | 1 | 52 |
| yeni | kurucu | tutuldu | 20 | 46 | 52 | 52 | - | - | 1 | 52 |
| yeni | temsilci | tutulmadı | 8 | 46 | 34 | 34 | Risk | ayrıldı (hf 32) | 2 | - |
| yeni | temsilci | tutulmadı | 20 | 46 | 34 | 34 | - | - | 10 | 46 |
| yeni | temsilci | geç tutuldu | 8 | 46 | 43 | 43 | - | - | 6 | 46 |
| yeni | temsilci | geç tutuldu | 20 | 46 | 43 | 43 | - | - | 6 | 46 |
| yeni | temsilci | tutuldu | 8 | 46 | 52 | 52 | - | - | 1 | 52 |
| yeni | temsilci | tutuldu | 20 | 46 | 52 | 52 | - | - | 1 | 52 |

Okuma (yeni):
- **Tutulmayan** (-12, 13 hafta, eşik +5 çırçırı `b2b_constants.gd:149`): uzaklık 8'de hesap Risk'e giriyor ve tutma kartı olmayınca 2 hafta sonra ayrılıyor (hf 32); uzaklık 20'de girmiyor. İz kurucuda 13 haftada, temsilcide 10 haftada siliniyor (%23 kısa). Geç tutulan için 8 ve 6 hafta (%25 kısa).
- **Tutulan:** +6 kalıcı (46 → 52, 80. haftada hâlâ 52), eşik -5.
- Eski: aynı yerde Risk (uzaklık 8), uzaklık 20'de yok; iz 4 hafta; tutulan sözün memnuniyete etkisi 1 hafta.

### 2.8 M8 Güncellenmeyen ürün
Hesap hf 12'de imzalıyor; ürün 30. (bot takvimi, spec) ya da 20. haftada (varyant) donuyor ve hiçbir alana dokunulmuyor; açık hata sabit 3; yenileme açık.

| donma haftası | hesap | yaş terimi (donmadan 26 / 52 / 104 hafta sonra) | memnuniyet (26 / 52. hafta) | ayrılma | yenileme tutumu: donmuş ürün (etkin ürün) |
|---|---|---|---|---|---|
| 30 | 1★ | 0 / 6 / 12 | 99 / 91 | - | hf 56: Zamma açık (etkin Zamma açık); hf 108: Zamma açık (etkin Zamma açık); hf 160: Zamma açık (etkin Zamma açık) |
| 30 | 3★ | 0 / 6 / 12 | 99 / 91 | - | hf 56: Zamma açık (etkin Zamma açık); hf 108: Zamma açık (etkin Zamma açık); hf 160: Zamma açık (etkin Zamma açık) |
| 20 | 1★ | 0 / 6 / 12 | 71 / 50 | - | hf 56: Zamma açık (etkin Zamma açık); hf 108: Ayrılmayı düşünüyor (etkin Zamma açık); hf 160: Ayrılmayı düşünüyor (etkin Zamma açık) |
| 20 | 3★ | 0 / 6 / - | 71 / 52 | hf 116 | hf 56: Aynı fiyat (etkin Zamma açık); hf 108: Yenilemeyecek (etkin Zamma açık) |

Okuma:
- Yaş terimi donmadan 26 / 52 / 104 hafta sonra **0 / -6 / -12**: spec'e birebir. Donmadan 52 hafta sonra hesap kaybı 0 (eşik ≤ 38).
- **30. haftada donan** bot ürünü Series A çıtasını (Çekirdek 1,5 / öteki 1) hâlâ karşılıyor (Çekirdek 1,5, Onboarding 1, Entegrasyonlar 3, Güven 2). Bu yüzden "beklenti yükseldiyse" koşulu fiilen tetiklenmiyor ve tutum değişmiyor (Zamma açık). Bedeli yaş terimi ödüyor: 99 → 91.
- **20. haftada donan** ürün (Çekirdek 0,6) yükselen çıtanın gerisinde kalıyor: 108. haftadaki yenilemede tutum "Zamma açık"tan "Ayrılmayı düşünüyor"a (3 basamak) iniyor; 3★ hesap "Yenilemeyecek" çıkıp 116. haftada ayrılıyor.
- M8'in iki ayağı da tutuyor; yenileme ayağı için gereken koşul (ürünün çıtanın gerisinde kalması) spec senaryosunda oluşmadığı için ikinci senaryo eklendi (yorum 15).

### 2.9 M10 İmza kapısı
Bot kayıtlarındaki imzaların her biri için, imza anındaki yeni model değeri (U - açık hata) eşik + 10'a karşı: altındaysa aday imzalamıyor. Pencere MVP sonrası 26 hafta (hf 7-33). "Bugünün imza sayısı" = kayıtta imzalayanların hepsi.

| Kol | MVP sonrası 26 haftada (hf 7-33) imza | kapıdan dönen | geçen pay |
|---|---|---|---|
| hiç düzeltmeyen (none) | 171 | 41 | 76,0% |
| en kötüsünü düzelten (worst) | 169 | 23 | 86,4% |
| vadesi gelen düzelten (due) | 170 | 21 | 87,6% |
| hata bedeli kapalı (off) | 170 | 5 | 97,1% |

Okuma: `fix_worst` %86,4 geçiriyor (≥ %80: GEÇTİ). Dönenler hafta 16-20 imzaları: ürünün Çekirdek'i 0,6'da, açık hata 9'dan 29'a çıkarken. `none` kolu %76: kapı hatayı pahalı yapıyor. Sınır: dönen aday sonradan (ürün iyileşince) imzalayabilir; bu pay üst sınırdır. Kapının gelir etkisi §4.5'te.

Bot ürününün imza anındaki U'su (kapısız, `worst`): evre 2'de 377 imza, p10 = 60, ortanca = 100; evre 3'te 323 imza, p10 = 96. İmzaların %75'i U = 100.

### 2.10 Ek bulgu: yenileme tutumu dağılımı
Yenileme dönemi açılırken (imzadan 44 hafta sonra) tutum = memnuniyet - eşik + ikna; ikna = (Satış yıldızı - 1) x 2 = +2 (2★ satışçı varsayımı). Bantlar `C_ICERIK_v2.md` §2.6.1: ≥ 25 Zamma açık, 12-24 Aynı fiyat, 5-11 İndirim ister, 0-4 Ayrılmayı düşünüyor, < 0 Yenilemeyecek.

| Kol | yenileme kararı | fark (memnuniyet - eşik + ikna) p10 / ortanca / p90 | en küçük - en büyük | tutum: Zamma açık / Aynı / İndirim ister / Ayrılmayı düşünüyor / Yenilemeyecek |
|---|---|---|---|---|
| hiç düzeltmeyen (none) | 268 | 4 / 8 / 11 | 2 - 15 | 0% / 6% / 84% / 10% / 0% |
| en kötüsünü düzelten (worst) | 347 | 59 / 63 / 67 | 53 - 72 | 100% / 0% / 0% / 0% / 0% |
| vadesi gelen düzelten (due) | 346 | 60 / 64 / 68 | 55 - 72 | 100% / 0% / 0% / 0% / 0% |
| hata bedeli kapalı (off) | 371 | 63 / 67 / 71 | 58 - 72 | 100% / 0% / 0% / 0% / 0% |

Okuma: bakımlı üründe fark 53-72; bant 25'te başlıyor. Her yenileme +%8 zamla bitiyor (bot 1. seçeneği seçiyor) ve kâğıt hiç gelmiyor (`C_ICERIK_v2.md` §2.6.5: yalnız "indirim ister" ya da daha kötü varsa kâğıt gelir). `none`'da farkın ortancası 8: tutum çoğunlukla "İndirim ister" (%84): gelirin %10'u gidiyor, hesap gitmiyor. **Bu bir kapı değil, bir tasarım bulgusu:** yenilemenin anlamlı olması için ya bantlar yukarı kayar (ör. Zamma açık ≥ 45) ya da U'nun doyumu azaltılır. Pazar çıtasını iki katına çıkaran bilgi koşusunda ortalama memnuniyet 75'e iniyor, ama tutum hâlâ %97 "Zamma açık" (aşağıdaki tablo): çıtayı oynatmak yetmiyor, bantlar oynamalı. Bantlar [ÇALIŞMA]; Erdem kararı.

Pazar çıtası ölçeği, bilgi koşusu (çıta ×1,0 bugünkü öneri; ×1,5 ve ×2,0 Traction ve Series A beklentilerinin çarpımı):

| Traction ve Series A çıtası | worst: ort. memnuniyet | worst: yenileme tutumu (Zamma açık / Aynı / İndirim ister / Ayrılmayı düşünüyor / Yenilemeyecek) | worst: kapı reddi / imza | worst: toplam kayıp % (tohum 7 / 11) | none: geç kayıp % (tohum 7 / 11) |
|---|---|---|---|---|---|
| x1,0 | 91,9 | 100% / 0% / 0% / 0% / 0% | 23 / 705 | 0,0 / 0,0 | 1,4 / 6,9 |
| x1,5 | 86,7 | 100% / 0% / 0% / 0% / 0% | 56 / 705 | 0,0 / 0,0 | 2,8 / 32,9 |
| x2,0 | 75,5 | 97% / 3% / 0% / 0% / 0% | 93 / 705 | 0,0 / 0,0 | 85,7 / 43,8 |

### 2.11 M9 Bütçe kesintisi
Yenileme döneminde hesap başına bir kez, 1★ %2, 2★ %1,5, 3★ %1; memnun (memnuniyet ≥ eşik + 12) küçülür (koltuk ve MRR x0,5), değilse ayrılır (`C_ICERIK_v3.md` §4). 330 hesap, 3 yıl, 1.000 deneme; yıldız karışımı botun imza karışımı (%56 / %42 / %2). Hesapların kesinti anındaki "memnuniyet - eşik" farkı, yeni model bot kollarının gerçek yenileme kararlarından örneklendi.

| hesap havuzu | örneklem (yenileme kararı) | ort. (memnuniyet - eşik) | olay/yıl | tam kayıp/yıl | tam kayıp (hesapların %'si) | küçülme/yıl | olayın küçülmeyle kalan payı |
|---|---|---|---|---|---|---|---|
| bakımlı ürün (worst+due+off havuzu) | 1064 | 62,9 | 5,75 | 0,00 | 0,00% | 5,75 | 100% |
| bakımsız ürün (none) | 268 | 5,9 | 5,75 | 5,70 | 1,73% | 0,04 | 1% |

Okuma: bakımlı üründe ortalama pay 62,9 puan, eşik + 12'nin çok üstünde: kesintiler "küçülme" olarak kalıyor ve **tam kayıp 0**. Bu "müşteriler ayrılmasın zaten" tutumuyla uyumlu; ama kapının alt sınırı (%0,5) tutmuyor. Bakımsız üründe tersi (%1,73 tam kayıp, küçülme %1). Gerçek bir oyuncu bu iki ucun arasındadır. Maliyet MRR olarak: bakımlı üründe yılda 5,75 küçülme, her biri hesabın MRR'ının yarısı. Seçenekler §5.3.

### 2.12 M13 Eski modelle karşılaştırma
Aynı girdiler, iki model (bot kolları, iki tohum toplamı). "Kayıp" toplam kayıp hesap sayısı (erken + geç). Kart izi, `satisfaction_delta`'nın bir kartta bıraktığı puan-hafta (taban seriden fark toplamı, 60 hafta).

| Kol | kayıp: K5 gerçek | eski, aynı U | yeni (kapılı) | yeni (kapısız) | ort. memnuniyet: K5 gerçek | eski, aynı U | yeni (kapılı) | nedensiz düşüş: eski kopya / yeni |
|---|---|---|---|---|---|---|---|---|
| hiç düzeltmeyen (none) | 141 | 0 | 18 | 36 | 44,8 | 78,8 | 42,4 | 2 / 0 |
| en kötüsünü düzelten (worst) | 40 | 0 | 0 | 4 | 61,6 | 95,4 | 91,8 | 2 / 0 |
| vadesi gelen düzelten (due) | 29 | 0 | 0 | 0 | 62,4 | 95,9 | 93,0 | 4 / 0 |
| hata bedeli kapalı (off) | 28 | 0 | 0 | 0 | 63,3 | 97,5 | 96,0 | 13 / 0 |

M1 sayıları §2.4'te (yeni 0, eski kopya 21, K5 gerçek 1.450 / 337).

`satisfaction_delta` kartları (15 kart, 38 delta; sayılar `data/events/cards/{customer,product,rival}/` kartlarından):

| Model | olumsuz delta (adet) | ort. büyüklük | ort. iz (puan-hafta) | iz / büyüklük (hafta) | olumlu delta (adet) | ort. büyüklük | olumlu: iz / büyüklük (hafta, pencere 60) |
|---|---|---|---|---|---|---|---|
| eski | 22 | 7,4 | 7,8 | 1,1 | 16 | 5,8 | 1,0 |
| yeni | 22 | 7,4 | 35,8 | 4,9 | 16 | 5,8 | 60,0 |

Okuma: olumsuz kart bugün 1,1 hafta iz bırakıyor (bir tikte siliniyor); yeni modelde 4,9 hafta (8 haftada doğrusal söner: ortalama 4,5 x büyüklük). 15 kartın etkisi yaklaşık 4,5 kat büyüyor; B'nin ve içeriğin ayarı M13 ile ölçülmeli. Olumlu delta eski modelde 1 hafta, yeni modelde kalıcı satır (60 haftalık pencerenin tamamı) ve +10 tavanına sayılıyor (yorum 12). `request_feature` kartı K5 koşularında yaklaşık 100-111 kez ateşleniyor (`PROBE TALLY`); delta'ları -5 / +3 / -4.

---

## 3. Kesinti ve sunucu yükü (M7)
Kural `C_ICERIK_v3.md` §2.3 ve §2.6, B'nin formülü: p = 0,10 x kademe x yük çarpanı x (1 + min(açık hata, 12) / 8), en çok 0,30; iki olay arası ≥ 4 hafta; v1.0'dan sonra ilk 3 hafta yok (`incident_system.gd:48-70`, `sprint.json:42-43`). Kademe 1,0 / 0,5 / 0,25; yük çarpanı yük ≤ %90 → 1, %90-100 → 1,5, > %100 → 2,5. 2.000 koşu x 104 hafta; sayılar koşu başına ortalama kesinti.

| açık hata | yük | Ekonomik olay/104 hf | Standart | Kurumsal | Std/Eko | Kur/Std | her basamak ≥ %25 az |
|---|---|---|---|---|---|---|---|
| az hata (2) | %70 (x1,0) | 8,65 | 4,98 | 2,72 | 0,58 | 0,55 | evet |
| az hata (2) | %95 (x1,5) | 11,51 | 6,94 | 3,87 | 0,60 | 0,56 | evet |
| az hata (2) | %105 (x2,5) | 15,08 | 10,16 | 6,01 | 0,67 | 0,59 | evet |
| orta (6) | %70 (x1,0) | 11,01 | 6,57 | 3,64 | 0,60 | 0,56 | evet |
| orta (6) | %95 (x1,5) | 14,05 | 8,96 | 5,18 | 0,64 | 0,58 | evet |
| orta (6) | %105 (x2,5) | 15,08 | 12,66 | 7,85 | 0,84 | 0,62 | hayır |
| tavanda hata (12+) | %70 (x1,0) | 13,67 | 8,65 | 4,98 | 0,63 | 0,58 | evet |
| tavanda hata (12+) | %95 (x1,5) | 15,08 | 11,51 | 6,94 | 0,76 | 0,60 | hayır |
| tavanda hata (12+) | %105 (x2,5) | 15,08 | 15,08 | 10,16 | 1,00 | 0,67 | hayır |

Okuma:
- Yük %95'in %70'e oranı (Ekonomik, az hata) 1,33 (hedef ≥ 1,3): yük etkisi görünüyor.
- **Basamak koşulu 3 hücrede bozuk:** orta hata + %105 yük (Std / Eko 0,84), tavanda hata + %95 yük (0,76), tavanda hata + %105 yük (1,00: Ekonomik ile Standart aynı). Neden: p_max 0,30 tavanı. Bu üç hücrede Ekonomik'in ham olasılığı 0,44 / 0,38 / 0,63 ve 0,30'da kesiliyor; Standart'ınki 0,22 / 0,19 / 0,31 (sonuncuda o da kesiliyor). Kademe çarpanı **tavandan önce** uygulandığı için kesik Ekonomik, Standart'a yaklaşıyor ya da onunla eşitleniyor.
- Kurumsal ≥ 4 olay: tavandaki hata satırında %70 yükte 4,98; az hatada 2,72, orta hatada 3,64. Hedefin hangi hata satırı için olduğu belgede yazmıyor (yorum 14); her hücre okumasında tutmuyor, tavan satırı okumasında tutuyor.
- Kurumsal bile yük %100'ün üstünde ve açık hata tavanda iken 104 haftada 10 kesinti yaşıyor; Ekonomik %70 yükte ve az hatada 8,6. "Yükü %90'ın altında tut" mesajı oyuncuya görünür olur.

---

## 4. Ekonomi (M11, M12)
Yöntem (`C_ICERIK_v3.md` §7.2): K5 `PROBE MONTH_BURN` aylık dökümü üstüne muhasebe. Çıkarılan: araç (`finance_system.gd:13-14,136,219-222`) ve servis (`infra_system.gd:87-92,267-277`). Sunucu = kayıttaki birim sayısı x yeni birim fiyatı (B2B Standart $120 / 50 koltuk, B2C $250 / 1.000 kullanıcı; eski $45 ve $55: `infra_system.gd:26,28`). Eklenen: kurucu satırı $1.500 (eski `TOOLS_BASE_MONTHLY[1]` karşılığı, `finance_system.gd:13`) ve ofis kirası ($0 / $1.500 / $8.000 / $18.000, `C_ICERIK_v3.md` §3.4; taşınma koşulları `office_constants.gd:15-62`). Bot kararları sabit; bu bir **tahmin**, gerçek koşu uygulamadan sonra alınacak.

Bootstrap runway (tek kurucu): 10.000 / 1.500 = **6,7 ay**, eski ve yeni aynı. MVP'den sonra bir birim sunucuyla: B2B Standart'ta 10.000 / 1.620 = 6,2 ay (eski 6,5), B2C Standart'ta 10.000 / 1.750 = 5,7 ay (eski 6,4) (tahmin).

### 4.1 Nakit ve kâra geçiş
En derin kümülatif açık = aylık (gelir - gider) toplamının en düşük noktası (dış fonlama hariç). "Kâra geçiş" = ilk net ≥ 0 ay sonu, ve 3 ay üst üste net ≥ 0 olan ilk ay. "En düşük nakit" = kayıttaki nakit + (yeni - eski) kümülatif fark; Frank'in çeki ve tohum dahil (hiçbir varyantta eksiye düşmüyor).

| Pazar | tohum | Varyant | en derin kümülatif açık | 52. hf kümülatif net | 101. hf kümülatif net | ilk net>=0 ay sonu (hf) | 3 ay üst üste net>=0 (hf) | en düşük runway, ay (evre 1 / 2 / 3) | en düşük nakit (çek dahil) |
|---|---|---|---|---|---|---|---|---|---|
| B2B | 7 | Eski (kayıt) | -41K (hf 36) | +9K | +316K | 40 | 40 | 5,3 / 2,0 / 34,4 | +6K (hf 10) |
| B2B | 7 | A: araç ve servis yok, sunucu Standart, kurucu, kira | -13K (hf 19) | +143K | +1038K | 23 | 23 | 5,3 / 2,0 / açık yok | +6K (hf 10) |
| B2B | 7 | C (öneri): A ve maaş bantları x1,5 | -32K (hf 36) | +54K | +790K | 40 | 40 | 5,3 / 2,0 / açık yok | +6K (hf 10) |
| B2B | 7 | D (öneri): A ve maaş bantları x2 | -69K (hf 36) | -35K | +542K | 40 | 40 | 5,3 / 2,0 / açık yok | +6K (hf 10) |
| B2B | 11 | Eski (kayıt) | -37K (hf 36) | +43K | +534K | 40 | 40 | 2,4 / 9,8 / 6,8 | +6K (hf 10) |
| B2B | 11 | A: araç ve servis yok, sunucu Standart, kurucu, kira | -12K (hf 23) | +188K | +1491K | 19 | 27 | 2,3 / 18,3 / açık yok | +6K (hf 10) |
| B2B | 11 | C (öneri): A ve maaş bantları x1,5 | -30K (hf 32) | +99K | +1245K | 36 | 36 | 2,3 / 12,3 / açık yok | +6K (hf 10) |
| B2B | 11 | D (öneri): A ve maaş bantları x2 | -58K (hf 36) | +10K | +999K | 40 | 40 | 2,3 / 6,2 / açık yok | +6K (hf 10) |
| B2C | 7 | Eski (kayıt) | -11K (hf 49) | +2K | +1638K | 23 | 36 | 5,3 / 2,1 / açık yok | +4K (hf 19) |
| B2C | 7 | A: araç ve servis yok, sunucu Standart, kurucu, kira | -12K (hf 49) | +4K | +2032K | 36 | 36 | 5,3 / 2,0 / açık yok | +4K (hf 19) |
| B2C | 7 | C (öneri): A ve maaş bantları x1,5 | -23K (hf 49) | -11K | +1952K | 54 | 54 | 5,3 / 2,0 / açık yok | +4K (hf 19) |
| B2C | 7 | D (öneri): A ve maaş bantları x2 | -34K (hf 49) | -27K | +1871K | 54 | 54 | 5,3 / 2,0 / açık yok | +4K (hf 19) |
| B2C | 11 | Eski (kayıt) | -21K (hf 54) | -21K | +1468K | 23 | 36 | 5,5 / 2,5 / açık yok | +5K (hf 19) |
| B2C | 11 | A: araç ve servis yok, sunucu Standart, kurucu, kira | -21K (hf 54) | -21K | +1834K | 36 | 36 | 5,5 / 2,4 / açık yok | +5K (hf 19) |
| B2C | 11 | C (öneri): A ve maaş bantları x1,5 | -35K (hf 54) | -35K | +1756K | 58 | 58 | 5,5 / 2,4 / açık yok | +5K (hf 19) |
| B2C | 11 | D (öneri): A ve maaş bantları x2 | -50K (hf 54) | -50K | +1677K | 58 | 58 | 5,5 / 2,4 / açık yok | +5K (hf 19) |

### 4.2 Evre başına aylık burn, gelir, net (30 güne normalize)
Burn: tek seferlik hariç tekrarlayan gider.

B2B, tohum 7:

| Varyant | Evre 1 (burn / gelir / net, aylık) | Evre 2 | Evre 3 |
|---|---|---|---|
| Eski (kayıt) | 2K / 0K / -2K | 42K / 52K / +7K | 114K / 159K / +27K |
| A: araç ve servis yok, sunucu Standart, kurucu, kira | 2K / 0K / -2K | 26K / 52K / +22K | 53K / 159K / +89K |
| C (öneri): A ve maaş bantları x1,5 | 2K / 0K / -2K | 35K / 52K / +13K | 67K / 159K / +74K |
| D (öneri): A ve maaş bantları x2 | 2K / 0K / -2K | 45K / 52K / +4K | 82K / 159K / +60K |

B2B, tohum 11:

| Varyant | Evre 1 (burn / gelir / net, aylık) | Evre 2 | Evre 3 |
|---|---|---|---|
| Eski (kayıt) | 2K / 0K / -2K | 39K / 49K / +5K | 127K / 188K / +45K |
| A: araç ve servis yok, sunucu Standart, kurucu, kira | 2K / 0K / -2K | 25K / 49K / +19K | 53K / 188K / +119K |
| C (öneri): A ve maaş bantları x1,5 | 2K / 0K / -2K | 33K / 49K / +10K | 67K / 188K / +105K |
| D (öneri): A ve maaş bantları x2 | 2K / 0K / -2K | 42K / 49K / +1K | 81K / 188K / +90K |

B2C, tohum 7:

| Varyant | Evre 1 (burn / gelir / net, aylık) | Evre 2 | Evre 3 |
|---|---|---|---|
| Eski (kayıt) | 2K / 0K / -2K | 12K / 23K / +9K | 99K / 327K / +214K |
| A: araç ve servis yok, sunucu Standart, kurucu, kira | 2K / 0K / -2K | 10K / 23K / +11K | 47K / 327K / +266K |
| C (öneri): A ve maaş bantları x1,5 | 2K / 0K / -2K | 12K / 23K / +9K | 53K / 327K / +260K |
| D (öneri): A ve maaş bantları x2 | 2K / 0K / -2K | 15K / 23K / +6K | 59K / 327K / +254K |

B2C, tohum 11:

| Varyant | Evre 1 (burn / gelir / net, aylık) | Evre 2 | Evre 3 |
|---|---|---|---|
| Eski (kayıt) | 2K / 0K / -2K | 13K / 26K / +10K | 101K / 332K / +215K |
| A: araç ve servis yok, sunucu Standart, kurucu, kira | 2K / 0K / -2K | 10K / 26K / +13K | 48K / 332K / +268K |
| C (öneri): A ve maaş bantları x1,5 | 2K / 0K / -2K | 13K / 26K / +10K | 54K / 332K / +262K |
| D (öneri): A ve maaş bantları x2 | 2K / 0K / -2K | 16K / 26K / +8K | 60K / 332K / +256K |

### 4.3 Sunucunun gelire oranı (M12)

| Pazar | tohum | Kademe | MVP sonrası ilk ay | 15-25. hf | 26-104. hf | Evre 3 |
|---|---|---|---|---|---|---|
| B2B | 7 | eski | - | 2,5 | 3,4 | 3,4 |
| B2B | 7 | Ekonomik | - | 3,3 | 4,6 | 4,6 |
| B2B | 7 | Standart | - | 6,5 | 9,1 | 9,1 |
| B2B | 7 | Kurumsal | - | 13,1 | 18,2 | 18,2 |
| B2B | 11 | eski | - | 2,3 | 3,4 | 3,4 |
| B2B | 11 | Ekonomik | - | 3,1 | 4,5 | 4,5 |
| B2B | 11 | Standart | - | 6,2 | 9,0 | 9,0 |
| B2B | 11 | Kurumsal | - | 12,5 | 17,9 | 18,0 |
| B2C | 7 | eski | 40,0 | 3,5 | 2,1 | 2,2 |
| B2C | 7 | Ekonomik | 90,9 | 8,0 | 4,9 | 5,0 |
| B2C | 7 | Standart | 181,8 | 15,9 | 9,8 | 9,9 |
| B2C | 7 | Kurumsal | 363,6 | 31,8 | 19,5 | 19,8 |
| B2C | 11 | eski | 40,0 | 3,5 | 2,2 | 2,2 |
| B2C | 11 | Ekonomik | 90,9 | 7,9 | 4,9 | 5,0 |
| B2C | 11 | Standart | 181,8 | 15,8 | 9,8 | 10,0 |
| B2C | 11 | Kurumsal | 363,6 | 31,5 | 19,7 | 20,0 |

Okuma: Standart B2B'de 26-104. haftada %9,1 / %9,0 ve B2C'de %9,8: Erdem'in %8-15 bandı ve v3'ün %8-12 hedefi içinde (**M12 GEÇTİ**). Ekonomik yarısı (%4,6), Kurumsal iki katı (%18,2). Erken haftalarda oran yüksek: B2B 15-25. hafta %6,5 (gelir küçük), B2C MVP sonrası ilk ay %182 (tek birim $250, gelir $70-560; altyapı ilk müşteriden önce ödenir). Kapasite politikası kayıttaki eski otomatik büyümedir; oyuncu sunucuyu daha geniş tutarsa oran artar (§6).

### 4.4 Evre 3 kalem kalem (B2B, aylık ortalama)

| tohum | Kalem | Eski | A (yeni) |
|---|---|---|---|
| 7 | Gelir | 159K | 159K |
| 7 | Maaş ve ek mesai | 29K | 29K |
| 7 | Geçim ve araçlar (kalkar) | 11K | 0 |
| 7 | Servis maliyeti (kalkar) | 69K | 0 |
| 7 | Sunucular | 5K | 15K |
| 7 | Kurucu satırı + kira | 0 | 10K |
| 7 | Tek seferlik | 18K | 18K |
| 7 | Net (aylık) | +27K | +89K |
| 11 | Gelir | 188K | 188K |
| 11 | Maaş ve ek mesai | 29K | 29K |
| 11 | Geçim ve araçlar (kalkar) | 11K | 0 |
| 11 | Servis maliyeti (kalkar) | 81K | 0 |
| 11 | Sunucular | 6K | 17K |
| 11 | Kurucu satırı + kira | 0 | 7K |
| 11 | Tek seferlik | 16K | 16K |
| 11 | Net (aylık) | +45K | +119K |

Servis maliyeti evre 3'te gelirin %43'üne yakındır (tohum 7: $69K / $159K; tohum 11: $81K / $188K) ve net farkın çoğunu o yapıyor. Araç ($11K) ikinci kalem. Yeni kalemler (sunucu artışı, kurucu satırı, kira) kalkan iki kalemin ($80K / $92K) ancak $20K / $18K'sını geri getiriyor.

### 4.5 Memnuniyet modelinin gelire etkisi (B2B, tahmin)
Yeni modelin MRR'ı = ayakta kalan hesapların imza MRR'ı + yenileme fiyat değişimi (zam %8, indirim %10-15, bütçe küçülmesi %50); kapıdan dönen aday sıfır. K5 gerçek MRR'ı = ayakta hesapların imza MRR'ı. Fark aya eklendi. Genişleme ve K5'te sonradan değişen MRR iki tarafta da yok sayıldı.

| tohum | Varyant | açık (etkisiz) | açık (etkili) | 52. hf kümülatif (etkisiz) | (etkili) | evre 3 net (etkisiz) | (etkili) | 104. hf MRR farkı |
|---|---|---|---|---|---|---|---|---|
| 7 | A | -13K (hf 19) | -26K (hf 23) | +143K | +182K | +89K | +101K | +14K MRR |
| 7 | C | -32K (hf 36) | -35K (hf 32) | +54K | +93K | +74K | +87K | +14K MRR |
| 11 | A | -12K (hf 23) | -21K (hf 23) | +188K | +249K | +119K | +135K | +18K MRR |
| 11 | C | -30K (hf 32) | -28K (hf 27) | +99K | +161K | +105K | +121K | +18K MRR |

Okuma: kapı erken gelirden yaklaşık $13K MRR alıyor (hafta 16-20 imzaları): en derin açık A'da -13K'dan -26K'ya iniyor (hafta 23). Sonra yeni model daha az hesap kaybediyor ve her yenilemede %8 zam alıyor: 104. haftada MRR +14K (tohum 7) ve +18K (tohum 11) fazla. Evre 3 net 12-16K artıyor. Yani memnuniyet modeli ilk yılın nakit baskısını büyütüyor, sonrasını rahatlatıyor.

---

## 5. Kalan kapılar: tanı ve öneri koşuları
Aşağıdaki her koşu modelin **dışında** yapıldı; sabit değiştirilmedi. Etkisi ayrı gösteriliyor.

### 5.1 M5 Hiç düzeltmeyen (KALDI)
**Tanı.** Formül `hata terimi = min(3 x H, 60)`, H = açık hata / canlı hat (`C_ICERIK_v3.md` §5.2). `none` kolunda 50. haftadan sonra H 20-40 (140-325 açık hata, 7-8 canlı hat): terim hep tavanda. Memnuniyet = U - 60. U = 100 iken 40 kalıyor; eşik 30 / 33 / 36 (+2 inşaat): fark 2-10 puan **pozitif**. Hesap kaybetmiyor, "İndirim ister" (fark 5-11) diye yenileniyor. Kayıp yalnız eşiği yüksek (3★, inşaat) ya da kesinti satırı alan hesaplarda: iki tohumda 18 hesap (8'i 3★, 7'si 2★, 3'ü 1★; 14'ü Risk, 4'ü bütçe kesintisi).
**Öneri (O1).** Tavanı yükseltmek:

| hata terimi tavanı | none kolu kayıp (tohum başına) | worst kolu geç kayıp | ort. memnuniyet worst / none (tohum 7) | M3 / M4 / M5 | worst: kapı reddi / imza |
|---|---|---|---|---|---|
| 60 | tohum 7: geç 1,4% erken 0,0%; tohum 11: geç 6,9% erken 0,0% | 0,0%; 0,0% | 92,5 / 42,2 | geçti / geçti / kaldı | 23 / 705 |
| 62 | tohum 7: geç 13,4% erken 0,0%; tohum 11: geç 11,9% erken 0,0% | 0,0%; 0,0% | 92,5 / 42,5 | geçti / geçti / geçti | 23 / 705 |
| 64 | tohum 7: geç 34,8% erken 0,0%; tohum 11: geç 59,0% erken 0,0% | 0,0%; 0,0% | 92,5 / 41,7 | geçti / geçti / geçti | 23 / 705 |
| 66 | tohum 7: geç 48,2% erken 0,0%; tohum 11: geç 75,4% erken 0,0% | 0,0%; 0,0% | 92,5 / 41,2 | geçti / geçti / geçti | 23 / 705 |
| 68 | tohum 7: geç 92,9% erken 0,0%; tohum 11: geç 89,6% erken 0,0% | 0,0%; 0,0% | 92,5 / 43,2 | geçti / geçti / geçti | 23 / 705 |
| 70 | tohum 7: geç 94,6% erken 0,0%; tohum 11: geç 91,0% erken 0,0% | 0,0%; 0,0% | 92,5 / 44,3 | geçti / geçti / geçti | 23 / 705 |
| 80 | tohum 7: geç 100,0% erken 0,0%; tohum 11: geç 100,0% erken 0,0% | 0,0%; 0,0% | 92,5 / 44,7 | geçti / geçti / geçti | 23 / 705 |

Okuma: tavan 62 M5'i tutturuyor (%13,4 / %11,9); 64'te %35 / %59. Basamaklı çünkü `none` kolunda terim sürekli tavanda ve eşikler 30-38'de kümeleniyor: tavan her artışta bir eşik bandını daha açıyor. Tavan 64'te kayıp 118 hesap (246 imzadan): 2★ 101 / 111, 3★ 13 / 13, 1★ 4 / 122; yani 2★ ve 3★ gider, 1★ tutunur. Tavan 68'de 2★ ve 3★ hep, 70'te hepsi gider. İmza kapısı da sertleşiyor: tavan 64'te `none` kolunda imza 437'den 246'ya iniyor (imza anında terim daha büyük). M3 ve M4 değişmiyor (`worst/due/off`'ta H 0,5-4,8, terim en çok 15: tavana hiç dayanmıyor); ortalama memnuniyet (worst 92,5) ve `worst` kapı reddi (23 / 705) aynı. **Öneri: tavan 64.** Sınır: `none` kolunun 140-325 açık hatası uç bir oyuncudur; arada kalan oyuncu tavana dayanmaz.

### 5.2 M7 Kesinti kademesi (KALDI)
**Tanı.** §3. Kademe çarpanı tavandan önce uygulanıyor (`incident_system.gd:48-53`: `odds = base x tier x load x bugs`, sonra `minf(odds, p_max)`); yüksek yük ve hata birleşince Ekonomik ve Standart aynı tavana, 0,30'a dayanıyor.
**Öneri (O3).** Dört kural karşılaştırması:

| Kural | ≥%25 koşulunu bozan hücre | Kurumsal olay (tavanda hata, %70 yük) | Kurumsal olay (az hata, %70 yük) | %95 / %70 yük oranı (Ekonomik, az hata) | tavanda hata, yük x1,5 ve x2,5: Eko/Std/Kur |
|---|---|---|---|---|---|
| bugünkü kural: p_max 0,30; kademe çarpanı tavandan önce | 3 / 9 | 4,98 | 2,72 | 1,33 | 12 hata, x1,5: 15,1/11,5/6,9; 12 hata, x2,5: 15,1/15,1/10,2 |
| öneri a: p_max 0,45 | 1 / 9 | 4,98 | 2,72 | 1,33 | 12 hata, x1,5: 16,9/11,5/6,9; 12 hata, x2,5: 18,4/15,4/10,2 |
| öneri b: p_max 0,65 | 0 / 9 | 4,98 | 2,72 | 1,33 | 12 hata, x1,5: 16,9/11,5/6,9; 12 hata, x2,5: 20,9/15,4/10,2 |
| öneri c: p_max 0,30; kademe çarpanı tavandan sonra | 0 / 9 | 4,98 | 2,72 | 1,33 | 12 hata, x1,5: 15,1/9,9/5,8; 12 hata, x2,5: 15,1/9,9/5,8 |

Okuma: **öneri c** (çarpan tavandan sonra: `minf(base x load x bugs, p_max) x tier`) 9 hücrenin 9'unda basamağı tutturuyor ve B'nin p_max'ına dokunmuyor; her basamakta tam yarı. Alternatif: p_max 0,65 (9 / 9) ya da 0,45 (8 / 9). Kurumsal ≥ 4 olay koşulu hiçbir kuralda değişmiyor: az hatada 2,72, tavan hatada 4,98. C v3 §8'in B notuna eklenecek bir madde (B'nin kodu, Erdem onayı gerekir).

### 5.3 M9 Bütçe kesintisi (KALDI, alt sınır)
**Tanı.** §2.11. Memnun eşiği eşik + 12; bakımlı üründe hesap eşiğin ortalama 62,9 üstünde. Küçülme teklifi çıkıyor, hiçbiri ayrılmıyor.
**Seçenekler.**
1. Kapıyı "tam kayıp ≤ %1,5 ve küçülme payı ≥ %50" diye oku. Model değişmez; bakımlı havuzda geçer (0 ve %100). Erdem'in "müşteriler ayrılmasın zaten" sözüyle uyumlu. **Önerilen budur.**
2. Memnun hesabın %30'u kesintide yine de ayrılsın (kapanma, satın alınma gibi). Bakımlı havuzda tam kayıp 5,75 x 0,30 = 1,73 olay / yıl = %0,52, küçülme payı %70: iki koşul tutar. Yeni bir kural ve yeni bir metin demek.

### 5.4 M11 Gider ve runway (KALDI)
**Tanı.** Evre 3'te "Servis maliyeti" gelirin %43'üne yakın (E4); kalkınca net 27K'dan 89K'ya çıkıyor ve ilk yıl açığı 41K'dan 13K'ya iniyor. Üç koşul bozuk: açık hafta 19 / 23'te (30'dan önce) ve 25K'nın altında; 52. hafta kümülatif net 80K'nın çok üstünde; evre 3 net bugünün iki katının (55K / 89K) üstünde. Bootstrap runway ve B2C koşulları tutuyor.
**Öneri (maaş bandı taraması, B2B, `fix_worst`).** Telafi maaş bantlarını çarpmak (`hr_constants.gd:591-598`; kurucu satırı çarpılmaz). Dört koşul: açık ≥ 25K ve hafta > 30; 52. hafta ≤ 80K; evre 3 ≤ 2 x eski.

| tohum | Varyant | en derin kümülatif açık | 52. hf kümülatif net | evre 3 aylık net / sınır (2 x eski) | açık >= 25K ve hf > 30 | 52. hf <= 80K | evre 3 <= 2 x eski | en düşük nakit |
|---|---|---|---|---|---|---|---|---|
| 7 | A (maaş x1,0) | -13K (hf 19) | +143K | +89K / sınır +55K | hayır | hayır | hayır | +6K |
| 7 | C (x1,5) | -32K (hf 36) | +54K | +74K / sınır +55K | evet | evet | hayır | +6K |
| 7 | D (x2,0) | -69K (hf 36) | -35K | +60K / sınır +55K | evet | evet | hayır | +6K |
| 7 | E (x2,2) | -87K (hf 45) | -71K | +54K / sınır +55K | evet | evet | evet | +6K |
| 11 | A (maaş x1,0) | -12K (hf 23) | +188K | +119K / sınır +89K | hayır | hayır | hayır | +6K |
| 11 | C (x1,5) | -30K (hf 32) | +99K | +105K / sınır +89K | evet | hayır | hayır | +6K |
| 11 | D (x2,0) | -58K (hf 36) | +10K | +90K / sınır +89K | evet | evet | hayır | +6K |
| 11 | E (x2,2) | -73K (hf 45) | -25K | +84K / sınır +89K | evet | evet | evet | +6K |

Okuma: ×1,5 açığı 30K+ seviyesine ve 30. haftanın ötesine çekiyor, 52. haftayı 54K / 99K yapıyor (ikinci tohum 80K'nın üstünde); evre 3 sınırı tutmuyor. ×2,0 açık ve 52. hafta koşullarını iki tohumda da tutturuyor, evre 3'te 60K (sınır 55K) ve 90,2K (sınır 89,5K) ile kıl payı kalıyor. ×2,2 dört koşulu iki tohumda da tutturuyor; bedeli ilk yılın derinliği: -87K / -73K ve 52. hafta -71K / -25K (dış fonlama olmadan). Yani evre 3 koşulu maaşla ancak ilk yılı çok sertleştirerek tutuyor; v3 §3.5'in beklediği gibi evre 3 gevşemesinin görünür karşılığı büyüme harcaması (satışçı, pazarlama / E).
**Tahmin: servisin gerçek karşılığı müşteri temsilcisi.** Hesap kapasitesi 4 + 2 x yıldız (`b2b_constants.gd:160-161,176-178`); 2★ temsilci 8 hesap taşır. Botun 13 kişilik kadrosunda 3 temsilci var. Hesap sayısı kadar temsilci tutsaydı:

| tohum | hafta | hesap | gereken temsilci (2★: hesap kapasitesi 8) | aylık maaş (junior bandın ortası $1.875) |
|---|---|---|---|---|
| 7 | 72 | 216 | 27 | $50.625 |
| 7 | 96 | 304 | 38 | $71.250 |
| 7 | 103 | 330 | 42 | $78.750 |
| 11 | 72 | 211 | 27 | $50.625 |
| 11 | 96 | 304 | 38 | $71.250 |
| 11 | 103 | 330 | 42 | $78.750 |

304 hesapta 38 temsilci, aylık yaklaşık $71K: kalkan servisin evre 3 ortalamasıyla ($69K-81K) aynı büyüklük. Yani telafi, maaş bantlarını çarpmadan, "hesap sayısına göre temsilci tutmak" oyuncu kararı olarak gelirse ekonomi kendiliğinden dengelenir. Ama bunu modelde hiçbir kural zorlamıyor ve bu raporda temsilci kapasitesini aşan hesabın sonucu ölçülmedi. Bu soru M11'in dışında; Erdem'e açık.

### 5.5 Erdem'den karar bekleyenler
1. **Hata terimi tavanı** (M5): 60 mı, 64 mü? Öneri 64.
2. **Kesinti olasılığı sırası** (M7): kademe çarpanı tavandan sonra mı? Öneri evet (B'ye not).
3. **Yenileme bantları** (§2.10): bakımlı hesap yenilemede hep "Zamma açık" çıkıyor; bantlar kaydırılsın mı, kâğıt hiç gelmesin mi?
4. **Gider telafisi** (M11): telafisiz + oyuncu kararı (temsilci), maaş ×1,5, ×2 ya da ×2,2?
5. **Bütçe kesintisi kapısı** (M9): kapıyı yeniden okumak mı, memnun hesabın %30'u ayrılsın mı?

Not: B'ye gidecek madde 1 (doluluk çarpanı), `C_ICERIK_v3.md` §8'de hazır. Bu raporun bulgusundan B'yi etkileyen tek şey M7 önerisi (kademe çarpanı tavandan sonra); `satisfaction_delta` kartlarının izinin 4,5 kat uzaması (§2.12) içerik ayarı için B'ye ayrıca not edilebilir.

---

## 6. Varsayımlar: Python yaklaşımı kodun kopyası değildir
**Doğrulamalar (kodun kopyası olmasa da girdiyi ve formülü sınadım):**
- Eski mekanizma kopyası K5 kaydıyla: `none` %95,8, `off` %99,0 geçiş tutuyor (§2.1).
- K5 gerçek kayıp satırları A'nın `K5_OLCUM.md` tablosuyla birebir (§2.3).
- U uygulaması `KALITE_v2.md` §2.6 tablosuyla: 9 hücrenin 8'i birebir; inşaat P1'de 81 çıkıyor, belge 80 (belge Python yuvarlamasıyla, ben Godot'nun yarım-yukarı yuvarlamasıyla).
- Ekonomi: "Bugün" satırı `C_ICERIK_v3.md` §3.5 tablosuyla aynı (açık -41K / -37K, hafta 36; 52. hafta +9K / +43K; 101. hafta +316K / +534K). A ve C satırlarında açık aynı büyüklükte (A: -13K / -12K, v3: -12K / -10K); 52. hafta farkı (A: +143K / +188K, v3: +124K / +162K) ofis kirasından: v3 ofisi çalışan sayısından seçmişti (12 ve üstü Plaza), ben taşınma koşullarını (marka ≥ 40, nakit) uyguladım, Plaza daha geç açılıyor.

Memnuniyet:
- **Ürün girdisi K5 yayın kartlarından yeniden kuruldu**: `feat` kademeleri, `res:<alan>` = cila 0,5 (hat başına en çok 1,0, alanın hatlarına sırayla dağıtılır; hangi hatta düştüğü kayıtta yok). Onboarding'e `line_hidden_self_serve` ilk yayınlandığında giriyor. Alan seviyesi = hatların (kademe + cila) ortalaması (`sprint_catalog.gd:644-651`).
- **Açık hata** kayıttaki toplam; yeni modelde alanlara canlı hat sayısıyla orantılı dağıtılıyor (`C_ICERIK_v3.md` §5.2), yani H = açık hata / toplam canlı hat. Hatların gerçekte kümelenmemesi (rastgele hatta düşer) bu varsayımla uyumlu. Eski kolda hesabın hata sayısı kayıttaki `bugs=` değeri (kayıtta olmayan gün için açık hatanın %60'ı).
- **Rakip çıkışı yok.** `rival_hits` yok sayıldı; yalnız aday bağlamını etkiliyor (`KALITE_v2.md` §3.3).
- **Olay motoru yok.** Kartlar, gece zarı, tutma kartı (indirim ver, söz ver, oyala), CS yükselmesi, genişleme, Kurumsal sunucu maddesi simüle edilmedi. Risk makinesi (1 hafta eşik altı, 2 haftalık sayaç, 3 haftalık yeniden giriş) var, ama tutma kartı oynanmıyor: iki kolda da eşik altına inen hesap ayrılıyor. Kayıtta ilk Risk haftasında sayaç 3 görünüyor (2 olmalı); botun "oyala" oynadığını varsayıyorum, doğrulamadım.
- **Söz yok** bot kollarında (kayıttaki söz olayları, ör. `worst` tohum 7'de 20 söz, tekrar oynatılmadı); söz yalnız M6 ve R9 senaryolarında. İstek teslimi kayıttan alındı (`req:` kartları).
- **Kesinti:** B'nin zarı, kademe Standart (0,5), yük ≤ %90 (çarpan 1); süre 3-8 saat tekdüze; tutar yuvarlanmış min(8, 0,6 x saat); bütün hesaplara aynı hafta aynı satır (gece / sabah ayrımı yok; kod `incident_system.gd:279-291` iki grup kuruyor).
- **Sahip:** kurucu (`cs_dampen` 1,0); M6 temsilci kolu çıktı 5 (0,725).
- **Yenileme:** bot, satışçı raporunun 1. seçeneğini seçer (tutumun en iyi fiyatı); ikna +2; karşı teklif ve kurucu yolu yok; fiyat sözleşme sonunda işler. 104 haftada ilk yenileme (44. hafta) ölçülüyor, ikinci yalnız 270 haftalık R9 ve M8 senaryolarında.
- **Sektör** K5'te yok. Eşik ekinden çıkarıldı: ek 5 → inşaat; ek 0 → sekiz sektörden tohumlu rastgele; sigortalı hesap kayıtta hiç yok. Sağlık, Tekstil ve Medya aday üretmiyor (`KALITE_v2.md` §2.2).
- **Kopya sınırı:** `worst/due` kollarında kayıtla kopya %61-64 tutuyor (§2.1): kart delta'ları ve temsilci yavaşlatması kopyada yok.

Ekonomi:
- **Bot kararları sabit:** işe alım, satış, sprint, sunucu birim sayısı K5 kaydındaki gibi; yeni giderler muhasebe. Bot nakde göre işe aldığı için gerçek koşu bu sayılardan sapar.
- **Sunucu birim sayısı** eski otomatik büyümeden. Oyuncunun kapasite politikası (bilerek pay bırakmak) modelde yok; yük %80-90 bandı varsayımı değil, kayıttaki birimin sonucu.
- **Servis ve araç tümden çıkarıldı**, yerine hiçbir şey eklenmedi (A varyantı). Kurucu satırı sabit $1.500.
- **Kira:** oyuncu, koşulları sağlanan en üst ofise taşınır ve inmez (İş hanı: evre ≥ 2 ve nakit ≥ 6.500, Frank'in çeki için evre vekil; Plaza: ekip ≥ 12, nakit ≥ 45K, marka ≥ 40; Loft: 35 / 110K / 70). Taşınma gecikmesi (1 hafta) yok. Botun 13 kişilik kadrosu Loft'a hiç varmıyor.
- **Maaş çarpanı** maaş ve ek mesaiye uygulandı; işe alım primi ve kıdem tazminatı çarpılmadı.
- **Gelir etkisi** (§4.5) yalnız imza MRR'ı + yenileme fiyat değişimi; genişleme ve sonradan değişen MRR yok.
- **Ay payı** `ticks x 7 / 30`; `MONTH_BURN` takvim ayı sınırlarına göre.
- **B2C** için memnuniyet modeli yok (yalnız gider).

---

## 7. Yorum listesi
Belgede eksik ya da çelişkili yerde seçtiğim en makul okuma:
1. **Yeni eşik:** 30 + 3 x (yıldız - 1) + sektör ekinin yarısı; yarım değer aşağı yuvarlanır (5 → 2, 3 → 1). `C_ICERIK_v3.md` §5.7 "en çok 38" ile uyumlu (3★ inşaat: 36 + 2).
2. **Eski kolda eşik** bugünkü kod (33 / 42 / 51); ayrı bir kol "eski mekanizma, yeni eşik" de koşuldu (4 kol toplamı nedensiz 10, kayıp 0; tablo dışında).
3. **Eski kolda hedef:** gizli eksen yerine yeni modelin U'su, aynı hesap referansıyla; imza seed'i (kararlılık + deneyim ortalaması) yok sayıldı, imza `max(eşik + 10, 50)`.
4. **Pazar çıtası rampası:** yeni beklenen alan (0 → 0,5) rampasız tam değerle giriyor (sıfırdan rampa alan dahil / haric ikilisini tanımsız yapıyor); yükselen alanlar (Çekirdek 0,6 → 1 → 1,5; öteki 0,5 → 1) 8 haftada doğrusal.
5. **Hesap referansı** imzada aday bağlamı (rakipsiz), yenileme dönemi açılışında yeniden okunur; arada sabit (`KALITE_v2.md` §3.3).
6. **Açık hata terimi** alan ağırlığıyla değil toplam canlı hat sayısıyla hesaplandı: açık hata alanlara canlı hat sayısıyla orantılı dağıldığı için iki yol aynı sonucu verir (§6).
7. **`fix_off`** = hata terimi 0 (`ProductState.bugs_free`, `product_state.gd:233-234` `costed`). Eski kopyada hesap cezası 0.
8. **Yenileme indirimi** +8 terim yazıyor (belge yalnız "İndirim ver" kartı için yazıyor); zam -2. İkisi bir sonraki yenilemeye kadar. Karar anındaki değerden okunuyor.
9. **Bütçe kesintisi zarı** yenileme döneminde bir kez, hesap ve model başına aynı tohum (iki kolda aynı zar); "memnun" karar anındaki memnuniyet ≥ eşik + 12.
10. **Ayrılış haftası:** yenilememe kararı 44. haftada verilir, hesap bitişe kadar öder ve sözleşme sonunda (52. hafta) kayıp sayılır. Ortada Risk ile ayrılan hafta kayıp haftasıdır.
11. **İmza kapısı** MVP öncesi (hafta 7) imzaya da uygulanıyor; imzada 70 olduğu için geçiyor.
12. **`satisfaction_delta`** olumlu satır sönmez (kalıcı, +10 tavanına sayılır), olumsuz 8 hafta söner. Aksi hâlde "sönen olumlu satır olaysız düşüş" olurdu (§5.3 ilkesi). Belge süreyi cinsten bağımsız yazıyor.
13. **Eşik çırçırı** yeni modelde de var (tutulan -5, bozulan +5, tavan seed + 10; `C_ICERIK_v3.md` §5.7 "Tut").
14. **M7 "Kurumsal ≥ 4 olay"** hangi hata satırı için, belgede yazmıyor. Tavandaki hata satırı ve %70 yükle de okudum; en geniş okuma her hücre.
15. **M8 yenileme ayağı** (30. hafta donması): bot ürünü çıtayı karşıladığı için tetiklenmiyor; 20. hafta varyantı eklendi.
16. **M9 "bakımlı havuz"** = worst + due + off kollarının yeni model yenileme farkları; "bakımsız" = none.
17. **M10 "bugünün imza sayısı"** = K5'te imzalayanların hepsi; dönen aday sonra imzalamıyor (üst sınır).
18. **Nedensiz düşüş** tanımı: eski kopyada U ve hesabın hata cezası o hafta değişmişse adlı; yeni modelde bileşenlerden biri değişmişse adlı. K5 gerçek seride dar ve geniş okuma iki ayrı sayı.
19. **Kayıp yüzdesi** A'nın tanımı (kayıp / (kayıp + dönem sonu ayakta)) kullanıldı; K5 gerçek satırları A'nın tablosuyla birebir.
20. **M1 sayılan hesap-haftası** yalnız kapı açık ve kapısız bot kolları: 249.994.
21. **Yuvarlama:** `round` Godot'daki gibi yarım yukarı (belgedeki bir hücre Python yuvarlamasıyla 80, burada 81).

---

## 8. Kod sabitleri ve kaynakları
| Sabit | Değer | Yer |
|---|---|---|
| İmza değeri | `max(eşik + 10, 50)` | `sales_system.gd:364-368`; `b2b_constants.gd:19-20` |
| Eşik (eski) | 33 + 9 x (★ - 1) + sektör ek (inşaat ve sağlık 5, sigorta 3) | `b2b_constants.gd:39-46,48-53` |
| Kayma | günde 3 → tikte 21; ilk 4 hafta günde 5 → 35 | `b2b_constants.gd:30-31`; `b2b_sales_system.gd:87-118` |
| Taban | hedef ≥ eşik + 2, 4 hafta | `b2b_constants.gd:15-16`; `b2b_sales_system.gd:150-151,172-174` |
| Hata cezası (eski) | 0,3 x adet, en çok 20 | `b2b_constants.gd:58-59`; `b2b_sales_system.gd:146-147` |
| Güven defteri | söz +6 / -2 / -12; günde 0,4 affeder; sınır -25 / +10 | `b2b_constants.gd:263-268` |
| Söz anlık | +15 / -5 / -20; eşik -5 / +5 (tavan +10) | `b2b_constants.gd:138-152` |
| Risk makinesi | 1 hafta eşik altı, 2 hafta sayaç, 3 hafta yeniden giriş | `b2b_constants.gd:21,27-28`; `b2b_sales_system.gd:211-234` |
| CS yavaşlatma | 1 - 0,055 x çıktı, en az 0,4 | `b2b_constants.gd:163,184-190` |
| Kesinti zarı | 0,10 x kademe x yük x (1 + min(açık, 12) / 8), en çok 0,30; ≥ 4 hafta ara; 3 hafta sessiz | `incident_system.gd:38-70`; `sprint.json:41-43` |
| Kesinti bedeli | saat x 0,6, en çok 8; kredi %85 affeder | `incident_system.gd:279-291`; `sprint.json` `incident.outage` |
| Araç gideri | taban 1.500 / 1.500 / 5.500; kişi başı 150 / 300 / 500 | `finance_system.gd:13-14,219-222` |
| Servis maliyeti | hesap 45 + koltuk 8; B2C 1.000 kullanıcı 700; yeni hesap MRR x 0 / 0,25 / 3 | `infra_system.gd:87-92,267-277` |
| Sunucu fiyatı (eski) | B2B 30 / 45 / 70 (50 koltuk); B2C 35 / 55 / 85 (1.000 kullanıcı) | `infra_system.gd:26,28,30-31` |
| Maaş bantları | geliştirici 2.000-3.000 / 3.000-6.000 / 6.000-10.000, müşteri temsilcisi 1.500-2.250 / ... | `hr_constants.gd:591-598` |
| Hesap kapasitesi | 4 + 2 x yıldız | `b2b_constants.gd:160-161,176-178` |
| Ofis koşulları | İş hanı nakit 6.500; Plaza ekip 12, nakit 45K, marka 40; Loft 35, 110K, 70 | `office_constants.gd:15-62` |
| Ürün seviyesi | hatların (kademe + cila) ortalaması, hat ≤ 3 | `sprint_catalog.gd:644-651`; `product_lines.gd:20` |
| Günlük sıra | ürün → sprint → ... → satış (kayma) → ... → olay motoru (kart) | `time_manager.gd:383-416` |

Yeni modelin sayıları (hepsi `C_ICERIK_v3.md` §5 ve `KALITE_v2.md` §2-3'ten; betikte `model.py` başında, paragraf numarasıyla): hata katsayısı 3, tavan 60 (§5.2); defter satırları +6 / -3 / -12 / +4, olumlu tavan +10 (§5.3); imza kapısı +10 (§5.4); güncelleme yaşı 26 / 4 / -1 / -12 (§5.5); ağırlıklar 0,50 / 0,25 / 0,15 / 0,10, tavan payı 0,25, oran tavanı 1,5, taban 70 (`KALITE_v2.md` §2.5, §3.1, §3.4); beklenti Bootstrap 0,6 (Çekirdek), Traction 1 / 0,5, Series A 1,5 / 1 (`KALITE_v2.md` §3.2).

---

## 9. Yeniden koşturma
Dizin: `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/msim/`. Hepsi `python -I <betik>` (isolated mod; betikler kendi dizinlerini `sys.path`'e ekler).

| Betik | İş | Çıktı (`out/`) |
|---|---|---|
| `k5.py` | K5 kayıtlarını okur, ürün serisini kurar | `cache/` |
| `model.py` | yeni ve eski memnuniyet modeli (paragraf numaralı) | |
| `real_old.py` | K5 gerçek seri: nedensiz düşüş, ilk hafta, kopya sınaması | |
| `p1_bot.py` | bot kolları (4 kol x 2 tohum x 5 model) | `p1_tables.md`, `p1.pkl` |
| `p2_scen.py` | R9 şekilleri, M2, M6, M8, M7, M9, kart izi | `p2_tables.md`, `p2.json` |
| `p3_econ.py` | ekonomi (E1-E5) | `p3_tables.md`, `p3.json` |
| `p4_prop.py` | öneri koşuları (O1-O3) | `p4_tables.md`, `p4.json` |
| `p5_gates.py` | M1 toplamı, ilk hafta, M10, tutum dağılımı | `g.json` |
| `build_report.py` | bu raporu kurar | `docs/tasks/faz_cde/MEMNUNIYET_SIM.md` |
| `run_all.py` | yukarıdakilerin hepsini sırayla koşar | |

Sıra: `p1_bot.py` → `p2_scen.py` → `p3_econ.py` → `p4_prop.py` → `p5_gates.py` → `build_report.py`. Toplam yaklaşık 1 dakika. Tohumlar sabit; sonuçlar bayt-deterministik.

---

## 10. İnceleme sonrası (Opus)
Kıdemli inceleme, 17 Ekim 2026 gecesi. Betikler yeniden koşulmadı: kabul edilen iki öneri (M7 öneri c, M9 seçenek 1) bu
raporda zaten ayrı koşuyla ölçülmüştü (§5.2, §5.3); öbürleri Erdem'e gidiyor. Formül kontrolü: `model.py`'nin `fit()`
(oran 1,5'te kesik, tavan payı 0,25, 70 × uyum, 100'de kesik), `bug_term()` (3 × açık ÷ canlı hat, en çok 60), defter
satırının doğrusal sönmesi (süre × sahip katsayısı) ve yaş terimi (26 / 4 / 12) `C_ICERIK_v3.md` §5 ve `KALITE_v2.md` §3 ile
aynı.

| Konu | İncelemenin kararı | Belgeye işlendiği yer |
|---|---|---|
| M7 kesinti sırası | Kabul: kademe çarpanı `p_max`'tan sonra (öneri c, 9 / 9). Değerler Erdem'in; yalnız sıra değişir, B'ye not | `C_ICERIK_v3.md` §2.6, §7.4, §8 madde 5 |
| M9 bütçe kesintisi | Kabul: kapı "tam kayıp ≤ %1,5 ve küçülme payı ≥ %50" diye okunur (seçenek 1); model aynı | `C_ICERIK_v3.md` §4, §7.4 |
| M5 hata terimi tavanı | Kabul edilmedi, 60 kalır. Sonuç bir eşik bandına yaslanan uçurum (62'de %13, 64'te %35 ile %59, 68'de %90); asıl neden U doyumu (§2.9). Beklenti kalibrasyonundan sonra yeniden ölçülür | `C_ICERIK_v3.md` §5.2; `KALITE_v2.md` §3.5, §8 |
| U doyumu, yenileme bantları (§2.10) | Erdem'e soru: önce beklenti kalibrasyonu (imzada U ortancası 70 ile 85), sonra bantlar (örnek Zamma açık ≥ 45) | `KALITE_v2.md` §8 ve Soru 5; `C_ICERIK_v3.md` §6 ve Soru 5 |
| M11 gider telafisi | Erdem'e soru; C v3'ün tablosu bu raporun sayılarıyla güncellendi (fark ofis kirası varsayımı, §6) | `C_ICERIK_v3.md` §3.5, Soru 1 |
| M13 kart izi ×4,5 | B'ye not | `C_ICERIK_v3.md` §8 madde 4 |

Kapı tablosunun inceleme sonrası okuması: 13 kapının 8'i geçti; M7 (öneri c ile) ve M9 (kapının yeni okumasıyla) geçer;
M5 ve M11 Erdem'in kararına bağlı; M13 bilgi.
