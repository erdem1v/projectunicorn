# SIM1 devri (SIM2 için)

Rapor: `../out/tur2/SIM_RAPOR_1.md`. Sonuçlar: `../out/tur2/sim1_sonuc.json` (resmî ayar), `sim1_sonuc_aday.json` (iki KURAL adayıyla).

## Model yapısı (`sim.py`)
- `Spec` (75): N=5/7/10 hat listesi (modül + 4 platform + 7 dönem hattı); profiller `P_profiles.json`'dan, 7 ve 5 için P'nin katlamasıyla. `modules_for` hesabın modül sırası (önemli, Finans, sektör imzası, temel; S ve N olasılıkla), `wants` yeni modül isteği adayları.
- `effort_table` (166): kademe eforu, üç biçim (`geometrik` resmî; `kuvvet`, `iki_parca` KURAL adayı). `work` (177): puanı öncelik sırasıyla dağıtır, hatta haftada en çok 6 kişilik puan.
- `World` (216): 8 rakip haftalık. `_order` (322) rakibin kart sırası (mevzuat, odakta standarda yetiş, girişimde dönem hattı, odakta lider ol, dönem hattı, genişlik, tavana doldur). `_run` (354) haftalık adım; S = yayımlayanların üst medyanı, L = en iyi ikinci (oyuncu hariç); `Sh`, `Lh` hafta hafta saklanır. `_year_end` (389) havuz, pay (çekim), ekip, satın alma ve yeni girişim, G8 denetimi, yıl sonu anlık görüntüsü. `g1_rows` (464).
- `run_player` (491): oyuncu botu ve hesapları. Hesap olayları yığında: `k` yenileme kontrolü (8 hf önce: istek, şart ya da ayrılma kararı), `y` yenileme (koltuk, yıldız, şartlı yenileme), `i` yıllık istek yoklaması (yalnız 3★+), `s` şart süresi. Portföy ölçeğe 3 yılda çıkar ve tutulur (harness). `order_for` (688) botun öncelikleri. Sonunda iki bitiş penceresinde ölçüler.
- `g1_summary` (964), `player_summary` (1009), `g5_gate` (1046), `g10_rows` (1062), `soru23` (1080), `print_tables` (1120), `main` (1229).
- Dünya oyuncudan bağımsızdır (yalnız portföyün hedef boyu havuzdan düşülür): dünya (N, tohum, ölçek) başına bir kez kurulur, 42 bot x takım koşusu onu okur.

## Ayar noktaları
- G1: `efor_bicim`, `efor_carpani`, `efor_g` (+ `efor_g_giris`, `efor_kirilim`), `havuz_2012` (dev bakım yükü), `rivals.json` ekip, büyüme, tavan, `eras.json` tavan takvimi.
- G5: `istek_olasilik`, `istek_omur_hafta`, `istek_derinlik_hedefi` (`bir_ust` resmî, `piyasa` aday), `istek_onemli_modul_payi`, `yenileme_kontrol_hafta`, `memnun_esik`, `dusuk_yildiz_*`.
- Harness: `olcek_yildiz_karisimi`, `portfoy_*`, `imza_en_cok_acik`, `buyuyen_takim`, `gelistirici_orani`.

## Açık işler
1. KURAL kararı gerekir (co-director): efor eğrisi (`iki_parca` adayı), istek hedefi (`piyasa` adayı). Resmî ayarda G1 2015'te, G5 kart ve şartlı bandı düşüyor.
2. Geç oyun durgunluğu: rakip ekipleri tavanda (30/15/12) ve bakım yükü hesapla doğrusal büyüyor; S 2026 sonrası ~0,2/yıl. Rakip kasa modeli (gelir - maaş, SENTEZ §8.1) yok; ekip tavanı geliri izlemiyor.
3. G2, G3, G4, G6, G7, G9, G11, G12 koşulmadı. Satış zarı yok: imza `imza_en_cok_acik` süzgecidir (SENTEZ §5.2 formülü SIM2'de). Fiyat (Soru 8, F1/F2), yıllık sıralama (Soru 4, S1/S2), bilinen yol (Soru 10, B) modelde yok.
4. Ses patlaması kısmen harness'ten: rampa sırasında aynı haftalarda imzalanan hesaplar yenileme kontrolüne birlikte giriyor (mail tepesi 11-12). Satış zarıyla imza yayılınca yeniden ölçülmeli.
5. Öncü bot dönem hatlarında nadiren ilk (1-2/7): girişimler hattı açıldığı gün başlıyor. G3 için öncü politikası ve dönem hattı tavanı (`donem_ilk_tavan`) gözden geçirilmeli.
6. Kart başına 6 kişi yer tutucudur (Faz D atama araştırması). Geç kademelerde bağlayıcıdır: tek hatta haftada en çok 9 puan.
7. 4★-5★ hesaplar imza süzgecinde çoğu zaman elenir (portföyde 3★+ payı %0-16); satış zarı gelince yeniden bakılmalı.
8. B2C yok; rakip hesapları sayıdır, profil başına değil (çekim bütün havuzda).

## SIM3 bitti (2026-10-22, SENTEZ §13.4 madde 1-10)
- Rapor `../out/tur2/SIM_RAPOR_2.md` (SIM2'nin eski sayıları yenileriyle değişti). 2 tam koşu (`sim3_tam_aday/kural.json`) + 43 kısmi koşu (`sim3_k_*`, `sim3_m_*`); okuyucular `../out/tur2/sim3_oku.py`, `sim3_tablo.py`, `sim3_fiyat_kapi.py`, `sim3_kontrol.py`.
- Yeni bayraklar/sabitler (hepsi varsayılan kapalı): `--ek`, `--N`, `--olcek`, `--bot`, `--takim`, `--bkolu-yok`, `--ham`; `arge_tavan`, `kadro_kurali`, `rakip_kasa` (true | "yukari"), `fiyat_formul`/`fiyat_durus`, `oncu_politika`, `istek_geri`, `istek_en_cok`, `satis_hedef_carpan`. `--mod sim2` G3, G9 ve tempo ölçülerini de yazar. `sim3.json`: yalnız geçen iki sabit (eskime 2, istek ömrü 13).
- Geçmeyenler ve Erdem'e seçenekler: G2 geç (dev payı), fiyat kapısı ("pahalı" baskın), tempo K3 (G1 ile çelişki), G9, kadro birimi, rakip kasası; hepsi SENTEZ §13.4'te. G6 tutma bantları kapı değil (Erdem 2026-10-17).
- Açık işler: şartlı yenileme (G5 alt sınır) hiçbir kolda doğmuyor; G10 takım kolları yapısal; girişim fonu (kasa) ve D'nin gerçek kadro birimi sim'de yok.
