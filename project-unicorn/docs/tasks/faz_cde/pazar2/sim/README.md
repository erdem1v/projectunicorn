# Pazar 2 simülasyonu (SIM1 + SIM2)

ERP modül pazarının biçim simülasyonu: 8 rakip (1 dev, 2 yerleşik, 5 girişim) ve bir oyuncu botu 2012'den 2035'e haftalık yarışır.
Oyun kodunu okumaz; kodun sabitleri `constants.json`'da kaynağıyla elle aktarılmıştır. Uydurma dünyadır: biçim gösterir, kalibrasyon değildir.

## Koşu (yalnız standart kütüphane, Python 3.10+)
- `python -I sim.py --mod tam --isci 8` · SIM1: bütün kollar, 20 tohum, ~4 dk; sonuç `../out/tur2/sim1_sonuc.json`, tablolar ekrana.
- `python -I sim.py --mod sim2 --isci 10` · SIM2: `sim2.json` katmanıyla (satış zarı, fiyat defteri, G2/G4/G6/G7, demo, sıralama,
  bilinen yol kolu); sonuç `../out/tur2/sim2_sonuc.json`. SIM2 alanları SIM1 koşusunu değiştirmez (SIM1 çıktısı bayt düzeyinde aynı kalır).
- `python -I sim.py --mod g1` · yalnız rakip dünyası ve G1 (birkaç saniye); ayar taraması için.
- `--tohum N` tohum sayısı · `--isci N` süreç sayısı · `--cikti yol` sonuç JSON'unun yeri.
- `--ayar ad=değer` sabiti ezer (değer JSON: `--ayar efor_carpani=6`, `--ayar efor_bicim='"iki_parca"'`); noktalı yol
  öbür dosyalara iner: `--ayar rivals.rakipler.0.tavan=45`, `--ayar rivals.turler.dev.modul_tavanda_olasilik=0`.
- Aynı tohum ve aynı ayarla çıktı bayt düzeyinde aynıdır (işçi sayısından bağımsız).
- SIM3 bayrakları (hepsi varsayılan kapalı; öncekiyle aynı sayı): `--ek sim3.json` (sim2.json üstüne ek katman) · `--N 10` `--olcek 330` `--bot odakli,verimli` `--takim 25,50,buyuyen`
  (kısmi koşu, N=10 ölçek 330 yaklaşık 15-60 sn) · `--bkolu-yok` (bilinen yol B kolunu koşma) · `--ham` (tohum başına MRR/doluluk/fiyat örneği).
  Yeni sabitler (`constants.json`, `_sim3`): `arge_tavan`, `kadro_kurali`, `rakip_kasa`, `fiyat_formul`/`fiyat_durus`, `oncu_politika`, `istek_geri`/`istek_en_cok`, `satis_hedef_carpan`.
  `--mod sim2` artık G3, G9 ve demo temposu (`tempo`) ölçülerini de yazar. Komutlar ve sonuçlar: `../out/tur2/SIM_RAPOR_2.md` §0 ve §5.

## Dosyalar
- `sim.py` · tek betik: `Spec` (hat listesi, profil indirgeme), `World` (rakip yarışı, standart S ve L), `run_player` (oyuncu botu ve hesaplar), kapı özetleri ve tablolar.
- `constants.json` · her sabit: değer, kaynak, [WORKING] işareti. SIM1 ayarları (efor ×8, havuz 12.000, istek ömrü 26 hf) burada;
  SIM2 sabitleri de burada, SIM1'i değiştirmeyen değerlerle.
- `sim2.json` · SIM2 katmanı: `--mod sim2` bu değerleri constants.json'un üstüne yazar (SIM2 ayar ve kural kararları). `sim3.json` · SIM3 katmanı (`--ek`): yalnız kendi kapısını geçen iki sabit.
- `eras.json` · dönem tavanı (K3 2012 … K14 2034), dönem hatları (mobil, e-Belge, KVKK, API, YZ, 2 kurgu hat), mevzuat tarihleri.
- `modules.json` · 5 / 7 / 10 modül kümeleri ve 4 platform hattı.
- `rivals.json` · rakipler: tür, ekip, büyüme, tavan, pay, odak profilleri.
- Profil verisi tek dosyada: `../out/tur2/P_profiles.json` (P kolu; 13 sektör, 9 profil, Z/S/N/- hücreleri, 7 ve 5 için katlama).
- `DEVIR.md` · model yapısı, ayar noktaları, açık işler.
- Raporlar: `../out/tur2/SIM_RAPOR_1.md`, `../out/tur2/SIM_RAPOR_2.md`.
