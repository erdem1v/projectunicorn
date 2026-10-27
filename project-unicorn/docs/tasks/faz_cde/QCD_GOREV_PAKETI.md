# Q, C, D PRD turu · Görev paketi
2026-10-18 · Yardımcı yönetmen (oturum 3ef3b847) · Bu turdaki bütün ajanların ortak girdisi. Repo kodu değişmez, commit
yok, Godot koşturulmaz.

## 1. Erdem'in talimatı (birebir, 2026-10-18)
> sen prdleri hazırlamaya başla her prd için sorularını prdler tamamlandıktan sonra tekrar sor gerekirse revize yaparız
> oyunun oynanışına nasıl etki edeceğini düşünerek alternatif başarılı oyunlkarın analizlerini yaparak bu oyunun %90üstü
> olumlu review almasını sağlayacak şekilde kurgulanmalı ve ve iyi analiz edilmeli. bu oyuna çok fazla emek ve mesai
> harcadım. şu anda steam ai generated oyun kaynıyor sıradan olamayız kötü olmayız bozuk hiç olamayız. codirector oldugunu
> unutma oynanışını nasıl etkiler diye sormalısın core gameplay core döngü eğlenceli ve akıcı olmak zorunda

Okuma:
- Çıta Steam'de %90 üstü olumlu yorum. Ölçüt "mantıklı model" değil, **eğlenceli ve akıcı çekirdek döngü**.
- Her mekanik "oynanışı nasıl etkiler" sorusundan geçer. Doğru ama sıkıcı, doğru ama angarya, doğru ama okunmaz olan
  mekanik kesilir ya da sadeleşir.
- Sorular PRD'ler bitince PRD başına sorulur. Erdem'in itirazı olursa revize edilir.

## 2. Bu turun çıktıları
| Dosya | Ne |
|---|---|
| `arastirma/R13_OVULEN.md` | Çok olumlu yorum alan yönetim ve tycoon oyunları: çekirdek döngü, karar yoğunluğu, yorumlarda övülen şeyler |
| `arastirma/R14_KIZILAN.md` | Türün olumsuz yorum kalıpları, zayıf oyunlar, "yapay zekâ üretimi" şüphesi |
| `arastirma/R15_BIZIM_DONGU.md` | Bizim oyunun bugünkü döngüsü (A ve B sonrası, `main` @ `889b9b8`) |
| `OYNANIS_HUKMU.md` | Q, C, D'nin her mekaniğine oynanış hükmü, hedef çekirdek döngü, %90 kontrol listesi |
| `PRD_FAZ_Q_KALITE.md` | Faz Q görevi (ekransız kalite modeli) |
| `PRD_FAZ_C_URUN_HESAP.md` | Faz C görevi (ürün sayfası, sunucu, giderler, B2B hesaplar ve memnuniyet) |
| `PRD_FAZ_D_EKIP_SPRINT.md` | Faz D görevi (ekip modeli ve sprint düzeni) |

Hepsi `project-unicorn/docs/tasks/faz_cde/` altında (izlenmiyor). Faz sırası: **Q → C → D**, sonra E (pazaryeri, Erdem'in
yorumu bekleniyor, bu turda yok).

## 3. Kaynaklar ve öncelik (çelişkide üstteki geçerli)
1. `ERDEM_CDQ_CEVAP.md`: Erdem'in 17 Ekim akşam kararları ve ekleri (birebir). Bağlayıcı.
2. `ERDEM_CD_YORUM.md`: Erdem'in 17 Ekim öğle yorumu (birebir).
3. Bu turun tasarım belgeleri: `C_ICERIK_v3.md`, `KALITE_v2.md`, `SPRINT_DUZENI.md`, `D_MODEL_v3.md`, ölçümleri
   `D_SIM_v3.md`, `MEMNUNIYET_SIM.md`. Her birinin sonundaki "İnceleme notu (Opus)" gövdeden önce gelir.
4. v3'ün "değişmeyen" dediği kısımlar için `C_ICERIK_v2.md` ve `D_MODEL_v2.md`; ürün eksenleri için `X_URUN_EKSENLERI.md`.
5. Uygulanmış olanı anlatan: `../faz_ab/PRD_FAZ_A_HATALAR.md`, `../faz_ab/PRD_FAZ_B_OLAYLAR.md`, `../faz_ab/RAPOR_A.md`,
   `../faz_ab/RAPOR_B.md`. **Faz B bitti** (son commit `889b9b8`). RAPOR_B §1 madde 1: A'nın hata sprinti hedefleri olaylar
   açıkken tutmuyor; D bunu sahiplenir.
6. Özet: `OYUN_SISTEMLERI.md` (planlanan son hâlin rehberi). Araştırmalar `arastirma/R1`–`R12`.
7. Eski planlar (`C_PLAN.md`, `D_PLAN.md`, `C_GOREV.md`, `D_GOREV.md`): yalnız v3'ün sessiz kaldığı yerde.

## 4. Erdem'in bağlayıcı kuralları (bu tur için)
- **Görünmez model yok.** Oyuncunun hiçbir yerde görmediği sayı ekonomiyi sürmez.
- **Gizli gider yok.** Giderde yalnız oyuncunun gördüğü ve yönettiği kalem durur.
- **Durup dururken düşüş yok.** Memnuniyet yalnız adı yazan bir nedenle düşer.
- **Zorluk dozu:** "amacımız oyuncuyu gerçek hayat gibi aşırı zorlamak değil". Sağlıklı büyüme hedefi.
- **Ölçek:** Her kural 1, 3, 6, 12, 25 ve 50 kişide sınanır, uç bileşimler dahil. Sabit yerine oran. Her kuralın "neden var"
  cevabı. "X oyununda var" tek başına gerekçe değildir.
- **Ekranlar:** Claude Design maketi yok. Ekran oyunun kendi Menajer diliyle gösterilir (`docs/mockups/menajer/`).
- **Yazım:** TR ve EN birlikte; oyuncu metninde tire yok; doğal beyaz yaka Türkçesi, tam cümle, kısa ve doğrudan.
- **Uygulama kuralları** (PRD'nin §8'ine yazılır): önce adım tablosu ve Erdem'in onayı; Sonnet kodlar (xhigh ya da max),
  Haiku mekanik iş ve kapılar, Opus kıdemli inceleme ve düzeltme hakkı; commit başına en çok 1 inceleme ve 1 düzeltme;
  push yalnız Erdem "push et" deyince ve öncesinde tam smoke yok; tek klasör, worktree yok; `git checkout --` yasak; yalnız
  kendi değişikliğini commit et; editörün `project.godot` ve tema farkı commit edilmez; Erdem oyun oynarken ağır iş yok.
- Kayıt şeması bugün 17. Sıradaki faz bir sonrakini alır (Q şema değiştirirse 18, C bir sonrakini, D ondan sonrakini).

## 5. Erdem'in açık 10 sorusu (PRD'lere dağılımı)
Erdem bunlara henüz cevap vermedi. PRD'lerde öneri olarak yazılır, **"onay bekliyor"** işaretlenir, PRD'nin sonundaki
sorulara girer. Oynanış hükmü bir öneriyi değiştirirse gerekçesi yazılır.
- **Q:** 1 sektör ağırlıkları ve ölü sektörler (Sağlık, Tekstil, Medya); 2 pazar beklentisi doyumu (imzaların %75'inde
  ürün uyumu 100).
- **C:** 3 memnuniyet modeli (satırların toplamı, imza kapısı, hata terimi, güncelleme yaşı); 4 giderler (servis giderin
  yarısı; maaş ×1,5 önerisi; kurucu satırı, ofis kirası); 5 bütçe kesintisi; ayrıca yenileme bantları (C v3 Soru 5).
- **D:** 6 test ve gönder sorusu; 7 birden çok PM; 8 kurucunun %10 düşüşü; 9 sprint düzeni ve tek kurucuda %6,6 hata
  sprinti; 10 EA takımı.

## 6. Yardımcı yönetmenin oynanış riskleri (OYNANIS_HUKMU bunları karara bağlar)
1. Orta ve son oyunda karar kalmıyor: ürün uyumu doyuyor, her yenileme zamla bitiyor, bakımlı üründe kayıp yok.
2. Zorluk eğrisi: servis gideri kalkınca ilk yıl fazla kolaylaşıyor.
3. 50 kişide oyuncu ne yapıyor: sprint 2 ya da 3 tık. Karar kart seçmekten stratejiye kaymalı.
4. Sistem kalabalığı: her sistem tek satırla okunmalı ve bir karar doğurmalı, doğurmuyorsa kesilmeli.
5. Akış kesintileri: gönder sorusu, acil durum, kâğıt ve mail aynı haftaya binmemeli.

## 7. PRD biçimi (A ve B'nin biçimi, artı iki zorunlu ek)
Başlık bloğu ve "Bu belgeyi alan ajana" bölümü `PRD_FAZ_A_HATALAR.md` gibi. Bölümler:
0. Ekler ve öncelik
1. Amaç (Erdem'in sözleriyle)
2. Kararlar (bağlayıcı). Her kararın altında **"Oynanışa etkisi"**: oyuncunun kararı, ne sıklıkta, nasıl okunur (tek
   satır), angarya ya da akış kesintisi riski, 1 kişide ve 50 kişide ne hissettirir, OYNANIS_HUKMU'nün hükmü.
3. Oyuncu ne görecek: ekran ekran, örnek metin TR/EN, Menajer dili.
4. Kabul ölçütleri: ölçülebilir kapılar (simülasyon kapıları ve bot ölçümleri) ve **oynanış kapıları**.
5. Araştırma (uygulayıcı yapar, koddan önce; gerekiyorsa)
6. Bağlantılar: kopukluk olmayacak (bağlantı haritası; dosya:satır `main` @ `889b9b8`'e göre)
7. Kapsam dışı
8. Çalışma biçimi ve adım tablosu (commit dilimleri; her dilimin modeli ve kapı bütçesi)
9. Aynı ağaçtaki öbür fazlarla kurallar
10. **Erdem'e sorular**: en çok 6; her biri önerili ve oynanış etkisi tek cümleyle.

Belge "ne bekliyoruz"u yazar, "nasıl kodlanır"ı uygulayıcıya bırakır. Kod referansları dosya:satır. Uzunluk A ve B
kadar (500 ile 650 satır); tekrar yok, kalabalık yok.
