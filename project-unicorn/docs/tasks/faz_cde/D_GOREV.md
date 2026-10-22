# Faz D görev yazısı · Ekip modeli (role göre puan, yıldız, uyum, testçi, PM)
Önce `ORTAK.md`'yi oku. Model: Opus, yüksek. Önce `D_ARASTIRMA.md` gelir, onu oku.

**Durum:** A ve B şu an uygulanıyor. Planın A ile B bittikten sonra değerlendirilecek. A'nın düzeltme kartı eforunu
(1, 2 ya da 3) ve B'nin kâğıt ve olaylarındaki rol seslerini olmuş say. Bunlara dayanan varsayımları "A/B varsayımı"
diye işaretle.

## 1. Amaç (Erdem'in sözleriyle)
**Tur 1**
- "Tasarımcı, ürün yöneticisi, geliştirici, testçi hepsi aynı SP'yi mi üretmeli?"
- "Geliştirici sayısı SP'yi mi belirlemeli?"
- "Diğer oyunlar nasıl yapıyor, best practice ne?"
- "İşe alınan kişinin yıldızı fark etmeli."

**Tur 2**
- "Geliştirici geliştirme puanı üretsin, tasarımcı tasarım puanı üretsin, testçi test puanı üretsin. Ama bunu karta
  nasıl yansıtmalıyız? Bu kart şu kadar tasarım puanı istiyor, şu kadar development istiyor gibi mi kurgulamak lazım?
  … O kart bu total geliştirme puanından ne kadar efekt alıyor ve ne kadar bir sürede yapılıyor? … Burada yazdığın
  şeyler hep çok ucu açık, vague bırakmışsın."
- "Bedeli büyük evet, yapacak bir şey yok. Bunun doğru hesaplanması şart. Bu oyunun core mekaniği."

## 2. Bugünkü akış
**Puan hesabı**
- `sprint_system.gd:1279-1294`. Kişinin haftalık puanı = 2 (`person_points_week`) × beceri bandı × verim × saat.
  - Beceri bandı rolün ana alanının 0–10 puanından okunur: 0,75 / 1,0 / 1,25, sınırları 3 ve 6.
  - Verim `HRSystem.productivity`'den, saat `hours_output_mult`'tan gelir.
- Kurucu bantsızdır: `founder_mult`.
- `points_for` işe alım dosyasında da okunur.
- **Sorun:** 4, 5 ve 6 puanlık kişiler aynı puanı üretiyor. Yıldız neredeyse hiç fark etmiyor.

**Kapasite ve aşamalar**
- Kapasite = ekip puanı × sprint haftası (`:446-450`). 125% tavanına kadar "+" ile kart eklenebilir.
- Aşamalar tasarım, geliştirme, test. Payları (`data/product/sprint.json:7`):
  - özellik 0,2 / 0,6 / 0,2,
  - düzeltme 0 / 0,7 / 0,3,
  - araştırma 1 / 0 / 0.
- Haftalık atama otomatik (`_assign`, `:754-781`). Yanlış roldeki kişi yarı hızla çalışır.

**Hatalı kapanış**
- Test aşaması testçisiz çalışılırsa kart "faulty" olur (`:796`).
- Kapanışta %40 zar atılır (`:1027`; `sprint.json:28` `faulty_chance`).

**Roller ve alanlar**
- 6 rol (`hr_constants.gd:304-316`). Ana ve ikincil alanlar `:86-95`.
- Alan puanı 0–10. Yıldız = puan / 2, en fazla 5★.
- Rolün tutabileceği alanlar `HRConstants.can_hold_area`.
- Ekip alan ve iş adaptörü: ALAN ile İŞ aynı liste. `clear_areas` = `clear_jobs`. `assign_area` kişiyi
  `AREA_PRIMARY_JOB`'ın işine oturtur.

**PM**
- Çeyrek görünümünü açar ve sprint planının devrini (delegate) mümkün kılar.
- Plan beklemesi (`awaits_plan :394-401`) PM'e devredilmişse saat durmaz.

**Verim**
- Verim eğrisi, moral payı ve gün içi düşüş `hr_constants.gd:770-860`. PRD_EKIP_VERIM_DESTEK'ten, Software Inc.
  esinli.

**Tahmin = sonuç**
- Plan ekranındaki tahmin (`plan_outcome`) kapanışla birebir eşleşmeli.
- Kapısı `--sprint-probe`: `PRED` ve `CLOSE`, adsız uyuşmazlıkta çıkış 1 (CLAUDE.md §12).

**Ürün karmaşıklığı**
- A'da silinir. "Özelliğe tasarım karmaşıklığı" fikri sana geldi.

**Tur 2 tasarımı**
- `../sprint/T2_5a_loop.md` §4. m(s) eğrisi, uyum, ekip cezası, örnek tablo.
- Erdem yıldız tablosunu onayladı, gerisini düzeltti.

## 3. Hedef akış
- Her rol kendi aşamasının puanını üretir. Kart, ihtiyacını oyuncuya anlaşılır biçimde söyler. Plan ekranı ekibin
  hangi aşamada ne kadar güçlü olduğunu gösterir. Tahmin, sonuçla aynı çıkar.
- Yıldız gerçekten fark eder.
- Yanlış ya da uymayan atamanın bedeli atama anında görünür.
- Testçi hatayı azaltır. Testçi yoksa test yıldızı olan biri ikincil rolde test yapabilir.
- PM puan üretmez. Değeri koordinasyondan ve "önden gitmekten" gelir.

## 4. Bağlayıcı kararlar (karar defteri, Faz D)
**Role göre çıktı (onaylı)**
- Somut olarak cevapla:
  - Kart ihtiyacını nasıl söyler? Aşama başına puan mı?
  - Ekibin aşama kapasitesi kartın süresine nasıl çevrilir?
  - Oyuncu bunu nasıl görür?
- Araştır: Game Dev Tycoon, Software Inc., Mad Games Tycoon 2, Startup Company.

**Yıldız çarpanları (onaylı)**

| Yıldız | 1★ | 2★ | 3★ | 4★ | 5★ |
|---|---|---|---|---|---|
| Çarpan | ×0,64 | ×0,86 | ×1,16 | ×1,54 | ×2,0 |

- Yıldız 5'e kadar. 5★'teki ×2,0 iddialı olabilir; kalibrasyonda bakılır.
- Yarım yıldızlar ara değerdir (puan 0–10).
- Tur 2'deki eğri m(s) = 0,5 + 0,05s + 0,01s² idi; tablo bu eğrinin yıldız noktalarıdır.

**Uyum**
- Ana alan ×1,0, ikincil ×0,7, uymayan iş ×0,4.
- ×0,3 ya da hiç çalışamama da değerlendirilir; öner.
- Oyuncu atama anında verim kaybını açıkça görmeli ("bu böyle çalışmaz"). Moral yıpranması varsa o da görünmeli.

**Ekip büyüklüğü cezası**
- "3'ü aşan her kişi için −%6" fazla ve kaba bulundu. Erdem önce %5 tavan dedi, sonra kişi başı %5'i de fazla buldu.
- Kademeli olmalı: örneğin 5 kişiye kadar %2, 20 kişiye kadar daha fazla. Kalibrasyonla ayarlanır.

**Testçi**
- Hata ihtimalini düşürür.
- Tur 2'deki %19 ve %11 oranları yüksek bulundu. Testçi yokken %40 da fazla.
- Test yıldızı olan herhangi bir çalışan (örn. geliştirici) ikincil rolde test yapabilir. Test yıldızı olmayan
  (örn. PM) uymayan iş kuralına düşer.
- Oranlar oyuncuya gösterilsin mi? Öner.

**PM**
- Puan üretmez. Koordinasyon kaybını azaltır, Çeyrek'i açar, karar kâğıtlarına PM sorusu ekler (B'nin kâğıtları).
- **"PM önden gider":**
  - Geliştiriciler bu sprinti koşarken PM sonraki sprintlerin kartlarını hazırlar.
  - Küçük iş bir haftada hazır olur, büyük iş iki ay sürebilir. Erdem'in gerçek hayattan örneği: "Tuğba irili ufaklı
    işleri bir haftada, çok büyük işleri iki ayda çıkarıyor."
  - Özelliklere tasarım karmaşıklığı eklenir. Belki sprintten bağımsız ayrı bir PM akışı olur.
  - Cevapla: Gerçekçi mi? Bu oyun için fazla mı? Nasıl harmanlanır? Gerek var mı? Önerini gerekçeyle yaz.
  - PM'siz ekipte ne olur? Erken oyunda kurucu tek başınadır; bu akış oyunu kilitlememeli.

**Bedel kabul**
- Çekirdek mekanik, ucuz yedek yok.
- Plan ekranındaki tahmin sprint sonucuyla aynı olmalı.

## 5. Araştırılacaklar
**Web (`D_ARASTIRMA.md`, ayrı Sonnet ajanı yazar)**
1. Game Dev Tycoon, Software Inc., Mad Games Tycoon 2, Startup Company ve Big Ambitions:
   - Rol başına puan üretimi.
   - Kart ya da görevin ihtiyacını nasıl söylediği (aşama başına puan, süre, ilerleme çubuğu).
   - Oyuncuya nasıl gösterildiği.
   - Yanlış rol ve beceri farkının etkisi.
2. Ekip büyüklüğü cezası:
   - Brooks yasası, iletişim kanalları n(n−1)/2.
   - Software Inc.'in takım boyutu kuralı.
   - Diğer oyunlarda kademeli koordinasyon kaybı.
3. PM'in önden gitmesi: dual-track agile, backlog refinement, "Definition of Ready", discovery ve delivery. Gerçek
   hayatta PM hazırlığı sprinte kaç hafta önden gider? Büyük işler nasıl bölünür?
4. Test kapsamı ve hata kaçışı (defect escape rate): ayrı QA olan ve olmayan ekiplerde kabaca oranlar.

**Senin cevaplayacakların**
- Kart ihtiyacı ve aşama kapasitesi modeli. Formül ve örnek tablo: tek kurucu, kurucu + 2 kişi, 6 kişi, 12 kişi.
- Plan ekranında gösterim (ASCII taslak):
  - kartın aşama ihtiyacı,
  - ekibin aşama kapasitesi,
  - atama uyarısı,
  - testçi ve hata ihtimali.
- Tahmin ile sonucun eşleşmesi: `plan_outcome` aynı hesabı nasıl yapar? `--sprint-probe` kapısı nasıl kalır?
- İşe alım dosyasındaki puan gösterimi (`points_for`).
- PM akışı önerisi ve en sade hâli.
- Kurucunun sprint payı ve kurucunun yıldızı: bugün kurucu bantsız ×1,0.
- Kayıt şeması ve eski kayıt.

## 6. Kapsam dışı
- Olay ve kâğıt metinleri (B).
- Ürün sayfası (C).
- Pazaryeri (E).
- Pazarlama.
- Verim eğrisinin kendisi (PRD_EKIP_VERIM_DESTEK'te kuruldu). Onu yeniden tasarlama, yalnız oku.

## 7. Sınırlar
`ORTAK.md` "Fazlar arası sınırlar".
- **A:** Düzeltme kartı eforu (1, 2 ya da 3) senin aşama puanı modeline uyar. Nasıl uyduğunu yaz.
- **B:** "Sürüm sonrası bozulma" olayı senin hata ihtimalini kullanır.

## 8. Çıktı
`fazlar/D_PLAN.md`, `ORTAK.md`'deki şablonla.
- Bot koşusuyla (`--sprint-probe`, `run_gate.sh`) bugünkü ve önerilen modelin sprint puanlarını karşılaştıran bir
  ölçüm dilimi koy. MVP'nin ~6. haftada çıkması kalibrasyon kararıdır; bozuluyorsa söyle.
