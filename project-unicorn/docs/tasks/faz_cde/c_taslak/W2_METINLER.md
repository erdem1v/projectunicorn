# W2 · Faz C Pazar 2 yazım dalgası

Kaynak `W2_METINLER.json`; bu dosya `w2check.py` ile üretilir, elle düzenlenmez.

## C8

| id | Yer | EN | TR |
|---|---|---|---|
| `accounts.col_seats` | HESAPLAR · sütun başlığı | Staff · Seats | Çalışan · Koltuk |
| `accounts.col_sector` | HESAPLAR · sütun başlığı | Sector | Sektör |
| `accounts.col_modules` | HESAPLAR · sütun başlığı | Modules | Modüller |
| `accounts.col_stars` | HESAPLAR · sütun başlığı | Stars | Yıldız |
| `accounts.col_trend` | HESAPLAR · sütun başlığı | Trend | Gidiş |
| `accounts.col_condition` | HESAPLAR · sütun başlığı | Condition | Şart |
| `accounts.trend_growing` | HESAPLAR · Gidiş hücresi | Growing | Büyüyor |
| `accounts.trend_steady` | HESAPLAR · Gidiş hücresi | Steady | Durağan |
| `accounts.trend_shrinking` | HESAPLAR · Gidiş hücresi | Shrinking | Küçülüyor |
| `accounts.condition_cell` | HESAPLAR · Şart hücresi | {module} {wanted} · {deadline} | {module} {wanted} · {deadline} |
| `accounts.view_conditional` | HESAPLAR · görünüm (Şartlı süzgeci) | Conditional {count} | Şartlı {count} |
| `accounts.term_short_obsolete` | HESAPLAR · Memnuniyet hücresinin kısa terim adı (eskime) | {module} behind | {module} geride |
| `accounts.term_short_request` | HESAPLAR · Memnuniyet hücresinin kısa terim adı (bekleyen istek) | Waiting request | Bekleyen istek |
| `accounts.action_promise_tip` | HESAPLAR · açık isteği olan 3★+ satırında Söz ver düğmesinin ipucu | Promise {module} {level}. A broken promise goes into the account's ledger. | {module} {level} için söz ver. Tutulmayan söz hesabın defterine yazılır. |
| `accounts.status_may_not_renew` | DÜŞTÜ | PLAN_C_P2 §6 'Yenileme tutum bantları' satırı ve Sessiz 36: Yenilemeyebilir kalkar, yerini Şartlı alır (accounts.status_conditional). | |
| `accounts.status_not_renewing` | DÜŞTÜ | PLAN_C_P2 §6 'Sözleşme ortası Risk geri sayımıyla ayrılma' ve 'Yenileme kâğıdı' satırları: ayrılma yalnız yenileme gününde olur (SENTEZ:352), önceden 'Yenilemeyecek' hâli doğmaz; şartın bildirimi C4'ün Fesih bildirimi etiketini okur. | |
| `accounts.term_short_update_age` | DÜŞTÜ | PLAN_C_P2 §6 'Güncelleme yaşı' satırı. | |
| `accounts.term_short_raise` | DÜŞTÜ | PLAN_C_P2 §6 'Durum terimleri zam −2 ve gönülsüz yenileme −6' satırı. | |
| `accounts.term_short_reluctant` | DÜŞTÜ | PLAN_C_P2 §6 'Durum terimleri zam −2 ve gönülsüz yenileme −6' satırı. | |

## C10

| id | Yer | EN | TR |
|---|---|---|---|
| `era.locked` | Ürün · kademe kartı · kilit gerekçesi (dönem tavanı) | Opens in {year} | {year} yılında açılır |

## C12

| id | Yer | EN | TR |
|---|---|---|---|
| `report.sender` | Yıllık rapor maili (Kasım) · gönderen | Sektör Telgrafı | Sektör Telgrafı |
| `report.subject` | Yıllık rapor maili (Kasım) · konu (B2B) | Annual ERP report · {year} | Yıllık ERP raporu · {year} |
| `report.intro` | Yıllık rapor maili (Kasım) · giriş paragrafı (B2B) | Sektör Telgrafı's annual ERP list is out. This year's ranking reads 1 January to 31 October. | Sektör Telgrafı'nın yıllık ERP listesi çıktı. Bu yılın sıralaması 1 Ocak ile 31 Ekim arasını okur. |
| `report.sec_biggest` | Yıllık rapor maili (Kasım) · bölüm başlığı | The biggest | En büyükler |
| `report.big_row` | Yıllık rapor maili (Kasım) · en büyükler satırı (ilk beş) | {rank}. {company} · {account_count} accounts | {rank}. {company} · {account_count} hesap |
| `report.you_rank` | Yıllık rapor maili (Kasım) · oyuncu ilk beşte değilse | You are No. {rank} · {account_count} accounts | Siz {rank}. sıradasınız · {account_count} hesap |
| `report.sec_fastest` | Yıllık rapor maili (Kasım) · bölüm başlığı | The fastest growing | En hızlı büyüyenler |
| `report.fast_row` | Yıllık rapor maili (Kasım) · en hızlı büyüyenler satırı | {rank}. {company} · {pct}% growth | {rank}. {company} · %{pct} büyüme |
| `report.you_fast_rank` | Yıllık rapor maili (Kasım) · oyuncu listede ama ilk beşte değil | You are No. {rank} · {pct}% growth | Siz {rank}. sıradasınız · %{pct} büyüme |
| `report.you_fast_young` | Yıllık rapor maili (Kasım) · oyuncu bir yaşında değil | Your company is not a year old yet; it can enter this list next year. | Şirketiniz henüz bir yaşında değil; bu listeye gelecek yıl girebilir. |
| `report.you_fast_floor` | Yıllık rapor maili (Kasım) · oyuncu gelir tabanının altında | To enter this list, yearly revenue has to pass {floor}. | Bu listeye girmek için yıllık gelirin {floor} tabanını geçmesi gerekir. |
| `report.sec_awards` | Yıllık rapor maili (Kasım) · bölüm başlığı (yalnız B2B) | Modules of the year | Yılın modülleri |
| `report.award_row` | Yıllık rapor maili (Kasım) · ödül satırı (on modül) | {module} of the year: {company} | Yılın {module} modülü: {company} |
| `report.award_none` | Yıllık rapor maili (Kasım) · ödülsüz modül | {module}: no award this year; nobody cleared the bar | {module}: bu yıl ödül yok, eşiği geçen çıkmadı |
| `report.sec_yours` | Yıllık rapor maili (Kasım) · bölüm başlığı (oyuncunun modülleri) | Your modules | Sizin modülleriniz |
| `report.yours_row` | Yıllık rapor maili (Kasım) · oyuncunun modül satırı | {module}: {state} | {module}: {state} |
| `report.state_award` | Yıllık rapor maili (Kasım) · modül durumu sözcüğü | award | ödül |
| `report.state_shortlist` | Yıllık rapor maili (Kasım) · modül durumu sözcüğü | on the shortlist | kısa listede |
| `report.state_standard` | Yıllık rapor maili (Kasım) · modül durumu sözcüğü | at the standard | standartta |
| `report.state_behind` | Yıllık rapor maili (Kasım) · modül durumu sözcüğü | behind | geride |
| `report.award_yours` | Yıllık rapor maili (Kasım) · oyuncu ödül aldıysa, ödül bölümünün altı | The {module} award is yours: leads who want {module} come more often until {until}. | {module} ödülü sizin: {module} isteyen adaylar {until} tarihine kadar daha sık geliyor. |
| `report.rules` | Yıllık rapor maili (Kasım) · son paragraf, kurallar (B2B) | How the lists are made: the biggest are ranked by number of accounts. The fastest growing are ranked by growth over the last 52 weeks; to enter, a company must be at least a year old and past {floor} in yearly revenue. A module award goes to the highest level shipped, used by at least {min_count} accounts; a company wins at most one award per module a year. Leads who want a winning module come more often for 12 months. | Listeler nasıl yapılır: Büyüklük listesi hesap sayısına göre sıralanır. Büyüme listesi son 52 haftanın büyümesine göre sıralanır; girmek için en az bir yıllık olmak ve yıllık gelirde {floor} tabanını geçmek gerekir. Modül ödülü yayımlanmış en yüksek seviyeye gider ve o modülü en az {min_count} hesabın kullanması gerekir; bir şirket bir modülde yılda en çok bir ödül alır. Ödül alan modülü isteyen adaylar 12 ay boyunca daha sık gelir. |
| `report.subject_b2c` | Yıllık rapor maili (Kasım) · konu (B2C) | Annual platform report · {year} | Yıllık platform raporu · {year} |
| `report.intro_b2c` | Yıllık rapor maili (Kasım) · giriş paragrafı (B2C) | Sektör Telgrafı's annual platform list is out. This year's ranking reads 1 January to 31 October. | Sektör Telgrafı'nın yıllık platform listesi çıktı. Bu yılın sıralaması 1 Ocak ile 31 Ekim arasını okur. |
| `report.big_row_b2c` | Yıllık rapor maili (Kasım) · en büyükler satırı (B2C) | {rank}. {company} · valued at {value} | {rank}. {company} · değeri {value} |
| `report.you_rank_b2c` | Yıllık rapor maili (Kasım) · oyuncu ilk beşte değilse (B2C) | You are No. {rank} · valued at {value} | Siz {rank}. sıradasınız · değeri {value} |
| `report.rules_b2c` | Yıllık rapor maili (Kasım) · son paragraf, kurallar (B2C) | How the lists are made: the biggest are ranked by value. The fastest growing are ranked by growth in value over the last 52 weeks; to enter, a company must be at least a year old. | Listeler nasıl yapılır: Büyüklük listesi değere göre sıralanır. Büyüme listesi son 52 haftada değerin büyümesine göre sıralanır; girmek için en az bir yıllık olmak gerekir. |
| `award.badge_line` | Satış · aday listesinin üstü · ödül satırı (12 ay) | {module} of the year · more leads until {until} | Yılın {module} modülü · {until} tarihine kadar daha çok aday |
| `news.report_out` | Haber şeridi · rapor günü | Sektör Telgrafı's annual ERP list is out, with {company} on top. | Sektör Telgrafı'nın yıllık ERP listesi çıktı; zirvede {company} var. |

## C11a

| id | Yer | EN | TR |
|---|---|---|---|
| `news.rival_update` | Haber şeridi · rakip sürümü (haftada en çok bir satır) | {rival} updated its {module} module. | {rival}, {module} modülünü yeniledi. |
| `news.rival_update_two` | Haber şeridi · rakip sürümü (haftada en çok bir satır) · aynı rakip iki modül | {rival} updated its {module} and {module_two} modules. | {rival}, {module} ve {module_two} modüllerini yeniledi. |
| `news.rival_update_many` | Haber şeridi · rakip sürümü (haftada en çok bir satır) · aynı rakip üç ve daha çok modül | {rival} updated {count} modules at once, {module} among them. | {rival} aynı hafta {count} modülünü yeniledi; aralarında {module} modülü de var. |
| `news.rivals_same_module` | Haber şeridi · rakip sürümü (haftada en çok bir satır) · iki rakip aynı modül | {rival} and {rival_two} both updated {module} this week. | Bu hafta {module} modülünü hem {rival} hem {rival_two} yeniledi. |

## C11b

| id | Yer | EN | TR |
|---|---|---|---|
| `market.share_line` | Finans · pazar payı satırı | Market share {pct}% · No. {rank} in ERP | Pazar payı %{pct} · ERP'de {rank}. sırada |
| `market.pool_line` | Piyasa · Sektör görünümü · havuz satırı | ERP market: {account_count} accounts across {company_count} companies | ERP pazarı: {company_count} şirkette {account_count} hesap |
| `market.rival_line` | Piyasa · sektör rakibinin kartı · hesap satırı | {account_count} accounts · {mrr} a month | {account_count} hesap · ayda {mrr} |
| `pool.won_from` | Haftalık satış özeti · rakipten gelen hesap | {company} joined · was with {rival} | {company} geldi · önceki ürünü {rival} |
| `pool.lost_to` | Haftalık satış özeti · rakibe giden hesap | {company} left · now with {rival} | {company} gitti · yeni ürünü {rival} |
| `news.rival_acquired` | Haber şeridi · kasası biten girişim satın alındı | {buyer} has bought {rival}, and its customers change hands with it. | {buyer}, {rival} şirketini satın aldı. Müşterileri de el değiştiriyor. |

## C5-1

| id | Yer | EN | TR |
|---|---|---|---|
| `renewal.grew` | Haftalık satış özeti · yenileme, koltuk arttı | {company} grew ({old} → {new} employees): +{seat_delta} seats | {company} büyüdü ({old} → {new} çalışan): +{seat_delta} koltuk |
| `renewal.grew_no_seats` | Haftalık satış özeti · yenileme, büyüdü ama memnuniyet düşük | {company} grew but added no seats: satisfaction is low ({reasons}) | {company} büyüdü ama koltuk eklemedi: memnuniyeti düşük ({reasons}) |
| `renewal.shrank` | Haftalık satış özeti · yenileme, koltuk azaldı | {company} shrank ({old} → {new} employees): −{seat_delta} seats | {company} küçüldü ({old} → {new} çalışan): −{seat_delta} koltuk |
| `renewal.star_up` | Haftalık satış özeti · yenileme, bant aştı | {company} moved up a size: {old_stars} → {new_stars} | {company} bir üst ölçeğe geçti: {old_stars} → {new_stars} |
| `renewal.star_down` | Haftalık satış özeti · yenileme, bandın altına indi | {company} moved down a size: {old_stars} → {new_stars} | {company} bir alt ölçeğe indi: {old_stars} → {new_stars} |
| `renewal.left_condition` | Haftalık satış özeti · yenilemedi, iki adım geride modül | {company} did not renew: {module} at {ours}, wanted {wanted} · now with {rival} | {company} yenilemedi: {module} {ours} seviyesinde, istediği {wanted} · artık {rival} |
| `renewal.left_satisfaction` | Haftalık satış özeti · yenilemedi, memnuniyet eşiğin altında | {company} did not renew: satisfaction under the bar ({reasons}) · now with {rival} | {company} yenilemedi: memnuniyeti eşiğin altında ({reasons}) · artık {rival} |
| `renewal.left_non_product` | Haftalık satış özeti · yenilemedi, ürün dışı neden | {company} did not renew: {reason}. Not about the product. | {company} yenilemedi: {reason}. Ürünle ilgisi yok. |
| `leave.reason_budget` | Ürün dışı ayrılma nedeni (küçük harf parça) | cutting its spending | harcamalarını kısıyor |
| `leave.reason_acquired` | Ürün dışı ayrılma nedeni (küçük harf parça) | bought by another company | başka bir şirkete satıldı |
| `leave.reason_closed` | Ürün dışı ayrılma nedeni (küçük harf parça) | closing down | kapanıyor |
| `sat.term_non_product` | Memnuniyet ipucu · defter satırı · ürün dışı ayrılma (hesabın son satırı) | Left for a reason outside the product: {reason} | Ürün dışı ayrılma: {reason} |
| `weekly.sec_renewals` | Haftalık satış özeti · bölüm başlığı | Renewals | Yenilemeler |
| `weekly.sec_left` | Haftalık satış özeti · bölüm başlığı | Did not renew | Yenilemeyenler |
| `weekly.renewed_same` | Haftalık satış özeti · koltuğu değişmeyen yenilemeler tek satır | {count} accounts renewed on the same seats. | {count} hesap aynı koltukla yeniledi. |
| `weekly.renewed_same_one` | Haftalık satış özeti · aynı, tek hesap | {count} account renewed on the same seats. | {count} hesap aynı koltukla yeniledi. |
| `leave.mail.subject` | Ayrılan 3★+ hesabın maili · konu (mail bütçesine girer) | We are not renewing | Sözleşmemizi yenilemiyoruz |
| `leave.mail.body_budget` | Ayrılan hesabın maili · gövde, harcama kesintisi | Our renewal date has come, but we are not continuing this year: we are cutting our spending.<br><br>The decision is not about your product. Thank you for the work so far. | Yenileme günümüz geldi ama bu yıl devam etmiyoruz: harcamalarımızı kısıyoruz.<br><br>Karar ürününüzle ilgili değil. Bugüne kadarki emeğiniz için teşekkür ederiz. |
| `leave.mail.body_acquired` | Ayrılan hesabın maili · gövde, şirket satın alındı | Our company has been bought, and the new owners run their own systems. So we are not renewing our contract.<br><br>The decision is not about your product. | Şirketimiz satın alındı ve yeni sahiplerimiz kendi sistemlerini kullanıyor. Bu yüzden sözleşmemizi yenilemiyoruz.<br><br>Karar ürününüzle ilgili değil. |
| `leave.mail.body_closed` | Ayrılan hesabın maili · gövde, şirket kapanıyor | We are closing the company, so we will not renew.<br><br>We were glad to work with your product. Thank you. | Şirketimizi kapatıyoruz; sözleşmemizi yenilemeyeceğiz.<br><br>Ürününüzle çalışmaktan memnunduk. Teşekkür ederiz. |
| `leave.mail.body_satisfaction` | Ayrılan hesabın maili · gövde, memnuniyet eşiğin altında | Our renewal date has come and we have decided not to continue. What wore on us most these past months: {reasons}.<br><br>We are moving to {rival}. | Yenileme günümüz geldi ve devam etmeme kararı aldık. Son aylarda bizi en çok yoran şunlar oldu: {reasons}.<br><br>{rival} ile devam ediyoruz. |
| `accounts.status_may_leave_tip` | HESAPLAR · Ayrılabilir etiketinin ipucu | Satisfaction is under the bar. If it stays there, they leave at the renewal on {date}. | Memnuniyeti eşiğin altında. Böyle kalırsa {date} tarihindeki yenilemede ayrılır. |
| `accounts.renew_tip` | HESAPLAR · Yenileme hücresinin ipucu | Renews {date}. Seats follow the company's size that day; the price stays the same. | Yenileme {date}. Koltuk o gün şirketin büyüklüğüne göre yeniden bakılır; fiyat aynı kalır. |
| `renew.rep.subject` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.rep.opening` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.rep.opening_one` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.rep.opening_overflow` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.rep.group_raise` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.rep.group_same` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.rep.group_discount` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.rep.group_last` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.rep.group_leaving` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.list_more` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.rep.opt_as_agreed` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.rep.opt_hold_price` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.rep.expired` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.chip_raise` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.chip_discount` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.chip_leaves` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.chip_reluctant` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.outcome_seats_up` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.outcome_seats_down` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.outcome_switch` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.outcome_budget` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.outcome_budget_leave` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.result.subject` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.result.columns` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.result.not_renewing` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.result.total` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.news_frame` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.news_raise` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.news_same` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.news_discount` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.news_seats_up` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.news_seats_down` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.founder.subject` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.founder.body` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.founder.row` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.founder.more` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.founder.opt_raise` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.founder.opt_same` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.founder.opt_mixed` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.founder.opt_hand` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.founder.lock_hand` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.founder.lock_mixed` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.founder.expired` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.answers.subject` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.answer_raise` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.answer_same` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.answer_discount` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.answer_counter_same` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.answer_counter_discount` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.answer_leaving` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.answer_seats_up` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.answer_seats_down` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.answer_switch` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.answer_budget` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.answer_budget_leave` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.counter.title` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.counter.body` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.counter.opt_accept` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.counter.opt_split` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.counter.opt_hold` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.counter.expired` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.log_budget` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.log_switch` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.tip` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.tip_remaining` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.tip_remaining_one` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.tip_owner` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `renew.tip_owner_you` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in renew.*'ı; ve 'Yenileme kâğıdı, ayda bir kâğıt' ile 'Yenileme tutum bantları' satırları: kâğıt, zam ve karşı teklif yok, sonuç haftalık özette (yerine renewal.*, accounts.renew_tip). | |
| `budget_mail.subject` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in budget_mail.*'ı; ve 'Bütçe kesintisinde memnun hesabın koltuğu yarıya inmesi' satırı (yerine leave.mail.*). | |
| `budget_mail.body_keep` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in budget_mail.*'ı; ve 'Bütçe kesintisinde memnun hesabın koltuğu yarıya inmesi' satırı (yerine leave.mail.*). | |
| `budget_mail.body_leave` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in budget_mail.*'ı; ve 'Bütçe kesintisinde memnun hesabın koltuğu yarıya inmesi' satırı (yerine leave.mail.*). | |
| `sector.trend_growing` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in sector.trend_*'ı; ve '13 sektörün eğilim tablosu' satırı: gidiş hesap başına (accounts.trend_*). | |
| `sector.trend_steady` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in sector.trend_*'ı; ve '13 sektörün eğilim tablosu' satırı: gidiş hesap başına (accounts.trend_*). | |
| `sector.trend_flat` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in sector.trend_*'ı; ve '13 sektörün eğilim tablosu' satırı: gidiş hesap başına (accounts.trend_*). | |
| `sat.term_raise` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in sat.term_raise/reluctant'ı; ve 'Durum terimleri zam −2 ve gönülsüz yenileme −6' satırı. | |
| `sat.term_reluctant` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in sat.term_raise/reluctant'ı; ve 'Durum terimleri zam −2 ve gönülsüz yenileme −6' satırı. | |

## C5-2

| id | Yer | EN | TR |
|---|---|---|---|
| `cond.mail.subject` | Yenileme şartı maili · konu (mail bütçesinde önce gelir) | Our condition for renewal: {module} | Yenileme şartımız: {module} |
| `cond.mail.body` | Yenileme şartı maili · gövde (yenilemeden 8 hafta önce) | Our contract renews on {date}. {module} is behind what others in the market offer, and we need it at level {wanted}.<br><br>We are renewing on that condition. If {module} reaches level {wanted} by {deadline}, nothing changes. If it does not, we will send our notice that day. | Sözleşmemiz {date} tarihinde yenileniyor. Rakiplerde olan {module} sizde zayıf kaldı; bizim için {wanted} seviyesinde olması gerekiyor.<br><br>Bu şartla yeniliyoruz. {deadline} tarihine kadar {module} {wanted} seviyesine gelirse her şey sürer. Gelmezse o gün fesih bildirimimizi göndeririz. |
| `cond.notice_mail.subject` | Şart karşılanmadı · fesih bildirimi maili · konu | The condition was not met | Şartımız karşılanmadı |
| `cond.notice_mail.body` | Şart karşılanmadı · fesih bildirimi maili · gövde | The condition we set at renewal was not met by {deadline}: {module} is still at {ours}, and we asked for {wanted}. So we are ending our contract on {end}.<br><br>If {module} reaches level {wanted} before then, we will take our decision back. | Yenilemede koştuğumuz şart {deadline} tarihine kadar karşılanmadı: {module} hâlâ {ours} seviyesinde, istediğimiz {wanted}. Bu yüzden sözleşmemizi {end} tarihinde sonlandırıyoruz.<br><br>O tarihe kadar {module} {wanted} seviyesine gelirse kararımızı geri alırız. |
| `cond.met_mail.subject` | Şart karşılandı maili · konu | Our condition is met | Şartımız karşılandı |
| `cond.met_mail.body` | Şart karşılandı maili · gövde | {module} has reached the level we asked for. We are lifting our condition, and the contract carries on as it was. | {module} istediğimiz seviyeye geldi. Şartımızı kaldırıyoruz; sözleşmemiz olduğu gibi sürüyor. |
| `cond.withdraw_body` | Fesih bildiriminin geri alınması · gövde (konu SALES_CLAUSE_WITHDRAW_SUBJECT) | {module} has reached the level we asked for. We are withdrawing our notice, and the contract continues. | {module} istediğimiz seviyeye geldi. Fesih bildirimimizi geri alıyoruz; sözleşmemiz sürüyor. |
| `cond.log_ended` | Satış günlüğü · şart yüzünden biten sözleşme | {company} · contract ended · condition: {module} | {company} · sözleşme feshedildi · şart: {module} |
| `sat.term_condition` | Memnuniyet ipucu · defter satırı · şart (tutarsız bilgi satırı) | Condition: {module} {wanted} · deadline {deadline} | Şart: {module} {wanted} · son gün {deadline} |
| `accounts.status_conditional` | HESAPLAR ve hesap kartı · Durum etiketi, şart açık | Conditional · {deadline} | Şartlı · {deadline} |

## C6-1

| id | Yer | EN | TR |
|---|---|---|---|
| `req.mail.subject` | İstek maili (müşteri) · konu | A request from us: {module} | Bir isteğimiz var: {module} |
| `req.mail.body_new` | İstek maili (müşteri) · gövde, yeni modül (genişleme) | Our company has grown, and we now need {module} as well. Once it reaches level {level} in your product we will start using it; we know our seat price goes up with it. | Şirketimiz büyüdü ve artık {module} modülüne de ihtiyacımız var. Ürününüzde {level} seviyesine geldiğinde onu da kullanmaya başlarız; koltuk fiyatımızın buna göre artacağını biliyoruz. |
| `req.mail.body_depth` | İstek maili (müşteri) · gövde, kullandığı modülde derinlik | We would like {module} at level {level}; that level is already out there in the market. If it comes, we will put it to work straight away. | Kullandığımız {module} modülünü {level} seviyesinde görmek istiyoruz; piyasada bu seviye artık var. Gelirse hemen kullanırız. |
| `req.mail.body_gap` | İstek maili (müşteri) · gövde, memnun 3★+ hesabın bir adımlık açığı | {module} on your side is a step behind what others offer. It would help a great deal if it arrived before our renewal on {date}; we are not making it a condition. | Rakiplerde olan {module} seviyesi sizde bir adım geride. {date} tarihindeki yenilememizden önce gelirse çok işimize yarar; bunu şart koşmuyoruz. |
| `req.rep.subject` | İstek maili (müşteri temsilcisi) · konu | Request: {company} · {module} | İstek: {company} · {module} |
| `req.rep.body_new` | İstek maili (temsilci) · gövde, yeni modül | {company} has grown and wants to add {module}. Once it reaches level {level} they will start using it, and their seat price goes up with it. | {company} büyüdü ve {module} modülünü de eklemek istiyor. {level} seviyesine gelince kullanmaya başlayacaklar; koltuk fiyatları da buna göre artar. |
| `req.rep.body_depth` | İstek maili (temsilci) · gövde, derinlik | {company} wants {module} at level {level}. That level is already out there in the market. | {company}, {module} modülünü {level} seviyesinde istiyor. Bu seviye piyasada artık var. |
| `req.rep.body_gap` | İstek maili (temsilci) · gövde, bir adımlık açık | {company} says our {module} is a step behind what others offer. They would like it before their renewal on {date}, but they are not making it a condition. | {company}, {module} modülümüzün rakiplerden bir adım geride olduğunu söylüyor. {date} tarihindeki yenilemeden önce gelmesini istiyorlar ama şart koşmuyorlar. |
| `req.card_row` | Ürün · SPRINT · modül kartında birleşen istek satırı · şartlı hesap var | {module} {level} · {count} accounts want it · {conditional} conditional · {mrr} a month | {module} {level} · {count} hesap istiyor · şartlı {conditional} · ayda {mrr} |
| `req.card_row_one` | Ürün · SPRINT · modül kartında birleşen istek satırı · şartlı hesap var, tek hesap | {module} {level} · {count} account wants it · {conditional} conditional · {mrr} a month | {module} {level} · {count} hesap istiyor · şartlı {conditional} · ayda {mrr} |
| `req.card_row_plain` | Ürün · SPRINT · modül kartında birleşen istek satırı · şartlı hesap yok | {module} {level} · {count} accounts want it · {mrr} a month | {module} {level} · {count} hesap istiyor · ayda {mrr} |
| `req.card_row_plain_one` | Ürün · SPRINT · modül kartında birleşen istek satırı · şartlı hesap yok, tek hesap | {module} {level} · {count} account wants it · {mrr} a month | {module} {level} · {count} hesap istiyor · ayda {mrr} |
| `sat.term_request_waiting` | Memnuniyet ipucu · defter satırı · iki çeyrekten uzun bekleyen istek | Waiting on its request: {module} {level} · since {since} | İsteğini bekliyor: {module} {level} · {since} tarihinden beri |
| `renewal.expanded` | Haftalık satış özeti · istek teslim edildi, hesap modül ekledi | {company} added {module}: seat price {old} → {new} | {company}, {module} modülünü ekledi: koltuk fiyatı {old} → {new} |
| `weekly.more_voices` | Haftalık satış özeti · mail bütçesini aşan istek ve şartlar | {count} more accounts raised requests or conditions this week, all on the module cards. | Bu hafta {count} hesap daha istek ya da şart bildirdi; hepsi modül kartlarında. |
| `weekly.more_voices_one` | Haftalık satış özeti · aynı, tek hesap | {count} more account raised a request or condition this week; it is on the module cards. | Bu hafta {count} hesap daha istek ya da şart bildirdi; hepsi modül kartlarında. |
| `support.new_request` | Destek raporu · Bu hafta, yeni istek | New request: {company} wants {module} {level}. | Yeni istek: {company}, {module} {level} istiyor. |
| `req.card_body` | DÜŞTÜ | PLAN_C_P2 §6 'İsteğin Söz ver / Listeye al kesintisi, decline −4, süre −5' satırı: istek mail ve modül kartıyla gelir (yerine req.mail.*, req.card_row*). | |
| `req.card_title` | DÜŞTÜ | PLAN_C_P2 §6 'İsteğin Söz ver / Listeye al kesintisi, decline −4, süre −5' satırı: istek mail ve modül kartıyla gelir (yerine req.mail.*, req.card_row*). | |
| `req.opt_promise` | DÜŞTÜ | PLAN_C_P2 §6 'İsteğin Söz ver / Listeye al kesintisi, decline −4, süre −5' satırı: istek mail ve modül kartıyla gelir (yerine req.mail.*, req.card_row*). | |
| `req.opt_list` | DÜŞTÜ | PLAN_C_P2 §6 'İsteğin Söz ver / Listeye al kesintisi, decline −4, süre −5' satırı: istek mail ve modül kartıyla gelir (yerine req.mail.*, req.card_row*). | |
| `req.expire_note` | DÜŞTÜ | PLAN_C_P2 §6 'İsteğin Söz ver / Listeye al kesintisi, decline −4, süre −5' satırı: istek mail ve modül kartıyla gelir (yerine req.mail.*, req.card_row*). | |

## C6-2

| id | Yer | EN | TR |
|---|---|---|---|
| `ov.request_b2b` | Genel Bakış · İstekler bloğu · modül toplamı satırı | {module} {level} · {count} accounts · {mrr} a month | {module} {level} · {count} hesap · ayda {mrr} |
| `ov.request_b2b_one` | Genel Bakış · İstekler bloğu · tek hesap | {module} {level} · {count} account · {mrr} a month | {module} {level} · {count} hesap · ayda {mrr} |
| `ov.condition_strip` | Genel Bakış · şart şeridi | Conditional renewals: {count} accounts · {modules} | Şartlı yenileme: {count} hesap · {modules} |
| `ov.condition_strip_one` | Genel Bakış · şart şeridi, tek hesap | Conditional renewal: {count} account · {modules} | Şartlı yenileme: {count} hesap · {modules} |

## C3a-1

| id | Yer | EN | TR |
|---|---|---|---|
| `sat.term_discount` | Memnuniyet ipucu · elde tutma indiriminin durum terimi (+8) | Discount to keep them | Kalmaları için indirim |
| `sat.term_update_age` | DÜŞTÜ | PLAN_C_P2 §6 'Güncelleme yaşı (26 hafta, −1 / 4 hafta, iki vurgu alanı)' satırı: ayrı sürüm ritmi cezası yok (KARARLAR:124, SENTEZ:53, :891). | |
| `sat.update_age_note` | DÜŞTÜ | PLAN_C_P2 §6 'Güncelleme yaşı (26 hafta, −1 / 4 hafta, iki vurgu alanı)' satırı: ayrı sürüm ritmi cezası yok (KARARLAR:124, SENTEZ:53, :891). | |
| `sat.update_age_reset` | DÜŞTÜ | PLAN_C_P2 §6 'Güncelleme yaşı (26 hafta, −1 / 4 hafta, iki vurgu alanı)' satırı: ayrı sürüm ritmi cezası yok (KARARLAR:124, SENTEZ:53, :891). | |

## C3a-2

| id | Yer | EN | TR |
|---|---|---|---|
| `module.finance.name` | Ürün · Çekirdek · modül adı (PROD_LINE_ERP_LEDGER) | Finance and Accounting | Finans ve Muhasebe |
| `module.finance.k1.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_LEDGER_K1) | Basic Bookkeeping | Ön Muhasebe |
| `module.finance.k1.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_LEDGER_K1_DESC) | Income, expense and every cash movement are filed by date; when the day closes, the balance is known. | Gelir, gider ve her kasa hareketi tarih sırasıyla kaydedilir; gün kapanınca bakiye bellidir. |
| `module.finance.k2.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_LEDGER_K2) | Chart of Accounts | Hesap Planı |
| `module.finance.k2.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_LEDGER_K2_DESC) | Every movement falls into an account, and receivables and debts sit side by side with their due dates. | Her hareket bir hesaba düşer; alacaklar ve borçlar vadeleriyle yan yana durur. |
| `module.finance.k3.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_LEDGER_K3) | Cash Forecast | Nakit Öngörüsü |
| `module.finance.k3.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_LEDGER_K3_DESC) | The bank statement is matched to the books overnight, and the rhythm of collections names the week the cash runs tight. | Banka ekstresi gece defterle eşlenir; tahsilat ritmi okunur ve kasanın daralacağı hafta önceden söylenir. |
| `module.purchasing.name` | Ürün · Çekirdek · modül adı (PROD_LINE_ERP_INTAKE) | Purchasing | Satın Alma |
| `module.purchasing.k1.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_INTAKE_K1) | Purchase Orders | Sipariş Formu |
| `module.purchasing.k1.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_INTAKE_K1_DESC) | Every order to a supplier leaves from one form, and what was asked for, from whom and at what price stays on record. | Tedarikçiye giden her sipariş tek formdan çıkar; ne, kimden, hangi fiyata istendiği kayıtta kalır. |
| `module.purchasing.k2.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_INTAKE_K2) | Supplier Records | Tedarikçi Kartı |
| `module.purchasing.k2.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_INTAKE_K2_DESC) | Each supplier's prices, delivery times and past orders sit on one card, and quotes are laid side by side. | Her tedarikçinin fiyatı, teslim süresi ve geçmiş siparişleri tek kartta durur; teklifler yan yana konur. |
| `module.purchasing.k3.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_INTAKE_K3) | Document Reading | Belge Okuma |
| `module.purchasing.k3.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_INTAKE_K3_DESC) | The supplier's invoice and delivery note are scanned and matched to the order on their own; a person only signs off what does not agree. | Tedarikçinin faturası ve irsaliyesi taranır, siparişle kendiliğinden eşlenir; insana yalnız tutmayanı onaylamak kalır. |
| `module.hr.name` | Ürün · Çekirdek · modül adı (önerilen anahtar PROD_LINE_ERP_HR) | HR and Payroll | İK ve Bordro |
| `module.hr.k1.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_HR_K1) | Staff Records | Personel Kartı |
| `module.hr.k1.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_HR_K1_DESC) | Each employee's start date, salary and leave live on one card, and the filing cabinet finally closes. | Her çalışanın giriş tarihi, maaşı ve izni tek kartta tutulur; dosya dolabı kapanır. |
| `module.hr.k2.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_HR_K2) | Payroll Run | Bordro |
| `module.hr.k2.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_HR_K2_DESC) | Salaries, deductions and bonuses are worked out in one run at month end, and payroll goes out ready for the bank. | Maaş, kesinti ve prim ay sonunda tek seferde hesaplanır; bordro bankaya hazır çıkar. |
| `module.hr.k3.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_HR_K3) | Shift Planning | Vardiya Planı |
| `module.hr.k3.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_HR_K3_DESC) | Shifts, leave and overtime share one calendar, and who will be where is known weeks ahead. | Vardiya, izin ve fazla mesai aynı takvimde planlanır; kimin nerede olacağı haftalar önceden bellidir. |
| `module.production.name` | Ürün · Çekirdek · modül adı (önerilen anahtar PROD_LINE_ERP_PRODUCTION) | Production | Üretim |
| `module.production.k1.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_PRODUCTION_K1) | Bill of Materials | Ürün Ağacı |
| `module.production.k1.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_PRODUCTION_K1_DESC) | What each product is made of, part by part and count by count, is written down, and the recipe leaves the foreman's head. | Her ürünün hangi parçadan kaçar adet yapıldığı yazılır; reçete ustabaşının aklından çıkar. |
| `module.production.k2.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_PRODUCTION_K2) | Material Planning | Malzeme Planı |
| `module.production.k2.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_PRODUCTION_K2_DESC) | The plan works back from the orders, and which part will run short, and when, shows up in advance. | Plan siparişlerden geriye doğru kurulur; hangi parçanın ne zaman eksileceği önceden görünür. |
| `module.production.k3.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_PRODUCTION_K3) | Batch Tracing | Parti İzleme |
| `module.production.k3.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_PRODUCTION_K3_DESC) | Every batch carries the raw material and the machine it came from, so a complaint is traced within the hour. | Her parti hangi hammaddeden, hangi makineden çıktığını taşır; şikâyet gelince kaynağı bir saatte bulunur. |
| `module.warehouse.name` | Ürün · Çekirdek · modül adı (önerilen anahtar PROD_LINE_ERP_WAREHOUSE) | Warehouse and Shipping | Depo ve Sevkiyat |
| `module.warehouse.k1.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_WAREHOUSE_K1) | Dispatch Notes | Sevk İrsaliyesi |
| `module.warehouse.k1.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_WAREHOUSE_K1_DESC) | Everything that leaves goes out with a dispatch note, and which truck it is on stays on record. | Çıkan her mal bir irsaliyeyle yola çıkar; hangi kamyonda olduğu kayıtta durur. |
| `module.warehouse.k2.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_WAREHOUSE_K2) | Pick Lists | Toplama Listesi |
| `module.warehouse.k2.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_WAREHOUSE_K2_DESC) | Orders turn into a pick list in shelf order, and nobody walks the same aisle twice. | Siparişler raf sırasıyla toplama listesine döner; depocu aynı koridordan iki kez geçmez. |
| `module.warehouse.k3.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_WAREHOUSE_K3) | Carrier Link | Taşıyıcı Bağlantısı |
| `module.warehouse.k3.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_WAREHOUSE_K3_DESC) | The carrier's system is plugged in; labels print themselves, and the customer sees where the parcel is without calling. | Taşıyıcının sistemi bağlanır; etiket kendiliğinden basılır, müşteri paketin nerede olduğunu aramadan görür. |
| `module.channels.name` | Ürün · Çekirdek · modül adı (önerilen anahtar PROD_LINE_ERP_CHANNELS) | Store and Channels | Mağaza ve Kanal |
| `module.channels.k1.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_CHANNELS_K1) | Till | Kasa Ekranı |
| `module.channels.k1.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_CHANNELS_K1_DESC) | A sale in the shop is rung up at the till and comes off the stock in the same moment. | Mağazadaki satış kasada kaydedilir ve aynı anda stoktan düşer. |
| `module.channels.k2.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_CHANNELS_K2) | Branch Network | Şube Ağı |
| `module.channels.k2.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_CHANNELS_K2_DESC) | Every branch's sales gather in one place, and which shop ran out of what is known by evening. | Bütün şubelerin satışı tek merkezde toplanır; hangi mağazada neyin bittiği akşam bellidir. |
| `module.channels.k3.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_CHANNELS_K3) | Multichannel Orders | Çok Kanallı Sipariş |
| `module.channels.k3.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_CHANNELS_K3_DESC) | Shop, website and phone orders fall into one queue, and the same item is never sold twice. | Mağaza, web sitesi ve telefon siparişi aynı kuyruğa düşer; aynı ürün iki kez satılmaz. |
| `module.projects.name` | Ürün · Çekirdek · modül adı (önerilen anahtar PROD_LINE_ERP_PROJECTS) | Projects and Time | Proje ve Zaman |
| `module.projects.k1.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_PROJECTS_K1) | Timesheets | Zaman Çizelgesi |
| `module.projects.k1.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_PROJECTS_K1_DESC) | Everyone notes which job their hours went to, and by the end of the week it is plain who worked on what. | Herkes saatini hangi işe harcadığını yazar; hafta bitince kimin neyle uğraştığı görünür. |
| `module.projects.k2.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_PROJECTS_K2) | Job Costing | İş Maliyeti |
| `module.projects.k2.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_PROJECTS_K2_DESC) | Hours and expenses are tied to the project, and which jobs make money is known before they are delivered. | Saatler ve harcamalar projeye bağlanır; hangi işin para kazandırdığı teslimden önce bellidir. |
| `module.projects.k3.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_PROJECTS_K3) | Progress Billing | Hakediş Faturası |
| `module.projects.k3.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_PROJECTS_K3_DESC) | The finished part of the job is measured and turned into an invoice, and the client pays as the work moves. | İşin biten kısmı ölçülür ve faturaya döner; müşteri iş ilerledikçe öder. |
| `module.assets.name` | Ürün · Çekirdek · modül adı (önerilen anahtar PROD_LINE_ERP_ASSETS) | Assets and Maintenance | Varlık ve Bakım |
| `module.assets.k1.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_ASSETS_K1) | Asset Register | Demirbaş Listesi |
| `module.assets.k1.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_ASSETS_K1_DESC) | Every machine, vehicle and building sits on one register, with where it stands and when it was bought. | Her makine, araç ve bina tek listede, nerede durduğu ve ne zaman alındığıyla tutulur. |
| `module.assets.k2.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_ASSETS_K2) | Maintenance Schedule | Bakım Takvimi |
| `module.assets.k2.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_ASSETS_K2_DESC) | Equipment due for service warns ahead of time, and the technician is called before anything breaks. | Bakımı yaklaşan ekipman önceden uyarır; arıza beklenmeden servis çağrılır. |
| `module.assets.k3.name` | Ürün · modül kademesi · kart adı (PROD_STEP_ERP_ASSETS_K3) | Field Work Orders | Saha İş Emri |
| `module.assets.k3.desc` | Ürün · modül kademesi · kart açıklaması (PROD_STEP_ERP_ASSETS_K3_DESC) | A fault report lands on the field technician's phone, and parts, hours and the signature are closed from there. | Arıza kaydı sahadaki teknisyenin telefonuna düşer; parça, saat ve imza oradan kapanır. |
| `module.stock.name` | Ürün · Çekirdek · modül adı (PROD_LINE_ERP_STOCK) | Stock | Stok |
| `module.invoicing.name` | Ürün · Çekirdek · modül adı (PROD_LINE_ERP_INVOICING) | Invoicing | Fatura |
| `sat.term_bugs` | Memnuniyet ipucu · açık hata satırı | Open bugs ({count} in its modules and the shared lines) | Açık hata (kullandığı modüllerde ve ortak hatlarda {count}) |

## C3a-3

| id | Yer | EN | TR |
|---|---|---|---|
| `sat.term_base` | Memnuniyet ipucu · defter satırı · taban (ürün terimi kalkınca ilk satır) | Base for a product that does the job | İşini gören ürünün tabanı |
| `sat.term_obsolete` | Memnuniyet ipucu · defter satırı · eskime (hesabın istediği standart ya da altı: 1★-3★) | {module} stuck at {ours}, rivals have {theirs} | {module} {ours} seviyesinde kaldı, rakiplerde {theirs} |
| `sat.term_obsolete_top` | Memnuniyet ipucu · defter satırı · eskime (hesabın istediği standardın üstü: 4★-5★) | {module} stuck at {ours}, the best rivals have {theirs} | {module} {ours} seviyesinde kaldı, en iyi rakiplerde {theirs} |
| `sat.term_fit` | DÜŞTÜ | PLAN_C_P2 §6 'Sektör TABLE, emphasis, ... market_ref, account_fit' satırı: ürün uyumu terimi kalkar; yerine sat.term_base ve eskime satırı (C3a-3, Sessiz 6). | |
| `sat.renewal_reading` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in sat.renewal_reading, sat.term_market_moved'u; ve 'market_ref tetikleyicisinin yenileme açılışına taşınması' satırı (market_ref kalkar). | |
| `sat.term_market_moved` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in sat.renewal_reading, sat.term_market_moved'u; ve 'market_ref tetikleyicisinin yenileme açılışına taşınması' satırı (market_ref kalkar). | |

## C3b-1

| id | Yer | EN | TR |
|---|---|---|---|
| `loss.say_key_missing` | Kurucu görüşmesi · kayıp nedeni (müşterinin cümlesi); satış uzmanının kayıp mailinde {quote} olarak alıntılanır | {module} matters most to us, and you do not have it at all. We cannot buy without it. | {module} bizim için en önemlisi ve sizde hiç yok. Onsuz alamayız. |
| `loss.say_key_short` | Kurucu görüşmesi · kayıp nedeni (müşterinin cümlesi); satış uzmanının kayıp mailinde {quote} olarak alıntılanır | {module} matters most to us, and yours is not at the level we need. | {module} bizim için önemli, sizde istediğimiz seviyede değil. |
| `loss.say_module` | Kurucu görüşmesi · kayıp nedeni (müşterinin cümlesi); satış uzmanının kayıp mailinde {quote} olarak alıntılanır | Your {module} falls short of what we need. We cannot buy it as it is. | {module} sizde istediğimizin gerisinde. Bu hâliyle alamayız. |
| `loss.say_deeper` | Kurucu görüşmesi · kayıp nedeni (müşterinin cümlesi); satış uzmanının kayıp mailinde {quote} olarak alıntılanır | {rival} goes further on {module}. We are going with them. | {module} tarafında {rival} daha ileride. Onlarla devam ediyoruz. |
| `loss.say_rep` | Kurucu görüşmesi · kayıp nedeni (müşterinin cümlesi); satış uzmanının kayıp mailinde {quote} olarak alıntılanır | For a purchase this size we wanted someone more seasoned across the table. | Bu ölçekte bir alım için karşımızda daha deneyimli birini görmek isterdik. |
| `loss.say_price` | Kurucu görüşmesi · kayıp nedeni (müşterinin cümlesi); satış uzmanının kayıp mailinde {quote} olarak alıntılanır | {rival} offered {their_price} a seat. You are asking {our_price}. | {rival} koltuk başına {their_price} verdi, siz {our_price} istiyorsunuz. |
| `loss.say_cold` | Kurucu görüşmesi · kayıp nedeni (müşterinin cümlesi); satış uzmanının kayıp mailinde {quote} olarak alıntılanır | This took too long. We have gone another way. | Bu iş çok uzadı. Başka bir yola girdik. |
| `loss.winner` | Kurucu görüşmesi · kayıp panelinin ikinci satırı | Went with {rival} | Seçtikleri: {rival} |
| `loss.rep_body` | Satış uzmanının kayıp maili · gövde (haftada en çok bir; konu SALES_REP_LOST_TITLE kalır) | Boss, I could not close {company}. In the last meeting they told me: "{quote}" {rival} took the contract. | Patron, {company} ile anlaşamadım. Son görüşmede şunu söylediler: "{quote}" Sözleşmeyi {rival} aldı. |
| `loss.row` | Haftalık satış özeti · kayıp satırı (mail bütçesini aşan kayıplar) | {company}: lost · {reason} · {rival} won | {company}: kaçtı · {reason} · {rival} kazandı |
| `loss.row_key` | Haftalık satış özeti · kayıp nedeni parçası (loss.row içinde, küçük harf) | key module {module} falls short | önemli modülleri {module} eksik |
| `loss.row_module` | Haftalık satış özeti · kayıp nedeni parçası (loss.row içinde, küçük harf) | {module} falls short | {module} eksik |
| `loss.row_deeper` | Haftalık satış özeti · kayıp nedeni parçası (loss.row içinde, küçük harf) | the rival goes further on {module} | {module} tarafında rakip ileride |
| `loss.row_rep` | Haftalık satış özeti · kayıp nedeni parçası (loss.row içinde, küçük harf) | the rep's experience fell short ({rep_stars} rep, {account_stars} account) | satış uzmanının deneyimi yetmedi ({rep_stars} uzman, {account_stars} hesap) |
| `loss.row_price` | Haftalık satış özeti · kayıp nedeni parçası (loss.row içinde, küçük harf) | price, {their_price} against our {our_price} | fiyat: onlar {their_price}, biz {our_price} |
| `loss.row_cold` | Haftalık satış özeti · kayıp nedeni parçası (loss.row içinde, küçük harf) | they went cold | aday soğudu |
| `probe.key_question` | Kurucu görüşmesi · önemli modül sorusu (genel; sektöre özel cümle yoksa) | What matters most to us is {module}. What do you have there? | Bizim için en önemlisi {module}. Bu tarafta neyiniz var? |
| `probe.answer_ready` | Kurucu görüşmesi · önemli modül sorusu · cevap, modül istenen seviyede | {module} is ready. I can show you. | {module} hazır. Size gösterebilirim. |
| `probe.answer_admit` | Kurucu görüşmesi · önemli modül sorusu · cevap, modül eksik | {module} is not where you want it yet. I will show you where it stands. | {module} henüz istediğiniz yerde değil. Bugünkü hâlini olduğu gibi gösteririm. |
| `probe.lock_not_ready` | Kurucu görüşmesi · önemli modül sorusu · 'hazır' cevabının kilit gerekçesi | {module} does not back that up yet. | {module} bunu henüz desteklemiyor. |
| `probe.key.manufacturing_production` | Kurucu görüşmesi · önemli modül sorusu · sektöre özel (sektör, önemli modül) | Everything starts on the line for us. Can {module} carry the bill of materials and plan? | Bizde her şey hattın başında başlar. {module} ürün ağacını ve planı taşıyabiliyor mu? |
| `probe.key.textile_stock` | Kurucu görüşmesi · önemli modül sorusu · sektöre özel (sektör, önemli modül) | We live on sizes and colours. Can {module} keep every size and colour apart? | Bizim işimiz beden ve renk. {module} her bedeni ve rengi ayrı tutabiliyor mu? |
| `probe.key.logistics_warehouse` | Kurucu görüşmesi · önemli modül sorusu · sektöre özel (sektör, önemli modül) | Our day is loading and unloading. Can {module} tell us what goes on which truck? | Bizim işimiz yükleme. {module} hangi malın hangi kamyonda olduğunu söyleyebiliyor mu? |
| `probe.key.logistics_assets` | Kurucu görüşmesi · önemli modül sorusu · sektöre özel (sektör, önemli modül) | Our fleet is on the road all day. Can {module} keep track of every vehicle's servicing? | Filomuz bütün gün yolda. {module} her aracın bakımını takip edebiliyor mu? |
| `probe.key.retail_channels` | Kurucu görüşmesi · önemli modül sorusu · sektöre özel (sektör, önemli modül) | We have branches all over the city. Can {module} bring every shop's till into one place? | Şehrin her yanında şubemiz var. {module} bütün kasaları tek yerde toplayabiliyor mu? |
| `probe.key.ecommerce_channels` | Kurucu görüşmesi · önemli modül sorusu · sektöre özel (sektör, önemli modül) | Orders come in through every channel, night and day. Can {module} put them in one queue? | Sipariş her kanaldan gece gündüz gelir. {module} hepsini tek kuyruğa alabiliyor mu? |
| `probe.key.technology_invoicing` | Kurucu görüşmesi · önemli modül sorusu · sektöre özel (sektör, önemli modül) | Our customers pay us monthly. Can {module} run subscription billing on its own? | Müşterilerimiz bize aylık ödüyor. {module} abonelik faturasını kendi kesebiliyor mu? |
| `probe.key.legal_projects` | Kurucu görüşmesi · önemli modül sorusu · sektöre özel (sektör, önemli modül) | We bill by the hour. Can {module} go from the timesheet straight to the invoice? | Biz saatle fatura keseriz. {module} zaman çizelgesinden faturaya gidebiliyor mu? |
| `probe.key.media_projects` | Kurucu görüşmesi · önemli modül sorusu · sektöre özel (sektör, önemli modül) | Every production is its own project. Can {module} show what each one cost us? | Her yapım ayrı bir proje. {module} hangisinin bize kaça mal olduğunu gösterebiliyor mu? |
| `probe.key.finance_finance` | Kurucu görüşmesi · önemli modül sorusu · sektöre özel (sektör, önemli modül) | Our business is the numbers. Can {module} close the period without a single gap? | Bizim işimiz rakam. {module} dönemi tek bir açık bırakmadan kapatabiliyor mu? |
| `probe.key.insurance_finance` | Kurucu görüşmesi · önemli modül sorusu · sektöre özel (sektör, önemli modül) | Every policy is a payment on a date. Can {module} see each one coming? | Her poliçe bir tarihte bir ödeme demek. {module} hepsini önceden görebiliyor mu? |
| `probe.key.construction_projects` | Kurucu görüşmesi · önemli modül sorusu · sektöre özel (sektör, önemli modül) | Every site is a job of its own. Can {module} keep each project's costs apart? | Her şantiye ayrı bir iş. {module} her projenin maliyetini ayrı tutabiliyor mu? |
| `probe.key.real_estate_invoicing` | Kurucu görüşmesi · önemli modül sorusu · sektöre özel (sektör, önemli modül) | Hundreds of rent invoices go out every month. Can {module} raise them on its own? | Her ay yüzlerce kira faturası çıkıyor. {module} bunları kendi kesebiliyor mu? |
| `probe.key.health_stock` | Kurucu görüşmesi · önemli modül sorusu · sektöre özel (sektör, önemli modül) | We hold medicine and supplies. Does {module} track batch numbers and expiry dates? | İlaç ve sarf malzemesi tutuyoruz. {module} parti ve son kullanma tarihini izliyor mu? |
| `sign.mail_line` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in sign.*'ı; ve 'İmza kapısı (eşik + 10)' satırı: P'de kesin kayıp ve kazanç yok (SENTEZ:393). | |
| `sign.mail_line_clean` | DÜŞTÜ | PLAN_C_P2 §6 son satırları: W1'in sign.*'ı; ve 'İmza kapısı (eşik + 10)' satırı: P'de kesin kayıp ve kazanç yok (SENTEZ:393). | |
| `loss.bugs_rep` | DÜŞTÜ | PLAN_C_P2 §6 'İmza kapısı (eşik + 10), sign_gate_reason, sign_single_loss' satırı; açık hata kayıp nedeni sırasında yok (SENTEZ:438-440). Yerine loss.say_* ve loss.row_*. | |
| `loss.bugs_meeting` | DÜŞTÜ | PLAN_C_P2 §6 'İmza kapısı (eşik + 10), sign_gate_reason, sign_single_loss' satırı; açık hata kayıp nedeni sırasında yok (SENTEZ:438-440). Yerine loss.say_* ve loss.row_*. | |
| `loss.bugs_summary_row` | DÜŞTÜ | PLAN_C_P2 §6 'İmza kapısı (eşik + 10), sign_gate_reason, sign_single_loss' satırı; açık hata kayıp nedeni sırasında yok (SENTEZ:438-440). Yerine loss.say_* ve loss.row_*. | |

## C3b-5

| id | Yer | EN | TR |
|---|---|---|---|
| `lead.sector_line` | Satış · aday kartı · sektör satırı | {sector} · {seat_count} seats | {sector} · {seat_count} koltuk |
| `lead.modules_head` | Satış · aday kartı · modül satırının başlığı | Modules wanted | İstediği modüller |
| `lead.module_row` | Satış · aday kartı · modül ve sözcük | {module} · {word} | {module} · {word} |
| `lead.word_at` | Satış · aday kartı · modül sözcüğü | at the level they want | istediği seviyede |
| `lead.word_one_short` | Satış · aday kartı · modül sözcüğü | one step short | bir adım eksik |
| `lead.word_far_short` | Satış · aday kartı · modül sözcüğü | far short | çok eksik |
| `lead.word_missing` | Satış · aday kartı · modül sözcüğü | not in our product | bizde yok |
| `lead.key` | Satış · aday kartı · önemli modül işareti | key | önemli |
| `lead.cooling` | Satış · aday kartı · süresinin iki katını aşan aday | Going cold | Soğuyor |
| `lead.lock_rep` | Satış · aday kartı · kilit gerekçesi, satış uzmanı iki yıldız altta | This account needs a sales rep of at least {stars}. | Bu hesap için en az {stars} satış uzmanı gerekir. |
| `lead.lock_founder` | Satış · aday kartı · kilit gerekçesi, kurucu iki yıldız altta | Closing this account takes at least {stars} in sales. | Bu hesabı kapatmak için satışta en az {stars} gerekir. |
| `lead.reach_above` | Satış · aday kartı · bir üst yıldız uyarısı (×0,6) | {name} is one star below this account | {name} bu hesabın bir yıldız altında |
| `account.staff_seats` | Satış · hesap kartı · büyüklük satırı | {staff} employees · {seat_count} seats | {staff} çalışan · {seat_count} koltuk |
| `account.modules_head` | Satış · hesap kartı · modül çiplerinin başlığı | Modules | Modüller |
| `account.renew_line` | Satış · hesap kartı · yenileme satırı | Renews {date} | Yenileme {date} |
| `sector.manufacturing` | Sektör adı (SECTOR_MANUFACTURING) · aday kartı ve HESAPLAR | Manufacturing | İmalat |

## C3b-4a

| id | Yer | EN | TR |
|---|---|---|---|
| `stance.low` | Satış · Fiyat duruşu seçicisi · duruş adı (SALES_STANCE_COMPETITIVE) | Low | Ucuz |
| `stance.high` | Satış · Fiyat duruşu seçicisi · duruş adı (SALES_STANCE_PREMIUM) | High | Pahalı |
| `stance.hint_low` | Satış · Fiyat duruşu seçicisi · tek satır açıklama (SALES_STANCE_HINT_COMPETITIVE) | Below the suggested price. More tables close, each for less. | Önerilen fiyatın altında. Daha çok masa kapanır, her biri daha az getirir. |
| `stance.hint_standard` | Satış · Fiyat duruşu seçicisi · tek satır açıklama (SALES_STANCE_HINT_STANDARD) | The suggested price, drawn from the modules wanted and how good they are. | Önerilen fiyat: istenen modüllerden ve onların kalitesinden çıkar. |
| `stance.hint_high` | Satış · Fiyat duruşu seçicisi · tek satır açıklama (SALES_STANCE_HINT_PREMIUM) | Above the suggested price. Fewer tables close, each for more. | Önerilen fiyatın üstünde. Daha az masa kapanır, her biri daha çok getirir. |
| `stance.caption_tip` | Satış · Fiyat duruşu seçicisi · başlığın ipucu (SALES_STANCE_CAPTION'ın altı) | Your sales reps quote with this stance on every offer. | Satış uzmanların her teklifte bu duruşla fiyat verir. |
| `price.suggested` | Satış · fiyat paneli · önerilen fiyat satırı | Suggested price: {price} a seat · {total} a month | Önerilen fiyat: koltuk başına {price} · ayda {total} |
| `price.reason_below` | Satış · fiyat paneli · tek satır gerekçe (fiyatı en çok çeken modül) | {module} is below the market: price {pct}% lower | {module} piyasanın altında: fiyat %{pct} düşük |
| `price.reason_above` | Satış · fiyat paneli · tek satır gerekçe | {module} is ahead of the market: price {pct}% higher | {module} piyasanın önünde: fiyat %{pct} yüksek |
| `price.reason_level` | Satış · fiyat paneli · tek satır gerekçe, kalite çarpanı 1 | Every module they want is at the market level | İstenen modüllerin hepsi piyasa seviyesinde |
| `price.rival_offer` | Satış · fiyat paneli · en güçlü rakibin standart teklifi | {rival} is offering {price} a seat | {rival} koltuk başına {price} teklif ediyor |
