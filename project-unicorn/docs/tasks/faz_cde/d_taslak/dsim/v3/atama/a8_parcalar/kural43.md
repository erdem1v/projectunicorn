Kapatma ölçümleri (aynı 20 tohum). `P_rp` = tam P, satır seçimi eski kuralla (plan sırasındaki en önde açık satır; "ihtiyaç önde" satır seçimi kapalı):

*P − P_rp* (satır seçiminin etkisi)

{{tab:rp_fark}}

**Okuma.** Her adım ayrı ayrı sorulduğunda:

1. **Plan sırası** (T_plan, A6): Tarif'in MVP, söz ve açık hata bedellerinin nedeni. 3 kişide MVP {{m:T:S2:mvp}} → {{m:T_plan:S2:mvp}}, kaynaklı 3 kişide açık hata {{m:T:PR_S2:acik}} → {{m:T_plan:PR_S2:acik}} (A6 §4.4). P bu sırayı korur.
2. **İleri oynatma** (P − P_sabit; eksi = P lehine MVP, açık hata ve söz için): MVP haftası 6 kişide {{dm:P:P_sabit:S3:mvp}} (her iki arzda aynı), 12 kişide {{dm:P:P_sabit:S4:mvp}} (sınırsız); açık hata 6 kişide {{dm:P:P_sabit:S3:acik}} (sınırsız), kaynaklı 6 ve 12 kişide {{dm:P:P_sabit:PR_S3:acik}} / {{dm:P:P_sabit:PR_S4:acik}}; kaynaklı 6 kişide kaçan söz {{dm:P:P_sabit:PR_S3:soz}}; kaynaklı 50 kişide teslim {{dm:P:P_sabit:PR_S6:teslim}} puan/hf. Karşılığı: 25 ve 50 kişide sınırsız arzda açık hata P'de {{dm:P:P_sabit:S5:acik}} / {{dm:P:P_sabit:S6:acik}} daha fazla (hafta başı seçim sprint ölçüsüne bakıyor, açık hata sprintten uzun bir şey; A3'ün usta aramasında da aynı yön). 3 kişide ve 25 kişide MVP, söz ve teslimde fark yok.
3. **Saklama seçenekleri** (P − P_core5): 6 kişide MVP haftası {{dm:P:P_core5:S3:mvp}} (her iki arzda); başka hücrede ayırt edilemiyor. Mikro test: Yazılım satırında testçi, asıl işi (test) sprintte beklerken yazılıma kilitlenmez.
4. **Satır seçimi** ("ihtiyaç önde", P − P_rp): kaynaklı 3 kişide açık hata {{d:P:P_rp:PR_S2:acik}}, teslim {{d:P:P_rp:PR_S2:teslim}}; başka hücrede ayırt edilemiyor. Erdem'in örneğinde (§2) küçük kartların testinin sprint içinde yapılabilmesi buna bağlı: eski satır seçimiyle (`P_rp`) iz 1'de küçük kartlar h3,18'de, ikinci sprintte biter, çünkü geliştiriciler büyük kartın yazılımını sürdürür ve biten kartların testi onun bitmesini bekler; ihtiyaç önde kuralıyla h1,80 ve h1,87'de, ilk sprintte biter.
5. **Yer değişimi** ("karmaşık kart daha iyi kişilere", `P_sabit` − `P_ns`; ikisi de ileri oynatmasız ve satır seçimi aynı): doğan hata 6 / 12 kişide {{d:P_sabit:P_ns:S3:dogan}} / {{d:P_sabit:P_ns:S4:dogan}}, 25 / 50 kişide {{d:P_sabit:P_ns:S5:dogan}} / {{d:P_sabit:P_ns:S6:dogan}}; teslim, MVP ve açık hatada da fark yok. Yani bu kart verisiyle adımın ölçülebilir ek kazancı yok (§7).
6. **"Kalır"** (P − P_np; T_plan − T_plan_np): T_plan'da "kalır" MVP'yi kaynaklı 6 kişide {{dm:T_plan:T_plan_np:PR_S3:mvp}} hafta geciktiriyor (T_plan'da kilidi bilen bir şey yok); P'de aynı bedel yok (P − P_np: MVP {{dm:P:P_np:PR_S3:mvp}}; açık hata {{dm:P:P_np:PR_S3:acik}}, teslim {{dm:P:P_np:PR_S3:teslim}} puan/hf). Yani kilit P'de küçük bir bedel taşıyor (kaynaklı 3-12 kişide açık hata en çok +0,5, teslim en çok −0,4 puan/hf); planlayıcı kilidi bilerek kurunca T_plan'ın MVP bedeli yok oluyor.
7. **Plan puanı sırası** (`ρ`): 0,5 / 0,85 / 1,0 arasında MVP, açık hata, teslim ve doğan hata ayırt edilemiyor; kaçan söz yalnız ρ = 1,0'da (her kart eşit) biraz kötü (kaynaklı 6 kişide {{m:P_r1:PR_S3:soz}}, ρ = 0,85'te {{m:P:PR_S3:soz}}).

{{tab:rho_soz}}

**Hafif kip (ileri oynatmasız P, `P_sabit`) tüm hücrelerde** (aynı dağıtım kuralı, her hafta tek seçenek, plan başına 1 oynatma; plan ekranı her "+" tıklamasında yeniden hesaplarken ucuz yol):

*MVP haftası*

{{tab:sabit_mvp}}

*Açık hata*

{{tab:sabit_acik}}

*Teslim (puan/hf)*

{{tab:sabit_teslim}}

*Kaçan söz (kaynaklı arz)*

{{tab:sabit_soz}}

Eşli farklar (P − P_sabit):

*MVP haftası*

{{tab:sabit_fark_mvp}}

*Açık hata*

{{tab:sabit_fark_acik}}

*Teslim (puan/hf)*

{{tab:sabit_fark_teslim}}

*Kaçan söz (yalnız kaynaklı arz)*

{{tab:sabit_fark_soz}}

### 4.4 Teslim açığı nereden geliyor (A9 incelemesinde düzeltildi)

P'nin 12 ve 25 kişide R'ye göre teslim kaybı ({{d:P:R:S4:teslim}} ve {{d:P:R:S5:teslim}}) nereden geliyor? İlk sürüm bunu gereksinim kapısına bağlamıştı (`P_gyok` kolu, kapı yok). Bu yanlıştı: `P_gyok` kapıyla birlikte hata modelinin gereksinimini de sıfırlıyor (`req = yok`), yani her kart "1 yıldızlık iş" sayılıyor ve doğan hata üçte bir düşüyor; düzeltme işi azalınca teslim artıyor. Kapının kendi etkisini ayırmak için iki kol eklendi (`a9run.py`, ham sonuçlar `out9/`):

- `P_kapi_k9`: kapı yok (gereksinimin altındaki kişi karta girebilir), hata modeli kartın gerçek gereksinimini kullanır.
- `P_pmZ_k9`: kapı var, PM kartı Karar 21'in (ii) okumasıyla seçer (zor karta en iyi PM, kalanlar boştaki en iyi PM sırayla; A6 §3). `P_pmR_k9`: PM'i R'nin kuralıyla seçer (yalnız tanı; Karar 21'e uymaz).

*Teslim (puan/hf)*

{{tab:gyok}}

{{tab:gyok_fark}}

*Doğan hata*

{{tab:gyok_dogan}}

{{tab:gyok_fark_dogan}}

*Boşta (PM hariç)*

{{tab:gyok_fark_bosta}}

Okuma:

1. **Kapı teslimi düşürmüyor.** Hata modeli aynı tutulunca kapıyı kaldırmak teslimi değiştirmiyor: P − P_kapı 12 / 25 kişide {{d:P:P_kapi_k9:S4:teslim}} / {{d:P:P_kapi_k9:S5:teslim}}. Kapı kalkınca gereksinimin altındaki kişiye düşen Yazılım işi R düzeyine çıkıyor (12 kişide {{m:P_kapi_k9:S4:altinda}}, R {{m:R:S4:altinda}}) ve doğan hata artıyor: P − P_kapı 12 / 25 kişide {{d:P:P_kapi_k9:S4:dogan}} / {{d:P:P_kapi_k9:S5:dogan}}. Yani kapı bedava: teslimden bir şey götürmüyor, doğan hatayı %3-5 azaltıyor. P'nin R'ye göre doğan hata kazancının (§1.2) neredeyse tamamı kapıdan: kapısız P'nin doğan hatası R ile ayırt edilemiyor ({{d:P_kapi_k9:R:S4:dogan}} / {{d:P_kapi_k9:R:S5:dogan}}). Boşta farkı da kapıdan değil (P − P_kapı 12 kişide {{d:P:P_kapi_k9:S4:bosta}}).
2. **Sınırsız arzda açık PM okumasından geliyor.** Aynı planlayıcıda PM'i (ii) okumasıyla seçince 12 kişide teslim R düzeyinde ({{d:P_pmZ_k9:R:S4:teslim}}), 25 kişide açık {{dm:P:R:S5:teslim}}'den {{dm:P_pmZ_k9:R:S5:teslim}}'e iniyor; doğan hata da düşüyor (P_pmZ − P 12 kişide {{d:P_pmZ_k9:P:S4:dogan}}). R'nin PM kuralıyla (`P_pmR_k9`) 12 ve 25 kişide açık kapanıyor ({{d:P_pmR_k9:R:S4:teslim}} / {{d:P_pmR_k9:R:S5:teslim}}). Bu, A6 §3'ün tarif için bulduğu (ii) − (i) farkıyla aynı yönde.
3. **Kaynaklı arzda açığın yarısı kalıyor ve kaynağı ayrılmadı.** Kaynaklı 12 / 25 kişide (ii) okumasıyla bile {{dm:P_pmZ_k9:R:PR_S4:teslim}} / {{dm:P_pmZ_k9:R:PR_S5:teslim}} puan/hf (R'nin PM kuralıyla da {{dm:P_pmR_k9:R:PR_S4:teslim}} / {{dm:P_pmR_k9:R:PR_S5:teslim}}). "Kalır" bunu açıklamıyor (P − P_np kaynaklı 12 kişide {{d:P:P_np:PR_S4:teslim}}); tarif ailesinin öbür kolları da (T_plan) R'nin altında ({{d:T_plan:R:PR_S4:teslim}}). [DEĞERLENDİREMEM] Kalanın nedeni bu koşularla ayrılamıyor.

### 4.5 İlkenin ölçüsü: karmaşık iş kime gidiyor

Teslim edilen özellik kartlarında kartın karmaşıklığı (puan × Yazılım gereksinimi) ile kartın Yazılım işini yapanların iş payı ağırlıklı ortalama yıldızı arasındaki korelasyon ve en karmaşık çeyrekle en basit çeyreğin ortalama yıldız farkı (`a8ilke.py`; 6 ve 12 kişide 8 tohum, 25 kişide 4 tohum; 50 kişi çok yavaş olduğu için bu ölçüde yok; tohum sayısı az olduğundan değerler yön gösterir, tablo gibi okunmamalı):

```
{{dosya:out8/a8_ilke.txt}}
```

Sıfıra yakın korelasyon ilkenin işlemediği, pozitif korelasyon karmaşık işe daha iyi kişilerin gittiği anlamına gelir. Okuma: R'de korelasyon sıfıra yakın (en çok 0,19); P'de her hücrede pozitif (0,15 ile 0,50), sınırsız arzda 12 ve 25 kişide dört kolun en yükseği, 6 kişide Tarif ve T_plan'ın altında ama en karmaşık çeyrekle en basit çeyrek arasındaki yıldız farkı P'de en büyük (1,27); kaynaklı arzda P ile Tarif arasındaki fark küçük.

**Test satırında ilke işlemiyor (A9 incelemesi).** Aynı ölçü kartın Test işini yapanların Test yıldızıyla (`a9ilke.py`, 8 tohum):

```
{{dosya:out9/a9_ilke_test.txt}}
```

Test satırında P'nin korelasyonu R ve T_plan düzeyinde (6 kişide 0,20, 12 kişide -0,03; Yazılım'da 0,48 ve 0,50). Nedeni kodda: satır seçimi (`assign_e8`) kişileri sınıf ve hız sırasıyla, en hızlıdan başlayarak satıra alıyor ve satırın açık yeri (Test'te kart başına 1) dolunca duruyor; "yetenlerin en zayıfı" seçimi (`_pick_crew`) yalnız satıra alınmış kişiler arasında yapılıyor. Yazılım satırında yer bol olduğu için herkes satıra giriyor ve ilke işliyor; Test'te basit kartın testine de boştaki en iyi testçi giriyor. Testçinin yakalaması kaçan hatayı belirlediği için bu, Karar 19'un Test'teki karşılığının henüz kurulmadığı anlamına gelir (§7).
