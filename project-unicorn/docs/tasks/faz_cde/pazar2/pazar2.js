export const meta = {
  name: 'pazar2-erp-pazari',
  description: 'Gerçek ERP pazarı önce: ürün evrimi, satış ve koltuk, sektör-modül, rakip şirketler, dönem kilitleri; tek tasarım ve Erdem soruları',
  phases: [
    { title: 'Araştırma', detail: 'A1-A3 gerçek pazar, B1-B2 oyunlar, K kod' },
    { title: 'Doğrulama', detail: 'yük taşıyan iddialar kaynağında' },
    { title: 'Sentez', detail: 'ERP pazarı modeli, sim planı, sorular' },
  ],
}

const ROOT = 'C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/'
const OUT = ROOT + 'docs/tasks/faz_cde/pazar2/out/'
const PREV = 'C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/1eb70ce4-b7b7-4a33-a29b-4043e7472f47/scratchpad/beklenti/'

const CTX = `
BAĞLAM (Project Unicorn): Godot ile yapılan şirket yönetimi oyunu, Steam hedefi %90 üstü olumlu yorum. Oyuncu bir yazılım
şirketi kurar; ilk ürün türü ERP (ayrıca not aracı ve video B2C türleri var). Takvim 1 Ocak 2012'de başlar, bir oyun tiki bir
haftadır; oyun sahibi Erdem bir bitiş yılı düşünüyor (örnek 2030). Ekip 1 kişiden 50 kişiye büyüyebilir; B2B'de yüzlerce hesap
olabilir. Ürün "alanlardan" ve hatlardan oluşur, sprint kartları ve Ar-Ge ağacıyla gelişir.
ÖNCEKİ ARAŞTIRMA REDDEDİLDİ: ${PREV} altındaki R1-R6, T1, T2, SENTEZ_BEKLENTI.md ("Pazar merdiveni") yalnız oyun mekaniği
çerçevesinde kaldı; Erdem "sığ, çiğ" buldu. Onları OKU ama tekrar etme; gerçek ERP pazarıyla derinleştir.
ERDEM'İN 2026-10-20 KARARLARI (bağlayıcı; ayrıntı ${ROOT}docs/tasks/faz_cde/ERDEM_KARARLAR_2026-10-20.md):
1. Beklenti ekranda metrik olarak gösterilmez. Müşteri ilişkisi iyi tutulur, ürün düzenli gelişir, istekler karşılanırsa memnun
   kalır; büyüyen müşteri zaman zaman yeni şey ister. Beklenti İSTEK olarak gelir: yıl ortasında ("şuna ihtiyacımız var") ya da
   yenilemede ŞART olarak ("rakiplerde olan şu alanınız zayıf, yenilerken bunu istiyoruz", "standardın altındaki şunu getirin yoksa gideriz").
   Yeni müşteri: "bu modül bizim için önemli, sizde istediğimiz seviyede değil".
2. Kopyalama mekaniği YOK. Rakipler bizim gibi şirkettir: aynı kart listesini ve Ar-Ge ağacını kendi büyüklükleri ve çalışan
   dağılımlarıyla yürütür. Dev rakip yüksek başlar ve aynı yol haritasını izler; onu geçmek uzun sürer. Oyuncu farkı hız, verim,
   satış, destek ve Ar-Ge'de öne geçerek açar (ör. YZ dönemi gelince ilk atılımı yapan şirketlerden olmak). Oyuncuya liderlik
   bilgisi verilip verilmeyeceği ayrı sorudur.
3. Rakip sürümleri ERP pazarında bir SEKTÖR STANDARDI oluşturur; büyük hesap daha özellikli ürüne yönelir; ürün bu standarda
   göre okunur. Asıl sorular: standart nasıl büyür ve oyuncuya nasıl gösterilir.
4. Sektörler ya yalnız ad olarak kalır ya da MODÜLLERLE anlam kazanır (ERP'de fatura, İK, lojistik gibi modüller; sağlık firması
   lojistik modülü almaz). Satış görüşmesinde müşteri istediği modülleri ve koltuk sayısını söyler, oyuncu teklif verir.
5. Koltuk artışı beklentiyi artırmaz; koltuk müşterinin büyüklüğüne ve memnuniyetine göre artar ya da artmaz; her müşteri büyümez,
   1★ sürekli koltuk almaz; her yenilemede koltuk değişmez. Müşteri yıldızı 5 basamağa çıkar (KOBİ 3-10 koltuk, dev 100-1.000);
   yıldız yenilemede değişebilir.
6. Tavan çok uzakta: SAP gibi yıllar süren ürün geliştirme; Ar-Ge ve yıla bağlı kilitlerle yeni şeyler açılır; erken yıllarda
   tavana varılamaz, 2020'de en çok o dönemin tavanı; oyunun bitiş yılı var.
7. Takvim sıkışmaz (hafta süresi sonra kalibre edilir).
8. Geliştirilmeyen ürünün görünür bir cezası olmalı ("geliştirmesem de olur" yorumu istenmez); hataya mı yeni özelliğe mi bağlı, tasarlanacak.
9. Satışçının "en az %60" kapanış tabanı kalkar; satışçı yıldızının neyi etkileyeceği araştırılır (hesap büyüklüğüne oranla
   kapanış ihtimali, süre, başka neler), oyuncuyu tatmin edecek biçimde.
Genel kurallar: oyuncu her düşüşün nedenini görebilir ve etkileyebilir (gizli gider ve ceza yok); kural 1 kişide de 50 kişide de
kırılmaz, oranla ölçeklenir; olabildiğince basit; her mekanikte "oyuncunun oynanışını nasıl etkiler".
`

const RULES = `
ARAŞTIRMA KURALLARI (zorunlu):
- Kaynak sicili: S#, URL, yayıncı, yayın tarihi, erişim tarihi, güven (Yüksek/Orta/Düşük). URL'siz kaynak sayılmaz. Satıcının
  kendi ürününü anlatan sayfası Düşük; analist raporlarının satıcı sponsorlu özetleri Düşük; resmî sürüm notları, yıllık raporlar
  (SAP/Oracle/Microsoft 10-K, faaliyet raporu), hakemli çalışma, bağımsız anket (Panorama Consulting, KeyBanc, Bridge Group) Orta-Yüksek.
- Her olgu cümlesi [S#] taşır ya da (varsayım) diye işaretlenir; [BOŞLUK], [SIÇRAMA], [DEĞERLENDİREMEM], [GÖRÜŞ] etiketleri.
  Bulunamayan "bulunamadı" yazılır, uydurulmaz. Sayı varsa sayı, yıl varsa yıl.
- Başarısız ve eleştirilmiş örnekler AYRI aramayla bulunur (başarısız ERP projeleri ve satıcıları; oyunlarda olumsuz Steam yorumu).
- Arama bütçesi aşağıda; WebFetch serbest (bilinen birincil sayfaları doğrudan oku: Wikipedia sürüm tarihçeleri, resmî sürüm
  notları, yatırımcı sunumları). Bütçe bitince model bilgisiyle yazma; "belirsiz (kanıtsız)" yaz.
- Oyun koduna ve repo dosyalarına yazma; yalnız kendi çıktı dosyanı yaz. Türkçe, sade dil.
- Her bölümün sonunda "Oyuna ders" maddeleri: bu bulgu oyuncunun hangi kararını, ne sıklıkta doğurur.
`

const SCHEMA = {
  type: 'object',
  properties: {
    file: { type: 'string' },
    summary: { type: 'string', description: 'en çok 250 kelime' },
    lessons: { type: 'array', items: { type: 'string' } },
    numbers: { type: 'array', items: { type: 'string' }, description: 'kaynaklı sayılar, her biri [S#] ile' },
    failures_found: { type: 'array', items: { type: 'string' } },
    searches: { type: 'integer' },
    evidence: { type: 'string' },
    gaps: { type: 'array', items: { type: 'string' } },
  },
  required: ['file', 'summary', 'lessons', 'numbers', 'failures_found', 'searches', 'evidence', 'gaps'],
}

const TOPICS = [
  { key: 'A1_erp_evrimi', budget: 20, prompt: `
KONU: ERP ürünleri yıllar içinde nasıl gelişti ve "sektör standardı" nasıl oluştu (2005-2026, 2030 öngörüsü).
İncele: SAP (R/3, ECC, Business One, Business ByDesign, S/4HANA 2015, RISE, Joule YZ), Oracle NetSuite (2008 öncesi bulut ERP,
SuiteSuccess), Microsoft Dynamics (NAV/AX → Business Central, 365), Odoo (OpenERP, modüler uygulama mağazası, sürüm ritmi), Infor,
Epicor; Türkiye: Logo (Tiger, j-Platform, Netsis satın alımı), Mikro, Nebim, Uyumsoft. Her biri için: hangi modüller hangi yıl geldi,
sürüm ritmi (yıllık/çeyreklik), ekip büyüklüğü ya da Ar-Ge harcaması (rapor varsa), yeni girişimin devle nasıl yarıştığı
(NetSuite ve Odoo'nun yükselişi gibi), bir özelliğin "fark yaratan"dan "olmazsa olmaz"a dönüş anları (bulut, mobil, API/
entegrasyon pazarları, e-fatura/e-defter zorunluluğu (Türkiye 2014-2020), KVKK 2016 / GDPR 2018, uzaktan çalışma 2020, YZ 2023+).
Çıktıda bir zaman çizelgesi tablosu (yıl, olay, hangi modül/alan standart oldu, kaynak) ve "2012'de başlayıp 2030'da biten bir
oyunda dönem kilitleri ne olabilir" bölümü. Başarısızlar: geride kalan, çöken ya da satın alınan ERP satıcıları (ör. eski on-prem
satıcıların bulut geçişi), başarısız büyük ERP sürümleri.` },
  { key: 'A2_erp_satis', budget: 22, prompt: `
KONU: Gerçek ERP satışı ve hesap yaşam döngüsü, müşteri büyüklüğüne göre.
İncele: KOBİ / orta / büyük / kurumsal müşteri kaç kullanıcı (koltuk) alır, hangi modüllerle başlar, teklif nasıl kurulur
(modül × koltuk, kademeler, kurulum bedeli), satış döngüsü süresi büyüklüğe göre, RFP ve demo süreci, kazanma oranları,
satışçının deneyim ve kıdeminin etkisi (kota tutturma, ramp süresi, büyük hesap uzmanlığı: Bridge Group, RepVue, Gartner/CSO
Insights ve benzeri), yenilemede koltuk ne sıklıkla ve ne kadar değişir, genişleme (yeni modül alma) ne sıklıkla, ayrılma
nedenleri ve oranları büyüklüğe göre, ERP'nin geçiş maliyeti (switching cost) ve kilitlenme, yenileme pazarlığında müşterinin
şart koşması ve özellik isteği. 5 basamaklı bir müşteri ölçeği için koltuk bantları öner (kaynaklı). Satışçı yıldızı (1-5) için
oyuna uyarlanabilir etkiler listesi (kapanış ihtimali, süre, indirim, hangi büyüklükte işe yaradığı). Başarısızlar: batan ERP
projeleri (Panorama, kamuya açık davalar), satışın aşırı söz verip müşterinin ayrıldığı vakalar.` },
  { key: 'A3_sektor_modul', budget: 10, prompt: `
KONU: Hangi sektör hangi ERP modüllerini ister.
İncele: imalat (MRP, üretim planlama, kalite), dağıtım ve lojistik (WMS, sevkiyat), perakende (POS, stok, çok kanallı), hizmet
ve danışmanlık (proje muhasebesi, PSA, zaman takibi), sağlık, inşaat, gıda, e-ticaret, kamu. Her sektör için: çekirdek modüller
(herkesin istediği: finans, muhasebe, fatura, satın alma, İK/bordro), sektöre özgü modüller, entegrasyon ihtiyaçları, düzenleme
şartları (Türkiye: e-fatura, e-irsaliye, KVKK). Çıktıda sektör × modül matrisi (zorunlu / sık / nadir) ve "oyunda sektörler
modüllerle nasıl anlam kazanır, kaç sektör ve kaç modül yeter" önerisi. Başarısız: tek modülle tüm sektörlere satmaya çalışan
ya da dikey (vertical) ERP'lerin genel ERP'ye kaybettiği/kazandığı örnekler.` },
  { key: 'B1_rakip_sirketler', budget: 18, prompt: `
KONU: Oyunlarda rakiplerin oyuncuyla AYNI kurallarla çalışan şirketler olarak simüle edilmesi.
İncele (mekanik dökümü): Software Inc. (yapay zekâ şirketleri ürün tasarlar, çalışan tutar, pazar payı, satın alma), Capitalism
Lab / Capitalism II (rakip şirketlerin Ar-Ge yarışı, ürün kalitesi ve fiyatı), Mad Games Tycoon 2 (rakip stüdyolar), Big Ambitions
(adlı rakipler), Football Manager (yapay zekâ kulüpleri aynı kuralla transfer ve kadro), Motorsport Manager (rakip araç geliştirme),
Offworld Trading Company, Startup Company. Her biri için: rakip oyuncuyla aynı kuralları mı izliyor yoksa senaryo mu; rakibin
büyüklüğü/ekibi/bütçesi gelişimini nasıl belirliyor; oyuncu rakibin ilerleyişini nereden görüyor (haber, pazar ekranı, sürüm
listesi); dev rakibi geçmek ne kadar sürüyor; simülasyonun başarım maliyeti; oyuncunun öne geçtiğini bilmesi (liderlik bilgisi)
nasıl gösteriliyor. Başarısızlar: rakibin pasif, haksız, görünmez ya da hile yapıyor bulunduğu örnekler (Steam olumsuz yorum, forum).` },
  { key: 'B2_donem_kilit', budget: 18, prompt: `
KONU: Oyunlarda yıla bağlı teknoloji kilitleri, uzun ilerleme, bitiş yılı, geç oyun ve geliştirmemenin cezası.
İncele: Game Dev Tycoon (yıla göre açılan konular/motor özellikleri, oyun 30-35 yılda biter), Mad Games Tycoon 2 (yıl, motor
özelliklerinin eskimesi, bitiş yılı), Software Inc. (yıla göre teknoloji seviyeleri, eskiyen ürün), Civilization (çağlar),
Anno 1800, OpenTTD (araç modelleri yıla bağlı), Capitalism Lab (teknoloji yılları), Football Manager (sezonlar). Her biri için:
bitiş yılı var mı ve neden; geç oyunda "her şeyi açtım" anına ne kadar kalıyor ve oyuncular ne diyor; geliştirmeyi bırakan
oyuncu nasıl cezalanıyor (eskime, satış düşüşü, puan); ceza oyuncuya nasıl görünüyor. Başarısızlar: geç oyunu boş, çözülmüş ya
da sıkıcı bulunan oyunlar; eskime cezası haksız ya da görünmez bulunan örnekler.` },
]

const KOD = `${CTX}
GÖREV: Kod haritası (yalnız oku, yazma). Proje kökü ${ROOT}. Önceki harita ${PREV}R5_kod_haritasi.md; tekrar etme, şunları ekle:
1. Sektörler: nerede tanımlı, kim okuyor, oyuncu nerede görüyor (dosya:satır). Kaldırılırsa ya da modüle bağlanırsa neler etkilenir.
2. Müşteri yıldızı ve koltuk: yıldızın tanımı (1-3), koltuk bantları, yıldızı okuyan her sistem ve ekran; 5 basamağa çıkarmanın
   dokunacağı yerler (kayıt şeması dahil).
3. ERP'nin hatları ve alanları: bugün "modül" kavramına en yakın ne var (hat, alan, Ar-Ge düğümü); sprint kart kataloğu ve Ar-Ge
   ağacı nerede, kaç kart/düğüm, yıl ya da dönem kilidi var mı.
4. Rakipler: rival_catalog, rivals.json, RivalRegistry: rakiplerin aynı kart listesini/Ar-Ge ağacını yürütmesi için ne gerekir.
5. Satışçı: yıldızı neyi etkiliyor bugün (dosya:satır).
6. Durgunluk: ürün güncelleme almazsa bugün ne oluyor.
Çıktı: ${OUT}K_kod_haritasi.md. Görmediğini "bulunamadı" yaz.`

phase('Araştırma')
const [kod, ...research] = await parallel([
  () => agent(KOD, { label: 'K kod haritası', phase: 'Araştırma', model: 'sonnet', effort: 'high',
    schema: { type: 'object', properties: { file: { type: 'string' }, summary: { type: 'string' } }, required: ['file', 'summary'] } }),
  ...TOPICS.map(t => () => agent(`${CTX}\n${RULES}\nARAMA BÜTÇEN: en çok ${t.budget} WebSearch.\n${t.prompt}\nÇIKTI DOSYASI: ${OUT}${t.key}.md (kaynak sicili en sonda).`,
    { label: t.key, phase: 'Araştırma', schema: SCHEMA, model: 'sonnet', effort: 'high' })),
])
const ok = research.filter(Boolean)
log(`Araştırma ${ok.length}/5, toplam arama ${ok.reduce((s, r) => s + (r.searches || 0), 0)}`)
const files = [kod && kod.file, ...ok.map(r => r.file)].filter(Boolean).map(f => '- ' + f).join('\n')

phase('Doğrulama')
const verify = await agent(`${CTX}\nGÖREV: Şüpheci doğrulama. Oku:\n${files}\nTasarıma en çok yük bindiren ~15 iddiayı (özellikle sayılar: koltuk bantları, satış süreleri, kazanma oranları, yenileme ve koltuk değişim sıklığı, modül-sektör eşleşmesi, ERP zaman çizelgesi yılları, oyun mekanikleri) kaynağında AÇ ve oku (en çok 12 WebSearch, WebFetch serbest). Her biri: doğrulandı / kısmen / yanlış / açılamadı; eski veri güncelmiş gibi mi; tek satıcı kaynağı mı taşıyor; başarısız örnek gerçekten var mı. Çıktı ${OUT}V_dogrulama.md.`,
  { label: 'V doğrulama', phase: 'Doğrulama', model: 'sonnet', effort: 'high',
    schema: { type: 'object', properties: { file: { type: 'string' }, summary: { type: 'string' }, refuted: { type: 'array', items: { type: 'string' } }, searches: { type: 'integer' } }, required: ['file', 'summary', 'refuted', 'searches'] } })
const all = files + (verify ? '\n- ' + verify.file : '')

phase('Sentez')
const synth = await agent(`${CTX}
Oku:\n${all}
Ayrıca Faz D'nin atama araştırması ${ROOT}docs/tasks/faz_cde/d_taslak/ altında bittiyse (yeni bir atama/verim raporu) oku; bitmediyse
rakiplerin "aynı kart listesiyle çalışması" kısmının ona bağlı olduğunu yaz.
GÖREV (kıdemli tasarım yönetmeni): Erdem'in kararlarına uyan TEK bir "ERP pazarı modeli" tasarla. Kapsam:
1. Modüller ve sektörler: ERP hangi modüllerden oluşur, sektör neyi belirler, müşteri hangi modülleri ister; bugünkü alan/hat
   modeliyle ilişkisi (yeniden adlandırma mı, yeni yapı mı).
2. Müşteri: 5 yıldız, koltuk bantları, büyüme ve küçülme, yıldızın yenilemede değişmesi, her yenilemede koltuk değişmemesi.
3. Satış akışı: görüşmede modül ve koltuk talebi, teklif, satışçının yıldızının etkileri (%60 taban yok), kayıp nedenleri.
4. Sektör standardı: rakiplerin sürümlerinden nasıl doğar, büyük hesap neden daha özellikli ürüne yönelir, oyuncuya nasıl
   gösterilir (sayı metrik değil; istek, şart, haber, karşılaştırma). Liderlik bilgisi gösterilsin mi: seçenekleriyle.
5. Beklentinin sesi: yıl ortası istek ve yenileme şartı; ne zaman, ne sıklıkta, kaç hesapta; angarya olmadan (yüzlerce hesap).
6. Rakipler: aynı kart listesi ve Ar-Ge ağacıyla, büyüklüğüne ve çalışan dağılımına göre ilerleyen şirketler; dev, yerleşik,
   girişim; oyuncunun öne geçme yolları; başarım maliyeti.
7. Dönem ve tavan: 2012'den bitiş yılına (seçenekleriyle) dönem kilitleri, Ar-Ge'de öncü olma (YZ gibi), tavanın uzaklığı.
8. Durgunluk cezası: hata ve yeni özellik ayrımı, görünürlüğü.
9. Ölçek (1-50 kişi, yüzlerce hesap) ve kaçak büyüme / ölü bölge kontrolü.
10. Pre-mortem (3 yol: kanıt, aktör tepkisi, bağımlılık) ve olumsuz Steam yorumunun tek cümlesi.
11. Kod öncesi python simülasyonu planı (kapılar ve ölçekler).
12. Faz Q, C, D ve Ar-Ge'ye etkisi: neler yeniden yazılır, neler aynı kalır; C'nin şu an kodladığı C1/C2/C4/C7/C9'a etkisi.
13. Erdem'e karar soruları: YALNIZ araştırmadan sonra hâlâ onun kararı olan ve tasarımı değiştiren sorular; her biri oyuncu
    örneğiyle, 2-3 gerçek seçenek, oyuncu ne görür, bedel; tek listede, numaralı ve harfli (Erdem tek mesajla cevaplar).
    Seçeneklere "önerilen" etiketi koyma; görüşün varsa "ajanın görüşü" diye ayrı satırda.
Kaynak sicilini devral. Çıktı: ${OUT}SENTEZ_ERP_PAZARI.md; ilk bölüm en çok 15 satırlık özet. Oyun koduna yazma.`,
  { label: 'Sentez', phase: 'Sentez', model: 'opus', effort: 'xhigh',
    schema: { type: 'object', properties: { file: { type: 'string' }, summary: { type: 'string' }, questions: { type: 'array', items: { type: 'string' } } }, required: ['file', 'summary', 'questions'] } })

return { kod, research: ok, verify, synth }
