# Görev: Satış ve ekip düzeltmeleri, ikonların Lucide'a geçişi (DUZELTME)

Oturum `project-unicorn-8e` (yeni). Yazan: yardımcı yönetmen (`co-director`), 2026-11-11.

## Başlamadan oku

- `project-unicorn/CLAUDE.md`.
- `docs/tasks/ORTAK_CALISMA.md`: önce §0, sonra §1–8. Kopya, özel index, kilitler ve kendi APPDATA kuralları bağlayıcı.
- Hafıza (giriş dizini MEMORY.md): `erdem-kararlar-2026-11-11`, `feedback-codirector-visible-rulings`,
  `feedback-fair-economy-no-hidden-costs`.
- Playtest raporu: `docs/tasks/dizustu/raporlar/playtest_2026-10-28/RAPOR.md` (madde 6, 7, 8) ve `dogrulama.json`.

## Başlama koşulu

Hemen başla, kendi kopyanda. Commit'ler yardımcı yönetmenin "YENIDEN-KURMA bitti" mesajından sonra; `kapi` kilidi o zamana
kadar onda. Pencereli koşu o zamana kadar `--screen 2`.

## Adımlar (her biri ayrı commit)

1. **D-1, hafta başı "Mesai bitiyor" (H03).** Haftanın başında 00:00–07:59 arası satış paneli "Mesai bitiyor. Bu hafta yeni bir masaya
   oturulmaz." deyip görüşmeyi kapatıyor; 08:00'de aynı hafta açılıyor. Gece ile mesai sonu aynı anahtara düşüyor
   (`sales_ledger.gd:327-328`, `work_hours_system.gd:57-59`). Düzelt; 7 Ekim'de de görülmüştü.
2. **D-2, "Kurucu" (H04).** Müşteri kartı "Müşteri temsilcisi: atanmadı" yazarken atama listesi "Kurucu … zaten sorumlu" diyor
   (`sales_tab.gd:661-666`, `customer.gd:43`, `assigned_to == ""`). Erdem: ikisi de "Kurucu" desin.
3. **D-3, yeni gelen 6 ay yıllık izne çıkmaz (H08).** İzin haftası işe alım sırasından türüyor ve yeni gelene muafiyet yok
   (`hr_constants.gd:1089-1090` `leave_week_for`, `character_registry.gd:445-447`).
   - Erdem'in kuralı: işe girişten sonraki ilk 6 ay (26 hafta) yıllık izin yok. Hastalık ve olay izinleri bu kuralın dışında.
   - 26 Erdem'in değeri; tek bir sabitte durur.
   - Kayıt uyumu korunur. Çekirdek mantık olduğu için bir smoke vakası uygun.
4. **D-4, Kadro'nun Görev sütunu kesilmez (H05).** "Defterix Fatura v1.9 üzer…" (`hr_ledger._text`: `clip_text`,
   `OVERRUN_TRIM_ELLIPSIS`). Metin kesilmez, sarar, satır büyür (28 Ekim kuralı). TR/EN ve 1,25 ölçekte kare çek.
5. **D-5, ikonların Lucide'a geçişi (K07).** Erdem: "hepsini Lucide'a geçir".
   - Envanter: `assets/icons/**` altındaki her ikon (~95 svg) ve onu okuyan her yer.
   - Her biri için bir Lucide karşılığı. Lucide ISC lisanslı; bunu üçüncü taraf notlarına yaz.
   - **Değiştirmeden önce** bir ikon kâğıdı çıkar: eski ve yeni yan yana, koyu zeminde, oyundaki boyutta (16 ve 24 px). Yardımcı
     yönetmene gönder, Erdem onaylayınca değiştir.
   - `assets/icons/product/` URUN_ARAYUZU'nundur (modül ikonları); oraya dokunma.
   - Değişimden sonra her sekmenin TR karesine bak: kayan, bulanık ya da boyu değişen ikon yok.

## Kurallar

- Kapılar CLAUDE.md §12, hedefli smoke (satış, b2b, hr önekleri).
- Görsel değişiklik kareyle kanıtlanır. Pencereli koşu `--screen 1` ya da `--screen 2`; ekran 0 asla.
- Commit başına en çok bir dar Opus incelemesi ve bir düzeltme turu. Push yok.
- Başlarken `ListAgents` koş, öbür üç oturuma tek satır yaz (etiketin DUZELTME). Her commit'ten sonra yardımcı yönetmene
  "DUZELTME <adım> <sha>" yaz. Bitince "hazır, son commit <sha>".
