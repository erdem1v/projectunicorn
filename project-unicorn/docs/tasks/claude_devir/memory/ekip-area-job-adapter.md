---
name: ekip-area-job-adapter
description: "Ekip rev 11'de ALAN ile İŞ aynı listedir — clear_areas doğrudan clear_jobs'tur ve assign_area seni AREA_PRIMARY_JOB'ın dediği işe oturtur"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 8f5a873a-93a2-4680-8f3c-605f37570c20
  modified: 2026-08-26T22:49:59.829Z
---

**Ekip rev 11 atamayı İŞ'ten ALAN'a taşıdı ama ikisini AYIRMADI — bir adaptörle örttü**
(`character_registry.gd`). Bunu bilmeden yazılan her atama kodu sessizce yanlış çalışır.

Mekanik:
- `clear_areas(id)` **doğrudan `clear_jobs(id)`'dir.** Alanları temizlediğini sandığın çağrı
  kişinin İŞLERİNİ siler.
- `assign_area(id, area)` → `HRConstants.primary_job_for_area(area)` → `assign_job(id, job)`.
  Yani bir ALAN vermek, o alanın `AREA_PRIMARY_JOB` tablosundaki BİRİNCİL İŞİNE oturtmaktır.
- Tablo (`hr_constants.gd`): `product|design|engineering → build` · `qa → test` ·
  `customer_success → accounts` · `sales → sales` (2026-08-27'ye kadar `accounts`'tu).

**İki gerçek hataya yol açtı (2026-08-27 hotfix turu), ikisi de sessizdi:**

1. **Kurucuyu destek masasına oturtma.** Kod `assign_job(founder, JOB_SUPPORT)` sonra
   "alanı da verelim" diye `clear_areas` + `assign_area(customer_success)` koşuyordu. Sonuç:
   ilk satırın verdiği DESTEK işi silindi, yerine HESAPLAR yazıldı, masa yine boş kaldı.
   **Görev tek başına yeter**, çünkü `HRSystem.effective_skill` alan ATAMASINI değil
   `role_stats`'ı okur ve kurucu altı alanı da taşır. Vaka `hotfix_founder_takes_support_desk`
   bunu "a seated founder validated nothing" ile yakaladı.
2. **Bir işi `JOBS`'a geri getirmek `AREA_PRIMARY_JOB`'ı GÜNCELLEMEZ.** Satış rev 6
   (`4bdc1fb`) `JOB_SALES`'i geri getirdi, tabloyu unuttu, ve `"sales": "accounts"` satırı
   yorumuyla birlikte ("satış işi emekli") bayat kaldı. Sonucu: Satış alanına atanan herkes
   HESAPLAR'a oturuyordu, §3'ün "atanmış satış kapasitesi" musluğu hiç dolmuyordu, ve yeni bir
   Satış Temsilcisi kendi işine doğmuyordu.

**Kural:** bir iş ekliyor ya da geri getiriyorsan `AREA_PRIMARY_JOB`'a BAK. Bir kişiyi bir işe
oturtuyorsan `assign_job` kullan ve arkasından alan çağrısı EKLEME. Bir okuma seam'inin GÖREVİ
mi ALANI mı okuduğunu doğrula: `SupportSystem.desk_roster()` görevi (`assigned_to_job`) okur ama
`validation_per_day()` alanın katkısını toplar — bu ikisi ayrı eksen SANILIR, değildir.

İlgili: [[project-unicorn-current-stage]], [[ekip-rev11-closing-round]]


## Ek dersler — Destek Hattı turu (2026-08-27)

**`AREA_PRIMARY_JOB` DEĞİŞTİRMEK HER SMOKE FİKSTÜRÜNE DOKUNUR.** `CharacterRegistry.add` taze
işe alınanı `default_job_for_role` ile oturtuyor, o da bu tablodan türüyor. `customer_success`
satırını `accounts`'tan `support`'a çevirmek ÜÇ vakayı düşürdü ve üçü de düzeltmenin
ÇALIŞTIĞININ kanıtıydı: "bordroda var masada yok" fikstürü kendi kendini çürüttü (taze Mİ artık
masaya doğuyor), bir vaka HESAPLAR'ı dolu bekliyordu, biri de kapasiteyi. Bir iş satırı
değiştiriyorsan `_make_employee` kullanan her vakayı şüphelen.

**`HRSystem.is_idle` KURUCUYU DIŞLAR** (`c.category == "employee"`). "Kurucu boşta mı" diye bir
soru soracaksan onu ayrı yazmak zorundasın; `is_idle`'ı genelleştirmek §12.2'nin (çalışan boşta
durur ve maaş yer) anlamını bozar.

**KARŞILIKLI ÖZYİNELEME TUZAĞI.** Bir durum makinesi bir yüklemi okuyor, yüklem de durum
makinesini okuyorsa sonsuz döngüdür. `SupportSystem.founder_passive_care()` bilerek
`HRSystem.founder_task_state()` ÇAĞIRMIYOR — olgu tek yerde tanımlı (atama yokluğu + meşgul
değil + canlı ürün), durum makinesi onu OKUYOR. İki fonksiyon aynı olguyu iki yönden anlatır,
ama yalnız biri tanımlar.

**`founder_task_label()` ÜÇÜNCÜ TEKİL BİR CÜMLEDİR** ("Bir yapımda çalışıyor"), bir isim
tamlaması değil. Cümlenin ortasına gömersen ekranda "Sen Bir yapımda çalışıyor durumundasın"
diye okunur. İki nokta ile alıntıla: "Meşgulsün: {what}."
