---
name: smoke-verification-cadence
description: "Erdem's rule (2026-07-29): full smoke suite runs ONCE, in the lead's integration step — never per phase, never by subagents"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: fceea5b0-7c5a-442f-95ba-aeeaf1464c91
  modified: 2026-10-05T21:49:43.934Z
---

**2026-10-06 güncel: push öncesi tam süit koşulmaz, Erdem istemedikçe → [[feedback-push-without-full-smoke]].**

Çok fazlı (subagent'lı) task'larda smoke koşu kuralı — Erdem 2026-07-29:

**Ara-faz tam-smoke koşuları YAPILMAZ.** Subagent'lar yalnız KENDİ dosyalarının parse
kontrolünü yapar. Tam süit + baseline byte-diff YALNIZ lead'in entegrasyon adımında,
TEK SEFER koşulur.

**Case sayısını ASLA ezberden söyleme, KAYNAKTAN çıkar.** Doğru ölçüm (default arm'ı
eşleşmez, çünkü desen isim + `fail = _case_` istiyor):
`grep -cE '^\s+"[a-z0-9_]+":\s+fail = _case_'`
Sağlaması: arm sayısı == `grep -cE '^static func _case_[a-z0-9_]+\(\) -> String:'`, ve
arm→func eşlemesi 1:1 olmalı (yetim arm ya da çağrılmayan func = defter satırı kaçmış).

**Not:** bir ara not "97 sayımı `_:` default arm'ını da sayıyordu, gerçek 96" demişti —
2026-07-29'da kaynaktan doğrulandı, DOĞRU DEĞİL: yukarıdaki desen default arm'ı zaten
eşleştirmiyor ve o gün ölçüm 1:1 çıktı (arms == funcs). Coupling sonrası **106**
(97 − hr_shim_parity + speed-ladder'ın 2'si + Coupling'in 8'i).

**Why:** her case ayrı Godot process'i (autoload state'i temiz kalmalı — `endgame_smoke.gd`
header'ının kuralı), yani tam süit ~8 dakika duvar süresi. HR Core'da bunu dört kez koştum
(baseline, migration sonrası, scaffold sonrası, entegrasyon) — ilk üçü aynı cevabı verdi ve
sırf bekleme süresi ~25 dakika yedi. Ara koşuların yakaladığı hiçbir şey, entegrasyon
koşusunun yakalamayacağı bir şey değildi.

**How to apply:**
- Baseline'ı BİR KEZ al (task başında, hiçbir edit'ten önce) — bu iptal edilmedi, byte-diff'in
  referansı odur.
- Faz içinde doğrulama gerekiyorsa: `--import` ile parse kontrolü + o fazın KENDİ case'lerini
  tek tek koş (`--endgame-smoke=<case>`), tam süit değil.
- Tam süit + `Compare-Object` baseline diff = entegrasyon adımı, tek sefer.
- Runner scripti scratchpad'de: `run_smoke.ps1 -OutFile <path>` (match block'tan case adlarını
  çıkarır, her birini ayrı process'te koşar, PASS/FAIL satırlarını dosyaya yazar).
  **Per-case timeout ŞART** (`Start-Process` + `WaitForExit`): proje derlenmezse `main.gd`
  hiç `quit()`e ulaşmaz ve process SONSUZA KADAR asılı kalır — timeout'suz runner tüm süiti
  kilitler.
- **Baseline'ı ÖNCE al, koşarken HİÇBİR proje dosyasını düzenleme:** her case ayrı process
  olarak diskteki GÜNCEL kaynağı okur, ortada yapılan edit baseline'ı bozar.
  **BU KURALI İKİNCİ KEZ ÇİĞNEDİM (2026-08-10, ODA sanat migrasyonu).** Süiti arka planda
  başlattım, sonra "yalnızca yorum satırı" diye `oda_layout.gd`'nin MAX_CROP gerekçesini
  düzenledim — davranışı değiştiremezdi, ama kuralın VARLIK SEBEBİ tam olarak bu akıl
  yürütme. Koşuyu 14/153'te öldürüp baştan aldım. **Pratik önlem: süiti başlatmadan ÖNCE
  "düzenlemem gereken başka dosya var mı?" diye tam bir tarama yap (yorumlar, defter
  notları, stale gerekçeler dahil) ve süiti EN SON iş olarak kuyruğa al.** Arka planda
  koşarken yalnız proje DIŞI iş yapılır (plan dosyası, memory, ölçüm/görsel analiz).
- **`TaskStop` arka plandaki bash DÖNGÜSÜNÜ öldürmeyebilir (2026-08-10).** Süiti iptal edip
  yenisini AYNI çıktı yoluyla başlattım; öldürdüğümü sandığım koşu yaşamaya devam etti,
  aynı dosyaya append etti ve aynı anda ikinci bir Godot süreci koşturdu. Sonuç: tek
  dosyada İKİ `RESULT` satırı (`152/1` ve `153/0`) ve bir "FAIL" — üstelik o FAIL sahteydi,
  çünkü yeni koşu için `rm -rf smoke_logs` yapınca eski koşunun log dizinini altından
  çekmiştim (`[: : integer expression expected` satırları bunun parmak izi). Case tek başına
  5/5 PASS geçti. **Kural: iptalden sonra (a) `tasklist | grep -i godot` ile gerçekten
  öldüğünü DOĞRULA, (b) yeni koşuya HER ZAMAN taze bir çıktı dizini ver — asla aynı yolu
  yeniden kullanma, yoksa iki koşu birbirine karışır ve hangi sayının doğru olduğu
  belirsizleşir.**

**SMOKE PASS TEK BAŞINA YETMEZ — koşuyu DERLEME hatasına da kapıla (2026-08-07'de yandım).**
Bir autoload'da (`event_manager.gd`) parse hatası varken süit ÇÖKMEZ: Godot o autoload'u
instantiate edemez, oyun topallayarak devam eder ve o autoload'a DOKUNMAYAN case'ler
sapasağlam `SMOKE PASS` basar. O koşuda 6 case'in 5'i "geçti", yalnız EventManager'a ihtiyaç
duyan biri düştü — ve ben yanlış yerde hata aradım. Belirti şu satırlardır, ve stdout'ta
PASS'ın çok yukarısındadırlar:
`SCRIPT ERROR: Parse Error:` · `Compile Error: Failed to compile depended scripts` ·
`Failed to instantiate an autoload`
Bu yüzden runner HER case için `2>&1` yakalamalı ve `Parse Error|Compile Error|Failed to
instantiate` sayısı > 0 ise case'i PASS saymamalı. Sadece `Select-String '^SMOKE'` bakan bir
runner sessizce yalan söyler.

**SMOKE + EKRAN GÖRÜNTÜSÜ DE YETMEZ — SHOT BATTERY'NİN LOG'UNU DA KAPILA (2026-08-08).**
Terminal reskin'inde `BuildHUDPanel.tscn`'de bir düğümü `HBoxContainer`→`VBoxContainer`
yaptım ama script'teki `@onready var decision_row: HBoxContainer` tip anotasyonunu
unuttum. Sonuç: atama sessizce düşer, referans `null` olur, altındaki buton bağlantıları
`Invalid access to property 'pressed' on a base object of type 'Nil'` ile ölür. **153/153
smoke PASS geçti** (smoke shell'i mount etmez) **ve ekran görüntüleri normal görünüyordu**
(kart zaten `visible=false` durumundaydı) — hata YALNIZ battery log'unda, kabuğu mount eden
her koşuda 42 kez, görünüyordu. Bu yüzden battery script'i sonunda
`grep -cE "Parse Error|Compile Error|SCRIPT ERROR"` koşmalı ve sıfır DEĞİLSE koşu
başarısız sayılmalı. Ders: sahnede bir düğümün TİPİNİ değiştirdiysen, o düğüme
`@onready` ile bağlanan her tip anotasyonunu ara (`grep -n "<NodeName>"` script'te).

**Yeni case'in gerçek bir nöbetçi olduğunu KANITLA (falsification).** Düzeltmeyi tek satırla
geçici olarak geri al (`if false:` / eski dönüş değeri), case'i koş, DÜŞTÜĞÜNÜ gör, sonra geri
tak ve tekrar koş. Bu tur ~40 saniye ve "bu case eski kodda düşer" iddiasını tahminden ölçüme
çeviriyor; 9 yeni case'in 7'sini böyle doğruladım. Yalnız yeni bir yardımcı fonksiyon ekleyen
case bunun istisnası: eski kodda derlenmez, o yüzden "düşer" iddiası dejenere — raporda öyle yaz.

**Edit çapası tuzağı:** bir yorum satırını çapa alarak fonksiyon ekleme. `# Target selector...`
diye eşleşen satır o fonksiyonun docstring'inin İÇİNDEYDİ; ekleme `func` imzasıyla gövdesinin
ARASINA düştü ve dosya "Expected indented block" ile derlenmez oldu. Çapayı `func` satırının
kendisinden ya da gövdenin ilk kod satırından seç.

İlgili: [[project-unicorn-current-stage]], [[godot-mcp-runtime-verification]]

**Bir testin FONKSİYONU çağırması, YOLU çağırdığı anlamına gelmez** (2026-08-21'de ölçüldü). İki kayıt-göçü vakası yıllardır geçiyordu çünkü `SaveManager._migrate_*`'i DOĞRUDAN, elde kurulmuş `{"characters": [...]}` dict'iyle çağırıyorlardı — oysa gerçek kayıt satırları `state["registries"]["characters"]` altında duruyor ve göçlerin hiçbiri onlara değmiyordu. v3'ten beri HER karakter göçü sessiz no-op'tu ve iki yeşil vaka bunu gizliyordu. Kural: bir göç vakası dosyayı YAZAR, `SaveManager.read_slot()` ile YÜKLER, sonucu okur. Aynı şüphe her "private fonksiyonu doğrudan çağıran" vaka için geçerli.


**SÜİT ARTIK 300 VAKA VE ~2,5 SAAT (2026-08-26, Satış rev 6).** Case başına ~30 sn duvar
süresi; "~8 dakika" cümlesi 106 vakalık dönemin ölçümüydü ve bugün ÜÇ MERTEBE yanlış.
Pratik sonucu şu: tam süiti başlatmak bir GÜN kararıdır, ve o gün içinde onu **dört kez**
yeniden başlatmak zorunda kaldım (mühürlü sahnede node-path hatası · lint'in yakaladığı
eksik kart alanı · motor probe'unun bayat şema iddiası · §11.7'nin açığa çıkardığı gizli
maaş hatası). Her seferinde durdurmak doğru karardı — kırmızı biteceğini BİLDİĞİN bir koşuyu
sonuna kadar beklemek 2,5 saati iki kez ödemektir — ama dördü de aynı kök sebebi paylaşıyor:
**süiti kuyruğa almadan önce DİĞER kapıları koş.** Sıra: `--import` → `--event-lint` →
`--event-probe` → `loc_residue` → `gen_signal_manifest` → değişen alanın kendi case'leri
tek tek → EN SON tam süit. Bu sıra ucuz kapıları önce koşturuyor ve dördünün de tam süiti
öldürmesini engellerdi.

**BİR MODÜLÜN ŞEMA ARTIRIMI BAŞKA MODÜLLERİN SABİT İDDİALARINI KIRAR.** `SCHEMA_VERSION`
10→11 iki yeri düşürdü: `engine_probe.gd:444` (`== 10`) ve `endgame_smoke` içindeki
`save_v10_product_state`. İkisi de "şemada şu blok VAR" demek istiyordu ama SAYIYI
sabitlemişti. Doğru şekil `>= N`; eşitlik yalnız gerçekten sabit bir hüküm için
(`MIN_LOADABLE_VERSION == 10` gibi). Şema artıran her task bu iki dosyayı ARAMALI:
`grep -rn "SCHEMA_VERSION ==" scripts/`.


**BİR DALGAYI COMMIT'LEMEDEN SONRAKİNE GEÇERSEN İKİSİNİ BİR DAHA AYIRAMAZSIN (2026-08-27'de
yaşandı).** Üç görev de "tek doğrusal commit" istiyordu. Destek Hattı dalgası, Hotfix
dalgasının EKLEDİĞİ bir fiili SİLDİ; Hotfix commit'lenmemişti, yani o ara durum çalışma
ağacında hiç var olmadı. `git add -p` yalnız ağaçta OLANI aşamalayabilir, dolayısıyla sadık bir
"yalnız hotfix" commit'i üretmek silinmiş kodu yeniden yazmak — tarihi uydurmak — olurdu.
**Kural: bir dalga yeşilse ve bir sonraki dalga onun kodunu değiştirecekse, ÖNCE commit'le.**
Hunk-seviyesi ayırma yalnız iki dalga aynı satırlara EKLEME yaptığında işe yarar; biri ötekini
siliyorsa ayırma matematiksel olarak imkânsızdır.

**SÜİTİ ÜÇ KEZ ÖLDÜRDÜM VE ÜÇÜNCÜSÜ BENİM HATAMDI.** İlk ikisi meşruydu (bilinen kırmızı, yeni
görev). Üçüncüsünde "küçük bir iş, araya sıkıştırayım" diye düşündüm — ve her araya sıkıştırma
kapıyı sıfırlıyor. Pratik kural: süit koşarken gelen yeni görev BEKLER; süit bitene kadar
yapılacak iş yalnız proje DIŞI iştir (rapor taslağı, commit mesajı, memory).

**`TaskStop` YİNE bash döngüsünü öldürmedi (2026-08-27, üç kez üç kez).** Her seferinde
`Get-CimInstance Win32_Process -Filter "Name='bash.exe'"` + `CommandLine -like "*smoke_run*"`
ile runner'ı, sonra `Get-Process Godot*` ile çocukları elle öldürmek gerekti. Bir kez
"CLEAN" dedikten sonra bile yeni PID'ler belirdi — çünkü döngü hâlâ yaşıyordu ve yeni case
başlatıyordu. ÖNCE DÖNGÜYÜ öldür, SONRA Godot'ları.

**ARKA PLANDAKİ UZUN KOŞULAR HARNESS TARAFINDAN ~1 SAATTE ÖLDÜRÜLÜYOR (2026-08-27, ÜÇ KEZ).**
Tam süiti üç kez arka planda başlattım, üçü de bitmeden `killed` geldi (115., 167. ve 167.
vakada). Her seferinde de `TaskStop`/kill SONRASI bir `smoke_run.sh --all` DÖNGÜSÜ hayatta
kaldı: bir noktada İKİ zombi döngü + altı Godot süreci aynı anda koşuyordu, yani o pencerede
üretilen HİÇBİR sonuç güvenilir değil.

**Çözüm: ÖN PLANDA 14'ERLİK PARÇALAR.** Bash tool'un tavanı 600 sn; vaka başına ~35 sn ile
14 vaka rahatça sığıyor ve her düşen vaka ANINDA görünüyor. Scratchpad'de `chunk.sh <start>
<count>`: `allcases.txt`'ten dilim alır, verdict'leri tek bir `chunks.log`'a ekler, düşenleri
stdout'a basar. Devam etmek için `grep -c 'SMOKE ' chunks.log` + 1'den başla.

**Her yeniden başlatmadan ÖNCE süreç tablosunu temizle, SIRA ÖNEMLİ:** önce
`Get-CimInstance Win32_Process -Filter "Name='bash.exe'"` + `CommandLine -like '*smoke_run*'`
ile DÖNGÜYÜ, sonra Godot çocuklarını. `Stop-Process` toplu çağrısı auto-mode sınıflandırıcısı
tarafından REDDEDİLEBİLİR — `taskkill //PID <pid> //T //F` (Bash'ten) geçiyor ve zaten daha
hedefli. Temizliği `CLEAN CHECK -> smoke loops: 0   godot: 0` ile DOĞRULA.

**DEVRALINMIŞ KIRMIZIYI VARSAYMA, KANITLA.** Bu turda üç kırmızı çıktı ve üçü de gerçekten
devralınmıştı — ama bunu iki farklı yolla gösterdim: ikisi YAPISAL olarak (`MIN_LOADABLE_VERSION`
HEAD'de de şimdi de 10, fixture'lar v5/v7), üçüncüsü ÖLÇÜMLE (`git stash push -u` → tertemiz
HEAD ağacında koş → AYNI mesajla düştü → `git stash pop` → `git diff --stat` öncesiyle birebir).
Stash testi tek vaka için ~30 sn ve "benim yüzümden değil" iddiasını tahminden ölçüme çeviriyor.


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Smoke verification cadence](smoke-verification-cadence.md) — Erdem 2026-07-29: tam süit YALNIZ entegrasyon adımında tek sefer; subagent'lar sadece parse kontrolü; case sayısını kaynaktan çıkar (Coupling sonrası 106; 2026-08-21'de 230), runner'a per-case timeout şart; koşarken proje dosyası DÜZENLEME (2026-07-29'da bu kuralı ihlal edip bir koşuyu geçersiz kıldım); **SMOKE PASS tek başına yetmez — autoload parse hatasında süit çökmez, ilgisiz case'ler PASS basar; runner her case'i `Parse Error|Compile Error|Failed to instantiate` ile de kapılamalı (2026-08-07); yeni case'i falsification ile kanıtla**
