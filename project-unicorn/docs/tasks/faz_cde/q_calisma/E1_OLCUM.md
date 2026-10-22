# Faz Q · E1 ölçüm durağı (19 Ekim)

Koşulan kod: HEAD `bd7ed53` (K0 … K7b). 15 kol × tohum 7 ve 11 × 104 hafta, iki sprint probu, Q0b'nin iki tik probu × 3.
38 koşunun hepsi bitti; PROBE ERROR 0, motor hatası 0. Tam tablolar `K8_TABLOLAR.md`, tanı sayımları `K8_TANI.txt`.
Taban: `Q0b_TABAN.md` (eski kod, aynı kollar). Q0b'de olmayan kollar (`_desk`, `quality_core`, `vc_product`) fix_worst ya da
vc_cautious tabanıyla kıyaslanır. Sabitlere dokunulmadı.

## 1. Kapılar bir bakışta (fix_worst, iki tohumun havuzu; parantezde masalı ikiz fix_worst_desk)

| PRD | Kapı | Hedef | Ölçüm | Durum |
|---|---|---|---|---|
| §4.3 | Nedensiz U düşüşü | 0 hafta | 0 (bütün B2B kolları, 1.636 hafta) | ✅ |
| §4.4-1 | İmzada U = 100 payı, bütün imzalar | ≤ %25 | %67,8 (%48,9) | ❌ |
| §4.4-1 | aynı, 2★ ve 3★ | ≤ %25 | %45,0 (%26,7) | ❌ |
| §4.4-2 | Traction imza U ortancası, bütün | 70-85 | 100 (83) | ❌ (masalıda ✅) |
| §4.4-2 | aynı, 2★ ve 3★ | 70-85 | 88 (72) | ❌ yakın (masalıda ✅) |
| §4.4-3 | Traction'ın ilk 12 haftasında 2★ aday U ortancası | ≥ 48 | 60 | ✅ |
| §4.4-4 | MVP sonrası 26 haftada imza, Q0b'ye oran | %80-120 | %58 (%61) | ❌ |
| §4.4-5 | Satışçı kapanış kaybı | %5-15 | %1,1 (masalı; 3/279) | ❌ (2★'da 3/48 = %6,3) |
| §4.4-5 | aynı, quality_core | ≥ %20 | %0 (0/335; satışçılar yalnız 1★ kapatıyor) | ❌ |
| §4.4-6 | B2C kitle eğrisi, Q0b'den sapma | ≤ %20 | hf13 +%170-210, hf52 +%300-3.500 | ❌ |
| §4.4-7 | VC zayıf alan cümlesi, koşu başına | ≤ 3 | en çok 2 (vc_product) | ✅ |
| §4.5-1 | quality_core ile fix_worst arasında 2★+3★ U farkı | ≥ 10 puan | 30 (masalı 14); quality_core daha düşük | ✅ (yön: yalnız Çekirdek kaybettiriyor) |
| §4.5-2 | Series A Avı'nda 3★ aday payı farkı | ≥ 5 puan | masalı +10,7; masasız quality_core Series A'ya varamıyor | ✅ (masalı) |
| §4.5-3 | Sektörler arası 2★ aday U farkı | ≥ 8 | 17,5 | ✅ |
| §4.5-3 | Zayıf alanı vurgu 1 sayan sektörün farkı | ≥ 10 | 24 | ✅ |
| §4.5-4 | Kurucu kaybında alan adlı pay | ≥ %50 | %19,9 (%64,6) | ❌ (2★ ve 3★'ta 37/40 = %92) |
| §4.5-4 | Satışçı kaybında alan adlı pay | %100 | 3/3 | ✅ |
| §4.5-5 | B2B Traction haftalık kart sayısı | artmaz | 2 (Q0b 3) | ✅ |
| §4.6 | 330 hesapta gece tiki | ≤ +%5 | +%11 (141,1 → 157,2 ms, ortanca) | ❌ (K9'da önbellek) |
| §4.8 | Sprint probu uyuşmazlığı | büyümez | b2b adlı 7 → 10 (dünya kayması), b2c 8 → 8, adsız 0 | ⚠️ |

## 2. Neden tutmuyor (sayıyla)

**a) 1★ tasarım gereği doyuyor, kapıları o sulandırıyor.** fix_worst'te 1★ imzaların %85'i U = 100 (262/309); kurucunun
kaybettiği 1★ görüşmelerin hiçbiri alan adlı değil (fiyat 105, eksik kademe 41). Satışçıların kapattığı adayların %83'ü 1★
ve U 100: zar yalnız eksik alan varken atıldığı için 231 kapanışın hiçbirinde atılmadı. 2★ ve 3★'a bakınca açıklanmış kayıp
%92, satışçı kaybı 3/48. Karar 8 bu durumu öngörüyor ve kapıyı 2★ ve 3★'a uygulamayı öneriyor.

**b) 2★ geç oyunda doyuyor, 3★ hiç doymuyor.** fix_worst 2★ imzalarının %46'sı U = 100 (104/226); 3★ imza 104 haftada
yalnız 5 (U = 100 hiç yok; 3★ imzaların %40'ında U, tolerans + 10'un altında). Botun ürününde İlk kullanım hiç yapılmıyor,
3★ satırı (Çekirdek 2, vurgu 1,5, kalan 1) ona hep kapalı. Ürünün kovalayacağı müşteri kalmıyor: 2★ yetmiş, 3★ ulaşılmaz.

**c) İmza düşüşü erken Traction'dan geliyor ve kendini besliyor.** MVP'de 2★ aday U'su 23, 11-23. haftalar arası 49-64
(çıta 47). 2★ kurucu kayıplarının 31/34'ü zayıf alan. 3★ aday 26 haftada 6-7 (Q0b 29-31): ürünün 3★ uyumu düşük, kapı
karışımı üst bandı 1★'a devrediyor. Aday sayısı 19. haftaya kadar tabanla birebir aynı; sonra imza az olduğu için MRR geç,
satışçı geç alınıyor ve aday akışı 19-25. haftalarda tabanın yarısında kalıyor. MRR: 26. hafta yarı (18-28 bin, taban 38-44 bin),
78. hafta tabana yaklaşıyor (94-136 bin, taban 112-148 bin). Series A Avı'na giriş 72-103. hafta (taban 61-83).
Kısmen tasarımın niyeti ("MVP 1★'a yeter, 2★ Çekirdek'in kalanını ister"); bot kayıptaki alan adını okumuyor, oyuncu okur.

**d) B2C kitlesi kaçıyor.** Memnuniyet 14'ten 78-82'ye çıktı (Deneyim tuzağı kalktı), ağızdan ağıza büyüme her hafta ~%10.
52. haftada kitle 32-218 bin (taban 4-8 bin), MRR 0,25-1,1 M$ (taban 21-29 bin), Series A Avı 35. hafta (taban 75-81).
fix_off'ta 104. haftada 17 milyon kullanıcı. K4c'nin duyarlılığı: tek sabit tabana indirmiyor (en iyi bileşim WOM kapısı
60 + aşınma eşiği 40 → 52. hafta 34 bin).

## 3. Senden istenen kararlar
Sabitler geçici değerleriyle duruyor (onay bekliyor). K9 senin seçtiğin değerleri yazar ve bir kez yeniden ölçer.

1. **Kapı kapsamı.** U = 100 payı, Traction ortancası, satışçı zarı ve açıklanmış kayıp kapıları 2★ ve 3★ satırından mı
   okunsun? Önerim: evet (Karar 8'in öngörüsü; 1★'ı kapıya sokmak onu zorlaştırmaya iter).
2. **2★ doyumu (yıldız tablosu, Karar 8'in tek kolu).** Bugün `CORE_2` 1,0, vurgu 1 ÷ hat (Güven 0,5). Önerim: `CORE_2` 1,5
   ve vurgu tam 1. 2★ ancak Çekirdek'in çoğu ikinci sürümdeyken doyar (U = 100 için Çekirdek 1,18 yerine 1,77). Bedeli:
   orta Traction'da 2★ itirazı ve kaybı artar, imza düşüşü büyür. Seçenek: tablo aynı kalır, kapı ertelenir.
3. **İmza düşüşü (§4.4-4, %58).** Önerim: kabul, kapı yeni modele göre %55-65 bandına çekilsin ve C'nin imza kapısıyla
   yeniden ölçülsün; açık 78. haftada kapanıyor. Seçenek: erken 2★'ı yumuşat (2★ vurgu beklentisi 0, yalnız Çekirdek 1).
   Bu seçenek 2. sorunun önerisiyle çelişir.
4. **B2C kitle ve beklenti (§4.4-6 ve PRD §10 kalan soru 1).** Önerim: eğri tabana çekilsin. K9'da ağızdan ağıza büyüme
   (`WOM_SAT_GATE` 30, `WOM_COEF` 0,0012) ve `B2C_QUALITY_PER_FIT` 5/7 ölçülerek ayarlanır; hedef 26, 52 ve 104. haftada
   taban ± %20; tutmazsa ölçümle gelirim. Beklenti kitleye bağlı kalsın (1.000 / 10.000 / 50.000), ama ürün sayfasının B2C
   sözcüğü en az 2★ satırını okusun (küçük kitlede tek K1'e "Güçlü" demesin). Seçenek: yeni hızlı eğri kabul.

## 4. İkinci tur (önerimle; onay gelince K9'a girer)
- 1★ adayda vurgu alanının beklentisi 0 ve seviyesi 0 ise sözcük "Yok" ve güçlü cevap kilitli, geri dönüş kapısı kapalı
  (PRD harfiyen). Önerim: beklentisi 0 olan alan cevap ve dönüş kapısında "Yeterli" sayılsın.
- B2C taban merdiveni: seviyesi 0 olan alan kitle 1.000'i geçince doğrudan "crossed" olur, uyarı kartı atlanır.
  Önerim: önce uyarı (bir hafta), sonra crossed.
- Satışçı zarı eğrisi (`CLOSE_CURVE`) aynı kalsın; 2★'da 3/48 = %6,3 bandın içinde (n küçük).
- Kapı karışımı eşikleri (`QUALITY_STRENGTH_LOW` 0,6 / `HIGH` 1,0) aynı kalsın; Karar 8 doyum için oynatılmasını yasaklıyor.
- Gece tiki: K9'da `SprintCatalog.capabilities` önbelleği (kod, sabit değil); hedef +%5.

## 5. Bilgi (karar değil)
- C'nin girdisi, imzada U < tolerans + 10: fix_worst 1★ %0, 2★ %4, 3★ %40 (n = 5); fix_worst_desk 2★ %3, 3★ %17,5 (n = 194);
  quality_core 2★ %42.
- quality_core kolu kendini besleyemiyor: 2★ aday U ortancası 31, masasız ikiz Series A Avı'na hiç varmıyor. §4.5-1 PRD'nin
  sözüyle ("en az 10 puan farklı") tutuyor, ama yön tersine: yalnız Çekirdek'e yatırmak kaybettiriyor (sektör vurgusu önemli).
- B2B MVP'sinde Çekirdek 0,6 < 1 olduğu için VC'nin zayıf alan sorusu ve seed'in "ne kadar büyük" sorusu Çekirdek 1'e
  varana kadar hep açık (K4v).
- Hesap toleransı U ölçeğinde 2★ ve 3★ hesabı zayıf üründe altta bırakıyor (K1 ERP'de 3★ U 43, çıta 51): C3a'nın konusu (K4b).

## 6. Erdem'in E1 kararları (19 Ekim)
1. Kapı kapsamı: 2★ ve 3★ satırı (önerilen). Erdem: "önerilen ile devam et ama bu konuda hiç bi şey anlamadım iş bitiminde bunu
   bana açıkla neydi nasıl değiştirdik şu anki durum ne" → RAPOR_Q'da ve son mesajda sade dille, örnekle anlatılacak.
2. 2★ satırı: `CORE_2` 1,0 → 1,5 ve 2★ vurgu beklentisi tam 1 (1 ÷ hat yerine). K9 yazar ve bir kez ölçer.
3. İmza düşüşü kabul; §4.4-4 kapısı yeni modelde %55-65, C'nin imza kapısıyla yeniden ölçülür.
4. B2C: eğri tabana çekilir (ağızdan ağıza büyüme ve B2C_QUALITY_PER_FIT ölçülerek; hedef 26, 52, 104. haftada taban ± %20);
   beklenti kitleye bağlı kalır; ürün sayfasının B2C sözcüğü en az 2★ satırını okur.
İkinci tur maddeleri (§4) onaylanmadı: RAPOR_Q'da "onay bekliyor".
