Klasör: `docs/tasks/faz_cde/d_taslak/dsim/v3/atama/`. Hepsi `python -I`, en çok 2 işçi, her python çağrısı 9 dakikanın altında (`chain8.sh` 420 sn bütçeli çağrıları eksik iş kalmayana dek tekrarlar; sonuçlar önbellekli).

```
python -I a8test.py micro ; python -I a8test.py falsify ; python -I a8test.py react ; python -I a8test.py determ ; python -I a8test.py kalir
python -I a8test.py regress 5            # a8plan yüklü, p8 kapalı: R, T, T_plan A6 kayıtlarıyla 0 fark
bash run_a8.sh                           # H1 P (12 hücre, 20 tohum) · H2 ablasyon (P_sabit, P_core5, P_ns, P_np; 6 hücre) · H3 P_gyok
bash run_a8d.sh ; bash run_a8e.sh ; bash run_a8f.sh   # H4-H5 P_sabit tüm hücreler, P_ns büyük ekipler (ilk koşu satır seçimi kuralını yanlış taşıdığı için H8'de yeniden koşuldu) · H6 ρ duyarlılığı · H7 T_plan_np
bash run_a8g.sh                          # H8 P_ns (ileri oynatma ve yer değişimi yok; 10 hücre) · H9 P_rp (satır seçimi eski kural; 8 hücre)
bash chain8.sh ana H P_r5 "S2,S3,S4,PR|S2,PR|S3,PR|S4" 20   # ρ = 0,5
python -I a8test.py tekrar               # kayıtlı P sonuçları son kodla yeniden koşulunca aynı mı
python -I a8sec.py "S2,S3,S4,S5,PR|S3" 3 > out8/a8_secim.txt ; python -I a8dbg.py S2 1 P 2   # hangi seçenek kazanıyor ; bir tohumda seçenek puanları
python -I a8ilke.py S4 8 ; python -I a8ilke.py "PR|S5" 4    # ilke ölçüsü (out8/a8_ilke.txt)
python -I a8test.py dogrula              # tohum sayısı, tahmin = sonuç, gereksinim altı iş, bulunan <= doğan
python -I a8iz.py iz1 R,T,T_plan,P,P_rp > out8/iz1.txt ; python -I a8iz.py iz1b R,T,P > out8/iz1b.txt ; python -I a8iz.py iz2 S2 1 R,T,T_plan,P > out8/iz2.txt
python -I a8rapor.py                     # bu belge (ATAMA/A8_PROAKTIF_PLAN.md), a8_metin.md ve a8_parcalar/ şablonlarından
```

Tek hücre: `python -I a8run.py one P S3 1 H` (kol, senaryo, tohum, kalibrasyon). Kollar (`a8run.py`, `ARMS`): `P` ana planlayıcı; `P_sabit` ileri oynatma yok; `P_core5` saklama seçeneği yok; `P_ns` ileri oynatma ve yer değişimi yok; `P_np` "kalır" kapalı; `T_plan_np` T_plan'ın "kalır" kapalı hâli; `P_gyok` gereksinim kapısı yok ve hata modelinin gereksinimi de 0 (tanı; kapının etkisini hata hacminden ayırmaz, A9: `P_kapi_k9`); `P_r1`, `P_r5`, `P_r85` plan puanı sırası ağırlığı 1,0 / 0,5 / 0,85 (ana kol 0,85, `P_r85` onun yeniden koşusu); `P_rp` satır seçimi eski kuralla. R, Tarif (`T`) ve `T_plan` A6'nın kolları (`a6run.py`).

Dosyalar: `a8plan.py` (planlayıcı: `alloc_p8` dağıtım kuralı, `assign_e8` satır seçimi, `week8` hafta başı seçimi, `rollout`, `plan_score`, `select`), `a8run.py` (koşucu), `a8test.py` (doğrulama), `a8iz.py` (izler), `a8sec.py`, `a8dbg.py`, `a8ilke.py` (tanı sayımları), `a8x.py`, `a8cmp.py` (geliştirme sırasında hızlı karşılaştırma), `a8tab.py` ve `a8rapor.py` (tablolar ve bu belge), `a8_metin.md` ve `a8_parcalar/` (belge şablonu), `chain8.sh`, `run_a8*.sh`, `out8/` (ham sonuçlar, günlükler, izler).

A9 incelemesi (Opus) eklemeleri, aynı klasörde:

```
python -I a8test.py regress 5 > out9/a9_regress.txt                      # p8 kapalı: R, T, T_plan A6 kayıtlarıyla 0 fark
python -I a9run.py tekrar P,P_core5,P_np,P_gyok,P_r5,P_r1,T_plan_np,P_rp,P_ns,P_sabit "S3,PR|S3,S4" 2 > out9/a9_tekrar.txt
python -I a9run.py run P_kapi_k9 "S4,S5,PR|S4,PR|S5"                      # kapı yok, hata modeli aynı (hata2.req_dev gerçek gereksinimle)
python -I a9run.py run P_pmZ_k9 "S4,S5,PR|S4,PR|S5" ; python -I a9run.py run P_pmR_k9 "S4,S5,PR|S4,PR|S5"
python -I a9chk.py                                                       # tablodan seçilen sayılar ham pkl'den, a8tab'sız
python -I a9iz1.py ; python -I a9iz1.py 100 1 ; python -I a9iz1.py 70      # iz 1'in bağımsız kurulumu (a8plan/dsim3 import edilmez)
python -I a9iz1v.py 70 P 1 0                                             # sınır vakası: büyük kart üç kişiyle bu sprintte bitebiliyor
python -I a9ilke.py S4 8 R,T_plan,P test                                 # ilke ölçüsü Test satırında
```
