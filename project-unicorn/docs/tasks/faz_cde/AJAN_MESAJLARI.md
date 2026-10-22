# Q, C, D ajan mesajları ve sıra
2026-10-18 · Yardımcı yönetmen. Her mesaj ayrı bir ajan oturumuna olduğu gibi yapıştırılır.

## Sıra
| Dalga | Ne yürür | Bitiş koşulu |
|---|---|---|
| 0 · Şimdi | RAPOR_B madde 7 düzeltmesinin sahibi oturum commit eder (`sprint_system.gd`, `sprint_probe.gd`, `endgame_smoke.gd`). Üç oturum açılır, her biri adım tablosunu getirir. Godot'suz hazırlık aynı anda yürür: Q0 ve Q0v; C0, C0v, C0r ve W1; D0t, D0s ve W | Madde 7 commit'i `git log`'da, Q'nun adım tablosu onaylı |
| 1 · Q kodlar | Q: K1 … K9, E1 durağı, rapor. Godot'u yalnız Q koşturur. C ve D docs altında hazırlığını bitirir | `RAPOR_Q.md` var, Q'nun son commit'i `git log`'da |
| 2a · Maketler | C0m, ardından M (sırayla, aynı anda değil): ekranlar oyunun kendi arayüzüyle. Ardından C'nin ve D'nin E1 durakları | Kareler alındı, C'nin E1'i cevaplandı |
| 2b · C kodlar | C: C1 … C9, E2, rapor. D bekler | `RAPOR_C.md` var, C'nin son commit'i `git log`'da |
| 3 · D kodlar | D: D0 … D9, rapor | `RAPOR_D.md` var |
| 4 · Playtest | Erdem'in derli toplu playtest'i, sonra revizyon | |

---

## Mesaj 1 · Faz Q (Kalite)
```
Sen Project Unicorn'da Faz Q'nun (Kalite) uygulayıcısısın. Görevin şu PRD:
project-unicorn/docs/tasks/faz_cde/PRD_FAZ_Q_KALITE.md
PRD bağlayıcıdır. Önce baştan sona oku, sonra §0'daki ekleri ve aynı klasördeki ERDEM_QCD_CEVAP.md'yi (benim 18 Ekim kararlarım) oku.

İlk iş: koda dokunmadan PRD §8'deki adım tablosunu güncel koda göre bana getir (Adım | Ne | Kim | Model | Düşünme | Süre | Neden) ve onayımı bekle. Onaya kadar yalnız Q0 haritası ve Q0v yürüyebilir; ikisi de oyun dosyasına yazmaz, Godot koşturmaz.

Başlama koşulu: ağaçta RAPOR_B §1 madde 7'nin commit edilmemiş düzeltmesi var (sprint_system.gd, sprint_probe.gd, endgame_smoke.gd). Bu commit git log'da görünmeden hiçbir oyun dosyasına yazma ve Godot koşturma; dosyalar hâlâ kirliyse dur ve bana sor.

Aynı ağaçta C ve D oturumları da açık. Sen bitirene kadar onlar yalnız docs altında çalışır ve Godot'u yalnız sen koşturursun. Ortak dosyalar PRD §9'da.

Kurallar:
- Her commit: Sonnet kodlar (xhigh, büyük dilimde max), Haiku kapıları koşar ve ekran çeker, Opus kıdemli inceleme yapar (düzeltme hakkı var), sonra commit. Commit başına en çok 1 inceleme ve 1 düzeltme.
- Commit öneki "Faz Q Kn:". Yalnız kendi değişikliğini commit et. project.godot ve tema farkı commit edilmez. git checkout -- yasak. Worktree yok. Push yok; push yalnız ben "push et" deyince.
- Ben oyun oynarken ağır iş (bot koşusu, tam smoke) açma.
- E1'de ölçüm tablolarıyla bana dur. Onaysız sabit yazma; kapı tutmazsa ölçümle gel, sabiti sessizce oynatma.
- Oyuncu metni TR ve EN birlikte, tiresiz.

Bitince aynı klasöre RAPOR_Q.md yaz: önce bakılacaklar, kabul ölçütleri, onay bekleyenler, commit listesi, sorular. C ve D bu raporu bekliyor.
```

## Mesaj 2 · Faz C (Ürün ve hesaplar)
```
Sen Project Unicorn'da Faz C'nin (Ürün sayfası, sunucu, giderler, B2B hesaplar) uygulayıcısısın. Görevin şu PRD:
project-unicorn/docs/tasks/faz_cde/PRD_FAZ_C_URUN_HESAP.md
PRD bağlayıcıdır. Önce baştan sona oku, sonra §0'daki ekleri ve aynı klasördeki ERDEM_QCD_CEVAP.md'yi (benim 18 Ekim kararlarım) oku.

İlk iş: koda dokunmadan PRD §8'deki adım tablosunu bana getir (Adım | Ne | Kim | Model | Düşünme | Süre | Neden) ve onayımı bekle.

Başlama koşulu: Faz Q şu an aynı ağaçta kod yazıyor. RAPOR_Q.md gelip Q'nun son commit'i git log'da görünene kadar:
- Yalnız C0, C0v, C0r ve W1 yürür.
- Oyun koduna, strings.csv'ye ve data/'ya yazma; Godot koşturma.
- Çıktıların docs/tasks/faz_cde/c_taslak/ altında durur.
Q bitince:
- C0s yalnız python -I ile koşar. Simülasyon betikleri docs/tasks/faz_cde/c_taslak/msim/ altında.
- C0m (ekranlar oyunun kendi arayüzüyle) D'nin maketinden önce ve onunla aynı anda değil koşar.
- Sonra E1'de bana dur, onaydan sonra C1'den başla.
Kayıt şeması 19. Ortak dosyalar ve D'ye verilecekler PRD §9'da.

Kurallar:
- Her commit: Sonnet kodlar (xhigh, büyük dilimde max), Haiku kapıları koşar ve ekran çeker, Opus kıdemli inceleme yapar (düzeltme hakkı var), sonra commit. Commit başına en çok 1 inceleme ve 1 düzeltme.
- Commit öneki "Faz C Cn:". Yalnız kendi değişikliğini commit et. project.godot ve tema farkı commit edilmez. git checkout -- yasak. Worktree yok. Push yok; push yalnız ben "push et" deyince.
- Ben oyun oynarken ağır iş açma.
- E1 ve E2'de ölçümle bana dur. Onaysız sabit yazma; kapı tutmazsa ölçümle gel.
- Oyuncu metni TR ve EN birlikte, tiresiz.

Bitince aynı klasöre RAPOR_C.md yaz. D bu raporu bekliyor.
```

## Mesaj 3 · Faz D (Ekip ve sprint)
```
Sen Project Unicorn'da Faz D'nin (Ekip modeli ve sprint düzeni) uygulayıcısısın. Görevin şu PRD:
project-unicorn/docs/tasks/faz_cde/PRD_FAZ_D_EKIP_SPRINT.md
PRD bağlayıcıdır. Önce baştan sona oku, sonra §0'daki ekleri ve aynı klasördeki ERDEM_QCD_CEVAP.md'yi (benim 18 Ekim kararlarım) oku.

İlk iş: koda dokunmadan PRD §8'deki adım tablosunu bana getir (Adım | Ne | Kim | Model | Düşünme | Süre | Neden) ve onayımı bekle.

Başlama koşulu: Faz Q ve ardından Faz C aynı ağaçta kod yazacak. RAPOR_C.md gelip C'nin son commit'i git log'da görünene kadar oyun koduna, strings.csv'ye ve data/'ya yazma.
Q bitmeden:
- Yalnız D0t (Godot'suz harita), D0s ve W yürür. D0s yalnız python -I ile koşar.
- Simülasyon betikleri docs/tasks/faz_cde/d_taslak/dsim/ ve d_taslak/sprint_duzeni/ altında.
Q bitince:
- M (sprint planı maketi, oyunun kendi arayüzüyle) C'nin C0m'inden sonra ve onunla aynı anda değil koşar.
- Sonra E1'de bana dur.
C bitince D0'dan başla. Kayıt şeması 20; D1 başlarken şema 19 değilse dur.
RAPOR_B §1 madde 1 (A'nın hata sprinti hedefleri olaylar açıkken) senin kabul ölçütündür.

Kurallar:
- Her commit: Sonnet kodlar (xhigh, büyük dilimde max), Haiku kapıları koşar ve ekran çeker, Opus kıdemli inceleme yapar (düzeltme hakkı var), sonra commit. Commit başına en çok 1 inceleme ve 1 düzeltme.
- Commit öneki "Faz D Dn:". Yalnız kendi değişikliğini commit et. project.godot ve tema farkı commit edilmez. git checkout -- yasak. Worktree yok. Push yok; push yalnız ben "push et" deyince.
- Ben oyun oynarken ağır iş açma.
- E1'de bana dur. Onaysız sabit yazma; kapı tutmazsa ölçümle gel.
- Oyuncu metni TR ve EN birlikte, tiresiz.
- Her kural 1, 3, 6, 12, 25 ve 50 kişide sınanır.

Bitince aynı klasöre RAPOR_D.md yaz.
```
