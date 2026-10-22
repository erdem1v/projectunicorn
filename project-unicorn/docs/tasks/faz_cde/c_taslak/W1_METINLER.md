# W1 · Faz C yazım dalgası

Kaynak `W1_METINLER.json`; bu dosya `wcheck.py` ile üretilir, elle düzenlenmez.

## C1

| id | Yer | EN | TR |
|---|---|---|---|
| `ov.tab_overview` | Ürün penceresi · kâğıt şeridi (GENEL BAKIŞ \| SPRINT \| ÇEYREK) | Overview | Genel Bakış |
| `ov.locked` | Genel Bakış · v1.0'dan önce kilit satırı ve ipucu | Opens when v1.0 ships. | v1.0 yayınlanınca açılır. |
| `server.head` | Genel Bakış · Sunucu bloğu başlığı | Server | Sunucu |
| `server.tier_economy` | Sunucu bloğu · kademe seçici | Economy | Ekonomik |
| `server.tier_standard` | Sunucu bloğu · kademe seçici | Standard | Standart |
| `server.tier_enterprise` | Sunucu bloğu · kademe seçici | Enterprise | Kurumsal |
| `server.capacity_seats` | Sunucu bloğu · kapasite satırı (B2B) | Capacity {n} seats · {bill} a month | Kapasite {n} koltuk · ayda {bill} |
| `server.capacity_users` | Sunucu bloğu · kapasite satırı (B2C) | Capacity {n} users · {bill} a month | Kapasite {n} kullanıcı · ayda {bill} |
| `server.load_seats` | Sunucu bloğu · yük satırı (B2B) | Load {load}% · spare {spare} seats · {spare_cost} a month | Yük %{load} · boş pay {spare} koltuk · ayda {spare_cost} |
| `server.load_users` | Sunucu bloğu · yük satırı (B2C) | Load {load}% · spare {spare} users · {spare_cost} a month | Yük %{load} · boş pay {spare} kullanıcı · ayda {spare_cost} |
| `server.btn_decrease` | Sunucu bloğu · Azalt düğmesi | Decrease · {n} | Azalt · {n} |
| `server.btn_increase` | Sunucu bloğu · Artır düğmesi | Increase · {n} | Artır · {n} |
| `server.auto_toggle` | Sunucu bloğu · Otomatik ayarla anahtarı | Auto adjust | Otomatik ayarla |
| `server.tip_increase_seats` | Sunucu bloğu · Artır ipucu (B2B) | Add {n} seats · {old_cost} → {new_cost} a month · load {old_load}% → {new_load}% | {n} koltuk ekle · ayda {old_cost} → {new_cost} · yük %{old_load} → %{new_load} |
| `server.tip_increase_users` | Sunucu bloğu · Artır ipucu (B2C) | Add {n} users · {old_cost} → {new_cost} a month · load {old_load}% → {new_load}% | {n} kullanıcılık yer ekle · ayda {old_cost} → {new_cost} · yük %{old_load} → %{new_load} |
| `server.tip_decrease_seats` | Sunucu bloğu · Azalt ipucu (B2B) | Remove {n} seats · {old_cost} → {new_cost} a month · load {old_load}% → {new_load}% | {n} koltuk çıkar · ayda {old_cost} → {new_cost} · yük %{old_load} → %{new_load} |
| `server.tip_decrease_users` | Sunucu bloğu · Azalt ipucu (B2C) | Remove room for {n} users · {old_cost} → {new_cost} a month · load {old_load}% → {new_load}% | {n} kullanıcılık yer çıkar · ayda {old_cost} → {new_cost} · yük %{old_load} → %{new_load} |
| `server.tip_decrease_short` | Sunucu bloğu · Azalt ipucunun ikinci satırı, yük %100'ü geçecekse | Load becomes {load}%. Capacity falls short. | Yük %{load} olur. Kapasite yetmez. |
| `server.growth` | Sunucu bloğu · büyüme satırı (yalnız anahtar kapalıyken) | At this growth rate, load passes {edge}% in {weeks} weeks. | Bu büyüme hızıyla yük {weeks} hafta sonra %{edge} sınırını geçer. |
| `server.growth_one` | Sunucu bloğu · büyüme satırı, 1 hafta | At this growth rate, load passes {edge}% next week. | Bu büyüme hızıyla yük gelecek hafta %{edge} sınırını geçer. |
| `server.warn_high` | Sunucu bloğu · yük %90 üstü satırı (sarı) | Load {load}%. Above {edge}%, the chance of an outage is {mult} times higher. | Yük %{load}. Yük %{edge} üstündeyken kesinti ihtimali {mult} katına çıkar. |
| `server.warn_over` | Sunucu bloğu · yük %100 üstü satırı (kırmızı) | Load {load}%. Capacity falls short; the chance of an outage is {mult} times higher. | Yük %{load}. Kapasite yetmiyor; kesinti ihtimali {mult} katına çıkar. |
| `server.warn_none` | Sunucu bloğu · canlı ürün, kapasite 0 | The product is live with no capacity; the chance of an outage is {mult} times higher. | Ürün yayında ama kapasite yok; kesinti ihtimali {mult} katına çıkar. |
| `server.release_drop_seats` | Sürüm notu · ağır kademe kapasiteyi düşürdü (B2B) | With {version}, capacity fell from {old} seats to {new}. Load {old_load}% → {new_load}%. | {version} ile kapasite {old} koltuktan {new} koltuğa indi. Yük %{old_load} → %{new_load}. |
| `server.release_drop_users` | Sürüm notu · ağır kademe kapasiteyi düşürdü (B2C) | With {version}, capacity fell from room for {old} users to {new}. Load {old_load}% → {new_load}%. | {version} ile kapasite {old} kullanıcıdan {new} kullanıcıya indi. Yük %{old_load} → %{new_load}. |
| `server.auto_tip` | Sunucu bloğu · Otomatik ayarla ipucu | When on, capacity grows one step once load reaches {edge}%, bringing load to about {target}%. It never shrinks capacity; the cost of the spare room is shown in this block. | Açıkken yük %{edge} olunca kapasite bir adım büyür ve yük yaklaşık %{target} olur. Kapasiteyi küçültmez; boş payın parası bu blokta yazar. |
| `server.auto_last_seats` | Sunucu bloğu · son otomatik büyüme (yalnız anahtar açıkken, B2B) | Automatic increase {date} · {old} → {new} seats | Otomatik büyüme {date} · {old} → {new} koltuk |
| `server.auto_last_users` | Sunucu bloğu · son otomatik büyüme (B2C) | Automatic increase {date} · {old} → {new} users | Otomatik büyüme {date} · {old} → {new} kullanıcı |
| `server.tier_tip_price_seats` | Kademe ipucu · fiyat (B2B) | {price} a month per {unit} seats | {unit} koltuk başına ayda {price} |
| `server.tier_tip_price_users` | Kademe ipucu · fiyat (B2C) | {price} a month per {unit} users | {unit} kullanıcı başına ayda {price} |
| `server.tier_tip_outage` | Kademe ipucu · kesinti çarpanı (üç kademe) | Outage chance ×{mult} | Kesinti ihtimali ×{mult} |
| `server.tier_tip_reports` | Kademe ipucu · Ekonomik'in bildirim bedeli | {pct}% more bug reports | %{pct} daha fazla hata bildirimi |
| `server.tier_tip_no_enterprise` | Kademe ipucu · Ekonomik'te kurumsal hesap imzası | Enterprise customers will not sign on this tier | Kurumsal müşteriler bu kademeyle imza atmaz |
| `server.tier_tip_clause_no` | Kademe ipucu · Ekonomik ve Standart | Does not meet the enterprise contract clause | Kurumsal sözleşme şartını karşılamaz |
| `server.tier_tip_clause_yes` | Kademe ipucu · Kurumsal | Meets the enterprise contract clause | Kurumsal sözleşme şartını karşılar |
| `server.tier_preview` | Sunucu bloğu · kademe değiştirme önizlemesi | {from} → {to} · {old} → {new} a month | {from} → {to} · ayda {old} → {new} |
| `server.tier_switch` | Sunucu bloğu · önizlemenin onay düğmesi | Switch | Geç |
| `incident.load_line` | Kesinti kartı (incident_outage_b2b ve _b2c) · gövdenin son cümlesi, yalnız yük %90 üstündeyken | Server load was at {pct}% when it went down. | Çöktüğü sırada sunucu yükü %{pct} düzeyindeydi. |

## C2

| id | Yer | EN | TR |
|---|---|---|---|
| `fin.row_salaries` | Finans · gider dağılımı kalemi | Salaries | Maaşlar |
| `fin.row_overtime` | Finans · gider dağılımı kalemi | Overtime | Ek mesai |
| `fin.row_servers` | Finans · gider dağılımı kalemi | Servers | Sunucular |
| `fin.row_office` | Finans · gider dağılımı kalemi | Office | Ofis |
| `fin.row_marketing` | Finans · gider dağılımı kalemi | Marketing | Pazarlama |
| `fin.empty` | Finans · gider dağılımı, hiç kalem yokken | No expenses this month. | Bu ay gider yok. |
| `fin.office_tip` | Finans · Ofis kaleminin ipucu | {office} rent · {amount} a month | {office} kirası · ayda {amount} |

## C4

| id | Yer | EN | TR |
|---|---|---|---|
| `clause.strip` | Pazarlık onay şeridi · 3★ ve üstü, sunucu Kurumsal değilken | Contract clause: Enterprise server · within {weeks} weeks · {delta} more a month | Sözleşme maddesi: kurumsal sunucu · {weeks} hafta içinde · ayda {delta} fazla |
| `clause.label` | HESAPLAR · Durum etiketi, madde açık | Server clause · {date} | Sunucu maddesi · {date} |
| `clause.label_notice` | HESAPLAR · Durum etiketi, fesih bildirimi | Termination notice · {date} | Fesih bildirimi · {date} |
| `clause.waiting` | Genel Bakış · Sunucu bloğu, madde satırı (yalnız B2B) | {n} accounts waiting for Enterprise servers | Kurumsal sunucu bekleyen {n} hesap |
| `clause.waiting_one` | Genel Bakış · Sunucu bloğu, madde satırı, tek hesap | {n} account waiting for Enterprise servers | Kurumsal sunucu bekleyen {n} hesap |
| `clause.sender` | Kurumsal madde mailleri · gönderen satırı | {name} · {company}, IT | {name} · {company}, Bilgi İşlem |
| `clause.sign_mail.subject` | Kurumsal madde · imza maili konusu (satış masasının kapattığı anlaşma) | The server clause in our contract | Sözleşmedeki sunucu maddesi |
| `clause.sign_mail.body` | Kurumsal madde · imza maili gövdesi | As agreed in the contract, we expect our data to be kept on an enterprise grade server. We would like the move to be done by {date}. | Sözleşmede konuştuğumuz gibi verilerimizin kurumsal düzeyde bir sunucuda tutulmasını bekliyoruz. Taşımanın {date} tarihine kadar bitmesini rica ederiz. |
| `clause.notice_mail.subject` | Kurumsal madde · fesih bildirimi maili konusu | Ending our contract | Sözleşmemizin feshi |
| `clause.notice_mail.body` | Kurumsal madde · fesih bildirimi maili gövdesi | The enterprise server clause in our contract has not been met since {since}, so we are ending the contract on {end}. If our data is moved to an enterprise server before then, we will withdraw this notice. | Sözleşmemizdeki kurumsal sunucu maddesi {since} tarihinden beri karşılanmıyor. Bu yüzden sözleşmemizi {end} tarihinde sonlandırıyoruz. O tarihe kadar verilerimiz kurumsal sunucuya taşınırsa kararımızı geri alırız. |
| `clause.reserve_mail.subject` | Kurumsal madde · hakkını saklı tutan hesabın maili konusu | The server clause is still open | Sunucu maddesi hâlâ açık |
| `clause.reserve_mail.body` | Kurumsal madde · hakkını saklı tutan hesabın maili gövdesi | The enterprise server clause in our contract is still not met. We are carrying on for now, but we reserve the right to end the contract. | Sözleşmemizdeki kurumsal sunucu maddesi hâlâ karşılanmıyor. Şimdilik devam ediyoruz, ancak sözleşmeyi feshetme hakkımızı saklı tutuyoruz. |
| `clause.withdraw_mail.subject` | Kurumsal madde · bildirimin geri alınması maili konusu | We are withdrawing our notice | Fesih bildirimimizi geri alıyoruz |
| `clause.withdraw_mail.body` | Kurumsal madde · 4 hafta içinde Kurumsal'a geçilince | We see our data has been moved to an enterprise server. We are withdrawing our notice, and the contract continues. | Verilerimizin kurumsal sunucuya taşındığını gördük. Fesih bildirimimizi geri alıyoruz; sözleşmemiz sürüyor. |
| `clause.btn_switch` | Kurumsal madde mailleri ve toplantı çıkışı · geçiş düğmesi | Move to Enterprise · {old} → {new} a month | Kurumsal sunucuya geç · ayda {old} → {new} |
| `clause.downgrade_fact` | Sunucu bloğu · Kurumsal'dan inerken önizlemenin olgu satırı | The server clause of {n} accounts will no longer be met. | {n} hesabın sözleşmesindeki sunucu maddesi karşılanmaz olur. |
| `clause.downgrade_fact_one` | Sunucu bloğu · olgu satırı, tek hesap | The server clause of {n} account will no longer be met. | {n} hesabın sözleşmesindeki sunucu maddesi karşılanmaz olur. |
| `clause.log_ended` | Satış günlüğü · madde yüzünden biten sözleşme | {company} · contract ended · server clause | {company} · sözleşme feshedildi · sunucu maddesi |
| `sat.term_clause` | Memnuniyet ipucu · Kurumsal madde durum terimi (−10) | Enterprise server clause | Kurumsal sunucu maddesi |

## C5

| id | Yer | EN | TR |
|---|---|---|---|
| `renew.rep.subject` | Satışçı raporu (kâğıt) · başlık | {month} renewals | {month} yenilemeleri |
| `renew.rep.opening` | Satışçı raporu · açılış | {n} contracts end in {month}, and I have spoken to all of them. | {month} ayında {n} sözleşme bitiyor, hepsiyle görüştüm. |
| `renew.rep.opening_one` | Satışçı raporu · açılış, tek sözleşme | One contract ends in {month}, and I have spoken to them. | {month} ayında tek bir sözleşme bitiyor, onlarla görüştüm. |
| `renew.rep.opening_overflow` | Satışçı raporu · açılış, masa taştı (kurucu kâğıdıyla birleşmiş kâğıt) | {n} contracts end in {month}. I spoke to {met} of them. I did not get to the other {left}, so their offer is your call. | {month} ayında {n} sözleşme bitiyor. {met} hesapla görüştüm; kalan {left} hesaba vaktim yetmedi, onlara gidecek teklif senin kararın. |
| `renew.rep.group_raise` | Satışçı raporu · tutum satırı, zamma açık | Renewing at {pct}% more: {accounts}. | %{pct} zamla devam ediyor: {accounts}. |
| `renew.rep.group_same` | Satışçı raporu · tutum satırı, aynı fiyat | Staying at today's price: {accounts}. | Aynı fiyattan devam etmek istiyor: {accounts}. |
| `renew.rep.group_discount` | Satışçı raporu · tutum satırı, indirim ister | Asking for {pct}% off: {accounts}. | %{pct} indirim istiyor: {accounts}. |
| `renew.rep.group_last` | Satışçı raporu · tutum satırı, ayrılmayı düşünüyor | Staying only with {pct}% off: {accounts}. | %{pct} indirim olursa kalıyor: {accounts}. |
| `renew.rep.group_leaving` | Satışçı raporu · tutum satırı, yenilemeyecek | Not renewing: {accounts}. Their contracts end at the end of {month}. | Yenilemeyecek: {accounts}. Sözleşmeleri {month} sonunda bitiyor. |
| `renew.list_more` | Rapor ve kâğıtlar · uzun ad listesinin sonu | {accounts} and {n} more | {accounts} ve {n} hesap daha |
| `renew.rep.opt_as_agreed` | Satışçı raporu · seçenek 1 | Renew as agreed | Konuştuğun gibi yenile |
| `renew.rep.opt_hold_price` | Satışçı raporu · seçenek 2 | Offer today's price to those asking for a discount | İndirim isteyenlere aynı fiyatı teklif et |
| `renew.rep.expired` | Satışçı raporu · cevapsız kalınca not | No answer came, so {employee} offered everyone today's price. | Cevap gelmedi; {employee} herkese aynı fiyatı teklif etti. |
| `renew.chip_raise` | Yenileme kâğıtları · etki çipi, zam | Raise {amount} a month | Zam ayda {amount} |
| `renew.chip_discount` | Yenileme kâğıtları · etki çipi, indirim | Discount {amount} a month | İndirim ayda {amount} |
| `renew.chip_leaves` | Yenileme kâğıtları · etki çipi, ayrılan hesaplar | Leaving: {accounts} | {accounts} ayrılır |
| `renew.chip_reluctant` | Yenileme kâğıtları · etki çipi, gönülsüz yenileme | Renewing reluctantly: {accounts} | {accounts} gönülsüz yeniler |
| `renew.outcome_seats_up` | Satışçı raporu ve sonuç maili · koltuk artışı satırı | Adding seats: {company}. Their team grew; going from {old} seats to {new}. | Koltuk ekliyor: {company}. Ekipleri büyüdü; {old} koltuktan {new} koltuğa çıkıyor. |
| `renew.outcome_seats_down` | Satışçı raporu ve sonuç maili · mali koltuk azalışı satırı | Cutting seats: {company}. They are cutting costs; going from {old} seats to {new}. | Koltuk azaltıyor: {company}. Maliyetleri kısıyorlar; {old} koltuktan {new} koltuğa iniyor. |
| `renew.outcome_switch` | Satışçı raporu ve sonuç maili · başka ürüne geçiş satırı | Not renewing: {company}. They are moving to a product with a stronger {area} side. | Yenilemeyecek: {company}. {area} tarafını daha güçlü buldukları bir ürüne geçiyorlar. |
| `renew.outcome_budget` | Satışçı raporu ve sonuç maili · bütçe kesintisi, memnun hesap | Cutting its budget: {company}. Going from {old} seats to {new}. | Bütçesini küçültüyor: {company}. {old} koltuktan {new} koltuğa iniyor. |
| `renew.outcome_budget_leave` | Satışçı raporu ve sonuç maili · bütçe kesintisi, memnun olmayan hesap | Cutting its budget: {company}. Not renewing this year; the contract ends at the end of {month}. | Bütçesini küçültüyor: {company}. Bu dönem yenilemiyor; sözleşmesi {month} sonunda bitiyor. |
| `renew.result.subject` | Sonuç maili · konu | {month} renewals done | {month} yenilemeleri tamam |
| `renew.result.columns` | Sonuç maili · sütun başlıkları | Company · Before · After · Change | Firma · Eski · Yeni · Değişim |
| `renew.result.not_renewing` | Sonuç maili · yenilemeyen hesabın satırı | Not renewing. The contract ends at the end of {month}. | Yenilemeyecek. Sözleşmesi {month} sonunda bitiyor. |
| `renew.result.total` | Sonuç maili · alt satır | Total: {delta} a month. | Toplam: ayda {delta}. |
| `renew.news_frame` | Yenileme haberi · çerçeve (sonuç mailinin ve haber satırının tek cümlesi) | {company} renewed {terms}. | {company} sözleşmesini {terms} yeniledi. |
| `renew.news_raise` | Yenileme haberi · fiyat parçası, zam | with a {pct}% increase | %{pct} zamla |
| `renew.news_same` | Yenileme haberi · fiyat parçası, aynı fiyat | at the same price | aynı fiyatla |
| `renew.news_discount` | Yenileme haberi · fiyat parçası, indirim | with a {pct}% discount | %{pct} indirimle |
| `renew.news_seats_up` | Yenileme haberi · koltuk parçası, artış | and {n} more seats | ve {n} koltuk daha ekleyerek |
| `renew.news_seats_down` | Yenileme haberi · koltuk parçası, azalış | and {n} fewer seats | ve {n} koltuk azaltarak |
| `renew.founder.subject` | Kurucu kâğıdı · başlık | Contracts ending in {month} | {month} ayında biten sözleşmeler |
| `renew.founder.body` | Kurucu kâğıdı · gövde | Our contracts with these customers end in {month}. We need to send the renewal offers this week. | Şu müşterilerle sözleşmemiz {month} ayında bitiyor. Yenileme tekliflerini bu hafta göndermemiz gerekiyor. |
| `renew.founder.row` | Kurucu kâğıdı · hesap satırı | {company} · {amount} a month · satisfaction {sat} · leaves under {bar} | {company} · ayda {amount} · memnuniyet {sat} · eşik {bar} |
| `renew.founder.more` | Kurucu kâğıdı · 6 satırı aşan hesaplar | The other {n} accounts are all at least {margin} points above the point where they would leave. | Diğer {n} hesabın hepsi eşiğinin en az {margin} puan üstünde. |
| `renew.founder.opt_raise` | Kurucu kâğıdı · seçenek 1 | Offer everyone a renewal at {pct}% more | Hepsine %{pct} zamlı yenileme teklifi gönder |
| `renew.founder.opt_same` | Kurucu kâğıdı · seçenek 2 | Offer everyone a renewal at today's price | Hepsine aynı fiyatla yenileme teklifi gönder |
| `renew.founder.opt_mixed` | Kurucu kâğıdı · seçenek 3 | Offer {pct}% off to those who may not renew, today's price to the rest | Yenilemeyebilir olanlara %{pct} indirim, ötekilere aynı fiyat teklif et |
| `renew.founder.opt_hand` | Kurucu kâğıdı · seçenek 4, satışçıya devret | Hand these accounts to {employee} | Bu hesapları {employee} üstlensin |
| `renew.founder.lock_hand` | Kurucu kâğıdı · devret seçeneğinin kilit gerekçesi | Nobody works the sales desk. | Satış masasında kimse yok. |
| `renew.founder.lock_mixed` | Kurucu kâğıdı · seçenek 3'ün kilit gerekçesi (ilk yenileme, etiketli hesap yok) | None of these accounts is marked May not renew. | Bu hesapların hiçbirinde Yenilemeyebilir etiketi yok. |
| `renew.founder.expired` | Kurucu kâğıdı · cevapsız kalınca not | No answer came, so everyone was offered today's price. | Cevap gelmedi; herkese aynı fiyatla teklif gitti. |
| `renew.answers.subject` | Cevaplar maili (kurucu yolu) · konu | {month} renewal replies | {month} yenileme cevapları |
| `renew.answer_raise` | Cevaplar maili · satır, zamla yeniledi | Renewed at {pct}% more. | %{pct} zamla yeniledi. |
| `renew.answer_same` | Cevaplar maili · satır, aynı fiyatla yeniledi | Renewed at the same price. | Aynı fiyatla yeniledi. |
| `renew.answer_discount` | Cevaplar maili · satır, indirimle yeniledi | Renewed at {pct}% off. | %{pct} indirimle yeniledi. |
| `renew.answer_counter_same` | Cevaplar maili · karşı teklif, aynı fiyat | "We will sign at the same price." | "Aynı fiyat olursa imzalarız." |
| `renew.answer_counter_discount` | Cevaplar maili · karşı teklif, indirim | "We will stay with {pct}% off." | "%{pct} indirim olursa devam ederiz." |
| `renew.answer_leaving` | Cevaplar maili · yenilemeyecek | "We will not renew. We will keep using it until the end of {month}." | "Sözleşmemizi yenilemeyeceğiz. {month} sonuna kadar kullanmaya devam edeceğiz." |
| `renew.answer_seats_up` | Cevaplar maili · hesabın ağzından koltuk artışı | "Our team has grown. For the new term we want {new} seats instead of {old}." | "Ekibimiz büyüdü. Yeni dönemde {old} yerine {new} koltuk istiyoruz." |
| `renew.answer_seats_down` | Cevaplar maili · hesabın ağzından mali azalış | "We are cutting costs. For the new term we will carry on with {new} seats instead of {old}." | "Maliyetleri kısıyoruz. Yeni dönemde {old} yerine {new} koltukla devam edeceğiz." |
| `renew.answer_switch` | Cevaplar maili · hesabın ağzından başka ürüne geçiş | "We will not renew. We are moving to a product with a stronger {area} side, and we will keep using yours until the end of {month}." | "Yenilemeyeceğiz; {area} tarafı daha güçlü bir ürüne geçiyoruz. {month} sonuna kadar sizinkini kullanmaya devam edeceğiz." |
| `renew.answer_budget` | Cevaplar maili · hesabın ağzından bütçe kesintisi, memnun hesap | "We have cut our budget. It is not about the product; we will carry on with {new} seats instead of {old}." | "Bütçemizi küçülttük. Bu, ürünle ilgili değil; {old} yerine {new} koltukla devam ediyoruz." |
| `renew.answer_budget_leave` | Cevaplar maili · hesabın ağzından bütçe kesintisi, memnun olmayan hesap | "We have cut our budget and cannot continue this year. The contract ends at the end of {month}." | "Bütçemizi küçülttük, bu dönem devam edemeyeceğiz. Sözleşme {month} sonunda bitiyor." |
| `renew.counter.title` | Karşı teklif kâğıdı · başlık | {month} counter offers | {month} karşı teklifleri |
| `renew.counter.body` | Karşı teklif kâğıdı · gövdenin girişi (satırlar cevaplar mailinin karşı teklif satırları) | Some customers came back to our offer with their own number: | Bazı müşteriler teklifimize kendi rakamlarıyla döndü: |
| `renew.counter.opt_accept` | Karşı teklif kâğıdı · seçenek 1 | Accept every counter offer | Karşı tekliflerin hepsini kabul et |
| `renew.counter.opt_split` | Karşı teklif kâğıdı · seçenek 2 | Accept those asking for today's price, offer today's price to those asking for a discount | Aynı fiyat isteyeni kabul et, indirim isteyene aynı fiyatı teklif et |
| `renew.counter.opt_hold` | Karşı teklif kâğıdı · seçenek 3 | Stand by our offer | Teklifimizde ısrar et |
| `renew.counter.expired` | Karşı teklif kâğıdı · cevapsız kalınca not | No answer came, so those who countered were offered today's price. | Cevap gelmedi; karşı teklif verenlere aynı fiyat teklif edildi. |
| `budget_mail.subject` | Bütçe kesintisi maili (kâğıtsız) · konu | Contract renewal | Sözleşme yenileme |
| `budget_mail.body_keep` | Bütçe kesintisi maili · memnun hesap, yarı koltukla yeniler | We are cutting our budget this year and spending less on software. This is not about your product; our team is happy with it. We will renew at the end of {month} with {new} seats instead of {old}. The monthly fee goes from {old_fee} to {new_fee}. | Bu yıl bütçemizi küçültüyoruz ve yazılım harcamalarımızı azaltıyoruz. Karar ürününüzle ilgili değil; ekibimiz ürünü kullanmaktan memnun. Sözleşmemizi {month} sonunda {old} yerine {new} koltukla yeniliyoruz. Aylık ücret {old_fee} yerine {new_fee} olacak. |
| `budget_mail.body_leave` | Bütçe kesintisi maili · memnun olmayan hesap, yenilemez | We are cutting our budget this year and spending less on software. We cannot continue this year. The contract ends at the end of {month}. | Bu yıl bütçemizi küçültüyoruz ve yazılım harcamalarımızı azaltıyoruz. Bu dönemde devam edemeyeceğiz. Sözleşme {month} sonunda bitiyor. |
| `renew.log_budget` | Satış günlüğü · bütçe kesintisiyle yenilemeyen | {company} · not renewing · budget cut | {company} · yenilemeyecek · bütçe kesintisi |
| `renew.log_switch` | Satış günlüğü · başka ürüne geçen | {company} · not renewing · moving to another product | {company} · yenilemeyecek · başka ürüne geçiyor |
| `renew.tip` | HESAPLAR · Yenileme hücresinin ipucu, ilk satır | Renews {date} · {trend} | Yenileme {date} · {trend} |
| `renew.tip_remaining` | HESAPLAR · Yenileme ipucu, kalan sözleşme değeri | {months} months left · {amount} | Kalan {months} ay · {amount} |
| `renew.tip_remaining_one` | HESAPLAR · Yenileme ipucu, kalan 1 ay | {months} month left · {amount} | Kalan {months} ay · {amount} |
| `renew.tip_owner` | HESAPLAR · Yenileme ipucu, yürüten satışçı | {name} runs the renewal. | Yenilemeyi {name} yürütür. |
| `renew.tip_owner_you` | HESAPLAR · Yenileme ipucu, kurucu yürütür | You run the renewal. | Yenilemeyi sen yürütürsün. |
| `sector.trend_growing` | Sektör eğilimi · Büyüyen | Growing sector | Büyüyen sektör |
| `sector.trend_steady` | Sektör eğilimi · Olağan | Steady sector | İstikrarlı sektör |
| `sector.trend_flat` | Sektör eğilimi · Durağan | Flat sector | Durağan sektör |
| `sat.term_discount` | Memnuniyet ipucu · indirim durum terimi (+8, sonraki yenilemeye kadar) | Renewal discount | Yenileme indirimi |
| `sat.term_raise` | Memnuniyet ipucu · zam durum terimi (−2, sonraki yenilemeye kadar) | Renewal price rise | Yenileme zammı |
| `sat.term_reluctant` | Memnuniyet ipucu · gönülsüz yenileme durum terimi (−6) | Reluctant renewal | Gönülsüz yenileme |

## C6

| id | Yer | EN | TR |
|---|---|---|---|
| `ov.release_head` | Genel Bakış · Sürüm bloğu başlığı | Release | Sürüm |
| `ov.release_age` | Sürüm bloğu · sürüm ve yaşı | {version} · {n} weeks ago | {version} · {n} hafta önce |
| `ov.release_age_one` | Sürüm bloğu · sürüm ve yaşı, 1 hafta | {version} · last week | {version} · geçen hafta |
| `ov.release_age_now` | Sürüm bloğu · sürüm bu hafta çıktı | {version} · this week | {version} · bu hafta |
| `ov.release_next` | Sürüm bloğu · sonraki sürüm | Next {version} · Sprint {n} | Sonraki {version} · Sprint {n} |
| `ov.stability_head` | Genel Bakış · Kararlılık bloğu başlığı | Stability | Kararlılık |
| `ov.stability_outages` | Kararlılık bloğu · ilk satırın kesinti parçası | {n} outages in the last 4 weeks | son 4 haftada {n} kesinti |
| `ov.stability_outages_one` | Kararlılık bloğu · kesinti parçası, 1 | {n} outage in the last 4 weeks | son 4 haftada {n} kesinti |
| `ov.stability_outages_none` | Kararlılık bloğu · kesinti parçası, 0 | no outages in the last 4 weeks | son 4 haftada kesinti yok |
| `ov.rep_line` | Kararlılık bloğu · temsilci satırı | Account manager: {name} | Müşteri temsilcisi: {name} |
| `ov.requests_head` | Genel Bakış · İstekler bloğu başlığı | Requests | İstekler |
| `ov.request_b2b` | İstekler bloğu · B2B satırı (yalnız 3★ hesaplar) | {feature} · {accounts} · {amount} a month | {feature} · {accounts} · ayda {amount} |
| `ov.request_b2c` | İstekler bloğu · B2C satırı | {feature} · {n} comments | {feature} · {n} yorum |
| `ov.request_b2c_one` | İstekler bloğu · B2C satırı, 1 yorum | {feature} · {n} comment | {feature} · {n} yorum |
| `ov.requests_no_large` | İstekler bloğu · B2B, 3★ hesap yok | Requests come from large accounts (3★). You have none yet. | İstekleri büyük hesaplar (3★) yapar. Henüz böyle bir hesabın yok. |
| `ov.requests_none_open` | İstekler bloğu · B2B, 3★ var ama açık istek yok | No open requests. | Açık istek yok. |
| `ov.requests_no_rep_b2c` | İstekler bloğu · B2C, temsilci yok | No account manager | Müşteri temsilcisi yok |
| `ov.biz_head` | Genel Bakış · İş bloğu başlığı | Business | İş |
| `ov.biz_b2b` | İş bloğu · B2B satırı | MRR {mrr} · ARR {arr} · {n} accounts · this month +{won} −{lost} | MRR {mrr} · Yıllık {arr} · {n} hesap · bu ay +{won} −{lost} |
| `ov.biz_b2b_one` | İş bloğu · B2B satırı, 1 hesap | MRR {mrr} · ARR {arr} · {n} account · this month +{won} −{lost} | MRR {mrr} · Yıllık {arr} · {n} hesap · bu ay +{won} −{lost} |
| `ov.biz_b2c` | İş bloğu · B2C satırı | MRR {mrr} · conversion {pct}% | MRR {mrr} · dönüşüm %{pct} |
| `req.card_body` | İstek kesintisi kartı (customer.request_feature) · gövde | {customer} wants something the product does not do yet: {feature}. They are asking when it will come. | {customer} ürünün henüz yapmadığı bir şey istiyor: {feature}. Ne zaman geleceğini soruyorlar. |
| `req.card_title` | İstek kesintisi kartı · başlık | Customer request | Müşteri talebi |
| `req.opt_promise` | İstek kesintisi kartı · şık 1, Söz ver | Promise it | Söz ver |
| `req.opt_list` | İstek kesintisi kartı · şık 2, Listeye al | Put it on the list | Listeye al |
| `req.expire_note` | İstek kesintisi kartı · süresi dolunca not | {customer} got no promise; the request went on the list. | {customer} söz almadı; istek listeye girdi. |

## C7

| id | Yer | EN | TR |
|---|---|---|---|
| `support.subject` | Destek raporu · konu | Support · Week {n} | Destek · Hafta {n} |
| `support.sender` | Destek raporu · gönderen | {name} · Account manager | {name} · Müşteri temsilcisi |
| `support.sec_trouble` | Destek raporu · bölüm | Most trouble | En çok sorun çıkan |
| `support.sec_asked` | Destek raporu · bölüm (B2B'de yalnız 3★ istekleri; yoksa çizilmez) | Most asked for | En çok istenen |
| `support.sec_week` | Destek raporu · bölüm | This week | Bu hafta |
| `support.new_priority` | Destek raporu · Bu hafta, hat Öncelikli eşiğine ulaştı | {line} is up to {n} open bugs and now marked Priority. | {line} tarafında açık hata {n} oldu; artık Öncelikli. |
| `support.new_cleared` | Destek raporu · Bu hafta, hat sıfırlandı | {line} has no open bugs left. | {line} tarafında açık hata kalmadı. |
| `support.new_worst` | Destek raporu · Bu hafta, en kötü hat değişti | {line} is now where most of the trouble is. | En çok sorun çıkan yer artık {line}. |
| `support.new_request` | Destek raporu · Bu hafta, yeni istek bilindi | New request: {feature}, from {accounts}. | Yeni istek: {feature}. İsteyen: {accounts}. |
| `support.shipped` | Destek raporu · Bu hafta, düzeltme yayına girdi | The {line} fix is live: {from} → {to} open bugs. | {line} düzeltmesi yayında: {from} → {to} açık hata. |
| `support.behind` | Destek raporu · Yetişemedim satırı | I could not keep up: {incoming} reports came in this week and I got to {handled}. | Yetişemedim: bu hafta {incoming} bildirim geldi, {handled} tanesine bakabildim. |
| `support.btn_fix` | Destek raporu · düğme | Open the {line} fix | {line} düzeltmesini aç |

## C8

| id | Yer | EN | TR |
|---|---|---|---|
| `accounts.tab_leads` | Satış (B2B) · kâğıt şeridi | Leads | Adaylar |
| `accounts.tab_accounts` | Satış (B2B) · kâğıt şeridi | Accounts | Hesaplar |
| `accounts.kpi` | Satış başlığı · ölçüler (B2B) | {n} accounts · MRR {mrr} · ARR {arr} · this month +{won} −{lost} | {n} hesap · MRR {mrr} · Yıllık {arr} · bu ay +{won} −{lost} |
| `accounts.col_company` | HESAPLAR · sütun başlığı | Company | Firma |
| `accounts.col_seats` | HESAPLAR · sütun başlığı | Seats | Koltuk |
| `accounts.col_monthly` | HESAPLAR · sütun başlığı | Monthly | Aylık |
| `accounts.col_satisfaction` | HESAPLAR · sütun başlığı | Satisfaction | Memnuniyet |
| `accounts.col_status` | HESAPLAR · sütun başlığı | Status | Durum |
| `accounts.col_renewal` | HESAPLAR · sütun başlığı | Renewal | Yenileme |
| `accounts.col_request` | HESAPLAR · sütun başlığı | Request | İstek |
| `accounts.col_manager` | HESAPLAR · sütun başlığı | Manager | Temsilci |
| `accounts.view_all` | HESAPLAR · görünüm | All {n} | Tümü {n} |
| `accounts.view_status` | HESAPLAR · görünüm | With a status {n} | Durumu olan {n} |
| `accounts.view_renewing` | HESAPLAR · görünüm | Renewing soon {n} | Yenilemesi yakın {n} |
| `accounts.view_no_manager` | HESAPLAR · görünüm | No account manager {n} | Temsilcisi olmayan {n} |
| `accounts.search` | HESAPLAR · firma arama kutusu | Search companies | Firma ara |
| `accounts.foot` | HESAPLAR · alt toplam satırı | {n} accounts · {seats} seats · {mrr} a month | {n} hesap · {seats} koltuk · ayda {mrr} |
| `accounts.status_may_leave` | HESAPLAR · Durum etiketi | May leave | Ayrılabilir |
| `accounts.status_may_not_renew` | HESAPLAR · Durum etiketi | May not renew | Yenilemeyebilir |
| `accounts.status_not_renewing` | HESAPLAR · Durum etiketi | Not renewing · {month} | Yenilemeyecek · {month} |
| `accounts.action_check_in` | HESAPLAR · satır eylemi (yalnız Ayrılabilir ve Yenilemeyebilir) | Check in | İlgilen |
| `accounts.sat_cell` | HESAPLAR · Memnuniyet hücresi, en büyük olumsuz satırın adı | {sat} · {term} | {sat} · {term} |
| `accounts.term_short_bugs` | HESAPLAR · Memnuniyet hücresinin kısa terim adı | Open bugs | Açık hata |
| `accounts.term_short_outage` | HESAPLAR · Memnuniyet hücresinin kısa terim adı | Outage | Kesinti |
| `accounts.term_short_promise_late` | HESAPLAR · Memnuniyet hücresinin kısa terim adı | Promise kept late | Geç tutulan söz |
| `accounts.term_short_promise_broken` | HESAPLAR · Memnuniyet hücresinin kısa terim adı | Broken promise | Tutulmayan söz |
| `accounts.term_short_deferred` | HESAPLAR · Memnuniyet hücresinin kısa terim adı | Postponed fix | Ertelenen düzeltme |
| `accounts.term_short_update_age` | HESAPLAR · Memnuniyet hücresinin kısa terim adı | No recent update | Güncelleme yok |
| `accounts.term_short_clause` | HESAPLAR · Memnuniyet hücresinin kısa terim adı | Server clause | Sunucu maddesi |
| `accounts.term_short_raise` | HESAPLAR · Memnuniyet hücresinin kısa terim adı | Price rise | Zam |
| `accounts.term_short_reluctant` | HESAPLAR · Memnuniyet hücresinin kısa terim adı | Reluctant renewal | Gönülsüz yenileme |

## C9

| id | Yer | EN | TR |
|---|---|---|---|
| `atlas.home` | Ekip · Atlas, evde (arama kilitli) | There is one desk at home, and it is yours. To hire your first employee, you need to move to the Business block. | Evde tek masa var, o da senin. İlk çalışanını almak için İş hanına taşınman gerekiyor. |
| `atlas.full` | Ekip · Atlas, ofis dolu | There is no free desk in the office. You can hire once you move to a bigger one. | Ofiste boş masa yok. Daha büyük bir ofise taşınınca işe alabilirsin. |
| `atlas.desks` | Ekip · Atlas, tavan satırı | Desks {desks} · {free} free | Masa {desks} · boş {free} |
| `atlas.btn_offices` | Ekip · Atlas, şehir haritasına giden düğme | See offices | Ofisleri gör |
| `atlas.moving` | Ekip · Atlas, taşınma sürerken | The move finishes on {date}. Whoever you hire starts once the new desks are ready. | Taşınma {date} tarihinde bitiyor. İşe aldığın kişi yeni masalar hazır olunca başlar. |
| `office.card_line` | Şehir haritası · ofis kartı satırı | {desks} desks · {rent} rent a month | {desks} masa · ayda {rent} kira |
| `office.card_line_current` | Şehir haritası · bulunulan ofisin kartı | {desks} desks · {taken} taken · {rent} a month | {desks} masa · {taken} dolu · ayda {rent} |
| `office.card_line_home` | Şehir haritası · evin kartı | {desks} desk · no rent | {desks} masa · kira yok |
| `office.move_tip` | Şehir haritası · Taşın düğmesinin ipucu | Rent is {rent} a month. Monthly costs {old} → {new}. The move takes a week; rent starts the week you arrive. | Kira ayda {rent}. Aylık gider {old} → {new}. Taşınma bir hafta sürer; kira taşındığın hafta başlar. |
| `office.req_team` | Şehir haritası · Plaza şartı | Team of at least {n} (you included) | Ekip en az {n} kişi (sen dahil) |

## C3a

| id | Yer | EN | TR |
|---|---|---|---|
| `sat.head` | Satış · hesap memnuniyeti ipucu · başlık | Satisfaction {sat} · leaves under {bar} | Memnuniyet {sat} · ayrılma eşiği {bar} |
| `sat.term_fit` | Memnuniyet ipucu · ürün uyumu satırı | Product fit ({areas}) | Ürün uyumu ({areas}) |
| `sat.term_bugs` | Memnuniyet ipucu · açık hata satırı | Open bugs ({n} in the areas it uses) | Açık hata (baktığı alanlarda {n}) |
| `sat.term_outage` | Memnuniyet ipucu · kesinti satırı (13 hafta söner) | Outage {date}, {hours} hours · gone by {until} | Kesinti {date}, {hours} saat · {until} tarihinde silinir |
| `sat.term_outage_one` | Memnuniyet ipucu · kesinti satırı, 1 saat | Outage {date}, {hours} hour · gone by {until} | Kesinti {date}, {hours} saat · {until} tarihinde silinir |
| `sat.term_promise_kept` | Memnuniyet ipucu · söz tutuldu (+6 kalıcı) | Promise kept: {feature} | Söz tutuldu: {feature} |
| `sat.term_promise_late` | Memnuniyet ipucu · söz geç tutuldu (−3, 8 hafta) | Promise kept late: {feature} · gone by {until} | Söz geç tutuldu: {feature} · {until} tarihinde silinir |
| `sat.term_promise_broken` | Memnuniyet ipucu · söz tutulmadı (−12, 13 hafta) | Promise broken: {feature} · gone by {until} | Söz tutulmadı: {feature} · {until} tarihinde silinir |
| `sat.term_request_shipped` | Memnuniyet ipucu · isteği yayına girdi (+4 kalıcı, yalnız 3★) | Their request shipped: {feature} | İsteği yayına girdi: {feature} |
| `sat.term_deferred` | Memnuniyet ipucu · ertelenen hata (8 hafta) | Postponed fix: {line} · gone by {until} | Ertelenen düzeltme: {line} · {until} tarihinde silinir |
| `sat.term_event` | Memnuniyet ipucu · olay kartının satisfaction_delta satırı (8 hafta) | {event} · gone by {until} | {event} · {until} tarihinde silinir |
| `sat.term_history` | Memnuniyet ipucu · göçün tek satırı (eski trust_offset, 4 hafta) | Earlier dealings · gone by {until} | Önceki ilişki · {until} tarihinde silinir |
| `sat.term_update_age` | Memnuniyet ipucu · güncelleme yaşı terimi (26 haftadan sonra) | No update to {areas} for {weeks} weeks | {areas} tarafında {weeks} haftadır güncelleme yok |
| `sat.update_age_note` | Memnuniyet ipucu · yaş uyarısı (20. haftadan, terim başlamadan) | The last update to {areas} came {weeks} weeks ago. After {limit} weeks, satisfaction drops 1 point every {step} weeks. | {areas} tarafındaki son güncelleme {weeks} hafta önce çıktı. {limit} haftadan sonra memnuniyet her {step} haftada 1 puan düşer. |
| `sat.update_age_reset` | Memnuniyet defteri · yaşı sıfırlayan yayının tek satırı | {areas} updated in {version} | {areas} tarafı {version} ile güncellendi |

## C3b

| id | Yer | EN | TR |
|---|---|---|---|
| `sat.renewal_reading` | Memnuniyet ipucu · son satır (yalnız Q'nun yenileme okuması bugünkünden farklıysa) | At renewal, product fit counts as {fit}. | Yenileme döneminde ürün uyumu {fit} sayılır. |
| `sat.term_market_moved` | Memnuniyet defteri · market_ref tazelenince değişimin satırı | Expectations moved at renewal | Yenilemede beklenti değişti |
| `sign.mail_line` | İmza maili · memnuniyet satırı | Satisfaction starts at {sat}: product fit {fit}, open bugs {bugs}. | Memnuniyet {sat} ile başlıyor: ürün uyumu {fit}, açık hata {bugs}. |
| `sign.mail_line_clean` | İmza maili · memnuniyet satırı, açık hata terimi 0 | Satisfaction starts at {sat}: product fit {fit}. | Memnuniyet {sat} ile başlıyor: ürün uyumu {fit}. |
| `loss.bugs_rep` | Satışçının kayıp maili · gövde, kapı açık hata yüzünden reddetti (loss_area boş) | Boss, I could not close {company}. They asked about the open bugs in {area} and I could not win them over. | Patron, {company} ile anlaşamadım. {area} tarafındaki açık hataları sordular, ikna edemedim. |
| `loss.bugs_meeting` | Kurucu görüşmesi · kayıp nedeni satırı, açık hata | The open bugs on your {area} side worry us. Let us talk again once they are closed. | {area} tarafındaki açık hatalar bizi düşündürüyor. Onlar kapanınca yeniden konuşalım. |
| `loss.bugs_summary_row` | Satışçının haftalık özeti · kayıp satırı, açık hata | {company}: lost, they asked about the open bugs in {area}. | {company}: kaçtı, {area} tarafındaki açık hatalar soruldu. |
