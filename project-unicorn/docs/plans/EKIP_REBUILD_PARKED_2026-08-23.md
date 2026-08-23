# Ekip rev 11 — bu turda PARK EDİLEN işler

**Tarih:** 2026-08-23 · **Kapsam:** Faz 1–7 kesintisiz turu (`91698f9` → `8e2c149`)
**Kural:** GDD bir cevap veriyorsa çözüldü. GDD sessizse ve doldurmak bir tasarım hükmü
gerektiriyorsa park edildi. Aşağıdaki her satır ya bir HÜKÜM bekliyor ya da kendi kapısıyla
koşması gereken atomik bir adım.

---

## A · Kendi adımını ve kendi kanıtını isteyenler

### A1 · Kurucu cetveli 0–5 → 0–10 (plan C18 / C18a)
**Durum:** yapılmadı. Plan onu bir KAPIYA bağlıyor: değer kıpırdamadan ÖNCE kurucu
yeteneğini okuyan her yer sayılır, `linear · threshold · other` diye sınıflanır ve done
mesajı her okuyucunun nasıl korunduğunu tek tek yazar.

**Neden park:** "tam olarak denk" bir iddia değil, kanıtlanacak bir şey — ve C18a'nın
taslağı iki karşı örneği zaten yakaladı (`FOUNDER_SPEED_COEF` yarıya inmeli, yoksa
kurucunun build katkısı ikiye katlanır; `experience_gain_mult` KASTEN denk değil). Bunu
uzun bir turun sonunda, kendi kapısı olmadan yapmak tam olarak C18a'nın engellemek için
var olduğu hatadır.

**Bugün ne değişti:** hiçbir şey. Kurucu hâlâ 0–5'te ve Kişisel'deki yıldız satırı hâlâ
5 üzerinden 2,5'te tavanlı. Bu, §2.4 ile §5.3'ün ihlali olarak AÇIK duruyor.

### A2 · `Character`'ın ölü alanları ve kayıt şeması süpürmesi
`area_experience` · `overload_days` · `overtime_days` · `leave_month` · `leave_until_day` ·
`leave_taken_year` · `loyalty` · `trust_score` · `attention_flag` · çalışanlarda `equity_pct`.

**Durum:** hepsi ATIL — hiçbir üretim yolu okumuyor, `leave_month` yalnız işe alımda
yazılıp bir daha bakılmıyor. Sildirilmediler.

**Neden park:** silmek kayıt şemasına dokunuyor ve smoke süitinde ~46 referansları var
(`area_experience` 19, `overload_days` 15, `leave_taken_year` 12). Mekanik bir süpürme,
ama kendi kapısını hak ediyor: yanlış yapılırsa v7 kayıtları sessizce eksik yüklenir ve
bunu gösterecek tek şey o 46 iddianın doğru biçimde taşınmış olmasıdır.

**Not:** `equity_pct`'nin CANLI bir birim tehlikesi var ve o Ekip'in dışında —
`event_manager.gd` onu olay JSON'undan ÖLÇEKSİZ ve KELEPÇESİZ yazıyor, üç yüzey ise
0–1 kesri olarak okuyor. Yazılmış bir `"equity_pct": 5` kurucu payını %0'a kelepçeler ve
%500 çizer.

---

## B · GDD sessiz, hüküm bekliyor

### B1 · §10.6 kilitli kartlar, mevcut B2B kapısını KALDIRIYOR MU?
§10.6 iki kartı adıyla kilitli-görünür yapıyor (Pazarlama · in-house İK) ve ikisi de bu
turda geldi. Ama Satış Temsilcisi ile Müşteri Temsilcisi'nin B2B-ürün koşuluna bağlı
kilidi hakkında §10.6 hiçbir şey söylemiyor.

**Bu turdaki karar:** kapı KALDI. Gerekçe: §10.6 iki kart EKLİYOR, diğer altısının
koşulları hakkında hüküm vermiyor; ve o kapı tek başına bir B2C koşusunda satışçının
oynanmamış kurumsal aday üretmesini engelliyor (CLAUDE.md Prensip 2). Kaldırmak bir
tasarım hükmü olurdu, ve GDD onu vermiyor.

### B2 · Aday kartındaki runway şeridi "5 ay → 5 ay" yazıyor, KIRMIZI
§10.3 bedeli İŞE AL butonundan ÖNCE okutmayı istiyor. Şerit kırmızıya boyanıyor (gerçekten
kötüleşiyor) ama iki değer aynı sayıya yuvarlanıyor — yani "bu zarar veriyor" diyen bir
renk ile "hiçbir şey değişmedi" diyen iki sayı yan yana duruyor. Ölçülen fark ~0,6 ay.

**Neden park:** düzeltme `UiTokens.net_runway_text`'e dokunuyor ve o Finans ile pitch
tarafından da okunan PAYLAŞILAN bir biçimleyici. "Yuvarlanınca kaybolan bir deltayı nasıl
gösteririz" sorusu Ekip'in dışında bir biçim kararı.

### B3 · ODA'nın mesai çipi düğümü
Çip artık çizilmiyor (§8.2 çalışma saatleri modalini mesainin tek görünürlük yüzeyi
sayıyor) ama DÜĞÜMÜ sahnede duruyor. Silmek `--theme-audit=oda`'nın satır sayısını
oynatır ve o kapı bu turda bayt-aynı kalmak zorundaydı. Düğümün emekliye ayrılması
ODA'nın kendi tasarım turunun kararı.

### B4 · İki sinyal bildirildi, yayınlanmıyor
`raise_requested` (§9.2 zammı motorun olayı yapıyor, oyuncunun değil) ve
`employee_eligible_for_promotion` (§9.3 bir KENAR tanımlamıyor). Adları §15.3'ün
listesinde olduğu için bildiriliyorlar — olay motoru geldiğinde keşfedecek bir şey
kalmasın diye. Ne zaman ateşleyecekleri bir hüküm.

### B5 · §2.5 "unvan" — GDD'NİN KENDİ PARKI
§2.5 kurucu kartında unvan istiyor, §2.6 kurucu unvanını (Kurucu / CEO / Founder)
onboarding turuna park ediyor. Kart bugün ad ve köken taşıyor, uydurma bir unvan taşımıyor.

### B6 · Görevler matrisinde BOŞ BİR GRUP
§6c'nin tasarımsız yüzeylerinden beşi bu turda kuruldu (kurucu görev satırı · kilitli
üçüncü hücre · çok rozetli DURUM · saat istisnası etiketi · nötr huy alanı). Altıncısı
duruyor: matris içinde ÜYESİ OLMAYAN bir grubun görünümü. 1e boş SAYFAYI kapsıyor,
14. tur sıfır-çalışan halini kapsıyor; boş bir BAND'ın muamelesi yok.

---

## C · Kapsam dışı, ama bu turda görüldü (plan R4)

| Ne | Nerede | Neden dokunulmadı |
|---|---|---|
| ch01 §5 · ch02 §2/§6/§10 · ch06 §1.2 · ch12 §8 | `.docx` bölümleri | §17.6 onlara emir veriyor; hiçbir `.docx` bu turda açılmadı |
| `docs/PROJECT_SPEC.md` §4.1–4.3 | `:233`, `:539` | Hâlâ emekli dört eksenli kurucu modelini ve 1-pozitif/1-negatif huy kuralını yasalaştırıyor |
| `docs/CONTENT_GUIDE.md` | CLAUDE.md ona atıf yapıyor, dosya YOK | §0'ın "kaynak dosya yalan söylemez" kuralının aynı sınıfı |
| ch06 §1.2 destek formülü (plan Q2) | — | §12.0 Destek'i Yazılım VE Müşteri İlişkileri ile taşıyor, §17.6'nın formülü yalnız MT'yi sayıyor. **Bu turdaki varsayım: her iki taşıyıcı alan üstünden toplanır** (§4.4 developer-destekte halini adıyla istiyor) |
| `_migrate_sector_ids` düz yol okuyor (plan Q3a) | `save_manager.gd` | Ekip dışı; v1→v2 gerçek bir kayıtta hâlâ sessiz no-op |

---

## D · Bu turda DÜŞMEYEN ama düşen smoke vakaları

`226/234`. Düşen sekizin hiçbiri Ekip'e ait değil ve hiçbiri bu turda düşmedi:

- **Altısı** 2026-08-23'te başka bir oturumun turuna ait regresyon ve sahibi kendi
  tazeleyecek: `gate_decline_reminder` · `bankruptcy` · `shutter_recovery` ·
  `pivot_accept` · `pivot_decline` · `terminal_kills_gate`.
- **İkisi** turdan önce de düşüyordu: `all_scripts_load` ·
  `creation_draft_survives_navigation`.

---

## E · Tasarım kaynağı hakkında dürüst not

Çalışma saatleri modali (Faz 6) onaylı 19a–19d ARTBOARD'LARINA BAKILARAK değil, planın
R3 hükmünde yazılı tarifine ve §8.5'in metnine göre kuruldu: KAYNAK sütunu, 5–11 stepper,
"şirkete dön", "Tümünü şirkete eşitle", §14 bedel bloğu, dört durumlu başlık çipi.
Görev tanımındaki Claude Design projesi (`Unicorn Skins.dc.html`) bu turda içe
aktarılmadı. Yerleşim §8.5'in kendi cümlelerini karşılıyor ve iki tur çekimle okundu,
ama artboard'la piksel karşılaştırması YAPILMADI.
