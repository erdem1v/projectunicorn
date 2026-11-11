# Görev: Ürün arayüzü, Erdem'in 2026-11-11 kararları (URUN_ARAYUZU)

Oturum `project-unicorn-36` (15e4f65e). Yazan: yardımcı yönetmen (`co-director`), 2026-11-11.

## Başlamadan oku

- `project-unicorn/CLAUDE.md`, `docs/tasks/ORTAK_CALISMA.md` (önce §0).
- Hafıza: `erdem-kararlar-2026-11-11`, `feedback-codirector-visible-rulings`, `feedback-ui-dont-shove-everything`.
- Karar sayfası (Erdem'in cevapları): https://claude.ai/artifact/PCyLnju7d4fMEYQwYVsCZB. Cevaplar hafıza dosyasında yazılı;
  sayfayı açman gerekmez.

## Başlama koşulu

Mac'te kaybolan D3, D5, D4a, D4b'yi yardımcı yönetmenin iş akışı yeniden kuruyor. D3 `820ba5f` ve D5 `a243eba` commit'li;
D4a ve D4b sürüyor. "YENIDEN-KURMA bitti" mesajını bekle. O zamana kadar kopya açma, kod yazma. Bu yazıyı oku, adım
tablonu çıkar ve yardımcı yönetmene gönder. D4a ve D4b'nin incelemesinde sen yoksun; bitince commit'leri bir göz oku.

## Adımlar (sırayla, her biri ayrı commit)

1. **U-1, plandaki istek biçimi (E5), önce kare.** Erdem iki biçimi de görmek istiyor ve yüzdeyi beğenmedi:
   - Biçim 1: halka ve tarih.
   - Biçim 2: kartın durumu, yüzdesiz (aşamanın adı: "Tasarımda", "Testte" gibi).
   - İki biçimde de sabit olanlar:
     - karşılanan istek, sürümden sonraki sprintin sonuna kadar (~2 hafta) açık isteklerin altında kalır; en yenisi üstte,
       sayıya girmez;
     - kart bu sprintte ama o an kimse çalışmıyorsa "Bu sprintte" yazar;
     - uzun müşteri adında tarih adın altına iner;
     - yeşil tik yalnız tamamlanınca görünür, satır soluk çizilmez;
     - N2 (b) pano yuva çipi aynı boyda ve büyük harfle, (c) "bu çeyrek" vurgu renginde.
   - Her biçim için TR karesi, biri de EN. Yardımcı yönetmene gönder; Erdem seçince kodla.
2. **U-2, modül ikonları (UE2).** Erdem seçti:
   - İlk Kullanım: açık kapı (Lucide door-open);
   - Entegrasyonlar: yapboz (puzzle);
   - Büyüme: filiz (sprout);
   - Gelir: **kredi kartı** (credit-card);
   - Çekirdek (küp) ve Güven (kalkan) zaten onaylıydı.
   
   Adaylar `docs/tasks/dizustu/raporlar/ikon_adaylari/svg/`'de. İki harfli işaretler kalkar, `PRODUCT_AREA_*_MONO`'nun öbür
   okuyucularını grep'le. `assets/icons/product/` senindir; DUZELTME oturumu 91 ikonu Lucide'a geçirirken bu klasöre dokunmaz.
3. **U-3, dar aşama çubuğu.** Sayı çubuğun hemen sağında, eksenin içinde yazar (Erdem (b)). Prototip D7 kare ajanında
   (`wf_4818d0e1-b7a`, `stage_paint`, `bar.clip_contents = false`). Kareler a4_eleven ve a4_two_pm'de olmalı.
4. **U-4, hat adları (UM'nin kalanı).**
   - Veri girişi hattı → "Satın Alma".
   - Defter → "Muhasebe".
   - EN Stok → "Inventory".
   - Nakit Akışı **değişmez**.
   - strings.csv bayt aralığıyla değişir. EN karşılıkları ("Purchasing", "Accounting") TR/EN onay bekliyor diye işaretlenir.
5. **U-5, "+" basılamıyor (H09).** Modül panelindeki "+" yalnız orta listede vurgu varken çalışıyor
   (`area_panel.gd:262-264`, hayalet yalnız imleç üstündeyken kuruluyor). Düzelt. Sığmayan kartın nedeni ipucunda kalır;
   bedelsiz "Sprinti durdur"da çip yok, değişmez.
6. **U-6, plan ekranında Ar-Ge göstergesi (H06), önce kare.** Playtest'te 19–25. haftalar boş geçti: yeni kart Ar-Ge'den
   açılıyor ama plan ekranı bunu göstermiyor (`product_model.gd:243`, `PRODUCT_GO_RND`). Erdem: "plan ekranı yeni kartın Ar-Ge'den
   açıldığını göstersin". İki biçim karesi ve önerinle yardımcı yönetmene gel; ekrana açıklama satırı yığma.
7. **U-7 (D8).** Sessiz PLANMS tabanını masaüstünde `sessiz` kilidiyle ölç; son HEAD medyanı ≤ taban +%10.
   `RAPOR_URUN_ARAYUZU.md`'yi yaz.

## Kurallar

- Erdem'in seçtiği şey doğrudan kodlanır. Görsel kabul MCP ya da `--product-shot=live:*` karesiyle yapılır, kareler rapora girer.
  Yeni görünen bir öğe (U-1, U-6) önce kareyle sorulur.
- Pencereli koşular `--screen 1` ya da `--screen 2` alır, asla ekran 0 değil (ORTAK §0).
- Commit başına en çok bir dar Opus incelemesi ve bir düzeltme turu. Push yok.
- Her commit'ten sonra yardımcı yönetmene "URUN_ARAYUZU <adım> <sha>" yaz. Bitince "hazır, son commit <sha>".
