# SIM2 + SIM3 · Pazar 2 simülasyonunun ikinci turu (satış zarı, G2, G3, G4, G6, G7, G9, demo ve tempo, fiyat, sıralama)

Tarih: 2026-10-22 (SIM3 kapanış turu; SIM2 yorumu 2026-10-21). Betik: `sim/sim.py` (`--mod sim2`), katmanlar `sim/sim2.json` ve `sim/sim3.json`.
Uydurma dünyadır: biçim gösterir, kalibrasyon değildir (§6). Her tam koşu 20 tohum, ~2,3-2,6 dk (10 süreç).
SIM3 (SENTEZ §13.4 madde 1-10) bu raporun sayılarını **yeniledi**: aşağıdaki kapı tablosundaki her sayı SIM3 koşularından gelir; yenilenen kapıların eski sayıları silindi.
Madde 11 (G11) ve madde 12 (YZ dalgası, kapsam dışı) dokunulmadı.

## 0. SIM3 koşuları (tekrar üretilebilir)

Tanımlar (komutlar `sim/` içinden, `python -I`):
- `<ADAY>` = `--ayar efor_bicim='"iki_parca"' --ayar efor_carpani=1 --ayar efor_g_giris=4.5 --ayar efor_g=1.2 --ayar istek_derinlik_hedefi='"piyasa"'`
- `<SIM3>` = `--ek sim3.json` (yalnız kendi kapısını geçen iki sabit: `eskime_memnuniyet` 2, `istek_omur_hafta` 13)
- `<KURAL3>` = `--ayar donem_ilk_yil_sart=true --ayar dev_ihale_yili=2027 --ayar urun_disi_ayrilma='[0.047,0.027,0.017,0.01,0.007]'` (ürün dışı ayrılma = eski KURAL oranının üçte biri)
- `<TAM>` = `--mod sim2 --isci 10 --bkolu-yok --ham <SIM3> <ADAY> --ayar arge_tavan=1 --ayar oncu_politika='"erken"' --ayar fiyat_formul=true`
- Kısmi koşu kapsamı `<K>` = `--N 10 --olcek 330 --takim 25,50,buyuyen` (N=10, ölçek 330, ~15-60 sn); `<K3N>` = `--N 5,7,10 ...` (G1 için)

**Tam koşular (2)**, B kolu (bilinen yol) yok:
- `python -I sim.py <TAM> --cikti ../out/tur2/sim3_tam_aday.json` (kural adayları kapalı) · `... <KURAL3> --cikti ../out/tur2/sim3_tam_kural.json` (üçü açık).

**Kısmi koşular (43)**, hepsi `../out/tur2/sim3_k_*.json` ve `sim3_m_*.json`, ayrıntı §5'te. Okuyucular: `sim3_oku.py` (kapı özeti), `sim3_tablo.py` (tam tablo), `sim3_fiyat_kapi.py` (fiyat kapısı), `sim3_kontrol.py` (bağımsız kontrol).
Yeni bayraklar varsayılan KAPALI; kontrol: ADAY tabanı (`sim3_k_taban.json`) eski `sim2_sonuc_aday.json` ile G4, G6, G2, G5 ve demo hücrelerinde sayı sayı aynı çıktı.

---

## 1. Kapı tablosu (N=10, bitiş 2030; ayrıca 2035)

Hücreler: G6 için takım 25, 50 ve büyüyen × durgun dışı 5 bot (ölçek 330); G7 bütün kolların havuzu; G4 durgun bot, takım büyüyen / 25 / 50;
G2 güçlü botlar (odaklı, verimli, öncü), büyüyen takım. Yüzdeler tohum medyanı ya da koşu payıdır.
İki sütun: **taban** = `sim3_tam_aday.json` (SIM3 sabitleri + Ar-Ge +1, öncü bot "erken"; kural adayları KAPALI);
**+ kural** = `sim3_tam_kural.json` (aynısı + dönem hattında ilk yıl şart + 2027 ihale + ürün dışı ayrılma %4,7/2,7/1,7/1,0/0,7).

| Kapı | Alt şart (hedef) | **taban** | **+ kural** |
|---|---|---|---|
| **G1** | N=10: 2014 sonrası modül medyanı tavanın ≥ 1 altında; dev hatlarının ≤ %60'ında tavanda | ✅ dev en çok 2015'te %59 (2035'e kadar aynı) | ✅ aynı dünya |
| | N=5 ve N=7 (karşılaştırma) | ❌ dev 2015 ve 2017'de %82 / %77 | ❌ aynı |
| **G2** | erken (2012-2017) güçlü bot herhangi modülde lider ≤ %5 | ✅ %3 | ✅ %3 |
| | 2022 sonrası toplam payda devin önüne geçme ≥ %50 (2030 / 2035 sonu) | ❌ %8 / %32 | ❌ %20 / %38 |
| | (bilgi) sonda hatların ≥ yarısında üründe devin önünde (2030 / 2035) | %77 / %100 | %77 / %100 |
| | (bilgi) N=5 / N=7 geç gölge pay, 2030 / 2035 | %45 / %93 · %23 / %65 | %68 / %98 · %35 / %73 |
| | (bilgi) botlara göre, 2030 | verimli %25, odaklı ve öncü %0 | verimli %60, öncü ve odaklı %0 |
| **G3** | öncü bot (büyüyen takım) dönem hatlarının ≥ %50'sinde ilk K1; dev ≤ %20 | ✅ 3,5 / 6 hat (%63), yalnız teknoloji hatları 2,5 / 4 (%71); dev ilk olduğu hat payı: hepsi ❌ %35, teknoloji ✅ %0 | aynı (öncü politikası "erken"; "mevcut" politikada %37 ❌, §4.7) |
| **G4** | durgun kol 104 haftada B2B MRR'nin ≥ %40'ını kaybeder | ✅ %42 / %41 / %45 (büyüyen / 25 / 50) | ✅ %42 / %49 / %46 |
| | kayıpların ≥ %95'i adlı (ürün dışı ayrılma nedeniyle yazıldığı için adlı) | ✅ %100 | ✅ %100 (ürün dışı hariç sayılırsa %61-69, bilgi) |
| | kaybedilen 1★ ≤ %30 | ✅ %4 | ✅ %12-16 |
| | ayrı sürüm ritmi cezası yok | ✅ modelde yok; durgunun ilgi çarpanı 0,81-0,82 | ✅ aynı |
| | **G4 sonucu** | ✅ | ✅ |
| **G5** | mail medyan ≤ 2, p99 ≤ 5 | ✅ 0 / 4 | ✅ 0 / 5 |
| | sprint başına istek kartı ≤ 3 (p95) | ✅ 3 (en kötü tohum 4) | ✅ 3 (en kötü tohum 3) |
| | yılda şartlı yenilenen %5-25 | ❌ %0-0,8 | ❌ %0-1,3 |
| **G6** | yenilemelerin %20-50'sinde koltuk değişir | ✅ %21-29 | ✅ %26-30 |
| | 1★ yıllık büyüyen ≤ %10; yıldız değişimi ≤ %10 | ✅ en çok %4,9; %3,6 | ✅ en çok %5,0; %3,8 |
| | 1.000 koltuk üstü yok | ✅ yapı gereği (1.000'de kesilir) | ✅ yapı gereği |
| | (bilgi, kapı değil: Erdem 2026-10-17 gerçek dünya tutma bantlarını kaldırdı) 1★ tutma, gerçek SMB bandı %75-88 | %99,1-100 | %95,2-95,5 |
| | (bilgi) 5★ tutma, gerçek kurumsal bandı %90-97 | %48-100 (15 hücrenin 5'i bantta) | %74-99,5 (5'i bantta) |
| | **G6 sonucu** (SENTEZ §13.2 tanımı: koltuk, yıldız, 1★ büyüme, 1.000) | ✅ | ✅ |
| **G7** | eşleşen satıcı, tam uyum, 1★ kapanış %75-92; 5★ %45-60 | ✅ %91,4 (n 454.098); %49,8 (n 679) | ✅ %91,5 (n 581.107); %48,5 (n 1.187) |
| | bir yıldız alttaki satıcı / eşleşen 0,5-0,75 | ✅ 3★ 0,59 · 4★ 0,60 · 5★ 0,61 | ✅ 0,58 · 0,61 · 0,62 |
| | iki yıldız alttaki satıcı yasak; %100 yok; iki kat bayat aday ≤ %5 | ✅ yapı gereği (ulaşılamayan aday 4★ 21.292, 5★ 15.874); en yüksek ihtimal %92; bayat %0,45 (en kötü hücre %1,8) | ✅ aynı; bayat %0,40 (en kötü %1,7) |
| | **G7 sonucu** | ✅ | ✅ |
| **G8** | ekip, havuz, negatif yok | ✅ 0 ihlal | ✅ 0 ihlal |
| **G9** | her yıl K1-K2 ürünle kazanılabilir ≥ 6 adet 1★-2★ aday | ❌ geride kalan oyuncuda 2022'den sonra yılda 0 (durgun); tek kurucu 2028'den sonra 0 (§4.8) | ❌ aynı |
| **G10** | istek ve şart oranı ölçekler arasında ±%30 (büyüyen takım) | istek ✅ %21 · şart ❌ %34 | istek ✅ %25 · şart ✅ %14 |
| | istek ve şart oranı takım kolları arasında | ❌ %79 / %92 (yapısal, §11.1) | ❌ %78 / %98 |
| **Demo** | ilk 104 hafta 5★ kapatma ≤ %5 tohum | ✅ büyüyen takımda %0 (her bot) | ✅ %0 |
| | 4★ emekle ulaşılabilir | ❌ büyüyen takımda %0-5; satıcı bot 3 kişiyle %35-55, 6 kişiyle %75-85 | ❌ aynı biçim |
| **Tempo** | tek kurucunun ilk K1'i ≤ 6 hafta | ✅ 3-4 hafta | ✅ 3-4 hafta |
| | ilk 104 haftada kurucu ve 3-6 kişilik ekip en az 2-3 modülde K3 | ❌ 3 kişi: 0 modül (kapasite 2,4); 6 kişi: 1-4 (kapasite 4,5-5,7); büyüyen: 0 (kapasite 1,6-2,1); tek kurucu: 0 (0,8-1,1) | ❌ aynı (§4.6) |
| **Sıralama** | yıllık rapor + modül ödülü (prob, eşik yok) | §4.3 | §4.3 |
| **Fiyat** | hiçbir duruş tohumların %80'inden fazlasında en yüksek MRR'yi vermez | ❌ iki turda da (§4.4): pahalı duruş havuzda %66, huni serbestken %75; en kötü hücre %95-100 | ❌ aynı |
| | (bilgi) önerilen fiyat kolu C, standart duruş, A'ya göre MRR | C / A 1,29-1,40 | aynı |
| **G11** | tek 5★ hesap ≤ 20.000 $ | Erdem 30 ("5★'ın yüksek geliri sorun değil") ile hükmü düştü. Bilgi: 5★ MRR medyanı 19.000-23.200 $ (A), en çok 50.000 $; 5★ hesapların %45-71'i tek başına seed kapısını aşıyor | aynı biçim |
| | 50 kişide gelir / gider 1,2-2 | ❌ masa başı (yeni koşu yok): gerçekçi kadroda 2,0-3,1; yalnız hep kıdemli kadro bantta (1,1-1,8); ölçek 600 sim sabiti, bant ~250-410 hesapta tutar (SENTEZ §13.5) | aynı biçim |
| **G12** | maliyet | SIM1'de raporlandı (~55 işlem/hafta, dünya 0,08 sn); kod kapısı ayrı | |

Seçilen SIM3 sabitleri ve neden (hepsi [WORKING], kaynaksız): `eskime_memnuniyet` 0 → 2 (G4 kaybı %34-44'ten %41-45'e, kapı tur 1'de geçti); `istek_omur_hafta` 26 → 13 (G5 kartı p95 4 → 3, tur 1'de geçti).
Bunlar `sim/sim3.json`'dadır. Hiçbir başka sabit kapıyı geçirmek için değiştirilmedi.

---

## 2. Bu kapıların modele söylediği

**Geçenler.** Durgunluk (G4) memnuniyet eskimesiyle (hat başına, adım başına 2 puan) eşiğe ulaştı: durgun oyuncu 104 haftada MRR'nin %41-45'ini (kural adaylarıyla %42-49) kaybediyor, hepsi adlı.
Kayıp kanalı mevzuat (e-Belge 2016) + modül eskimesi; kural adaylarıyla ayrıca ürün dışı ayrılma. İstek kartı p95 3'e indi (hem eskime hem 13 haftalık ömür tek başına indiriyor, §5).
Satış zarı (G7) her koşuda aynı: eşleşen satıcıyla 1★ %91, 5★ %49, bir yıldız alttaki satıcı 0,58-0,62 kat. Bunun büyük kısmı formülün kendisidir; asıl sınav oynanışta.
Öncülük (G3) öncü botun "yeni dönem hattı öncelik 1" politikasıyla teknoloji hatlarında %71'e çıkıyor (politikasız %42).

**Geçmeyenler ve neden.**
1. **Tutma bilgi olarak gerçek dünyanın altında kalıyor, kapı değil.** Ürün dışı ayrılma olmadan iyi oyuncu 1★'ı hiç kaybetmiyor (%99-100). Eski kural oranının üçte birinde (1★ %4,7) tutma %95; üçte ikisinde (%9,3) %90-91; tam kural oranında (%14) %85,5-86,6, yani gerçek SMB bandında (%75-88) ancak orada ve G4'ün 1★ kaybı o zaman %28-30 (eşik %30) olur.
   Erdem 2026-10-17 hedefi "gerçek hayat kadar zorlamak değil, sağlıklı büyüme" dediği için üçte bir oran G6 kapısını (koltuk, yıldız, büyüme) ve G4'ü geçiriyor. 5★ tutma 15 hücrenin yalnız 5'inde gerçek bantta: alt uç kısa yoldaki zayıf botlar (odaklı büyüyen %48-74, satıcı büyüyen %75-80), üst uç baştan 50 kişilik kollar (%99-100).
2. **Dev pazar payı (G2 geç).** Güçlü botlar 2030'da hatların %77'sinde ürünle devin önünde, ama toplam payda geçemiyor (kural kolunda oyuncu %16, dev %25). Pay devrini %12 → %20 ve 2027 ihale payını %30 → %50 yapmak 2030'da %35'e, 2035'te %52'ye çıkarıyor (§5, madde 3); yine de 2030 için ❌. Sonuç N'ye çok bağlı: 5 modülde aynı ayarlarla %97 / %100.
3. **Tempo.** İki parçalı eforla (K3 = 111 puan) 104 haftada kurucu ve 3-6 kişilik ekip K3'e neredeyse hiç varamıyor; G1'i tutan her eğri bunu bozuyor ve tersi (§4.6).
4. **Fiyat.** Önerilen fiyat formülü sim'de çalışıyor (örnekler SENTEZ'in 39 / 57 / 52 / 43 / 71 $'ıyla bire bir), ama ×1,15 fiyat + ×0,85 kapanış çarpanıyla "pahalı" duruş tek doğru cevap oluyor. Satış hunisi hacmi kapanış ihtimalinden çok az etkileniyor (§4.4).
5. **Ölü bölge (G9).** Geride kalan oyuncu için 1★ hesabın "S − 2'ye razı" kuralı, standart yürüdükçe K1-K2 ürüne hiç aday bırakmıyor; bu G4'ün (durgunluk cezası) doğrudan sonucu (§4.8).
6. **Şartlı yenileme (G5 alt sınır)** hiçbir kolda doğmuyor (%0-1,3); SIM3'ün kapsamı dışındaydı, açık.

**Modelde olmayanlar (güncel).** Ayrı bir Ar-Ge araştırma kuyruğu (Ar-Ge tavanı "premium efor ile +1 kademe" olarak kuruldu, §4.5), yıllık raporun ve modül ödülünün oyundaki biçimi (sim yalnız sırayı ölçer), B2C, sektör artıları ve eksileri.

---

## 3. Katmanlar (`sim2.json`, `sim3.json`)

SIM2 katmanı değişmedi (gerekçeleri kayıtlı değil, onay bekliyor):

| Sabit | constants.json | sim2.json | Okunan etki |
|---|---|---|---|
| `satis_modeli` | süzgeç | **zar** | Erdem 6-7: satış zarı (ayar değil, cevap) |
| `koltuk_esik` | max(2, %10) | max(1, %5) | koltuk değişen yenileme SIM1'de %11-19, SIM2'de %22-29 (G6 bandı) |
| `gidis_olasilik` 2★-5★ | büyüyen %20-25 · durağan %55-62 · küçülen %18-20 | %30 · %45 · %25 | koltuk hareketini artırır (G6) |
| `gidis_yeniden_cek` | 0,3 | 0,5 | aynı yönde |
| `sart_sure_hafta` | 26 | 13 | gerekçe kaydı yok (G5 şartlı bandı yine ❌) |
| `memnun_esik` / `dusuk_esik` | 70 / 40 | 80 / 50 | gerekçe kaydı yok |
| `dusuk_yildiz_sart` | 0,2 | 0,3 | gerekçe kaydı yok |

SIM3 katmanı (`sim3.json`, `--ek`), yalnız kapısını geçenler:

| Sabit | eski | yeni | Neden |
|---|---|---|---|
| `eskime_memnuniyet` | 0 | 2 | madde 1: G4 kaybı %34 / %39 / %44 → %41 / %41 / %45 (taban + tek başına), kapı geçti |
| `istek_omur_hafta` | 26 | 13 | madde 4: G5 kart p95 4 → 3 (ADAY tabanında tek başına), kapı geçti. Yan etki: 13 haftada düşen istek karşılanmadığı için 26 haftalık bekleme cezası (−5 memnuniyet) artık hiç işlemiyor |

Denendi, **sabit değişmedi** (kapı geçmedi ya da karar Erdem'de): `pay_devri` 0,12 → 0,2 ve `dev_ihale_payi` 0,3 → 0,5 (G2 geç ❌); `urun_disi_ayrilma` (KURAL adayı, üçte biri: G4 ve G6 kapıları ✅, karar Erdem'de); kadro kuralı "d"; rakip kasası; fiyat çarpanları; efor eğrisi (`efor_g_giris` 3,5 / 3,0).
Eklenen kapalı mekanikler (`constants.json` `_sim3`): `arge_tavan` (+ `arge_baslangic_yili` 2018, `arge_carpan` 1,5), `kadro_kurali` / `kadro_dilim` 8 / `kadro_asama_payi` 0,5, `rakip_kasa`, `fiyat_formul` ve fiyat sabitleri, `oncu_politika`, `istek_geri`, `istek_en_cok`, `satis_hedef_carpan`.

---

## 4. Problar

### 4.1 G4 hücreleri (N=10, 2015 başındaki portföy, 104 hafta; `sim3_tam_aday.json` / `sim3_tam_kural.json`)

| Takım | MRR kaybı medyan (en az-en çok), taban | + kural | adlı (kural; ürün dışı hariç) | 1★ kayıp (taban / kural) | kayıp kanalı (kural, sayı) | yeni imza (kural) |
|---|---|---|---|---|---|---|
| büyüyen | %42 (%13-66) | %42 (%21-61) | %100 (%61) | %4 / %16 | ürün dışı 66, mevzuat 52, modül 50, platform 3 | 46 |
| 25 | %41 (%26-58) | %49 (%33-68) | %100 (%69) | %4 / %12 | ürün dışı 364, mevzuat 797, dönem hattı 3 | 120 |
| 50 | %45 (%32-55) | %46 (%34-65) | %100 (%66) | %4 / %14 | ürün dışı 486, mevzuat 928, dönem hattı 3 | 75 |

Eskimenin etkisini ayırmak için (kısmi koşular, N=10, kural adayları açık): eskime 0 / 2 ve ürün dışı üçte biri 0 / açık → kayıp %34-44 (hiçbiri) · %39-46 (yalnız ürün dışı) · %41-45 (yalnız eskime) · %41-49 (ikisi).
Ürün dışı ayrılmayı "adlı" saymak (SENTEZ tanımı) G4'ün adlı alt şartını kural kolunda %100'e çıkardı; eski sayı (%37-43) tanım farkıydı.

### 4.2 Demo (ilk 104 hafta, N=10, ölçek 330; `sim3_tam_kural.json`): en az bir 4★ / 5★ kapatan tohum payı

| Bot | büyüyen | 1 | 3 | 6 | 12 | 25 | 50 |
|---|---|---|---|---|---|---|---|
| odaklı | %0 / %0 | %0 / %0 | %0 / %0 | %60 / %0 | %95 / %0 | %100 / %65 | %100 / %70 |
| verimli | %0 / %0 | %0 / %0 | %0 / %0 | %65 / %0 | %90 / %0 | %100 / %70 | %100 / %80 |
| satıcı | %5 / %0 | %0 / %0 | %35 / %0 | %85 / %10 | %90 / %30 | %100 / %85 | %100 / %75 |
| öncü | %0 / %0 | %0 / %0 | %0 / %0 | %60 / %0 | %90 / %0 | %100 / %60 | %100 / %80 |

Büyüyen takımda ilk 4★ medyan 156-245. haftada, ilk 5★ 374-834. haftada (altı bot). Taban kolunda aynı biçim (satıcı 3 kişi %55 / 6 kişi %75).

### 4.3 Sıralama (Erdem 29; N=10, 2013-2030 = 18 yıl, büyüyen takım; yılların payı; `sim3_tam_kural.json`)

| Bot | modül top-3 | modül ödülü (1.) | kalabalık listede top-3 / ödül | sektör (profil) top-3 | yükselen top-3 | en büyükler, gölge sıra 2020 / 2025 / 2030 |
|---|---|---|---|---|---|---|
| odaklı | %94 | %39 | %81 / %39 | %69 | %36 | 4 / 4 / 4 |
| öncü | %94 | %28 | %72 / %19 | %72 | %39 | 4 / 4 / 3 |
| verimli | %100 | %61 | %89 / %56 | %72 | %39 | 4 / 4 / 2 |
| dağınık | %100 | %25 | %67 / %17 | %0 | %39 | 4 / 4 / 2 |
| durgun | %28 | %0 | %0 / %0 | %0 | %11 | 9 / 9 / 9 |

- Modül top-3 neredeyse her yıl geliyor (dağınık botta bile %100): 9 şirketlik listede ucuz bir haber. Anlamlı olan ödül (1.): %25-61, durgun %0 (Erdem 29'un istediği biçim).
- Sektör listesi odaklı oyuncuyu ödüllendiriyor (%69-72), dağınığı hiç (%0). Taban kolunda odaklı botun sektör payı %19 çıktı (öncü %78): bu oynaklık açıklanmadı, tek tohum dizisinin profil seçiminden gelebilir.
- "En büyükler" gerçek sırası her yıl 9/9'dur (düzenek portföyü ölçekte tutar); tablodaki **gölge sıra** pay kuralıyla hesaplanmış tahmindir.

### 4.4 Fiyat (Erdem 30): beşinci kol ve fiyat kapısı

Kol C = önerilen fiyat (SENTEZ §5.6: P0 30 $, modül ağırlığı hafif 0,10 / orta 0,20 / ağır 0,30, kalite çarpanı k = sınırla(1 + 0,5 (r − 1); 0,75; 1,25), duruş çarpanı 0,85 / 1 / 1,15 imzada damgalı,
genişlemede koltuk fiyatı yalnız yeni modülün ağırlığı kadar artar, yenilemede değişmez). Kapanış ihtimaline duruş çarpanı biner (1,1 / 1 / 0,85). Sınıf ataması [WORKING]: ağır = Fatura, İK ve Bordro, Üretim; hafif = Mağaza, Proje; kalan orta.
Standart duruşta büyüyen takım, ölçek 330, 2030 (`sim3_tam_kural.json`):

| Bot | son MRR A / C | C / A | 5★ hesap (n) · MRR medyanı A / C | 5★'ların seed kapısını tek başına aşan payı A / C |
|---|---|---|---|---|
| odaklı | 322.550 / 416.386 $ | 1,29 | 19 · 21.350 / 32.414 $ | %58 / %100 |
| verimli | 437.525 / 614.119 $ | 1,40 | 58 · 21.600 / 37.444 $ | %60 / %100 |
| öncü | 585.550 / 814.112 $ | 1,39 | 97 · 21.050 / 34.279 $ | %59 / %96 |

(A: koltuk 50 $ düz fiyat; B modül eki B/A 1,25-1,30.) Eski "5★ ≤ 20.000 $" hedefi Erdem 30 ile düştü.

**Fiyat kapısı** ("hiçbir duruş tohumların %80'inden fazlasında en yüksek MRR'yi vermez"), 5 bot × takım 25 / 50 / büyüyen × 20 tohum = 300 koşu, her duruş ayrı koşu, tohum başına 2030 MRR (C kolu), `sim3_fiyat_kapi.py`:

| Tur | Düzenek | ucuz / standart / pahalı kazanma payı (havuz) | en kötü hücre | Kapı |
|---|---|---|---|---|
| 1 | SIM2 düzeneği (portföy hedefte sabit), kapanış 1,1 / 1 / 0,85 | %8 / %26 / %66 | pahalı %95 | ❌ |
| 2 | satış hunisi serbest (`satis_hedef_carpan` 4: portföy hedefin 4 katına kadar açık, hacmi huni sınırlar) | %4 / %21 / %75 | pahalı %100 | ❌ |

Neden: portföy sabit hedefteyken imza hacmi yenileme kaybını dengelemek için sabittir (imza/yıl 11,8 / 11,7 / 12,0 üç duruşta), yani kapanış çarpanı hacmi hiç etkilemez. Huni serbestken pahalı duruş %12 az hesap (doluluk 2,06 ve 2,38) ama %15 yüksek fiyat getirir ve MRR'de önde kalır.
**Seçenek ölçümleri** (sabit değiştirilmedi; huni serbest, aynı koşu düzeni; kapanış çarpanları ucuz / standart / pahalı):

| Kapanış çarpanları | ucuz / standart / pahalı payı (havuz) | en kötü hücre | Okuma |
|---|---|---|---|
| 1,1 / 1 / 0,85 (bugün) | %4 / %21 / %75 | pahalı %100 | pahalı baskın |
| 1,25 / 1 / 0,75 | %19 / %29 / %52 | pahalı %90 | havuzda dengeli, hücrede değil |
| 1,4 / 1 / 0,65 | %37 / %34 / %29 | pahalı %85 (verimli bot, baştan 50 kişi) | havuz dengeli; 15 hücrenin 14'ü ≤ %70, bir hücre %85: küçük takımlar ucuz ya da standart, büyük sabit takım pahalı seçiyor |

### 4.5 Ar-Ge tavanı, kadro kuralı, rakip kasası (madde 5, 7, 8; N=5 / 7 / 10, ölçek 330; temel `sim3_k_b1.json`)

Temel = taban + kural adayları + SIM3 sabitleri, Ar-Ge / kadro / kasa kapalı. Her satır tek bir mekanik açıkken:

| Kol | G1 N=10 | G1 N=5 / 7 | G2 geç 2030 (büyüyen) | ürün önde | S artış/yıl (2015-2030) | Not |
|---|---|---|---|---|---|---|
| temel | ✅ dev 2015 %59 | ❌ ❌ | %13 | %88 | 0,31 | |
| **Ar-Ge +1** (2018'den, +1 kademe %150 efor) | ✅ | ❌ ❌ | %20 | %77 | 0,25 | rakipler dönem tavanına yaklaşmıyor (tavana kalan 6, etkin tavana 7): G1 etkilenmedi |
| **Kadro "d"** (⌈0,5 × kart eforu ÷ 8⌉ kişi) | ❌ dev 2015 %62 (eşik %60) | ❌ ❌ | %15 | %90 | 0,31 | tur 1 |
| Kadro "d", aşama payı 1,0 (tur 2, duyarlılık) | ❌ 2015 | ❌ ❌ (N=5'te 2019 da) | %15 | %92 | 0,31 | |
| Kadro "d", aşama payı 0,35 (tur 2, duyarlılık) | ✅ | ❌ ❌ | %13 | %90 | 0,31 | payı küçük alınca sabit 6 kişiye eşdeğer |
| **Rakip kasası, yalnız gelir** (tavan = hesap × 2.200 $ × 12 × %35 ÷ 2,07 milyon $) | ✅ | ❌ ❌ (ayrıca standart K2'de donuyor) | %20 | %100 | 0,22 (N=10), 0,00 (N=5/7) | girişimler (460 hesap) ancak 2 geliştirici taşıyor, ürün çıkaramıyor, standart 2030'da K5,5 (N=10) / K2 (N=5, 7) |
| Rakip kasası, **yalnız yukarı** (eski tavan alt sınır) | ✅ | ❌ ❌ | %12 | %70 | 0,31 | dev 30 → 34 (2030) / 47 (2035); standart değişmedi |
| Üçü birlikte (yukarı kasa) | ❌ dev 2015 | ❌ ❌ | %13 | %50 | 0,25 | |

Okuma: (a) Ar-Ge +1 tek başına G1'i bozmuyor, geç standardı biraz yavaşlatıyor (premium efor); (b) kadro kuralı G1'in 2015 dev doygunluğunu eşiğin üstüne itiyor ya da itmiyor, **birim eşlemesine** (aşama işi = kart eforunun kaçta kaçı) bağlı: payı ≥ 0,5 ise ❌, 0,35 ise ✅. D'nin gerçek birimi bilinmeden karar verilemez;
(c) gelire bağlama, girişimlerin VC fonu olmadan geliri tavanı taşıyamadığı için standardı dondurur; "yalnız yukarı" ise etkisizdir çünkü standart sekiz rakibin üst medyanıdır ve medyanı belirleyen girişim ve yerleşiklerin gelir tavanı eski tavanın altında kalır.

### 4.6 Demo temposu (madde 10; N=10, ölçek 330; `sim3_k_t4.5.json` / `k_t3.5` / `k_t3.0`)

K1 + K2 + K3 = 141,6 puan (5,5 × (1 + 4,5 + 4,5²)). Kapasite = ilk 104 haftada toplam etkin puan ÷ 141,6 (modüllere mükemmel yığılırsa kaç modül K3'e varırdı).

| Efor eğrisi (`efor_g_giris`) | tek kurucu: ilk K1 hf · kapasite · 104. hf K3 | 3 kişi: kapasite · K3 modül (odaklı / verimli / satıcı) | 6 kişi: kapasite · K3 modül | büyüyen: kapasite · K3 modül | G1 N=10 |
|---|---|---|---|---|---|
| 4,5 (ADAY, bugünkü) | 4 · 0,8-1,1 · 0 | 2,4-3,1 · 0 / 0 / 0 | 4,5-5,7 · 2 / 4 / 1 | 1,6-2,1 · 0 / 0 / 0 | ✅ |
| 3,5 | 4 · 1,3-1,7 · 0 | 3,8-4,8 · 1 / 2 / 0 | 6,9-8,7 · 5 / 7 / 4 | 2,5-3,2 · 0 / 0 / 0 | ❌ dev 2015, 2017, 2019 |
| 3,0 | 4 · 1,7-2,2 · 0 | 4,8-6,2 · 1 / 4 / 1 | 8,9-11,2 · 7 / 7 / 6 | 3,2-4,2 · 1 / 1 / 0 | ❌ + modül medyanı tavana <1: 2019, 2021, 2023, 2025 |

Tek kurucunun ilk K1'i ≤ 6 hafta her eğride ✅ (3-4 hafta). K3 kapısı ADAY eğrisinde ❌: 6 kişilik ekipte ancak 1-4 modül, 3 kişilik ve büyüyen ekipte hiç. Botlar yığmıyor, kademeleri modüllere yayıyor (52. haftada 5-10 modülde K1), kapasite sütunu mükemmel yığılmış üst sınırdır ve o da büyüyen takım için 1,6-2,1'dir: hedef (2-3 modül) kapasite olarak bile tutmuyor.

### 4.7 Öncülük (G3; `sim3_k_g3m.json` politika "mevcut", `sim3_k_g3e.json` "erken")

2030 bitişinde açık dönem hattı sayısı medyan 6 (2 mevzuat + 4 teknoloji; teknoloji tarihleri ±26 hafta kaydığı için kurgu 'ajan' hattı bazı tohumlarda 2030 sonunda açık sayılır). "Önce" = oyuncunun ilk K1'i dünyanın ilk K1'inden SIKI önce.
| Politika, N=10, öncü bot, büyüyen takım | hepsi: önce / açık hat | yalnız teknoloji | devin ilk olduğu hat (dünya) |
|---|---|---|---|
| mevcut (dönem hattı 3. öncelik) | 2 / 6 (%37), 2 hat aynı hafta | 2 / 4 (%42) | hepsi %35 ❌, teknoloji %0 |
| **erken** (K1'i olmayan açık dönem hattı 1. öncelik) | 3,5 / 6 (%63) ✅, 2 hat aynı hafta | 2,5 / 4 (%71) ✅ | hepsi %35 ❌, teknoloji %0 ✅ |

Dev tarafı yapısal: mevzuat hatlarında (e-Belge, KVKK) herkes duyuru haftasında başlıyor ve dev en çok ekip olduğu için ilk K1'i alıyor (%35 = 6 hattın 2'si). Kapı "teknoloji hatları" olarak okunursa ✅; "hepsi" okunursa dev payı hep ❌ (kural meselesi, mevzuat ödüllendirilmeyen yarıştır).
Öncü olmayan botlar (odaklı, büyüyen) %17-25.

### 4.8 Ölü bölge (G9; `sim3_k_g9m.json`, `k_g9a`, `k_g9b`; N=10, ölçek 330)

Ölçü: portföy doluluğundan bağımsız gölge aday akışı (ayrı rastgele akış), 1★-2★ aday, en iyi uygun satıcıyla kapanış ihtimali ≥ %25 ise "kazanılabilir"; yıl başına tohum medyanı, 2016-2030 arası en düşük yıl.

| Oyuncu | kazanılabilir 1★-2★ aday/yıl, 2016 → 2030 (2 yılda bir) | G9 (≥ 6 her yıl) |
|---|---|---|
| durgun, her takım | 13-133 (2016) → 0 (2022'den) | ❌ |
| dağınık, tek kurucu | 18 → 18 → 13 → 10 → 2 → 0 → 0 → 0 | ❌ (2026'dan 0) |
| odaklı, tek kurucu | 17 → 17 → 14 → 10 → 9 → 6 → 0 → 0 | ❌ (2028'den 0) |
| aktif, 25 ve 50 kişi, büyüyen | ≥ 40 her yıl | ✅ |

Seçenek ölçümleri (sabit değişmedi), aynı hücrelerde en düşük yıl:
| Kural | tek kurucu (dağınık / odaklı) | durgun | G4 durgun kaybı |
|---|---|---|---|
| bugün: 1★ razı S − 2 | 0 / 0 | 0 | %42 / %49 |
| 1★ razı S − 3 | 0 / 0 (2024'te 8-11, 2026'da 3-6, 2028'den 0) | 0 | %42 / %49 |
| 1★ mutlak üst sınır K2 (`istek_en_cok`) | **9 / 10 ✅** (her yıl 9-13) | 0 | %42 / %49 |

Durgun oyuncu K2 sınırında bile 0 kalıyor (2015'ten donmuş ürünü bazı modüllerde K2'nin altında). G4'ün kaybı seçenekten etkilenmiyor.

---

## 5. Madde madde durum (SENTEZ §13.4) ve çalıştırılan koşular

| # | Açık | Koşu (dosya) | Sonuç |
|---|---|---|---|
| 1 | Durgunluk kaybı ve eskime | `k_taban`, `k_kr`, `k_u3`, `k_u3e2`, `k_e2` | ✅ tur 1: `eskime_memnuniyet` 2 ile kayıp %41 / %41 / %45 (ADAY + eskime) |
| 2 | Ürün dışı ayrılma düşük | `k_u3`, `k_u3e2`; ek `m_ud2`, `m_ud3` | G4 adlı ✅ (ürün dışı nedeni yazıldığı için adlı), 1★ kaybı ✅ %12-16, G6 ✅; bilgi: 1★ tutma üçte bir %95, üçte iki %90-91, tam %85,5-86,6 (gerçek SMB bandı %75-88) |
| 3 | Dev pazar payı | `k_p2` (0,2), `k_p3` (0,2 + 0,5), `m_p3` (son taban) | ❌ iki turda: 2030 %25 → %28 (ara taban), son tabanda %35; 2035'te %52 ✅ ama bitiş yılı 2030 |
| 4 | İstek kartı p95 | `k_o13a` (ADAY + ömür 13) | ✅ p95 4 → 3 (en kötü tohum 5 → 4) |
| 5 | Ar-Ge tavanı | `k_arge`, `k_b1` | G1 ✅ (N=10), G2 geç %13 → %20 ❌ (§4.5) |
| 6 | Fiyat | `k_f_*` (tur 1), `k_h_*` (tur 2), `k_h2_*`, `k_h3_*` (seçenekler) | ❌ iki turda (§4.4) |
| 7 | Kadro tavanı | `k_kadro`, `k_kadro1`, `k_kadro35` | G1 N=10 aşama payı 0,5 ❌ (2015 %62), 0,35 ✅; birim eşlemesi Faz D'ye bağlı |
| 8 | Rakip kasası | `k_kasa`, `k_kasay`, `k_akk`, `k_akk2` | geç standart hızlanmıyor (§4.5); tam bağlama standardı donduruyor |
| 9 | G3, G9 | `k_g3m`, `k_g3e`, `k_g9m`, `k_g9a`, `k_g9b` | G3 ✅ (erken politika, teknoloji hatları); G9 ❌ (§4.8) |
| 10 | Demo temposu | `k_t4.5`, `k_t3.5`, `k_t3.0`, `k_g1_3.5`, `k_g1_3.0` | K1 ✅; K3 ❌ (§4.6) |

Komutlar (hepsi `sim/` içinden; her satırda `--mod sim2 --isci 10 --bkolu-yok --ham <K>` ve `--cikti ../out/tur2/sim3_<ad>.json` var, aşağıda yalnız farklı kısım):
- `k_taban` = `<ADAY>`; `k_kr` = `<ADAY>` + `--ayar donem_ilk_yil_sart=true --ayar dev_ihale_yili=2027`; `k_u3` = `k_kr` + ürün dışı üçte bir; `k_u3e2` = `k_u3` + `--ayar eskime_memnuniyet=2`; `k_e2` = `k_kr` + eskime 2.
- `k_p2` = `k_u3e2` + `--ayar pay_devri=0.2`; `k_p3` = `k_p2` + `--ayar dev_ihale_payi=0.5`; `k_o13` = `k_u3e2` + `--ayar istek_omur_hafta=13`; `k_o13a` = `<ADAY>` + ömür 13.
- `k_b1` = `<ADAY>` + `<KURAL3>` + eskime 2 + ömür 13, `--N 5,7,10 --olcek 330 --takim 25,50,buyuyen`; `k_arge` = `k_b1` + `--ayar arge_tavan=1`; `k_kadro` = `k_b1` + `--ayar kadro_kurali='"d"'`; `k_kadro1` / `k_kadro35` = + `--ayar kadro_asama_payi=1.0` / `0.35`; `k_kasa` = + `--ayar rakip_kasa=true`; `k_kasay` = + `--ayar rakip_kasa='"yukari"'`; `k_akk` / `k_akk2` = Ar-Ge + kadro + kasa (true / yukari).
- `k_t<g>` = `k_b1` ile `--ayar efor_g_giris=<g>`, `--N 10 --olcek 330 --bot odakli,verimli,satici --takim 1,3,6,buyuyen`; `k_g1_<g>` aynısı `--N 5,7,10 --bot odakli --takim buyuyen`.
- `k_g3m` / `k_g3e` = `k_b1` tabanı (efor 4,5), `--N 5,7,10 --bot oncu,odakli --takim buyuyen,50`, `--ayar oncu_politika='"erken"'` yalnız `k_g3e`'de; `k_g9m` / `k_g9a` / `k_g9b` = `--N 10 --bot durgun,daginik,odakli --takim 1,3,25,buyuyen` ve `--ayar istek_geri='[3,1]'` / `--ayar istek_en_cok='[2,99,99,99,99]'`.
- `k_f_<duruş>` = `k_b1` tabanı + `--ayar fiyat_formul=true --ayar fiyat_durus='"<duruş>"'`, 5 bot, takım 25,50,buyuyen; `k_h_*` aynısı + `--ayar satis_hedef_carpan=4`; `k_h2_*` / `k_h3_*` + `--ayar fiyat_durus_kapanis='[1.25,1.0,0.75]'` / `'[1.4,1.0,0.65]'`. Kapı: `python -I sim3_fiyat_kapi.py k_h 2030`.
- `m_ud2` / `m_ud3` / `m_p3`: son taban (`<TAM>` tabanı + Ar-Ge + erken + `<SIM3>` + dönem ilk yıl + ihale) ve ürün dışı `[0.093,0.053,0.033,0.02,0.013]` / `[0.14,0.08,0.05,0.03,0.02]` / üçte bir + `pay_devri=0.2 dev_ihale_payi=0.5`.

Diğer açıklar (SIM2'den, SIM3'te değişmedi): G10 takım kolları kapı tanımı konusu; G5 şartlı bandı ❌; G11 ikinci yarı kalibrasyon girdisi (SENTEZ §13.5).

---

## 6. Sınırlamalar

- **Uydurma dünya, kalibrasyon değil.** Havuz, pay devri (%12), ekip sayıları, memnuniyet dağılımı, yıldız karışımı, Ar-Ge premium çarpanı, modül ağırlık sınıfı, rakip gelir sabitleri kaynaksız ([WORKING], `constants.json`). Sayılar biçimi gösterir.
- **Portföy düzeneği.** Portföy 3 yılda ölçeğe çıkar ve orada tutulur; imza hacmi bu yüzden kapanış ihtimalinden bağımsız çıkar (§4.4, tur 2'de gevşetildi). Gerçek "en büyükler" sırası anlamsız (9/9), gölge sıra tahmindir.
- **G7'nin çoğu yapı gereğidir:** %100 yok, iki yıldız altı yasak ve 1★ tavanı formülden geliyor.
- **Ar-Ge** ayrı araştırma kuyruğu olarak değil, dönem tavanının bir üstündeki kademenin %150 eforu olarak kuruldu; hangi modülü araştıracağını bot seçmiyor, tavana varan hat kendiliğinden açıyor. **Kadro kuralı** D'nin birimiyle (puan = kişi-hafta?) bire bir eşlenmedi (aşama payı varsayımı 0,5).
- **Rakip kasası** yalnız gelir tavanıdır: rakip kasası, sermaye ve VC modellenmedi, girişimler dışarıdan fon almıyor.
- **Memnuniyet eskimesi** artık açık (2); hat başına, adım başına eşit puan.
- **Botlar kusursuz önceliklendiriyor** (G3'te "erken" politika bir harness değişikliğidir, oyuncu davranışı değil); insan oyuncu şartı kaçırabilir.
- **Kart başına 6 kişi** (kadro "sabit" kolunda) Faz D'nin yer tutucusudur.
- **SIM2 katmanının gerekçeleri kayıtlı değil** (§3).
- Bu rapordaki her SIM3 sayısı `sim3_*.json` dosyalarından okundu; okuma betikleri `out/tur2/sim3_*.py`.

### Bağımsız kontrol (ikinci türetme)

`sim3_kontrol.py`, sim.py'nin yolundan ayrı hesapla en önemli sayıları yeniden türetti. Hepsi tuttu, düzeltme gerekmedi.

| Sayı | İkinci yol | Sonuç |
|---|---|---|
| Önerilen fiyat formülü | SENTEZ §5.6 örnekleri elle (39 / 57 / 52 / 43 / 71 $) ve sim'in damgaladığı 504 hesap fiyatı, kaydedilen (modül, r) çiftlerinden yeniden hesaplandı | örnekler 39,0 / 57,0 / 52,3 / 42,8 / 71,2 (SENTEZ 39 / 57 / 52 / 43 / 71); 504 / 504 hesap eşleşti (en büyük fark 1e-14) |
| Tempo: büyüyen takım 104 haftada etkin puan | takım takvimi (1 kişi 52 hf, 3 kişi 52 hf), geliştirici payı, ek yük %25, hata yükü 0,28, yeni kod bölenine göre elle | 237 puan (hesapsız üst sınır) · sim 232 → kapasite 232 ÷ 141,6 = 1,64 (tablo 1,6) |
| G1 dev doygunluğu 2015 | yıl satırlarından dev_tavanda ÷ dev_hat | 9,5 ÷ 16 = 0,594 (≤ 0,60) |
| G2 geç %20 (kural, büyüyen) | üç botun hücrelerinden ağırlıklı ortalama (n = 20 her biri) | 0,200 = sim 0,200 |
| Fiyat kapısı (huni serbest) | ham MRR dizilerinden tohum başına kazanan, ters sırayla yeniden sayım | ucuz 0,04 / standart 0,207 / pahalı 0,753 (n 300) = §4.4 |
| Eski tabanla uyum | `sim3_k_taban.json` ile `sim2_sonuc_aday.json`: G4, G6, G2, G5, demo hücreleri | 0 fark (koşulan hücrelerde) |
