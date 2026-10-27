# Dizüstüne geçiş (2026-10-27)

## Durum

- Bu makinedeki her şey GitHub'da: kod, `docs/tasks/` (faz belgeleri, PRD'ler, devir notları, kareler), maket görselleri,
  Claude hafızası ve yardımcı yönetmen oturumunun kaydı (`docs/tasks/claude_devir/`).
- Erdem'in 2026-10-27 kararı: `docs/tasks/` artık repoda izlenir (23. karar bu yüzden askıda). Repo şu an public;
  Erdem bilgisayarı ilk açışında private yapacak.
- Çalışan oturum yok:
  - Ürün arayüzü (c7) `d1eb210` ile bitti. Devir notu `GOREV_URUN_ARAYUZU_DEVAM.md` sonunda "Devir (2026-10-27)".
  - Olaylar (d5) `8fbb189` ile bitti. Devir notu `GOREV_OLAY_UYGULAMA.md` sonunda.
  - Temizlik daha önce bitti.
- Masaüstünde kalanlar:
  - Bu iki oturumun ve Temizlik'in kayıtları (110–200 MB). Devir notları işi sürdürmeye yeter.
  - `Desktop/Unicorn_arsiv/` (9,8 GB, Temizlik'in proje dışına taşıdığı arşiv).

## Dizüstünde kurulum

1. **Godot 4.6.2-stable** kur.
2. Repoyu **kök klasöre** klonla. `project-unicorn` klasörünün içine klonlama, iç içe yapı olur.
   `git clone https://github.com/erdem1v/projectunicorn "Project Unicorn"`
3. Hafızayı ve oturum kaydını Claude'un klasörüne koy:
   - Windows: `powershell -ExecutionPolicy Bypass -File "Project Unicorn\project-unicorn\docs\tasks\claude_devir\kur_windows.ps1"`
   - Mac: `bash "Project Unicorn/project-unicorn/docs/tasks/claude_devir/kur_mac.sh"`

   Betik yazdığı klasörü ve devam komutunu basar.
4. Repo klasöründe `claude --resume 6d15b35f-66f1-4e87-b274-dc8c31d2f7b4` ile bu sohbete devam et.
5. Godot editörünü bir kez aç. `.godot/` önbelleği yeniden kurulur; headless komutlar ondan sonra çalışır.
6. Godot MCP (`.mcp.json`) bu makinenin yollarını taşır: bun, gopeak, `Desktop\Godot_v4.6.2-stable_win64.exe`.
   Dizüstünde yol farklıysa MCP açılmaz. İş durmaz; kapılar CLAUDE.md'deki `$GODOT` ile koşar.

## Erdem'e sorular (işler bittikten sonra)

1. **Sprint ekranı kareleri (UE)**: https://claude.ai/artifact/XHVbFN9e5qy49eKLJyfKrw
   - Sol sütunu daraltmak yalnız 288 → 280 px kazandırıyor, eksende hafta 152 → 155 px oluyor; fark görülmüyor.
     Gerçek genişlik için seçenekler:
     - Ürün penceresini genişletmek (1920 ekranda şu an 1424 px).
     - Kart ad sütununu daraltmak (312 px).
     - Sağ sütunu daraltmak (300 px).

     Hangisi denensin?
   - Modül ikonları: küp, şapka, komut satırı, kalkan, ok, etiket. Entegrasyonlar ve Büyüme yaklaşık.
   - "Planda" yazısı: (a) ad boyunda yazı ya da (b) yeşil tik. Önerim (b).
   - Plana alınmış talep satırının tamamı soluk çiziliyor. Böyle mi kalsın?
2. **UK, kartta aşama yüzdesi**: (a) kart adının altında, (b) çubuğun içinde. Önerim (a).
3. **UM, modül adları**: https://claude.ai/artifact/GyGe7SztQx3WEQbcViTNF3. Önerim: 1B, 2 Inventory, 3 İE/EG.
4. **Hedef gösterimi** ("Sıradaki: Aylık gelir $2,5K" yerine): https://claude.ai/artifact/KagkvsuKm87Pz6VFeadRJt.
   Önerim B: hedefin ilerleme çubuklu kendi kutusu ve açılır listesi. Kaynağı `docs/tasks/hedef_gosterimi/`.
5. **Olaylar önce ve sonra (8. adım)**: https://claude.ai/artifact/LaMBoCBjGfiyEht9w5sA9j
6. **CLAUDE.md §6 kâğıt cümlesi**: "en az üçte biri" → "%7–10". Sizin onayınızı ister.
7. **Git geçmişini yeniden yazmak** (repo ~380 → 80 MB, zorla push ister). Önerim: hayır. Temizlik raporu:
   https://claude.ai/artifact/HcupSgdpAcuqLhVPypeNTQ
8. **Satış ve Müşteri ilişkileri Ar-Ge aileleri.** Ar-Ge ağacı şu an dört aileli: İşlev/ürün, Platform/geliştirme,
   Süreç/test, Tasarım. Satış ve müşteri ilişkileri dalları eklensin mi? Park edildi, PRD ister.
9. **U3–U6'daki görünür kararlarım.** U8 sayfasında "yardımcı yönetmen kararı" etiketiyle gösterilecek; her birini
   bozabilirsiniz.
10. **TR/EN onay bekleyen metinler.** Liste U4, U5, U6 ve Olaylar 7 commit mesajlarının sonunda.
11. **`project.godot` editör sırası** (`5756087`): değer değişmedi, CLAUDE.md onayınızı istiyor. Kalsın mı, geri mi alınsın?

## Sıradaki işler (dizüstünde, onayla)

- Olaylar 7c: söz bozma çipi (`promise_break`) de kartın kendi payını okur. Kanıt: `promise_due` uzat/kaydır önce
  ve sonra.
- Ürün U7: kart görünümleri ve uzun kart adının iki satırdan sonra "…" ile kesilmesi (N4'e aykırı).
- Ürün U8: görsel sayfa. UK seçilince UK yaması.

## Öncelik önerim

1. Süren işleri bitir (yukarıdaki üçü) → tek karar sayfası.
2. Erdem'in oyun oturumu: ilk 30 hafta, sprint ekranı ve 28 olay.
3. Pazar 2'yi kapat (bir soru kaldı) → pazar ve rakip PRD'si.
4. Next Fest Haziran 2027 + demo tanımı + kapsam hesabı.
5. Steam Coming Soon: sanat yönü → kapsül.
6. TR/EN metin turu.
7. En son: eğitim akışı ve hedefler.
