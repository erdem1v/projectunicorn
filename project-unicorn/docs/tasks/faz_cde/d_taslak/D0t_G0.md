# D0t.2 · Derinlik kartının ilk kazancı g₀ (Q'nun seviye biriminde)

20 Ekim 2026 · D0t.2 alt ajanı (Sonnet) · Belge ve hesap işi: Godot koşturulmadı; oyun koduna, `strings.csv`'ye ve `data/`'ya yazılmadı; git'te durum değiştirilmedi. Kod Q'nun son commit'i `910ad1f`'ten okundu. Her sabit ve öneri **onay bekliyor**. Yardımcı betikler `d_taslak/dsim/v3/g0/` altında; sayıların hepsi koddan, veriden ya da o betiklerin çıktısından gelir (kaynağı her yerde yazılı).

## 0. Erdem için kısa özet
1. **Önerilen g₀ = 0,25 seviye** (Q'nun 2★ Çekirdek karesi) **[onay bekliyor]**. Bir alanın bütün derinlik kartları birleşince en çok 4·g₀ = 1,0 seviye, yani bir alan bir kademe yükselir. İlk kart 2★ sayfada her alanda en az 1 kare yazar ve bir Çekirdek kademe kartından %25 fazla (7,8 ve 6,2 ürün uyumu puanı) değer katar; sonraki kartlar altında kalır.
2. **Kare birimi:** 1 kare = referans beklentisinin beşte biri (`area_row`). B2B sayfası hep 2★ okur: **Çekirdek'te 0,25, öteki alanlarda 0,20 seviye.** 3★'ta 0,40 ve 0,30. Hat sayısı alanın kademe adımını belirler: Çekirdek 0,20 (0,8 kare), Güven & Ölçek 0,50, tek hatlı alanlar 1,00.
3. **Asıl bulgu, g₀'dan büyük:** Karar 13'ün iki cümlesi ("K3'ü biten hatta aç", "kesiğe varmış alanda önerme") Q'nun sayılarıyla birlikte tutmuyor. K3'ü bitmiş her alan 2★ ve 3★ referansının 1,5 katında ya da üstündedir. Kesik 2★ sayfaya göre uygulanırsa derinlik kartı **hiç açılmaz**; 3★'a göre ürün başına 2-20 kart açılır (yalnız Çekirdek).
4. **Kesikli tüketim hat başına 0-12 kart** (kesiksiz D0s: 13-178). 162 ad (hat başına 8,5) ve hatta 6 ad bile yeter. **Ama bedeli arz:** derinlik kartı teslim puanının 3 kişide %38'i, 12 kişide %82'si, 50 kişide %96'sıdır; kesikte teslim 3 / 6 / 12 / 25 / 50 kişide −%43 / −%74 / −%87 / −%94 / −%97 düşer, boşta payı %49-98 olur.
5. **Kesik yerine alan başına bir kart tavanı konursa** (arzı kısmen korur: 6 kişide teslim −%34…−%57): tavan 8 ise 162 ad yeter; 9 ve üstünde tek hatlı iki alanın (Onboarding, Entegrasyonlar, 8 ad) adı eksik kalır. "Hat başına 6 ad yetmez" sorusu kesikle değil, hangi tavanın seçildiğiyle cevap bulur.
6. **Azalma 0,75 ile ilk 11 kartta serinin %96'sı biter.** Kesiksiz tüketimde biten kartların %71'i (6 kişi) ile %97'si (50 kişi) bu noktanın ötesindedir ve her biri g₀'ın %5,6'sından azını katar. Bu pay g₀'a bağlı değildir.
7. **Kazanç hattın içine eklenirse sıfır olur** (`level` her hattı `min(kademe + cila, son kademe)` ile keser, K3 hat zaten 3,0). Alanın ortalamasına, kırpmadan sonra eklenmeli.
8. **Erdem'e sorular §6'da:** kesik cümlesi için üç yol, azalma biçimi, g₀ onayı, etiket kuralı. g₀ ancak kesik kararıyla birlikte anlam kazanır.


## 1. Neye bakıldı
- **Kod:** Q'nun son commit'i `910ad1f`, `git show` ile okundu (çalışma ağacı değil). `scripts/systems/product_quality.gd` (aşağıda `pq:satır`), `sprint_catalog.gd` (`sc:satır`), `product_lines.gd` (`pl:satır`), `data/product/sprint.json` (`sprint.json:satır`).
- **Belgeler:** PRD_FAZ_D Karar 13 (satır 306-330), RAPOR_Q §4.1 ve §7.1, D0s §10 ve İnceleme notu (düzeltilmiş tüketim sayıları), `Wa_ADLAR.json` (19 hat, 162 ad).
- **Simülasyon:** `d_taslak/dsim/v3/dsim3.py` değişmedi. `g0/sim_g0.py` onu alt sınıf olarak koşar: D0s'un R okuması (`D3_KEYMODE=plan D3_SHIELD=0 D3_PMRULE=karar4h`), kaynaklı arz, 104 hafta, 20 tohum (1-20), S1-S6 = 1, 3, 6, 12, 25, 50 kişi. `orig` kolu dsim3'ü aynen koşar ve D0s'un kayıtlı sonuçlarını yeniden üretir (kontrol: S4 tohum 1 ve 2'de `depth_seq`, teslim ve boşta eşit; 20 tohum medyanları D0s §10'un düzeltilmiş tablosuyla aynı: hat başına 13 / 25 / 47 / 102 / 178, en çok kullanılan hat 16 / 28 / 52 / 115 / 192,5). Tablolar `g0/tablolar.py` (analitik) ve `g0/ozet.py` (simülasyon) çıktısıdır; bu belgedeki tablolar o çıktının kopyasıdır.
- **Godot koşmadı; oyun koduna, CSV'ye ve `data/`'ya yazılmadı; git'te durum değişmedi.**

## 2. A · Bir "kare" kaç seviyedir

**Kare, referans beklentisinin beşte biridir.** `area_row` kareyi `min(roundi(seviye ÷ beklenti × 5), 10)` diye hesaplar (`pq:200`); beş ve on sayıları `sprint.json:39` (`pm.goal_mark` 5, `pm.goal_squares` 10). Beşinci kare referansın kendisi, onuncu kare beklentinin iki katıdır (oran 2,0). Soluk kareler 8'den başlar: `roundi(RATIO_CAP × 5)` = `roundi(7,5)` = 8 (`pq:201`, `RATIO_CAP` `pq:13`). Godot `roundi` yarımı sıfırdan uzağa yuvarlar.

Yani 1 kare = beklenti ÷ 5 seviye. Beklentiler `pq:37-41` ve `pq:341-355`:

| Rol | 1★ beklenti | 2★ beklenti | 3★ beklenti | 1 kare = seviye (1★) | 1 kare = seviye (2★) | 1 kare = seviye (3★) |
|---|---|---|---|---|---|---|
| Çekirdek | 0,60 | 1,25 | 2,00 | 0,120 | 0,250 | 0,400 |
| Vurgu alanı (sayfada çekirdek dışı her alan; hesapta sektörün ilk iki alanı) | — | 1,00 | 1,50 | — | 0,200 | 0,300 |
| Kalan alan (yalnız sektörlü hesap bağlamı; sayfada yok) | — | 0 (bakmaz) | 1,00 | — | — | 0,200 |

- **Ekranda görünen kare B2B'de hep 2★'ındır.** `area_row` bağlamsız `expectation(area)` çağırır (`pq:196`); bağlam boşken B2B ürün sayfası 2★ okur (`PAGE_STAR` `pq:24`, `pq:118-129`) ve sektör yoktur, bu yüzden çekirdek dışı her alan "vurgu"dur (`pq:327-328`). Sonuç: **Çekirdek'te 1 kare = 0,25 seviye, öteki dört alanda 1 kare = 0,20 seviye.**
- **3★ karesi** (Çekirdek 0,40, vurgu 0,30, kalan 0,20) B2B sayfasında görünmez; hesap bağlamında (sektörlü) ve B2C'de kitle 10.000'den 50.000'e giderken görünür (`_audience_star` `pq:312-316`: 2★'tan 3★'a kitlenin logaritmasıyla doğrusal, kare 0,25'ten 0,40'a ve 0,20'den 0,30'a kayar).
- **Sektörle değişen yalnız hesap bağlamıdır.** Tablo `pq:48-62`'de 13 sektörün ilk iki alanı vurgu, üçüncüsü "kalan": kalan alan **9 sektörde Onboarding**, 2'sinde Entegrasyonlar, 2'sinde Güven & Ölçek. Kalan alana 2★ hesap hiç bakmaz (beklenti 0, `pq:353-354`'te 2★ satırı yok); 3★ hesap 1,0 bekler. Yani Onboarding'e yapılan derinlik, en yaygın sektörlerde 2★ hesabın uyumunu hiç oynatmaz.
- **Aralık:** kare 0,12 (1★ Çekirdek MVP hücresi, `sprint.json:5` 3 hat ÷ Çekirdek 5 hat = 0,6 beklenti) ile 0,40 (3★ Çekirdek) arasındadır; derinlik kartı K3'ten sonra geldiği için pratik aralık 2★: 0,20-0,25, 3★: 0,30-0,40.
- **Rakip artışı** (`rival_bump` 0,5, en çok 1,0; `pq:123-125`) yalnız aday ve ekonomi bağlamında beklentiyi büyütür; ekranın karesine girmez.

**Bir kademe adımı kaç kare** (kademe kartının karşılığı). Alan seviyesi hatların ortalamasıdır (`pq:96-104`), bu yüzden bir hattın bir kademesi alana 1 ÷ hat sayısı kadar katar. Hat sayıları: Çekirdek 5 kimlik hattı, Güven & Ölçek 2, Entegrasyonlar 1, Onboarding 1 (Ar-Ge gizli hattı açarsa 2) (`sprint.json:130-137`, `pl:40-41`).

| Alan (B2B) | Hat sayısı | Bir kademe adımı = alan seviyesi | = kare (2★ sayfa) | = kare (3★) | Tüm hatlar K1 / K2 / K3: kare (2★ sayfa) | aynı, 3★ |
|---|---|---|---|---|---|---|
| Çekirdek | 5 | 0,20 | 0,80 | 0,50 | 4 / 8 / 10 | 3 / 5 / 8 |
| Güven & Ölçek (Güvenlik + Dayanıklılık) | 2 | 0,50 | 2,50 | 1,67 | 5 / 10 / 10 | 3 / 7 / 10 |
| Entegrasyonlar | 1 | 1,00 | 5,00 | 3,33 | 5 / 10 / 10 | 3 / 7 / 10 |
| Onboarding & Erişim (mobil; gizli hat açılmamış) | 1 | 1,00 | 5,00 | 3,33 | 5 / 10 / 10 | 3 / 7 / 10 |

İki sonuç:
1. **Çubuk, çekirdek dışı alanlarda K2'de dolar.** 2★ sayfada Entegrasyonlar, Onboarding ve Güven & Ölçek hatları K2'ye gelince 10 karedir (oran 2,0 = çubuğun sonu); K3 bir kare daha göstermez. Çekirdek K2'de 8, K3'te 10 (12 çıkıyor, 10'a kesiliyor).
2. **PRD'nin örnek metni "Entegrasyonlar +1 kare (ilk karttan az)"** Entegrasyonlar K3 olduktan sonra (derinlik kartı ancak K3'ten sonra açılır) 2★ sayfada hiçbir zaman doğru olamaz: çubuk zaten 10/10.

## 3. B · g₀ adayları

**Birim:** g₀ Q'nun seviye biriminde (alan seviyesine eklenen sayı). k'inci kartın kazancı g₀ × 0,75^(k−1) (PRD Karar 13), birikmiş kazanç g₀ × (1 − 0,75^k) ÷ 0,25, sonsuzdaki tavan **4·g₀**. "k" alan başınadır: D_MODEL_v3'ün ve etki satırının ("bu alandaki ilk karttan az") dediği gibi aynı alanda biten kartlar sayılır, hat sayılmaz (dsim3'ün modeli de böyle: `depth_area`).

**Etki satırı kuralı (benim okumam, onay bekliyor).** PRD "kazanç bir kareden azsa 'ilk karttan az' der" ve örnek olarak "+1 kare (ilk karttan az)" veriyor. İkisini birlikte tutan okuma: N = ⌊kazanç ÷ kare⌋; N ≥ 1 ise "+N kare", alanın ilk kartından sonraki kartlarda "(ilk karttan az)" eki; N = 0 ise yalnız "ilk karttan az". Tablolarda `+N` = "+N kare", `+N~` = "+N kare (ilk karttan az)", `<` = "ilk karttan az". Kare birimi Q'nun `area_row`'undandır (2★ Çekirdek 0,25, 2★ diğer 0,20, 3★ Çekirdek 0,40, 3★ diğer 0,30).

Dört aday:
- **G1 = 0,125** (2★ Çekirdek'in yarım karesi).
- **G2 = 0,25** (2★ Çekirdek'in bir karesi; 4·g₀ = 1,0 seviye = bir alanın "bir kademesi").
- **G3 = 0,5** (iki kare; PRD'nin örnek okunuşuna yakın: ikinci kart "+1 kare (ilk karttan az)").
- **G4 = 0,2** (Çekirdek'te bir kademe adımı kadar; öteki 2★ alanlarda tam bir kare).

**G1 = 0,125**

| k | Kazanç (seviye) | Birikmiş (seviye) | 2★ Çekirdek: kare (etiket) | 2★ diğer: kare (etiket) | 3★ Çekirdek: kare (etiket) | 3★ diğer: kare (etiket) |
|---|---|---|---|---|---|---|
| 1 | 0,1250 | 0,125 | 0,50 (<) | 0,62 (<) | 0,31 (<) | 0,42 (<) |
| 2 | 0,0938 | 0,219 | 0,38 (<) | 0,47 (<) | 0,23 (<) | 0,31 (<) |
| 3 | 0,0703 | 0,289 | 0,28 (<) | 0,35 (<) | 0,18 (<) | 0,23 (<) |
| 4 | 0,0527 | 0,342 | 0,21 (<) | 0,26 (<) | 0,13 (<) | 0,18 (<) |
| 5 | 0,0396 | 0,381 | 0,16 (<) | 0,20 (<) | 0,10 (<) | 0,13 (<) |
| 6 | 0,0297 | 0,411 | 0,12 (<) | 0,15 (<) | 0,07 (<) | 0,10 (<) |
| 7 | 0,0222 | 0,433 | 0,09 (<) | 0,11 (<) | 0,06 (<) | 0,07 (<) |
| 8 | 0,0167 | 0,450 | 0,07 (<) | 0,08 (<) | 0,04 (<) | 0,06 (<) |
| 12 | 0,0053 | 0,484 | 0,02 (<) | 0,03 (<) | 0,01 (<) | 0,02 (<) |
| 20 | 0,0005 | 0,498 | 0,00 (<) | 0,00 (<) | 0,00 (<) | 0,00 (<) |

**G2 = 0,25**

| k | Kazanç (seviye) | Birikmiş (seviye) | 2★ Çekirdek: kare (etiket) | 2★ diğer: kare (etiket) | 3★ Çekirdek: kare (etiket) | 3★ diğer: kare (etiket) |
|---|---|---|---|---|---|---|
| 1 | 0,2500 | 0,250 | 1,00 (+1) | 1,25 (+1) | 0,62 (<) | 0,83 (<) |
| 2 | 0,1875 | 0,438 | 0,75 (<) | 0,94 (<) | 0,47 (<) | 0,62 (<) |
| 3 | 0,1406 | 0,578 | 0,56 (<) | 0,70 (<) | 0,35 (<) | 0,47 (<) |
| 4 | 0,1055 | 0,684 | 0,42 (<) | 0,53 (<) | 0,26 (<) | 0,35 (<) |
| 5 | 0,0791 | 0,763 | 0,32 (<) | 0,40 (<) | 0,20 (<) | 0,26 (<) |
| 6 | 0,0593 | 0,822 | 0,24 (<) | 0,30 (<) | 0,15 (<) | 0,20 (<) |
| 7 | 0,0445 | 0,867 | 0,18 (<) | 0,22 (<) | 0,11 (<) | 0,15 (<) |
| 8 | 0,0334 | 0,900 | 0,13 (<) | 0,17 (<) | 0,08 (<) | 0,11 (<) |
| 12 | 0,0106 | 0,968 | 0,04 (<) | 0,05 (<) | 0,03 (<) | 0,04 (<) |
| 20 | 0,0011 | 0,997 | 0,00 (<) | 0,01 (<) | 0,00 (<) | 0,00 (<) |

**G3 = 0,5**

| k | Kazanç (seviye) | Birikmiş (seviye) | 2★ Çekirdek: kare (etiket) | 2★ diğer: kare (etiket) | 3★ Çekirdek: kare (etiket) | 3★ diğer: kare (etiket) |
|---|---|---|---|---|---|---|
| 1 | 0,5000 | 0,500 | 2,00 (+2) | 2,50 (+2) | 1,25 (+1) | 1,67 (+1) |
| 2 | 0,3750 | 0,875 | 1,50 (+1~) | 1,88 (+1~) | 0,94 (<) | 1,25 (+1~) |
| 3 | 0,2812 | 1,156 | 1,12 (+1~) | 1,41 (+1~) | 0,70 (<) | 0,94 (<) |
| 4 | 0,2109 | 1,367 | 0,84 (<) | 1,05 (+1~) | 0,53 (<) | 0,70 (<) |
| 5 | 0,1582 | 1,525 | 0,63 (<) | 0,79 (<) | 0,40 (<) | 0,53 (<) |
| 6 | 0,1187 | 1,644 | 0,47 (<) | 0,59 (<) | 0,30 (<) | 0,40 (<) |
| 7 | 0,0890 | 1,733 | 0,36 (<) | 0,44 (<) | 0,22 (<) | 0,30 (<) |
| 8 | 0,0667 | 1,800 | 0,27 (<) | 0,33 (<) | 0,17 (<) | 0,22 (<) |
| 12 | 0,0211 | 1,937 | 0,08 (<) | 0,11 (<) | 0,05 (<) | 0,07 (<) |
| 20 | 0,0021 | 1,994 | 0,01 (<) | 0,01 (<) | 0,01 (<) | 0,01 (<) |

**G4 = 0,2**

| k | Kazanç (seviye) | Birikmiş (seviye) | 2★ Çekirdek: kare (etiket) | 2★ diğer: kare (etiket) | 3★ Çekirdek: kare (etiket) | 3★ diğer: kare (etiket) |
|---|---|---|---|---|---|---|
| 1 | 0,2000 | 0,200 | 0,80 (<) | 1,00 (+1) | 0,50 (<) | 0,67 (<) |
| 2 | 0,1500 | 0,350 | 0,60 (<) | 0,75 (<) | 0,38 (<) | 0,50 (<) |
| 3 | 0,1125 | 0,463 | 0,45 (<) | 0,56 (<) | 0,28 (<) | 0,38 (<) |
| 4 | 0,0844 | 0,547 | 0,34 (<) | 0,42 (<) | 0,21 (<) | 0,28 (<) |
| 5 | 0,0633 | 0,610 | 0,25 (<) | 0,32 (<) | 0,16 (<) | 0,21 (<) |
| 6 | 0,0475 | 0,658 | 0,19 (<) | 0,24 (<) | 0,12 (<) | 0,16 (<) |
| 7 | 0,0356 | 0,693 | 0,14 (<) | 0,18 (<) | 0,09 (<) | 0,12 (<) |
| 8 | 0,0267 | 0,720 | 0,11 (<) | 0,13 (<) | 0,07 (<) | 0,09 (<) |
| 12 | 0,0084 | 0,775 | 0,03 (<) | 0,04 (<) | 0,02 (<) | 0,03 (<) |
| 20 | 0,0008 | 0,797 | 0,00 (<) | 0,00 (<) | 0,00 (<) | 0,00 (<) |

**Kazancın bir karenin altına indiği ilk kart** ve tavan:

| Aday | 1 karenin altına inen ilk k: 2★ Çekirdek | 1 karenin altına inen ilk k: 2★ diğer | 1 karenin altına inen ilk k: 3★ Çekirdek | 1 karenin altına inen ilk k: 3★ diğer | Sonsuzdaki tavan 4·g₀ (seviye) | = kare (2★ Çekirdek) |
|---|---|---|---|---|---|---|
| G1 · yarım kare · 0,125 seviye | ilk kartta zaten altında | ilk kartta zaten altında | ilk kartta zaten altında | ilk kartta zaten altında | 0,50 | 2,0 |
| G2 · bir kare · 0,250 seviye | 2 | 2 | ilk kartta zaten altında | ilk kartta zaten altında | 1,00 | 4,0 |
| G3 · iki kare · 0,500 seviye | 4 | 5 | 2 | 3 | 2,00 | 8,0 |
| G4 · bir Çekirdek kademe adımı · 0,200 seviye | ilk kartta zaten altında | 2 | ilk kartta zaten altında | ilk kartta zaten altında | 0,80 | 3,2 |

Okuma:
- G1 ve G4, Çekirdek'te **ilk kartta bile** bir karenin altında: ilk kart "ilk karttan az" yazar, yanlış etiket. G2 ilk kartta tam 1 kare (2★ Çekirdek) ve 1,25 kare (2★ diğer); ikinci karttan beri "<". G3 üç (Çekirdek) ya da dört (öteki alanlar) karta kadar sayı yazar.
- **Hiçbir aday 3★ sayfada ilk kartta 1 kare vermez, G3 hariç.** G2'nin 3★ Çekirdek ilk kartı 0,62 kare. 3★ ekranı yalnız B2C'de büyük kitlede ve hesap bağlamında olduğu için bu kabul edilebilir (§5).
- Kare yuvarlaması: `area_row` karesi `roundi` ile yuvarlanır ve çubuk 10'da durur. Etki satırı `area_row` farkından yazılırsa (önce/sonra), sayı kazancın ⌊⌋'ünden sapar. Örnek, G2, Çekirdek K2'de (seviye 2,0, 8 kare):

| k | Kazanç (seviye) | Kazanç (kare) | area_row kare önce | sonra | fark |
|---|---|---|---|---|---|
| 1 | 0,2500 | 1,00 | 8 | 9 | 1 |
| 2 | 0,1875 | 0,75 | 9 | 10 | 1 |
| 3 | 0,1406 | 0,56 | 10 | 10 | 0 |
| 4 | 0,1055 | 0,42 | 10 | 10 | 0 |
| 5 | 0,0791 | 0,32 | 10 | 10 | 0 |

  Üçüncü karttan beri çubuk 10'da doymuş: kazanç 0,56 kare ama çubuk değişmiyor. Satırı kazançtan (⌊kazanç ÷ kare⌋) yazmak ya da çubuk doyunca "bu alan çubuğun sonunda" demek gerekir (§7 madde 5).

**Bir kartın ürün uyumuna (U) etkisi** (kesik ve `CORE_LEAD` tavanı devrede değilken; `fit_from_levels` `pq:268-297`, `FIT_SCALE` 70 `pq:12`, ağırlıklar `pq:16-18`; ΔU = 70 × ağırlık ÷ ağırlık toplamı × Δseviye ÷ beklenti, 2★ hesapta toplam 0,90 çünkü kalan alana bakılmaz, 3★'ta 1,00):

| Rol | Ağırlık | ΔU / seviye (2★ hesap) | ΔU / seviye (3★ hesap) | İlk kart G1 (2★ / 3★) | G2 | G3 | G4 |
|---|---|---|---|---|---|---|---|
| Çekirdek | 0,50 | 31,1 | 17,5 | 3,9 / 2,2 | 7,8 / 4,4 | 15,6 / 8,8 | 6,2 / 3,5 |
| Vurgu 1 | 0,25 | 19,4 | 11,7 | 2,4 / 1,5 | 4,9 / 2,9 | 9,7 / 5,8 | 3,9 / 2,3 |
| Vurgu 2 | 0,15 | 11,7 | 7,0 | 1,5 / 0,9 | 2,9 / 1,8 | 5,8 / 3,5 | 2,3 / 1,4 |
| Kalan | 0,10 | — | 7,0 | — / 0,9 | — / 1,8 | — / 3,5 | — / 1,4 |

Karşılaştırma için kademe adımı (aynı hesapla):

| Alan | Bir kademe adımı (seviye) | ΔU (2★ hesap) | ΔU (3★ hesap) |
|---|---|---|---|
| Çekirdek (5 hat) | 0,20 | 6,2 | 3,5 |
| Güven & Ölçek (2 hat) · vurgu 1 | 0,50 | 9,7 | 5,8 |
| Tek hatlı alan · vurgu 1 | 1,00 | 19,4 | 11,7 |

G2'nin ilk kartı Çekirdek'te 7,8 U puanı eder, bir Çekirdek kademe adımı 6,2: ilk derinlik kartı bir Çekirdek kademe kartından %25 fazla değer katar. G3 15,6 (2,5 kademe adımı) ile derinliği kademenin önüne geçirir. G4 tam bir kademe adımına eşit (6,2), G1 altında (3,9). Güven & Ölçek ve tek hatlı alanlarda kademe adımı (9,7 ve 19,4) G3 hariç her adayın ilk kartından büyüktür (G3'te vurgu 1 alanında eşit, 9,7).

## 4. C · Oran kesiği (1,5) ve derinlik kartı tüketimi

### 4.1 Kesik hangi yıldızın beklentisine göre (koddan)
`RATIO_CAP` yıldızsız bir sabittir: `_ratio(seviye, beklenti) = min(seviye ÷ beklenti, 1,5)` (`pq:380-381`). Hangi yıldız olduğu, çağıranın verdiği beklentiden gelir. Kodda üç okuyucu var ve üçü farklı:
- **Ürün uyumu U:** hesabın ya da adayın kendi yıldızı ve sektörü (`fit_from_levels` `pq:271-282`, `_ref` `pq:364-370`). Kesik müşteri başınadır.
- **Ekran (`area_row`):** sayfa referansı, B2B'de 2★; soluk kareler 8'den başlar (`pq:194-201`).
- **`next_ratio` (lider önerisi, çeyrek şeridi):** kesiksizdir ve sıradaki yıldıza bakar (`pq:172-174`); `next_star` bir alan 1★ ya da 2★ beklentisinin altındaysa o yıldızı, hepsi karşılanmışsa 3'ü döner (`pq:163-168`).

PRD Karar 13 "kesiğe varmış alanda kart önerilmez" derken hangisini kastettiğini yazmıyor (E madde 4). İki sınır hesapladım: **2★ sayfa** (oyuncunun gördüğü soluk kareler; en dar kesik) ve **3★** (en geniş kesik; derinlik kartı K3'ten sonra açıldığı için o ana kadar her alan 2★'ı karşılamıştır ve `next_star` zaten 3'tür). Kesiğin seviye karşılığı:

| Alan | 2★ beklenti | 2★ kesik seviyesi (1,5×) | 3★ beklenti | 3★ kesik seviyesi (1,5×) | Tüm hatlar K3: oran 2★ | oran 3★ | K3 bitince iki yıldızda da kesikte mi |
|---|---|---|---|---|---|---|---|
| Çekirdek | 1,25 | 1,875 | 2,00 | 3,000 | 2,40 | 1,50 | evet |
| Güven & Ölçek (Güvenlik + Dayanıklılık) | 1,00 | 1,500 | 1,50 | 2,250 | 3,00 | 2,00 | evet |
| Entegrasyonlar | 1,00 | 1,500 | 1,50 | 2,250 | 3,00 | 2,00 | evet |
| Onboarding & Erişim (mobil; gizli hat açılmamış) | 1,00 | 1,500 | 1,50 | 2,250 | 3,00 | 2,00 | evet |

**Bulgu: K3'ü bitmiş her alan, iki yıldızda da kesiktedir.** Bir hattın K3'ü 3,0 verir (`pq:102-103`, `TIER_MAX` `pl:20`); kesiğe en yakın durum 3★ Çekirdek, tam 1,50. Yani Karar 13'ün iki cümlesi ("K3'ü biten hatta aç" ve "kesiğe varmış alanda önerme") Q'nun bugünkü sayılarıyla birlikte tutmuyor: derinlik kartının açıldığı an çoğu durumda kesiğin de geçildiği andır.

### 4.2 Kesiğe kaç kartta varılır
Tipik alan "K3'ü bitmiş hatlar" ise cevap **0 kart**: alan zaten kesikte. Kart yalnız alanın bazı hatları K3, bazıları geride iken açılabilir. Taban seviye = hatların kademe ortalaması. Cila 0 alındı: cila kartı üretilmez, sayacı yalnız kayıt göçü doldurur (ACIK 96), ve K3 hatta zaten 3,0'a kırpılır, yani cila bu tablolarda hiçbir şeyi oynatmaz. Hücre: "2★ kesik / 3★ kesik" için kesiğe kaç kartla varıldığı; `0·K` = alan zaten kesikte, kart açılmaz; `hiç` = 4·g₀ boşluğu kapatmaz, kesiğe hiç varılmaz (kartlar sürekli gelir):

| Alan | Durum | Taban seviye | G1: 2★ / 3★ kesik | G2: 2★ / 3★ kesik | G3: 2★ / 3★ kesik | G4: 2★ / 3★ kesik |
|---|---|---|---|---|---|---|
| Çekirdek | 1 hat K3, 4 hat K1 | 1,40 | 11 / hiç | 3 / hiç | 1 / 6 | 4 / hiç |
| Çekirdek | 2 hat K3, 3 hat K1 | 1,80 | 1 / hiç | 1 / hiç | 1 / 4 | 1 / hiç |
| Çekirdek | 1 hat K3, 4 hat K2 | 2,20 | 0·K / hiç | 0·K / 6 | 0·K / 2 | 0·K / hiç |
| Çekirdek | 3 hat K3, 2 hat K1 | 2,20 | 0·K / hiç | 0·K / 6 | 0·K / 2 | 0·K / hiç |
| Çekirdek | 3 hat K3, 2 hat K2 | 2,60 | 0·K / 6 | 0·K / 2 | 0·K / 1 | 0·K / 3 |
| Çekirdek | 4 hat K3, 1 hat K2 | 2,80 | 0·K / 2 | 0·K / 1 | 0·K / 1 | 0·K / 1 |
| Çekirdek | 4 hat K3, 1 hat K1 | 2,60 | 0·K / 6 | 0·K / 2 | 0·K / 1 | 0·K / 3 |
| Çekirdek | 5 hat K3 | 3,00 | 0·K / 0·K | 0·K / 0·K | 0·K / 0·K | 0·K / 0·K |
| Güven & Ölçek | 1 hat K3, 1 hat boş | 1,50 | 0·K / hiç | 0·K / 5 | 0·K / 2 | 0·K / 10 |
| Güven & Ölçek | 1 hat K3, 1 hat K1 | 2,00 | 0·K / 3 | 0·K / 1 | 0·K / 1 | 0·K / 2 |
| Güven & Ölçek | 1 hat K3, 1 hat K2 | 2,50 | 0·K / 0·K | 0·K / 0·K | 0·K / 0·K | 0·K / 0·K |
| Güven & Ölçek | 2 hat K3 | 3,00 | 0·K / 0·K | 0·K / 0·K | 0·K / 0·K | 0·K / 0·K |
| Entegrasyonlar | hat K3 | 3,00 | 0·K / 0·K | 0·K / 0·K | 0·K / 0·K | 0·K / 0·K |

Okuma (G2 = 0,25 için):
- **2★ kesikte Çekirdek**, kademe toplamı 9'a kadar kart alır (5 hattın ortalaması 1,875'in altında): 1 hat K3 + 4 hat K1'de (toplam 7) 3 kart, 2 hat K3 + 3 hat K1'de (toplam 9) 1 kart. Toplam 10 olunca (ör. 1 hat K3 + 4 hat K2) kesiktir. Güven & Ölçek, Entegrasyonlar ve Onboarding'de 2★ kesik, ilk K3 ortaya çıktığı anda doludur (Güven & Ölçek'te 1 hat K3 + 1 hat boş bile 1,5).
- **3★ kesikte** yalnız Çekirdek ve yarım kalmış Güven & Ölçek kart alır: 1 hat K3 + 4 hat K2'de 6 kart, 3 hat K3 + 2 hat K2'de 2 kart; tek hatlı alanlar hiç.
- **Kesiğe varış hızı g₀ ile ters orantılı:** aynı iki 3★ durumda G3 (0,5) 2 ve 1 kartta, G1 (0,125) hiç ve 6 kartta varır.
- **Her alanın bütün hatları K3 olunca** (kimlik hattı sayısı ne olursa olsun) kart kalmaz.

### 4.3 Kesik tüketimi sınırlar mı: dsim3 ile
**D0s kesiği modellemedi.** `dsim3.py` derinlik kartını yalnız hat K3 ve hattın açık kartı 1 + ⌊hesap ÷ 5⌋'in altındayken açar (`_issue` `:1195-1212`); kazanç yalnız önerideki etkiyi (`_impact` `:1423-1429`) ve "en zayıf alan"ı (`_weak_area` `:1431-1436`) oynatır; alan seviyesi, kesik ya da seri tavanı yoktur. D0s'un hat başına 13 / 25 / 47 / 102 / 178 sayıları (3 / 6 / 12 / 25 / 50 kişi) bu yüzden **kesiksiz** tüketimdir. `orig` kolu bunları yeniden üretti (§1). "Gerçek alan eşlemesi" kolu hatları gerçek alanlara koyar (Çekirdek 5 hat, Onboarding 1, Entegrasyonlar 1, Güven & Ölçek 2; `sprint.json:130-137`); ürün başına toplam aynı kalır ama tek hatlı alanlar tüm yükü tek hatta alır:

| Ekip | Okuma | Tohum | Hat başına açılan kart: medyan hat | en çok kullanılan hat | Ürün başına açılan (9 hat) | Ürün başına biten | Biten kartların 11/alan (%95 serisi) ötesindeki payı |
|---|---|---|---|---|---|---|---|
| 1 | D0s taban | 20 | 0,0 | 10,0 | 29 | 5 | 0% |
| 1 | gerçek alan eşlemesi | 20 | 0,0 | 11,0 | 29 | 4 | 0% |
| 3 | D0s taban | 20 | 13,0 | 16,0 | 116 | 48 | 9% |
| 3 | gerçek alan eşlemesi | 20 | 12,0 | 18,0 | 115 | 45 | 2% |
| 6 | D0s taban | 20 | 25,0 | 28,0 | 220 | 151 | 71% |
| 6 | gerçek alan eşlemesi | 20 | 16,0 | 41,5 | 206 | 136 | 68% |
| 12 | D0s taban | 20 | 47,0 | 52,0 | 400 | 332 | 87% |
| 12 | gerçek alan eşlemesi | 20 | 25,5 | 87,5 | 387 | 322 | 86% |
| 25 | D0s taban | 20 | 102,0 | 115,0 | 863 | 808 | 95% |
| 25 | gerçek alan eşlemesi | 20 | 53,0 | 170,0 | 792 | 738 | 94% |
| 50 | D0s taban | 20 | 178,0 | 192,5 | 1472 | 1432 | 97% |
| 50 | gerçek alan eşlemesi | 20 | 159,5 | 199,5 | 1477 | 1438 | 97% |

| Ekip | Çekirdek (hat başına ortalama açılan) | Onboarding (hat başına ortalama açılan) | Entegrasyonlar (hat başına ortalama açılan) | Güven & Ölçek (hat başına ortalama açılan) |
|---|---|---|---|---|
| 1 | 2 | 9 | 8 | 0 |
| 3 | 11 | 18 | 16 | 13 |
| 6 | 15 | 41 | 40 | 24 |
| 12 | 24 | 86 | 87 | 48 |
| 25 | 48 | 168 | 170 | 107 |
| 50 | 147 | 200 | 199 | 175 |

**Teslim puanı kimden geliyor** (D0s taban, 104 hafta): derinlik kartı 6 kişide %65, 12 kişide %82, 25 kişide %92, 50 kişide %96. Kademe kartı en çok 720 puandır (27 kart).

| Ekip | Kademe kartı puanı (27 kart) | İstek kartı puanı | Derinlik kartı puanı | Derinlik payı (teslim puanı) |
|---|---|---|---|---|
| 1 | 480 | 40 | 75 | 13% |
| 3 | 720 | 640 | 832 | 38% |
| 6 | 720 | 960 | 3155 | 65% |
| 12 | 720 | 1020 | 8052 | 82% |
| 25 | 720 | 1100 | 21190 | 92% |
| 50 | 720 | 1040 | 37912 | 96% |

**Kesik ve seri tavanı eklenmiş koşular.** 20 tohum, 104 hafta, kaynaklı arz, medyan. `kesik 2★` ve `kesik 3★`: alanın seviyesi (kademe ortalaması + g₀ × (1 − 0,75^n) ÷ 0,25) beklentisinin 1,5 katına varınca o alanın derinlik kartı açılmaz ve açık planlanmamış olanlar çekilir; her kesik kolu üç g₀ ile koşuldu (0,125 / 0,25 / 0,5). `seri tavanı N`: kesik yok, ama alan başına en çok N derinlik kartı (N = 8 serinin %90'ına, 9 = %90'ın hemen üstüne, 11 = %95,8'ine, 17 = %99'a karşılık gelir).

| Varyant (ürün başına açılan derinlik kartı, medyan) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| D0s taban | 29 | 116 | 220 | 400 | 863 | 1472 |
| taban, gerçek alan | 29 | 115 | 206 | 387 | 792 | 1477 |
| kesik 2★ · g₀ 0,125 | 0 | 0 | 0 | 0 | 0 | 0 |
| kesik 2★ · g₀ 0,25 | 0 | 0 | 0 | 0 | 0 | 0 |
| kesik 2★ · g₀ 0,5 | 0 | 0 | 0 | 0 | 0 | 0 |
| kesik 3★ · g₀ 0,125 | 20 | 19 | 6 | 8 | 2 | 4 |
| kesik 3★ · g₀ 0,25 | 12 | 10 | 5 | 3 | 2 | 4 |
| kesik 3★ · g₀ 0,5 | 9 | 8 | 5 | 2 | 2 | 4 |
| seri tavanı 8/alan | 24 | 32 | 32 | 32 | 32 | 32 |
| seri tavanı 9/alan | 26 | 36 | 36 | 36 | 36 | 36 |
| seri tavanı 11/alan | 28 | 44 | 44 | 44 | 44 | 44 |
| seri tavanı 17/alan | 29 | 66 | 68 | 68 | 68 | 68 |

| Varyant (teslim, puan/hf, 21-104. hafta medyanı) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| D0s taban | 5,6 | 21,2 | 47,6 | 99,7 | 242,7 | 432,6 |
| taban, gerçek alan | 5,5 | 20,6 | 45,2 | 97,2 | 217,8 | 434,9 |
| kesik 2★ · g₀ 0,125 | 5,5 | 12,1 | 12,4 | 13,3 | 14,0 | 14,0 |
| kesik 2★ · g₀ 0,25 | 5,5 | 12,1 | 12,4 | 13,3 | 14,0 | 14,0 |
| kesik 2★ · g₀ 0,5 | 5,5 | 12,1 | 12,4 | 13,3 | 14,0 | 14,0 |
| kesik 3★ · g₀ 0,125 | 5,3 | 13,1 | 12,4 | 13,3 | 14,0 | 14,0 |
| kesik 3★ · g₀ 0,25 | 5,4 | 12,9 | 12,4 | 13,3 | 14,0 | 14,0 |
| kesik 3★ · g₀ 0,5 | 5,4 | 12,7 | 12,4 | 13,6 | 14,0 | 14,0 |
| seri tavanı 8/alan | 5,4 | 19,7 | 20,6 | 15,1 | 14,0 | 14,0 |
| seri tavanı 9/alan | 5,4 | 20,0 | 22,1 | 16,5 | 14,0 | 14,0 |
| seri tavanı 11/alan | 5,5 | 20,1 | 24,0 | 18,5 | 14,0 | 14,0 |
| seri tavanı 17/alan | 5,5 | 20,6 | 31,5 | 25,8 | 16,7 | 15,1 |

| Varyant (boşta payı) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| D0s taban | 7% | 14% | 13% | 13% | 8% | 15% |
| taban, gerçek alan | 9% | 16% | 17% | 15% | 13% | 14% |
| kesik 2★ · g₀ 0,125 | 10% | 49% | 74% | 88% | 95% | 98% |
| kesik 2★ · g₀ 0,25 | 10% | 49% | 74% | 88% | 95% | 98% |
| kesik 2★ · g₀ 0,5 | 10% | 49% | 74% | 88% | 95% | 98% |
| kesik 3★ · g₀ 0,125 | 9% | 44% | 74% | 88% | 95% | 98% |
| kesik 3★ · g₀ 0,25 | 9% | 45% | 74% | 88% | 95% | 98% |
| kesik 3★ · g₀ 0,5 | 9% | 44% | 75% | 88% | 95% | 98% |
| seri tavanı 8/alan | 9% | 19% | 62% | 88% | 95% | 98% |
| seri tavanı 9/alan | 9% | 19% | 59% | 87% | 95% | 98% |
| seri tavanı 11/alan | 8% | 17% | 56% | 85% | 95% | 98% |
| seri tavanı 17/alan | 9% | 16% | 43% | 80% | 94% | 98% |

Zamanlama (sprint = 2 hafta, 0'dan sayılır; "kesiksiz" `map` kolu, Çekirdek):

| Ekip | İlk hat K3 (sprint) | Dokuz hat da K3 (sprint) | Kesiksiz: Çekirdek'te ilk derinlik kartı | 2★ kesik: Çekirdek kesiğe varış | 2★ kesik: ilk derinlik kartı | 3★ kesik (g₀ 0,25): Çekirdek kesiğe varış | 3★ kesik: ilk derinlik kartı |
|---|---|---|---|---|---|---|---|
| 1 | 34 | — | 34 | 28 | — | — | 32 |
| 3 | 9 | 31 | 9 | 8 | — | 12 | 9 |
| 6 | 6 | 12 | 6 | 4 | — | 7 | 6 |
| 12 | 4 | 7 | 4 | 4 | — | 5 | 4 |
| 25 | 3 | 5 | 3 | 3 | — | 4 | 3 |
| 50 | 3 | 4 | 3 | 2 | — | 4 | 3 |

Okuma:
1. **2★ kesikte derinlik kartı hiç açılmaz** (0 kart, her ekipte, her g₀'da): Çekirdek'in kesiği (seviye 1,875) beş hattın K2'ye varmasıyla dolar, yani ilk K3'ten önce ya da aynı sprintte. **3★ kesikte** ürün başına 2-20 kart açılır, hepsi Çekirdek'te (g₀ 0,125'te 1 kişide 20, 3 kişide 19; 0,25'te 12 ve 10; ≥ 6 kişide 2-8). Kesik tüketimi hat başına **0-12 karta** indirir (1 kişide 12, ≥ 6 kişide ≤ 3).
2. **Bedeli arzdır.** Derinlik kartı kalkınca 6 kişi ve üstü ekip yalnız 27 kademe kartıyla ve 3★ hesapların isteğiyle (104 haftada ~37 istek kartı) kalır. Teslim D0s tabanına göre 3 kişide −%43 (21,2 → 12,1), 6 kişide −%74 (47,6 → 12,4), 12 kişide −%87 (99,7 → 13,3), 25 kişide −%94 (242,7 → 14,0), 50 kişide −%97 (432,6 → 14,0); boşta payı %49, 74, 88, 95, 98. Planlanacak kart kalmayan sprint payı 12 kişide %42, 25 ve 50 kişide %50. Bu, PRD Karar 13'ün dayandığı "arz kapısı tutuyor" sonucunu (OYNANIS_HUKMU #17, D_SIM_v3 §11) geçersiz kılar: o sonuç derinlik kartının kesiksiz açılmasına dayanıyordu.
3. **Seri tavanı da çare değil.** Alan başına 8-17 karta bağlamak (kesikten bağımsız) 6 kişide teslimi 20,6-31,5'e (−%57…−%34), 12 kişide 15,1-25,8'e (−%85…−%74), 25 ve 50 kişide 14,0-16,7'ye indirir. 12 kişide 17 kartlık (%99) seri bile D0s teslimin dörtte biridir.
4. **Neden:** D0s'un derinlik kartı tüketimi (6 kişide 220, 12 kişide 400, 25 kişide 863, 50 kişide 1.472 kart/ürün) serinin değerli kısmının (alan başına 9-11 kart, ürün başına 36-44) çok ötesindedir. Kesiksiz koşuda biten kartların **%71'i (6 kişi), %87'si (12 kişi), %95'i (25 kişi), %97'si (50 kişi)** 11. kartın ötesindedir, yani her biri g₀'ın %5,6'sından azını katar (tablo C3; "gerçek alan" kolunda %68, 86, 94, 97). **Bu pay g₀'a bağlı değildir.**
5. **1 kişi.** İlk K3 sprint 34'te (yaklaşık 68. hafta); 104 haftada ürün başına 4-5 derinlik kartı biter (3,5'i Çekirdek'te, 1'i Onboarding'de). Derinlik burada teslim puanının %13'ü; "kademe yeter" (PRD) doğru.

Seri tablosu (g₀'dan bağımsız; k = alanda biten kart):

| k. kart | Kazancı g₀'ın yüzdesi | Birikmiş (tavan 4·g₀'ın yüzdesi) | G2'de kazanç (2★ Çekirdek kare) |
|---|---|---|---|
| 1 | 100,0% | 25,0% | 1,000 |
| 2 | 75,0% | 43,8% | 0,750 |
| 3 | 56,2% | 57,8% | 0,562 |
| 5 | 31,6% | 76,3% | 0,316 |
| 8 | 13,3% | 90,0% | 0,133 |
| 11 | 5,6% | 95,8% | 0,056 |
| 15 | 1,8% | 98,7% | 0,018 |
| 20 | 0,4% | 99,7% | 0,004 |
| 30 | 0,0% | 100,0% | 0,000 |
| 50 | 0,0% | 100,0% | 0,000 |
| 100 | 0,0% | 100,0% | 0,000 |
| 177 | 0,0% | 100,0% | 0,000 |

| Tavanın payı | Gereken kart sayısı (alan başına) |
|---|---|
| 80% | 6 |
| 90% | 9 |
| 95% | 11 |
| 99% | 17 |

**Sınır.** Simülasyon kademeleri dsim3'ün zinciriyle, genişlik önce ilerletir ve kapıları (Ar-Ge düğümü, yıldız) bilmez; hepsi K2 olmadan hiçbir hat K3 olmaz. Kapılı oyunda bir ya da iki hat erken K3 olabilir; o durumda 2★ kesikte bile alan başına 1-3 kart çıkar (tablo C2x, G2). Bu "0 kart" sonucunu yumuşatır ama arz sonucunu değiştirmez (en çok 3 kart/alan). Cila yoktur (ACIK 96).

### 4.4 162 ad yeter mi
Adlar hat başınadır, kazanç alan başına: **ürün başına 74-78 ad** vardır (9 hat = 5 kimlik + 4 ortak), hat başına 8-9; Onboarding ve Entegrasyonlar tek hattır ve 8'er adı vardır:

| Ürün | Kimlik hattı | Çekirdek adları | Hat başına | Mobil (Onboarding) | Entegrasyonlar | Güven & Ölçek (2 hat) | Ürün toplamı (9 hat) |
|---|---|---|---|---|---|---|---|
| erp | 5 | 43 | 8-9 | 8 | 8 | 17 | 76 |
| note_tool | 5 | 41 | 8-9 | 8 | 8 | 17 | 74 |
| video_clip | 5 | 45 | 9-9 | 8 | 8 | 17 | 78 |

Hat başına en çok kullanılan hattaki kart sayısı (medyan), 6'yı ve 8'i aşan hat sayısı (9 hattan; 8 = yazılı en az ad). Not: sim hat sırası Çekirdek 0-4, Onboarding 5, Entegrasyonlar 6, Güven & Ölçek 7-8:

| Varyant (en kullanılan hattaki kart · 6'yı aşan hat sayısı · 8'i aşan hat sayısı, medyan, 9 hat) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| D0s taban | 10 · >6: 3 · >8: 3 | 16 · >6: 9 · >8: 9 | 28 · >6: 9 · >8: 9 | 52 · >6: 9 · >8: 9 | 115 · >6: 9 · >8: 9 | 192 · >6: 9 · >8: 9 |
| taban, gerçek alan | 11 · >6: 3 · >8: 2 | 18 · >6: 9 · >8: 8 | 42 · >6: 9 · >8: 9 | 88 · >6: 9 · >8: 9 | 170 · >6: 9 · >8: 9 | 200 · >6: 9 · >8: 9 |
| kesik 2★ · g₀ 0,125 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 |
| kesik 2★ · g₀ 0,25 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 |
| kesik 2★ · g₀ 0,5 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 | 0 · >6: 0 · >8: 0 |
| kesik 3★ · g₀ 0,125 | 12 · >6: 2 · >8: 1 | 9 · >6: 2 · >8: 1 | 3 · >6: 0 · >8: 0 | 3 · >6: 0 · >8: 0 | 1 · >6: 0 · >8: 0 | 2 · >6: 0 · >8: 0 |
| kesik 3★ · g₀ 0,25 | 12 · >6: 1 · >8: 1 | 6 · >6: 0 · >8: 0 | 3 · >6: 0 · >8: 0 | 2 · >6: 0 · >8: 0 | 1 · >6: 0 · >8: 0 | 2 · >6: 0 · >8: 0 |
| kesik 3★ · g₀ 0,5 | 9 · >6: 1 · >8: 1 | 5 · >6: 0 · >8: 0 | 2 · >6: 0 · >8: 0 | 2 · >6: 0 · >8: 0 | 1 · >6: 0 · >8: 0 | 2 · >6: 0 · >8: 0 |
| seri tavanı 8/alan | 8 · >6: 3 · >8: 0 | 8 · >6: 3 · >8: 0 | 8 · >6: 2 · >8: 0 | 8 · >6: 2 · >8: 0 | 8 · >6: 2 · >8: 0 | 8 · >6: 2 · >8: 0 |
| seri tavanı 9/alan | 9 · >6: 3 · >8: 2 | 9 · >6: 3 · >8: 3 | 9 · >6: 2 · >8: 2 | 9 · >6: 2 · >8: 2 | 9 · >6: 2 · >8: 2 | 9 · >6: 2 · >8: 2 |
| seri tavanı 11/alan | 11 · >6: 3 · >8: 2 | 11 · >6: 4 · >8: 3 | 11 · >6: 3 · >8: 2 | 11 · >6: 3 · >8: 2 | 11 · >6: 2 · >8: 2 | 11 · >6: 3 · >8: 2 |
| seri tavanı 17/alan | 11 · >6: 3 · >8: 2 | 17 · >6: 5 · >8: 4 | 17 · >6: 4 · >8: 3 | 17 · >6: 4 · >8: 3 | 17 · >6: 4 · >8: 3 | 17 · >6: 4 · >8: 3 |

- **Kesiksiz (D0s):** 3 kişide bile en çok kullanılan hat 16-18, 12 kişide 52-88, 50 kişide 192-200 kart; 9 hattın 9'u 8 adı aşar. **162 ad (hat başına 8,5) 3 kişiden itibaren yetmez**, "hat başına 6" tek kurucudan başka kimseye yetmez. Gerçek alan eşlemesinde yük tek hatlı iki alana biner (hat başına 86-87 kart 12 kişide).
- **Kesik (Q'nun sayılarıyla):** hat başına en çok 0-12 kart. 2★ kesikte hiç kart yok. 3★ kesikte ≥ 6 kişide hiçbir hat 3'ü geçmez; 3 kişide en çok 9 (g₀ 0,125), 6 (0,25), 5 (0,5); 1 kişide 12 kart tek bir Çekirdek hattında toplanabilir (>8: 1 hat). **162 ad fazlasıyla yeter; 6 ad da ≥ 3 kişide yeter.** Ama bu yetmek, §4.3'teki arz çöküşünün sonucudur.
- **Seri tavanı (arzı kısmen koruyan okuma; teslim için §4.3):** alan başına N kart. **N = 8**: ürün başına 24-32 kart, hiçbir hat 8'i geçmez (tek hatlı iki alan tam 8 adı kullanır): **162 ad yeter**. **N = 9**: 2-3 hat 9. adı ister (Onboarding ve Entegrasyonlar 8 ad yazılı). **N = 11**: tek hatlı iki alanda 3'er ad eksik. **N = 17**: tek hatlı iki alanda 9'ar ad eksik; Güven & Ölçek'in iki hattı 10 ve 7 kart alır. Çekirdek'te yük beş hatta bölünür: N = 17'de hat başına 2,5-5 kart (12 kişi), 2-4 kart (50 kişi).
- Yani E1'deki "hat başına 6 ad yetmez" sorusu kesikle değil, **hangi tavanın seçildiğiyle** cevap bulur: tavan yoksa 162 ad yetmez; Q'nun kesiği olduğu gibi uygulanırsa ad gerekmez ama arz da yoktur; alan başına tavan 8 ise yeter, 9 ve üstünde tek hatlı iki alanın adı çoğaltılmalıdır.

## 5. D · Öneri

**Önerilen: g₀ = 0,25 seviye (G2). Onay bekliyor.** Bu, Q'nun 2★ Çekirdek karesidir (`CORE_2` 1,25 ÷ 5, `pq:37`); 4·g₀ = 1,0 seviye, yani bir alanın bütün derinlik kartları birleşince alan seviyesi bir kademe kadar yükselir (Çekirdek'te beş hattın birer kademesi, tek hatlı alanda hattın bir kademesi). Kod yeri: `ProductQuality.level` sonuna alan başına derinlik kazancı eklenir (E madde 2); k'inci kartın kazancı `0,25 × 0,75^(k−1)`.

Gerekçe:
1. **Oyuncu okunuşu.** 2★ sayfada ilk kart her alanda en az bir kare yazar (Çekirdek 1,00; öteki alanlar 1,25): "+1 kare". İkinci karttan sonra bir karenin altında: "ilk karttan az". G1 ve G4 Çekirdek'te ilk kartı bir karenin altında bırakır, yani ilk karta "ilk karttan az" yazdırır (yanlış). G3 (0,5) ilk üç-dört karta sayı yazar ama gereğinden güçlüdür (madde 2).
2. **Kademe kartıyla kıyas.** Bir Çekirdek kademe adımı 0,20 seviyedir; G2'nin ilk derinlik kartı bunun 1,25 katı (ΔU 7,8 ve 6,2), ikinci kart 0,94 katı (0,1875), sonrakiler altında. Güven & Ölçek (0,50) ve tek hatlı alanlarda (1,00) kademe adımı her derinlik kartından büyüktür. G3 ilk kartta 2,5 kademe adımı eder (15,6 U) ve derinliği kademenin önüne geçirir. Kural "derinlik hiçbir kademe adımından büyük olmasın" ise G4 (0,2) en yakın adaydır; farkı küçüktür ve bedeli yukarıdaki etiket sorunudur (yuvarlayan bir etiket kuralı çözer).
3. **Kesiğe varış hızı.** Karar 13 olduğu gibi kalırsa kesik, g₀'dan bağımsız olarak derinliği kapatır (§4.3). Kesik yumuşatılırsa (§6 soru 1) G2 ile tavan 1,0: 2★ kesikte Çekirdek 3 karta kadar kart alır (1 hat K3 + 4 hat K1), 3★ kesikte 1 hat K3 + 4 hat K2'de 6 kartta kesiğe varılır; G3 aynı iki durumda 1 ve 2 kart, G1 11 kart ve hiç.
4. **1 kişide** g₀ yalnız son aylarda görünür: 104 haftada 4-5 kart biter, 3,5'i Çekirdek'te. G2 ile Çekirdek'teki ilk iki kart +0,25 ve +0,19 (toplam 0,44 seviye = 1,75 kare, ΔU ≈ +14 puan).
5. **50 kişide** ilk K3 sprint 3'te (6. hafta) ve ürün başına ~29 derinlik kartı/sprint biter. Her alan serinin %90'ına (9 kart) yaklaşık iki sprintte varır, sonra kartlar değersizdir. g₀'ın büyüklüğü 50 kişide oyunun gidişini değiştirmez; **değiştiren şey azalma biçimi ve kesik kararıdır** (§6 soru 1-2).
6. **Ekonomiye etkisi küçük ve sınırlı.** Çekirdek 2★ hesabı için ilk kart +7,8 U (G2), kademe adımı +6,2; kesikteki hesapta 0. Çubuk görünümü de K2'den sonra çoğu alanda doymuştur (§3).

G2'nin kendisi §4.1-4.3'teki sorunu çözmez; g₀ sorunun karşı tarafında bir ayardır. **Önerim, g₀'ı E1'e kesik kararıyla birlikte götürmek** (§6).

## 6. Erdem'e sorular (E1)
1. **Kesik cümlesi (Karar 13) Q'nun sayılarıyla derinliği kapatıyor** (teslim 6 kişide −%74, 12 kişide −%87, 25 ve 50 kişide −%94 ve −%97; boşta %74-98). Üç yol:
   - **(a)** Kesik kartı önermekten çıkarılsın; kartlar gelmeye devam etsin, kazanç 4·g₀'da doysun, etki satırı doyunca "çubuk dolu / ilk karttan az" desin. Arzı korur; bedeli: 12 kişide kartların %87'si, 50 kişide %97'si değersiz iş olur (PRD'nin "jenerik ad grind hissi" riski büyür).
   - **(b)** Kesik kalsın (3★ referansıyla); büyük ekibin arzı derinlik dışından gelsin (E'nin modülleri, istek akışı, yeni hat). Derinlik kartı yalnız 1-3 kişide anlamlı kalır; 6-50 kişi için D'nin arz kapıları yeniden açılır.
   - **(c)** Derinlik kazancı Q'nun oran kesiğinin dışına konsun (4·g₀ ile sınırlı küçük bonus). Q'nun sabitine dokunur (`RATIO_CAP` onay bekliyor); kart yine ilk 9-11 kartta değerli, sonrası değersiz kalır.
2. **Azalma 0,75 ile ilk 11 kartta %96 doyuyor.** Hat başına yüz küsur kart tüketen ekipte kartların %87-97'si g₀'ın %5,6'sından azını katar. Azalma daha yavaş olsun mu (ör. 0,9: aynı doygunluğa 31. kartta varılır), yoksa kart sayısı alan başına tavanlansın mı? Hangisi seçilirse g₀ aynı kalır.
3. **g₀ = 0,25 (bir 2★ Çekirdek karesi) onaylı mı?**
4. **Etiket kuralı** (§3): "+N kare" için N = ⌊kazanç ÷ kare⌋ ve "(ilk karttan az)" eki mi, yoksa yuvarlama mı?

## 7. E · Açık kalanlar ve PRD'nin sessiz olduğu yerler

1. **Kesik ile K3 tetikleyicisi birlikte tutmuyor** (§4.1-4.2). Karar 13 hem "K3'ü biten hatta aç" hem "oran kesiğine varmış alanda önerme" diyor; Q'nun sayılarıyla K3 bitmiş her alan kesiktedir. E1'de seçilecek (§6 soru 1).
2. **Kazanç hattın seviyesine mi alanın ortalamasına mı eklenir.** `level` her hattı `min(kademe + cila, hattın son kademesi)` ile keser (`pq:102-103`); derinlik kartı yalnız K3'ü bitmiş hatta açıldığı için o hat zaten tavanda (3,0). **Kazanç hattın içine eklenirse sıfır olur.** "En çok hattın son kademesi" tavanı, kazanç hat içindeyse derinliği tam keser. Kazanç alanın ortalamasına, `pq:104`'ten sonra, eklenmeli: `return sum / caps.size() + derinlik_kazanci[alan]`. Sonuç: alan seviyesi 3'ü aşabilir (`expectation`'ın `top` kesmesi `pq:126-129` beklentiyi keser, seviyeyi değil); `area_row` karesi 10'da durur; `word_for` (`pq:133-138`) beklenti + 1'de "Güçlü" der, derinlik bu eşiği geçirebilir (2★ Çekirdek K2'de 2,0 "Yeterli"; G2'nin ilk kartıyla 2,25 "Güçlü").
3. **Kazancı tutan yer ve "k".** Alan başına bir sayaç (biten kart sayısı) ve toplam kazanç; kayıt şeması D'nin 20'si. k'yi kartın **bittiği an** saymak gerekir (plana girişte değil): aynı sprintte aynı alandan iki derinlik kartı biterse ikincisi 0,75 ile gelir. Sprint öngörüsü (`SprintCatalog.forecast`, `sc:338`) ve etki satırı bunu bilmeli, yoksa D'nin "tahmin = sonuç" kapısı kırılır.
4. **Kesik tanımı (PRD sessiz).** Hangi yıldızın beklentisi (kod: kesik yıldızsız sabit 1,5 ve oranı çağıran seçer, §4.1), ne zaman değerlendirilir (kart açılırken mi, planlanırken mi, biterken mi), uçuştaki kartlar kesik aşılınca ne olur (kazanç kırpılır mı, kart düşer mi), ve "önerilmez" ne demek: açılmaz mı, açık ama sıralamada sona mı, oyuncu elle seçebilir mi. Simülasyonda "açılmaz ve açık planlanmamış kartlar çekilir" okudum (§4.3).
5. **Etki satırı: kazançtan mı, çubuk farkından mı.** PRD "area_row karesiyle" diyor. `area_row` yuvarlar ve 10'da keser (§3); satır kazançtan (⌊kazanç ÷ kare⌋) yazılırsa çubuk değişmese de "+1 kare" der, çubuk farkından yazılırsa "+0" çıkabilir. Çubuk doyduysa satırın ne diyeceği tanımsız.
6. **Öneri sırası (`_impact`, `sc:813-829`).** Kart etkisi `step` 1,0 + `level` 2,0 × Δseviye (`sprint.json:78`). Derinlik kartı bu formülü aynen alırsa kazancı 0'a inmiş kart da 1,0 alır ve öneride kademe kartına eşit çıkar. Derinlik kartının etkisi `step` olmadan yalnız Δseviye × `level` olmalı (D'nin simülasyonu `0,75^k` kullanıyor, koddaki formülden farklı).
7. **Hattın seviyesi düşebilir.** Ar-Ge bir alana gizli hat açarsa alan seviyesi yarıya iner (RAPOR_Q §1 madde 6); rakip artışı beklentiyi yükseltir (`pq:123-125`); B2C kitlesi büyüdükçe referans yükselir (`pq:312-316`). Kesikte olan alan yeniden kesiğin altına inebilir. Kart durumdan türetilirse (kesik her çağrıda sorulursa) sorun yok; kart saklanıyorsa geri çekme/geri getirme kuralı gerek.
8. **Rakip artışı kesiği geçici açar.** İki rakip çıkışı (`rival_bump` 0,5 × 2, en çok 1,0; yalnız aday ve ekonomi bağlamı, pencere 6 hafta, `pq:123-125`, `sprint.json:31-33`) 2★ Çekirdek beklentisini 2,25'e, kesiğini 3,375'e çıkarır: K3'lü Çekirdek'te (3,0) 0,375'lik boşluk doğar (G2 ile 2 kart). Vurgu alanlarında aynı bump kesiği 3,0'a çıkarır, yani K3'te hâlâ kesik. K3'ten sonra kesiği açan tek yer budur ve geçicidir.
9. **Cila.** ACIK 96: cila kartı üretilmez, sayacı yalnız kayıt göçü doldurur (hat başına en çok 1,0, `sprint.json:35-36`); K3 hatta kırpıldığı için derinliği etkilemez. Derinlik kazancı ile göçten gelen cila ayrı sayaçlardır ve ikisi de seviyeye girer; "derinlik cilanın yerini alıyor mu" sorusu PRD'de yok.
10. **B2C** (`1 + ⌊hattın kullanıcısı ÷ 2.500⌋`, "ölçülmedi"). Alanlar Çekirdek, Onboarding, Büyüme (tek hat), Güven & Ölçek, Gelir (ücretli plan, tek kademeli, derinlik yok). Kesik hareketli (kitle yıldızı sürekli kayar). Bu belgenin B2B ölçümleri B2C'ye taşınmadı.
11. **Ad sayısı hat başına, kazanç alan başına.** Tek hatlı alanlarda (Entegrasyonlar, Onboarding) alanın bütün kartları o hattın adlarından gelir; Çekirdek'te beş hat arasında bölünür (§4.4).
12. **Birim güncellemesi.** `area_row` sabitleri (`goal_mark` 5, `goal_squares` 10) ya da beklenti tablosu (CORE_2 1,25 K9c'de değişti) değişirse kare birimi değişir; g₀ seviye biriminde yazıldığı için etkilenmez, yalnız etki satırının etiketi kayar.

## 8. Yeniden üretim
Klasör: `docs/tasks/faz_cde/d_taslak/dsim/v3/g0/`. Hepsi `python -I`; sim en çok 2 işçi, her çağrı 420 sn bütçeli ve kaldığı yerden sürer.
```
python -I tablolar.py > out/tablolar.md     # §2-§3 analitik tablolar (Godot yok)
bash kos.sh                                  # sim: orig, map, cut2/cut3 (g0 0,125/0,25/0,5), ser:N ; 20 tohum ; S1-S6  -> out/main/*.pkl
python -I ozet.py main > out/ozet.md         # §4 simülasyon tabloları
```
Bu belgedeki tablolar o iki çıktıdan `build.py` ile bire bir yerleştirildi (metin elle yazıldı, tablo hücresi elle yazılmadı). Çıktılar `out/` altındadır (`tablolar.md`, `ozet.md`, `main/*.pkl`).
Varyantlar (`sim_g0.py`): `orig` dsim3 aynen (D0s taban); `map` dsim3 + gerçek alan eşlemesi (hat 0-4 Çekirdek, 5 Onboarding, 6 Entegrasyonlar, 7-8 Güven & Ölçek; öneri 5. basamağı ve etkisi bu eşlemeyle); `cut2:g` ve `cut3:g` alanın seviyesi (taban = kademelerin ortalaması + g × (1 − 0,75^n) ÷ 0,25) 2★ ya da 3★ sayfa beklentisinin 1,5 katına varınca o alanın derinlik kartı açılmaz ve açık planlanmamış olanlar çekilir; `ser:N` alan başına en çok N derinlik kartı. Simülasyon kademe ilerlemesini dsim3'ün zinciriyle (genişlik önce) yapar, kapıları (Ar-Ge, yıldız) bilmez; cila yoktur.

## 9. Ek kollar (E1 için)

Ana oturumun isteği: §6 soru 1 ve 2'ye ölçülmüş öneri. Kurallar aynı: Godot yok, `python -I`, en çok 2 işçi, her çağrı 9 dakikanın altında; R okuması, kaynaklı arz, 104 hafta, 20 tohum, 1 / 3 / 6 / 12 / 25 / 50 kişi, g₀ = 0,25. Gövde (§0-§8) değişmedi; bu bölüm eklendi.

### 9.1 Kollar ve ölçüler
| Kol | Kural | Koşu |
|---|---|---|
| **(a)** | Kesik kartı önermekten çıkar, kartlar hep gelir; azalma q = 0,75. Ürün uyumunda Q'nun 1,5 kesiği durur (kazanç kesiğin içinde, kesikten sonra U'ya 0 katar). | `orig` (D0s tabanı, tablodan) ve `map` (gerçek alan eşlemesi), §4.3 koşusu |
| **(a')** | (a) ile aynı, q = 0,9 | `D3_DGAIN=0.9`, `map`, yeni koşu |
| **(c)** | Kazanç Q'nun kesiğinin dışında: oran = min(taban ÷ beklenti, 1,5) + kazanç ÷ beklenti. Alanda biten kartların kazancı serinin tavanının (g₀ ÷ (1 − q)) %95'ine varınca alan kapanır: yeni kart açılmaz, açık ama planlanmamış kartlar çekilir. q = 0,75 (alan başına 11 kart). | `sat:0.95`, yeni koşu |
| **(c')** | (c) ile aynı, q = 0,9 (alan başına 29 kart; tavan 10·g₀ = 2,5 seviye) | `D3_DGAIN=0.9`, `sat:0.95`, yeni koşu |
| **Tavan 8** | Alan başına en çok 8 kart (açılan sayılır), q = 0,75 | `ser:8`, §4.3'ten |
| (c) rezerv | (c)'nin kapanışı açılan kart sayısıyla (11 ve 29), açık kartlar çekilmez | `ser:11`, `ser:29` (q = 0,9) |
| Karar 13 | Bugünkü metin: 3★ kesik | `cut3:0.25`, §4.3'ten |

Notlar:
- "Tavanın %95'i" için serinin kendi tavanı alındı (q 0,75'te 4·g₀, q 0,9'da 10·g₀). İstek "4·g₀'ın %95'i" q 0,9'da 5 karta denk gelirdi (0,25 × (1 − 0,9^5) ÷ 0,1 = 0,95); bu, (c')'yi anlamsız kısa yapardı.
- **Değerli kart:** alanda k'inci biten kartın kazancı g₀'ın %5'inden büyükse (q^(k−1) > 0,05): q 0,75'te k ≤ 11, q 0,9'da k ≤ 29. **Değerli pay** = Σ_alan min(biten, K) ÷ Σ biten.
- **Eksik ad** = Σ_hat max(0, açılan kart − hattın adı). Hat adları: Çekirdek hatlarında 8, Onboarding 8, Entegrasyonlar 8, Güvenlik 9, Dayanıklılık 8 (üç ürünün en az adı, `Wa_ADLAR.json`; toplam 73). 0 = 162 ad yeter.
- **Dolu ve değerli kapasite** = (1 − boşta) × değerli pay: benim türettiğim bileşik ölçü; ekibin zamanının ne kadarının değerli bir kartla dolu geçtiği.
- Tüm sayılar `g0/out/ek_sim.md` ve `ek_u.md` çıktısıdır (`ozet_ek.py`, `ek_u.py`).

### 9.2 Ekip başına sonuç
**Teslim (puan/hf, 21-104. hafta):**

| Kol (20 tohum, medyan) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| (a) D0s tabanı: kesik yok, q 0,75 (dsim3'ün kendi alan eşlemesi) | 5,6 | 21,2 | 47,6 | 99,7 | 242,7 | 432,6 |
| (a) kesik yok, q 0,75 (gerçek alan eşlemesi) | 5,5 | 20,6 | 45,2 | 97,2 | 217,8 | 434,9 |
| (a') kesik yok, q 0,9 | 5,5 | 20,6 | 45,3 | 95,9 | 216,4 | 434,9 |
| (c) bonus kesik dışı, alan %95'te kapanır, q 0,75 | 5,5 | 20,4 | 22,6 | 21,0 | 14,3 | 14,0 |
| (c') aynısı, q 0,9 | 5,5 | 20,6 | 41,0 | 40,7 | 33,5 | 26,3 |
| tavan 8/alan, q 0,75 | 5,4 | 19,7 | 20,6 | 15,1 | 14,0 | 14,0 |
| (c) rezerv sayımlı: açılan kart 11/alan, q 0,75 | 5,5 | 20,1 | 24,0 | 18,5 | 14,0 | 14,0 |
| (c') rezerv sayımlı: açılan kart 29/alan, q 0,9 | 5,5 | 20,6 | 45,0 | 41,0 | 28,2 | 23,3 |
| Karar 13 olduğu gibi: kesik 3★, g₀ 0,25, q 0,75 | 5,4 | 12,9 | 12,4 | 13,3 | 14,0 | 14,0 |

**Boşta payı:**

| Kol (20 tohum, medyan) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| (a) D0s tabanı: kesik yok, q 0,75 (dsim3'ün kendi alan eşlemesi) | 7% | 14% | 13% | 13% | 8% | 15% |
| (a) kesik yok, q 0,75 (gerçek alan eşlemesi) | 9% | 16% | 17% | 15% | 13% | 14% |
| (a') kesik yok, q 0,9 | 9% | 16% | 17% | 16% | 13% | 14% |
| (c) bonus kesik dışı, alan %95'te kapanır, q 0,75 | 9% | 17% | 56% | 83% | 95% | 98% |
| (c') aynısı, q 0,9 | 9% | 16% | 25% | 65% | 88% | 96% |
| tavan 8/alan, q 0,75 | 9% | 19% | 62% | 88% | 95% | 98% |
| (c) rezerv sayımlı: açılan kart 11/alan, q 0,75 | 8% | 17% | 56% | 85% | 95% | 98% |
| (c') rezerv sayımlı: açılan kart 29/alan, q 0,9 | 9% | 16% | 18% | 67% | 90% | 96% |
| Karar 13 olduğu gibi: kesik 3★, g₀ 0,25, q 0,75 | 9% | 45% | 74% | 88% | 95% | 98% |

**Değerli kart payı** (biten derinlik kartlarından kazancı g₀'ın %5'inden büyük olanlar):

| Kol (20 tohum, medyan) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| (a) D0s tabanı: kesik yok, q 0,75 (dsim3'ün kendi alan eşlemesi) | 100% | 90% | 29% | 13% | 5% | 3% |
| (a) kesik yok, q 0,75 (gerçek alan eşlemesi) | 100% | 89% | 32% | 14% | 6% | 3% |
| (a') kesik yok, q 0,9 | 100% | 100% | 84% | 36% | 16% | 8% |
| (c) bonus kesik dışı, alan %95'te kapanır, q 0,75 | 100% | 98% | 88% | 79% | 73% | 78% |
| (c') aynısı, q 0,9 | 100% | 100% | 96% | 91% | 82% | 86% |
| tavan 8/alan, q 0,75 | 100% | 100% | 100% | 100% | 100% | 100% |
| (c) rezerv sayımlı: açılan kart 11/alan, q 0,75 | 100% | 100% | 100% | 100% | 100% | 100% |
| (c') rezerv sayımlı: açılan kart 29/alan, q 0,9 | 100% | 100% | 100% | 100% | 100% | 100% |
| Karar 13 olduğu gibi: kesik 3★, g₀ 0,25, q 0,75 | 100% | 100% | 100% | 100% | 100% | 100% |

**Dolu ve değerli kapasite** (1 − boşta) × değerli pay:

| Kol (20 tohum, medyan) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| (a) D0s tabanı: kesik yok, q 0,75 (dsim3'ün kendi alan eşlemesi) | 0,93 | 0,79 | 0,25 | 0,12 | 0,05 | 0,03 |
| (a) kesik yok, q 0,75 (gerçek alan eşlemesi) | 0,91 | 0,76 | 0,27 | 0,12 | 0,05 | 0,03 |
| (a') kesik yok, q 0,9 | 0,91 | 0,84 | 0,70 | 0,30 | 0,14 | 0,07 |
| (c) bonus kesik dışı, alan %95'te kapanır, q 0,75 | 0,91 | 0,81 | 0,38 | 0,13 | 0,04 | 0,02 |
| (c') aynısı, q 0,9 | 0,91 | 0,84 | 0,72 | 0,31 | 0,10 | 0,04 |
| tavan 8/alan, q 0,75 | 0,91 | 0,81 | 0,38 | 0,12 | 0,05 | 0,02 |
| (c) rezerv sayımlı: açılan kart 11/alan, q 0,75 | 0,92 | 0,83 | 0,44 | 0,15 | 0,05 | 0,02 |
| (c') rezerv sayımlı: açılan kart 29/alan, q 0,9 | 0,91 | 0,84 | 0,82 | 0,33 | 0,10 | 0,04 |
| Karar 13 olduğu gibi: kesik 3★, g₀ 0,25, q 0,75 | 0,91 | 0,55 | 0,26 | 0,12 | 0,05 | 0,02 |

**Biten derinlik kartı** (ürün başına):

| Kol (20 tohum, medyan) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| (a) D0s tabanı: kesik yok, q 0,75 (dsim3'ün kendi alan eşlemesi) | 5 | 48 | 151 | 332 | 808 | 1432 |
| (a) kesik yok, q 0,75 (gerçek alan eşlemesi) | 4 | 45 | 136 | 322 | 738 | 1438 |
| (a') kesik yok, q 0,9 | 4 | 48 | 138 | 320 | 738 | 1441 |
| (c) bonus kesik dışı, alan %95'te kapanır, q 0,75 | 4 | 42 | 50 | 56 | 60 | 56 |
| (c') aynısı, q 0,9 | 4 | 48 | 120 | 128 | 142 | 136 |
| tavan 8/alan, q 0,75 | 3 | 29 | 32 | 32 | 32 | 32 |
| (c) rezerv sayımlı: açılan kart 11/alan, q 0,75 | 4 | 34 | 44 | 44 | 44 | 44 |
| (c') rezerv sayımlı: açılan kart 29/alan, q 0,9 | 4 | 45 | 114 | 116 | 116 | 116 |
| Karar 13 olduğu gibi: kesik 3★, g₀ 0,25, q 0,75 | 4 | 5 | 4 | 3 | 2 | 4 |

**En çok kullanılan hattaki kart** (açılan, medyan):

| Kol (20 tohum, medyan) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| (a) D0s tabanı: kesik yok, q 0,75 (dsim3'ün kendi alan eşlemesi) | 10 | 16 | 28 | 52 | 115 | 192 |
| (a) kesik yok, q 0,75 (gerçek alan eşlemesi) | 11 | 18 | 42 | 88 | 170 | 200 |
| (a') kesik yok, q 0,9 | 11 | 18 | 41 | 88 | 170 | 202 |
| (c) bonus kesik dışı, alan %95'te kapanır, q 0,75 | 11 | 18 | 18 | 15 | 13 | 13 |
| (c') aynısı, q 0,9 | 11 | 18 | 36 | 36 | 34 | 32 |
| tavan 8/alan, q 0,75 | 8 | 8 | 8 | 8 | 8 | 8 |
| (c) rezerv sayımlı: açılan kart 11/alan, q 0,75 | 11 | 11 | 11 | 11 | 11 | 11 |
| (c') rezerv sayımlı: açılan kart 29/alan, q 0,9 | 11 | 18 | 29 | 29 | 29 | 29 |
| Karar 13 olduğu gibi: kesik 3★, g₀ 0,25, q 0,75 | 12 | 6 | 3 | 2 | 1 | 2 |

**Eksik ad** (162 ad yetiyor mu: 0 = evet):

| Kol (20 tohum, medyan) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| (a) D0s tabanı: kesik yok, q 0,75 (dsim3'ün kendi alan eşlemesi) | 5 | 46 | 147 | 326 | 790 | 1399 |
| (a) kesik yok, q 0,75 (gerçek alan eşlemesi) | 4 | 43 | 133 | 314 | 719 | 1404 |
| (a') kesik yok, q 0,9 | 4 | 46 | 134 | 314 | 722 | 1406 |
| (c) bonus kesik dışı, alan %95'te kapanır, q 0,75 | 4 | 37 | 26 | 13 | 9 | 8 |
| (c') aynısı, q 0,9 | 4 | 46 | 110 | 100 | 73 | 66 |
| tavan 8/alan, q 0,75 | 0 | 0 | 0 | 0 | 0 | 0 |
| (c) rezerv sayımlı: açılan kart 11/alan, q 0,75 | 3 | 8 | 6 | 6 | 6 | 6 |
| (c') rezerv sayımlı: açılan kart 29/alan, q 0,9 | 4 | 38 | 54 | 54 | 54 | 54 |
| Karar 13 olduğu gibi: kesik 3★, g₀ 0,25, q 0,75 | 4 | 0 | 0 | 0 | 0 | 0 |

### 9.3 Okuma
1. **(a) ve (a') arzı korur, değerli işi korumaz.** Boşta %9-17 (1-12 kişi), teslim D0s tabanıyla aynı (12 kişide 95,9-97,2 ve 99,7). Ama değerli pay (a)'da 3 kişide %89, 6 kişide %32, 12 kişide %14; (a')'de 100 / 84 / 36. Yani q 0,9 aynı arzı bırakıp 6 kişide değerli payı 32 → 84'e çıkarır. Yine de iki kolda da ürün uyumuna **gerçek** katkı sıfırdır: kesik uyum hesabında durduğu için K3'ü bitmiş alanda hiçbir kart U'yu oynatmaz (§9.4, durum E). "Değerli" burada yalnız seviyenin kağıt üstündeki kazancıdır.
2. **(c) ve (c') değeri gerçek yapar, bedeli arzdır.** (c) q 0,75: 6 kişide boşta %56, 12 kişide %83. (c') q 0,9: boşta 6 kişide %25, 12 kişide %65, 25-50 kişide %88-96; değerli pay 6 kişide %96, 12 kişide %91. Tavan 8 bu kolların hepsinden kötüdür (boşta 6 kişide %62, 12 kişide %88) ve Karar 13'ün bugünkü hâliyle (%74 ve %88) aynı düzeydedir.
3. **Kapanışta açık kartları çekmek zarar veriyor.** (c) ve (c') kolları kapanınca planlanmamış açık kartları çekti; sayım açılan kartla yapılıp çekilmediğinde (rezerv) 6 kişide (c') 41,0 → 45,0 teslim, boşta %25 → %18 olur (12 kişide 40,7 → 41,0). (c)'de de aynı yönde (6 kişi 22,6 → 24,0). Önerilen uygulama: alan kapanınca **yeni kart açılmaz, açık kartlar kalır**.
4. **Biten sayımıyla kapanış kayar.** Küçük ekip bütün stoku K3 olur olmaz açar: 3 kişide (c)'de 110 kart açılır (kesiksizde 115), yani kapanış orada hiç ısırmaz; 6 kişi ve üstünde alan başına biten 12-18 (tavan 11), (c')'de 29-39 (tavan 29). Rezerv sayımı bu aşımı kaldırır.
5. **Ad.** Kesiksiz kollar (a, a') 3 kişiden itibaren yüzlerce ad ister; yetmez. (c) q 0,75 3-50 kişide 8-37 ad eksik, (c') 46-110 eksik (en çok kullanılan hat 32-36 kart). **Yalnız tavan 8 tam yeter** (eksik 0); rezerv sayımlı 11 kartta eksik 6 (Onboarding ve Entegrasyonlar'da 3'er ad), rezerv sayımlı 29 kartta 54 (tek hatlı iki alanda 21'er, Güven & Ölçek'in iki hattında 7 ve 5). Yani (c') için hat başına 6 değil, **tek hatlı alanlarda ad sayısı kapanış kartına eşit olmalı** (ya da adlar yeniden kullanılmalı: "aynı işin farklı kapsamı").
6. **12 kişide hiçbir kol hem dolu hem değerli değil** (bileşik 0,30-0,33, 25-50 kişide ≤ 0,14). Neden: değerli kart sayısı kolun tavanıyla sınırlı (q 0,75'te ürün başına 44, q 0,9'da 116), 12 kişilik ekip kesiksizde ~320 kart bitirir. Bu açığı derinlik kapatamaz; q 0,963'e kadar yavaşlatmak gerekirdi (alan başına 80 değerli kart), bu da tavanı 27·g₀'a taşır. 12 kişi ve üstü için arz derinlik dışından (E'nin modülleri, yeni hatlar) gelmeli.

### 9.4 Tipik bir 3★ hesapta ürün uyumu U (kollar (c) ve (c'))
Hesap: 3★, sektör technology (vurgu 1 Entegrasyonlar, vurgu 2 Güven & Ölçek, kalan Onboarding; ağırlık 0,50 / 0,25 / 0,15 / 0,10; beklenti 3★ 2,0 / 1,5 / 1,5 / 1,0). U, Q'nun `fit_from_levels` formülüdür (`pq:268-297`): oran = seviye ÷ beklenti, (a)'da toplam kesikte, (c)'de taban kesikte + kazanç kesikten sonra; U = min(100, 70 × ortalama), ortalama en çok Çekirdek oranı + 0,25. Kartların hepsi Çekirdek'e gidiyor (çeyrek hedefi Çekirdek); (c) alan 11., (c') 29. kartta kapanır. Kod değil hesap: `g0/ek_u.py`.

**Çekirdek geride: 1 hat K3 + 4 hat K2 (2,20), öteki alanlar K2 (2,0)**

| Çekirdek derinlik kartı sayısı | (a): U | (c): U | (c'): U | (c') g₀ 0,1: U |
|---|---|---|---|---|
| 0 | 86 | 86 | 86 | 86 |
| 1 | 91 | 91 | 91 | 88 |
| 2 | 94 | 94 | 95 | 90 |
| 3 | 96 | 96 | 98 | 91 |
| 5 | 100 | 100 | 100 | 93 |
| 8 | 100 | 100 | 100 | 96 |
| 11 | 100 | 100 | 100 | 98 |
| 29 | 100 | 100 | 100 | 100 |

**Çekirdek doymuş: 5 hat K3 (3,0), öteki alanlar K1 (1,0)**

| Çekirdek derinlik kartı sayısı | (a): U | (c): U | (c'): U | (c') g₀ 0,1: U |
|---|---|---|---|---|
| 0 | 78 | 78 | 78 | 78 |
| 1 | 78 | 83 | 83 | 80 |
| 2 | 78 | 86 | 86 | 81 |
| 3 | 78 | 88 | 90 | 83 |
| 5 | 78 | 92 | 96 | 85 |
| 8 | 78 | 94 | 100 | 88 |
| 11 | 78 | 95 | 100 | 90 |
| 29 | 78 | 95 | 100 | 95 |

**Her alan K3 (3,0)**

| Çekirdek derinlik kartı sayısı | (a): U | (c): U | (c'): U | (c') g₀ 0,1: U |
|---|---|---|---|---|
| 0 | 100 | 100 | 100 | 100 |
| 1 | 100 | 100 | 100 | 100 |
| 2 | 100 | 100 | 100 | 100 |
| 3 | 100 | 100 | 100 | 100 |
| 5 | 100 | 100 | 100 | 100 |
| 8 | 100 | 100 | 100 | 100 |
| 11 | 100 | 100 | 100 | 100 |
| 29 | 100 | 100 | 100 | 100 |

Özet (ham U = 70 × ortalama, 100'e kesilmeden):

| Durum | Kol | İlk kartın ΔU'su (ham) | 5. kartın ΔU'su (ham) | Doygunluk | Doygunlukta toplam ΔU (U 100'e kesik) | U (ham): önce → doygunluk |
|---|---|---|---|---|---|---|
| B | (a) | 4,4 | 1,4 | 29 kart | 13,7 | 86,3 → 100,0 |
| B | (c) | 4,4 | 1,4 | 11 kart | 13,7 | 86,3 → 100,0 |
| B | (c') | 4,4 | 2,9 | 29 kart | 13,7 | 86,3 → 100,0 |
| B | (c') g₀ 0,1 | 1,7 | 1,1 | 29 kart | 13,7 | 86,3 → 100,0 |
| E | (a) | 0,0 | 0,0 | 29 kart | 0,0 | 78,2 → 78,2 |
| E | (c) | 4,4 | 1,4 | 11 kart | 16,8 | 78,2 → 94,9 |
| E | (c') | 4,4 | 2,9 | 29 kart | 21,8 | 78,2 → 100,0 |
| E | (c') g₀ 0,1 | 1,7 | 1,1 | 29 kart | 16,7 | 78,2 → 94,8 |

Okuma:
- **Durum B (Çekirdek geride, tipik ilk derinlik kartı anı):** ilk kart +4,4 U, 5. kart +1,4 (q 0,75) ya da +2,9 (q 0,9). U 86'dan 5 kartta 100'e varır; doygunluğa (11 ya da 29 kart) gerek kalmaz. (a) ve (c) aynıdır: U 100'e kesikten önce dolar.
- **Durum E (Çekirdek doymuş, öteki alanlar K1):** (a)'da derinlik hiçbir şey katmaz (78 → 78). (c) q 0,75'te ilk kart +4,4, 5. kart +1,4, doygunlukta (11 kart) 78 → 95 (+16,8). (c') q 0,9, g₀ 0,25'te ilk +4,4, 5. kart +2,9, 8. kartta U 100: derinlik, öteki üç alanın K1'de kalmasını tamamen telafi eder. Bu bir denge riskidir: tavan 10·g₀ = 2,5 seviye Çekirdek'te 12,5 kademe adımına eşit.
- **q 0,9'u q 0,75 ile aynı toplamda tutmak** g₀ = 0,1 ister (doygunlukta 0,95 seviye; (c)'nin 0,96'sı ile aynı toplam; durum E'de 78 → 95, ilk kart +1,7, 5. kart +1,1); ama 2★ Çekirdek karesinin (0,25) 0,4'ü olur: etiket kuralı (§3) ilk kartı "ilk karttan az" yazdırır.
- **Durum F (her alan K3):** U her kolda 100 (ham 105); derinlik hiçbir şey katmaz. Tamamlanmış bir üründe derinlik kartlarının ekonomik değeri (c)'de de yoktur; değer yalnız zayıf bırakılmış alan varken vardır.
- Varsayımım: `CORE_LEAD` tavanı Çekirdek oranına bonusu da katar (tavan = Çekirdek oranı + 0,25). Bonus Çekirdek oranından hariç tutulursa tavan Çekirdek'in kesikli oranına bağlı kalır; durum E'de ham ortalama 1,12 ve tavan 1,75 olduğundan sonuç değişmez, ama Çekirdek'i bonusla "ödünç" alan zayıf bir ürün için ayrıca bakılmalı.

### 9.5 Öneri
**(c') önerilir** (azalma 0,9, bonus Q'nun kesiğinin dışında, alan serinin %95'ine varınca yeni kart açmaz ama açık kartlar kalır, sayım açılan kartla), çünkü 1-6 kişide boşta %9-18 iken kartların %100'ü değerli (dolu ve değerli kapasite 0,84 ve 0,82) ve değer gerçektir, 12 kişide boşta %67'ye çıkar ve o ekipte (ile 25-50 kişide) arzı derinlik dışından (EA) getirmek gerekir.

Koşullar ve alternatif:
1. (c') Q'ya dokunur: oran kesiği tabandan ölçülür, bonus kesikten sonra eklenir (E madde 2 ile birlikte; `RATIO_CAP` onay bekliyor).
2. q 0,9 + g₀ 0,25 tavanı 2,5 seviyeye çıkarır (durum E: 8 kartta U 100). İki yol: g₀'ı 0,1'e indirmek (etiket sorunu) ya da bonus tavanını ayrıca (ör. alan başına 1,5 seviye) koymak. Karar Erdem'in.
3. Ad: (c') için tek hatlı alanlarda (Onboarding, Entegrasyonlar) 29 ad ya da yeniden kullanım gerekir; 162 ad yetmez (eksik 54).
4. Kesik sayısal kısıt istemezse **(a')** yedek: Q'ya dokunmaz, arz D0s kadar (boşta %9-17), değerli pay 100 / 100 / 84 / 36; değer kağıt üstünde (U'ya 0). 12 kişide kartların %64'ü "dolgu"dur.
5. Karma: (c') bonusu ama alan kapanmasın = (a') arzı (boşta ≤ %17) + ilk 29 kartta gerçek değer; sonraki kartlar dolgu olur. Arz sayıları (a')'dür, ayrıca koşulmadı.

### 9.6 Yeniden üretim (ek)
```
python -I sim_g0.py main sat:0.95 S1,S2,S3,S4,S5,S6 420           # (c) q 0,75
D3_DGAIN=0.9 python -I sim_g0.py ek09 map,sat:0.95,ser:29,ser:11 S1,S2,S3,S4,S5,S6 420   # (a'), (c'), rezerv sayımlı
python -I ozet_ek.py > out/ek_sim.md                               # §9.2 tabloları
python -I ek_u.py > out/ek_u.md                                    # §9.4 tabloları
```
`sim_g0.py`'ye `sat:<pay>` kuralı eklendi (alan başına biten kartların kazancı serinin tavanının payına varınca o alan kapanır, planlanmamış açık kartlar çekilir); azalma `D3_DGAIN` ortam anahtarıyla gelir. Önceki koşuların sonuçları değişmedi.
