# Görev: Ürün > Sprint arayüzü ve Archivo (PRD_URUN_SPRINT_ARAYUZU uygulaması)

2026-10-23 · Yazan: yardımcı yönetmen (oturum `co-director`) · Erdem paralel başlattı

## Ne yapacaksın

`docs/tasks/PRD_URUN_SPRINT_ARAYUZU.md`'yi U0'dan U8'e uygula. PRD kapalıdır: tasarım sorusu sorma. PRD'nin sessiz ya da
çelişkili olduğu bir yer bulursan kodlamayı o noktada durdur ve yardımcı yönetmene tek mesajda, numaralı liste olarak yaz.
Varsayılan seçme.

## Başlamadan oku

1. `project-unicorn/CLAUDE.md` (kod, metin, CSV, smoke ve commit kuralları).
2. `docs/tasks/PRD_URUN_SPRINT_ARAYUZU.md` baştan sona.
3. Maket: Sprint Ekranı A4 (24 kare). Yerel: `docs/strateji/sprint_ekrani/A4.html`. Bağlantı:
   https://claude.ai/artifact/U7PDe2j3ZJNRRFGcmFiu9v . Erdem A4'ü 2026-10-23'te gördü ve bu görevin yazılmasını istedi;
   PRD'deki "U2, Erdem A4'e baktıktan sonra" şartı karşılandı.
4. Kod haritası: `docs/kod_haritasi/README.md`, ardından `sistemler/02_urun_sprint.md`, `08_sekmeler.md`,
   `09_arayuz_bilesen.md`, `01_cekirdek.md`. Kod aramadan önce haritaya bak.
5. Erdem'in kararları: `docs/tasks/faz_cde/ERDEM_KARARLAR_2026-10-20.md` (2026-10-22 ve 2026-10-23 bölümleri).

## Sıra ve başka oturumla ortak çalışma

- **D oturumu (`project-unicorn-6a`) aynı klasörde sprint modelini kodluyor** (D1b, D2b, D3, D4, D7m). PRD §12 hangi
  U adımının hangi D adımını beklediğini yazar. **U0 (Archivo) hemen başlayabilir.** U1 ve sonrası §12'deki D adımları
  commit'lenince başlar; D'ye ve yardımcı yönetmene sor, tahmin etme.
- Git index'i ve Godot ortak: index'e girmeden ve Godot koşmadan önce D'ye ve `co-director`'a "kapı bende", bitince
  "bitti" yaz. Aynı anda makinede en çok iki Godot süreci olur (D biri kullanıyor); sen en çok bir süreç kullan.
- Erdem oyun oynarken (bellek 2 GB'ın altında) ağır koşu başlatma.
- Başka oturumun commit'lenmemiş değişikliğine dokunma; `git checkout -- <yol>` kullanma.

## Çalışma kuralları

- Her adım: Sonnet kodlar (yüksek düşünme) → Haiku kapıları koşar ve kareleri çeker → Opus kıdemli gözle inceler
  (yalnız diff, CLAUDE.md §9, dokunulan sistem sayfasının "Dikkat" listesi) ve gerekirse düzeltir → commit.
  Commit başına en çok 1 inceleme ve 1 düzeltme; düzeltmeden sonra kapı düşerse adım durur, yardımcı yönetmene gelinir.
- Commit öneki `Ürün arayüzü Un:`, uyguladığı kararın numarası (PRD §3), metin varsa "TR/EN onay bekliyor".
  **Push yok.** Push yalnız Erdem "push et" deyince.
- Bir sistemi değiştiren commit, o sistemin `docs/kod_haritasi/sistemler/` sayfasını ve `docs/HARITA.md`'yi de günceller.
  DIZIN, SEMBOLLER ve KALITE elle düzenlenmez; commit'ten sonra `python -I tools/kod_haritasi/uret.py` koşulur ve çıktı
  aynı commit'e girer.
- Eski çizim, alan, işlev ve anahtar, son okuyucusunu değiştiren adımın commit'inde silinir (CLAUDE.md §8).
- Oyuncu metninde tire yok, açıklayıcı cümle yok (Erdem: oyuncu kuralı görselden anlar). Ekranda "SP" değil "Efor".
- Görsel kabul: her adımın karesini maketin karesiyle yan yana koy; U8'in görsel sayfasını yardımcı yönetmen Erdem'e sunar.

## Bitince

- Her commit'ten sonra `co-director`'a tek satır: adım, sha, oyuncu ne görür.
- Sonunda `docs/tasks/RAPOR_URUN_ARAYUZU.md`: commit'ler, onay bekleyen metinler ve sabitler, park edilenler, bilinen
  sorunlar. Rapor tek başına okunduğunda yetmeli.
