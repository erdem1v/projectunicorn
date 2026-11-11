# Görev: Hedef paneli, Yardım sekmesi ve üst bar (ARAYUZ)

Oturum `project-unicorn-07` (yeni). Yazan: yardımcı yönetmen (`co-director`), 2026-11-11.

## Başlamadan oku

- `project-unicorn/CLAUDE.md`, özellikle §5 metin, §7 UI/STYLE LAW, §11 görsel kabul.
- `docs/tasks/ORTAK_CALISMA.md`: önce §0, sonra §1–8. Kopya, özel index, kilitler ve kendi APPDATA kuralları bağlayıcı.
- Hafıza (giriş dizini MEMORY.md):
  - `erdem-kararlar-2026-11-11`;
  - `feedback-codirector-visible-rulings`;
  - `feedback-ui-show-dont-tell`;
  - `feedback-ui-dont-shove-everything`;
  - `ui-design-system`.
- Tasarım çalışması: `docs/tasks/dizustu/raporlar/hedef_paneli/` (`index.html`, `img/`, `maket/AB_birlesik/mock.html`).
  Erdem 28 Ekim'de Planet Zoo gibi bir düğmeyle açılan ayrı bir görünüm istemişti.
- Kod: `scripts/systems/cheque_read.gd` (hedef merdiveni; "cheque" 5 adım, sonra "seed" 2 adım).
  `scripts/ui/components/top_bar.gd`: 257–288 civarındaki SIRADAKİ yuvası 7 şeyi taşıyor; hedef adımı en düşük öncelikli yedek.
  `scripts/ui/components/left_tabs.gd`: ray.

## Başlama koşulu

Hemen başla, kendi kopyanda. Commit'ler yardımcı yönetmenin "YENIDEN-KURMA bitti" mesajından sonra; `kapi` kilidi o zamana kadar
onda. Pencereli koşu o zamana kadar `--screen 2`.

## Adımlar

1. **A-1, hedef paneli (K14).** Erdem birleşik tasarımı seçti.
   - Rayda Ayarlar'ın üstünde kapalı bir satır: "Hedefler 4/5" ve bölmeli çubuk.
   - Satıra basınca panel açılır. Sırasıyla:
     - şimdiki hedef büyük, çubuğuyla ve ilgili sekmeye giden düğmeyle (ör. "Satış'a git");
     - merdiven;
     - kilitli Seed listesi.
   - Frank'in cümlesi yalnız portre ipucunda.
   - Hedef listesi kalmayınca ray satırı kalkar.
   - Hedef adımı üst barın SIRADAKİ yuvasından çıkar; o yuvanın öbür altı işi kalır.
   - Maketten farklı bir şey gerekirse önce kareyle sor.
2. **A-2, Yardım sekmesi (K14, Erdem "şimdi eklensin" dedi).** Önce içerik önerisi.
   - Ne girer: terimler (MRR, runway, burn, churn...), her pencerenin ne işe yaradığı, kısayollar gibi. Ne girmez.
   - Panelde nerede durur.
   - İki kare ve önerinle yardımcı yönetmene gel. Erdem seçince kodla.
   - Metin önce İngilizce yazılır, Türkçe yerelleştirilir; hepsi "TR/EN onay bekliyor".
3. **A-3, SIRADAKİ yalnız başlık (H05).** Erdem: "Sadece başlık, 'Çeyrek bülteni' olabilir; devamına gerek var mı?"
   - Yuvada artık "Çeyrek bülteni: i… · bu hafta son" gibi kesik metin yok, yalnız işin başlığı.
   - Ayrıntı ipucunda.
   - Yedi kipin hepsini 1920 ve 1,25 ölçekte, TR ve EN karede denetle: kesik yok, taşma yok.

## Kurallar

- Yeni token ya da varyasyon `build_theme.gd`'den geçer. `THEME_STAMP` HEAD'deki değerin bir fazlası olur (CLAUDE.md §7,
  ORTAK §3).
- Oyuncu metni anahtar olarak doğar (`strings.csv`, bayt aralığıyla).
- Görsel kabul `--office-shot` / `--tab-shot` kareleriyle ya da MCP ile yapılır, rapora girer. Pencereli koşu `--screen 1`
  ya da `--screen 2`; ekran 0 asla.
- Commit başına en çok bir dar Opus incelemesi ve bir düzeltme turu. Push yok.
- Başlarken `ListAgents` koş, öbür üç oturuma tek satır yaz (etiketin ARAYUZ). Her commit'ten sonra yardımcı yönetmene
  "ARAYUZ <adım> <sha>" yaz. Bitince "hazır, son commit <sha>".
