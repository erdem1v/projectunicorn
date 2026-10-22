# Wa · Derinlik kartı adları: kaynaklı aday listesi

Arama sayısı: **46** (WebSearch, standart kip). Bütçe doldu mu: **hayır**. Toplam aday: **162**, 19 hat. 'Bulunamadı' satırı: **0**.

Her satırın kaynağı, o aramanın sonuç listesinde gördüğüm gerçek bir sayfadır. Sayfaların kendisini tek tek açmadım; ayrıntı arama özetinden alındı. Bu yüzden 'kaynak türü' sütununu okuyun: **resmi sayfa** satıcının kendi yardım ya da ürün sayfası, **satıcı tanıtımı** pazarlama metni, **üçüncü taraf** blog ya da inceleme, **kullanıcı isteği** özelliğin varlığını değil ihtiyacın varlığını gösterir. Kullanıcı isteği olanları Wb'de ad olarak kullanmadan önce bir daha bakın.

Kaynak türü dağılımı: kullanıcı isteği 3, satıcı tanıtımı 17, resmi sayfa 85, üçüncü taraf 57.

Kural: ad işin kendisini söyler, marka ve arayüz talimatı yok; mevcut K1–K3 kart adlarını tekrarlamaz. 'Hat' sütunundaki 'shared' dört ortak platform hattıdır (her ürün alt tipinde aynı).


## Nakit Akışı (Cash Flow) · `line_erp_cashflow`

Ürün: erp · Alan (eksen): innovation · Mevcut kartlar: Cash Movements → Cash Flow Statement → Cash Forecast

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Best-case and worst-case cash scenarios | Müşteri zamanlamayı ve tutarı oynatıp en iyi ve en kötü nakit durumunu yan yana görür. | arandı | satıcı tanıtımı | https://ecosire.com/apps/odoo/cash-flow-forecasting | 1 |
| 2 | Planned purchase tried on the forecast | Müşteri planladığı bir alımı ya da işe almayı tahmine ekleyip defterlere dokunmadan etkisini görür. | arandı | resmi sayfa | https://quickbooks.intuit.com/global/cash-flow/ | 6 |
| 3 | Expected pay date from each customer's habit | Her faturanın tahmini ödeme günü, o müşterinin geçmiş ödeme alışkanlığından gelir. | arandı | üçüncü taraf | https://cfotech.co.uk/story/xero-cash-flow-manager-projects-short-term-cash-moves | 7 |
| 4 | Forecast split by project or cost center | Nakit tahmini proje, şube ya da masraf merkezi bazında ayrı okunur. | arandı | satıcı tanıtımı | https://ecosire.com/apps/odoo/cash-flow-forecasting | 1 |
| 5 | Recurring costs carried into the forecast | Her ay tekrarlayan gelir ve giderler tahmine kendiliğinden girer. | arandı | resmi sayfa | https://quickbooks.intuit.com/global/cash-flow/ | 6 |
| 6 | Cash view stretched from 30 to 90 days | Müşteri kısa görünümden 90 günlük uzun görünüme geçip daralacak haftaları erken görür. | arandı | resmi sayfa | https://quickbooks.intuit.com/ie/cash-flow/ | 6 |
| 7 | Hand-entered payroll and tax payments | Faturası olmayan maaş ve vergi ödemeleri tahmine elle satır olarak eklenir. | arandı | üçüncü taraf | https://floatapp.com/blog/xero-data-cash-flow-forecast | 7 |
| 8 | Cash summary shared with the accountant | Tahminin özeti tek adımda muhasebeciyle paylaşılır. | arandı | resmi sayfa | https://quickbooks.intuit.com/global/cash-flow/ | 6 |

## Veri Girişi (Data Entry) · `line_erp_intake`

Ürün: erp · Alan (eksen): innovation · Mevcut kartlar: Manual Entry → Spreadsheet Import → Document Reading

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Receipt photo read into an expense | Fişin fotoğrafı çekilir; satıcı, toplam ve vergi alanları kendiliğinden okunur. | arandı | resmi sayfa | https://www.freshbooks.com/blog/product-updates-accountants | 2 |
| 2 | Receipts uploaded in bulk | Bir seferde çok sayıda fiş yüklenir, hepsi sırayla okunur. | arandı | resmi sayfa | https://www.freshbooks.com/blog/product-updates-accountants | 2 |
| 3 | Bank statement import that skips duplicates | Aynı ekstre iki kez yüklense de yinelenen hareketler kendiliğinden dışarıda kalır. | arandı | resmi sayfa | https://www.zoho.com/books/help/banking/dashboard.html | 8 |
| 4 | Bank rules that file transactions on their own | Tekrarlayan banka hareketleri kurala göre hesaba oturur, insan yalnız istisnaya bakar. | arandı | resmi sayfa | https://www.zoho.com/books/help/banking/transaction-rule.html | 8 |
| 5 | More statement file formats accepted | Ekstre CSV dışında OFX, QIF ve CAMT.053 gibi biçimlerle de içeri girer. _(Biçim listesi arama özetinden; sayfanın kendisi açılmadı.)_ | arandı | resmi sayfa | https://www.zoho.com/books/banking.html | 8 |
| 6 | Supplier rule that codes later bills the same way | Bir tedarikçi için seçilen hesap ve vergi, sonraki faturalara aynen uygulanır. | arandı | satıcı tanıtımı | https://dext.com/au/integrations/quickbooks | 27 |
| 7 | Held for review with duplicates flagged | Okunan belge yayınlanmadan önce yinelenen ve eksik tedarikçi bilgisiyle işaretlenip bekler. | arandı | satıcı tanıtımı | https://dext.com/au/integrations/quickbooks | 27 |
| 8 | Own inbox address for supplier invoices | Tedarikçi faturaları işletmeye ait bir adrese yönlendirilir, elle yükleme kalkar. | arandı | satıcı tanıtımı | https://dext.com/resources/compare/dext-vs-hubdoc | 27 |
| 9 | Line added by hand when an import fails | İçeri aktarılamayan banka satırı elle eklenip mutabakata girer. | arandı | resmi sayfa | https://www.freshbooks.com/blog/product-updates-accountants | 2 |

## Defter (Ledger) · `line_erp_ledger`

Ürün: erp · Alan (eksen): stability · Mevcut kartlar: Basic Bookkeeping → Chart of Accounts → Automatic Reconciliation

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Month-end close in a fixed order | Dönem kapanışı faturalar, ödemeler, banka mutabakatı, defter kontrolü sırasıyla yürür. | arandı | resmi sayfa | https://jobbag.helpscoutdocs.com/article/151-27-steps-for-happy-month-end | 3 |
| 2 | Exchange rates fetched on the last day | Yabancı para bakiyeleri ayın son günündeki kurla değerlenir. | arandı | resmi sayfa | https://jobbag.helpscoutdocs.com/article/151-27-steps-for-happy-month-end | 3 |
| 3 | Foreign currency revaluation at close | Döviz bakiyeleri dönem sonunda güncel kurla yeniden değerlenir. | arandı | üçüncü taraf | https://vintti.com/blog/how-to-reconcile-foreign-currency-accounts-in-xero-managing-exchange-rate-fluctuations | 28 |
| 4 | Unrealised currency gain and loss accounts | Gerçekleşmemiş kur farkı kendi hesabına yazılır ve ana para biriminde görünür. | arandı | üçüncü taraf | https://vintti.com/blog/how-to-reconcile-foreign-currency-accounts-in-xero-managing-exchange-rate-fluctuations | 28 |
| 5 | Receivables tied out to the control account | Yaşlandırılmış alacak listesi defterdeki kontrol hesabıyla eşitlenir. | arandı | üçüncü taraf | https://netsuite.folio3.com/blog/how-to-close-a-month-end-period-in-netsuite-the-complete-guide/ | 3 |
| 6 | Accruals and depreciation posted before close | Tahakkuk ve amortisman kapanıştan önce deftere işlenir. | arandı | üçüncü taraf | https://netsuite.folio3.com/blog/how-to-close-a-month-end-period-in-netsuite-the-complete-guide/ | 3 |
| 7 | Suggested matches on bank reconciliation | Her banka satırı için defterdeki olası karşılık önerilir, onay tek tıktır. | arandı | resmi sayfa | https://xero.com/us/accounting-software/reconcile-bank-transactions | 9 |
| 8 | Cost-center tags on manual journals | Elle girilen yevmiye satırlarına iki izleme etiketi eklenip raporda ayrılır. _(Kaynak bir bağlayıcı belgesi; etiket sayısı (iki) oradan.)_ | arandı | üçüncü taraf | https://cdn.cdata.com/help/DXN/ado/pg_accountingtable-manualjournals.htm | 28 |

## Stok (Stock) · `line_erp_stock`

Ürün: erp · Alan (eksen): experience · Mevcut kartlar: Stock Count → Warehouse and Shelf → Handheld Scanner

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Lot and serial counts in any order | Sayımda hangi parti ve seri numaralarının sayıldığı, hangilerinin kaldığı görünür. | arandı | resmi sayfa | https://docs.oracle.com/en/cloud/saas/readiness/scm/25b/inv25b/25B-inventory-wn-f36651.htm | 4 |
| 2 | Lot tracking for groups of items | Bir grup ürün tek parti numarasıyla izlenir. | arandı | üçüncü taraf | https://media.unstack.com/media/anchorgroup1/pdf/ds_netsuite_advanced_inventory_wZ2yd2K.pdf | 4 |
| 3 | Serial number on every unit sold | Her satılan birim kendi seri numarasıyla alıştan satışa izlenir. | arandı | üçüncü taraf | https://media.unstack.com/media/anchorgroup1/pdf/ds_netsuite_advanced_inventory_wZ2yd2K.pdf | 4 |
| 4 | Low-stock threshold alert | Eşiğin altına inen ürün için uyarı gelir, sipariş zamanı kaçmaz. | arandı | resmi sayfa | https://apps.shopify.com/built-in-features/inventory | 29 |
| 5 | Bins inside a shelf | Raf içindeki göz ya da kutu bazında konum tutulur. | arandı | resmi sayfa | https://www.zoho.com/inventory/help/bin-locations/ | 10 |
| 6 | Kits built from several items | Birkaç kalemden oluşan paket tek ürün gibi satılır, parçaları stoktan düşer. | arandı | resmi sayfa | https://www.zoho.com/inventory/help/items/composite-items.html | 10 |
| 7 | Incoming stock counted before it arrives | Yoldaki mal satışa açılmadan 'gelen' olarak ayrı sayılır. | arandı | üçüncü taraf | https://stockie.helpscoutdocs.com/article/60-include-incoming-inventory | 29 |
| 8 | Scheduled cycle counts by location | Tüm depoyu kapatmadan belirli ürün ya da konumlar düzenli aralıkla sayılır. | arandı | üçüncü taraf | https://shiphero.com/?p=39470 | 4 |
| 9 | Recount triggered by a big difference | Küçük sayım farkı kabul edilir, büyük fark yeniden sayım ister. | arandı | üçüncü taraf | https://www.cleverence.com/amp/articles/for-business/inventory-erp-software-5827/ | 4 |

## Fatura (Invoicing) · `line_erp_invoicing`

Ürün: erp · Alan (eksen): experience · Mevcut kartlar: Issuing Invoices → Batch Invoicing → Collection Cycle

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Second currency on bulk invoices | Toplu faturalarda müşterinin parası kullanılır, kur otomatik uygulanır. _(PRD §3.2 örnek adıyla aynı.)_ | arandı | resmi sayfa | https://www.zoho.com/en-ng/books/accounting-software/invoice-management/ | 5 |
| 2 | Late fee added after the due date | Vadesi geçen faturaya yüzde ya da sabit gecikme bedeli eklenir. | arandı | resmi sayfa | https://www.lightspeedhq.com/pos/retail/invoicing/ | 5 |
| 3 | Reminders before and after the due date | Hatırlatma vadeden önce ve sonra, seçilen sıklıkla kişiselleştirilerek gider. | arandı | resmi sayfa | https://www.lightspeedhq.com/pos/retail/invoicing/ | 5 |
| 4 | Partial payments against one invoice | Bir faturaya parça parça ödeme gelir, kalan tutar izlenir. | arandı | üçüncü taraf | https://www.softwareadvice.com.au/software/319945/due-com | 5 |
| 5 | Deposit taken on the invoice itself | Kapora ya da kısmi ön ödeme aynı faturanın içinde alınır. | arandı | resmi sayfa | https://www.lightspeedhq.com/pos/retail/invoicing/ | 5 |
| 6 | Progress invoices cut from one estimate | Tek tekliften aşamaya ya da yüzdeye göre birkaç ara fatura çıkar. | arandı | resmi sayfa | https://quickbooks.intuit.com/global/invoicing | 11 |
| 7 | Recurring invoices charged automatically | Tekrarlayan fatura belirlenen aralıkla hem kesilir hem tahsil edilir. | arandı | resmi sayfa | https://www.lightspeedhq.com/pos/retail/invoicing/ | 5 |
| 8 | Invoice look chosen per customer type | Fatura görünümü müşteri grubuna göre ayrı temayla çıkar. | arandı | üçüncü taraf | https://ucollect.helpscoutdocs.com/article/37-using-branding-themes-in-xero | 30 |
| 9 | Customer credit applied to repeating invoices | Müşterinin alacağı tekrarlayan faturaya kendiliğinden düşülür. _(Kaynak bir özellik isteği: bugün elle yapılan işi gösterir, ürünün sunduğunu değil.)_ | arandı | kullanıcı isteği | https://productideas.xero.com/forums/967115-invoices-quotes/suggestions/45065365-repeating-invoice-automatic-application-of-credi | 30 |

## Entegrasyonlar (Integrations) · `line_shared_integrations`

Ürün: shared · Alan (eksen): innovation · Mevcut kartlar: Single Connection → Multiple Integrations → Open API and Webhooks

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Failed deliveries retried with backoff | Karşı taraf cevap vermezse bildirim giderek seyrekleşen aralıklarla yeniden denenir. | arandı | resmi sayfa | https://developer.close.com/api/resources/webhooks | 12 |
| 2 | Delivery history for every notification | Her bildirimin durum kodu ve cevabı kayıtta görünür. | arandı | üçüncü taraf | https://www.mintlify.com/builderz-labs/mission-control/api/webhooks | 12 |
| 3 | Replay of failed notifications | Başarısız bildirimler toplu olarak yeniden oynatılır. | arandı | üçüncü taraf | https://jentic.com/apis/hookdeck.com/hookdeck.md | 12 |
| 4 | Subscription paused after days of failure | Günlerce hata veren bağlantı durdurulur, düzelince elle yeniden açılır. | arandı | resmi sayfa | https://developer.close.com/api/resources/webhooks | 12 |
| 5 | Instant triggers instead of polling | Veri değişince bağlı uygulama anında haber alır, dakikalarca beklemez. | arandı | resmi sayfa | https://help.zapier.com/hc/en-us/articles/8496244568589 | 16 |
| 6 | More triggers and actions in the connector | Otomasyon bağlayıcısı yeni tetikleyici ve eylemlerle genişler. | arandı | resmi sayfa | https://attio.com/changelog/updated-zapier-integration-2 | 16 |
| 7 | Keys limited to chosen resources | Her anahtara yalnız okuma ya da yazma izni verilen kaynaklar tanımlanır. | arandı | resmi sayfa | https://docs.stripe.com/keys/restricted-api-keys | 31 |
| 8 | Event time stamped for reordering | Sıra garantisi olmayan olaylar, üzerindeki zamana göre doğru sıraya dizilir. | arandı | resmi sayfa | https://apidocs.launchdarkly.com/tag/Webhooks | 12 |

## Güvenlik & Yetki (Security and Access) · `line_shared_security`

Ürün: shared · Alan (eksen): stability · Mevcut kartlar: Accounts and Sessions → Roles and Permissions → Audit Trail and Encryption

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Single sign-on for the whole team | Çalışanlar şirket dizinindeki hesapla tek girişle içeri girer. | arandı | resmi sayfa | https://slack.com/resources/why-use-slack/slacks-enterprise-security-features | 13 |
| 2 | Accounts added and removed from the directory | Dizinde açılan hesap ürüne yansır, işten ayrılanın erişimi kendiliğinden kalkar. | arandı | resmi sayfa | https://slack.com/resources/why-use-slack/slacks-enterprise-security-features | 13 |
| 3 | Session length set by the admin | Yönetici oturumun ne kadar açık kalacağını belirler. | arandı | resmi sayfa | https://slack.com/resources/why-use-slack/slacks-enterprise-security-features | 13 |
| 4 | Audit events streamed to security tools | Denetim olayları gerçek zamanlı olarak güvenlik izleme araçlarına akar. | arandı | resmi sayfa | https://slack.com/blog/news/secure-your-slack-data | 13 |
| 5 | Passkeys instead of passwords | Parola yerine telefon ya da cihaz kilidiyle giriş yapılır. | arandı | resmi sayfa | https://support.google.com/a/topic/2759193?hl=en | 32 |
| 6 | Two-step sign-in required for everyone | Yönetici ikinci adımı tüm kullanıcılar için zorunlu kılar. | arandı | resmi sayfa | https://knowledge.workspace.google.com/admin/security/deploy-2-step-verification | 32 |
| 7 | Security-key-only sign-in for admins | Yöneticiler yalnız donanım anahtarı ya da passkey ile girebilir. | arandı | resmi sayfa | https://knowledge.workspace.google.com/admin/security/monitor-the-health-of-your-security-settings | 32 |
| 8 | Backup codes issued by the admin | Zorunlu doğrulamada yedek kodları kullanıcı değil yönetici verir. | arandı | resmi sayfa | https://support.google.com/a/topic/2759193?hl=en | 32 |
| 9 | Access tokens that expire | Komut satırı anahtarları belirli gün sonra kendiliğinden geçersiz olur. _(Stripe CLI anahtarı 90 gün geçerli; arama özetinden.)_ | arandı | resmi sayfa | https://docs.stripe.com/stripe-cli/keys | 31 |

## Dayanıklılık (Durability) · `line_shared_durability`

Ürün: shared · Alan (eksen): stability · Mevcut kartlar: Autosave → Version History → Offline Work

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Restore one deleted page from the bin | Silinen tek sayfa çöp kutusundan, çalışma alanına dokunmadan geri gelir. | arandı | üçüncü taraf | https://thebricks.com/resources/how-to-recover-deleted-notion-pages | 14 |
| 2 | Recovery window longer on bigger plans | Eski sürüme dönüş süresi paketle uzar: 30, 180, 365 gün. | arandı | resmi sayfa | https://www.dropbox.com/help/11 | 33 |
| 3 | Restore keeps the current version too | Eski sürüme dönülünce şimdiki hâl de listede eski sürüm olarak kalır. | arandı | üçüncü taraf | https://gizmodo.com/how-to-recover-any-version-of-a-file-1847161175 | 33 |
| 4 | Conflicting copies kept, never overwritten | İki cihazda aynı not değişince ikisi de saklanır, biri sessizce ezilmez. | arandı | resmi sayfa | https://bear.app/faq/how-bear-pro-handles-conflicted-notes | 19 |
| 5 | Both versions saved as copies | Çakışmada kullanıcı birini atar ya da ikisini ayrı kopya olarak tutar. | arandı | resmi sayfa | https://notesnook.com/help/faqs/what-are-merge-conflicts | 19 |
| 6 | Backup outside the workspace | Çalışma alanı silinse bile çalışan bir yedek dışarıda durur. | arandı | üçüncü taraf | https://simplebackups.com/blog/notion-backup | 14 |
| 7 | Saved-state indicator | Değişikliklerin hâlâ gönderilip gönderilmediği ya da hepsinin kaydedildiği görünür. | arandı | resmi sayfa | https://help.mem.ai/features/offline-mode-syncing.md | 19 |
| 8 | Deleted files listed with their history | Silinen dosyalar listelenir ve sürüm geçmişinden geri getirilir. | arandı | resmi sayfa | https://obsidian.md/help/sync/settings | 44 |

## Mobil & Erişim (Mobile and Access) · `line_shared_mobile`

Ürün: shared · Alan (eksen): experience · Mevcut kartlar: Responsive Interface → Mobile App → Offline Mobile

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Home screen widget for one pinned item | Tek bir not ya da liste ana ekrana sabitlenip dokunuşla açılır. | arandı | üçüncü taraf | https://9to5google.com/2023/03/09/google-keep-single-note-widget/ | 34 |
| 2 | Checkboxes tapped from the widget | Liste maddeleri uygulamayı açmadan widget üzerinden işaretlenir. | arandı | üçüncü taraf | https://9to5google.com/2023/03/09/google-keep-single-note-widget/ | 34 |
| 3 | Quick-capture widget | Ana ekrandaki widget yeni notu tek dokunuşla başlatır. | arandı | resmi sayfa | https://workspaceupdates.googleblog.com/2023/03/google-keep-notes-available-on-home-screen-android-devices.html | 34 |
| 4 | App locked with fingerprint or face | Uygulama açılışta parmak izi ya da yüz tanıma ister. | arandı | resmi sayfa | https://help.zoho.com/portal/hi/community/topic/biometric-unlock-night-mode-sync-and-more-in-your-android-app | 15 |
| 5 | Save from other apps' share menu | Başka uygulamada paylaş denince içerik doğrudan uygulamaya kaydedilir. | arandı | üçüncü taraf | https://f-droid.org/app/com.mhss.app.mybrain | 15 |
| 6 | Widget that scrolls and fades | Widget kaydırılır, saydamlığı ayarlanır. | arandı | resmi sayfa | https://tidynotes.featurebase.app/changelog | 15 |
| 7 | Dark mode kept in step across devices | Koyu tema bir cihazda seçilince öbürlerine de geçer. | arandı | resmi sayfa | https://help.zoho.com/portal/hi/community/topic/biometric-unlock-night-mode-sync-and-more-in-your-android-app | 15 |
| 8 | Quick note from the notification area | Bildirim alanındaki küçük bileşenle uygulamayı açmadan not başlatılır. _(Kaynak eski (2014) bir haber; özellik bugünün sürümünde değişmiş olabilir.)_ | arandı | üçüncü taraf | https://www.cio.de/a/google-keep-for-ios-gets-closer-to-evernote-with-ease-of-use-features,3250259 | 34 |

## Yakalama (Capture) · `line_note_tool_capture`

Ürün: note_tool · Alan (eksen): innovation · Mevcut kartlar: Quick Note → Capture Anywhere → Voice Capture

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Page clipped from the browser | Web sayfasının tamamı ya da seçilen kısmı bir deftere kaydedilir. | arandı | üçüncü taraf | https://iphonelife.com/content/how-to-use-evernote-ultimate-guide | 35 |
| 2 | Email forwarded into a notebook | E-posta özel bir adrese iletilince not olarak düşer. | arandı | üçüncü taraf | https://wiki.mobileread.com/wiki/Evernote | 35 |
| 3 | Paper pages scanned with the camera | Basılı sayfa ya da el yazısı kamerayla taranıp nota dönüşür. | arandı | üçüncü taraf | https://iphonelife.com/content/how-to-use-evernote-ultimate-guide | 35 |
| 4 | Business card scanned into a contact | Kartvizit taranır, metni okunur ve aranabilir olur. | arandı | üçüncü taraf | https://wiki.mobileread.com/wiki/Evernote | 35 |
| 5 | Audio note kept with the note | Ses kaydı notun içine eklenir. | arandı | üçüncü taraf | https://transcribe.com/blog/best-evernote-alternatives | 17 |
| 6 | Transcript under the recording | Ses kaydının altına yazıya dökülmüş metin gelir. _(Kaynak bir topluluk isteği: ihtiyacı gösterir, ürünün sunduğunu değil.)_ | arandı | kullanıcı isteği | https://forum.obsidian.md/t/transcription-of-audio-recordings/29355 | 17 |
| 7 | Clip from the share menu | Başka uygulamadan paylaş menüsüyle içerik nota atılır. _(Kaynak eski (2014) bir haber.)_ | arandı | üçüncü taraf | https://www.iclarified.com/43976/evernote-for-ios-updated-with-touch-id-support-for-unlocking-accounts-ability-to-clip-content-through-share-menus/comments | 17 |
| 8 | PDF marked up in place | Yakalanan PDF üzerine not düşülür. _(Kaynak bir kütüphane el kitapçığı (2017).)_ | arandı | üçüncü taraf | https://elmhurstpubliclibrary.org/lib/wp-content/uploads/EvernoteBasics_Handout_042617SV.pdf | 35 |

## Bağlantı (Linking) · `line_note_tool_linking`

Ürün: note_tool · Alan (eksen): innovation · Mevcut kartlar: Note Links → Link Map → Suggested Links

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Backlinks listed under each note | Bir nota bağlanan bütün notlar o notun altında sıralanır. | arandı | resmi sayfa | https://obsidian.md/help/plugins/backlinks | 18 |
| 2 | Unlinked mentions turned into links | Notun adı başka yerde geçiyorsa tek adımda bağa dönüştürülür. | arandı | resmi sayfa | https://obsidian.md/help/plugins/backlinks | 18 |
| 3 | Graph of one note's neighbours | Tek notun komşularını gösteren küçük harita açılır. | arandı | üçüncü taraf | https://www.mintlify.com/obsidianmd/obsidian-help/getting-started/link-notes | 18 |
| 4 | Unlinked mentions drawn on the map | Bağ kurulmamış anılışlar da haritada bağ gibi görünür. _(Kaynak bir topluluk isteği; özellik gönderilmiş değil.)_ | arandı | kullanıcı isteği | https://forum.obsidian.md/t/graph-view-option-to-show-links-based-on-unlinked-mentions/8802 | 18 |
| 5 | Alternate names for one page | Bir sayfa takma adlarıyla da bağlanır ve aranır. _(Takma ad ayrıntısı arama özetinden (forum); belge sayfası açılmadı.)_ | arandı | resmi sayfa | https://docs.logseq.com/ | 36 |
| 6 | Reference to a single block | Notun tamamı değil, tek paragraf başka yerden anılır. | arandı | üçüncü taraf | https://discuss.logseq.com/t/the-basics-of-logseq-block-references/8458 | 36 |
| 7 | Block embedded where it is referenced | Anılan blok içeriğiyle birlikte başka sayfada görünür. | arandı | üçüncü taraf | https://discuss.logseq.com/t/the-difference-between-logseqs-block-embeds-and-page-embeds/8460 | 36 |
| 8 | Reference count on the original block | Bir blok kaç kez anıldıysa sayısı kaynağında görünür. | arandı | üçüncü taraf | https://discuss.logseq.com/t/the-basics-of-logseq-block-references/8458 | 36 |

## Eşitleme (Sync) · `line_note_tool_sync`

Ürün: note_tool · Alan (eksen): stability · Mevcut kartlar: Cloud Sync → Offline Sync → Live Sync

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Text files merged on conflict | İki cihazda değişen metin dosyaları birleştirilir. | arandı | resmi sayfa | https://obsidian.md/help/sync/troubleshoot | 19 |
| 2 | Latest edit wins for other file types | Metin olmayan dosyalarda en son değişiklik kalır. | arandı | resmi sayfa | https://obsidian.md/help/sync/troubleshoot | 19 |
| 3 | Conflict mode chosen in settings | Çakışmada otomatik birleştirme ya da elle çözüm ayarlardan seçilir. | arandı | resmi sayfa | https://obsidian.md/help/sync/troubleshoot | 19 |
| 4 | Conflicts shown side by side | Çakışan sürümler not listesinde yan yana görünür, kullanıcı seçer. | arandı | resmi sayfa | https://bear.app/faq/how-bear-pro-handles-conflicted-notes | 19 |
| 5 | Sync progress shown in the profile menu | Gönderilmeyi bekleyen değişiklik olup olmadığı görünür. | arandı | resmi sayfa | https://help.mem.ai/features/offline-mode-syncing.md | 19 |
| 6 | Folders left out of sync | Seçilen klasörler yüklenmez ve indirilmez. | arandı | resmi sayfa | https://obsidian.md/help/sync/settings | 44 |
| 7 | Sync settings kept per device | Her cihazın eşitleme ayarı ötekinden farklı olabilir. | arandı | resmi sayfa | https://obsidian.md/help/sync/settings | 44 |
| 8 | Version history of synced notes | Eşitlenen notların eski sürümleri bir ay boyunca saklanır. | arandı | resmi sayfa | https://obsidian.md/help/sync/version-history | 44 |

## Editör (Editor) · `line_note_tool_editor`

Ürün: note_tool · Alan (eksen): experience · Mevcut kartlar: Text Editor → Block Editor → Canvas Editor

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Block reused across pages | Bir blok değişince onu kullanan her sayfada güncellenir. | arandı | resmi sayfa | https://www.notion.com/help/synced-blocks | 20 |
| 2 | Equation block | Matematik formülü sayfaya biçimli olarak yazılır. | arandı | resmi sayfa | https://www.notion.com/help/guides/types-of-content-blocks | 45 |
| 3 | Table of contents from headings | Başlıklardan içindekiler listesi kendiliğinden kurulur. | arandı | resmi sayfa | https://www.notion.com/help/guides/types-of-content-blocks | 45 |
| 4 | Callout blocks | Önemli not renkli ve simgeli bir kutuda öne çıkar. | arandı | resmi sayfa | https://www.notion.com/help/guides/types-of-content-blocks | 45 |
| 5 | Sections that fold away | Ayrıntı bir başlığın altında saklanır, tıklayınca açılır. | arandı | resmi sayfa | https://www.notion.com/help/guides/types-of-content-blocks | 45 |
| 6 | Page templates | Sık kullanılan sayfa düzeni şablon olarak saklanıp yeniden kullanılır. | arandı | resmi sayfa | https://www.notion.com/help/guides/types-of-content-blocks | 45 |
| 7 | Code block with a language tag | Kod bloğuna dil etiketi konur. | arandı | resmi sayfa | https://developers.notion.com/guides/data-apis/enhanced-markdown | 45 |
| 8 | Web page card on the canvas | Tuvale bir web sayfası kartı bırakılır. | arandı | resmi sayfa | https://obsidian.md/help/plugins/canvas | 46 |
| 9 | Whole folder dropped on the canvas | Bir klasör sürüklenince içindeki bütün dosyalar tuvale girer. | arandı | resmi sayfa | https://obsidian.md/help/plugins/canvas | 46 |

## Arama (Search) · `line_note_tool_search`

Ürün: note_tool · Alan (eksen): experience · Mevcut kartlar: Instant Search → Filtered Search → Semantic Search

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Saved search shortcuts | Sık yapılan arama ve süzgeçler kısayol olarak saklanır. | arandı | resmi sayfa | https://help.evernote.com/hc/articles/208313828 | 38 |
| 2 | Search by tag, notebook and date | Arama etiket, defter ve oluşturma tarihiyle daraltılır. | arandı | resmi sayfa | https://help.evernote.com/hc/articles/208313828 | 38 |
| 3 | A tag left out of the search | Belirli etiketli notlar sonuçtan çıkarılır. | arandı | üçüncü taraf | https://www.pcworld.com/article/440233/how-to-find-anything-in-evernote-6-advanced-search-tips.html | 38 |
| 4 | Text found inside scanned pages | Taranan fiş ve faturaların içindeki yazı aramada bulunur. | arandı | resmi sayfa | https://support.apple.com/en-bw/102757 | 38 |
| 5 | Smart folder that gathers all scans | Kurala uyan notlar, hangi klasörde olursa olsun tek akıllı klasörde toplanır. | arandı | resmi sayfa | https://support.apple.com/en-bw/102757 | 38 |
| 6 | Handwriting found by search | El yazısı notlar arama sonucuna girer. | arandı | resmi sayfa | https://goodnotes-team.notion.site/Search-Handwriting-and-Math-Recognition-f626b2af52c3494bb5526ae9e1074b9e | 21 |
| 7 | Text inside images and PDFs searched together | Görsel, PDF ve düz not tek aramada taranır. | arandı | üçüncü taraf | https://www.pcworld.com/article/432330/5-powerful-ways-to-find-anything-in-evernote.html | 21 |
| 8 | Imported PDF text searched | İçe aktarılan PDF'in metin katmanı aramaya girer. | arandı | resmi sayfa | https://goodnotes-team.notion.site/Search-Handwriting-and-Math-Recognition-f626b2af52c3494bb5526ae9e1074b9e | 21 |

## Klip Çıkarma (Clipping) · `line_video_clip_clipping`

Ürün: video_clip · Alan (eksen): innovation · Mevcut kartlar: Manual Cut → Scene Breaks → Automatic Clip Selection

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Clips ranked by hook, flow and value | Çıkan klipler kanca, akış, değer ve gündeme göre puanlanıp sıralanır. | arandı | resmi sayfa | https://help.opus.pro/docs/article/virality-score | 22 |
| 2 | Clips found from a typed topic | Kullanıcı konuyu yazar, uzun videodan o konudaki anlar çıkar. | arandı | üçüncü taraf | https://www.castmagic.io/software-reviews/opus-clip | 22 |
| 3 | Relevance score against the prompt | Klip, yazılan isteğe ne kadar uyduğuna göre puanlanır. | arandı | resmi sayfa | https://help.opus.pro/docs/article/virality-score | 22 |
| 4 | Long clips picked by sight and sound | On beş dakikaya varan klipler görüntü, ses ve duygu ipuçlarından seçilir. | arandı | üçüncü taraf | https://www.castmagic.io/software-reviews/opus-clip | 22 |
| 5 | Hook line laid over the top clips | En iyi kliplerin başına dikkat çeken bir kanca yazısı gelir. | arandı | üçüncü taraf | https://www.castmagic.io/software-reviews/opus-clip | 22 |
| 6 | Moments picked by reading the transcript | Tek başına durabilecek anlar yazıdan bulunur. | arandı | satıcı tanıtımı | https://riverside.fm/clips | 39 |
| 7 | Sentence picked in the transcript becomes a clip | Yazıda seçilen cümle doğrudan klibe dönüşür. | arandı | üçüncü taraf | https://gotranscript.com/public/turn-long-videos-into-social-shorts-with-riverside | 39 |
| 8 | Own page and link for each clip | Her kliple paylaşılabilir bir sayfa ve bağlantı gelir. | arandı | üçüncü taraf | https://gotranscript.com/public/turn-long-videos-into-social-shorts-with-riverside | 39 |
| 9 | Dead air and filler cut in one pass | Boşluklar ve dolgu sözcükleri tek hamlede ayıklanır. | arandı | satıcı tanıtımı | https://www.submagic.co/hi/features/auto-video-editor | 23 |

## Altyazı (Captions) · `line_video_clip_captions`

Ürün: video_clip · Alan (eksen): innovation · Mevcut kartlar: Caption Track → Captions by the Word → Captions Across Languages

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Speaker labels checked after transcript | Konuşmacı etiketleri yazıdan sonra gözden geçirilir. | arandı | satıcı tanıtımı | https://www.bytecap.io/add-captions-to-video | 23 |
| 2 | Word list for names and brands | Özel isim ve marka sözcükleri sözlüğe eklenir, yazı onları doğru çıkarır. | arandı | üçüncü taraf | https://alternativeto.net/software/blitzclip/about/ | 23 |
| 3 | Key words picked out in colour | Cümlenin önemli sözcükleri ayrı renkle vurgulanır. | arandı | satıcı tanıtımı | https://choppity.com/features/captions | 23 |
| 4 | A word emphasised with one click | Yazıdaki bir sözcüğe tıklanınca altyazıda öne çıkar. | arandı | satıcı tanıtımı | https://choppity.com/features/captions | 23 |
| 5 | Caption box and shadow styles | Yazı tipi, boyut, gölge ve arka plan şekli seçilir. | arandı | satıcı tanıtımı | https://choppity.com/features/captions | 23 |
| 6 | Filler words left out of the caption | Eee, ıı gibi dolgu sözcükleri altyazıdan çıkarılır. | arandı | üçüncü taraf | https://wavespeed.ai/docs/docs-api/wavespeed-ai/ai-video-editor-video-captioner | 23 |
| 7 | Brand fonts in captions | Marka yazı tipi altyazıya uygulanır. | arandı | üçüncü taraf | https://www.castmagic.io/software-reviews/opus-clip | 22 |
| 8 | Subtitle file for uploading elsewhere | Altyazı ayrı bir dosya olarak indirilip başka yayın yerine yüklenir. | arandı | satıcı tanıtımı | https://www.veed.io/tools/subtitle-translator | 40 |
| 9 | Captions burned into the picture | Altyazı görüntüye kalıcı olarak işlenir. | arandı | satıcı tanıtımı | https://www.veed.io/tools/translate-subtitles | 40 |

## İşleme Hattı (Pipeline) · `line_video_clip_pipeline`

Ürün: video_clip · Alan (eksen): stability · Mevcut kartlar: Upload and Encode → Render Queue → Distributed Processing

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Direct uploads served ahead of batches | Kullanıcının yüklediği iş, toplu işlerin önüne geçer. | arandı | resmi sayfa | https://transloadit.com/docs/api/queues/ | 24 |
| 2 | Overflow queue when slots run out | Yer kalmayınca fazla iş yedek kuyruğa geçer, yer açılınca döner. | arandı | resmi sayfa | https://transloadit.com/docs/api/queues/ | 24 |
| 3 | Job priority set when submitting | Acil işler düşük öncelikli işlerden önce başlar. | arandı | resmi sayfa | https://aws.amazon.com/about-aws/whats-new/2019/07/aws-elemental-mediaconvert-adds-ability-to-prioritize-transcoding-jobs | 24 |
| 4 | Retries that cannot make duplicate outputs | Zaman aşımından sonra yeniden denenen iş çifte çıktı ve çifte ücret üretmez. | arandı | resmi sayfa | https://transloadit.com/glossary/cloud-transcoding/ | 24 |
| 5 | Cancel a job before it starts | Başlamamış iş iptal edilebilir, başlayan edilemez. | arandı | resmi sayfa | https://5centscdn.net/help/?p=623 | 24 |
| 6 | Failed job retried after fixing the source | Kaynak dosya düzeltilince başarısız iş yeniden gönderilir. | arandı | resmi sayfa | https://5centscdn.net/help/?p=623 | 24 |
| 7 | Cover frame chosen after processing | Kapak karesi işlem bitince seçilir; varsayılan videonun ortasındandır. | arandı | resmi sayfa | https://www.mux.com/docs/guides/set-a-default-thumbnail | 41 |
| 8 | Animated preview made from the video | Videodan kısa hareketli önizleme üretilir. | arandı | üçüncü taraf | https://providers.apievangelist.com/providers/mux-com/ | 41 |
| 9 | Signed callback when the video is ready | Video hazır olunca imzalı bir bildirim gelir. | arandı | üçüncü taraf | https://providers.apievangelist.com/providers/mux-com/ | 41 |

## Kurgu (Editing) · `line_video_clip_timeline`

Ürün: video_clip · Alan (eksen): experience · Mevcut kartlar: Timeline → Multitrack Editing → Editing Together

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Ripple edit that closes the gap | Bir klip silinince arkasındakiler boşluğu kapatacak şekilde kayar. | arandı | üçüncü taraf | https://learn.usecardboard.com/editing/timeline | 25 |
| 2 | Clips snapping to each other | Klipler birbirinin kenarına yapışır, aralarında boşluk kalmaz. | arandı | resmi sayfa | https://www.openshot.org/files/user-guide/timeline.html | 25 |
| 3 | Markers on the timeline | Zaman çizelgesine işaretçi konur, sonra oraya dönülür. | arandı | resmi sayfa | https://www.openshot.org/files/user-guide/timeline.html | 25 |
| 4 | Keyframes for position, scale and opacity | Konum, ölçek ve saydamlık zaman içinde anahtar karelerle değişir. | arandı | resmi sayfa | https://www.openshot.org/files/user-guide/timeline.html | 25 |
| 5 | Light proxy files for editing | Kurgu hafif kopyalarla yapılır, çıktıda orijinal dosyalara dönülür. | arandı | üçüncü taraf | https://workflow.frame.io/guide/resolve-proxies | 42 |
| 6 | Beats marked on the music | Müzikteki vuruşlar çizelgeye kendiliğinden işaretlenir. | arandı | üçüncü taraf | https://www.companionlink.com/blog/2024/12/tips-for-syncing-music-and-video-in-capcut-desktop-for-professional-edits/ | 42 |
| 7 | Speed curve on a clip | Klibin hızı bir eğriyle yavaşlayıp hızlanır. | arandı | üçüncü taraf | https://www.companionlink.com/blog/2024/12/tips-for-syncing-music-and-video-in-capcut-desktop-for-professional-edits/ | 42 |
| 8 | Slip and slide trims | Klibin yeri değişmeden içeriği kaydırılır ya da komşuları birlikte oynatılır. | arandı | üçüncü taraf | https://docs.rs/oximedia-edit | 25 |
| 9 | Silences cut in one action | Yazıda seçilen susmalar tek hamlede kesilir. | arandı | üçüncü taraf | https://gotranscript.com/public/turn-long-videos-into-social-shorts-with-riverside | 39 |

## Çerçeve (Framing) · `line_video_clip_framing`

Ürün: video_clip · Alan (eksen): experience · Mevcut kartlar: Vertical Crop → Brand Template → A Frame for Every Screen

| # | Ad (EN) | Ne yapar | Durum | Kaynak türü | Kaynak | Arama no |
|---|---|---|---|---|---|---|
| 1 | Crop that follows the speaker | Kırpma penceresi konuşan kişiyi izler. | arandı | üçüncü taraf | https://miracamp.com/post/auto-reframe-in-premiere-pro | 26 |
| 2 | Tracking mode picked per shot | Durağan çekim için yavaş, hareketli çekim için hızlı izleme seçilir. | arandı | üçüncü taraf | https://miracamp.com/post/auto-reframe-in-premiere-pro | 26 |
| 3 | Crop path fixed by hand | Konu kaybolursa kırpmanın anahtar kareleri elle düzeltilir. | arandı | üçüncü taraf | https://photography.tutsplus.com/tutorials/how-to-use-auto-reframe-in-premiere-pro--cms-106794 | 26 |
| 4 | Every clip reframed in one go | Çizelgedeki bütün klipler hedef orana tek seferde çevrilir. | arandı | üçüncü taraf | https://miracamp.com/post/auto-reframe-in-premiere-pro | 26 |
| 5 | Titles resized with the new frame | Başlıklar ve hareketli grafikler yeni kadraja göre ölçeklenir. _(Ayrıntı arama özetinden; sayfanın kendisi açılmadı.)_ | arandı | üçüncü taraf | https://miracamp.com/post/auto-reframe-in-premiere-pro | 26 |
| 6 | Margins kept clear of platform buttons | Yazı ve yüz, platformun düğme ve başlık şeritlerinin altında kalmaz. | arandı | satıcı tanıtımı | https://www.kapwing.com/video-editor/tiktok/safe-zone | 43 |
| 7 | Preview of the lower caption area | Reels ve Shorts'ta altta kapanan alan önizlemede gösterilir. | arandı | satıcı tanıtımı | https://www.kapwing.com/video-editor/instagram-reels/safe-zone | 43 |
| 8 | Focus switched to whoever is talking | Kadraj konuşan kişiye geçer. | arandı | satıcı tanıtımı | https://choppity.com/features/captions | 23 |
| 9 | Clips reframed to vertical when picked | Seçilen an dikeye çevrilip yazıyla birlikte hazır gelir. | arandı | satıcı tanıtımı | https://riverside.fm/clips | 39 |

## Arama sorguları

1. accounting software cash flow forecasting release notes new features scenarios recurring items
2. small business ERP data import bank feed receipt capture OCR release notes new features
3. accounting software general ledger month-end close checklist multi-currency revaluation bank reconciliation rules help center
4. inventory management software features reorder points lot tracking batch serial numbers cycle count help center
5. invoicing software features recurring invoices multi-currency late fees payment reminders partial payments help center
6. QuickBooks Cash Flow Planner features what-if scenarios 90-day forecast
7. Xero short-term cash flow forecast expected invoices bills scenarios help
8. Zoho Books import bank statements auto-categorize bank rules receipt autoscan how it works
9. Xero bank reconciliation suggested matches bank rules reconcile multiple currencies foreign currency gain loss
10. Zoho Inventory features batch tracking serial numbers reorder point bin locations cycle counting composite items
11. QuickBooks Online invoice features recurring invoices progress invoicing automatic reminders partial payments multi-currency
12. SaaS integrations improvements webhooks retry delivery logs API rate limits OAuth scopes API keys developer docs changelog
13. Slack Enterprise security features SSO SCIM provisioning audit logs session duration IP allowlist data export
14. Notion or Dropbox restore deleted items version history retention trash recovery backups help center
15. mobile app release notes biometric unlock push notifications home screen widget share extension quick actions productivity app
16. Zapier integrations app changelog new triggers actions custom fields polling vs instant webhooks help
17. Evernote OR Notion OR Obsidian web clipper email to note scan documents voice transcription audio notes help
18. Obsidian backlinks unlinked mentions graph view local graph Roam Logseq bidirectional links features docs
19. note app sync conflict resolution selective sync offline mode sync status indicator help center
20. Notion blocks features templates synced blocks slash commands databases linked views toggles callouts help
21. note-taking app search operators saved searches search within attachments OCR in images PDFs handwriting search
22. Opus Clip features virality score clip length topic keyword curation AI B-roll help center
23. auto captions video editor features speaker labels filler word removal custom vocabulary caption styles animated highlight help
24. video processing pipeline cloud transcoding queue priority retry failed jobs resumable upload progress notifications docs
25. video editor timeline features ripple edit snapping markers keyframes proxy media nested sequences adjustment layers help
26. auto reframe video vertical 9:16 face tracking subject tracking safe zones multiple aspect ratios Premiere Pro help
27. QuickBooks Online email receipts forward to bills inbox auto capture bills Dext Hubdoc features
28. Xero lock dates multi-currency revalue foreign currency balances manual journals repeating journals tracking categories help
29. Shopify inventory transfers purchase orders low stock alerts inventory states available committed incoming help
30. Xero invoices repeating invoices credit notes prepayments overpayments send statements branded invoice themes help
31. restricted API keys granular permissions OAuth scopes API versioning docs Stripe
32. Google Workspace admin passkeys security keys 2-step verification enforcement login challenges suspicious login alerts
33. Google Docs version history name versions restore previous version see changes Dropbox file version history recover deleted files
34. Todoist OR Google Keep OR Evernote mobile widget lock screen quick add share sheet notification reminders Android iOS release notes
35. Evernote web clipper email notes to Evernote scan documents business cards help center
36. Roam Research Logseq block references embeds aliases page properties queries bidirectional linking docs
37. Obsidian canvas editor tables callouts math LaTeX footnotes markdown formatting syntax help
38. Evernote search syntax saved searches search by tag notebook created date; Apple Notes smart folders search scanned documents
39. Descript text-based editing remove filler words studio sound eye contact multicam; Riverside magic clips feature docs
40. YouTube auto-translate captions subtitle formats SRT VTT export translate subtitles glossary dubbing languages Kapwing OR VEED help
41. Mux video API features thumbnails animated GIF preview storyboards watermark webhooks video asset status errors
42. DaVinci Resolve proxy workflow compound clips adjustment clips multicam; CapCut keyframes speed ramp auto beat sync features
43. Canva brand kit templates resize magic switch safe zone TikTok Instagram Reels UI overlay margins video template
44. Obsidian Sync selective sync folders version history deleted files help
45. Notion help page templates, toggle lists, callout block, table of contents block, equations block, code block syntax highlighting
46. Obsidian Canvas help cards connections groups embed notes web pages in canvas
