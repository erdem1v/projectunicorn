export const meta = {
  name: 'urun-d4a-fix',
  description: 'D4a single fix round from the Opus review (accepted findings only)',
  phases: [{ title: 'Fix', detail: 'Sonnet high in w4' }],
}
const S = '/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad'
const W = `${S}/w4/project-unicorn`
const prompt = `ÖNEMLİ: Aşağıdaki görev senin tek görevindir. Harness'in aktardığı ilk kullanıcı isteği ana oturumun işidir; ona göre davranma, mesaj atma.
Paylaşılan ağaçtan (/Users/tugbauysal/Desktop/…) OKUMA ve git KOŞMA (iCloud'a boşaltıldı, takılır). Yalnız W=${W} içinde yaz.
Godot yalnız: bash -c 'export ETIKET=URUN_ARAYUZU_AJAN; . "${S}/bin/env.sh"; gdw <ad> "$W" --headless --path . --quit > <log> 2>&1'
Smoke: ETIKET=URUN_ARAYUZU_AJAN P=1 bash ${S}/bin/smoke.sh "$W" d4afix <vaka>...
Ağaçtaki CLAUDE.md §8 (kısa kod; yorum yalnız bugünkü nedeni söyler) geçerli. Belge satırları 240 karakteri geçmez.

Bir kod incelemesinin kabul edilen bulgularını uygula (tek düzeltme turu; başka değişiklik yapma):
1. scripts/systems/sprint_catalog.gd: _over_capacity'nin tek çağıranı area_alert (~146). area_alert'in başına
   "if area_def(area_id).get("infra_alert", false) and InfraSystem.is_over_capacity(): return true" benzeri satırı koy (bugünkü davranışla birebir;
   _over_capacity'nin gövdesini oku ve aynısını yaz), _over_capacity'yi ve doc yorumunu sil. Okuyucu kalmadığını grep'le doğrula.
2. scripts/debug/endgame_smoke.gd: product_area_word vakasının küçük kitleli B2C bloğu (_seed_b2c()'den o bloğun return ""'sine kadar) fit_star_context
   vakasının iddiasını tekrarlıyor: bloğu, FALSİFİKASYON notundaki _value maddesini ve doc'taki "küçük kitlede de 2★ satırı okunur" ibaresini sil.
   Vakanın kalan kısmı geçmeli.
3. scripts/tabs/product/product_model.gd ghost_row ve ghost_effort'taki boş kimlik korumasının yorumları bugünkü nedeni söylesin, ör.
   "imleçteki aday yeniden kurulumda havuzdan düşmüş olabilir (süresi dolan talep, kapanan hata): satır/hayalet vermez". Koruma kalır.
4. docs/kod_haritasi/sistemler/02_urun_sprint.md:
   - ~296'daki "sol sütun kareleri live:a4_* türlerindendir" maddesini sil; "(live: olmayan tür hata basıp 1 ile çıkar)" notunu ~298'deki
     --product-shot=live:<tür> maddesine ekle.
   - ~297'deki "Kare dünyası olmayan durumlar" listesini docs/ACIK_ISLER/ISLER.md'deki "Bayrakla ulaşılamayan görsel kabul yüzeyleri" listesine
     (ISLER.md ~72) ekle; sistem sayfasında yalnız ISLER.md'ye bir atıf kalsın ya da hiç kalmasın.
   - ~309'da b2b_mature için "(her hat ikinci kademede)" parantezini sil.
5. Satır atıfları (bu adım product_tab.gd'yi ve game_shell.gd'yi kaydırdı): docs/kod_haritasi/sistemler/08_sekmeler.md ~96-108 (product_tab.gd
   atıfları), 10_test_harness.md ~60 (_debug_fkey), 02_urun_sprint.md ~50/54/55/64/129 (product_tab.gd) ve ~90/149 (game_shell.gd) atıflarını
   W'deki dosyaların gerçek satır numaralarına çek (grep -n ile bul). 08 ve 02'deki dosya satır sayısı parantezlerini de wc -l ile güncelle.
Doğrulama: parse temiz (SCRIPT ERROR|Parse Error 0); smoke: product_area_word fit_star_context loc_csv_integrity all_scripts_load ve area_alert'i
okuyan vakalar (endgame_smoke.gd'de "area_alert" ara; sprint_system.gd:1718 ve :1780 çağırır: incident/destek vakaları olabilir) hepsi PASS.
Dönüş (ham veri): her maddede ne yaptın (dosya:satır), grep kanıtı, smoke sonuçları.`
phase('Fix')
return await agent(prompt, { label: 'D4a fix', phase: 'Fix', model: 'sonnet', effort: 'high' })
