# Soru paketi 3 · Pazar 2

Tarih: 2026-10-21. Hazırlayan: sentez ajanı. Tasarımın son hâli: `pazar2/out/SENTEZ_ERP_PAZARI.md`.
Tek mesajla cevaplanır: "1A", "1B" ya da "1C".

Bu pakette tek soru var. Öbür adaylar senin önceki cevaplarınla kapandı, yeniden sorulmadı:
- Ucuz / standart / pahalı fiyatın çarpanları ve ödülün etkisinin büyüklüğü: ayar sayısıdır, oynanışla ölçülür.
- Hacim indirimi: 30. cevabın ("5★'ın yüksek geliri sorun değil") gereği yok.
- Modül ödülünün karşılığı: üç adaydan ikisi elendi. "Büyük müşteri seni kısa listeye alır" demoda 5★'ı açardı (5. cevap);
  "itibar artar" oyuncuya görünmezdi (gizli etki yok kuralı). Kalan: o modülü isteyen müşteriler 12 ay daha sık gelir.
- Müşterinin ürünle ilgisiz nedenle ayrılması: 17 Ekim cevabın ("düşük ihtimalle, nedeni yazılarak") geçerli.
- Hedef sektör seçimi ve sektörlerin artı ve eksileri: 26. cevapta "sonraki konu" dedin.

---

## Soru 1. Yapay zekâ dönemi oyuna bir kez mi gelsin, iki kez mi?

**Araştırma ne buldu.** Gerçek ERP pazarında yapay zekâ iki dalgada geldi. İlk dalga 2017-2018'deki "akıllı otomasyon"
duyurularıydı: SAP Mayıs 2017'de, Oracle Ekim 2017'de, NetSuite Nisan 2018'de ("ilk akıllı bulut ERP"), Microsoft Eylül 2018'de
duyurdu. Bu dalga olgun üründen çok duyuruydu: Microsoft'un modülleri duyuru günü hazır değildi ("önümüzdeki aylarda"), Oracle'ınkiler
fiyatı açıklanmamış ayrı eklentiydi, analistler o yıl makine öğrenmesini "abartılı beklentinin zirvesinde" görüyordu. İkinci dalga
2023'teki sohbet eden yapay zekâ asistanıdır: Microsoft Mart 2023'te, SAP ve Oracle Eylül 2023'te. 2019 ve 2020'ye özgü bir dönüm
noktası bulunamadı.

**Soru nereden çıktı.** 27. cevapta örnek olarak "YZ furyası, 2020 civarı" dedin. Önceki tasarım ve simülasyon tek bir YZ hattını
2023'te açıyordu. Kaynaklar ise 2018 ve 2023'ü gösteriyor. Hangisini seçtiğin, oyunun ortasında (2016-2023 arası, demo sonrası
gövdenin ilk yarısı) oyuncunun önüne kaç tane büyük "erken mi gireyim" kararı geleceğini değiştiriyor.

**Oyuncu örneği.** Nisan 2018, oyunun yaklaşık 330. haftası. 12 kişilik bir ekibin var, Stok ve Üretim'de güçlüsün. Haber şeridinde
"Ardenna akıllı otomasyonlu sürümünü duyurdu" satırı düşüyor.

- **A) Tek dalga, 2023.** Yukarıdaki haber hiç gelmez; oyuncu 2023 Mart'a kadar yapay zekâ görmez. 2023'te "YZ yardımcısı" hattı
  açılır, herkes sıfırdan başlar; oyuncu tek bir büyük karar verir: erken mi gireyim, bekleyeyim mi. Sıklık: oyunda bir kez,
  yaklaşık 574. haftada (normal hızda 3,6 saat oynamışken). Oyuncu ne görür: 2016-2023 arasında yeni kademe açılımları ve API hattı
  dışında büyük teknoloji olayı yoktur. Bedel: en az içerik (bir hat, bir Ar-Ge araştırması). Gerçek tarihlerle tutarlı ama ilk
  dalgayı atlar.
- **B) İki dalga, 2018 ve 2023.** Nisan 2018'de "Akıllı otomasyon" araştırması ve hattı açılır. İlk kademesi az kazandırır ve
  ekranda öyle yazar ("ilk dalga: kazancı küçük, rakipler de yeni"); 2020 civarı ikinci kademesi açılıp olgunlaşır (senin
  örneğin buraya denk gelir). 2023'te "YZ yardımcısı" ayrıca açılır, herkes yine sıfırdan başlar. Oyuncu iki kez karar verir:
  2018'de "erken girip az kazanayım mı, bekleyeyim mi", 2023'te büyük dalga. Oyuncu ne görür: 2018'de "Ardenna duyurdu" haberi,
  Ar-Ge'de yeni araştırma, araştırma bitince seçtiği modüllerin tavanı bir kademe yükselir. Bedel: bir hat ve bir Ar-Ge
  araştırması daha, yaklaşık 20-25 metin satırı (Türkçe ve İngilizce, hesap). Risk: ilk dalgaya erken giren oyuncu "boşa
  harcadım" hissedebilir; bunu ekrandaki "kazancı küçük" satırı ve 2020'deki olgunlaşma karşılar.
- **C) Tek dalga, 2020 civarı.** Yapay zekâ bir kez, 2020'de gelir; 2023 ayrı bir olay olmaz. Oyuncu tek kararı oyunun ortasında
  verir (yaklaşık 420. hafta). Bedel: A ile aynı içerik. Gerçek tarihlerle tutmaz: 2020'ye özgü bir olay yok, 2023'ün asistan
  dalgası ise oyunda görünmez.

**Ajanın görüşü:** B. Kaynaklarla uyumlu, senin "2020 civarı" örneğin ikinci kademede yaşıyor, "2-3 yılda ERP bitmesin" isteğine
2018 ile 2023 arasında bir araştırma kararı ekliyor ve yeni bir sistem değil, dönem tablosunda bir satır daha.

**Cevaptan sonra ne olur.** Dönem tablosunun YZ satırları senin seçimine göre yazılır (sim'in `eras.json`'u ve sentezin §3.3, §9.1
bölümü); simülasyon ilk koşusunda bu satırlarla döner. O zamana kadar sentez B'yle yazılı durur, kod ve sim YZ satırlarına dokunmaz.
