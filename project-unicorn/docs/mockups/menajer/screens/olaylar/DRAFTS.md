# Olaylar mail taslakları (A4, onay bekliyor)

Erdem kararı 15'in örnek dönüşümü: altı temsilî kart mail olarak yazıldı, önce İngilizce, sonra Türk okur için yeniden
yazılmış Türkçe. Bir ek taslak (Frank'in tanışması) çerçeve için gerekti. Hepsi **TASLAK**: Frank'in her satırı Erdem
onaylamadan ekrana çıkmaz (CLAUDE §3). Mühürlü Türkçe (Frank Diyalogları v6) mümkün olan her yerde kelimesi kelimesine
korundu; değişen her şey "Ne değişti" altında.

Değişmeyenler, altısında da: her olgu, bedel, seçenek ve etki çipi kartla aynı (aynı modifier, aynı kilit koşulu, aynı
süre). Metin gözlemler, hükmü yalnız Frank verir. Gerçek marka, UI talimatı, tire yok. Gün sınırında ateşlenen kartlar saat
yazmaz (başlıkta yalnız "Hafta 14 · Nisan 2026"); yalnız saatlik kartlar ve oyuncu eylemiyle açılanlar saat yazar.

Kaynaklar: kartlar `data/events/cards/**`, metin `localization/strings.csv`, Frank'in sesi
`docs/content/events_draft/Frank Diyalogları · v6.md` ve `docs/writing/FRANK_VOICE_INVENTORY.md`.

## Mailin ortak parçaları (yeni, onay bekliyor)

| Parça | EN | TR | Not |
|---|---|---|---|
| Alıcı satırı | To · Founder · Unicorn Inc. | Kime · Kurucu · Unicorn Inc. | Kurucu adı varsa ad; boşsa `HR_ROLE_FOUNDER` (bugünkü varsayılan). Şirket `GameState.company_name`. |
| Konu | kartın yeni `subject` alanı | | Başlık (`title`) iç ad olarak kalır: geçmiş satırı, toast. Liste, okuma bölmesi ve kapı yuvası konuyu ya da göndereni okur. |
| Cevap bloğu | Your reply | Cevabın | Karar ve kağıt. Geçmiş kipte "Seçimin" (SPEC §13'te var). |
| Selamlama | Hello, / Hi, | Merhaba, | Müşteri ve çalışan maillerinde, göndericinin yazdığı gibi. Frank selam vermez. |
| Kapanış | Regards, | Saygılarımla, | Yalnız müşteri muhatabı. Çalışan kapanış yazmaz: altındaki yapısal imza adını zaten taşır (inceleme r3). |
| İmza | ad, unvan, şirket | | Yapısal, yazarın elinden çıkmaz; adı olmayan muhatapta unvan + şirket. |

---

## 1 · `funding.frank_cheque` · Frank'in teklifi (kabul + kilitli ret)

**Bugün** (`ANGEL_EVENT_*`, v6 #10 MÜHÜRLÜ)

- TR: başlık "Frank'in teklifi". Gövde: "Ürün para kazandırmaya başladı. / Arayan yine Frank. / "Buraya kadar kendi birikimin
  ve emeğinle geldin. İşleri hızlandırman için yirmi beş bin dolar koyuyorum, yüzde dört alıyorum. Pazarlık yok. Bir kere
  soruyorum: alıyor musun?" / Cevap bekliyor." Seçenekler: Kabul et (çip "Nakit +$25K · Frank'e %4 hisse"), Reddet (kilitli:
  "Zor modda açılır.").
- EN: title "Frank's offer". Body: "The product has started making money. / Frank again. / "You got this far on your own
  savings and your own work. I'll put in twenty-five thousand to speed things up, and I'll take four percent. No haggling.
  I'm asking once: do you want it?" / He waits for an answer." Options: Accept (chip "Cash +$25K · 4% to Frank"), Refuse
  (locked: "Unlocks in hard mode.").

**Mail, EN**

- From: Frank Köseoğlu · Operating Partner. To: Founder · Unicorn Inc. Date: Week 14 · April 2026 (daily card, no hour).
- Subject: **An offer**
- Body (Frank's face, no greeting, no sign-off):
  > The product has started making money.
  >
  > You got this far on your own savings and your own work. I'll put in twenty-five thousand to speed things up, and I'll
  > take four percent. No haggling. I'm asking once: do you want it?
- Signature: Frank Köseoğlu / Operating Partner
- Your reply: **Accept** (one open option, presented armed: Cash +$25K | To Frank 4% equity). **Refuse**, locked: "Unlocks in
  hard mode."

**Mail, TR**

- Kimden: Frank Köseoğlu · Operating Partner. Kime: Kurucu · Unicorn Inc. Tarih: Hafta 14 · Nisan 2026.
- Konu: **Teklif**
- Gövde:
  > Ürün para kazandırmaya başladı.
  >
  > Buraya kadar kendi birikimin ve emeğinle geldin. İşleri hızlandırman için yirmi beş bin dolar koyuyorum, yüzde dört
  > alıyorum. Pazarlık yok. Bir kere soruyorum: alıyor musun?
- İmza: Frank Köseoğlu / Operating Partner
- Cevabın: **Kabul et** (Nakit +$25K | Frank'e %4 hisse). **Reddet**, kilitli: "Zor modda açılır."

**Ne değişti, neden**

- "Arayan yine Frank." / "Frank again." çıktı: kimin yazdığını başlık söylüyor, telefon kanalı maile döndü (v6 Bölüm 3:
  Frank'in kanalı mesaj ve telefon).
- "Cevap bekliyor." / "He waits for an answer." çıktı: bekleyişi cevap bloğu ve üst bardaki kapı taşıyor.
- İlk satır anlatıcıdan Frank'in ağzına geçti, Türkçesi mühürlü haliyle aynı (Erdem'in düzeltmesi "kazandırmaya başladı").
  Seçenek: Frank duyduğunu aktarıyor diye "başlamış". Öneri: mühürlü hali kalsın.
- Tırnaklar kalktı: gövdenin tamamı Frank'in sözü; yüzü Source Serif 4 (SPEC §3.1 Frank'in sözleri).
- Konu yeni: Frank kendi adını konuya yazmaz, "Frank'in teklifi" iç başlık olarak kalır.
- Etkiler aynı: `angel_accept`; ret `funding.hard_mode` seam'ine kilitli.

---

## 2 · `customer.frank_intro` · Frank'in tek seçenekli anı

**Bugün** (v6 #6 MÜHÜRLÜ; kartta `speaker` yok, alt başlık "Telefon")

- TR: başlık "Eski bir dost". Gövde: "Ürün yayında. Telefon çalıyor, arayan Frank. / "Eski bir dostuma senin üründen
  bahsettim. İşine yarayabileceğini düşünüyor. Bir görüşme ayarladım. Hazırlıklı git." / Kapatıyor." Seçenek: Satış'a git
  (çipler "Yeni aday", "Seni oraya götürür"; `mentor_advisory` sessiz).
- EN: title "An old friend". Body: "The product is live. The phone rings. It's Frank. / "I told an old friend of mine about
  what you've built. He thinks it might be useful to him. I've set up a meeting. Go in prepared." / He hangs up." Option:
  Go to Sales.

**Mail, EN**

- From: Frank Köseoğlu · Operating Partner. Date: the day boundary after the B2B ship, no hour.
- Subject: **An old friend**
- Body:
  > I told an old friend of mine about what you've built. He thinks it might be useful to him. I've set up a meeting. Go in
  > prepared.
- Your reply: **Go to Sales** (one open option, presented armed: A new prospect | Takes you there).

**Mail, TR**

- Konu: **Eski bir dost**
- Gövde:
  > Eski bir dostuma senin üründen bahsettim. İşine yarayabileceğini düşünüyor. Bir görüşme ayarladım. Hazırlıklı git.
- Cevabın: **Satış'a git** (Yeni aday | Seni oraya götürür).

**Ne değişti, neden**

- Çağrı anlatısı çıktı ("Ürün yayında. Telefon çalıyor, arayan Frank." ve "Kapatıyor."): mailin göndericisi var, kapatılan
  telefonu yok. "Ürün yayında" bilgisi tetikleyicide zaten var; Frank'in sözü olduğu gibi.
- Alt başlık "Telefon" emekli: kanal artık mail.
- Kartın `speaker` alanı boş, bu yüzden bugün MENTOR rozeti ve Frank'in yüzü çıkmıyor. Mailde göndericiyi Frank yapmak
  `speaker: char_mentor_frank` ister (motor alanı, öneri).
- Soru: `mentor_advisory` notu ("Görüşme ayarlandı. Hazırlıklı git.") artık mailin tekrarı. Not kalsın mı (bildirim yığını
  için), yoksa mail mi yeter? Etkiler bu taslakta değişmedi.

---

## 3 · `customer.retention` · çok seçenekli, kilitli seçenekli müşteri kararı

**Bugün**

- TR: başlık "Müşteri riski". Gövde: "{customer} hatta. / "{seam:musteri.risk_voice}"". Seçenekler: Söz ver, Oyala, İndirim
  ver, Kendi haline bırak. Kilitler: "Bu hesaba verilmiş, henüz tutulmamış bir söz var.", "İki kez oyaladın. Üçüncüsünü kimse
  beklemez.", "Fiyatlarını zaten iki kez indirdin." Süre dolunca: "{customer} bir daha aramadı."
- EN: title "Account at risk". Body: "{customer} on the line. / "{seam:musteri.risk_voice}"". Options: Promise it, Stall
  them, Offer a discount, Let it go. Expire: "{customer} didn't call again."

**Mail, EN**

- From: the account's contact (SENDERS.md, CONTACT). Fixture account in the seed: **Ege Sigorta · IT Manager** (sector title
  `B2B_CONTACT_INSURANCE`), company monogram. Date: day boundary, no hour.
- Subject: **We need to talk**
- Body:
  > Hello,
  >
  > {risk_voice}
  >
  > Regards,
- Seed voice (`B2B_RISK_VOICE_SHORT_2`, picked by `hash("co_ege") % 3 = 1`): "My team works around it more than they work
  in it. That has to stop." Broken-promise voice (`B2B_RISK_VOICE_BROKEN`): "You said it would be there. It isn't. We've
  started looking at other options."
- Signature: IT Manager / Ege Sigorta (a named contact signs with the name)
- Your reply: **Promise it** (The customer stays · a promise owed, Reputation +1), **Stall them** (A short-term move,
  Reputation −1), **Offer a discount** (The customer stays · MRR −$150, Reputation −1; 15 % of $1,000), **Let it go** (no
  intervention · the counter keeps running). Locks unchanged; the clause that fails names itself.
- Expire: "{customer} didn't write again."

**Mail, TR**

- Kimden: Ege Sigorta · BT Müdürü. Konu: **Konuşmamız gerek**
- Gövde:
  > Merhaba,
  >
  > {risk_voice}
  >
  > Saygılarımla,
- Tohum sesi: "Ekibim sistemin içinde çalışmaktan çok etrafından dolanıyor. Bu böyle sürmez." Tutulmayan söz sesi: "Olacak
  dediniz, olmadı. Başka seçeneklere bakmaya başladık."
- İmza: BT Müdürü / Ege Sigorta
- Cevabın: **Söz ver**, **Oyala**, **İndirim ver**, **Kendi haline bırak** (çipler kartla aynı).
- Süre dolunca: "{customer} bir daha yazmadı."

**Ne değişti, neden**

- "{customer} hatta." / "on the line" çıktı: hesap artık yazıyor; sözü tırnaksız gövde oldu.
- Konu her ses çeşidine uyuyor (şikâyet, tutulmayan söz, kısa sesler).
- Süre notu "aramadı" → "yazmadı": kanal maile döndü.
- Gözlem (değişiklik değil, Erdem'in kararına): `B2B_LOCK_STALL_CAP`'in ikinci cümlesi "Üçüncüsünü kimse beklemez." /
  "Nobody waits for a third." kilidin kendi bilgeliğini söylüyor (CLAUDE §5). Yalnız olgu: "İki kez oyaladın." / "You've
  stalled them twice." Çerçevelerde bugünkü metin değişmedi; o kilit hiçbir çerçevede görünmüyor.

---

## 4 · `customer.expansion` · süreli kağıt

**Bugün**

- TR: başlık "Büyüme fırsatı". Gövde: "{customer} sistemi bir ekibe daha açmak istiyor. / Aynı fiyattan koltuk istiyorlar."
  Seçenekler: Koltukları ekle (çip "Koltuk +{seats} · MRR {mrr}"), Şimdi değil ("Değişiklik yok"). Süre 2 hafta; dolunca
  "{customer} o bütçeyi başka bir şeye harcadı."
- EN: title "Growth opening". Body: "{customer} wants to roll the system out to another team. / They're asking for more
  seats at the same price." Options: Add the seats, Not now.

**Mail, EN**

- From: the account's contact; seed: **Nordica · Operations Manager** (`B2B_CONTACT_LOGISTICS`), monogram. Paper, two weeks.
- Subject: **One more team**
- Body:
  > Hello,
  >
  > We'd like to roll the system out to another team. Could you add the seats at the same price?
  >
  > Regards,
- Your reply (after "Respond"): **Add the seats** (Seats +6 · MRR +$600), **Not now** (No change).

**Mail, TR**

- Kimden: Nordica · Operasyon Müdürü. Konu: **Bir ekip daha**
- Gövde:
  > Merhaba,
  >
  > Sistemi bir ekibimize daha açmak istiyoruz. Koltukları aynı fiyattan ekleyebilir misiniz?
  >
  > Saygılarımla,
- Cevabın ("Cevapla"dan sonra): **Koltukları ekle** (Koltuk +6 · MRR +$600), **Şimdi değil** (Değişiklik yok).

**Ne değişti, neden**

- Üçüncü kişi anlatı ("{customer} ... istiyor ... istiyorlar") hesabın birinci çoğul sesine geçti; "aynı fiyattan" isteği
  korundu.
- Çip: orta boy hesap 6 koltuk; fiyat hesabın kendi koltuk fiyatı (`b2b_expand`): Nordica $2.000 / 20 koltuk = $100, 6 ×
  $100 = $600. Not: tohum fikstürü `seat_price` yazmadığı için `--b2b-shot` bugün $120 yedeğiyle +$720 basar; gerçek
  hesapta imza fiyatı vardır.

---

## 5 · `team.resignation` · çalışan ayrılığı

**Bugün**

- TR: başlık "Ayrılık". Gövde: "{seam:hr.resign_voice}" (tırnaklı tek replik). Seçenek: Anlaşıldı (çip "{who} ayrılıyor",
  tehlike).
- EN: title "A departure". Body: the same seam. Option: Understood.

**Mail, EN**

- From: {employee}; seed: **Selin Kaya · QA Engineer** (Unicorn Inc.), bust and portrait well.
- Subject: **My notice**
- Body:
  > Hi,
  >
  > {resign_voice}
- Seed voice (`HR_RESIGN_VOICE_4`, `hash("char_emp_shot_3") % 4 = 3`): "I got an offer from somewhere else. Honestly, I
  made the call myself."
- Signature: Selin Kaya / QA Engineer · Unicorn Inc.
- Your reply: **Understood** (one open option, presented armed: Team · Selin is leaving, danger).

**Mail, TR**

- Kimden: Selin Kaya · Test Mühendisi. Konu: **İstifa dilekçem**
- Gövde:
  > Merhaba,
  >
  > Başka bir yerden teklif geldi. Doğrusunu istersen, aramayı ben yaptım.
- İmza: Selin Kaya / Test Mühendisi · Unicorn Inc.
- Cevabın: **Anlaşıldı** (Ekip · Selin ayrılıyor).

**Ne değişti, neden**

- Replik tırnaksız gövde oldu (CSV değerleri tırnak taşıyor: yeni anahtar ya da çizimde tırnak atma).
- Kapanış yok: imza (Selin Kaya / Test Mühendisi · Unicorn Inc.) yapısal, gövdede ikinci kez ad yazılmaz.
- "İstifa dilekçem": Türk ofisinin kendi sözü; "My notice" İngilizcede aynı işi görür. Çeviri değil yerelleştirme.
- Ayrıldıktan sonra mail kutuda kalır: ad aynı, yanında "Ayrıldı", yüz gri ve %55, damga AYRILDI.

---

## 6 · `world.final_stretch_press` · basın

**Bugün**

- TR: başlık "Sektör Telgrafı · yıllık dosya". Gövde: "Yıllık dosya çıkmış. Seninle aynı yıl kurulan şirketlerin listesi.
  Çoğunun yanında bir tur, bir satış ya da bir kapanış yazıyor. / Seninkinin yanında ilk gün yazdıkları satır duruyor. Dosya
  yorum yapmıyor. Sadece sıralıyor." Seçenek: Dosyayı kenara koy (etkiler sessiz: `stamp_day`, `start_arc`). Süre 4 hafta.
- EN: title "Sector Telegraph · the annual file". Body: "The annual file is out. It lists every company founded the same year
  as yours. Most have a round, a sale or a closure next to the name. / Next to yours is the line they wrote on day one. The
  file doesn't comment. It only lists." Option: Set the file aside.

**Mail, EN**

- From: **Sektör Telgrafı** (outlet monogram in `outlet-sektor`). Paper, four weeks; day boundary, no hour.
- Subject: **The annual file**
- Body:
  > This year's annual file is out: every company founded the same year as yours.
  >
  > Most have a round, a sale or a closure next to the name. Next to yours is the line we ran on day one.
  >
  > The file does not comment. It only lists.
- Signature: Sektör Telgrafı
- Your reply: **Set the file aside** (a beat: no chips).

**Mail, TR**

- Kimden: Sektör Telgrafı. Konu: **Yıllık dosya**
- Gövde:
  > Yıllık dosya çıktı: seninle aynı yıl kurulan şirketlerin listesi.
  >
  > Çoğunun yanında bir tur, bir satış ya da bir kapanış yazıyor. Seninkinin yanında ilk gün yazdığımız satır duruyor.
  >
  > Dosya yorum yapmaz. Yalnız sıralar.
- İmza: Sektör Telgrafı
- Cevabın: **Dosyayı kenara koy**

**Ne değişti, neden**

- Başlık ikiye ayrıldı: yayın gönderen oldu, "yıllık dosya" konu.
- EN başlıktaki "Sector Telegraph" özel adın çevirisiydi (CLAUDE §5 özel ad çevrilmez; haber şeridi EN'de de "Sektör
  Telgrafı" yazıyor). Gönderen iki dilde "Sektör Telgrafı".
- Anlatıcının iğnesi ("Dosya yorum yapmıyor. Sadece sıralıyor.") yayının kendi notuna döndü; hüküm yine kurulmuyor, okur
  çıkarıyor. "yazdıkları" → "yazdığımız": yayın kendisi konuşuyor.
- Soru: bülten kurucuya "sen" diye mi seslenir (girişim bülteni tonu), "siz" mi?

---

## Ek taslak · `MENTOR_INTRO_BODY` · Frank'in tanışması (çerçeve için)

**Bugün** (v6 #1 MÜHÜRLÜ): sahne: alarm, tavandaki boya izi, kayıtlı olmayan numara, Frank'in üç sorusu ve kurucunun
cevapları, "Kapatıyor. Saat onu beş geçiyor." Seçenek: Hadi başlayalım.

**Mail, EN**

- From: Frank Köseoğlu · Operating Partner. Date: Week 1 · January 2026 · 09:00 (sent at the run's start, a real hour).
- Subject: **It's Frank**
- Body:
  > You'll remember me from your old company. Did you quit, or are you still thinking about it?
  >
  > So what have you actually got, an idea or something that works? If it's an idea, there's nobody to write the first
  > version. You'll write it, and it'll probably be bad.
- Reply: **Let's get started**

**Mail, TR**

- Konu: **Ben Frank**
- Gövde:
  > Eski şirketten hatırlarsın. İstifa ettin mi, yoksa hâlâ düşünüyor musun?
  >
  > Elinde ne var şu an, fikir mi yoksa çalışan bir şey mi? Fikirse ilk sürümü yazacak kimse yok. Sen yazacaksın,
  > muhtemelen kötü olacak ama normal olan bu zaten.
- Cevap: **Hadi başlayalım**

**Ne değişti, neden**

- Sahne maile sığmaz: alarm, tavan, kurucunun cevapları gider. Frank'in kendi satırları kelimesi kelimesine kalır; cevaplar
  gelmeden sorduğu için "O zaman" → "Fikirse" / "If it's an idea".
- Yeni Frank satırı (taslak): "Eski şirketten hatırlarsın." / "You'll remember me from your old company." Anlatıcının
  "Eski şirkette danışmandı" bilgisini taşır.
- Seçenek B: sahne mühürlü haliyle kurucunun kendi notu (SELF) olarak kalır, Frank mail atmaz. Erdem seçer.

## Yazılmayanlar (bu turda)

Dönem özeti, Ar-Ge notu ve haftalık satış özeti metinleri yeniden yazılmadı: motorun bestelediği içerik olduğu gibi
göründü, yalnız gönderen ve konu eklendi (INDEX.md). Kalan 50'yi aşkın kartın tam dönüşümü onaydan sonra (plan, "Tam
dönüşüm").
