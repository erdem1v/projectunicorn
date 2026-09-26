# Açık işler

Açık işlerin tek yeri bu klasördür.
- `ACIK_KARARLAR.md`: sahibin kararını bekleyen maddeler. Ajan bunlara karar gelmeden dokunmaz.
- Bu dosya: yapılması kararlaştırılmış ama henüz yapılmamış işler. Biten iş, onu bitiren commit'te buradan silinir.

## Test paketi
- Smoke ve probe paketi yalın bir paketle değiştirilecek (CLAUDE.md "Test"). Bugün `scripts/debug/endgame_smoke.gd`
  347 vaka taşıyor. Yalnız smoke, probe ya da `main.gd` debug harness'larının eriştiği üretim kodu (temizlik dalgası 1
  raporlarında 119 sembol) bu işle birlikte silinir.

## Kod temizliği: kalan adımlar
- Araçlar: `scripts/debug/run_probe.gd`, `scripts/events/tools/`, `scripts/debug/loc_residue.gd`, `tools/`;
  `scripts/debug/fmt_probe.gd` ve `scripts/debug/font_specimen.gd` silinecek.
- Sistemler arası iş: dalga 1 raporlarında başka sistemin dosyasına düşen 172 değişiklik önerisi ve 151 bildirilmiş
  hata ya da sapma ayıklanacak. Gerçek hata düzeltilir, tasarım sorusu `ACIK_KARARLAR.md`'ye girer.
- CSV süpürmesi: dalganın kullanılmaz bıraktığı anahtarlar (raporlarda 101 aday; `docs/writing/` ve
  `ACIK_KARARLAR.md`'de geçenler kalır, DRAFT-EN maddesindeki PRICE_TIP_PREMIUM ve PRICE_TIP_VOLUME dahil), ardından
  `event_bus.gd` başlıklarındaki atıflar ve `python tools/gen_signal_manifest.py`.
- `data/events/cards/customer/price_break.json`: `scope` alanı slot tanımı yerine `"prospect": "any"` dizesi taşıyor;
  kart bağlanırsa (bağlanması `ACIK_KARARLAR.md`'de açık) kapsam çözülmez.
- Olay motoru bir kart kimliğini tek örnek sayıyor: masada bir kağıdı dururken aynı kartın başka özne için ikinci
  örneği gelirse (ör. iki hesabın `customer.retention`'ı) ikisi karışıyor. Önceden düşürülen ikinci örnek ilk kağıdın
  üstüne yazılıyordu; koddan okunduğu kadarıyla şimdi son gün uyarısı gibi bütçeden muaf kesinti olarak açılıyor.
  Kuyruk ve masa `event_id` ile anahtarlı olduğu sürece örneklerden biri kaybolabilir; incelenecek (`EvQueue`,
  `EvPapers`, `EvTempo.assign`, `EvEngine._step_assign_classes`).

## Görsel kabul
- Temizlik dalgası 1 UI kodunu sadeleştirdi; görünür bir değişiklik amaçlanmadı ama commit'ler görsel kabulden geçmedi
  (kural dalgadan sonra geldi). Dokunulan ekranlar: Finans, Ar-Ge, Onboarding, Yatırım ve toplantı sahneleri, Satış,
  Ürün, Ekip, olay kartı, ODA, kayıt ve ayarlar modalları, üst bar ve sol sekmeler. Bilinen görünür farklar
  commit mesajlarının hata düzeltmesi ve "TR/EN onay bekliyor" satırlarında; ayrıca Kadro'nun TRAIT ikonu 18px'ten
  onaylı ölçüye (26×26 kutuda 15px) indi.
