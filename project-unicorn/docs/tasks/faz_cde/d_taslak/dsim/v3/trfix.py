# Uretilen tablolardaki ASCII Turkce sozcukleri duzgun Turkceye cevirir (kimlik gibi | _ - iceren belirtecler korunur).
import re
_M = """Acik:Açık acik:açık Adim:Adım adim:adım adima:adıma adimi:adımı Ayni:Aynı ayni:aynı Bagli:Bağlı bagli:bağlı Bosta:Boşta bosta:boşta
Buyuk:Büyük buyuk:büyük Buyume:Büyüme buyume:büyüme buyumesi:büyümesi buyukluge:büyüklüğe buyukluk:büyüklük Cekme:Çekme cekme:çekme
cekilen:çekilen cekilir:çekilir Duzeltme:Düzeltme duzeltme:düzeltme dusus:düşüş dususlerin:düşüşlerin dustu:düştü dusuk:düşük dusurmez:düşürmez
gec:geç gecti:geçti GECTI:GEÇTİ OLCULMEDI:ÖLÇÜLMEDİ Olcu:Ölçü olcek:ölçek Gelistirme:Geliştirme gelistirici:geliştirici gelistiricide:geliştiricide
Kacan:Kaçan kacan:kaçan Kapi:Kapı kapi:kapı kapanis:kapanış Karisim:Karışım karisik:karışık kartin:kartın kartinda:kartında karti:kartı kaydi:kaydı
kazanci:kazancı Kisi:Kişi kisi:kişi kisiyi:kişiyi kosu:koşu kosuda:koşuda kosular:koşular kosularinda:koşularında kosulla:koşulla kosullu:koşullu
kosulsuz:koşulsuz kosulsuzdan:koşulsuzdan kosuluyla:koşuluyla kosunun:koşunun kotu:kötü Kucuk:Küçük kucuk:küçük kurali:kuralı kullanilan:kullanılan
medyani:medyanı okumasi:okuması oldugu:olduğu olmali:olmalı once:önce Once:Önce onceki:önceki onden:önden Onden:Önden oneri:öneri oranli:oranlı
payi:payı politikasi:politikası puani:puanı puaninda:puanında rolu:rolü satiri:satırı satir:satır sayisi:sayısı senaryolari:senaryoları
sikligi:sıklığı sinirlari:sınırları sinirli:sınırlı Sinirsiz:Sınırsız sinirsiz:sınırsız Sira:Sıra sira:sıra siradaki:sıradaki sirasi:sırası
sirasiyla:sırasıyla sonuc:sonuç Sonuc:Sonuç soz:söz Soz:Söz sure:süre Surerken:Sürerken surerken:sürerken takim:takım tasarimci:tasarımcı
Testci:Testçi testci:testçi testcisiz:testçisiz tum:tüm yalniz:yalnız yapisal:yapısal yavas:yavaş yetersizligi:yetersizliği yildizi:yıldızı
Yapim:Yapım yuksek:yüksek YUKSEKTE:YÜKSEKTE GOZU:GÖZÜ TITIZ:TİTİZ esikli:eşikli esleme:eşleme eslemede:eşlemede egim:eğim egri:eğri egrisi:eğrisi
gonder:gönder gore:göre gurultuden:gürültüden haftalik:haftalık haftanin:haftanın hazirlik:hazırlık hazirliksiz:hazırlıksız
hazirlanmamisi:hazırlanmamışı hazirlayacak:hazırlayacak hazirlayani:hazırlayanı hazirlayanindan:hazırlayanından hizli:hızlı isi:işi islemez:işlemez
kalani:kalanı kaldigi:kaldığı kalinca:kalınca kalir:kalır kalkani:kalkanı kalmadi:kalmadı kanit:kanıt baslanmis:başlanmış baslar:başlar basi:başı
basina:başına baska:başka baskasi:başkası basqasinin:başkasının bitis:bitiş bolme:bölme bolundu:bölündü ciftleri:çiftleri cok:çok darbogaz:darboğaz
deger:değer degeri:değeri degismez:değişmez degistirme:değiştirme dolulugu:doluluğu dort:dört edilmemis:edilmemiş ayrica:ayrıca ayari:ayarı alim:alım
alir:alır altinda:altında anindaki:anındaki arasinda:arasında artis:artış artisi:artışı asama:aşama asan:aşan asimi:aşımı
Anindaki:Anındaki ilkinin:ilkinin kadroyu:kadroyu ufuklu:ufuklu Hata:Hata Tek:Tek Ters:Ters Surerken:Sürerken Sifir:Sıfır
Vadesi:Vadesi Verilen:Verilen Beklenen:Beklenen Bulunan:Bulunan Mikro:Mikro Sonuc:Sonuç Senaryo:Senaryo Tohum:Tohum Teslim:Teslim
dakika:dakika yeni:yeni kalan:kalan mikro:mikro uymayan:uymayan Uymayan:Uymayan yok:yok cekilen:çekilen sprintte:sprintte
yetersiz:yetersiz yeterli:yeterli iyisi:iyisi iyisiyle:iyisiyle ikiser:ikişer girmez:girmez girer:girer girdi:girdi
sonraki:sonraki sonrasi:sonrası hazirlanmamis:hazırlanmamış hafta:hafta ilerlemesi:ilerlemesi
tabani:tabanı tabana:tabana saf:saf birebir:birebir tablo:tablo sabit:sabit
acilan:açılan adi:adı alabilecegi:alabileceği alanindan:alanından aldigi:aldığı alimda:alımda aninda:anında artirir:artırır asamada:aşamada asmaz:aşmaz
ayrilan:ayrılan azalir:azalır degilse:değilse disi:dışı duser:düşer dusmez:düşmez duzeltmeyen:düzeltmeyen egimi:eğimi farki:farkı gelistirdigi:geliştirdiği
hic:hiç hicbir:hiçbir isde:işte istegi:isteği iyilesir:iyileşir kalacaga:kalacağa karsilastirma:karşılaştırma kartlarin:kartların olculur:ölçülür
onerinin:önerinin planin:planın raporlanir:raporlanır rolune:rolüne sayisiyla:sayısıyla takimi:takımı testcinin:testçinin ust:üst uste:üste ustu:üstü
varir:varır yazili:yazılı yildiz:yıldız kaynakli:kaynaklı Kaynakli:Kaynaklı ESKI:ESKİ is:iş uc:üç tahmin:tahmin eksi:eksi hata:hata Kapi:Kapı
S3'un:S3'ün"""
MAP = dict(x.split(":", 1) for x in _M.split())


def trfix(text):
    def rep(m):
        w = m.group(0)
        return MAP.get(w, w)
    t = re.sub(r"(?<![\w|\-])[A-Za-z]+(?![\w|\-])", rep, text)
    t = t.replace("->", "→")
    t = re.sub(r"(?<=\d)\*(?!\*)", "★", t)
    t = re.sub(r"(?<![\w|\-])-(?=\d)", "−", t)
    return t
