# OLAYLAR uygulama planı (2. ve 3. adımın birleşimi)

2026-10-26 · Girdi: `step1/revize2.json`, `step2/degistirici.json` + `metin_ekleri.json`, `step3/fiil_seam.json` · Kod: scratchpad kopyası (HEAD). Yapısal çıktı `plan/plan.json` (bu sayfa ondan üretildi: `plan/md.py`). Bütün sayılar [WORKING]: kartın JSON'unda ya da `EvTuning`'de durur.

## 1. Kısa sonuç

- **28 kart dosyası:** görevin 23 kartı (#7'nin üç varyantı dahil) ve 5 ek kart (#5 ayrılış, #25 ortaya çıkış, #31 B2B ikizi, iki basın dosyası: B2C ve B2B). Hiçbiri parka gitmez; karar 9'un iki koşulu tarih penceresiyle, rakip koşulları rakip yuvasıyla kuruldu.
- **İki tablonun 30 çelişkisi** çözüldü (§2). Ağırlık: sayılar 2. adımdan, fiil ve seam kuruluşu 3. adımdan; ikisinin de görmediği bir O4 sorunu yeni bir lint düğmesiyle (yuva `subject: false`) çözüldü.
- **Kod: 5 commit grubu, 42 kalem** (§4): sıra olasılık → kişi → satış ve hesap → altyapı → sprint ve kâğıt. 3. adımın kalemlerinden küçülen ya da düşenler: check dizisi, `olay.stumble_odds`, `hr.role_count`, `decision_line_top`, `urun.decision_step_name`, üç `aday.*` seam'i, `bonus` etiketi, teklif sinyali; yeni: `olay.award_live_*`, L01, `summer_leave` (shift_leave'in yerine).
- **Kayıt sürümü artmaz.** Yeni alanlar varsayılanlı `@export` (Customer, Prospect, Character), `ProductState` bayrakları, kart sözlüğünde `pinned`, motor bloğunda `watch` listesi.
- **Başka oturumlara 6 istek** (§5): URUN_ARAYUZU'na `_assign`'ın kilidi (I01), kâğıt havuzu (I02), sunucu düğmesi (I03); TEMIZLIK'e mail_pane (I04); ikisine ortak dosya bilgisi (I05); yardımcı yönetmene kurgu seçimleri (I06).
- **Öz denetim:** 139/139 kod iddiası kopyada bulundu, 28 kart ve 69 seçenek kurallara karşı tarandı, bulgu 0 (§10).

## 2. Çelişkiler ve çözümleri

| # | Konu | İki tablo ne diyordu | Çözüm ve gerekçe |
|---|---|---|---|
| Ç01 | check dalının anlamı | Görev: '%15 ihtimalle:' + on_fail. Kod: EvDice.check odds ihtimalle PASS döndürür (dice.gd:39-40); 2. adım riski 'risk dalı', 3. adım on_pass dedi. | Risk dalı on_pass'a yazılır, oran o dalın oranıdır; çip boş olmayan her dalı kendi oranıyla çizer (on_fail = 100 − p). GDD §9.2'nin örneği (hr.retention_odds) geçme oranıdır; semantiği ters çevirmek ileride check kullanacak her kartı bozardı. Görevin istediği görünüm (oran + riskli dalın çipleri, tehlike rengi) aynen çıkar. |
| Ç02 | #30 canlı demo: iki zar mı tek zar mı | 3. adım: check dizisi (birincilik ve takılma iki bağımsız zar) + olay.stumble_odds + kesin Marka +3. 2. adım: tek zar, oran açık hatadan düşer, kayıp dalının markası durumdan. | 2. adım. Kesin Marka +3 canlı demoyu öbür şıklardan her yönden iyi yapıyordu; check dizisi motorda tek kartlık genellik olurdu (CLAUDE.md §8). Y02 iki seam: olay.award_live_odds, olay.award_live_slip. |
| Ç03 | #31 kitle yüzdesi | Erdem onaylı −%1 / −%0,5; 2. adım çip yarım yüzde yazamadığı için −%2 / −%1'e katladı; 3. adım Y12 (ondalık çip) önerdi. | Onaylı sayılar kalır, Y12 yazılır (küçük çip işi). 2. adımın kriz.acik metin ekleri düşer. |
| Ç04 | #7 PM 1. şık | 3. adım −%30 verim (eski onaylı). 2. adım +%20 (hazırlık öne alınır); −%30 şıkkı 3. şıktan her yönden kötü yapıyordu. | 2. adım (+%20 / 2 hafta), metin ekleri TR/EN onay bekliyor. |
| Ç05 | #7 testçi varyantının şıkları | 3. adım 'testi geliştiriciler yapsın'ı yeniden kurulacak (P01) saydı; 2. adım onu tuttu, mekanik eşi 'sürüm kaysın'ı prim şıkkıyla değiştirdi. | 2. adım: Erdem'in onayladığı etiket kalır; P01 kapanır. |
| Ç06 | #7 'ikisi de gitsin' çipi ve O2 | Karar 4f 'çip iki izni ve morali yazar' der; 3. adım izni kart uygulamadığı için sahte çip olur dedi. Çipsiz şık O2'de bedava kalır. | Fiil shift_leave yerine summer_leave {apart}: together kipi bu yılın izin haftasını sabitler (gerçek yazım) ve 'aynı iki hafta' çipini bedel olarak çizer. İzni başlatan HR'nin kendi tikidir. |
| Ç07 | #7 prim etiketi | 3. adım yeni 'bonus' etiketi; 2. adım var olan 'retention' ('Bağlılık primi'). | Var olan 'retention'. Yeni etiketler: equipment, gift, award. |
| Ç08 | #7 yuva sırası | revize2: gönderen çiftin kıdemlisi; 2. adım: prim 'other'ın (kayan) maaşından. | employee = önce izne çıkan (gönderen), other = geç başlayan (kayan). kosul_notu değişir; oyuncu metni değişmez. |
| Ç09 | #5 ayrılış gecikmesi | 3. adım 3 hafta, 2. adım 4. | 4 hafta (metin 'dört hafta sonra'; çip '4 hafta sonra: … ayrılır'). |
| Ç10 | #8 sayıları | 3. adım: damage_product (hemen), lider −%30 yarım gün, trim share. 2. adım: trim bugs 1 (kart çıkınca), iki kişiye bir gün −%20, trim amount 5 + follow. | 2. adım; 2. şık etiketi 'bir gün' (metin ekleri). |
| Ç11 | #9 on_expire | 3. adım hesabın memnuniyeti; 2. adım konuşan PM'in morali −4. | 2. adım: cevapsız kalan PM'in sorusu, söz zaten sistemin söz olayına gider. |
| Ç12 | #11 3. şık | 2. adım hattaki öbür hesaplara +4 ekledi (metin ekleri); 3. adımın fiillerinde yok. | Y26'nın 'others' kümesine isteğe bağlı line parametresi; ayrı anahtar yok. |
| Ç13 | #15 söz süresi | 2. adım 4 hafta; revize2 metni 'bir sprintlik söz'. | B2BConstants.PROMISE_DEADLINE_WEEKS (2): metin değişmez. |
| Ç14 | #18 bedel | 3. adım −%50 / 1 hafta; 2. adım −%50 / 2 hafta ('bir haftalık iş'). | 2. adım. |
| Ç15 | #19 konuşan ve hesaplar | revize2 PM kâğıdı; PM kâğıdı yalnız 'request' kartında gelir (sprint_system.gd:1400-1403). 2. adım 'top3' seçicisi, 3. adım yeni decision_line_top. | Konuşan test aşamasındaki kişi (speaker_role [tester, developer], stage test, id product.sprint_test_rival_batch). Üç hesap var olan line_top seçicisinin üç yuvası. Metin {seam:urun.decision_card} okur (var olan seam); kart her özellik kartında gelebilir. |
| Ç16 | #21 on_expire | 3. adım boş; 2. adım aday düşer. | 2. adım (drop_prospect kayıptır, I2'ye uyar). |
| Ç17 | #23 Kerem'in sprinti | 3. adım −%50 / 2 hafta; 2. adım −%50 / 4 hafta ('bir sprintlik iş'). | 2. adım. |
| Ç18 | server_price'ın sözlüğü ve #24'ün on_expire'ı | 3. adım NEUTRAL (kart düşse de fiyat iner); 2. adım I2 gereği süre dolumunda olumlu etki yok. | ECONOMIC + işaret kuralı (mult > 1 bedel); #24 on_expire boş, expires_weeks 4. |
| Ç19 | #25 ortaya çıkış gecikmesi | 3. adım [2, 4]; 2. adım 3. | 3 hafta (2. adım). |
| Ç20 | #26 terimin şartı | 2. adım: ürünün Onboarding'i yeterliyse; 3. adım: alan adayın sektör vurgularından biriyse. | 2. adım (oyuncunun vurgusu ancak ürün arkasında durursa işe yarar). |
| Ç21 | #30 marka eşiği | Karar 3 'marka ve kitle eşiği düşer'; 3. adım finance.brand >= <düşük> bıraktı. | Eşik yok: Bootstrap + v1.0 + koşuda bir kez yeterli süzgeç. 'Düşer' azalır anlamındaysa finance.brand >= 5 [WORKING] eklenir (I06 e). |
| Ç22 | #31 basın kartı | 2. adım tek kart, iki pazar satırı; 3. adım iki dosya. | İki dosya: efekt pazara göre dallanamaz; B2B'de audience_delta Kitle çipini yanlış çizerdi. Gecikme [4, 8] Y11 aralığıyla (2. adımın 4 + hedef delay_weeks [0,4] zincir kartında işlemez). |
| Ç23 | #32 1. şık | 3. adım sick_leave + assign_to dev (hasta kişiye kilit); 2. adım sick_leave + sprint_card_carry. | 2. adım: kartın sonraki sprinte kalması çipte okunur; hasta kişiye 'yalnız bu kartta' çipi anlamsızdı. |
| Ç24 | #9 / #32 'promise' ve 'decision' kartları | 3. adım assign_to {card: promise|decision}. | Aynen; I01 olmadan kilit davranışı yok (URUN_ARAYUZU). |
| Ç25 | #1 tutar | 3. adım yer tutucu; 2. adım finance.daily_burn × −7. | 2. adım (finance.daily_burn gün başına orandır, × 7 bir hafta). |
| Ç26 | #23 kilidin dayanağı | 1. adım YY onayı bekliyordu. | YY kararı: 3★ ve üstü hesap varken kilitli; gerekçe TR 'Büyük müşterilerimizin sözleşmesinde bugünkü sağlayıcımızın adı yazıyor.' EN 'Our larger customers' contracts name our current provider.' (TR/EN onay bekliyor). Eşik B2BConstants.CLAUSE_STAR, yeni seam sales.big_accounts. |
| Ç27 | çoklu hesap seçicisi | 2. adım top3; 3. adım decision_line_top. | Var olan line_top (SprintCatalog.paper_account) üç yuvada; yeni seçici yok. |
| Ç28 | teklif sinyali | 3. adım ProspectRegistry.prospect_updated (yeni autoload sinyali). | Yazılmaz: dinleyen arayüz yok; teklif seçim anının çipinde görünür. Aday satırında teklif gösterimi park (P03). |
| Ç29 | imzadaki söz | 3. adım PromiseRegistry.create; var olan B2BSalesSystem.accept_promise ise riskteki hesabı da toparlar (_recover). | PromiseRegistry.create, B2BSalesSystem.apply_offer'ın içinden (yeni hesapta toparlama bump'ı yok). |
| Ç30 | O4 ve gönderen yuvası | Yok (iki adım da görmedi): #23, #30, #31 ve ikizinin çalışan yuvası öznesiz şıklarda O4'e takılırdı. | L01: yuva 'subject': false; baseline büyümez. |

## 3. Kartlar (5. adımın girdisi)

Ortak kurallar: `schema: 3`, `version_scope: demo` (gerekçe: 23 kartın hepsi demo penceresinde, 0–130 hafta, gelir). Metin kaynağı her kartta **satır içi**: kart JSON'unun `text.tr` / `text.en` blokları (sprint kâğıtlarının bugünkü biçimi, ör. `product/sprint_test_their_data.json`); kaynak revize2'nin `*_yuva` alanları, yoksa düz alanlar; `strings.csv`'ye yalnız fiil çipleri, etiketler, mail ve kilit anahtarları girer. Koşullar motorun yaprak biçimindedir (`{seam, op, value}`, `{entity_seam, scope, op, value}`). `on_expire` JSON'da `{"penalties": [...]}`; `expire_note` metin bloğunda. Kâğıtlar (`tick: request`) `speaker_role`, `stage`, `pool_group` taşır; konuşan yuvası `employee`'dir.

| No | revize id | yeni id | Klasör | tick / class | Aile · latch · gecikme · süre | TR/EN onay |
|---|---|---|---|---|---|---|
| #1 | `calisan.bilgisayar` | `team.work_laptop` | team/ | daily / paper | team_gear · {"one_shot": true} run · [0, 0] · 2 hf | onaylı |
| #3 | `calisan.dugun` | `team.wedding_invite` | team/ | daily / paper | employee_life · {"cooldown_weeks": 26} entity · [1, 6] · 2 hf | onaylı |
| #5 | `calisan.yuksek_lisans` | `team.master_degree` | team/ | daily / paper | employee_life · {"cooldown_weeks": 52} entity · [0, 2] · 2 hf | onaylı |
| #5 ek | `calisan.yuksek_lisans.ayrilis` | `team.master_degree_farewell` | team/ | scheduled / paper | employee_life · {"one_shot": true} entity · [0, 0] · 1 hf | bekliyor |
| #6 | `calisan.kaba_musteri` | `team.rude_client` | team/ | daily / paper | customer_abuse · {"cooldown_weeks": 26} entity · [0, 1] · 1 hf | bekliyor |
| #7 | `ekip.ayni_izin.pm` | `team.same_leave_pm` | team/ | daily / paper | team_summer_leave · {"cooldown_weeks": 52} run · [0, 0] · 1 hf | bekliyor |
| #7 | `ekip.ayni_izin.gelistirici` | `team.same_leave_dev` | team/ | daily / paper | team_summer_leave · {"cooldown_weeks": 52} run · [0, 0] · 1 hf | bekliyor |
| #7 | `ekip.ayni_izin.testci` | `team.same_leave_tester` | team/ | daily / paper | team_summer_leave · {"cooldown_weeks": 52} run · [0, 0] · 1 hf | bekliyor |
| #8 | `ekip.kod_inceleme` | `product.sprint_dev_code_review` | product/ | request / paper | sprint_dev · {"cooldown_weeks": 52, "max_fires": 3} run · [0, 0] · 1 hf | bekliyor |
| #9 | `ekip.soz_verdi` | `team.promise_made` | team/ | daily / paper | team_promise · {"cooldown_weeks": 26} entity · [0, 0] · 1 hf | bekliyor |
| #10 | `musteri.egitim` | `customer.training_request` | customer/ | daily / paper | customer_onboarding · {"cooldown_weeks": 8} entity · [0, 0] · 2 hf | bekliyor |
| #11 | `musteri.kendi_hatasi` | `customer.own_data_error` | customer/ | daily / paper | customer_data · {"cooldown_weeks": 26} entity · [0, 1] · 2 hf | bekliyor |
| #12 | `musteri.muhasebeci` | `customer.finance_team` | customer/ | daily / paper | customer_onboarding · {"cooldown_weeks": 26} entity · [0, 0] · 2 hf | bekliyor |
| #15 | `urun.eski_tarayici` | `customer.old_browser` | customer/ | daily / paper | sales_terms · {"cooldown_weeks": 26} entity · [0, 1] · 2 hf | bekliyor |
| #18 | `rakip.kesinti` | `rival.outage` | rival/ | daily / paper | rival_exit · {"one_shot": true} entity · [1, 6] · 1 hf | onaylı |
| #19 | `rakip.ayni_ozellik` | `product.sprint_test_rival_batch` | product/ | request / paper | sprint_test · {"cooldown_weeks": 52, "max_fires": 1} run · [0, 0] · 1 hf | bekliyor |
| #21 | `rakip.panel` | `rival.new_firm_warning` | rival/ | daily / paper | rival_poaching · {"cooldown_weeks": 26} entity · [0, 1] · 1 hf | bekliyor |
| #23 | `dunya.disk` | `world.server_price_hike` | world/ | daily / paper | infra_cost · {"one_shot": true} run · [1, 6] · 4 hf | bekliyor |
| #24 | `dunya.bulut` | `world.cloud_price_cut` | world/ | daily / paper | infra_cost · {"one_shot": true} run · [1, 8] · 4 hf | onaylı |
| #25 | `dunya.veri_nerede` | `world.data_location` | world/ | daily / paper | customer_security · {"one_shot": true} run · [0, 2] · 1 hf | bekliyor |
| #25 ek | `dunya.veri_nerede.ortaya` | `world.data_claim_exposed` | world/ | scheduled / paper | customer_security · {"one_shot": true} run · [0, 0] · 1 hf | bekliyor |
| #26 | `dunya.ceyrek_bulteni` | `world.quarterly_bulletin` | world/ | daily / paper | world_bulletin · {"one_shot": true} run · [0, 0] · 2 hf | bekliyor |
| #30 | `odul.final` | `world.award_final` | world/ | daily / paper | award · {"one_shot": true} run · [1, 6] · 1 hf | bekliyor |
| #31 | `kriz.acik` | `product.encryption_flaw` | product/ | daily / interrupt | product_security · {"one_shot": true} run · [0, 4] · 1 hf | onaylı |
| #31 ek | `kriz.acik.b2b` | `product.encryption_flaw_b2b` | product/ | daily / interrupt | product_security · {"one_shot": true} run · [0, 4] · 1 hf | bekliyor |
| #31 ek | `kriz.acik.basin` | `product.encryption_flaw_press` | product/ | scheduled / paper | product_security · {"one_shot": true} run · [0, 0] · 1 hf | bekliyor |
| #31 ek | `kriz.acik.basin` | `product.encryption_flaw_press_b2b` | product/ | scheduled / paper | product_security · {"one_shot": true} run · [0, 0] · 1 hf | bekliyor |
| #32 | `kriz.ameliyat` | `product.sprint_pm_hospital` | product/ | request / paper | sprint_pm · {"cooldown_weeks": 52, "max_fires": 3} run · [0, 0] · 1 hf | bekliyor |

### #1 `calisan.bilgisayar` → `team.work_laptop`

- **Tetik:** günlük tarama; ilk işe alım Ev'de, işe girişinin ikinci haftası.
- **Guards:** {} · **sender:** employee · **tags:** [].
- **Yuvalar:** employee:employee ← most_senior where hr.tenure_weeks[employee] <= 2.
- **Koşul:** hr.headcount == 1 ∧ hr.run_hires == 1 ∧ office.current == "home".
- **Makullük:** {"phase_band": ["bootstrap_team"], "headcount": [1, 1], "product": "any", "modules": [], "min_week": 0, "subject_tenure_weeks": 1}; family `team_gear`, family_subject {"once": true}; delay_weeks [0, 0] (ikinci haftanın sorusu: dar pencere); latch {"one_shot": true}, latch_key run; expires_weeks 2.
- **Şıklar:**
  - `send_new` “Yeni bir bilgisayar gönder”: add_cash(amount_seam="finance.daily_burn", amount_mult=-7, label="equipment"); change_morale(scope="employee", amount=4)
    - Kazanç: çalışanın morali +4. Bedel: Kasa −1 haftalık gider (finance.daily_burn × 7). En iyi: pist 6 aydan uzunken.
  - `send_old` “Kendi eski laptopunu gönder”: change_morale(scope="employee", amount=-4); productivity_mod(scope="employee", pct=-10, weeks=4)
    - Kazanç: kasa korunur. Bedel: moral −4, verim −%10 / 4 hafta. En iyi: pist 3 aydan kısayken.
- **on_expire:** change_morale(scope="employee", amount=-6); productivity_mod(scope="employee", pct=-10, weeks=4).
- **Yeni kod:** Y19 equipment etiketi.
- **Not:** newest_hire seçilmedi: T3 8 hafta taban ister (lint.gd T3); tek çalışanda most_senior aynı kişidir. Kart adı team.work_laptop.

### #3 `calisan.dugun` → `team.wedding_invite`

- **Tetik:** günlük tarama; 26 haftasını dolduran çalışanlar arasından tohumlu rastgele.
- **Guards:** {} · **sender:** employee · **tags:** [].
- **Yuvalar:** employee:employee ← random.
- **Koşul:** {}.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [1, null], "product": "any", "modules": [], "min_week": 26, "subject_tenure_weeks": 26}; family `employee_life`, family_subject {"once": true}; delay_weeks [1, 6]; latch {"cooldown_weeks": 26}, latch_key entity; expires_weeks 2.
- **Şıklar:**
  - `gold_full` “Düğüne git, tam altın tak”: add_cash(amount_seam="hr.salary", amount_slot="employee", amount_mult=-0.1, label="gift"); change_morale(scope="employee", amount=10)
    - Kazanç: moral +10. Bedel: Kasa −maaşın %10'u. En iyi: kilit kişi ya da morali 50'ye yakın.
  - `gold_quarter` “Düğüne git, çeyrek altın tak”: add_cash(amount_seam="hr.salary", amount_slot="employee", amount_mult=-0.03, label="gift"); change_morale(scope="employee", amount=5)
    - Kazanç: moral +5. Bedel: Kasa −maaşın %3'ü. En iyi: moral orta bantta, kasa rahat değil.
  - `flowers` “Gidemeyeceğini söyle, çiçek gönder”: add_cash(amount_seam="hr.salary", amount_slot="employee", amount_mult=-0.015, label="gift")
    - Kazanç: en ucuz cevap. Bedel: Kasa −maaşın %1,5'i, moral kazancı yok. En iyi: kasa çok dar ya da moral 80 üstü.
- **on_expire:** change_morale(scope="employee", amount=-6).
- **Yeni kod:** Y07 random seçici, Y10 amount_slot, Y19 gift etiketi.
- **Not:** Kişi başına bir kez (family_subject once); latch_key entity + cooldown 26 aynı kişiye ikinci kez gelmez.

### #5 `calisan.yuksek_lisans` → `team.master_degree`

- **Tetik:** günlük tarama; bahar sonu (Mayıs, Haziran), junior çalışan.
- **Guards:** {} · **sender:** employee · **tags:** [].
- **Yuvalar:** employee:employee ← random where hr.level[employee] == 0.
- **Koşul:** time.month in [5, 6].
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [1, null], "product": "any", "modules": [], "min_week": 0, "subject_tenure_weeks": 26}; family `employee_life`, family_subject {"once": true}; delay_weeks [0, 2]; latch {"cooldown_weeks": 52}, latch_key entity; expires_weeks 2.
- **Şıklar:**
  - `congratulate` “Tebrik et, son ayında işini devretsin”: schedule_event(event_id="team.master_degree_farewell", delay_weeks=4)
    - Kazanç: maaş yükü 4 hafta sonra kalkar, kişi 4 hafta daha çalışır. Bedel: çip: '4 hafta sonra: {employee} ayrılır' (Y11, tehlike); ayrılışta ekip morali −5 (motorun kendisi). En iyi: rolde yedek varken ya da pist kısayken.
  - `promote` “Okulu bir yıl ertelemesini rica et, terfi teklif et”: promote(scope="employee", pct=15)
    - Kazanç: kişi kalır, orta seviyeye geçer, moral ~+12 (HRActions.apply_promotion). Bedel: maaş kalıcı +%15. En iyi: kişi rolünde tekken.
- **on_expire:** schedule_event(event_id="team.master_degree_farewell", delay_weeks=4).
- **Yeni kod:** Y07 random, Y11 schedule_event çipi, Y18 promote.
- **Not:** ÇELİŞKİ Ç09: gecikme 4 hafta (2. adım; metin 'dört hafta sonra') — 3. adımın 3'ü değil. apply_raise ayrıca çağrılmaz (çift zam).

### #5 ek `calisan.yuksek_lisans.ayrilis` → `team.master_degree_farewell`

- **Tetik:** team.master_degree congratulate şıkkı ve on_expire'ı: schedule_event 4 hafta; bağlam taşınır.
- **follows:** `team.master_degree`.
- **Guards:** {} · **sender:** employee · **tags:** [].
- **Yuvalar:** employee:employee ← verilir.
- **Koşul:** {}.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [1, null], "product": "any", "modules": [], "min_week": 0, "subject_tenure_weeks": 0, "fresh_reason": "zincir: özne ana kartın çalışanıdır"}; family `employee_life`, family_subject {"once": true}; delay_weeks [0, 0] (zincir: ana kart zamanlar); latch {"one_shot": true}, latch_key entity; expires_weeks 1.
- **Şıklar:**
  - `thank` “Teşekkür et, yolu açık olsun de”: employee_leaves(scope="employee", reason="study")
    - Kazanç: yok (açık beat). Bedel: kişi ayrılır (tehlike çipi), ekip morali −5 (motor). En iyi: tek şık.
- **on_expire:** employee_leaves(scope="employee", reason="study").
- **Yeni kod:** yok.
- **Not:** Tek şıklı beat, bedeli var (O2 geçer). Kişi arada giderse zamanlanmış kart düşer (EvScope.still_valid).

### #6 `calisan.kaba_musteri` → `team.rude_client`

- **Tetik:** günlük tarama; temsilcisi olan, hatlarında açık hata bulunan B2B hesap.
- **Guards:** {"market": "b2b", "product_live": true} · **sender:** employee · **tags:** [].
- **Yuvalar:** customer:customer ← random where musteri.bugs[customer] >= 1 ∧ musteri.is_assigned[customer] == true; employee:employee ← account_rep; founder:founder ← verilir.
- **Koşul:** sales.is_b2b == true.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [1, null], "product": "live", "modules": [], "min_week": 0, "subject_tenure_by_slot": {"customer": 4, "employee": 4}}; family `customer_abuse`, family_subject {"once": true}; delay_weeks [0, 1]; latch {"cooldown_weeks": 26}, latch_key entity; expires_weeks 1.
- **Şıklar:**
  - `take_over` “{customer} ile telefonda bundan sonra sen konuş”: take_account(scope="customer"); productivity_mod(scope="founder", pct=-15, weeks=2); change_morale(scope="employee", amount=4)
    - Kazanç: temsilcinin morali +4, hesabın memnuniyeti dokunulmaz. Bedel: hesap kurucunun masasına geçer, kurucu verimi −%15 / 2 hafta. En iyi: hesap büyük ve hassasken.
  - `call_boss` “Müdürü ara, ekibine böyle konuşamayacağını söyle”: change_morale(scope="employee", amount=6); trust_delta(scope="customer", amount=-4) · **check** `olay.odds_15` → on_pass [account_notice(scope="customer", reason="rude_call")] / on_fail []
    - Kazanç: temsilcinin morali +6. Bedel: hesap memnuniyeti −4 (trust_offset). Risk: %15 (olay.odds_15): fesih bildirimi, 4 hafta sonra sözleşme biter. En iyi: hesap küçük, temsilci kilit.
  - `tell_cope` “Ona “müşteri bu, idare et” de”: change_morale(scope="employee", amount=-6)
    - Kazanç: kurucunun zamanı ve hesap korunur. Bedel: temsilcinin morali −6. En iyi: kurucu çok yoğun, temsilcinin morali yüksek.
- **on_expire:** change_morale(scope="employee", amount=-8).
- **Yeni kod:** Y03 check+effects, Y04 check çipi, Y07 random, Y20 account_notice, Y25 musteri.bugs, Y27 take_account.
- **Not:** 'Tercihen kadın' uygulanmaz (Character'da cinsiyet alanı yok). 'O hafta bulunan hata' yerine hesabın hatlarındaki açık hata (musteri.bugs). musteri.is_assigned var olan seam.

### #7 `ekip.ayni_izin.pm` → `team.same_leave_pm`

- **Tetik:** günlük tarama; aynı roldeki iki kişinin bu yılki iki haftalık yaz izni blokları ≥1 hafta örtüşüyor, önce başlayanın iznine 2–4 hafta var, yıl zarı tuttu.
- **Guards:** {} · **sender:** employee · **tags:** [].
- **Yuvalar:** employee:employee ← leave_pair where hr.role[employee] == "product_manager" ∧ hr.leave_weeks_left[employee] >= 2 ∧ hr.leave_weeks_left[employee] <= 4; other:employee ← leave_partner.
- **Koşul:** year_roll < 0.5 (EvDice.unit('year', yıl, kart id, '')).
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [2, null], "product": "any", "modules": [], "min_week": 0, "subject_tenure_weeks": 4}; family `team_summer_leave`, family_subject {"cooldown_weeks": 52}; delay_weeks [0, 0] (dar pencere: iznin 2–4 hafta öncesi); latch {"cooldown_weeks": 52}, latch_key run; expires_weeks 1.
- **Şıklar:**
  - `prep_then_go` “Kartları önden hazırlasınlar, sonra ikisi de çıksın”: summer_leave(scope="employee", other="other", apart=false); productivity_mod(scope="employee", pct=20, weeks=2); productivity_mod(scope="other", pct=20, weeks=2)
    - Kazanç: izinden önceki iki hafta ikisinin de verimi +%20 (hazırlık öne alınır). Bedel: çip: ikisi aynı iki hafta izinde; o haftalar hazırlık durur. En iyi: sonraki sütunda hazırlanacak çok kart varken.
  - `settle_it` “Kendi aralarında karar versinler”: summer_leave(scope="employee", other="other", apart=true); change_morale(scope="employee", amount=-4); change_morale(scope="other", amount=-4)
    - Kazanç: rol hiç boş kalmaz (geç başlayanın izni bu yıl örtüşmeyecek kadar kayar). Bedel: ikisinin de morali −4. En iyi: sprintte teslim ya da sözlü kart varken.
  - `both_go` “İkisi de gitsin, sürüm kaysın”: summer_leave(scope="employee", other="other", apart=false); change_morale(scope="employee", amount=4); change_morale(scope="other", amount=4)
    - Kazanç: ikisinin de morali +4 (dönüşteki doğal +15'e ek). Bedel: çip: ikisi aynı iki hafta izinde (summer_leave together); rol boş, plan kayar. En iyi: sözlü kart yokken, moral düşükken.
- **on_expire:** change_morale(scope="employee", amount=-3); change_morale(scope="other", amount=-3).
- **Yeni kod:** Y06 year_roll, Y13 hr.role, Y15 leave_pair/leave_partner + hr.leave_weeks_left, Y16 summer_leave.
- **Not:** Karar 4. Yuva sırası (Ç08): employee = önce izne çıkan (gönderen), other = geç başlayan (kayan); prim other'ın maaşından. Üç varyant tek aile: yılda en çok biri. İzinler doğal başlar (HRMoraleSystem.tick_leave_departures); 'together' kipi bu yılın haftasını sabitler ve çipini çizer (Ç06). Ç04: 1. şık +%20 verim (2. adım), 3. adımın −%30'u değil.

### #7 `ekip.ayni_izin.gelistirici` → `team.same_leave_dev`

- **Tetik:** günlük tarama; aynı roldeki iki kişinin bu yılki iki haftalık yaz izni blokları ≥1 hafta örtüşüyor, önce başlayanın iznine 2–4 hafta var, yıl zarı tuttu.
- **Guards:** {} · **sender:** employee · **tags:** [].
- **Yuvalar:** employee:employee ← leave_pair where hr.role[employee] == "developer" ∧ hr.leave_weeks_left[employee] >= 2 ∧ hr.leave_weeks_left[employee] <= 4; other:employee ← leave_partner.
- **Koşul:** year_roll < 0.5 (EvDice.unit('year', yıl, kart id, '')).
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [2, null], "product": "any", "modules": [], "min_week": 0, "subject_tenure_weeks": 4}; family `team_summer_leave`, family_subject {"cooldown_weeks": 52}; delay_weeks [0, 0] (dar pencere: iznin 2–4 hafta öncesi); latch {"cooldown_weeks": 52}, latch_key run; expires_weeks 1.
- **Şıklar:**
  - `settle_it` “Kendi aralarında karar versinler”: summer_leave(scope="employee", other="other", apart=true); change_morale(scope="employee", amount=-4); change_morale(scope="other", amount=-4)
    - Kazanç: rol hiç boş kalmaz (geç başlayanın izni bu yıl örtüşmeyecek kadar kayar). Bedel: ikisinin de morali −4. En iyi: sprintte teslim ya da sözlü kart varken.
  - `both_go` “İkisi de gitsin, sürüm kaysın”: summer_leave(scope="employee", other="other", apart=false); change_morale(scope="employee", amount=4); change_morale(scope="other", amount=4)
    - Kazanç: ikisinin de morali +4 (dönüşteki doğal +15'e ek). Bedel: çip: ikisi aynı iki hafta izinde (summer_leave together); rol boş, plan kayar. En iyi: sözlü kart yokken, moral düşükken.
  - `shift_with_bonus` “Birinin iznini kaydır, karşılığında prim ver”: summer_leave(scope="employee", other="other", apart=true); add_cash(amount_seam="hr.salary", amount_slot="other", amount_mult=-0.233, label="retention")
    - Kazanç: rol boş kalmaz, moral bozulmaz. Bedel: Kasa −kayan kişinin bir haftalık maaşı (hr.salary × 7/30). En iyi: kasa rahat, teslim yakınken.
- **on_expire:** change_morale(scope="employee", amount=-3); change_morale(scope="other", amount=-3).
- **Yeni kod:** Y06 year_roll, Y13 hr.role, Y15 leave_pair/leave_partner + hr.leave_weeks_left, Y16 summer_leave.
- **Not:** Karar 4. Yuva sırası (Ç08): employee = önce izne çıkan (gönderen), other = geç başlayan (kayan); prim other'ın maaşından. Üç varyant tek aile: yılda en çok biri. İzinler doğal başlar (HRMoraleSystem.tick_leave_departures); 'together' kipi bu yılın haftasını sabitler ve çipini çizer (Ç06).

### #7 `ekip.ayni_izin.testci` → `team.same_leave_tester`

- **Tetik:** günlük tarama; aynı roldeki iki kişinin bu yılki iki haftalık yaz izni blokları ≥1 hafta örtüşüyor, önce başlayanın iznine 2–4 hafta var, yıl zarı tuttu.
- **Guards:** {} · **sender:** employee · **tags:** [].
- **Yuvalar:** employee:employee ← leave_pair where hr.role[employee] == "tester" ∧ hr.leave_weeks_left[employee] >= 2 ∧ hr.leave_weeks_left[employee] <= 4; other:employee ← leave_partner.
- **Koşul:** year_roll < 0.5 (EvDice.unit('year', yıl, kart id, '')).
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [2, null], "product": "any", "modules": [], "min_week": 0, "subject_tenure_weeks": 4}; family `team_summer_leave`, family_subject {"cooldown_weeks": 52}; delay_weeks [0, 0] (dar pencere: iznin 2–4 hafta öncesi); latch {"cooldown_weeks": 52}, latch_key run; expires_weeks 1.
- **Şıklar:**
  - `settle_it` “Kendi aralarında karar versinler”: summer_leave(scope="employee", other="other", apart=true); change_morale(scope="employee", amount=-4); change_morale(scope="other", amount=-4)
    - Kazanç: rol hiç boş kalmaz (geç başlayanın izni bu yıl örtüşmeyecek kadar kayar). Bedel: ikisinin de morali −4. En iyi: sprintte teslim ya da sözlü kart varken.
  - `devs_test` “İkisi de gitsin, testi geliştiriciler yapsın”: summer_leave(scope="employee", other="other", apart=false); change_morale(scope="employee", amount=4); change_morale(scope="other", amount=4)
    - Kazanç: ikisinin de morali +4. Bedel: çip: ikisi aynı iki hafta izinde; test geliştiriciye yarım hızla düşer, yakalama düşer (doğal). En iyi: sözlü kart yokken.
  - `shift_with_bonus` “Birinin iznini kaydır, karşılığında prim ver”: summer_leave(scope="employee", other="other", apart=true); add_cash(amount_seam="hr.salary", amount_slot="other", amount_mult=-0.233, label="retention")
    - Kazanç: rol boş kalmaz, moral bozulmaz. Bedel: Kasa −kayan kişinin bir haftalık maaşı (hr.salary × 7/30). En iyi: kasa rahat, teslim yakınken.
- **on_expire:** change_morale(scope="employee", amount=-3); change_morale(scope="other", amount=-3).
- **Yeni kod:** Y06 year_roll, Y13 hr.role, Y15 leave_pair/leave_partner + hr.leave_weeks_left, Y16 summer_leave.
- **Not:** Karar 4. Yuva sırası (Ç08): employee = önce izne çıkan (gönderen), other = geç başlayan (kayan); prim other'ın maaşından. Üç varyant tek aile: yılda en çok biri. İzinler doğal başlar (HRMoraleSystem.tick_leave_departures); 'together' kipi bu yılın haftasını sabitler ve çipini çizer (Ç06). Ç05: Erdem'in onayladığı 'testi geliştiriciler yapsın' kalır; eski 3. şık ('sürüm kaysın') onunla mekanik olarak aynıydı, yerine prim şıkkı.

### #8 `ekip.kod_inceleme` → `product.sprint_dev_code_review`

- **Tetik:** SprintSystem._request_decision; data/product/sprint.json decision.cards havuzu (I02).
- **Kâğıt:** speaker_role "developer", stage dev, pool_group developer.
- **Guards:** {} · **sender:** employee · **tags:** [].
- **Yuvalar:** employee:employee ← verilir where hr.level[employee] == 0; lead:employee ← most_senior where hr.role[lead] == "developer" ∧ hr.level[lead] == 2.
- **Koşul:** urun.sprint_running == true ∧ urun.decision_phase == 1 ∧ urun.decision_card_late == true.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [2, null], "product": "any", "modules": [], "min_week": 0, "subject_tenure_weeks": 0, "fresh_reason": "konuşan ve kıdemli kartın üstündeki kişilerdir"}; family `sprint_dev`, family_subject {"cooldown_weeks": 26}; delay_weeks [0, 0] (request); latch {"cooldown_weeks": 52, "max_fires": 3}, latch_key run; expires_weeks 1.
- **Şıklar:**
  - `blockers_only` “{lead} yalnız hataya yol açacak notlarda dursun, gerisini geçsin”: sprint_card_effort(amount=-5); sprint_card_trim(bugs=1); change_morale(scope="lead", amount=-4)
    - Kazanç: kartın işi −5 puan. Bedel: kart çıkınca hattına 1 açık hata; kıdemlinin morali −4. En iyi: kart sözlüyken.
  - `pair_up` “{lead} ile {employee} bir gün aynı masaya otursun, notları birlikte kapatsınlar”: productivity_mod(scope="lead", pct=-20, weeks=1); productivity_mod(scope="employee", pct=-20, weeks=1); change_morale(scope="employee", amount=6)
    - Kazanç: junior'un morali +6, kart hatasız sürer. Bedel: ikisinin birer günü (verim −%20 / 1 hafta). En iyi: junior'un morali düşükken.
  - `follow_up` “Kart bu sprintte bu hâliyle kalsın, {employee} notları sonraki sprintte düzeltsin”: sprint_card_trim(amount=5, follow=true); change_morale(scope="employee", amount=4)
    - Kazanç: bu sprintin teslimi korunur, junior +4. Bedel: sonraki sprinte 5 puanlık takip kartı. En iyi: bu sprintte sürüm şartken.
  - `close_all` “{employee} bu sefer notların hepsini kapatsın, kart sağlam çıksın”: sprint_card_effort(amount=10); line_harden(line="decision"); change_morale(scope="employee", amount=-6)
    - Kazanç: hat 26 hafta yeni hata almaz. Bedel: kartın işi +10 puan, junior −6. En iyi: hat çok kullanılırken.
- **on_expire:** sprint_card_effort(amount=5); morale_crew(crew="speaker", amount=-4).
- **Yeni kod:** Y13 hr.role.
- **Not:** Karar 11: kâğıt. Konuşan yuvası kâğıt kuralı gereği 'employee' (revize2'nin {dev} jetonu {employee} olur). 'Takım lideri' yok: en kıdemli Senior geliştirici. Ç10: 2. adımın sayıları (trim bugs 1, iki kişiye bir gün, trim amount 5).

### #9 `ekip.soz_verdi` → `team.promise_made`

- **Tetik:** günlük tarama; hesabın açık sözünün kartı koşan sprintte geride, sprintin son haftası değil.
- **Guards:** {"market": "b2b", "product_live": true} · **sender:** employee · **tags:** [].
- **Yuvalar:** customer:customer ← random where musteri.has_open_promise[customer] == true ∧ musteri.promise_late[customer] == true; employee:employee ← quarter_pm; dev:employee ← top_skill:engineering where hr.role[dev] == "developer".
- **Koşul:** urun.sprint_running == true ∧ urun.sprint_last_week == false.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [2, null], "product": "live", "modules": [], "min_week": 0, "subject_tenure_by_slot": {"customer": 0, "employee": 0, "dev": 0}, "fresh_reason": "sözün gecikmesi hesabın ya da kişinin kıdemine bağlı değil"}; family `team_promise`, family_subject {"cooldown_weeks": 26}; delay_weeks [0, 0] (sözün sprinti sürerken, son haftadan önce: dar pencere); latch {"cooldown_weeks": 26}, latch_key entity; expires_weeks 1.
- **Şıklar:**
  - `focus` “{dev} ay sonuna kadar yalnız buna baksın”: assign_to(card="promise", scope="dev", weeks_seam="urun.weeks_to_month_end"); change_morale(scope="dev", amount=-6)
    - Kazanç: sözlü kart en güçlü geliştiriciyle yürür (tutulursa PROMISE_KEPT_OFFSET +6). Bedel: kişinin öbür kartları bekler, morali −6. En iyi: söz büyük hesaba verilmişken.
  - `ask_time` “Müşteriyi ara, ek süre iste”: trust_delta(scope="customer", amount=-6); promise_extend(scope="customer") · **requires** musteri.promise_extended[customer] == false, kilit: “Bu sözü bir kez uzattık.” / “We have already extended this promise once.”
    - Kazanç: söz bir sprint uzar. Bedel: hesap memnuniyeti −6 (trust_offset). En iyi: özellik yoldayken.
  - `drop` “Bu özelliğin şimdilik olmayacağını söyle”: promise_break(scope="customer")
    - Kazanç: plan serbest kalır. Bedel: kırık söz: memnuniyet ve iz −12 (PROMISE_BROKEN_OFFSET), marka bedeli (break_plan). En iyi: özellik yol haritasında yokken.
- **on_expire:** change_morale(scope="employee", amount=-4).
- **Yeni kod:** Y07/Y14 top_skill, Y13 hr.role, Y25 musteri.promise_late, musteri.promise_extended, Y28 kapsamlı söz fiilleri, Y37 assign_to, Y40 quarter_pm.
- **Not:** Karar 13. Ç11: on_expire konuşan PM'in morali −4 (2. adım). trust_delta promise_extend'den önce (fiil sırası: açık sözleri okur).

### #10 `musteri.egitim` → `customer.training_request`

- **Tetik:** günlük tarama; orta boy (2★) B2B hesap imzanın ertesi haftasında, Onboarding beklentinin altında.
- **Guards:** {"market": "b2b", "product_live": true} · **sender:** contact · **tags:** [].
- **Yuvalar:** customer:customer ← random where musteri.scale[customer] == 2 ∧ musteri.tenure_weeks[customer] <= 1 ∧ musteri.onboarding_short[customer] == true; rep:employee ← account_rep.
- **Koşul:** sales.is_b2b == true.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [1, null], "product": "live", "modules": [], "min_week": 0, "subject_tenure_by_slot": {"customer": 0, "rep": 0}, "fresh_reason": "yeni hesabın ilk haftası; temsilci hesabın kendi temsilcisi"}; family `customer_onboarding`, family_subject {"cooldown_weeks": 26}; delay_weeks [0, 0] (imzanın ertesi haftası: dar pencere); latch {"cooldown_weeks": 8}, latch_key entity; expires_weeks 2.
- **Şıklar:**
  - `visit` “{rep} gelecek hafta bir gün gidip anlatsın”: productivity_mod(scope="rep", pct=-20, weeks=1); trust_delta(scope="customer", amount=8)
    - Kazanç: hesap +8. Bedel: temsilcinin bir günü. En iyi: tek hesap ilk ayında.
  - `paid` “İki günlük eğitim teklif et, ücretini iste”: add_cash(amount_seam="musteri.mrr", amount_slot="customer", amount_mult=0.5, label="training"); productivity_mod(scope="rep", pct=-40, weeks=1); trust_delta(scope="customer", amount=-4)
    - Kazanç: Kasa +hesabın yarım aylık ücreti. Bedel: temsilcinin iki günü, hesap −4. En iyi: kasa darken.
  - `doc` “{rep} ekran ekran anlatan bir onboarding dokümanı hazırlasın”: productivity_mod(scope="rep", pct=-40, weeks=1); trust_delta(accounts="onboarding", amount=4)
    - Kazanç: ilk ayındaki bütün hesaplar +4. Bedel: temsilcinin iki günü. En iyi: aynı anda birkaç hesap ilk ayında.
  - `help_center` “Ürüne yardım merkezi ekle”: queue_card(area="onboarding"); trust_delta(scope="customer", amount=-4)
    - Kazanç: sonraki sprinte Onboarding kartı (bütün hesap ve adayların uyumu). Bedel: kartın puanı sonraki sprintten, hesap −4. En iyi: Onboarding sektör vurgusuyken.
- **on_expire:** trust_delta(scope="customer", amount=-6).
- **Yeni kod:** Y07 random, Y10 amount_slot, Y25 musteri.onboarding_short, Y26 accounts onboarding, Y38 queue_card.
- **Not:** Temsilcisiz yedek varyant park (P03). 'training' etiketi var (HR_COST_TRAINING 'Eğitim ücreti').

### #11 `musteri.kendi_hatasi` → `customer.own_data_error`

- **Tetik:** günlük tarama; perakende B2B hesap ilk haftalarında, Stok hattı canlı.
- **Guards:** {"market": "b2b", "product_live": true} · **sender:** employee · **tags:** [].
- **Yuvalar:** customer:customer ← random where musteri.sector[customer] == "retail" ∧ musteri.tenure_weeks[customer] <= 4; rep:employee ← account_rep (isteğe bağlı); employee:employee ← random where hr.role[employee] == "developer"; founder:founder ← verilir.
- **Koşul:** sales.is_b2b == true ∧ urun.line_tier.line_erp_stock >= 1.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [1, null], "product": "live", "modules": [], "min_week": 0, "subject_tenure_by_slot": {"customer": 1, "employee": 4, "rep": 0}, "fresh_reason": "temsilci hesabın kendi temsilcisidir"}; family `customer_data`, family_subject {"cooldown_weeks": 26}; delay_weeks [0, 1]; latch {"cooldown_weeks": 26}, latch_key entity; expires_weeks 2.
- **Şıklar:**
  - `rep_visits` “{rep} kayıtlarla müdüre gitsin”: productivity_mod(scope="rep", pct=-20, weeks=1); trust_delta(scope="customer", amount=8) · **requires** entity_exists rep, kilit: “Bu hesabın müşteri temsilcisi yok.” / “This account has no account manager.”
    - Kazanç: hesap +8. Bedel: temsilcinin bir günü. En iyi: temsilci varken.
  - `founder_calls` “Müdürü sen ara, kayıtları nazikçe anlat”: productivity_mod(scope="founder", pct=-10, weeks=1); trust_delta(scope="customer", amount=4)
    - Kazanç: hesap +4. Bedel: kurucunun verimi −%10 / 1 hafta. En iyi: temsilci yokken.
  - `warning_screen` “Sayım ekranına uyarı ekle, müdüre aldığımız önlemi anlat”: productivity_mod(scope="employee", pct=-50, weeks=2); trust_delta(scope="customer", amount=8); trust_delta(accounts="others", line="line_erp_stock", amount=4)
    - Kazanç: hesap +8, Stok hattını kullanan öbür hesaplar +4. Bedel: geliştiricinin bir haftalık işi (−%50 / 2 hafta). En iyi: Stok hattını çok hesap kullanırken.
- **on_expire:** trust_delta(scope="customer", amount=-6).
- **Yeni kod:** Y07 random, Y13 hr.role, Y25 musteri.sector, Y26 accounts others (+line), Y41 urun.line_tier.<hat>.
- **Not:** Ç12: 3. şığa hattaki öbür hesapların +4'ü (2. adım) 'others' + line parametresiyle. 'Stok hattında çalışmış geliştirici' seçicisi yok: rastgele geliştirici; metin hat geçmişi iddia etmez. Kilitli şık gizlenmez (GDD §3.3), gerekçeyle görünür.

### #12 `musteri.muhasebeci` → `customer.finance_team`

- **Tetik:** günlük tarama; küçük ya da orta boy B2B hesabın ilk ay kapanışı, Entegrasyonlar hattı açılmamış.
- **Guards:** {"market": "b2b", "product_live": true} · **sender:** contact · **tags:** [].
- **Yuvalar:** customer:customer ← random where musteri.scale[customer] <= 2 ∧ musteri.tenure_weeks[customer] >= 4 ∧ musteri.tenure_weeks[customer] <= 5; rep:employee ← account_rep.
- **Koşul:** sales.is_b2b == true ∧ urun.line_tier.line_shared_integrations == 0.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [1, null], "product": "live", "modules": [], "min_week": 0, "subject_tenure_by_slot": {"customer": 4, "rep": 0}, "fresh_reason": "temsilci hesabın kendi temsilcisidir"}; family `customer_onboarding`, family_subject {"cooldown_weeks": 26}; delay_weeks [0, 0] (ilk ay kapanışı: dar pencere); latch {"cooldown_weeks": 26}, latch_key entity; expires_weeks 2.
- **Şıklar:**
  - `queue_request` “Tabloya aktarmayı sonraki sprinte al”: queue_card(scope="customer", line="line_shared_integrations"); trust_delta(scope="customer", amount=8)
    - Kazanç: hesap +8, Entegrasyonlar k1 isteği. Bedel: kartın puanı (K1 15) sonraki sprintten. En iyi: sprintte yer varken.
  - `rep_shows` “{rep} finans ekibine bir gün sistemi göstersin”: productivity_mod(scope="rep", pct=-20, weeks=1); trust_delta(scope="customer", amount=4)
    - Kazanç: hesap +4. Bedel: temsilcinin bir günü. En iyi: sprint doluyken.
  - `carry_on` “Şimdilik böyle devam etmelerini rica et”: trust_delta(scope="customer", amount=-8)
    - Kazanç: hiçbir kaynak harcanmaz. Bedel: hesap −8. En iyi: hesap küçük, sprint ve temsilci doluyken.
- **on_expire:** trust_delta(scope="customer", amount=-8).
- **Yeni kod:** Y07 random, Y38 queue_card (+SprintBridges.open_request), Y41 urun.line_tier.<hat>.
- **Not:** Katalogda 'dışa aktarma' kademesi yok: en yakın karşılık Entegrasyonlar k1 (I06 a). Çip kartın adını yazar, etiket 'tabloya aktarma' der.

### #15 `urun.eski_tarayici` → `customer.old_browser`

- **Tetik:** günlük tarama; satış temsilcisinin işlediği sağlık adayı, Duyarlı Arayüz çıkmamış.
- **Guards:** {"market": "b2b", "product_live": true} · **sender:** employee · **tags:** [].
- **Yuvalar:** prospect:prospect ← rep_lead where aday.sector[prospect] == "health"; employee:employee ← lead_rep.
- **Koşul:** sales.is_b2b == true ∧ urun.responsive_shipped == false.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [1, null], "product": "live", "modules": [], "min_week": 0, "subject_tenure_by_slot": {"prospect": 0, "employee": 0}, "fresh_reason": "konuşan adayı işleyen temsilcidir"}; family `sales_terms`, family_subject {"cooldown_weeks": 26}; delay_weeks [0, 1]; latch {"cooldown_weeks": 26}, latch_key entity; expires_weeks 2.
- **Şıklar:**
  - `promise_support` “Desteğe söz ver”: prospect_offer(scope="prospect", promise_step="line_shared_mobile_k1")
    - Kazanç: aday masada kalır; imzalarsa söz hesaba yazılır (tutulursa +6). Bedel: çip: 'Teklif: imzalarsa söz verilir, Duyarlı Arayüz' — bir sprintlik söz yükü (PROMISE_DEADLINE_WEEKS 2). Risk: söz tutulmazsa kırık söz bedeli (sistemin kendi süpürmesi, zar değil). En iyi: Mobil ve Erişim hattında yer varken.
  - `decline` “Yapamayacağımızı söyle”: drop_prospect(scope="prospect")
    - Kazanç: söz yükü alınmaz. Bedel: aday düşer (tehlike çipi). En iyi: sprint doluyken.
- **on_expire:** drop_prospect(scope="prospect").
- **Yeni kod:** Y22 prospect_offer, Y23 drop_prospect, Y24 aday.* + rep_lead/lead_rep + {prospect} adı.
- **Not:** Karar 15: olay imzalatmaz, teklif yazar; kapanış zarına teklif terimi YOK (aday 'açılmazsa imza yok' dediği için teklif yalnız adayı akışta tutar). Ç13: söz süresi B2BConstants.PROMISE_DEADLINE_WEEKS (2 = 'bir sprintlik söz', revize2 metniyle aynı) — 2. adımın 4'ü değil. 'Eski tarayıcı' → Mobil ve Erişim k1 'Duyarlı Arayüz' (I06 b). Sektör id 'health' (B2BConstants.SECTORS).

### #18 `rakip.kesinti` → `rival.outage`

- **Tetik:** günlük tarama; B2B canlı, pazarda QUIET durumda küçük (startup) bir rakip, satış temsilcisi var.
- **Guards:** {"market": "b2b", "product_live": true} · **sender:** employee · **tags:** [].
- **Yuvalar:** rival:rival ← market_rival:startup where rival.status[rival] == "QUIET"; employee:employee ← random where hr.role[employee] == "sales_rep".
- **Koşul:** sales.is_b2b == true ∧ sales.account_count >= 1.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [1, null], "product": "live", "modules": [], "min_week": 0, "subject_tenure_by_slot": {"employee": 4}}; family `rival_exit`, family_subject {"cooldown_weeks": 26}; delay_weeks [1, 6]; latch {"one_shot": true}, latch_key entity; expires_weeks 1.
- **Şıklar:**
  - `demo_three` “{employee} bu hafta üçüne de demo yapsın”: add_prospect(archetype="small", source="rival_outage"); add_prospect(archetype="small", source="rival_outage"); add_prospect(archetype="mid", source="rival_outage"); productivity_mod(scope="employee", pct=-50, weeks=2)
    - Kazanç: üç yeni aday (iki küçük, bir orta). Bedel: temsilcinin bir haftalık işi (−%50 / 2 hafta). En iyi: tek şık (Erdem onaylı fırsat).
- **on_expire:** boş (olumlu etki süre dolumunda verilmez, I2; expire_note yazılır).
- **Yeni kod:** Y08 market_rival + {rival} adı, Y07 random, Y13 hr.role.
- **Not:** Ç14: −%50 / 2 hafta (2. adım, 'bir haftalık iş'). Rakibin kesinti durumu oyunda yok: kart haberin kendisidir (karar 9). Temsilcisiz yedek (rival.outage_solo) park P03. on_expire boş: olumlu etki süre dolumunda verilmez (I2); expire_note yazılır.

### #19 `rakip.ayni_ozellik` → `product.sprint_test_rival_batch`

- **Tetik:** SprintSystem._request_decision; özellik kartının Geliştirme'si bitmiş, Test'i başlamamış; decision.cards havuzu (I02).
- **Kâğıt:** speaker_role ["tester", "developer"], stage test, pool_group tester.
- **Guards:** {"market": "b2b", "product_live": true} · **sender:** employee · **tags:** [].
- **Yuvalar:** employee:employee ← verilir; rival:rival ← sprint_rival; acct_1:customer ← line_top; acct_2:customer ← line_top; acct_3:customer ← line_top.
- **Koşul:** urun.sprint_running == true ∧ urun.decision_kind == "feature" ∧ urun.decision_test_untouched == true.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [1, null], "product": "live", "modules": [], "min_week": 0, "subject_tenure_weeks": 0, "fresh_reason": "hesaplar kartın hattının kullanıcılarıdır"}; family `sprint_test`, family_subject {"cooldown_weeks": 26}; delay_weeks [0, 0] (request); latch {"cooldown_weeks": 52, "max_fires": 1}, latch_key run; expires_weeks 1.
- **Şıklar:**
  - `early_trial` “En yakın üç müşterimiz bu hafta erkenden denesin”: trust_delta(accounts="slots", slots=["acct_1", "acct_2", "acct_3"], amount=6); after_test(card="decision", min_bugs=1) → [trust_delta(accounts="slots", slots=["acct_1", "acct_2", "acct_3"], amount=-8)]
    - Kazanç: üç hesap +6 (A). Bedel: çip: 'Kartın testi hata bulursa: üç hesap −8' (B, tehlike). Risk: durumdan: kartın test zarı (SprintBugs); karta ihtimal yazılmaz. En iyi: kartın hata yükü düşükken.
  - `hold_plan` “Planı bozma, kart sırası gelince çıksın”: add_brand(amount=-1)
    - Kazanç: risk yok, plan aynen sürer. Bedel: Marka −1 (rakip önce duyurur). En iyi: plan sıkıyken.
  - `cut_test` “Testi kısalt, kart bu sprintin sürümüne girsin”: sprint_card_test(card="decision"); add_brand(amount=3)
    - Kazanç: Marka +3. Bedel: kartın testi yarıya iner (maliyet çipi). Risk: kaçan hata sürümle hatta açık hata (yakalama payından, zar yok). En iyi: marka eşiğe yakınken.
- **on_expire:** add_brand(amount=-1).
- **Yeni kod:** Y08 sprint_rival, Y26 accounts slots, Y39 after_test.
- **Not:** Ç15: konuşan PM değil test aşamasındaki kişi (SprintSystem._speaker PM kâğıdını yalnız 'request' kartına verir; Toplu Fatura bir core kademesi). speaker_role [tester, developer]: testçisiz ekipte testi yapan geliştirici konuşur. Üç hesap var olan line_top seçicisiyle (hattın en büyük üç hesabı); yeni 'top3/decision_line_top' seçicisi yazılmaz. Metin 'toplu fatura' yerine {seam:urun.decision_card} (var olan seam) okur → TR/EN onay bekliyor. Karar 12 rakip.* → rival/ der, karar 11 kâğıdı product/sprint_*.json'a koyar: karar 11 özeldir.

### #21 `rakip.panel` → `rival.new_firm_warning`

- **Tetik:** günlük tarama; oyuncunun pazar payı ≥%1 ve büyüyor, pazarda established rakip, temsilcinin elinde aday.
- **Guards:** {"market": "b2b", "product_live": true} · **sender:** employee · **tags:** [].
- **Yuvalar:** rival:rival ← market_rival:established; prospect:prospect ← rep_lead; employee:employee ← lead_rep.
- **Koşul:** sales.is_b2b == true ∧ rival.player_share_pct >= 1.0 ∧ finance.growth_streak_months >= 1.
- **Makullük:** {"phase_band": ["traction", "series_a"], "headcount": [1, null], "product": "live", "modules": [], "min_week": 0, "subject_tenure_by_slot": {"prospect": 0, "employee": 4}, "fresh_reason": "aday temsilcinin elindeki güncel adaydır"}; family `rival_poaching`, family_subject {"cooldown_weeks": 26}; delay_weeks [0, 1]; latch {"cooldown_weeks": 26}, latch_key entity; expires_weeks 1.
- **Şıklar:**
  - `reference_call` “{employee} adayı memnun bir müşterimizle görüştürsün”: productivity_mod(scope="employee", pct=-40, weeks=1) · **check** `olay.odds_20` → on_pass [drop_prospect(scope="prospect")] / on_fail []
    - Kazanç: aday tam fiyattan imzalayabilir. Bedel: temsilcinin iki günü. Risk: %20 (olay.odds_20): aday düşer. En iyi: temsilci boşken, memnun referans hesap varken.
  - `first_year_discount` “İlk yıl indirimli fiyat ver”: prospect_offer(scope="prospect", discount_pct=0.15, discount_weeks=52)
    - Kazanç: rakip riski kalkar, zar yok. Bedel: çip: 'Teklif: imzalarsa 52 hafta MRR −%15'. En iyi: temsilci doluyken, aday büyükken.
- **on_expire:** drop_prospect(scope="prospect").
- **Yeni kod:** Y03/Y04 check, Y08 market_rival, Y21 süreli indirim, Y22 prospect_offer, Y23 drop_prospect, Y24 rep_lead/lead_rep.
- **Not:** Karar 8 ve 15. X = %15 [WORKING] (RETAIN_DISCOUNT_PCT ile aynı ölçek). Teklif kapanış zarına terim eklemez. Pay eşiği %1 [WORKING] (MRR $15K; RivalCatalog.MARKET_TOTAL_MRR 1.500.000). Ç16: on_expire aday düşer (2. adım).

### #23 `dunya.disk` → `world.server_price_hike`

- **Tetik:** günlük tarama; ürün yayında, sürümden 8–52 hafta sonra.
- **Guards:** {"product_live": true} · **sender:** employee · **tags:** [].
- **Yuvalar:** employee:employee ← top_skill:engineering [subject:false] where hr.role[employee] == "developer".
- **Koşul:** urun.weeks_since_launch >= 8 ∧ urun.weeks_since_launch <= 52.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [1, null], "product": "live", "modules": [], "min_week": 0, "subject_tenure_weeks": 4}; family `infra_cost`, family_subject {"once": true}; delay_weeks [1, 6]; latch {"one_shot": true}, latch_key run; expires_weeks 4.
- **Şıklar:**
  - `accept` “Zammı kabul et, yerimizde kalalım”: server_price(mult=1.15)
    - Kazanç: kademe ve kapasite serbest. Bedel: sunucu faturası +%15. En iyi: fatura küçük ya da esneklik gerekirken.
  - `switch` “Ucuz sağlayıcıya geç”: server_price(mult=0.9); productivity_mod(scope="employee", pct=-50, weeks=4) · **requires** sales.big_accounts == 0, kilit: “Büyük müşterilerimizin sözleşmesinde bugünkü sağlayıcımızın adı yazıyor.” / “Our larger customers' contracts name our current provider.”
    - Kazanç: fatura bugünkünden −%10, kademe değişmez. Bedel: geliştiricinin bir sprinti (−%50 / 4 hafta). En iyi: fatura büyük, 3★ hesap yok.
  - `contract` “Bir yıllık sözleşme imzala, zammı yarıya indir”: server_price(mult=1.07); server_lock(weeks=52)
    - Kazanç: zam %7'de kalır. Bedel: 52 hafta kademe sabit, kapasite bugünkünün altına inmez. En iyi: kademe ve kapasite bir yıl yeterliyken.
- **on_expire:** server_price(mult=1.15).
- **Yeni kod:** Y14 top_skill, Y25 sales.big_accounts, Y31–Y34 fiyat çarpanı, kilit, server_price, server_lock, L01 subject:false.
- **Not:** Karar 1 ve YY kararı (3★ ve üstü hesap varken 2. şık kilitli; gerekçe kademeden bağımsız, TR/EN onay bekliyor). Eşik B2BConstants.CLAUSE_STAR (3), yeni sabit yok. Ç17: −%50 / 4 hafta (2. adım: 'bir sprintlik iş' = iki haftalık tam iş). Çalışan yuvası gönderendir, kartın öznesi şirketin faturasıdır: 'subject': false (L01).

### #24 `dunya.bulut` → `world.cloud_price_cut`

- **Tetik:** günlük tarama; #23'ten ≥26 hafta sonra, #23'te ucuz sağlayıcıya geçilmemiş.
- **follows:** `world.server_price_hike`.
- **Guards:** {"product_live": true} · **sender:** contact · **tags:** [].
- **Yuvalar:** yok.
- **Koşul:** history fired event=world.server_price_hike ∧ history weeks_since event=world.server_price_hike op=>= value=26 ∧ ¬(history chose event=world.server_price_hike option=switch).
- **Makullük:** {"phase_band": ["bootstrap_solo", "bootstrap_team", "traction", "series_a"], "headcount": [0, null], "product": "live", "modules": [], "min_week": 0}; family `infra_cost`; delay_weeks [1, 8]; latch {"one_shot": true}, latch_key run; expires_weeks 4.
- **Şıklar:**
  - `ack` “Anladım”: server_price(mult=0.7, tiers=["cloud", "enterprise"])
    - Kazanç: Standart ve Kurumsal birim fiyatı −%30. Bedel: yok (açık beat). En iyi: tek şık.
- **on_expire:** boş (olumlu etki süre dolumunda verilmez, I2; expire_note yazılır).
- **Yeni kod:** Y33 server_price tiers.
- **Not:** Tek şıklı bedelsiz dünya duyurusu: O2 bulgusu tools/lint_baseline.json'a gerekçesiyle (görev 'Kart şeması'). Ç18: server_price ECONOMIC sayılır (fatura parası); on_expire boş (I2: olumlu etki süre dolumunda verilmez; kart okunmazsa indirim inmez).

### #25 `dunya.veri_nerede` → `world.data_location`

- **Tetik:** günlük tarama; tarih penceresi hafta 76–110 (Haziran 2013 sonrası, karar 9), sağlık ya da finans hesabı.
- **Guards:** {"market": "b2b", "product_live": true} · **sender:** contact · **tags:** [].
- **Yuvalar:** customer:customer ← random where musteri.sector[customer] in ["health", "finance"]; founder:founder ← verilir.
- **Koşul:** time.week >= 76 ∧ time.week <= 110 ∧ sales.is_b2b == true ∧ sales.account_count >= 2.
- **Makullük:** {"phase_band": ["bootstrap_solo", "bootstrap_team", "traction", "series_a"], "headcount": [0, null], "product": "live", "modules": [], "min_week": 76, "subject_tenure_weeks": 4}; family `customer_security`; delay_weeks [0, 2]; latch {"one_shot": true}, latch_key run; expires_weeks 1.
- **Şıklar:**
  - `founder_calls` “Bilgi işlem müdürünü sen ara, sunucu düzenini anlat”: productivity_mod(scope="founder", pct=-10, weeks=1); trust_delta(scope="customer", amount=8)
    - Kazanç: hesap +8. Bedel: kurucunun verimi −%10 / 1 hafta. En iyi: hesap büyük, kurucunun haftası hafif.
  - `send_all` “Bütün hesaplara aynı açıklamayı gönder”: trust_delta(accounts="others", amount=4); trust_delta(scope="customer", amount=-4)
    - Kazanç: öbür hesaplar +4. Bedel: soran hesap −4. En iyi: çok hesap varken.
  - `lie` ““Verileriniz Türkiye'de ayrı bir sunucuya alınıyor” de”: trust_delta(scope="customer", amount=10) · **check** `olay.odds_25` → on_pass [schedule_event(event_id="world.data_claim_exposed", delay_weeks=3)] / on_fail []
    - Kazanç: hesap +10 (trust_offset tavanı). Bedel: kazanç ~4 haftada söner. Risk: %25 (olay.odds_25): 3 hafta sonra gerçek ortaya çıkar, fesih bildirimi (çip Y11 ile hedefin ortak etkisi). En iyi: hesap küçük ve memnuniyeti eşikteyken.
- **on_expire:** trust_delta(scope="customer", amount=-8).
- **Yeni kod:** Y03/Y04 check, Y07 random, Y11 schedule_event çipi, Y25 musteri.sector, Y26 accounts others.
- **Not:** Karar 9: tarih penceresi (dinleme haberleri Haziran 2013 ≈ tik 75–76); metnin ilk cümlesi doğru kalır. Ç19: gecikme 3 hafta (2. adım). Sektör id'leri 'health', 'finance'.

### #25 ek `dunya.veri_nerede.ortaya` → `world.data_claim_exposed`

- **Tetik:** world.data_location 'lie' şıkkının check dalı (schedule_event 3 hafta; bağlam taşınır).
- **follows:** `world.data_location`.
- **Guards:** {"market": "b2b"} · **sender:** contact · **tags:** [].
- **Yuvalar:** customer:customer ← verilir; founder:founder ← verilir.
- **Koşul:** musteri.has_notice[customer] == false.
- **Makullük:** {"phase_band": ["bootstrap_solo", "bootstrap_team", "traction", "series_a"], "headcount": [0, null], "product": "live", "modules": [], "min_week": 0, "subject_tenure_weeks": 0, "fresh_reason": "zincir: ana kartın hesabı"}; family `customer_security`; delay_weeks [0, 0] (zincir: ana kart zamanlar); latch {"one_shot": true}, latch_key run; expires_weeks 1.
- **Şıklar:**
  - `apologize` “Müdürü ara, özür dile”: account_notice(scope="customer", reason="data_claim", mail=false); productivity_mod(scope="founder", pct=-10, weeks=1); add_reputation(amount=-1)
    - Kazanç: itibar daha az düşer. Bedel: kurucu −%10 / 1 hafta, itibar −1; fesih sürer. En iyi: itibar eşiğe yakınken.
  - `accept` “Bildirimi sessizce kabul et”: account_notice(scope="customer", reason="data_claim", mail=false); add_reputation(amount=-3)
    - Kazanç: kurucunun zamanı korunur. Bedel: itibar −3; fesih sürer. En iyi: kurucu yoğunken.
- **on_expire:** account_notice(scope="customer", reason="data_claim", mail=false); add_reputation(amount=-3).
- **Yeni kod:** Y20 account_notice, Y25 musteri.has_notice.
- **Not:** Karar 6: kart bildirimin kendisidir (mail false); account_notice her yolda ortak, bu yüzden ana kartın çipi Y11 ile '3 hafta sonra: fesih bildirimi' olur. meet_clauses bu bildirimi geri aldırmaz.

### #26 `dunya.ceyrek_bulteni` → `world.quarterly_bulletin`

- **Tetik:** günlük tarama; takvim çeyreğinin ilk haftası, B2B.
- **Guards:** {"market": "b2b", "product_live": true} · **sender:** press · **tags:** [].
- **Yuvalar:** yok.
- **Koşul:** time.quarter_start == true ∧ sales.is_b2b == true.
- **Makullük:** {"phase_band": ["bootstrap_solo", "bootstrap_team", "traction", "series_a"], "headcount": [0, null], "product": "live", "modules": [], "min_week": 0}; family `world_bulletin`; delay_weeks [0, 0] (çeyreğin ilk haftası: dar pencere); latch {"one_shot": true}, latch_key run; expires_weeks 2.
- **Şıklar:**
  - `focus_onboarding` “Bu çeyrek satış görüşmelerinde kurulum desteğine ağırlık veririm”: pitch_focus(area="onboarding", weeks=13)
    - Kazanç: 13 hafta satış görüşmelerinde Onboarding vurgusu: ürünün Onboarding'i adayın beklentisini karşılıyorsa iğneye +0,05. Bedel: yok (açık beat). En iyi: tek şık.
- **on_expire:** boş (olumlu etki süre dolumunda verilmez, I2; expire_note yazılır).
- **Yeni kod:** Y29 pitch_focus, Y30 time.quarter_start.
- **Not:** Karar 5: set_timed_flag WRITER_VERBS'e alınmaz, yazar fiili pitch_focus. Ç20: terim ürünün Onboarding seviyesi beklentiyi karşılıyorsa (2. adım), sektör vurgusu şartı (3. adım) yok. O2 lint_baseline'a gerekçesiyle.

### #30 `odul.final` → `world.award_final`

- **Tetik:** günlük tarama; Bootstrap, ürün canlı (v1.0), kurucunun yanında en az bir çalışan.
- **Guards:** {"product_live": true} · **sender:** press · **tags:** [].
- **Yuvalar:** employee:employee ← top_skill:engineering [subject:false] where hr.role[employee] == "developer"; founder:founder ← verilir.
- **Koşul:** phase.current == 1 ∧ urun.is_live == true.
- **Makullük:** {"phase_band": ["bootstrap_team"], "headcount": [1, null], "product": "live", "modules": [], "min_week": 0, "subject_tenure_weeks": 4}; family `award`, family_subject {"once": true}; delay_weeks [1, 6]; latch {"one_shot": true}, latch_key run; expires_weeks 1.
- **Şıklar:**
  - `live_demo` “Canlı demo yap”: productivity_mod(scope="founder", pct=-20, weeks=1) · **check** `olay.award_live_odds` → on_pass [add_cash(amount=10000, label="award"); add_brand(amount=3)] / on_fail [add_brand(amount_seam="olay.award_live_slip")]
    - Kazanç: %25 (açık hatayla düşer, taban %10): Kasa +$10.000, Marka +3. Bedel: kurucunun bir günü. Risk: kazanamazsan Marka +1, açık hata varsa −2 (olay.award_live_slip). En iyi: açık hata yokken.
  - `video` “Önceden çekilmiş demo videosu göster”: productivity_mod(scope="employee", pct=-40, weeks=1); add_brand(amount=2) · **check** `olay.odds_15` → on_pass [add_cash(amount=10000, label="award")] / on_fail []
    - Kazanç: Marka +2; %15: Kasa +$10.000. Bedel: geliştiricinin iki günü. En iyi: açık hata çokken.
  - `slides` “Slaytla anlat”: productivity_mod(scope="founder", pct=-10, weeks=1); add_brand(amount=1) · **check** `olay.odds_10` → on_pass [add_cash(amount=10000, label="award")] / on_fail []
    - Kazanç: Marka +1; %10: Kasa +$10.000. Bedel: kurucunun yarım günü. En iyi: sprint çok sıkışıkken.
- **on_expire:** add_brand(amount=-1).
- **modifier_lines:** {"urun.open_bugs": {"tr": "Açık hatalar", "en": "Open bugs"}}.
- **Yeni kod:** Y02 olay.award_live_odds / olay.award_live_slip, Y03/Y04 check, Y14 top_skill, Y19 award etiketi, L01 subject:false.
- **Not:** Karar 3: ödül $10.000 [WORKING] kartın JSON'unda, açık istisna (Bootstrap'ta ~1,5–2,5 aylık gider). Ç02: tek zar, oran durumdan (0,25 − 0,05 × min(açık hata, 3), taban 0,10); kayıp dalının markası durumdan (+1 / −2); 3. adımın iki zarlı check dizisi ve olay.stumble_odds yazılmaz. Ç21: marka ve kitle eşiği yok ('eşiği düşer' = kalkar; I06 e). modifier_lines yalnız durumdan gelen oranda (urun.open_bugs var olan seam).

### #31 `kriz.acik` → `product.encryption_flaw`

- **Tetik:** günlük tarama; canlı ürün, hafta ≥53 (2013 ve sonrası, karar 9: kart dünyanın haberidir).
- **Guards:** {"market": "b2c", "product_live": true} · **sender:** employee · **tags:** ["urgent"].
- **Yuvalar:** employee:employee ← top_skill:engineering [subject:false] where hr.role[employee] == "developer".
- **Koşul:** sales.is_b2b == false ∧ time.week >= 53.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [1, null], "product": "live", "modules": [], "min_week": 53, "subject_tenure_weeks": 4}; family `product_security`, family_subject {"once": true}; delay_weeks [0, 4]; latch {"one_shot": true}, latch_key run; expires_weeks 1.
- **Şıklar:**
  - `announce` “Yamala, basına duyur, herkesten şifresini değiştirmesini iste”: add_reputation(amount=3); audience_delta(pct=-0.01)
    - Kazanç: İtibar +3. Bedel: Kitle −%1. En iyi: itibar kitleden değerliyken.
  - `mail_users` “Yamala, yalnız kullanıcılara mail at”: add_reputation(amount=1); audience_delta(pct=-0.005)
    - Kazanç: İtibar +1. Bedel: Kitle −%0,5. En iyi: büyüme kırılganken.
  - `stay_quiet` “Yamala, kimseye duyurma”: (etki yok) · **check** `olay.odds_10` → on_pass [schedule_event(event_id="product.encryption_flaw_press", delay_weeks=[4, 8])] / on_fail []
    - Kazanç: kitle/hesaplar değişmez. Bedel: yalnız risk (çip: '%10 ihtimalle: 4 ile 8 hafta sonra: İtibar −8, …'). Risk: %10 (olay.odds_10): 4–8 hafta sonra basın kartı. En iyi: büyüme her şeyken, itibar payı varken.
- **on_expire:** add_reputation(amount=-2).
- **Yeni kod:** Y03/Y04 check, Y11 schedule_event aralığı ve çipi, Y14 top_skill, L01 subject:false.
- **Not:** Karar 9: tarih penceresi hafta ≥53; gerçek olay (Nisan 2014 ≈ tik 119) yumuşak tavanın ötesinde olduğu için tarihe çivilenmez, metin tarih yazmaz. Ç03: Erdem'in onayladığı −%1 / −%0,5 kalır; çip ondalık yüzdeyi yazar (Y12). 2. adımın −%2 / −%1'e katlaması geri alındı.

### #31 ek `kriz.acik.b2b` → `product.encryption_flaw_b2b`

- **Tetik:** günlük tarama; canlı ürün, hafta ≥53 (2013 ve sonrası, karar 9: kart dünyanın haberidir).
- **Guards:** {"market": "b2b", "product_live": true} · **sender:** employee · **tags:** ["urgent"].
- **Yuvalar:** employee:employee ← top_skill:engineering [subject:false] where hr.role[employee] == "developer".
- **Koşul:** sales.is_b2b == true ∧ time.week >= 53 ∧ sales.account_count >= 1.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [1, null], "product": "live", "modules": [], "min_week": 53, "subject_tenure_weeks": 4}; family `product_security`, family_subject {"once": true}; delay_weeks [0, 4]; latch {"one_shot": true}, latch_key run; expires_weeks 1.
- **Şıklar:**
  - `announce` “Yamala, basına duyur, hesaplardan şifrelerini değiştirmelerini iste”: add_reputation(amount=3); trust_delta(accounts="all", amount=-4)
    - Kazanç: İtibar +3. Bedel: bütün hesaplar −4. En iyi: hesaplar eşikten uzakken.
  - `mail_accounts` “Yamala, yalnız hesaplara mail at”: add_reputation(amount=1); trust_delta(accounts="all", amount=-2)
    - Kazanç: İtibar +1. Bedel: bütün hesaplar −2. En iyi: hesaplar eşiğe yakınken.
  - `stay_quiet` “Yamala, kimseye duyurma”: (etki yok) · **check** `olay.odds_10` → on_pass [schedule_event(event_id="product.encryption_flaw_press_b2b", delay_weeks=[4, 8])] / on_fail []
    - Kazanç: kitle/hesaplar değişmez. Bedel: yalnız risk (çip: '%10 ihtimalle: 4 ile 8 hafta sonra: İtibar −8, …'). Risk: %10 (olay.odds_10): 4–8 hafta sonra basın kartı. En iyi: büyüme her şeyken, itibar payı varken.
- **on_expire:** add_reputation(amount=-2).
- **Yeni kod:** Y03/Y04 check, Y11 schedule_event aralığı ve çipi, Y14 top_skill, L01 subject:false.
- **Not:** B2B ikizi; B2C kartıyla aynı aile (product_security), koşuda yalnız biri. Y26 accounts all.

### #31 ek `kriz.acik.basin` → `product.encryption_flaw_press`

- **Tetik:** product.encryption_flaw 'stay_quiet' şıkkının check dalı (schedule_event [4, 8] hafta).
- **follows:** `product.encryption_flaw`.
- **Guards:** {"market": "b2c"} · **sender:** press · **tags:** [].
- **Yuvalar:** yok.
- **Koşul:** {}.
- **Makullük:** {"phase_band": ["bootstrap_solo", "bootstrap_team", "traction", "series_a"], "headcount": [0, null], "product": "live", "modules": [], "min_week": 0}; family `product_security`; delay_weeks [0, 0] (zincir: ana kart zamanlar); latch {"one_shot": true}, latch_key run; expires_weeks 1.
- **Şıklar:**
  - `no_comment` “Yorum yapmayalım”: add_reputation(amount=-8); audience_delta(pct=-0.05)
    - Kazanç: yok (açık beat). Bedel: İtibar −8, Kitle −%5. En iyi: tek şık.
- **on_expire:** add_reputation(amount=-8); audience_delta(pct=-0.05).
- **Yeni kod:** Y12 ondalık yüzde (gerekmez: −%5).
- **Not:** Tek şıklı beat, bedeli var (O2 geçer). Etki pazara göre dallanamaz: iki dosya, aynı metin bloğu (Ç22). Erdem'in onayladığı #31 3. şık satırı.

### #31 ek `kriz.acik.basin` → `product.encryption_flaw_press_b2b`

- **Tetik:** product.encryption_flaw_b2b 'stay_quiet' şıkkının check dalı (schedule_event [4, 8] hafta).
- **follows:** `product.encryption_flaw_b2b`.
- **Guards:** {"market": "b2b"} · **sender:** press · **tags:** [].
- **Yuvalar:** yok.
- **Koşul:** {}.
- **Makullük:** {"phase_band": ["bootstrap_solo", "bootstrap_team", "traction", "series_a"], "headcount": [0, null], "product": "live", "modules": [], "min_week": 0}; family `product_security`; delay_weeks [0, 0] (zincir: ana kart zamanlar); latch {"one_shot": true}, latch_key run; expires_weeks 1.
- **Şıklar:**
  - `no_comment` “Yorum yapmayalım”: add_reputation(amount=-8); trust_delta(accounts="all", amount=-8)
    - Kazanç: yok (açık beat). Bedel: İtibar −8, bütün hesaplar −8. En iyi: tek şık.
- **on_expire:** add_reputation(amount=-8); trust_delta(accounts="all", amount=-8).
- **Yeni kod:** Y26 accounts all.
- **Not:** Tek şıklı beat, bedeli var (O2 geçer). Etki pazara göre dallanamaz: iki dosya, aynı metin bloğu (Ç22). Erdem'in onayladığı #31 3. şık satırı.

### #32 `kriz.ameliyat` → `product.sprint_pm_hospital`

- **Tetik:** SprintSystem._request_decision; müşteri isteği kartı Geliştirme'deyken; decision.cards havuzu (I02).
- **Kâğıt:** speaker_role "product_manager", stage any, pool_group pm.
- **Guards:** {"market": "b2b", "product_live": true} · **sender:** employee · **tags:** [].
- **Yuvalar:** employee:employee ← verilir; customer:customer ← verilir; dev:employee ← decision_dev; taker:employee ← random (isteğe bağlı) where hr.role[taker] == "developer".
- **Koşul:** urun.sprint_running == true ∧ urun.decision_phase == 1.
- **Makullük:** {"phase_band": ["bootstrap_team", "traction", "series_a"], "headcount": [3, null], "product": "live", "modules": [], "min_week": 0, "subject_tenure_weeks": 0, "fresh_reason": "kişiler kartın üstündekilerdir"}; family `sprint_pm`, family_subject {"cooldown_weeks": 52}; delay_weeks [0, 0] (request); latch {"cooldown_weeks": 52, "max_fires": 3}, latch_key run; expires_weeks 1.
- **Şıklar:**
  - `wait` “Kart {dev} dönene kadar beklesin”: sick_leave(scope="dev", weeks=2); sprint_card_carry()
    - Kazanç: ek iş yok, kişi kendi kodunu kaldığı yerden sürer. Bedel: kart sonraki sprinte kalır. En iyi: kart sözsüzken.
  - `hand_over` “Kartı başka bir geliştirici devralsın”: sick_leave(scope="dev", weeks=2); assign_to(card="decision", scope="taker", weeks=2); sprint_card_effort(amount_seam="urun.decision_card_effort", amount_mult=0.2) · **requires** entity_exists taker, kilit: “Ekipte kartı devralacak başka bir yazılımcı yok.” / “There is no other developer on the team to take the card.”
    - Kazanç: kart bu sprintte sürer. Bedel: kartın işi %20 büyür, devralanın kendi kartı bekler. En iyi: kart sözlüyken.
  - `call_brief` “{dev} taburcu olunca on dakika arayıp kaldığı yeri anlatsın”: sick_leave(scope="dev", weeks=2); change_morale(scope="dev", amount=-6)
    - Kazanç: kart ek iş olmadan sürer. Bedel: hasta kişinin morali −6. En iyi: kişinin morali yüksek, kart acilken.
- **on_expire:** sick_leave(scope="dev", weeks=2); sprint_card_carry().
- **Yeni kod:** Y07 random, Y13 hr.role, Y17 sick_leave, Y37 assign_to (+pin_card, I01), Y40 decision_dev.
- **Not:** Karar 14 ve 15. Ç23: 1. şık sick_leave + sprint_card_carry (2. adım; 3. adımın 'assign_to dev' kilidi değil: hasta kişiye kilit çipte anlamsız). Yokluk her yolda: her şıkta ve on_expire'da. PM kâğıdı yalnız 'request' kartında gelir (B2C'de gelmez).

## 4. Kod (4. adım)

Sıra ve bağımlılık:

1. **olasılık** — olasılık ve motor temeli: oran tablosu, check + effects, check çipi, lint, yıl zarı, tohumlu ve rakip seçicileri, seçici doğrulaması, amount_slot, schedule_event aralığı ve çipi, ondalık yüzde. Bağımlılık: yok (ilk). Öbür dört grubun smoke ve çipleri buna dayanır.
2. **kişi** — hr.role, top_skill seçicisi, izin çakışması seam'leri ve seçicileri, summer_leave, sick_leave, promote, üç finans etiketi. Bağımlılık: 1 (seçici listesi, amount_slot, çip altyapısı)
3. **satış ve hesap** — account_notice, süreli MRR indirimi, aday teklifi, drop_prospect, aday ve müşteri seam'leri, trust_delta kümeleri, take_account, kapsamlı söz fiilleri, pitch_focus, time.quarter_start. Bağımlılık: 1 (check dalı, seçiciler). Y22, Y21'i kullanır.
4. **altyapı** — fiyat çarpanı ve kilit (ProductState), InfraSystem kilidi ve lock_reason(), server_price, server_lock, run_probe koruması; mail_pane sunucu maddesi düğmesi. Bağımlılık: 1 (çipler). Y36 Temizlik B3'ün commit'ine bağlı (karar 1). Commit'ten sonra URUN_ARAYUZU'na I03.
5. **sprint ve kâğıt** — assign_to kolu ve SprintSystem.pin_card, queue_card ve SprintBridges.open_request, after_test ve EvWatch, kâğıt seçicileri, urun.line_tier. Bağımlılık: 1 ve 3 (after_test'in iç etkisi 'slots' kümesini kullanır). URUN_ARAYUZU'nun I01 commit'i (pin'i okuyan _assign) gelmeden assign_to'nun smoke'u koşulmaz; gelmezse pin_card ve kol commit'lenir, kilit davranışı I01 ile açılır.

Her grubun commit'i: önek `Olaylar n:`, push yok; diff'i bir Opus (high) ajanı inceler, en çok 1 inceleme ve 1 düzeltme; kapı ORTAK_CALISMA §3'ün özel index yöntemiyle, birleşik ağaçta. `_vocabulary.md` (`--event-vocab`), kod haritası ve sinyal manifesti birleşik ağaçta yeniden üretilir, elle düzenlenmez. Yalnız JSON ve metin taşıyan commit (5. adımın kartları) ayrı incelenmez.

### 4.1 olasılık (`Olaylar 1: …`)

**Y01 `olay.odds_10 / olay.odds_15 / olay.odds_20 / olay.odds_25`** — seam (GLOBAL FLOAT). Kaynak: 3. adım Y01.

- İmza: EvSeams.register("olay.odds_<n>", Kind.GLOBAL, TYPE_FLOAT, func(): return EvTuning.ODDS["odds_<n>"], "Events", note) ; EvTuning.ODDS := {"odds_10": 0.10, "odds_15": 0.15, "odds_20": 0.20, "odds_25": 0.25} [WORKING]
- Sahip: Olay motoru (EvTuning tek [WORKING] tablosu) · Dosya: scripts/events/core/tuning.gd, scripts/events/seams/seams_incident.gd (yeni _install_odds; olay. ad alani orada) · Dosya sahibi: OLAYLAR
- Durum alanı: yok (sabit tablo) · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: seam; cipi Y04 cizer (EFFECT_CHANCE)
- Lint: odds_seam kayitli GLOBAL seam olmali (lint.gd:209-213, var). Y05: bu tablodaki seam'ler modifier_lines zorunlulugundan muaf.
- `--event-vocab`: seam listesine 4 satir (olay. ad alani) · Smoke: Y03'un vakasi okur; ayri vaka yok
- Kullanan: team.rude_client (15), rival.new_firm_warning (20), world.data_location (25), world.award_final video 15 / slayt 10, product.encryption_flaw ve _b2b (10)
- Gerekçe: Degistirici kurallari: sabit ihtimal EvTuning'de tek tabloda, adli seam'le okunur; karta sayi yazilmaz (motor GDD §9.2, I7). Ad deseni: {seam:} metin regex'i (presenter.gd SEAM_RE) rakam kabul etmez ama bu seam'ler metne girmez; EvSeams.register ad dogrulamaz (seams.gd:31-36).

**Y02 `olay.award_live_odds (GLOBAL FLOAT), olay.award_live_slip (GLOBAL INT)`** — seam (durumdan gelen oran ve kayıp dalının tutarı). Kaynak: plan (yeni).

- İmza: olay.award_live_odds = maxf(EvTuning.AWARD_LIVE_FLOOR, EvTuning.AWARD_LIVE_BASE - EvTuning.AWARD_LIVE_PER_BUG * mini(ProductState.open_bugs(), EvTuning.AWARD_LIVE_BUG_CAP)) ; olay.award_live_slip = EvTuning.AWARD_SLIP_CLEAN if ProductState.open_bugs() == 0 else EvTuning.AWARD_SLIP_BUGGY ; EvTuning: AWARD_LIVE_BASE 0.25, AWARD_LIVE_PER_BUG 0.05, AWARD_LIVE_BUG_CAP 3, AWARD_LIVE_FLOOR 0.10, AWARD_SLIP_CLEAN 1, AWARD_SLIP_BUGGY -2 [WORKING]
- Sahip: Olay motoru (okur: ProductState.open_bugs) · Dosya: scripts/events/core/tuning.gd, scripts/events/seams/seams_incident.gd (olay. ad alanı) · Dosya sahibi: OLAYLAR
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: Y04 çizer; kartın modifier_lines'ında urun.open_bugs 'Açık hatalar' / 'Open bugs' (ipucu, sayısız)
- Lint: 17.11: modifier_lines zorunlu kalır (durumdan gelen oran)
- `--event-vocab`: seam listesine 2 satır · Smoke: yok (okuyucu; event_check_with_effects'in bir kolu bu seam'le koşar)
- Kullanan: world.award_final live_demo
- Gerekçe: Ç02: #30'un 1. şıkkı tek zar taşır; takılma ayrı zar değil, ödül oranının ve kayıp dalının durumdan okunan parçasıdır (2. adım). 3. adımın check dizisi ve olay.stumble_odds yazılmaz.

**Y03 `check + effects birlikte (seçenek başına tek check)`** — motor degisikligi. Kaynak: 3. adım Y03.

- İmza: EvEngine.resolve (engine.gd:642): option.effects run_played ile, ardından check varsa dal run_check_branch ile koşar; deltas = effects + dal; outcome '<id>_pass' / '<id>_fail' korunur; zar anahtarı değişmez (EvDice.check(odds, event_id, option_id)). presenter.gd:72 choice'a check'i de taşır.
- Sahip: Olay motoru · Dosya: scripts/events/core/engine.gd:642-651 (resolve), scripts/events/present/presenter.gd:72 (choice.checks tasinir), scripts/events/tools/lint.gd:207-219 · Dosya sahibi: OLAYLAR
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz; outcome '<id>_pass' / '<id>_fail' biçimi korunur
- Sinyal: yok · Bot: run_probe _pick_choice yalniz choice.modifiers (effects) okur (run_probe.gd:1027-1077, 1102-1109); check dalindaki para gormezden gelinir, degisiklik gerekmez
- Çip: Y04
- Lint: check varken effects artik yasal; her check odds_seam ister; on_pass/on_fail 'check' kokeniyle lint'lenir (var).
- `--event-vocab`: yok · Smoke: YENİ vaka event_check_with_effects (fikstür kart): effects iki dalda da iner; dal zarı event_dice_is_stable ile aynı kalır; geçmiş satırı deltas'ı iki parçayla yazar; yükle-tekrar aynı dal
- Kullanan: team.rude_client 2. şık, rival.new_firm_warning 1. şık, world.data_location 3. şık, world.award_final üç şık (tek zar), product.encryption_flaw(_b2b) 3. şık
- Gerekçe: Bugün check varsa effects hiç koşmaz (engine.gd:642-651). Görevin her kumarının kesin bir parçası var; kesin parçayı iki dala kopyalamak çipte aynı satırı iki kez çizerdi. GDD §3.3 seçenek şeması effects ve check'i yan yana sayar. Ç02: check dizisi YOK.

**Y04 `check dali cipi (EvChips)`** — cip / sunum. Kaynak: 3. adım Y04.

- İmza: EvChips.describe_check(check, ctx, names) -> Array: boş olmayan her dal için başlık parçası EFFECT_CHANCE {pct} + dalın çipleri; on_pass p = roundi(odds × 100), on_fail 100 − p; dal cost/danger çip taşıyorsa başlık 'danger', yoksa 'gain'; boş dal çizilmez. presenter seçeneğin çiplerine ekler; mail_pane.gd seçenek ve geçmiş satırı (küçük hunk).
- Sahip: Olay motoru sunumu · Dosya: scripts/events/present/chips.gd, scripts/events/present/presenter.gd:72, scripts/tabs/events/mail_pane.gd:342-343 (secenek cipleri) ve :576 (gecmis satiri) · Dosya sahibi: OLAYLAR + ortak (mail_pane.gd kucuk hunk)
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: EFFECT_CHANCE (danger | gain (dala gore)) TR “%{pct} ihtimalle:” EN “{pct}% chance:”
- Lint: O2: secenegin check dallarindaki cost/danger cipi bedel sayilir (lint.gd:645-658 _has_cost dallara bakar)
- `--event-vocab`: yok · Smoke: event_chip_coverage (var) check dallarindaki fiilleri de saymali
- Kullanan: Y03'un kartlari
- Gerekçe: Ç01: EvDice.check odds ihtimalle PASS döndürür (dice.gd:39-40) ve GDD §9.2'nin örneği (hr.retention_odds) geçme oranıdır. Görev metni '%15 ihtimalle:' + on_fail der; anlamı korumak için RİSK DALI on_pass'a yazılır, oran o dalın oranıdır. Semantiği ters çevirmek ileride check kullanacak her kartı bozardı. Oran hep görünür (§9.5/§9.6); sayı yalnız seam'den gelir, karta yazılmaz (I7).

**Y05 `lint: sabit oran muafiyeti, dal ve sonra-etkisi taraması`** — lint. Kaynak: 3. adım Y05.

- İmza: 17.11 (lint.gd:207-219): odds_seam EvTuning.ODDS tablosundan geliyorsa modifier_lines istenmez; _is_chained (lint.gd:492) ve erişilebilirlik (lint.gd:895) options[].effects yerine _option_effects (dallar dahil) + on_expire.penalties + after_test'in iç effects'ini gezer; O2 (_has_cost) dalları zaten sayar (lint.gd:624-629), değişmez.
- Sahip: Olay motoru araci · Dosya: scripts/events/tools/lint.gd · Dosya sahibi: OLAYLAR
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: yok
- Lint: kendisi
- `--event-vocab`: yok · Smoke: yok (--event-lint kapisi)
- Kullanan: world.data_claim_exposed ve iki basın kartı (yalnız check dalında zamanlanır), team.master_degree_farewell (on_expire da zamanlar)
- Gerekçe: Sabit oranın arkasında durum yok; I7'nin 'seam yoksa modifier yok' kuralı ona satır bulamaz. Bu GDD §17.11'den bir sapmadır: motor md'nin §27 inşa notlarına yazılır. Dal içindeki schedule_event bugün 'referanssız' sayılır (world.data_claim_exposed ve basın kartları yalnız dalda zamanlanır).

**L01 `yuva 'subject': false (O4)`** — lint + şema notu. Kaynak: plan (yeni).

- İmza: lint.gd _lint_v3_options: subject_slots yapılırken spec.get('subject', true) == false olan yuva atlanır; motor alanı okumaz.
- Sahip: Olay motoru aracı · Dosya: scripts/events/tools/lint.gd:520-530 · Dosya sahibi: OLAYLAR
- Durum alanı: kart JSON yuvası · varsayılan: true · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: yok
- Lint: O4 kendisi
- `--event-vocab`: yok · Smoke: yok (--event-lint kapısı)
- Kullanan: world.server_price_hike, world.award_final, product.encryption_flaw, product.encryption_flaw_b2b
- Gerekçe: Bu kartlarda çalışan yuvası gönderen ya da metinde anılan kişidir; kartın öznesi şirketin faturası, markası ya da itibarıdır. O4 bugün her employee yuvasını özne sayar ve öbür şıkları 'özneye bir şey düşürmüyor' diye düşürürdü. Baseline'a dört kart yazmak yerine yuvanın kendisi söyler. GDD §3.1'e §27 notu.

**Y06 `kosul yapragi year_roll`** — kosul yapragi. Kaynak: 3. adım Y06.

- İmza: {"year_roll": 0.5, "key": "<istege bagli>"} -> EvDice.unit("year", int(GameState.get_date_dict().year), key, "") < deger ; key yazilmazsa EvCatalog yuklemede kart id'sini damgalar
- Sahip: Olay motoru · Dosya: scripts/events/core/condition.gd:173 (_leaf), scripts/events/catalog/catalog.gd (yuklemede key damgasi, _compile_plausibility'nin yanina), scripts/events/tools/why.gd (yaprak raporu), scripts/events/tools/lint.gd (yaprak tanimi) · Dosya sahibi: OLAYLAR
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz (zar tohumdan ve yildan turer)
- Sinyal: yok · Bot: yok
- Çip: yok (kosul)
- Lint: bilinmeyen yaprak FALSE + push_error bugun (condition.gd:197-201); yeni yaprak tanitilir, deger 0..1
- `--event-vocab`: kosul yapraklari bolumune 1 satir (vocab_gen yapraklari listeliyorsa) · Smoke: YENI vaka event_year_roll: ayni tohum + ayni yil ayni sonuc, yil degisince yeniden zar (olay motoru)
- Kullanan: team.same_leave_pm/dev/tester (0.5 [WORKING])
- Gerekçe: Karar 4e. Seam'ler argumansizdir ve kart id'sini bilmez (E_dunya §3.3); EvCondition.eval(node, ctx) kartı bilmez (condition.gd:31), bu yuzden anahtar yuklemede yapraga yazilir. Uc varyantin tek zarla yilda bir gelmesi istenirse key olarak aile adi yazilir (oneri: key yazilmaz, aile freni Y-K05 ile yilda bire iner).

**Y07 `secici random (tohumlu)`** — kapsam secicisi. Kaynak: 3. adım Y07.

- İmza: EvScope.resolve(slots, given, card_id := "") ; _select(type, mode, used, bound, key) ; "random": havuz id'ye gore siralanir, i = floori(EvDice.unit("pick", GameState.day, card_id, slot_name) * havuz.size())
- Sahip: Olay motoru (kapsam) · Dosya: scripts/events/gate/scope.gd:54, 211-251, 254, 285, scripts/events/gate/gate.gd:109 (resolve cagrisi card_id gecer) · Dosya sahibi: OLAYLAR
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz; baglanan yuva ctx'te donar
- Sinyal: yok · Bot: yok
- Çip: yok
- Lint: Y09 secici adini dogrular
- `--event-vocab`: secici listesi (vocab_gen seciciyi yaziyorsa) · Smoke: event_year_roll vakasi icinde ikinci kol: ayni tohum ayni kisiyi, farkli tohumlar (20 tohum) en az iki farkli kisiyi secer
- Kullanan: team.wedding_invite, team.master_degree, team.rude_client (hesap), customer.training_request, customer.own_data_error, customer.finance_team, customer.old_browser (aday), rival.outage, world.data_location, product.sprint_pm_hospital (taker), rival secicileri (Y08)
- Gerekçe: Karar 16: rastgele secici tohumlu (EvDice), ayni tohum ayni kisi. Bugun her secici belirlenimci (scope.gd:204-209), _select karti bilmez. Anahtar gun + kart + yuva: resolve gun icinde propose, request ve why-fire icin tekrar cagrilinca ayni sonucu verir.

**Y08 `rakip secicileri sprint_rival, market_rival:<tier>; {rival} adi`** — kapsam secicisi + sunum duzeltmesi. Kaynak: 3. adım Y08.

- İmza: _select_rival(mode, used, key): havuz = RivalRegistry.get_all() suzulmus r.sub_product_type_id == ProductState.subtype(); "sprint_rival" -> SprintCatalog.rival_table() satirlari arasindan tohumlu; "market_rival:<giant|established|startup>" -> o kademeden tohumlu. presenter._name_of(TYPE_RIVAL) -> r.product_name
- Sahip: Olay motoru (okur: RivalRegistry, SprintCatalog.rival_table) · Dosya: scripts/events/gate/scope.gd:168-176, 211-216, scripts/events/present/presenter.gd:160-162 · Dosya sahibi: OLAYLAR
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: yok
- Lint: Y09
- `--event-vocab`: secici listesi · Smoke: yok (card_body_tokens_resolve gorsel kabulde {rival} adini dener)
- Kullanan: rival.outage (startup), product.sprint_test_rival_batch (sprint_rival), rival.new_firm_warning (established)
- Gerekçe: Karar 16: rakip adlari RivalRegistry'den. Bugun rival yuvasi butun 104 rakipten id sirasiyla ilkini baglar (scope.gd:176, 216) ve _name_of olmayan alani okur: Rival'da company_name yok, yalniz product_name (rival.gd:18; presenter.gd:162 r.company_name). Pythia ERP'nin established rakibidir ama sprint tablosunda degildir (E_dunya §1.2), bu yuzden iki ayri secici.

**Y09 `lint: secici adi dogrulamasi`** — lint. Kaynak: 3. adım Y09.

- İmza: EvScope.SELECTORS := {employee: [lowest_morale, newest_hire, most_senior, account_rep, support_lead, sprint_dev, random, top_skill:, leave_pair, leave_partner, lead_rep, decision_dev, quarter_pm], customer: [at_risk, escalated, expansion_ready, open_request, largest, smallest, line_top, line_warehouse, line_newest, line_slow, request, random], prospect: [rep_lead, random], rival: [sprint_rival, market_rival:, random], investor: [expiring_sheet, decision_sheet, seed_lead, random]} ; lint: slot.select listede değilse E (':' ile biten ad önektir). Her grup kendi seçicisini eklediği commit'te listeye yazar.
- Sahip: Olay motoru araci · Dosya: scripts/events/gate/scope.gd, scripts/events/tools/lint.gd · Dosya sahibi: OLAYLAR
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: yok
- Lint: yeni E kurali (17.12 ailesi)
- `--event-vocab`: yok · Smoke: yok
- Kullanan: butun yeni kartlar
- Gerekçe: Bu gorev 12 yeni secici ekliyor; bugun bilinmeyen secici sessizce 'id sirasiyla ilk bos' olur (scope.gd:216, 251, 282, 309; A_motor §15 TUZAK 7). Yazim hatasi gorsel kabulde bile fark edilmez (yine bir ad cikar).

**Y10 `amount_slot`** — motor (tutar). Kaynak: 3. adım Y10.

- İmza: EvEffects.amount(e: Dictionary, ctx: Dictionary = {}) -> int : e.has("amount_slot") ise roundi(float(EvSeams.read_for(e.amount_seam, entity_of({"scope": e.amount_slot}, ctx, ""))) * amount_mult)
- Sahip: Olay motoru · Dosya: scripts/events/core/effects.gd:677-683, 211-220 (_is_negative ctx alir), scripts/events/present/chips.gd:74 (ctx gecer), scripts/debug/run_probe.gd:1106 (EventGate.active_context() gecer), scripts/events/tools/lint.gd:301-304 · Dosya sahibi: OLAYLAR + ortak (run_probe.gd tek satir)
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: run_probe.gd:1106 ctx gecmezse 0 okur; tek satir
- Çip: fiilin kendi cipi; tutar ayni amount()'tan
- Lint: amount_slot varsa amount_seam ENTITY seam olmali ve turu (EvScope._type_for_seam) slotun turuyle ayni; GLOBAL kurali (lint.gd:301-304) yalniz slotsuz tutarda; ctx'siz _is_negative cagrisi isaret icin amount_mult'a bakar (lint.gd:244-246 gibi)
- `--event-vocab`: parametre notu · Smoke: event_amount_seam vakasi (endgame_smoke.gd:336, var) bir amount_slot koluyla genisler
- Kullanan: team.wedding_invite (hr.salary, employee), team.same_leave_dev / _tester prim şıkkı (hr.salary, other), customer.training_request 2. şık (musteri.mrr, customer)
- Gerekçe: Degistirici kurallari: yuvaya bagli tutar slotun entity seam'inden okunur; cip, gecmis satiri ve bot ayni ctx'le okur. Bugun amount_slot yok (effects.gd:677-683).

**Y11 `schedule_event: araligi gecikme ve hedefin kesin etkisi cipi`** — fiil genisletmesi + cip. Kaynak: 3. adım Y11.

- İmza: schedule_event {event_id, delay_weeks: int | [lo, hi], context?} ; [lo,hi] -> lo + floori(EvDice.unit("schedule", day, event_id, option_id) * (hi-lo+1)) ; cip: hedef kartin butun seceneklerinde (ve on_expire'inda) birebir ayni olan efektler EFFECT_LATER / EFFECT_LATER_RANGE basligiyla, ayni ctx'le cizilir; ortak efekt yoksa SILENT kalir
- Sahip: Olay motoru · Dosya: scripts/events/core/effects.gd:318-322, scripts/events/core/schedule.gd:28-40, scripts/events/present/chips.gd (SILENT_VERBS'ten cikar, kendi kolu) · Dosya sahibi: OLAYLAR
- Durum alanı: EvSchedule girdisi degismez (fire_on_day mutlak) · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: EFFECT_LATER (hedefin ciplerinden) TR “{n} hafta sonra:” EN “In {n} weeks:”; EFFECT_LATER_RANGE (hedefin ciplerinden) TR “{lo} ile {hi} hafta sonra:” EN “In {lo} to {hi} weeks:”
- Lint: O2 _has_cost hedefin ortak ciplerini sayar; delay_weeks dizi ise 0<=lo<=hi
- `--event-vocab`: parametre notu · Smoke: event_chip_coverage (var)
- Kullanan: team.master_degree (4 hafta), world.data_location dalı (3 hafta), product.encryption_flaw(_b2b) dalı ([4, 8] hafta)
- Gerekçe: Sonucu ileride inen sik bugun cipsiz ve O2'de bedelsiz gorunur (schedule_event SILENT, chips.gd:20-26). Yeni bir 'N hafta sonra ayrilir' HR zamanlayicisi yazmak yerine (B_ekip §7: yok) kartin kendi sonucu gosterilir: hedefin her yolda inen etkisi. Canli iki kullanici (customer.new_owner, rival.funding_round) cok secenekli ve ortak efektsiz hedeflere gider, gorunusleri degismez. #31'in '4 ile 8 hafta' penceresi araligi ister.

**Y12 `yuzde cipi ondalik`** — cip. Kaynak: 3. adım Y12.

- İmza: Fmt.signed_percent(pts, decimals := 0) ; chips.gd:194-198 audience pct icin round(pct*1000)/10
- Sahip: Sunum · Dosya: scripts/events/present/chips.gd:194-198, Fmt (ortak; signed_percent fmt.gd:144-145) · Dosya sahibi: OLAYLAR + ortak
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: EFFECT_AUDIENCE_PCT (var)
- Lint: yok
- `--event-vocab`: yok · Smoke: yok
- Kullanan: product.encryption_flaw 2. sik (Kitle -%0,5)
- Gerekçe: Ç03: #31'in Erdem'in onayladığı −%1 / −%0,5'i kalır; 2. adımın −%2 / −%1'e katlaması geri alınır. Çip yarım yüzdeyi yazamıyordu (chips.gd:194-198).

**Kabul ölçütü (kapı içinde, kendi APPDATA'sıyla, headless):**

- "$GODOT" --headless --path . --event-lint: yeni E yok; lint_baseline.json değişmez (bugünkü kartlar etkilenmez)
- loc_residue ve smoke loc_csv_integrity
- YENİ smoke event_check_with_effects, event_year_roll (tohumlu random seçici kolu dahil: aynı tohum aynı kişi, 20 tohumda en az iki farklı kişi)
- Genişleyen smoke event_amount_seam (amount_slot kolu), event_chip_coverage (check dalları ve schedule_event sonra-çipi sayılır)
- Var olan smoke: event_dice_is_stable, event_history_chip_matches_live, event_scope_where_filters_pool, event_delay_window, card_body_tokens_resolve ({rival} adı)
- --event-vocab birleşik ağaçta yeniden üretilir; python tools/gen_signal_manifest.py fark üretmez (yeni EventBus sinyali yok)
- Probe: --run-log=full_run:104:sim:1 ve full_run_b2c'nin ^PROBE satırları commit öncesiyle bayt-eş (motor değişikliği bugünkü kartların davranışını değiştirmez)
- Motor md §27'ye iki inşa notu (17.11 sabit oran muafiyeti, yuva subject:false)

### 4.2 kişi (`Olaylar 2: …`)

**Y13 `hr.role (ENTITY STRING)`** — seam. Kaynak: 3. adım Y13.

- İmza: hr.role(id) -> Character.role
- Sahip: HR · Dosya: scripts/events/seams/seams_hr.gd (_install_people, _install_company) · Dosya sahibi: OLAYLAR
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: yok
- Lint: where yapraklarinda kullanilir (_lint_where lint.gd:957-974)
- `--event-vocab`: 2 seam ailesi · Smoke: yok
- Kullanan: #7 üç varyant, #8 (lead), #9 (dev), #11, #18, #23, #30, #31 ve ikizi, #32 taker
- Gerekçe: Rol süzgeci bugün yok. hr.role_count.<rol> yalnız park edilen temsilcisiz yedeklere lazımdı (P01): yazılmaz.

**Y14 `secici top_skill:<alan>`** — kapsam secicisi (employee). Kaynak: 3. adım Y14.

- İmza: "top_skill:engineering" -> havuzda role_stats[alan] en buyuk, esitlikte id
- Sahip: Olay motoru (okur: Character.role_stats) · Dosya: scripts/events/gate/scope.gd:219-251 · Dosya sahibi: OLAYLAR
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: yok
- Lint: Y09
- `--event-vocab`: secici · Smoke: yok
- Kullanan: team.promise_made (dev), world.server_price_hike, world.award_final, product.encryption_flaw(_b2b)
- Gerekçe: revize2 'Yazılım yıldızı en yüksek geliştirici' dort kartta ister; most_senior seviyeye bakar, beceriye bakmaz (scope.gd:228).

**Y15 `izin çakışması: HRMoraleSystem.summer_week / leave_partner, hr.leave_weeks_left, seçici leave_pair / leave_partner`** — HR seam'i + entity seam + iki secici. Kaynak: 3. adım Y15.

- İmza: HRMoraleSystem.summer_week(emp, year) -> int (bu yıl için kayma varsa onu, yoksa leave_week) ; HRMoraleSystem.leave_partner(emp) -> String: aynı role'deki ACTIVE, bu yıl izni alınmamış, |summer_week farkı| <= 1 olan en yakın kişi (eşitlikte işe giriş sırası) ; hr.leave_weeks_left (ENTITY INT): bu yılın izninin başlamasına kalan hafta, alınmışsa ya da pencere geçtiyse -1 ; seçici leave_pair: havuzdan partneri olan ve summer_week'i partnerinkinden büyük olmayan (önce izne çıkan) en kıdemli ; leave_partner: bound['employee']'in partneri ; EvTuning.FAMILY_GAP_WEEKS['team_summer_leave'] = 52 [WORKING] (plausibility.gd:54'teki kopya EvTuning.family_gap'i okuyacak şekilde silinir; kopya bilinçliyse iki yere yazılır)
- Sahip: HR · Dosya: scripts/systems/hr_morale_system.gd (45-66 yanina), scripts/events/seams/seams_hr.gd, scripts/events/gate/scope.gd:219-251 · Dosya sahibi: ortak (hr_morale_system.gd) + OLAYLAR
- Durum alanı: Character.leave_week (var), Y16'nin override alanlari · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: yok
- Lint: Y09
- `--event-vocab`: 1 seam, 2 secici · Smoke: hr_leave_shift vakasinin icinde (Y16)
- Kullanan: team.same_leave_pm/dev/tester
- Gerekçe: Karar 4a/4b. Ç08: yuva sırası önce izne çıkan (employee, gönderen) / geç başlayan (other, kayan); prim other'ın maaşından okunur. 3. adımın hr.pair_leave_weeks'i yerine tek kişilik hr.leave_weeks_left (önce çıkanın kalan haftası çiftin en küçüğüdür).

**Y16 `summer_leave {scope, other, apart: bool}`** — fiil + HR seam'i (3. adımın shift_leave'inin yerine). Kaynak: plan (yeni).

- İmza: summer_leave -> HRMoraleSystem.plan_summer_leave(a: Character, b: Character, apart: bool) -> Dictionary {moved_id, week, weeks_away, a_week} ; apart: geç başlayanın bu yılki haftası partner_week + HRConstants.LEAVE_WEEKS'e (pencere HRConstants.LEAVE_WEEK_COUNT - 1'i aşarsa erken başlayan later_week - LEAVE_WEEKS'e) ; together (apart false): ikisinin de bu yılki haftası bugünkü summer_week'e sabitlenir ; yazıcı CharacterRegistry.set_leave_override(id, week, year) ; tick_leave_departures (hr_morale_system.gd:45-66) emp.leave_week yerine summer_week(emp, year) okur
- Sahip: HR (HRMoraleSystem; yazıcı CharacterRegistry) · Dosya: scripts/systems/hr_morale_system.gd, scripts/autoload/character_registry.gd, scripts/data_models/character.gd, scripts/events/core/effects.gd, scripts/events/present/chips.gd, scripts/events/tools/lint.gd, localization/strings.csv (EFFECT_ ailesi) · Dosya sahibi: ortak + OLAYLAR
- Durum alanı: Character.leave_week_override: int = -1, Character.leave_override_year: int = 0 (@export) · varsayılan: -1 / 0 = kayma yok · kayıt: sürüm artmaz (SaveCodec @export alanını kendisi bulur, eski kayıtta varsayılan); yıl alanı 2012 takvimiyle doğar, OLD_CALENDAR_YEAR_SHIFT gerekmez
- Sinyal: yok (HR sekmesi hr_day_processed ile yeniden çizer) · Bot: yok
- Çip: EFFECT_LEAVE_SHIFT (cost) TR “Yaz izni kayar: {name}, {n} hafta” EN “Summer leave moves: {name}, {n} weeks”; EFFECT_LEAVE_TOGETHER (cost) TR “Yaz izni: {a} ile {b} aynı iki hafta, {n} hafta sonra” EN “Summer leave: {a} and {b} away the same two weeks, in {n} weeks”
- Lint: WRITER_VERBS, NEUTRAL_VERBS, CONSEQUENCE_VERBS (iki kipte de bedel), SUBJECT_VERBS employee; 'other' bir employee yuvası olmalı
- `--event-vocab`: fiil listesine 1 satır · Smoke: YENİ vaka hr_leave_shift: apart yalnız bu yıl kayar ve gelecek yıl leave_week'e döner; together haftayı değiştirmez; kayıt yükle
- Kullanan: team.same_leave_pm/dev/tester
- Gerekçe: Karar 4d ve 4f. Ç06: 'İkisi de gitsin' şıkkının bedeli (iki kişi aynı iki hafta yok) çipte görünmezse şık O2'de bedava kalır ve karar 4f 'çip iki izni yazar' der. Fiil bu yılın haftasını sabitler (gerçek yazım, aynı alan) ve izni çipte yazar; izni başlatan yine HR'nin kendi tikidir. send_on_leave kullanılmaz (oyuncunun izni: yaz iznini yer, 8 hafta bekleme).

**Y17 `sick_leave`** — fiil + HR seam'i. Kaynak: 3. adım Y17.

- İmza: sick_leave {scope, weeks} -> HRMoraleSystem.send_on_sick_leave(emp, weeks): CharacterRegistry.set_status(id, STATUS_ON_LEAVE) ve yeni CharacterRegistry.set_away(id, 'sick', day + TimeModel.ticks(weeks)); leave_taken_year ve leave_until_day YAZILMAZ, başlangıç haberi yok; tick_leave_returns leave_kind == 'sick' için away_until_day'i okur, dönüş morali vermez, HR_NEWS_BACK_TO_WORK yazar, leave_kind'i boşaltır
- Sahip: HR · Dosya: scripts/systems/hr_morale_system.gd:31-42, 252-266, scripts/systems/hr_system.gd (weeks_until_return / leave_line ayni bitisi okur), scripts/data_models/character.gd, localization/strings.csv, scripts/events/core/effects.gd, scripts/events/present/chips.gd, scripts/events/tools/lint.gd · Dosya sahibi: ortak + OLAYLAR
- Durum alanı: Character.leave_kind: String = "", Character.away_until_day: int = 0 · varsayılan: "" / 0 · kayıt: surum artmaz
- Sinyal: CharacterRegistry.set_status'un mevcut yayini; headline_added yalniz donuste · Bot: yok
- Çip: EFFECT_SICK_LEAVE (cost) TR “{name} {n} hafta yok” EN “{name} is away for {n} weeks”
- Lint: NEUTRAL_VERBS, WRITER_VERBS, SUBJECT_VERBS employee
- `--event-vocab`: 1 fiil · Smoke: YENI vaka hr_sick_leave: sprint team()'den dusar, leave_taken_year degismez, donus morali 0, oyuncunun izin beklemesi (leave_cooldown_left) kisalmaz, kayit yukle
- Kullanan: product.sprint_pm_hospital (uc sik ve on_expire)
- Gerekçe: Karar 14. Yeni status yerine on_leave + tur alani: SprintSystem.away(), HRSystem.effective_skill, WorkHours, get_active_employees zaten on_leave'i disarir (B_ekip §1, §3: yeni status 15 yere dokunurdu). Ayri bitis alani oyuncunun yaz/tatil bekleme sayacini (leave_until_day'den, hr_actions.gd:180-183) bozmaz. Bilinen kenar: hastalik yaz izni haftasina denk gelirse o yilin yaz izni atlanir (hr_morale_system.gd:58, telafi yok); bugunku egitim kurali ile ayni.

**Y18 `promote`** — fiil. Kaynak: 3. adım Y18.

- İmza: promote {scope, pct} -> HRActions.apply_promotion(emp, pct) (hr_actions.gd:136) ; cip HRActions.preview_promotion (hr_actions.gd:111) ile
- Sahip: HR · Dosya: scripts/events/core/effects.gd (ECONOMIC_VERBS + kol), scripts/events/present/chips.gd, scripts/events/tools/lint.gd · Dosya sahibi: OLAYLAR
- Durum alanı: HR'nin kendi alanlari (level, monthly_salary, last_promotion_day) · varsayılan: - · kayıt: etkisiz
- Sinyal: EventBus.employee_promoted (var, HRActions yayar) · Bot: yok
- Çip: EFFECT_PROMOTION (cost) TR “{name} {level} olur, maaşı ayda {v}” EN “{name} becomes {level}, salary {v} a month”
- Lint: WRITER_VERBS, SUBJECT_VERBS employee; refused (ust seviye) loglanir
- `--event-vocab`: 1 fiil · Smoke: yok (HRActions'in kendi smoke'u var: hr_raise_and_leave); event_chip_coverage
- Kullanan: team.master_degree 2. sik
- Gerekçe: Karar 15. apply_promotion maasi da pct ile artirir ve moral verir (hr_actions.gd:136-155); #5'in 'Orta seviyeye gecer, maasi %15 artar' satiri tek cagridir. apply_raise ayni anda cagrilirsa zam iki kez iner; raise_salary fiili bu yuzden yazilmaz (kullanan kart yok, CLAUDE.md §8), park listesinde.

**Y19 `add_cash etiketleri equipment, gift, award`** — veri (ONE_TIME_LABELS + CSV). Kaynak: 3. adım Y19.

- İmza: FinanceSystem.ONE_TIME_LABELS'a 3 anahtar; CSV FIN_ONETIME_EQUIPMENT 'Ekipman'/'Equipment', FIN_ONETIME_GIFT 'Hediye'/'Gift', FIN_ONETIME_AWARD 'Ödül'/'Award'
- Sahip: Finans · Dosya: scripts/systems/finance_system.gd:31-58, localization/strings.csv (FIN_ONETIME_ ailesinin blogu) · Dosya sahibi: ortak
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: EFFECT_CASH (var)
- Lint: lint.gd:311-315 etiketi listede arar
- `--event-vocab`: yok · Smoke: loc_csv_integrity
- Kullanan: team.work_laptop (equipment), team.wedding_invite (gift), world.award_final (award, pozitif: apply_one_time_income)
- Gerekçe: Ç07: #7'nin primi var olan 'retention' etiketini kullanır (FIN_ONETIME_RETENTION 'Bağlılık primi' / 'Retention bonus'); 'bonus' yazılmaz. #10 'training' (HR_COST_TRAINING 'Eğitim ücreti').

**Kabul ölçütü (kapı içinde, kendi APPDATA'sıyla, headless):**

- --event-lint, loc_residue, loc_csv_integrity
- YENİ smoke hr_leave_shift, hr_sick_leave (sprint team()'den düşer, leave_taken_year değişmez, dönüş morali 0, oyuncunun izin beklemesi kısalmaz, kayıt yükle)
- Var olan smoke: hr_leave_cycle, hr_raise_and_leave, save_roundtrip_fingerprint, save_old_calendar_leave_year, sprint_away_lists_who_cannot_work, event_chip_coverage
- Probe: --run-log=full_run_staff25:104:sim:1 ^PROBE satırları bayt-eş (yaz izni haftası override yokken aynı)

### 4.3 satış ve hesap (`Olaylar 3: …`)

**Y20 `account_notice (fesih bildirimi, maddeden bagimsiz)`** — fiil + Customer alanlari + CustomerRegistry seam'i + B2BSalesSystem islevi. Kaynak: 3. adım Y20.

- İmza: account_notice {scope, reason, mail := true} -> B2BSalesSystem.give_notice(c: Customer, reason: String, mail: bool) -> bool : CustomerRegistry.set_exit_notice(id, day + ticks(B2BConstants.EXIT_NOTICE_WEEKS [4, WORKING]), reason); mail ise MessageSystem.post("exit_notice", ...) ; zaten bildirim varsa false ; B2BSalesSystem._tick_customer (b2b_sales_system.gd:48) basinda: exit_notice_day >= 0 ve day >= exit_notice_day -> SalesSystem.record_sales_event("notice_ended", reason, ...) + _remove_lost(c) + return
- Sahip: B2B satis (B2BSalesSystem); yazici CustomerRegistry · Dosya: scripts/data_models/customer.gd, scripts/autoload/customer_registry.gd (set_clause :239 yanina), scripts/systems/b2b_sales_system.gd:48, 303-310, scripts/systems/b2b_constants.gd:49-59, scripts/ui/components/inbox.gd:18, 316 (yeni mesaj turu), scripts/tabs/events/mail_pane.gd:137 (tur adi), scripts/tabs/sales_tab.gd:495-507, 542 (etiket ve gunluk), localization/strings.csv, scripts/events/core/effects.gd, scripts/events/present/chips.gd, scripts/events/tools/lint.gd · Dosya sahibi: ortak + OLAYLAR
- Durum alanı: Customer.exit_notice_day: int = -1, Customer.exit_notice_reason: String = "" · varsayılan: -1 / "" = bildirim yok · kayıt: surum artmaz (bildirilmis varsayilan; C_satis §10)
- Sinyal: set_exit_notice sinyalsiz (set_clause gibi; okuyanlar gunun tikinde cizer); hesap dusunce _remove_lost'un customer_churned yayini · Bot: istege bagli: PROBE END'e notice_ended= sayaci (clause_ended= gibi)
- Çip: EFFECT_ACCOUNT_NOTICE (danger) TR “Fesih bildirimi: {company}, sözleşme {n} hafta sonra biter” EN “Notice given: {company} leaves in {n} weeks”
- Lint: ECONOMIC_VERBS (kayip; _is_negative tutarsiz fiili kayip sayar, effects.gd:218-220 listesine girer), WRITER_VERBS, SUBJECT_VERBS customer
- `--event-vocab`: 1 fiil, 1 seam (musteri.has_notice) · Smoke: YENI vaka b2b_exit_notice: bildirim -> 4 tik sonra hesap duser, MRR reflect_mrr'den gecer, Kurumsal'a gecis (meet_clauses) bildirimi geri aldirmaz, kayit yukle (cekirdek: ekonomi, kayit)
- Kullanan: team.rude_client 2. sik (check dali, mail true), world.data_claim_exposed (iki sik ve on_expire, mail false: kartin kendisi bildirimdir)
- Gerekçe: Karar 6. Ayri alan, sunucu maddesinin notice_end_day'ini paylasmaz: meet_clauses notice_end_day'i olan her maddeli hesabi geri aldirir ve _tick_customer'in kapisi clause_due_day >= 0'dir (b2b_sales_system.gd:49, 339-345, 350-354); sales_tab ve mail_pane etiketi o alani sunucuya baglar (C_satis §1). Paylasilsaydi maddesiz hesabin bildirimi hic bitmezdi.

**Y21 `sureli MRR indirimi`** — Customer alanlari + CustomerRegistry seam'i + B2BSalesSystem islevi. Kaynak: 3. adım Y21.

- İmza: B2BSalesSystem.apply_timed_discount(c: Customer, pct: float, weeks: int) -> int : cut = roundi(c.mrr * pct); CustomerRegistry.set_timed_discount(id, cut, day + ticks(weeks)) (icinde set_mrr(mrr - cut)); SalesSystem.reflect_mrr() ; _tick_customer: timed_discount_until >= 0 ve day >= until -> set_timed_discount(id, 0, -1) (set_mrr(mrr + amount)) + reflect_mrr + record_sales_event("discount_ended")
- Sahip: B2B satis; yazici CustomerRegistry · Dosya: scripts/data_models/customer.gd, scripts/autoload/customer_registry.gd, scripts/systems/b2b_sales_system.gd:48, scripts/tabs/sales_tab.gd:565-576 (indirim satiri), localization/strings.csv · Dosya sahibi: ortak
- Durum alanı: Customer.timed_discount_amount: int = 0 (MRR'dan cekilen tutar), Customer.timed_discount_until: int = -1 · varsayılan: 0 / -1 · kayıt: surum artmaz
- Sinyal: set_mrr'nin customer_mrr_changed yayini (customer_registry.gd:131-140) · Bot: yok
- Çip: dogrudan fiil yok; Y22'nin teklif cipi yazar
- Lint: yok
- `--event-vocab`: yok · Smoke: YENI vaka b2b_timed_discount: MRR imzada %X duser, aradaki expand ve retain_discount'a ragmen 52 tik sonra cekilen tutar geri eklenir, kayit yukle (cekirdek: ekonomi, kayit)
- Kullanan: rival.new_firm_warning 2. sik (teklif uzerinden)
- Gerekçe: Karar 8: hesapta bitis tiki, b2b_month_discount degil (o kasadan tek seferlik cikis, effects.gd:635-641). Yuzde degil cekilen TUTAR saklanir: MRR saklı alandir ve expand/apply_discount ona yazar, bitiste yuzde yanlis tutar verirdi (C_satis §3). Bugun hic karta dogrudan fiil gerekmiyor (yalniz teklif); dogrudan fiil kullanan kart gelince eklenir.

**Y22 `prospect_offer (adaya teklif kosulu)`** — fiil + Prospect alanlari + ProspectRegistry seam'i + imzada okuma. Kaynak: 3. adım Y22.

- İmza: prospect_offer {scope: <prospect yuvası>, discount_pct?, discount_weeks?, promise_step?, promise_weeks?} -> ProspectRegistry.set_offer(id, {...}) ; okuma: SalesSystem.add_b2b_customer (sales_system.gd:343) sonunda B2BSalesSystem.apply_offer(c, prospect): discount_pct > 0 -> apply_timed_discount(c, pct, weeks) ; promise_step != '' -> PromiseRegistry.create(c.id, step, promise_weeks || B2BConstants.PROMISE_DEADLINE_WEEKS)
- Sahip: Satis (SalesSystem, ProspectRegistry) · Dosya: scripts/data_models/prospect.gd, scripts/autoload/prospect_registry.gd, scripts/systems/sales_system.gd:343-414, scripts/tabs/sales_tab.gd (aday satirinda teklif), localization/strings.csv, scripts/events/core/effects.gd, scripts/events/present/chips.gd, scripts/events/tools/lint.gd · Dosya sahibi: ortak + OLAYLAR
- Durum alanı: Prospect.offer_discount_pct: float = 0.0, offer_discount_weeks: int = 0, offer_promise_step: String = "", offer_promise_weeks: int = 0 · varsayılan: 0 / "" = teklif yok · kayıt: surum artmaz (prospect.gd:10-17 varsayilan = goc)
- Sinyal: yok (teklifi dinleyen arayüz yok; seçim anındaki çip görünürlüğü taşır) · Bot: yok (bot kart siklarini fiile gore secer; teklifi okuyan bot kolu yok)
- Çip: EFFECT_OFFER_DISCOUNT (cost) TR “Teklif: {prospect} imzalarsa {weeks} hafta MRR {pct}” EN “Offer: if {prospect} signs, MRR {pct} for {weeks} weeks”; EFFECT_OFFER_PROMISE (cost) TR “Teklif: {prospect} imzalarsa söz verilir, {step}” EN “Offer: if {prospect} signs, we promise {step}”
- Lint: ECONOMIC_VERBS, WRITER_VERBS, SUBJECT_VERBS prospect (O4'e prospect turu eklenir), CONSEQUENCE_VERBS
- `--event-vocab`: 1 fiil · Smoke: YENI vaka sales_offer_signing: teklifli aday iki yoldan (sign_deal, SalesRepSystem._close) imzalarsa hesap indirimli ve sozlu acilir; aday duserse teklif gider; kayit yukle (cekirdek: ekonomi, kayit)
- Kullanan: customer.old_browser 1. sik (soz), rival.new_firm_warning 2. sik (52 hafta %X)
- Gerekçe: Karar 15. Okuma noktası add_b2b_customer: iki imza yolu da (SalesFinalizer.sign_deal, SalesRepSystem._close) oradan geçer. Ç29: söz B2BSalesSystem.accept_promise ile değil PromiseRegistry.create ile açılır (accept_promise riskteki hesabı da toparlar, _recover; yeni imzada o bump yok). Ç28: ProspectRegistry'ye yeni sinyal yazılmaz, dinleyen yok. Kapanış zarına teklif terimi yok (#15 ve #21).

**Y23 `drop_prospect`** — fiil. Kaynak: 3. adım Y23.

- İmza: drop_prospect {scope} -> SalesFinalizer.lose(lead_id, account, reason 'event', target, lock_weeks) (sales_finalizer.gd:47); account/target/lock_weeks satışın kendi temsilci kaybındaki değerlerle (dönüş kilidi dahil)
- Sahip: Satis · Dosya: scripts/events/core/effects.gd, scripts/events/present/chips.gd, scripts/events/tools/lint.gd · Dosya sahibi: OLAYLAR
- Durum alanı: yok (ProspectRegistry.remove) · varsayılan: - · kayıt: etkisiz
- Sinyal: prospect_removed (var) · Bot: yok
- Çip: EFFECT_PROSPECT_LOST (danger) TR “Aday düşer: {prospect}” EN “Lead lost: {prospect}”
- Lint: ECONOMIC_VERBS (kayip), WRITER_VERBS, SUBJECT_VERBS prospect
- `--event-vocab`: 1 fiil · Smoke: sales_offer_signing vakasinin dusme kolu
- Kullanan: customer.old_browser 2. sik ve on_expire, rival.new_firm_warning 1. sik check dali
- Gerekçe: revize2 #15 'Aday duser' [VOCAB?]; adayi dusuren fiil yok (C_satis §5). Satisin kendi kayip yolu kullanilir, ikinci bir silme yazilmaz.

**Y24 `aday.sector seam'i, {prospect} adı, seçici rep_lead / lead_rep`** — seam ad alani + sunum duzeltmesi + iki secici. Kaynak: 3. adım Y24.

- İmza: aday.sector (ENTITY STRING, Prospect.industry) ; EvScope._type_for_seam: 'aday' -> TYPE_PROSPECT ; presenter._name_of(TYPE_PROSPECT) -> Prospect.company_name ; prospect 'rep_lead': worked_by'ı bir sales_rep olan adaylar arasından tohumlu ; employee 'lead_rep': bound['prospect'].worked_by (temsilci değilse boş)
- Sahip: Satis (okur); olay kapsami · Dosya: scripts/events/seams/seams_sales.gd, scripts/events/gate/scope.gd:151-158, 211-216, scripts/events/present/presenter.gd:150-166 · Dosya sahibi: OLAYLAR
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: yok
- Lint: _type_for_seam yeni ad alani; Y09
- `--event-vocab`: 4 seam, 2 secici · Smoke: yok (card_body_tokens_resolve {prospect} adini gorsel kabulde)
- Kullanan: customer.old_browser, rival.new_firm_warning
- Gerekçe: Kullanılmayan aday.star / aday.in_deal / aday.by_rep yazılmaz (rep_lead zaten temsilcinin adayını seçer). {prospect} bugün id basar (presenter.gd:150-166'da TYPE_PROSPECT kolu yok).

**Y25 `musteri.sector, musteri.bugs, musteri.onboarding_short, musteri.promise_late, musteri.promise_extended, musteri.has_notice (ENTITY); sales.big_accounts (GLOBAL)`** — seam. Kaynak: 3. adım Y25.

- İmza: musteri.sector -> c.industry ; musteri.bugs -> B2BSalesSystem.account_bugs(c) ; musteri.onboarding_short -> ProductQuality.level("onboarding") < float(c.market_ref.get("onboarding", ProductQuality.expectation("onboarding", ctx))) ; musteri.promise_late -> en eski acik sozun karti (SprintCatalog.card_by_id) sprintte ve SprintSystem.card_late(id) ; musteri.promise_extended -> o sozun extended'i ; musteri.has_notice -> exit_notice_day >= 0 ; sales.big_accounts -> B2B hesaplarda scale >= B2BConstants.CLAUSE_STAR sayisi
- Sahip: Satis / B2B (okur) · Dosya: scripts/events/seams/seams_sales.gd · Dosya sahibi: OLAYLAR
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: yok
- Lint: where/requires yapraklari
- `--event-vocab`: 7 seam · Smoke: yok
- Kullanan: #6 (bugs), #9 (promise_late, promise_extended), #10 (onboarding_short), #11 ve #25 (sector), #23 2. sik kilidi (big_accounts), #25 orta. (has_notice)
- Gerekçe: Hepsi C_satis §7 ve §9'un YOK listesinde; islevler hazir (account_bugs b2b_sales_system.gd:173, ProductQuality.level/expectation, SprintSystem.card_late sprint_system.gd:967). #23'un kilidi icin buyuk hesap esigi sunucu maddesinin esigiyle ayni (b2b_constants.gd:49 CLAUSE_STAR 3), yeni sabit yok.

**Y26 `trust_delta accounts: slots, others, all, onboarding`** — fiil genisletmesi. Kaynak: 3. adım Y26.

- İmza: trust_accounts (effects.gd:717): 'slots' + slots: [ad...] -> o yuvaların hesapları ; 'others' (+ isteğe bağlı line) -> yuva dışındaki bütün B2B hesaplar, line verilmişse SprintCatalog.line_accounts(line) ile süzülür ; 'all' -> bütün B2B ; 'onboarding' -> onboarding_until >= day olan B2B ; çip: others -> EFFECT_TRUST_OTHER_ACCOUNTS (var), all/slots -> EFFECT_TRUST_ACCOUNTS (var), onboarding -> yeni EFFECT_TRUST_NEW_ACCOUNTS
- Sahip: B2B (CustomerRegistry.set_trust_offset) · Dosya: scripts/events/core/effects.gd:717-734, scripts/events/present/chips.gd:53 (TRUST_GROUP_KEYS'e 'new'), scripts/events/tools/lint.gd:352 TRUST_ACCOUNTS · Dosya sahibi: OLAYLAR
- Durum alanı: trust_offset (var) · varsayılan: - · kayıt: etkisiz
- Sinyal: yok (set_trust_offset sinyalsiz, customer_registry.gd:219) · Bot: yok
- Çip: EFFECT_TRUST_NEW_ACCOUNTS (gain|cost) TR “Yeni hesapların memnuniyeti {v}” EN “New accounts' satisfaction {v}”
- Lint: TRUST_ACCOUNTS genisler; 'slots' ise slots listesi bos olamaz ve her ad customer slotu
- `--event-vocab`: parametre notu · Smoke: yok
- Kullanan: product.sprint_test_rival_batch (slots, üç hesap; after_test içinde de), customer.own_data_error 3. şık (others + line), world.data_location 2. şık (others), product.encryption_flaw_b2b ve basın kartı B2B (all), customer.training_request 3. şık (onboarding)
- Gerekçe: Ç12: #11'in 'Stok hattını kullanan öbür hesaplar +4'ü 'others' + line ile (ayrı anahtar yazılmaz). Ç27: #19'un üç hesabı var olan line_top seçicisinin üç yuvasıdır ('slots'); 'top3' seçicisi yazılmaz.

**Y27 `take_account`** — fiil. Kaynak: 3. adım Y27.

- İmza: take_account {scope: <customer slotu>} -> CustomerRegistry.assign_customer(id, "", true) (kurucunun masasi, sabitli)
- Sahip: Musteri iliskileri (CustomerRegistry) · Dosya: scripts/events/core/effects.gd, scripts/events/present/chips.gd, scripts/events/tools/lint.gd · Dosya sahibi: OLAYLAR
- Durum alanı: Customer.assigned_to, cs_pinned (var) · varsayılan: - · kayıt: etkisiz
- Sinyal: customer_assigned (var, customer_registry.gd:307-321) · Bot: yok
- Çip: EFFECT_ACCOUNT_TO_FOUNDER (cost) TR “Hesap sende: {company}” EN “Account now yours: {company}”
- Lint: NEUTRAL_VERBS, WRITER_VERBS, SUBJECT_VERBS customer
- `--event-vocab`: 1 fiil · Smoke: yok
- Kullanan: team.rude_client 1. sik
- Gerekçe: 'Aramalari sana gecer': hesabin sahibi kurucu olur (C_satis §7: assigned_to "" = kurucunun masasi). cs_pinned olmazsa CustomerRepSystem._delegate_excess hesabi geri dagitabilir (customer_rep_system.gd:152-180).

**Y28 `promise_extend / promise_break scope'lu`** — fiil genisletmesi. Kaynak: 3. adım Y28.

- İmza: promise_extend {scope: <customer slotu>} -> PromiseRegistry.extend(o hesabin en eski acik sozu) ; promise_break {scope} -> PromiseRegistry.break_promise(o hesabin acik sozleri) ; scope'suz hali bugunku gibi SprintSystem.event_promises()
- Sahip: Soz (PromiseRegistry, B2BSalesSystem.on_promise_resolved) · Dosya: scripts/events/core/effects.gd:455-470, break_plan :739-744, scripts/events/present/chips.gd (_break_parts 320-328 ayni plani okur), scripts/events/tools/lint.gd:371-376, 514-515 (V2) · Dosya sahibi: OLAYLAR
- Durum alanı: Promise.extended (var) · varsayılan: - · kayıt: etkisiz
- Sinyal: promise_broken (var) · Bot: yok
- Çip: EFFECT_PROMISE_MOVED (var), _break_parts (var)
- Lint: V2: scope'lu kullanim SYSTEM disi kartta yasal (fiil SYSTEM_VERBS'te kalir, kural scope'a bakar); requires musteri.promise_extended == false
- `--event-vocab`: parametre notu · Smoke: yok (PromiseRegistry'nin mevcut vakalari)
- Kullanan: team.promise_made 2. ve 3. sik
- Gerekçe: Ayni isi yapan ikinci fiil yazilmaz (CLAUDE.md §8); bugunku iki fiil yalniz soz olayinin sozlerine iner (gorev 'Hazir sanilan' tablosu; effects.gd:455-470). Karar 13: soz kurucunun masasindan gelir, sozu uzatmak ya da birakmak da kurucunun kararidir.

**Y29 `pitch_focus (karar 5'in yazar fiili)`** — fiil + satis seam'i + gorusme terimi. Kaynak: 3. adım Y29.

- İmza: pitch_focus {area, weeks} -> SalesMeetingSystem.set_pitch_focus(area, day + TimeModel.ticks(weeks)): GameState.set_flag('sales_pitch_focus', {area, until}) (FLAG_TYPES'e TYPE_DICTIONARY) ; _build_base_contributions (sales_meeting_system.gd:137): odak sürüyor ve ProductQuality.level(area) >= ProductQuality.expectation(area, <adayın bağlamı>) ise {seam: 'sales.pitch_focus', delta: SalesConstants.PITCH_FOCUS_DELTA 0.05 [WORKING]} ; sales_meeting_adapter.gd CHIP_BY_SEAM'e satır ; CSV SALES_MOD_PITCH_FOCUS
- Sahip: Satis gorusmesi (SalesMeetingSystem) · Dosya: scripts/systems/sales_meeting_system.gd:137-206, scripts/systems/sales_constants.gd, scripts/autoload/game_state.gd FLAG_TYPES, scripts/ui/meeting/sales_meeting_adapter.gd:28 (CHIP_BY_SEAM), scripts/events/seams/seams_sales.gd, scripts/events/core/effects.gd, scripts/events/present/chips.gd, localization/strings.csv · Dosya sahibi: ortak + OLAYLAR
- Durum alanı: GameState.flags.sales_pitch_focus · varsayılan: {} = odak yok · kayıt: surum artmaz (flags sozlugu)
- Sinyal: yok (gorusme acilinca okunur) · Bot: yok
- Çip: EFFECT_PITCH_FOCUS (gain) TR “{n} hafta satış görüşmelerinde öne çıkan: {area}” EN “Sales meetings lean on {area} for {n} weeks”
- Lint: NEUTRAL_VERBS, WRITER_VERBS; area ProductQuality alanlarindan biri
- `--event-vocab`: 1 fiil, 1 seam · Smoke: yok (gorusme igne terimi; gorsel kabulde --meeting-shot ile modifier satiri)
- Kullanan: world.quarterly_bulletin
- Gerekçe: Karar 5: set_timed_flag WRITER_VERBS'e alınmaz (EvFlags'ı okuyan sistem yok; satışı motorun iç durumuna bağlamak WRITE-THROUGH'un tersi). Ç20: terim ürünün o alanı adayın beklentisini karşılıyorsa iner (2. adım); 3. adımın 'sektör vurgusu' şartı yok.

**Y30 `time.quarter_start`** — seam (GLOBAL BOOL). Kaynak: 3. adım Y30.

- İmza: var d := GameState.get_date_dict(); return d.month in [1, 4, 7, 10] and d.day <= 7
- Sahip: Zaman · Dosya: scripts/events/seams/seams_world.gd:49 (_install_time) · Dosya sahibi: OLAYLAR
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: yok
- Lint: yok
- `--event-vocab`: 1 seam · Smoke: yok
- Kullanan: world.quarterly_bulletin
- Gerekçe: 'Her ceyregin ilk haftasi' bugun ifade edilemez (E_dunya §3.1: tikler 1, 14, 27, 41, 54 ...).

**Kabul ölçütü (kapı içinde, kendi APPDATA'sıyla, headless):**

- --event-lint, loc_residue, loc_csv_integrity
- YENİ smoke b2b_exit_notice, b2b_timed_discount, sales_offer_signing (iki imza yolu: sign_deal ve SalesRepSystem._close; aday düşerse teklif gider; kayıt yükle)
- Var olan smoke: b2b_promise_broken_on_deadline, b2b_promise_kept_on_ship, promise_extend_once, promise_break_chain, sales_rep_close_chance, b2b_pitch_meeting_signs, sales_meeting_replays_identically, event_trust_delta_lasting, save_roundtrip_fingerprint, event_chip_coverage
- Probe: --run-log=full_run:104:sim:1 ^PROBE bayt-eş; isteğe bağlı PROBE END notice_ended= alanı eklenirse yalnız o alan farklı
- Görsel kabul 7. adımda: --meeting-shot=probe ile 'Bu çeyreğin vurgusu' satırı (fikstürde odak açık)

### 4.4 altyapı (`Olaylar 4: …  (Y36 ayrı küçük commit: Olaylar 4b, Temizlik B3'ten sonra)`)

**Y31 `sunucu fiyat carpani ve kilit (ProductState bayraklari)`** — ProductState alanlari + yazicilar. Kaynak: 3. adım Y31.

- İmza: ProductState.INFRA_PRICE_MULT := "mvp_infra_price_mult" (float, 1.0), INFRA_TIER_MULT := "mvp_infra_tier_mult" (Dictionary {tier: carpan}, {}), INFRA_LOCK_UNTIL := "mvp_infra_lock_until" (int, -1), INFRA_LOCK_UNITS := "mvp_infra_lock_units" (int, 0) ; set_infra_price(mult, tiers) / set_infra_lock(until, units) -> EventBus.infra_changed
- Sahip: Urun durumu (ProductState) / Altyapi · Dosya: scripts/systems/product_state.gd:11-36, 280-333, scripts/autoload/game_state.gd:48-85 FLAG_TYPES (altyapi satirlari :77-82) · Dosya sahibi: ortak
- Durum alanı: GameState.flags (mvp_infra_*) · varsayılan: 1.0 / {} / -1 / 0 · kayıt: surum artmaz: okuyucu get_flag(KEY, varsayilan) (D_urun §7.2)
- Sinyal: EventBus.infra_changed (var, event_bus.gd:144; tek kaynagi ProductState infra yazicilari) · Bot: yok
- Çip: yok (Y33, Y34)
- Lint: yok
- `--event-vocab`: yok · Smoke: Y32'nin vakasi
- Kullanan: #23, #24
- Gerekçe: Karar 1: carpan ve kilit ProductState bayraginda, kayit surumu artmaz. #24 yalniz Standart ve Kurumsal'i ucuzlattigi icin kademe basina carpan ayrica gerekir.

**Y32 `InfraSystem: unit_price carpani, set_provider/set_capacity kilidi, lock_reason()`** — sistem islevleri. Kaynak: 3. adım Y32.

- İmza: unit_price(provider_id, market) (infra_system.gd:94-100) taban * ProductState.infra_price_mult() * tier_mult.get(provider_id, 1.0) ; static func lock_reason() -> String : kilit suruyorsa "PRODUCT_SERVER_LOCK_REASON" anahtari, yoksa "" (static icinde tr() yok; cagiran cevirir) ; static func lock_weeks_left() -> int ; set_provider (:170) basinda lock_reason() != "" ise false (Kurumsal dahil) ; set_capacity (:184) kilit surerken maxi(new_units, lock_units) ; static func scale_price(mult: float, tiers := []) ; static func lock(weeks: int)
- Sahip: Altyapi (InfraSystem) · Dosya: scripts/systems/infra_system.gd:94-100, 170-197, localization/strings.csv · Dosya sahibi: ortak
- Durum alanı: Y31 · varsayılan: - · kayıt: -
- Sinyal: infra_changed · Bot: Y35
- Çip: yok
- Lint: yok
- `--event-vocab`: yok · Smoke: YENI vaka infra_price_lock: carpan monthly_bill'e iner (B2B ve B2C), kilitte set_provider(Kurumsal dahil) false, kapasite tabanin altina inmez, Otomatik ayar buyutebilir, kilit bitince serbest, kayit yukle (cekirdek: ekonomi, kayit)
- Kullanan: #23, #24
- Gerekçe: Karar 1 is bolumu: kilidi motorda bu gorev yazar; set_provider ve kapasite azaltma tabanin altini reddeder; lock_reason() public ve yeni CSV anahtari bu gorevden. unit_price tek carpma noktasi (monthly_bill, daily_bill, product_model ipuclari, mail_pane, run_probe, sales_meeting_adapter oradan okur; D_urun §7.1). MVP anindaki set_provider (sprint_bridges.gd:125) kilitten once olur: kilit yalniz canli urunde imzalanir.

**Y33 `server_price`** — fiil. Kaynak: 3. adım Y33.

- İmza: server_price {mult, tiers?: ["cloud", "enterprise"]} -> InfraSystem.scale_price(mult, tiers) ; plan: EvEffects.server_price_plan(e) -> {before: monthly_bill(), after}
- Sahip: Altyapi · Dosya: scripts/events/core/effects.gd, scripts/events/present/chips.gd, scripts/events/tools/lint.gd · Dosya sahibi: OLAYLAR
- Durum alanı: Y31 · varsayılan: - · kayıt: -
- Sinyal: infra_changed · Bot: yok
- Çip: EFFECT_SERVER_PRICE (cost|gain) TR “Sunucu fiyatı {pct}, ayda {v}” EN “Server price {pct}, {v} a month”; EFFECT_SERVER_PRICE_TIERS (gain|cost) TR “Standart ve Kurumsal sunucu {pct}” EN “Standard and Enterprise servers {pct}”
- Lint: ECONOMIC_VERBS (fatura parası); _is_negative: server_price için mult > 1.0 bedeldir; WRITER_VERBS; mult > 0; tiers InfraSystem.PROVIDER_IDS içinde
- `--event-vocab`: 1 fiil · Smoke: infra_price_lock
- Kullanan: world.server_price_hike (1,15 / 0,90 / 1,07; on_expire 1,15), world.cloud_price_cut (0,70 Standart ve Kurumsal; on_expire boş, Ç18)
- Gerekçe: Karar 1 ve #24. Ç18: 3. adım NEUTRAL önermişti (duyuru düşse de fiyat insin diye); fiyat çarpanı aylık gideri oynatır, NEUTRAL saymak I2'yi dolanmak olurdu. #23'ün on_expire'ı (×1,15) bedeldir, geçer; #24'ün on_expire'ı boştur.

**Y34 `server_lock`** — fiil. Kaynak: 3. adım Y34.

- İmza: server_lock {weeks} -> InfraSystem.lock(weeks) : ProductState.set_infra_lock(day + ticks(weeks), InfraSystem.units())
- Sahip: Altyapi · Dosya: scripts/events/core/effects.gd, scripts/events/present/chips.gd, scripts/events/tools/lint.gd · Dosya sahibi: OLAYLAR
- Durum alanı: Y31 · varsayılan: - · kayıt: -
- Sinyal: infra_changed · Bot: yok
- Çip: EFFECT_SERVER_LOCK (cost) TR “Sunucu sözleşmesi {n} hafta: kademe sabit, kapasite en az {units} birim” EN “Server contract for {n} weeks: tier fixed, capacity at least {units} units”
- Lint: NEUTRAL_VERBS, WRITER_VERBS, CONSEQUENCE_VERBS
- `--event-vocab`: 1 fiil · Smoke: infra_price_lock
- Kullanan: world.server_price_hike 3. sik
- Gerekçe: Karar 1: yillik sozlesme x1,07 ve 52 hafta kilit; iki ayri fiil (fiyat, kilit) cunku #24 kilitsiz fiyat ister.

**Y35 `run_probe: kilitliyken Kurumsal denemesi yok`** — bot. Kaynak: 3. adım Y35.

- İmza: _answer_the_clause (run_probe.gd:1640-1650) basinda: if InfraSystem.lock_reason() != "": return
- Sahip: Arac · Dosya: scripts/debug/run_probe.gd:1640-1650 · Dosya sahibi: ortak
- Durum alanı: yok · varsayılan: - · kayıt: -
- Sinyal: yok · Bot: kendisi; PROBE DECISION tier satiri kilitte basilmaz
- Çip: yok
- Lint: yok
- `--event-vocab`: yok · Smoke: yok
- Gerekçe: Karar 1: run_probe botu kilitliyken Kurumsal'a gecmeyi denemez. set_provider false doner ama bot _decide("tier") satirini yine basardi.

**Y36 `mail_pane sunucu maddesi dugmesi kilidi`** — UI kucuk hunk. Kaynak: 3. adım Y36.

- İmza: mail_pane.gd:159-161 _actions(note, buttons, blocked) : blocked = InfraSystem.lock_reason() != "", note = tr(lock_reason()).format({weeks: InfraSystem.lock_weeks_left()})
- Sahip: Olaylar gelen kutusu (UI) · Dosya: scripts/tabs/events/mail_pane.gd:152-161, 800-812 · Dosya sahibi: ortak; Temizlik B3 bu dosyaya dokunuyor
- Durum alanı: yok · varsayılan: - · kayıt: -
- Sinyal: yok · Bot: yok
- Çip: yok
- Lint: yok
- `--event-vocab`: yok · Smoke: yok (gorsel kabul)
- Gerekçe: Karar 1: kilidi bu gorev ekler, Temizlik'e haber vererek.

**Kabul ölçütü (kapı içinde, kendi APPDATA'sıyla, headless):**

- --event-lint, loc_residue, loc_csv_integrity
- YENİ smoke infra_price_lock (çarpan monthly_bill'e iner B2B ve B2C; kilitte set_provider Kurumsal dahil false; kapasite tabanın altına inmez; Otomatik ayar büyütebilir; kilit bitince serbest; kayıt yükle)
- Var olan smoke: infra_capacity_moves_both_ways, infra_local_provider_tradeoff, save_roundtrip_fingerprint, event_chip_coverage
- Probe: --run-log=full_run_server_auto:104:sim:1 ve full_run ^PROBE SERVER satırları bayt-eş (çarpan 1,0, kilit yok)
- Y36: görsel kabul --inbox-shot ile kilitli düğme ve gerekçe ipucu (7. adım), Temizlik'e 'bitti <sha>'

### 4.5 sprint ve kâğıt (`Olaylar 5: …`)

**Y37 `assign_to (kol) + SprintSystem.pin_card`** — fiil + yeni public SprintSystem islevi + _assign istegi. Kaynak: 3. adım Y37.

- İmza: assign_to {card: "decision" | "promise", scope: <employee slotu>, weeks | weeks_seam} -> SprintSystem.pin_card(card_id: String, person_id: String, until_day: int) -> String (yeni public; c["pinned"] = {person, until} yazar, kosan sprintte _staff_week(false) cagirir; doner kart id ya da "") ; "promise" kart cozumu: scope'taki musteri slotunun en eski acik sozunun karti (SprintCatalog.card_by_id("feat:" + feature_id)) ; _assign (URUN_ARAYUZU yazar): day < until iken pinned kisi yalniz o karta verilir, baska karta verilmez; pinned kisi ekipte yoksa (izin, hastalik) kart kimsesiz bekler
- Sahip: Sprint (SprintSystem) · Dosya: scripts/systems/sprint_system.gd (yeni public pin_card; _assign govdesi URUN_ARAYUZU'nun), scripts/events/core/effects.gd (kol; NEUTRAL_VERBS'te zaten, effects.gd:40), scripts/events/present/chips.gd, scripts/events/tools/lint.gd · Dosya sahibi: URUN_ARAYUZU (sprint_system.gd: yalniz yeni public islev OLAYLAR'dan, _assign degisikligi onlardan) + OLAYLAR
- Durum alanı: kart sozlugu c.pinned = {person, until} (GameState.product.cards[id]) · varsayılan: c.get("pinned", {}) · kayıt: surum artmaz (kart sozlugu; D_urun §7.2 c.get deseni)
- Sinyal: yok yeni; atama yeniden yapilir · Bot: yok
- Çip: EFFECT_PIN (cost) TR “{name} {n} hafta yalnız bu kartta: {card}” EN “{name} works only on {card} for {n} weeks”
- Lint: WRITER_VERBS, SUBJECT_VERBS employee, weeks ya da weeks_seam (GLOBAL INT) zorunlu; V3'e girmez (sprint_card_* degil)
- `--event-vocab`: 1 fiil (kolsuzdan yazilira) · Smoke: URUN_ARAYUZU'nun _assign degisikligi kendi sprint smoke'unu tasir; olay tarafinda event_chip_coverage
- Kullanan: team.promise_made 1. şık (card promise, weeks_seam urun.weeks_to_month_end), product.sprint_pm_hospital 2. şık (card decision, taker, 2 hafta)
- Gerekçe: Karar 15 ve 11. Kartta kilit alani bugun yok (D_urun §2.1); _assign her cagrida atamayi sifirlar (sprint_system.gd:1259-1287). ORTAK_CALISMA §2: OLAYLAR yalniz yeni public islev ekler.

**Y38 `queue_card + SprintBridges.open_request`** — fiil + yeni public SprintBridges islevi. Kaynak: 3. adım Y38.

- İmza: queue_card {area? | line?, scope?: <customer slotu>} : scope yoksa kart = SprintCatalog.candidates(area) icinden (ya da line'in) ilk tasinabilir 'feat:' karti -> SprintSystem.send_next(card_id) (sprint_system.gd:103, var) ; scope varsa SprintBridges.open_request(customer_id, line) -> String (yeni public; tick_requests'in kayit bicimiyle, hesap basina tek acik talep kurali) -> send_next("req:" + id) ; plan: secilecek kartin adi
- Sahip: Sprint (send_next) ve SprintBridges (talep kaydi) · Dosya: scripts/systems/sprint_bridges.gd:22-56 (yeni public islev yanina), scripts/events/core/effects.gd, scripts/events/present/chips.gd, scripts/events/tools/lint.gd · Dosya sahibi: ortak (sprint_bridges.gd URUN_ARAYUZU listesinde degil) + OLAYLAR; send_next yalniz cagrilir
- Durum alanı: GameState.product.requests (var) ve next.cards (var) · varsayılan: - · kayıt: etkisiz
- Sinyal: yok yeni · Bot: yok
- Çip: EFFECT_QUEUE_CARD (cost) TR “Sonraki sprinte kart: {card}” EN “Next sprint gets a card: {card}”
- Lint: NEUTRAL_VERBS, WRITER_VERBS, CONSEQUENCE_VERBS; area ya da line ver; requires ile tasinabilir kart bulunmali (plan bos donerse refused)
- `--event-vocab`: 1 fiil · Smoke: yok (send_next ve talep akisi var olan yollar; event_chip_coverage)
- Kullanan: customer.training_request 4. sik (area onboarding: line_hidden_self_serve acilmissa 'Sık Sorulanlar', degilse Mobil ve Erisim k1), customer.finance_team 1. sik (scope customer, line line_shared_integrations)
- Gerekçe: 'Sonraki sprinte kart koymak' icin olay fiili yok; send_next public ama sarilmamis, disaridan talep ekleme yolu yok (D_urun §4). Talep kartina dusmek tesekkur notunu da hazir getirir (SB.thank).

**Y39 `after_test (kartin testi bitince etkiler)`** — fiil + olay motoru izleyicisi. Kaynak: 3. adım Y39.

- İmza: after_test {card: "decision", min_bugs: 1, effects: [...]} -> EvWatch.add(card_id, min_bugs, effects, ctx, event_id) ; EvWatch EventBus.card_phase_changed(card_id, phase)'e baglanir (event_bus.gd:162; tek yayici sprint_system.gd:1229-1231): kart SprintCatalog.card_by_id(id).tested olunca found >= min_bugs ise effects run_check_branch kokeniyle ve kartin ctx'iyle calisir, EvHistory'ye '<outcome>_tested' satiri yazilir; her durumda izleme silinir
- Sahip: Olay motoru (okur: SprintBugs alanlari c.tested, c.found) · Dosya: scripts/events/core/watch.gd (yeni EvWatch), scripts/events/core/save.gd:25 (kayit blogu), scripts/events/core/effects.gd, scripts/events/present/chips.gd, scripts/events/tools/lint.gd · Dosya sahibi: OLAYLAR
- Durum alanı: EvWatch._entries [{card_id, min_bugs, effects, context, event_id}] · varsayılan: [] · kayıt: olay motoru blogu (EvSchedule gibi to_dict/from_dict); SaveManager surumu artmaz
- Sinyal: dinler: EventBus.card_phase_changed (var); BINDINGS'e girmez (kart tetigi degil), manifest degismez · Bot: yok
- Çip: EFFECT_AFTER_TEST (danger (ardindan ic ciplerin kendisi)) TR “Kartın testi hata bulursa:” EN “If the card's test finds bugs:”
- Lint: NEUTRAL_VERBS, WRITER_VERBS, CONSEQUENCE_VERBS; ic effects TERMINAL ve ECONOMIC olmayan fiiller (I2); yalniz tick: request kartinda (karar karti) ; Y05 ic listeyi tarar
- `--event-vocab`: 1 fiil · Smoke: YENI vaka event_after_test: hata bulunursa ic etki iner ve gecmise yazilir, bulunmazsa duser, kayit yukle arada (cekirdek: olay motoru, kayit)
- Kullanan: product.sprint_test_rival_batch 1. sik
- Gerekçe: Karar 7. EventBus.card_phase_changed VAR (event_bus.gd:162) ama olay motoru dinlemiyor (signals.gd:22-42 BINDINGS'te yok) ve kart bir kapsam yuvasi olamaz (D_urun Ek 4). Takip kartı yerine ic etki secildi: oyuncu bedeli karar anında 'Kartın testi hata bulursa:' cipinde okur (EFFECT-VISIBILITY), revize2'de bu ana ait metin yok. Test bitince hata varsa SprintBugs duzeltmeyi Gelistirme'ye ekler ve faz 2'den 1'e doner, yoksa 3'e gecer (sprint_bugs.gd:81-104); iki durumda da faz degisir ve sinyal atilir. Bilinen sinir: decision_progress karti haftasiz bitirirse sinyal atilmaz (sprint_system.gd:1232 yorumu); bu kartin sikki test fazini yalnız yarilar (cut_test), bitirmez.

**Y40 `seçici decision_dev, quarter_pm`** — kapsam secicileri. Kaynak: 3. adım Y40.

- İmza: employee 'decision_dev': SprintSystem.decision_card().assignees içinde role developer olan ilk kişi ; employee 'quarter_pm': SprintCatalog.quarter_pm()
- Sahip: Olay motoru (okur: SprintSystem, SprintCatalog public okumalari) · Dosya: scripts/events/gate/scope.gd · Dosya sahibi: OLAYLAR
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: yok
- Lint: Y09
- `--event-vocab`: 3 secici · Smoke: yok
- Kullanan: product.sprint_pm_hospital (decision_dev), team.promise_made (quarter_pm)
- Gerekçe: sprint_dev koşan sprintin ilk geliştiricisidir, kartın değil (scope.gd:243-250). Ç27: decision_line_top yazılmaz, var olan line_top yeter.

**Y41 `urun.line_tier.<hat> (GLOBAL INT, dinamik)`** — seam. Kaynak: 3. adım Y41.

- İmza: urun.line_tier.<line_id> -> ProductState.line_tier(line_id) (build.module_unlocked.<id> gibi dinamik kayıt); yalnız koşulda kullanılır
- Sahip: Urun (okur) · Dosya: scripts/events/seams/seams_product.gd · Dosya sahibi: OLAYLAR
- Durum alanı: yok · varsayılan: - · kayıt: etkisiz
- Sinyal: yok · Bot: yok
- Çip: yok
- Lint: yok
- `--event-vocab`: 1 + hat sayisi kadar seam · Smoke: yok
- Kullanan: customer.own_data_error (urun.line_tier.line_erp_stock >= 1), customer.finance_team (urun.line_tier.line_shared_integrations == 0)
- Gerekçe: Hat başına kademe seam'i yok. urun.decision_step_name yazılmaz: #19'un metni var olan urun.decision_card'ı okur ('name of the card a sprint decision waits on').

**Kabul ölçütü (kapı içinde, kendi APPDATA'sıyla, headless):**

- --event-lint, loc_residue, loc_csv_integrity
- YENİ smoke event_after_test (hata bulunursa iç etki iner ve geçmişe yazılır, bulunmazsa düşer, arada kayıt yükle)
- Var olan smoke: sprint_decision_blocks_progress, sprint_decision_card_fires_shipped, sprint_save_roundtrip, sprint_skill_assignment, sprint_carry_keeps_progress, event_chip_coverage
- --sprint-probe=hours=40:cards=2:ticks=8:team=6 SUMMARY uyuşmazlık 0 (pin yokken plan ve kapanış aynı)
- Probe: --run-log=full_run:104:sim:1 ^PROBE bayt-eş

### 4.6 Lint listeleri (toplu)

- **WRITER_VERBS** (`lint.gd`): `account_notice`, `prospect_offer`, `drop_prospect`, `server_price`, `server_lock`, `sick_leave`, `summer_leave`, `promote`, `assign_to`, `queue_card`, `after_test`, `take_account`, `pitch_focus`. `set_timed_flag` girmez (karar 5).
- **SYSTEM_VERBS** değişmez; `promise_extend` / `promise_break` `scope`'lu kullanımda V2'den muaf (Y28).
- **NEUTRAL_VERBS** (`effects.gd`): `server_lock`, `sick_leave`, `summer_leave`, `queue_card`, `after_test`, `take_account`, `pitch_focus` (`assign_to` zaten orada). **ECONOMIC_VERBS:** `account_notice`, `prospect_offer`, `drop_prospect`, `promote`, `server_price` (Ç18; `_is_negative`: mult > 1 bedel).
- **CONSEQUENCE_VERBS:** `summer_leave`, `queue_card`, `server_lock`, `after_test`, `prospect_offer`. **SUBJECT_VERBS:** employee `sick_leave`, `summer_leave`, `promote`, `assign_to`; customer `account_notice`, `take_account`; prospect (yeni tür) `prospect_offer`, `drop_prospect`.
- **SILENT_VERBS**'ten `schedule_event` çıkar (Y11). **TRUST_ACCOUNTS:** + `slots`, `others` (+ `line`), `all`, `onboarding`.
- **Yeni kurallar:** seçici adı doğrulaması (Y09), sabit oranda `modifier_lines` muafiyeti ve dal / sonra-etkisi taraması (Y05), yuva `subject: false` (L01), `year_roll` yaprağı (Y06), `amount_slot` tür denetimi (Y10).
- **Baseline:** yalnız iki O2 (dünya duyuruları `world.cloud_price_cut`, `world.quarterly_bulletin`; görevin 'Kart şeması'), gerekçesiyle `--event-lint=baseline` ile. EventBus'a yeni sinyal yok: `EVENT_SIGNAL_MANIFEST.md` değişmez.

### 4.7 Kâğıt havuzu

`decision.cards` 44 → 47 (`sprint_chance` 0,5 ve `seen_weight` 2 değişmez). Kâğıt sprintlerin yarısında istenir; havuz ağırlıklı sırayla denenir, her kâğıdın eşit payı 1/44'ten 1/47'ye düşer (yaklaşık −%6). Gerçek sıklık her kâğıdın koşuluna bağlıdır; 6. adım `--sprint-probe` `PAPERSUM` ve makullük defterinden okur ve rapora yazar.

## 5. Başka oturumlara istekler

**I01 → URUN_ARAYUZU** (4. adım başlarken; 5. commit grubundan önce commit'lenmeli)

> OLAYLAR: karar 11 ve 15 için bir istek. SprintSystem._assign (sprint_system.gd, haftanın ataması) karttaki c.pinned = {person, until} alanını okusun: GameState.day < until iken o kişi yalnız o karta atanır, başka karta atanmaz; kişi ekipte değilse (izin, hastalık) kart kimsesiz bekler; süre geçince alan yok sayılır. Alanı OLAYLAR'ın ekleyeceği yeni public SprintSystem.pin_card(card_id, person_id, until_day) -> String yazar; var olan gövdeye dokunmam, pin_card koşan sprintte atamayı yenilemek için _staff_week(false) çağırır (istemezsen söyle). Kayıt sürümü artmaz: c.get("pinned", {}). Kullanan şıklar: team.promise_made 'yalnız buna baksın' (sözlü kart, ay sonuna dek) ve product.sprint_pm_hospital 'başkası devralsın' (2 hafta). Commit'leyince sha'yı yazar mısın?

**I02 → URUN_ARAYUZU** (5. adımda kâğıtlar yazılmadan önce (karar 11'in 'haber verilir'i))

> OLAYLAR: data/product/sprint.json decision.cards havuzuna üç kâğıt ekleyeceğim: product.sprint_dev_code_review (developer, dev), product.sprint_test_rival_batch (tester ya da developer, test), product.sprint_pm_hospital (product_manager, any). Havuz 44 → 47; sprint_chance ve seen_weight değişmez. Bilgi: _speaker'ın PM kuralı (PM kâğıdı yalnız kind == request) rakip kartını PM ağzından imkânsız kılıyordu, konuşanı test aşamasındakine çevirdim; kural değişmesin. Ekleme kartların commit'inde, kapı bendeyken birleşik ağaçta olur; sprint.json'da açık hunk'ın varsa söyle.

**I03 → URUN_ARAYUZU** (4. commit grubu (altyapı) commit'lenince, tek mesaj (karar 1'in iş bölümü))

> OLAYLAR: sunucu sözleşmesi kilidi <sha> ile main'de. Public okuma: InfraSystem.lock_reason() -> String (kilit sürerken 'PRODUCT_SERVER_LOCK_REASON' anahtarı, yoksa "") ve InfraSystem.lock_weeks_left() -> int. İstek: product_model.gd'deki sunucu kademe düğmeleri ve Azalt (kapasite tabandayken) kilitliyken devre dışı, ipucu tr(InfraSystem.lock_reason()).format({"weeks": InfraSystem.lock_weeks_left()}); sıradaki U commit'inde. Fiyat ipuçları unit_price'tan okuduğu için çarpan kendiliğinden gelir. Kilitliyken set_provider false, set_capacity tabanın altına inmez: düğme yalnız görünümdür.

**I04 → TEMIZLIK** (1. grubun commit'inden önce bilgi; Y36 B3'ün sha'sı gelince)

> OLAYLAR: mail_pane.gd'ye üç küçük ayrı hunk gelecek. (1) Seçenek çiplerinde ve geçmiş satırında check dalları (1. grup, ortak dosya kuralıyla commit anında birleşir). (2) Fesih bildirimi mesaj türü, gerekirse (3. grup). (3) Karar 1: sunucu maddesi düğmesine sözleşme kilidi — blocked = InfraSystem.lock_reason() != "" ve gerekçe ipucu; bunu B3 commit'inden SONRA yazacağım. B3'ü commit'leyince sha'yı yazar mısın? mail_pane.gd'de silme adayın varsa bu üç yeri ayır.

**I05 → TEMIZLIK ve URUN_ARAYUZU (bilgi)** (her grubun kapısında)

> OLAYLAR: ortak dosyalara küçük hunk'lar gelecek, kayıt sürümü artmıyor (yeni alanlar varsayılanlı @export): customer.gd, prospect.gd, character.gd, customer_registry.gd, prospect_registry.gd, character_registry.gd, b2b_sales_system.gd, b2b_constants.gd, sales_system.gd, sales_meeting_system.gd, sales_constants.gd, sales_meeting_adapter.gd, infra_system.gd, product_state.gd, game_state.gd (FLAG_TYPES), hr_morale_system.gd, finance_system.gd, sprint_bridges.gd, sales_tab.gd, inbox.gd, mail_pane.gd, run_probe.gd, strings.csv (yeni anahtarlar kendi aile bloklarında; EV_ dışında dosya sonuna ekleme yok), GDDs/ motor md §27 notları. sprint_system.gd'ye yalnız yeni public pin_card. Bu dosyalarda silme adayınız varsa söyleyin.

**I06 → yardımcı yönetmen (co-director)** (4. adım başlamadan; itiraz yoksa plan bu seçimlerle yürür, kurgu değişiklikleri 8. adım sayfasında Erdem'e gider)

> OLAYLAR planı, kurgu seçimleri (itiraz penceresi): (a) #12 'dışa aktarma' kademesi yok → Entegrasyonlar k1 (Tekil Bağlantı); (b) #15 'eski tarayıcı' kademesi yok → Mobil ve Erişim k1 (Duyarlı Arayüz), söz bir sprint; (c) #19 konuşan PM değil testi yapan kişi, kart her özellik kartında gelebilir, metin kartın adını okur (TR/EN onay bekliyor); (d) #10, #12, #15, #18'in temsilcisiz yedekleri park; (e) #30'da marka ve kitle eşiği tamamen kalkar ('düşer' azalır demekse finance.brand >= 5 eklerim); (f) check: riskli sonuç on_pass dalında, çip her dalı kendi oranıyla çizer (görev metninin 'on_fail'i değil; görünüm aynı); (g) karar 4f: 'ikisi de gitsin' şıkkı summer_leave together ile bu yılın izin haftasını sabitler ve 'aynı iki hafta' çipini bedel olarak çizer; gönderen çiftin önce izne çıkanı; (h) #24 okunmazsa indirim inmez (I2), kart 4 hafta bekler; (i) yıl zarı varyant başına, aile freni (52 hafta) yılda bire indirir.

## 6. Park

- **P01 Temsilcisiz yedek varyantlar: #10, #12, #15 (kurucu konuşur, bedel kurucunun verimi), #18 rival.outage_solo.** Etiketteki ad ve bedelin öznesi değişir; aynı metin bloğuyla ikinci dosya ister, by_seam yalnız GLOBAL seam okur (presenter.gd), efektler seam'e göre dallanmaz. hr.role_count.<rol> seam'i yalnız bunlara lazımdı, o da yazılmaz. Kartlar temsilci yokken gelmez.
- **P02 raise_salary fiili (HRActions.apply_raise).** Karar 15 'bağlanır' der ama kullanan kart yok: #5'in zammı terfinin içindedir (apply_promotion maaşı pct ile artırır); ikisi birden zammı iki kez indirir. Kullanıcısız fiil CLAUDE.md §8'e aykırı.
- **P03 Aday satırında teklif gösterimi (sales_tab) ve ProspectRegistry.prospect_updated sinyali.** Teklif seçim anının çipinde okunur; sonradan aday satırında görünmesi istenirse sinyal ve satır birlikte yazılır.
- **P04 Yazılmayan kod kalemleri.** check dizisi ve olay.stumble_odds (Ç02), decision_line_top / top3 (Ç27), urun.decision_step_name (urun.decision_card var), hr.role_count (P01), aday.star / aday.in_deal / aday.by_rep (kullanan yok), FIN 'bonus' etiketi (Ç07), set_timed_flag'in WRITER_VERBS'e alınması (karar 5).
- **P05 Karar 9'un 'yoksa park' dalı.** Bağlanacak 27 kayıttan hiçbiri parka gitmez: #25 ve #31 tarih penceresiyle, #18 ve #19 rakip yuvasıyla, #12 ve #15 en yakın kademeyle kuruldu (tablo PLAN.md 'Karar 9'). Park listesi görevin 6 kartıdır (#22, #27, #28, P1–P3).

## 7. Karar 9: oyunda karşılığı olmayan koşullar

| Kart | Koşul | Seçilen | Reddedilen |
|---|---|---|---|
| #25 world.data_location | dinleme haberleri | tarih penceresi hafta 76–110 [WORKING] | NEWS_S_VERI_YEREL şerit satırı: yalnız faz 3, rastgele, ateşi okunamaz |
| #31 product.encryption_flaw (+ B2B ikizi) | dönemin şifreleme açığı | kartın kendisi dünyanın haberi; hafta ≥53 [WORKING] | tik 119'a (Nisan 2014) çivilemek: yumuşak tavan 104'ün ötesi |
| #18 rival.outage | rakibin çöktüğü sabah | market_rival:startup + rival.status == QUIET; kart haberin kendisi | yeni 'kesinti' rakip durumu (yeni mekanik) |
| #19 product.sprint_test_rival_batch | rakip aynı özelliği geliştiriyor | sprint_rival yuvası; durum kartın bilgisidir | rakibin gelecek çıkışını okuyan seam (yok) |
| #21 rival.new_firm_warning | Pythia pazarda, pay büyürken | market_rival:established + rival.player_share_pct >= 1.0 + finance.growth_streak_months >= 1 | - |
| #12 customer.finance_team | dışa aktarma kademesi | urun.line_tier.line_shared_integrations == 0, istek Entegrasyonlar k1 | Tablo İçe Aktarma (ters yön) |
| #15 customer.old_browser | eski tarayıcı kademesi | urun.responsive_shipped == false; söz line_shared_mobile_k1 | - |
| #10 customer.training_request | Onboarding alanı zayıf | musteri.onboarding_short (Y25) | urun.floor_state (yalnız B2C) |
| #6 team.rude_client | tercihen kadın temsilci; o hafta bulunan hata | account_rep; musteri.bugs >= 1 | cinsiyet alanı yok; hata haftası seam'i yok |
| #8 product.sprint_dev_code_review | takım lideri | en kıdemli Senior geliştirici | takım lideri kavramı yok |
| #11 customer.own_data_error | Stok hattında çalışmış geliştirici | rastgele geliştirici | hat geçmişi seçicisi (veri kart başına) |

## 8. revize2.json'a girecek metin değişiklikleri

Oyuncu metni olanlar TR/EN onay bekler (commit mesajında). 2. adımın `kriz.acik` 1. ve 2. şık ekleri **alınmaz** (Ç03: onaylı −%1 / −%0,5 kalır).

| Kayıt | Şık | Alan | TR | EN | Neden | Onay |
|---|---|---|---|---|---|---|
| `calisan.bilgisayar` | 1 | sonuc | Kasa yaklaşık bir haftalık gider kadar azalır, Mert'in morali biraz yükselir | Cash drops by about a week's spending, Mert's morale rises a little | Sabit $1.000 yerine haftalık giderden ölçeklenir (ilk çalışanlı Ev'de ~$1.000). Çip doları yazar; bu satır Erdem'in okuduğu özettir. | TR/EN onay bekliyor |
| `calisan.bilgisayar` | 2 | sonuc | Kasa değişmez, Mert'in morali biraz düşer, eski laptopla dört hafta verimi %10 düşer | Cash unchanged, Mert's morale dips a little, and on the old laptop he works 10% slower for four weeks | Yalnız −4 moral 75'lik yeni çalışanın verim bandını değiştirmez; şık oynanışta bedavaydı. | TR/EN onay bekliyor |
| `calisan.dugun` | 1 | sonuc | Kasa Ece'nin aylık maaşının %10'u kadar azalır, Ece'nin morali çok yükselir | Cash drops by 10% of Ece's monthly salary, Ece's morale rises sharply | Sabit $400 yerine kişinin maaşından (hr.salary + amount_slot). | TR/EN onay bekliyor |
| `calisan.dugun` | 2 | sonuc | Kasa Ece'nin aylık maaşının %3'ü kadar azalır, Ece'nin morali yükselir | Cash drops by 3% of Ece's monthly salary, Ece's morale rises | Sabit $100 yerine maaştan. | TR/EN onay bekliyor |
| `calisan.dugun` | 3 | sonuc | Kasa Ece'nin aylık maaşının %1,5'i kadar azalır, Ece'nin morali değişmez | Cash drops by 1.5% of Ece's monthly salary, Ece's morale unchanged | Sabit $60 yerine maaştan. | TR/EN onay bekliyor |
| `calisan.kaba_musteri` | 1 | sonuc | Kuzey İnşaat'ın aramaları sana geçer, iki hafta verimin düşer, Zeynep'in morali biraz yükselir | Kuzey İnşaat's calls come to you, your productivity drops for two weeks, Zeynep's morale rises a little | Şığın okunur bir kazancı yoktu; 3. şıktan yalnız pahalıydı. | TR/EN onay bekliyor |
| `ekip.ayni_izin.pm` | 1 | sonuc | İkisi de iki hafta izinde; izinden önceki iki hafta ikisinin de verimi %20 artar | Both are away for two weeks; in the two weeks before, both work 20% faster | PM'in işi hazırlıktır; 'verim %30 düşer' hazırlığı öne alan bir kazanç vermiyor, şık 3. şıktan her yönden kötüydü. TR/EN onay bekliyor. Plan: 'ikisinin de morali yükselir' çıkar; dönüş morali her şıkta doğaldır, bu şıkta çip yok. | TR/EN onay bekliyor |
| `ekip.ayni_izin.gelistirici` | 3 | sonuc | Geç başlayanın izni bu yıl örtüşmeyecek kadar kayar, Kasa onun bir haftalık maaşı kadar azalır | The later one's leave slides just enough not to overlap this year, Cash drops by a week of their salary | Adım 1'in '[2. adım]' yer tutucusu dolduruldu. | TR/EN onay bekliyor |
| `ekip.ayni_izin.testci` | 3 | etiket | Birinin iznini kaydır, karşılığında prim ver | Move one leave and pay a bonus for it | Eski 3. şık 'İkisi de gitsin, sürüm kaysın' koddaki doğal davranışla 2. şıkla aynıdır (test fazı geliştiriciye kendiliğinden düşer, sprint_system.gd:1276-1281); geliştirici varyantının prim şıkkı geldi. TR/EN onay bekliyor. | TR/EN onay bekliyor |
| `ekip.ayni_izin.testci` | 3 | sonuc | Geç başlayanın izni bu yıl örtüşmeyecek kadar kayar, Kasa onun bir haftalık maaşı kadar azalır | The later one's leave slides just enough not to overlap this year, Cash drops by a week of their salary | Yukarıdaki etiketle birlikte. | TR/EN onay bekliyor |
| `ekip.kod_inceleme` | 2 | etiket | Kerem'le Onur'u bir gün aynı masaya oturt, notları birlikte kapatsınlar | Sit Kerem and Onur down together for a day to clear the notes | Bedel iki kişinin birer günüdür; yarım gün 3. şıktan her yönden ucuz kalıyordu. | TR/EN onay bekliyor |
| `ekip.kod_inceleme` | 2 | etiket_yuva | {lead} ile {employee} bir gün aynı masaya otursun, notları birlikte kapatsınlar | Sit {lead} and {employee} down together for a day to clear the notes | Etiketle aynı değişiklik, eksiz yuva biçimi. | TR/EN onay bekliyor |
| `ekip.kod_inceleme` | 2 | sonuc | Kerem'in ve Onur'un bu hafta birer günü gider, Onur'un morali yükselir | Kerem and Onur each lose a day this week, Onur's morale rises | Sayı −%30 (yalnız Kerem) yerine ikisine −%20. | TR/EN onay bekliyor |
| `ekip.kod_inceleme` | 1 | sonuc | Kartın kalan işi kısalır, kart çıkınca hattına bir hata düşer, Kerem'in morali biraz düşer | The card's remaining work shrinks, its line gets a bug when the card ships, Kerem's morale dips a little | Hata kartın incelenmemiş kodundadır, kart çıkınca düşer (sprint_card_trim bugs 1). | TR/EN onay bekliyor |
| `ekip.soz_verdi` | 2 | locked_reason | Bu sözü bir kez uzattık. | We have already moved this promise once. | Söz yalnız bir kez uzar (PromiseRegistry.extend); kilitli şık gerekçesiyle görünür. | TR/EN onay bekliyor |
| `musteri.egitim` | 2 | sonuc | Kasa hesabın yarım aylık ücreti kadar artar, Deniz'in iki günü gider, Anadolu Yapı'nın memnuniyeti biraz düşer | Cash rises by half the account's monthly fee, Deniz loses two days, Anadolu Yapı's satisfaction drops a little | Sabit $600 yerine hesabın MRR'ından (musteri.mrr + amount_slot). | TR/EN onay bekliyor |
| `musteri.kendi_hatasi` | 3 | sonuc | Emre'nin bir haftası gider, Ekin Gıda'nın memnuniyeti artar, Stok hattını kullanan öbür hesapların memnuniyeti biraz artar | Emre loses a week, Ekin Gıda's satisfaction rises, and other accounts on the Stock line are a little more satisfied | Geliştiricinin haftası temsilcinin gününden yalnız pahalıydı; önlem hattın bütün hesaplarına yayılır. | TR/EN onay bekliyor |
| `rakip.ayni_ozellik` | 1 | sonuc | Üç hesabın memnuniyeti artar; kartın testi hata bulursa aynı üç hesabın memnuniyeti daha çok düşer | All three accounts grow more satisfied; if the card's testing finds a bug, the same three accounts' satisfaction drops further | 'Kalıcı olarak' yanlış: trust_offset dört haftada söner. B (−8) A'dan (+6) büyük. | TR/EN onay bekliyor |
| `rakip.panel` | 2 | sonuc | Aday imzalarsa hesap ilk yıl %15 indirimli açılır, imzalamazsa teklif düşer | If they sign, the account opens at 15% off for the first year; if not, the offer lapses | Adım 1'in X yer tutucusu: %15. | TR/EN onay bekliyor |
| `dunya.disk` | 2 | locked_reason | Büyük müşterilerimizin sözleşmesinde bugünkü sağlayıcımızın adı yazıyor. | Our larger customers' contracts name our current provider. | Yardımcı yönetmen kararı: 3★ ve üstü hesap varken 2. şık kilitli, gerekçe kademeden bağımsız (adım 1'deki 'adıyla yazıyor' cümlesinin yerine). TR/EN onay bekliyor. | TR/EN onay bekliyor |
| `odul.final` | 1 | sonuc | Bir günün provaya gider; %25 ihtimalle birincilik (Kasa +$10.000, Marka +3), yoksa Marka +1; açık hatan varsa ihtimal düşer ve demo sahnede takılır (Marka −2) | You spend a day rehearsing; 25% chance to win (Cash +$10,000, Brand +3), otherwise Brand +1; with open bugs the odds drop and the demo freezes on stage (Brand −2) | Bir şık tek zar taşır; takılma durumdan okunur. Kesin Marka +3 canlı demoyu video ve slayttan her yönden iyi yapıyordu. Çip yüzdeyi seam'den yazar, karta sayı girmez. | TR/EN onay bekliyor |
| `odul.final` | 3 | sonuc | Yarım günün slaytlara gider, Marka +1, %10 ihtimalle birincilik | Half a day goes into the slides, Brand +1, 10% chance to win | Şığın bedeli yoktu. | TR/EN onay bekliyor |
| `kriz.ameliyat` | 2 | sonuc | Kart sürer, kartın işi %20 büyür, devralanın kendi kartı bekler | The card keeps moving, its work grows 20%, the other developer's own card waits | Mevcut seam kartın toplam puanını okur (urun.decision_card_effort); 'kalan' için yeni seam gerekir. | TR/EN onay bekliyor |
| `ekip.kod_inceleme` | 3 | etiket_yuva | Kart bu sprintte bu hâliyle kalsın, {employee} notları sonraki sprintte düzeltsin | Keep the card as it is this sprint, {employee} fixes the notes next sprint | Kâğıdın konuşan yuvası 'employee'dir (kâğıt kuralı); {dev} jetonu {employee} olur. EN 1. adımın yuva metninden; 5. adım birebir hizalar. | TR/EN onay bekliyor |
| `ekip.kod_inceleme` | 4 | etiket_yuva | {employee} bu sefer notların hepsini kapatsın, kart sağlam çıksın | {employee} closes every note this time, the card ships solid | Aynı jeton değişikliği. | TR/EN onay bekliyor |
| `rakip.ayni_ozellik` | - | gonderen | {employee}, Test Uzmanı (rol motordan) | {employee}, Tester (role from the engine) | Ç15: konuşan test aşamasındaki kişi (testçi ya da testi yapan geliştirici). | TR/EN onay bekliyor |
| `rakip.ayni_ozellik` | - | konu_yuva | Aynı özellik: {rival} | Same feature: {rival} | Kart her özellik kartında gelebilir; 'toplu fatura' sabiti çıkar. | TR/EN onay bekliyor |
| `rakip.ayni_ozellik` | - | metin_yuva | Rakiplerden {rival}, {seam:urun.decision_card} kartımızın aynısını geliştiriyormuş. Bizde kart hazır ama testine daha başlamadık. Önce biz çıkarsak ilk duyulan isim biz oluruz. | {rival} is building the same thing as our {seam:urun.decision_card} card. Ours is ready, but testing has not started yet. If we ship first, ours is the name people hear first. | Konuşan testi yapan kişi; kartın adı var olan urun.decision_card seam'inden. Rakip adına ek gelmez ('{rival} da' ünlü uyumu isterdi). | TR/EN onay bekliyor |
| `musteri.kendi_hatasi` | 1 | locked_reason | Bu hesabın müşteri temsilcisi yok. | This account has no account manager. | Kilitli şık gizlenmez (GDD §3.3); revize2 'temsilci yoksa 1. şık görünmez' diyordu. | TR/EN onay bekliyor |
| `kriz.ameliyat` | 2 | locked_reason | Ekipte kartı devralacak başka bir yazılımcı yok. | There is no other developer on the team to take the card. | Devralma şıkkı ekipte başka geliştirici yokken kilitli, gerekçeyle. | TR/EN onay bekliyor |
| `ekip.ayni_izin.pm` | - | kosul_notu | Gönderen çiftin önce izne çıkanıdır (eskisi: kıdemlisi). |  | Ç08 (oyuncu metni değil). | oyuncu metni değil |
| `ekip.ayni_izin.gelistirici` | - | kosul_notu | Gönderen çiftin önce izne çıkanı; prim geç başlayanın (kayanın) maaşından. |  | Ç08. | oyuncu metni değil |
| `ekip.ayni_izin.testci` | - | kosul_notu | Gönderen çiftin önce izne çıkanı; prim geç başlayanın (kayanın) maaşından. |  | Ç08. | oyuncu metni değil |
| `odul.final` | - | kosul_notu | v1.0 çıkmış, Bootstrap, kurucunun yanında en az bir çalışan; marka ve kitle eşiği yok; koşuda bir kez. Ödül $10.000 [WORKING] (karar 3'ün istisnası). |  | Ç21. | oyuncu metni değil |
| `dunya.veri_nerede` | - | kosul_notu | Karar 9: tarih penceresi hafta 76–110 [WORKING] (dinleme haberleri Haziran 2013 ≈ tik 75–76); sağlık ya da finans hesabı; metnin ilk cümlesi değişmez. |  | Karar 9 seçimi. | oyuncu metni değil |
| `kriz.acik` | - | kosul_notu | Karar 9: kart dünyanın haberidir; hafta ≥53 [WORKING]; metin tarih yazmaz. |  | Karar 9 seçimi. | oyuncu metni değil |
| `kriz.acik.b2b` | - | kosul_notu | Karar 9: #31 ile aynı pencere (hafta ≥53). |  | Karar 9 seçimi. | oyuncu metni değil |
| `rakip.kesinti` | - | kosul_notu | Pazarda QUIET durumda küçük (startup) bir rakip; kart haberin kendisidir (rakibin kesinti durumu oyunda yok). |  | Karar 9 seçimi. | oyuncu metni değil |
| `urun.eski_tarayici` | - | kosul_notu | 'Eski tarayıcı' kademesi yerine Mobil ve Erişim k1 (Duyarlı Arayüz); koşul urun.responsive_shipped == false; söz bir sprint (PROMISE_DEADLINE_WEEKS). |  | Karar 9 / I06 b. | oyuncu metni değil |
| `musteri.muhasebeci` | - | kosul_notu | 'Dışa aktarma' kademesi yerine Entegrasyonlar k1; koşul o hattın kademesi 0. |  | Karar 9 / I06 a. | oyuncu metni değil |
| `dunya.halka_arz` | - | kod_notu | Tohumlu rastgele seçici (Y07) investor yuvasını da doldurur; investor_favor ailesi hâlâ yok [VOCAB?]. |  | park kaydı: yalnız kod_notu güncel kalır | oyuncu metni değil |
| `dunya.okur_anketi` | - | kod_notu | Karar 2'nin 'ayın gelirinden düşer' fiili yok: FinanceSystem'de aylık gelir kalemine yazan olay fiili yok (apply_one_time_income aylık gelire yazmaz) [VOCAB?]. |  | park kaydı: yalnız kod_notu güncel kalır | oyuncu metni değil |
| `basin.kayit` | - | kod_notu | top_skill:engineering seçicisi (Y14) var; kapasiteyi olaydan yazan fiil yok, InfraSystem oyuncunundur [VOCAB?]. |  | park kaydı: yalnız kod_notu güncel kalır | oyuncu metni değil |
| `pazaryeri.yanlis_fiyat` | - | kod_notu | check dalı ve çipi (Y03, Y04) ile sonraki sprinte kart (queue_card, Y38) artık var; pazaryeri kavramları Faz E. |  | park kaydı: yalnız kod_notu güncel kalır | oyuncu metni değil |
| `pazaryeri.fare` | - | kod_notu | sprint_fix_first günlük kartta yasal (V3 yalnız sprint_card_* içindir; acil durum kartları kullanır): 'kod işi' notu bayat. |  | park kaydı: yalnız kod_notu güncel kalır | oyuncu metni değil |
| `pazaryeri.rekor_ay` | - | kod_notu | check dalı (Y03) ve sprint_fix_first hazır; mağaza memnuniyeti Faz E. |  | park kaydı: yalnız kod_notu güncel kalır | oyuncu metni değil |

## 9. Değiştirici kurallarına göre denge (özet)

- **Ölçek:** moral ±4 ('biraz'), ±6 (nitelemesiz), ±8–12 ('çok'); memnuniyet `trust_delta` ±4 / ±8, tavan +10, kırık söz −12; marka ±1–3; itibar ±1–3, kumarın kötü dalında −8 (Erdem onaylı #31).
- **Para:** `finance.daily_burn × −7` (#1), kişinin maaşından `hr.salary + amount_slot` (#3 %10 / %3 / %1,5; #7 bir haftalık maaş), hesabın MRR'ından `musteri.mrr + amount_slot` (#10 +%50). Sabit dolar yalnız #30'un ödülü (karar 3'ün istisnası).
- **Kumarlar** (EvTuning tek tablo; karta sayı yazılmaz): #6 %15 fesih, #21 %20 aday kaybı, #25 %25 ortaya çıkış, #30 %25→%10 (açık hatayla) / %15 / %10 ödül, #31 ve ikizi %10 basın. Hesap kaybı yalnız #6'nın zarında ve #25'in zarla gelen zincir kartında.
- **Kalıcı iz** her yerde `trust_delta` (`trust_offset`); `satisfaction_delta` hiçbir kartta yok.
- **Beat'ler:** #24, #26 (bedelsiz, baseline), #5 ayrılış ve iki basın kartı (tek şık, bedelli), #18 (tek şık, bedelli fırsat).

## 10. Öz denetim

**Ne doğrulandı (otomatik, `plan/build.py`):**

- (a) **Kod iddiaları:** planın dayandığı 139 bugünkü işlev, imza, sabit, alan, sinyal, seam ve CSV satırı kopyada regex'le arandı: 139/139 bulundu. Var sanılan 22 seam'in hepsi kayıtlı. Yeni sanılan 10 şeyin (pin_card, set_exit_notice, infra_price_mult, olay.odds_*, summer_leave, after_test, time.quarter_start, hr.role, EFFECT_CHANCE, FIN_ONETIME_EQUIPMENT) hiçbiri kodda yok.
- (b) **Kart kuralları:** 28 kart, 69 seçenek. Her beat olmayan şıkta bir bedel çipi (O2; check dalları ve `schedule_event`'in hedef kartındaki ortak etki dahil); kumar oranı 0,10–0,30 ve adlı seam'den; durumdan gelen oranda `modifier_lines`; riskli sonuç `on_pass`'ta; hesap kaybı zarsız değil; moral ve marka ölçekte; `add_cash` sabit doları yalnız #30'da, kişi ve gider tutarları iki haftalık sınırın altında; `on_expire`'da olumlu ekonomik etki yok (I2); `trigger_ending` ve `satisfaction_delta` yok; V1 (bugünkü WRITER_VERBS + planın 13 eki), V2 (yalnız kapsamlı söz fiilleri), V3 (`sprint_card_*` yalnız `tick: request`), O3; şema 3 alanları (plausibility, family, delay_reason, subject_tenure, fresh_reason, T2 family_subject, expires_weeks/on_expire); her fiilin yuvası scope'ta; kilitlenebilir şıkta `locked_reason`; kart metinlerinde ihtimal sayısı yok. Bulgu: 0.
- Denetim yardımcıları bilerek bozulmuş girdiyle sınandı: bedelsiz moral şıkkı bedel sayılmadı, hedef kartı bedelli `schedule_event` bedel sayıldı, `%15 ihtimalle` metni yakalandı, '%15 zam' yakalanmadı.
- **Kapsam:** revize2'nin 27 `bagla` kaydının hepsi planda; id'si 1. adımdan farklı olan: `rakip.ayni_ozellik` product.sprint_pm_rival_batch → product.sprint_test_rival_batch; aynı kayıttan ikinci dosya: `product.encryption_flaw_press_b2b`.

**Elle doğrulanan (c):**

- **WRITE-THROUGH:** her yeni fiil sahibin seam'inden geçer: hesap → `CustomerRegistry` (yeni `set_exit_notice`, `set_timed_discount`; var olan `assign_customer`, `set_trust_offset`, `set_mrr`), toplam MRR → `SalesSystem.reflect_mrr`, aday → `ProspectRegistry.set_offer` ve `SalesFinalizer.lose`, söz → `PromiseRegistry`, kişi → `CharacterRegistry` (yeni `set_leave_override`, `set_away`; var olan `set_status`) üzerinden HR, ürün → `ProductState` setter'ları ve `SprintSystem.pin_card` / `send_next`, talep → `SprintBridges.open_request` (köprünün `requests` yazarlığı), satış görüşmesi → `SalesMeetingSystem.set_pitch_focus`. Hiçbir olay başka alanın durumunu doğrudan yazmaz; `GameState.flags`'e yalnız sahibin adlı işlevi yazar.
- **ORTAK_CALISMA §2:** `sprint_system.gd`'ye yalnız yeni public `pin_card`; `_assign` değişikliği URUN_ARAYUZU'nda (I01). `sprint_catalog.gd`, `product_model.gd`, `product_tab.gd` yalnız okunur ya da istekle (I03). `mail_pane.gd` sunucu kilidi Temizlik B3'ten sonra (I04). `data/product/sprint.json` havuzu haber verilerek (I02).
- **ORTAK_CALISMA §6:** `SaveManager.SCHEMA_VERSION` artmaz; her yeni alan anlamlı varsayılanlı (`-1`, `0`, `""`, `{}`, `1.0`); motor bloğu `BLOCK_VERSION` 1 kalır (`watch` anahtarı yoksa boş). `strings.csv`'ye yeni anahtarlar kendi aile bloklarında (EFFECT_, FIN_ONETIME_, SALES_, PRODUCT_, HR_NEWS_), bayt aralığıyla.
- **EFFECT-VISIBILITY:** yeni her fiilin `EvChips.describe`'da etiketi var; check dalları (Y04), `schedule_event`'in sonra-çipi (Y11), `after_test` (Y39) çizilir; çip, geçmiş satırı ve bot tutarı aynı `EvEffects.amount(e, ctx)`'ten okur (Y10). `event_chip_coverage` her grubun kapısında.
- **I2/I3:** olumlu ekonomik etki yalnız oynanan karar ya da zar dalında; `on_expire`'larda yalnız bedel; `trigger_ending` yok; `account_notice` koşuyu bitirmez (I3'ün telgraf kuralı gerekmez).
- **Lint O2:** iki dünya duyurusu baseline'da; geri kalan her şık bedelli. **O3:** tek kişilik kartlarda ekip saati ve ekip morali yok (#8'in `morale_crew speaker`'ı muaf). **O4:** gönderen ya da anılan çalışan yuvaları `subject: false` (L01).

**Düzeltilen (bu turda):**

- 3. adımın #19 için önerdiği `urun.decision_step_name` gereksizdi: `urun.decision_card` seam'i zaten 'name of the card a sprint decision waits on' döndürüyor.
- 3. adımın `decision_line_top` seçicisi ve 2. adımın `top3` seçicisi gereksizdi: `line_top` (`SprintCatalog.paper_account`) `used` ile üç yuvada üç ayrı hesap verir.
- Teklifli imzanın sözü `accept_promise` ile değil `PromiseRegistry.create` ile açılır: `accept_promise` (`b2b_sales_system.gd:376`) riskteki hesabı da toparlar (`_recover`).
- `ProspectRegistry`'de sinyal yok; aday sinyalleri EventBus'tadır (`prospect_added`, `prospect_removed`): 3. adımın yeni autoload sinyali dinleyicisiz olduğu için yazılmaz.
- `assign_to` bugün `NEUTRAL_VERBS`'te ama kolu ve çipi yok (effects.gd:40 dışında geçmiyor): 'kolsuz' doğrulandı.
- Lint O2 check dallarını zaten sayıyor (`_option_effects`, lint.gd:624-629); 3. adımın bu iddiası düştü. Erişilebilirlik ve `_is_chained` taraması ise yalnız `options[].effects`'e bakıyor (lint.gd:494, :896): düzeltme Y05'te kalır.
- PROMISE_DEADLINE_WEEKS = 2 (`b2b_constants.gd:152`): #15'in sözü revize2 metniyle ('bir sprintlik söz') zaten aynı; 2. adımın 4 haftası alınmadı.
- Sektör id'leri `health`, `finance`, `retail` (B2BConstants.SECTORS); seviyeler junior 0, mid 1, senior 2; Geliştirme fazı 1, Test fazı 2.
- Pazar payı ölçeği: `rival.player_share_pct` = 100 × MRR / 1.500.000; #21 eşiği %1 (MRR ~$15K) [WORKING].
- `finance.daily_burn` gün başına orandır (seams_finance.gd: 'a per-day rate'): #1'in çarpanı −7 bir haftadır.
- `plausibility.gd:54` `EvTuning.FAMILY_GAP_WEEKS`'in kopyasını taşıyor: #7'nin 52 haftalık aile freni iki yere birden yazılmasın diye kopyanın EvTuning'i okuması Y15'e eklendi.
- #31'in oranı ve #30'un video/slayt oranları sabit tablodan geldiği için `modifier_lines` taşımaz; bu GDD §17.11'den sapmadır ve motor md §27'ye inşa notu olarak yazılır (Y05).

**Açık kalan (yardımcı yönetmen, I06):** kurgu seçimleri (a)–(i). Cevap gelmezse plan bu seçimlerle yürür; metne dokunanlar 8. adım sayfasında Erdem'e gider.
