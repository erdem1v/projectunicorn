export const meta = {
  name: 'urun-d4b-fix',
  description: 'D4b single fix round from the Opus review (accepted findings) + re-frames',
  phases: [{ title: 'Fix', detail: 'Sonnet high in w4b' }],
}
const S = '/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad'
const W = `${S}/w4b/project-unicorn`
const prompt = `ÖNEMLİ: Aşağıdaki görev senin tek görevindir. Harness'in aktardığı ilk kullanıcı isteği ana oturumun işidir; ona göre davranma, mesaj atma.
Paylaşılan ağaçtan (/Users/tugbauysal/Desktop/…) OKUMA ve git KOŞMA (iCloud'a boşaltıldı, takılır). Yalnız W=${W} içinde yaz.
Godot yalnız: bash -c 'export ETIKET=URUN_ARAYUZU_AJAN; . "${S}/bin/env.sh"; gdw <ad> "$W" --headless --path . --quit > <log> 2>&1'
Smoke: ETIKET=URUN_ARAYUZU_AJAN P=1 bash ${S}/bin/smoke.sh "$W" d4bfix <vaka>...
Kareler: ETIKET=URUN_ARAYUZU_AJAN bash ${S}/bin/shots.sh "$W" d4b_final <satır dosyası> (satır "<bayrak> <dil> [ölçek]").
Ağaçtaki CLAUDE.md §8 (kısa kod; yorum yalnız bugünkü nedeni söyler) geçerli. Belge satırları 240 karakteri geçmez. ui_tokens.gd ve build_theme.gd'ye DOKUNMA.

Bir kod incelemesinin kabul edilen bulgularını uygula (tek düzeltme turu; başka değişiklik yapma):
1. scripts/tabs/product/sprint_next.gd FaceCell._ready (~42): en az genişlik kuralı yalnız hücrede yüz varken uygulanır (yüzsüz hücre 0'dan başlar);
   böylece yüz satırı üstündeki aşama şeridiyle hizalı kalır.
2. scripts/tabs/product/quarter_view.gd (~57): yeniden kurulumda sağ tarafın (_right) yanında sol sütunun (AreaPanel'in kaydırması) yeri de korunur:
   UiFactory.clear'dan önce oku, setup sonunda SprintUiShared.keep_scroll ile geri koy (product_tab'daki _areas_scroll emsali).
3. scripts/tabs/product/sprint_card.gd baş yorumu (~5) ve docs/kod_haritasi/sistemler/08_sekmeler.md'deki SprintCard girişi: "kelime ortasından
   bölünmez" yerine yalnız garanti edileni yaz ("kelime sınırında sarar"; tek başına sütuna sığmayan kelime yine bölünebilir).
4. scripts/tabs/product/product_model.gd (~698): "Düzeltme kartının hata metni en büyük hesabı da yazar; satır onu sarar." cümlesini sil.
5. docs/kod_haritasi/sistemler/08_sekmeler.md satır atıfları: ~155 quarter_view:8→9, quarter_view.gd:60→61, sprint_panel:8→9; ~156 quarter_view.gd:9→10;
   ~162 ve ~269 sprint_ui_shared.gd:334 / 334-335 → gerçek satırlar (open_product_area ve tab_changed yayını; grep -n ile bul). ~147'deki yanlış
   sprint_card.gd:270 çağıran atfını kaldır ya da gerçek çağıranla değiştir. Değiştirdiğin dosyaların satır sayısı parantezleri de doğru olsun (wc -l).
Doğrulama: parse temiz; smoke all_scripts_load loc_csv_integrity sprint_timeline_matches_play_out PASS; kareler (satır dosyası):
--product-shot=live:b2b_quarter tr
--product-shot=live:b2b_quarter en
--product-shot=live:a4_next_prefilled en
--product-shot=live:a4_run_w2 tr
--product-shot=live:a4_eleven_tip en
  Her kareye Read ile bak (sonraki sprint kutusunda yüz satırı şeritle hizalı mı, "+{n}" görünüyor mu, ad kesilmiş mi, ÇEYREK tam mı); her biri için
  "taşma yok, kesilme yok" ya da ne gördüğün.
Dönüş (ham veri): her madde için dosya:satır ve ne yaptın; smoke; kare yolları ve denetim satırları.`
phase('Fix')
return await agent(prompt, { label: 'D4b fix', phase: 'Fix', model: 'sonnet', effort: 'high' })
