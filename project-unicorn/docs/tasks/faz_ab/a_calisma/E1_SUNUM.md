# E1 · Erdem durağı · Hata akışı, Karar 4 mekanizması, hedefler (2026-10-16)
Kaynaklar: `A0_ARASTIRMA.md` (araştırma ve ilk simülasyon), `A1d/` (bugünkü oyunun bot koşusu, tohum 7, 104 hafta),
ana oturumun simülasyonu (gerçek taban parametreleriyle, `scratchpad/e1sim.py`), `A2_DOGRULAMA.md`.

## 1. Araştırmanın özü
- 13 web araması. Game Dev Story, Software Inc. ve Game Dev Tycoon için forum ve wiki düzeyinde kaynak bulundu; Mad Games
  Tycoon 2, Startup Company ve Big Ambitions için hata modeli bulunamadı.
- Bulunan oyunların hiçbiri hatayı hat bazında sprint kartıyla düzeltmiyor. Ya otomatik bir "debug" aşaması var (Game Dev
  Story, Game Dev Tycoon) ya da ayrı bir destek ekibi (Software Inc.).
- Ortak fikir: bütün hatayı yakalamak gerekmez; az sayıda artık hata normaldir. Bu, "hat başına bedelsiz eşik" fikrini
  destekler.
- Bu yüzden mekanizma bir oyundan kopyalanmadı; bu oyunun kuralları üzerinde simülasyonla seçildi.

## 2. Bugün ne oluyor (bot, 104 hafta)
| | B2B | B2C |
|---|---|---|
| Geç dönemde müşteri | 192 hesap (en çok 320) | 26 bin kişilik kitle |
| Geç dönemde haftada yeni hata | ≈ 28 (yalnız taban terimi) | ≈ 46 (en çok 259) |
| Son sürümde açık bilet | 129 | 339 |
| Geç dönem sprint kapasitesi | 20 puan, 1 haftalık sprint | 20 puan, 2 haftalık sprint |

Sel buradan geliyor: akış müşteri sayısıyla doğrusal büyüyor. Ayrıca açık hata akışı besliyor; hata hata doğuruyor.

## 3. Hedefler (öneri, onay bekliyor)
"Düzenli düzelten" = her sprintte bedeli başlamış bütün hatları düzelten oyuncu (`fix_due` kolu).

| Ölçü | B2B erken | B2B geç | B2C erken | B2C geç |
|---|---|---|---|---|
| Haftada yeni hata | ≤ 1,5 | ≤ 4 | ≤ 1,5 | ≤ 3 |
| Açık hata, sürüm anında (düzenli düzelten) | ≤ 4 | ≤ 8 | ≤ 4 | ≤ 8 |
| Açık hata, sprint sonu tepesi (düzenli düzelten) | ≤ 8 | ≤ 16 | ≤ 8 | ≤ 16 |
| Hiç düzeltmeyen, v1.0'dan 20 hafta sonra | ≈ 25 | ≈ 80 | ≈ 30 | ≈ 60 |

Erken = v1.0'dan sonraki ilk 20 hafta.

**Bilinmesi gereken:** Hatalar rastgele dağıldığı için her sprintte yalnız en kötü hattı düzelten oyuncu geç dönemde 10–20
açık hata görür. Bunların çoğu hat başına 1–2 hatadır ve bedelsizdir (aşağıdaki eşik). Ortak yönetmenin "en kötü hattı düzelten
oyuncuda medyan 5'in altı" önerisi bu dağılımla yalnız erken dönemde tutuyor. Bu yüzden o oyuncunun hedefi açık hata sayısı değil,
churn ve düzeltme payıdır.

## 4. Karar 4 mekanizması (öneri, sabitler onay bekliyor)
1. **Akış (asıl kaldıraç).**
   - Açık hataya bağlı terim silinir (Karar 2: hata yalnız kullanımdan ve yeni koddan doğar).
   - Taban günde 0,2 → 0,1.
   - B2B'de akış hesap sayısıyla çok daha yavaş büyür (aynı hatayı çok hesap bildirir): bölen 10 → 80.
   - B2C bölen 2000 → 10000.
   - Beklenen: B2B erken ≈ 1,4, geç ≈ 4 (320 hesapta ≈ 6); B2C erken ≈ 1,3, geç ≈ 3.
2. **Hat başına 1 hata bedelsiz.** Bedel bir hattaki 2. hatadan başlar; ekranda bütün hatalar sayılır (dürüst sayı).
   Rastgele dağılımın ürettiği "her hatta 1 hata" oyuncuyu kart açmaya zorlamaz.
3. **Efor kademeleri:** 1–3 hata 1 puan, 4–6 hata 2 puan, 7 ve üstü 3 puan.
   - Karar 7'deki 1–2 / 3–5 / 6+ yerine; `sprint.json`'da tek ayar.
   - Neden: tek kurucunun bir haftalık sprinti 2 puandır. Bugünkü kademede 3 hatalı bir hat 2 puan, yani tek başına bir
     hata sprinti.
4. **Öncelikli kart eşiği 3 → 6.** Bugünkü "Acil" etiketinin yeni adı K4'te önerilir; B'nin "acil durum"uyla karışmaz.
   Bot yalnız bunları zorunlu alır.
5. **Bedel** (yalnız eşik üstü hatalar):
   - **B2B:** hesabın memnuniyet hedefi −0,4 × (hesabın kullandığı hatlardaki eşik üstü hata), en çok 20 puan.
   - **B2C:** kitle, eşik üstü hatayla orantılı ve tavanlı biçimde yavaşça erir. Katsayı K5'te analitik seçilir: en kötü
     hattı düzelten oyuncunun ek kaybı ≈ %5, hiç düzeltmeyenin en az 2 katı.
   - **İtibar:** eşik üstü hata toplamı 4 hafta üst üste 12 ve üstündeyse haftada −1, en düşük −10. Düzenli düzelten
     oyuncu buna hiç girmez.

## 5. Yapılabilirlik (simülasyon, 3000 sprint, gerçek parametreler)
| Durum | Kural | Düzeltme payı (medyan) | Hata sprinti | Üst üste iki | Sürüm anında açık hata (düzenli / tek kart) |
|---|---|---|---|---|---|
| Tek kurucu, erken, 2 hf, 4 puan | Bugün | %25 | %16 | %0,1 | 2 / 3 |
| | **Öneri** | %25 | **%6** | %0,04 | 3 / 4 |
| Tek kurucu, erken, 1 hf, 2 puan | Bugün | %50 | %23 | %1,9 | 1 / 1 |
| | **Öneri** | %0 (ort. %28) | **%10** | %0,5 | 3 / 3 |
| Küçük ekip, erken, 2 hf, 8 puan | Öneri | %12 | %0,3 | %0 | 4 / 6 |
| B2B geç, 1 hf, 20 puan, haftada 4 | Öneri | %5 | %0 | %0 | 6 / 13 |
| B2C geç, 2 hf, 20 puan, haftada 3 | Öneri | %10 | %0 | %0 | 7 / 20 |

- Tek kurucunun bir haftalık sprintinde 1 puanlık kart zaten kapasitenin %50'sidir. Hata sprinti orada sıfıra inemez,
  yalnız seyrekleşir.
- Bugünkü kuralla sel kalktığında ekipler zaten rahat. Eşik ve kademe asıl olarak tek kurucuyu ve "her hatta 1 hata"
  baskısını çözüyor.

## 6. Düzeltme payı hedefleri (§4.4'ün gözden geçirilmesi)
| Hedef | PRD | Öneri |
|---|---|---|
| Geç, en kötü hattı düzelten (`fix_worst`), medyan | ≤ %15 | ≤ %15 |
| Geç, düzenli düzelten (`fix_due`), medyan | ≤ %25 | **≤ %20** |
| Geç, `fix_due` hata sprinti oranı | ≤ %10 | **≤ %5** |
| Erken, `fix_worst` medyan | (ajan önerir) | **≤ %30** |
| Erken, `fix_due` medyan | (ajan önerir) | **≤ %30** |
| Erken, `fix_due` hata sprinti oranı | (ajan önerir) | **≤ %15** |
| Üst üste iki hata sprinti | yok | geçte 0, erkende ≤ %1 |
| Churn | `fix_worst` ≤ `fix_off` + %10; `fix_none` ≥ 2 × `fix_off` | aynı |

**"Düzeltilmesi gereken hat" (`fix_due`):** sprint başında 2 ve üstü hatası olan hat. B2B'de ayrıca hattı en az bir aktif ya
da deneme hesabı kullanır. Öncelikli kartı olan hat her zaman girer.

## 7. Sorular
1. Hedefler ve mekanizma (3–6) bu hâliyle mi?
2. **VC geri dönüş koşulu** "En zayıf eksen > 40". VC ham ekseni okuyor; ham eksen bugün 40'a hiç varmıyor (probe'da en çok
   33). Kodlanırsa ürün odaklı fonun geri dönüşü hiç açılmaz ve "Series A yolu kapandı" hiç sayılmaz (ACIK_KARARLAR 59).
   Seçenekler:
   - A: oyuncunun gördüğü eksen okumasıyla karşılaştır (0–120, çıtaya göre).
   - B: eşiği ham aralığa göre yeniden ölçekle.
   - C: kapı hiç açılmasın.
3. **B2C akış böleni:** A şimdi 10000'e mi çeksin, yoksa E'ye mi kalsın? Kalırsa B2C geç akışı haftada ≈ 15–20 olur ve B2C
   hedefleri A'da tutmaz.
4. **İtibar düşünce sebep nerede görünsün?** Öneri: Destek kartının ipucu (ör. "Uzun süredir bekleyen hatalar itibarı
   düşürdü"). Alternatif: TopBar'daki itibar değerinin ipucu.

## 8. Bilgi (karar gerekmiyor)
- **%40 hatalı kapanış zarı** bugün atılmıyor ve K1'den sonra da atılmayacak. Test fazına yalnız Test'e uyan biri girebiliyor.
  D değiştirir.
- **Kurucu satırı:** Görevler matrisinde kurucu satırı yok. Oyuncu kurucuyu Destek'e atayamıyor. "Yapım ve Destek tutan
  kurucu" yalnız bot ve eski kayıtta oluşuyor. A yalnız motor bağını kuruyor.
- **K8'in belge kapsamı genişliyor:** ACIK_KARARLAR 96, 97, 99, 43, 44 ve ISLER 56–58. Açık maddelere yalnız not düşülür.
