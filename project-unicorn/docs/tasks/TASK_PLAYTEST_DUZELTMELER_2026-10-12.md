# TASK · Playtest düzeltmeleri (2026-10-12)

**Kim çalıştırır:** tek bir geliştirici oturumu, **Sonnet**. Başlatma cümlesi: "project-unicorn/docs/tasks/TASK_PLAYTEST_DUZELTMELER_2026-10-12.md
dosyasını oku ve uygula."
**Kaynak:** Erdem'in 2026-10-12 sabahki playtest'i; her madde onun sözü, onaylı.
**Tek cümle:** ekranlardaki kalıcı açıklama satırları kalkar ya da ipucuna taşınır, bildirimler görünür yere iner, Frank'in çeki her yerde
dolaşmaz, Piyasa ve Ar-Ge baştan açık görünür, ana menünün arka planı maketteki koyu ve tam ekran şehre döner.

## 1. Kurallar ve bütçe (API kredisiyle koşuyor, tasarruf şart)
- `CLAUDE.md` bağlayıcı (§3 doğrudan main, push yok; §5 önce İngilizce, tire yok; §7 UI/STYLE LAW; §8 ölü anahtar ve kod bırakma).
- **Model:** bu oturum Sonnet. Alt ajan ve workflow AÇMA; tek istisna CLAUDE §9 incelemesi: commit başına tek Haiku ajanı, yalnız diff.
  Düzeltme en çok bir tur. İşler arasında `/clear` gerekmez ama gereksiz dosya okuma.
- **Kapılar (commit başına):** `loc_residue` → `smoke_run.sh loc_csv_integrity` → `all_scripts_load` → dokunulan sistemin vakaları
  (HARITA'daki önekler). Tam smoke yok. Canlı ağaçta ilk koşu sınıf önbelleği hatası verirse bir kez `--headless --import` koş.
- **Görsel kabul (Erdem katı):** değişen her ekranın TR ve EN çekimi 1920'de; 1536 yalnız yerleşimi dar yerlerde. Her satır için kendine sor:
  "bu yazı burada gerekli mi, oyuncu anlıyor mu, kalabalık mı?" Ekranda kalıcı açıklama satırı EKLEME.
- Metin: kaldırılan anahtar okuyucusu kalmadıysa CSV'den de silinir. Yeni ya da değişen TR metni commit mesajında "TR/EN onay bekliyor".
- Paylaşılan ağaç: yalnız kendi hunk'ların; `checkout --`, `reset --hard`, `stash`, `clean` yok.

## 2. Maddeler

### K1 · Bildirimler, Frank'in çeki, ofis kutusu
1. **Bildirim kartları yukarı.** Bugün sağ altta çıkan bildirim kartları (`scripts/ui/office/office_notice_stack.gd` ve onu yerleştiren yer)
   gözden kaçıyor. Üst barın **altına**, üst barın bittiği çizginin hemen altına, hız düğmelerinin hizasında (sağ üst) yerleşsin.
   Üst barın İÇİNE konmaz; üst barın düzeni değişmez. Kabul: kart üst barla çakışmıyor, pencere açıkken de görünür, 1536'da taşmıyor.
2. **Frank'in çeki her yerde dolaşmasın.** Ofisteki kalıcı "Frank'in çeki · Sıradaki: …" kartı ve Olaylar gelen kutusunun en üstündeki
   "Frank'in çeki 0/5 · YATIRIM · Dikkat" kâğıdı kalkar (Açılış C3'ün `inbox.gd` `desk()` hatırlatıcısı ve ofis yığını satırı). Çekin adımları
   Kişisel'de (evre hedefi) ve Finans'ta kalır; üst barın "Sıradaki" yuvası kalır. Kabul: oyunun ilk karesinde ofiste çek kartı yok, Olaylar'da
   yalnız "İlk sabah" var; Kişisel çek listesini gösteriyor. Etkilenen vakaları (`cheque_read_steps` vb.) yeni kurala göre güncelle.
3. **Ofisi taşı kutusu.** Sol alttaki kutu koyu arayüzle uyumsuz: Menajer koyu diline taşınır (`D_*` token'ları, `menajer_theme`). "Ofisi taşı"
   yazısı yerine dünya ikonu (Lucide `globe`, `assets/art/office/icons` kalıbı) olan bir düğme; basınca bugünkü gibi harita açılır; ipucu
   "Ofisi taşı". Kutudaki "Frank'in çekinden sonra" yazısı kalkar.

### K2 · Ürün penceresi
4. **Kalıcı açıklama satırları ipucuna.** Ürün ekranındaki açıklama cümleleri (ör. "→ ile kart gönder", ÇEYREK sekmesinin yanındaki "PM işe
   alınca", "Çekirdek beklentisi netleşir") ekranda yazmaz; öğenin üzerine gelince ipucu olarak çıkar (`tooltip_text` ya da var olan ipucu kalıbı).
   Kilit gerekçesi gibi kararı değiştiren bilgi kilit ikonunun ipucunda.
5. **"Ad öner" düğmesi kalkar.** Ürün adını oyuncu kendisi yazar; öneri düğmesi ve ona ait anahtarlar silinir.
6. **Alanlar → Çekirdek:** "Ürün çekirdeği henüz yok" yazısı kalkar (üstteki boş kutular ve "yok" yeterli).
7. **Yapılanlar:** hiçbir kademesi yapılmamış satırın üç boş kutusu gösterilmez; bölüm yalnız yapılmış olanları listeler.
8. **Rakip karşılaştırması:** "2/3 rakipte var", "3/3 rakipte var" gibi rakip satırları, oyuncu bir rakip araştırması yapmadan görünmez.
   Oyunda rakip araştırması diye bir mekanik yoksa bu satırlar şimdilik tamamen kalkar; hangisi olduğunu rapora yaz.
9. **Kilitli kart:** (ör. Duyarlı arayüz) üstteki kilit ikonu ve alttaki "Kilit: tasarım yıldızın yok" yerine kartın en altında tek satır:
   kilit ikonu + "2★ tasarım gerekli" (gereken alan ve yıldız ne ise).
10. **"Rakip açığını kapatır" yazısı** kartlardan kalkar.

### K3 · Sekmeler, Kişisel, Ekip
11. **Piyasa her zaman açık.** v1.0'a kadar kilitli kalma kuralı kalkar (Açılış C4'ün `RAIL_LOCK_AFTER_V1` ve motor v3'te `ModuleLocks`'a taşınan
    "live" kilidi). Oyuncunun şirketi zaten seed'den önce listede görünmüyor. Etkilenen vakalar ve `module_unlocked("piyasa")` güncellenir.
12. **Ar-Ge v1.0 öncesi de açılır, ağaç kilitli görünür.** "İlk sürüm yayınlandıktan sonra açılır" yazısı kalkar; oyuncu ağacı görür,
    düğümler kilitli. Araştırma başlatma kuralı değişmez.
13. **Kişisel · köken:** kurucunun altında köken adı ("Sıfırdan") kalır; "Hiçbir şey yoktu. Her satırı ben yazdım." gibi hikâye cümlesi kalkar.
14. **Kişisel · durum:** kurucunun portresi altındaki görev satırı gerçeği söyler. Ürün yokken, sprint yokken ya da uyurken "Yapımda görev alıyor"
    yazmaz. Ofisteki etkinlik mantığıyla aynı kaynak (`SprintSystem.role_of`, `SupportSystem.founder_passive_care`, `74aecdf`).
15. **Kişisel · eğitim:** "Eğitime gönder" düğmesinin altındaki "Deneyim barı dolmadı" yazısı kalkar; düğmenin üstündeki deneyim yüzdesi kalır.
16. **Kişisel · değerleme:** net servetin altındaki iki cümle tek cümle olur: "Değerleme henüz yok." / "No valuation yet."
17. **Ekip · işe alım ipucu:** "İşe alım başlat" düğmesinin altındaki "Ürün seçilince bir işe alım haftada iki sprint puanı ekler" yazısı kalkar.
    (Kuralın kendisi tasarım konusu, bu task'ta değişmez.)
18. **Ekip penceresi başlığı:** kapatma düğmesinin yanındaki "7 ana · 6 ikinci" gibi rol sayıları kalkar.

### K4 · Ana menünün arka planı
19. Menü, logo, kalemler ve düzen ONAYLI; değişen yalnız arka plan (`scripts/ui/menu_backdrop.gd`, `bake_plate`, `MENU_*` sabitleri).
    Hedef: `docs/mockups/menajer/screens/ana_menu/02_ana_ilk_kosu.png` gibi.
    - **Tam ekran şehir:** 1920 ve 1536'da dört köşede de harita dışı boşluk ya da zemin kenarı görünmez; kare yalnız binalar ve mahalle
      (sokaklar, çatılar) ile dolar. Kamera kadrajı ve yakınlaştırma buna göre ayarlanır.
    - **Koyu, gri tonlu, temayla uyumlu:** dünya renkli çizilmez. Siyah-beyaza yakın, koyu gri tonlar; Menajer koyu teması (`D_SURFACE_0`
      ailesi) ile uyumlu; pencere ışıkları sıcak küçük vurgular olarak kalabilir. Yeşil park, turuncu çatı gibi renkler bastırılır
      (menü arka planına özel renk geçişi; ofis sahnesinin renkleri değişmez).
    - **Yok:** dalgakıran, turuncu tekneler, deniz kenarı süsleri. Menü sahnesinde gizlenir; ofis dosyalarına dokunulmaz.
    - Pişmiş plaka (Düşük ayarı) aynı görünümle yeniden üretilir.
    - Kabul: `--menu-shot=empty` ve `=continue` 1920 ve 1536, TR; köşe piksellerinde zemin rengi yok; maketle yan yana çekim rapora.

### K5 · Beta kanalı (ayrı commit, en son)
20. **Beta kanalı kalkar.** Ürünlerin zaten test aşaması var; "Biten kartlar bir sprint bekler, hatalı çıkma ihtimali yarıya iner" ve beta kanalı
    seçeneği oyundan çıkar, kartlar beta beklemeden yayına girer. Motor kodu, kayıt alanı, anahtarlar ve beta vakaları birlikte silinir (CLAUDE §8);
    eski kayıtta beta'da bekleyen kart sıradaki sürüme düşer. Kapı: `sprint_*` vakaları ve `run_gate.sh` 3/3.
    **Dur kuralı:** silme 10'dan fazla dosyaya yayılırsa ya da run_gate kırmızıya dönerse commit'leme, rapora yaz.

## 3. Commit sırası
K1 → K2 → K3 → K4 → K5. Her biri tek commit, kendi kapısı ve tek Haiku incelemesiyle. Push yok.

## 4. Done
Erdem'e tek mesaj: madde başına ✅/⚠️/❌, commit kimlikleri, TR/EN ekran görüntüleri (K4'te maketle yan yana), silinen ve eklenen anahtarlar,
madde 8'in hangi yolla çözüldüğü, K5'in yapılıp yapılmadığı.
