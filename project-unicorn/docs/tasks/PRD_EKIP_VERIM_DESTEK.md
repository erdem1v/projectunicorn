# PRD · Ekip verimi, destek ve sprint akışı (mini)

**Kim çalıştırır:** bir geliştirici ajanı oturumu. Başlatma cümlesi: "project-unicorn/docs/tasks/PRD_EKIP_VERIM_DESTEK.md
dosyasını oku ve uygula."
**Durum:** co-director taslağı 2026-10-11; Erdem'in aynı günkü playtest notları ve kararlarıyla. Sayılar başlangıç
değeridir, "onay bekliyor" diye iner, Erdem playtest'te çevirir.
**Ne zaman:** Onarım 1'in A+B oturumu (Satış/Ekip/Ar-Ge/sprint dosyaları) bittikten sonra. D4 ve V3 olay kartıdır:
motor v3 taşıması main'e indikten sonra.
**Tek cümle:** destek biletleri kimse atanmasa da yavaşça okunur ve oyuncu ürünün hatalı olduğunu görür; verim
günün saatleriyle düşer, moral 40 saati aşınca aşınır, tükenmişlik ve izin vardır; işi biten ürün yöneticisi ve
tasarımcı bir sonraki işe geçer, boşta kalan geliştirici oyuncuya söylenir.

## 1. Kurallar
- `CLAUDE.md` bağlayıcı (§3 doğrudan main, push yok; §5 önce İngilizce, TR "TR/EN onay bekliyor"; §8–§9; §11 görsel kabul).
- **Model ve bütçe (Erdem 2026-10-11):** kod Opus; inceleme, ekran çekimi, kapı koşturma, belge Sonnet ya da Haiku
  (seçimi sen yaparsın). Commit başına tek inceleme, yalnız diff; düzeltme en çok bir tur; bu PRD'nin istemediği ölçüm
  ve ikinci tur yok.
- **Görsel kabul ciddi (Erdem):** ekrana giren her satırda kendine sor: "bu yazı burada doğru mu, oyuncu anlıyor mu,
  yerinde mi, kalabalık mı?" Gereksiz açıklama satırı ekleme; mevcut satırı güncelle. TR ve EN çekimi, 1920 ve 1536.
- Paylaşılan ağaç: yalnız kendi hunk'ların; `checkout --`, `reset --hard`, `stash`, `clean` yok.

## 2. Destek (D)
Bugün: v1.0 yayında bildirimler kendiliğinden gelir; doğrulama yalnız Destek'e atanan çalışan ve başka işi olmayan
kurucuyla olur (`SupportSystem.desk_roster`, `founder_passive_care`); kurucunun hızı Müşteri Başarısı puanıyla orantılı,
puan 0 ise hiçbir şey doğrulanmaz (`HRSystem.effective_skill`). Oyuncu temsilci almadan ürünün hatalı olduğunu görmez.
- **D1 Taban doğrulama.** Herkes mail okur: kurucu ve bu hafta sprint kartı olmayan her çalışan (`SprintSystem.role_of`
  boş) doğrulamaya `SUPPORT_BASE_POINTS` (öneri 2) ile katılır; Müşteri Başarısı puanı bundan büyükse o geçer. Destek'e
  atanan temsilci tam puanla çalışır (bugünkü gibi). Taban yalnız DOĞRULAMADIR; hata düzeltme kendiliğinden olmaz.
  Kabul: kurucu Müşteri Başarısı 0, kimse atanmamış, v1.0 yayında: 2 haftada doğrulanmış hata > 0; bir temsilci
  eklenince doğrulama hızı en az 3 kat. Smoke: `destek_empty_desk_piles_up` yeni kurala göre güncellenir.
- **D2 Kaçırılan bildirim (Erdem).** Üst barda işaret YOK. Uyarı destek kutusunun kendisinde: masanın o hafta bakamadığı
  bildirimler "kaçırılan" diye sayılır (haftanın gelen bildirimi − doğrulanan, sıfırın altına inmez) ve kutuda tek satır
  okunur: "Bu hafta {n} bildirim kaçırıldı" / "{n} reports missed this week". Oyuncu temsilci alması gerektiğini buradan
  anlar. Var olan destek satırını güncelle, ikinci bir açıklama satırı ekleme. Kabul: temsilcisiz büyüyen üründe sayı
  artar, temsilci gelince düşer; TR/EN çekim.
- **D3 Hotfix düğmesi.** Düzeltme koşusu her an bitirilebilir ve düzeltilenleri canlıya iter (`SupportSystem.end_fix_run`),
  ama düğmede yalnız ikon var (`build_bar.gd`). Koşu açıkken düğme "Hotfix yayınla · {n} düzeltildi" / "Ship hotfix ·
  {n} fixed" der, kapalıyken "Hata düzeltmeyi başlat" / "Start bug fixing". Oyuncu bitmesini beklemeden basar (sprint
  arasında bir hafta düzeltip sprinte dönebilsin). "hotfix" TR izinli ödünç listesine Erdem'in kararıyla eklenir
  (`docs/design/localization_glossary.md`). Kabul: koşu açık/kapalı TR/EN çekim.
- **D4 (motor v3'ten sonra) Koşu sürerken hata yığını kartı gelmez.** `product.bug_pile` koşu açıkken ateşlenmez: yeni
  seam `destek.fix_run_active` + kart koşulu. Kabul: `--why-fire=product.bug_pile` koşu açıkken kapalı.

## 3. Verim ve moral (V)
Bugün: verim = moral bandı (×1,10 / ×1,0 / ×0,85) × olay çarpanları; kurucuda moral yok. Mesainin 8 saatten sonraki
saatleri yarım verim sayılır (`TimeModel.OVERTIME_HOUR_YIELD`). Moral 8 saatte bile ayda ~7,5 puan düşer
(`HOUR_MORALE_MULT[8] = 1.0`, `MORALE_BASE_DRIFT_PER_DAY`); oyuncular istifadan kaçmak için mesaiyi 7'ye indiriyor.
Software Inc. araştırması: orada verim ihtiyaç çubuklarından (enerji, açlık, stres) türer; saat başı oran doğrulanamadı.
Bizim sürümümüz daha basit ve okunur:
- **V1 Gün içi verim eğrisi.** Kişi güne bir başlangıç verimiyle başlar: %100 × moral payı × olay çarpanları
  (`productivity_mods`). Moral payı kademeli (Erdem): moral 90+ → +%10 · 75–89 → +%5 · 50–74 → 0 · 30–49 → −%5 ·
  30 altı → −%10 (`MORALE_PACE_STEPS`, tek tablo). Her mesai saati verim `DECAY_PER_HOUR` (öneri %2; %1 ile de ölç) düşer; 8 saati
  aşan saatlerde `DECAY_OVERTIME_PER_HOUR` (öneri %3). Taban %50. Günün çıktısı saatlerin toplamıdır. Yarım verim kuralı
  KALKAR. Ekonomi kalibrasyonu korunur: varsayılan 8 saatlik gün, %100 başlangıçla bugünkü haftalık puanı verir
  (normalize et). Kurucu aynı eğriyi kullanır, moral payı yoktur. Moral bandının hız çarpanları kalkar; moral
  istifa, talep ve olaylar içindir. Gösterim: Ekip satırında ve dosyada "Verim %105 → %88" (gün başı → gün sonu); dosya
  satırı nedenlerini söyler. Kabul: `--sprint-probe` 8 saatte fark yok; 10 ve 12 saatte yeni puanlar rapora (eski
  yarım verimle yan yana); `run_gate.sh` 3/3; dosya ve Ekip çekimi TR/EN.
- **V2 Moral 40 saate kadar aşınmaz.** `HOUR_MORALE_MULT`: 5 → −1,0 · 6 → −0,5 · 7 → −0,25 · 8 → 0 · 9 ve üstü bugünkü gibi.
  Kırmızı olan `hr_morale_drift_shape` vakası yeni kurala göre düzeltilir (falsifikasyonla). Kabul: 8 saatte 26 haftada
  moral düşmez; 10 saatte düşer.
- **V3 (motor v3'ten sonra) Tükenmişlik, yalnız çalışan.** Çalışan üst üste `BURNOUT_WEEKS` (öneri 4) hafta 8 saati
  aşarsa tükenmişlik kartı gelir: moral −15 ve 2 hafta verim −%20. Kurucuya gelmez (Erdem: kurucunun mesaisi kendi
  kararı; onun bedeli V1'in gün içi düşüşü). Şıklar gerçek hamle
  (izne gönder / mesaiyi indir / devam et ve bedelini öde); metin taslak, TR/EN onay bekliyor; v3 makullük bloğu dolu.
- **V4 İzne gönder.** Çalışan dosyasına eylem: "İzne gönder" (1 ya da 2 hafta), var olan `HRMoraleSystem.send_on_leave(emp,
  weeks, true)` ile. Onay penceresi kaç hafta yok olacağını ve moralin ne kadar toparlanacağını söyler. Düğme dosyanın
  eylem sırasında zam ve terfiden sonra, ikincil stilde; hiyerarşi bozulmaz. Kurucuya yok. Kabul: dosya çekimi TR/EN,
  izindeki kişi sprint ve destekte sayılmaz.

## 4. Sprint akışı (S)
Bugün: kartlar haftalık atanır; kartını bitirenin artan puanı aynı sprintteki karta akar; sonraki sprint sütunundaki
kartlara kimse dokunmaz; tasarım bitmeden geliştirici başlamaz.
- **S1 Ürün yöneticisi ve tasarımcı önden gider.** Kendi fazını bitiren ürün ve tasarım rolü önce aynı sprintte o fazı
  bekleyen karta, yoksa sonraki sprint sütunundaki kartların ürün/tasarım fazına geçer ve hızının yettiği kadarını
  yapar; ilerleme kartta kalır. Ürün ve tasarım fazı tamamen biten kart sonraki sprintte doğrudan geliştirmeye girer;
  onlar da sıradaki kartlara geçer. Geliştirici ve testçi önden gitmez. Sonraki sütun boşsa beklerler (oyuncunun işi).
  Plan tahmini (`_play_out`) bunu bilir; `--sprint-probe` PRED=CLOSE %100 kalır. Kabul: `live:plan` ve `live:active`
  çekiminde sonraki sütun kartında hazır payı görünür (gerçek oran; tamamsa "Geliştirmeye hazır").
- **S2 Boştaki kişi oyuncuya söylenir, otomatik iş yok.** Bu hafta kartı olmayan geliştirici ve testçi ofiste molada
  görünür (bugün öyle); Ürün ekranında tek satır: "{n} kişi boşta · kart hazır değil" ve bir hamle önerisi (hata
  düzeltmeyi başlat ya da sonraki sprinti planla). Hata düzeltme kendiliğinden başlamaz.
- **S3 Sprint süresi ve ekip büyüklüğü (Erdem: en büyük sorunlardan biri).** Bugün sprint sabit 2 hafta sürer
  (`sprint_weeks`, `_end_week` yalnız süre dolunca kapatır); kartlar ilk hafta bitse de ekip ikinci hafta boş bekler, büyük
  ekip küçük ekiple aynı takvimde kalır.
  1. Sprint süresi oyuncunun seçimi: 1 ya da 2 hafta (planlama ekranında, varsayılan 2; 4 hafta ileride). Kapasite ve
     plan tahmini seçilen süreyle hesaplanır; kayıt alanı eski kayıtta 2.
  2. Sprintteki her kart bittiğinde sprint o haftanın sonunda kapanır, süre dolmayı beklemez; planlama hemen açılır
     (Sprint 7'nin onay ve saat tutma kuralı aynen).
  3. Ekip büyüdükçe planlanabilen kart artar: önce ölç (`--sprint-probe`, 1/3/6 kişilik ekip, 1 ve 2 haftalık sprint:
     planlanan kart, biten kart, boşta kalan kişi-hafta). Büyük ekip planı dolduramıyorsa nedenini (kapasite tavanı mı,
     açık kart sayısı mı) rapora yaz; sabit değişikliği onay bekler.
  Kabul: probe tablosu; 1 haftalık sprintte kapanış ve planlama çekimi TR/EN; `sprint_*` vakaları ve `run_gate.sh` 3/3.

## 5. Commit sırası
V2 (moral tablosu + vaka) → D1 → D3 → D2 → V4 → V1 (en büyük; ölçüm) → S3 → S1 → S2 → [motor v3 main'de] D4 → V3.
Her commit: lint → `loc_residue` → `loc_csv_integrity` → dokunulan vakalar → görsel kabul → tek inceleme → commit.

## 6. Onay bekleyenler (rapora)
`SUPPORT_BASE_POINTS` 2; verim eğrisi %2 (ve %1 ölçümü) / mesai %3 / taban %50; `MORALE_PACE_STEPS` kademeleri;
`HOUR_MORALE_MULT` yeni satırları; tükenmişlik 4 hafta, −15 moral, −%20 / 2 hafta; izin 1–2 hafta; sprint süresi 1/2
hafta ve erken kapanış; "hotfix" sözlük eki; yeni TR/EN metinleri. Not: yarım verim kuralı kalkınca mesai saati bugünden
verimli olur (9. saat ~%80, bugün %50); bedeli moral aşınması ve tükenmişlik. Ölç, dengesizse rapora yaz.

## 7. Done
✅/⚠️/❌ madde başına, commit, kapı ve ekran görüntüleri; V1'in 8/10/12 saat puan tablosu; D1'in doğrulama hızları
(temsilcisiz, tek temsilci).
