# U6 inceleme (Opus high, rv6): KIRIK yok; 1 YANLIŞ, 1 ZAYIF, 2 TEMİZLİK; kararlara 4 not. Godot koşulmadı (kod okuması).

1. YANLIŞ: board_row.gd:351 `_tick` ve card_tip.gd:76 `_who` etiketi `s.before`'dan seçiyor; SprintTimeline._card (sprint_timeline.gd:192) koşan sprintte
   `before`'u hem önceki sprintte önden biten (progress_at_start = total, need = 0) hem bu sprintin önceki haftasında biten aşama için doğru yapıyor →
   a4_run_w2'de önceki sprintte önden bitmiş tasarım "Tasarım · bu sprintte bitti" okunuyor (doğrusu B3 PRODUCT_AHEAD_DONE). Düzeltme: `s.need <= EPS and
   s.pre > EPS` → AHEAD_DONE, değilse STAGE_DONE_NOW; SprintUiShared'de tek yardımcı.
2. ZAYIF: board_row.gd:18 WAIT_KEYS / `_wait_tip`: kimsenin çalışmadığı araştırma aşamasının beklemesinde role "product" → WAIT_KEYS'te yok → ipucu boş. PRD B2 sessiz.
3. TEMİZLİK: board_row.gd:435 `_names`, :443 `_wait_tip`: ad için ProductModel.stage_face tam yüz kaydı (HRSystem.skill, yıldız) kuruyor; ad
   CharacterRegistry.get_character(id).character_name'den okunsun.
4. TEMİZLİK: sprint_board.gd `_early_tip(c)` erken kapanış yokken de hesaplanıyor ve iki kez çağrılıyor; sprint_next.gd `_load_row` `line.mouse_filter = PASS` gereksiz.

Notlar: N-a ad Label'ı özel ipucu kuran küçük Label alt sınıfı, MOUSE_FILTER_PASS kalsın (STOP satır hover'ını, → ×'i ve tekerleği kırar); satırın kendi
tooltip_text'i boşalsın; panel/düz seçimi açılışta bir kez yapılır (satırda imleç konumuna bakmak işe yaramaz).
N-b çubuğun tooltip_text'i bugün yalnız aşama adı (board_row.gd:393); B1 metni kurulumda yazılırsa koşan sprintte bayatlar → StagePaint'te tip_panel yerine
`_get_tooltip()` ve açılışta `_bar_tip(entry)`; CardTip.panel'ın `part` parametresi ölü kalır, silinsin.
N-c karar 2: `_next_card`'ın `ahead_week`/`started` hesabı bayrağa insin ya da silinsin; product_fixtures.gd:189, product_model.gd başlık yorumu, 08 belgesi.
N-d `_product_tip_shot` imleci sabit noktaya koyuyor (main.gd:3888); panel yalnız adda açılınca kısa adda nokta dışarı düşer → imleç ad Label'ının ortasına.

Sorunsuz: fare/etkileşim (IGNORE→PASS öğeler olay geçiriyor, STOP yok), bayat ipucu (F3 set_progress, C1 set_done, B1 açılışta _now), model yalnız okuma,
motor yoluna dokunan satır yok, panel sızıntısı yok, silinenlerin okuyucusu yok, CSV tek blok 36 satır LF, tokenlar eş, §11.1 harfi harfine (STAGE_DONE_NOW EN hariç),
çekim kancası yalnız shot yolunda, doküman atıfları doğru (09'un main.gd:46xx–53xx atıfları tabanda da kaymış; U6 +30 ekledi).
