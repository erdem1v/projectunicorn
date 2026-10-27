---
name: single-folder-single-remote-rule
description: "TESLİM YASASI (Erdem 2026-08-20): dal yok, worktree yok, merge yok — doğrudan main'e yazılır; Erdem oyunu açar, 'geri al' geri alır, 'push et' pushlar"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 955ec736-e19a-4a5c-9868-df5099415d75
  modified: 2026-08-20T12:49:40.176Z
---

**Yasa (Erdem, 2026-08-20). CLAUDE.md'de "DELIVERY LAW — ONE FOLDER, ONE BRANCH", TECH_SPEC §19.7
ve 2026-08-20 tarihli Karar Günlüğü satırı olarak yazıldı.**

1. **Tek klasör.** `Desktop/project steam` tek checkout'tur. **Worktree AÇILMAZ** — spike için de,
   taban ölçümü için de, "geçici olarak" da değil.
2. **Tek dal.** İş doğrudan `main`'e commit edilir. **Feature dalı yok, merge commit yok, rebase
   yok.** Uzakta yalnız `main` durur; GitHub laptoptan erişim içindir, ikinci bir yapı deposu
   değil. Lokalde ne varsa GitHub'da o görünür.
3. **Gerçekten dal ya da ikinci klasör gerekiyorsa ÖNCE SOR** — belirsiz spec'te olduğu gibi dur
   ve sor. Açıp sonra haber verme.
4. **İnceleme döngüsü iki kelime.** Ajan dosyaları değiştirir, Erdem oyunu açıp bakar.
   **"Geri al"** → değişiklik geri alınır. **"Push et"** → GitHub'a gider. **İSTENMEDEN PUSH
   EDİLMEZ.** Onay bekleyen işi dalda park etmeye gerek yok — revert o işi zaten yapıyor.

**Gözlenebilir (yasanın kendi ölçütü):** `git branch` tam olarak `* main`, `git worktree list` tek
satır, `git ls-remote --heads origin` tam olarak `refs/heads/main` basar. Üçünden biri fazlasını
basıyorsa yasa çiğnenmiş demektir.

**Why:** Üç bitmiş oturum (Lokalizasyon Faz 2, Kalibrasyon Turu A, Build Bar) haftalarca main'in
dışında kaldı; Erdem'in F5'te oynadığı oyun yapılanların neredeyse hiçbirini içermiyordu ve "oyun"
kelimesi birbiriyle çelişen üç kod tabanına işaret eder olmuştu. Onları birleştiren merge'de **tek
bir hüküm çatışması bile çıkmadı** — dallar izolasyon maliyeti ödetmiş, karşılığında inceleme
kazandırmamıştı. Paralel worktree'ler ayrıca bütün bir hata sınıfını besliyordu: paylaşılan
`.godot/` sınıf önbelleği, ODA tema denetimini oynatan paylaşılan `user://settings.json`, sahipsiz
uncommitted değişiklikler. İnceleyen tek kişi tek yapıya bakıyorsa revert daldan ucuzdur.

**How to apply:**
- `git worktree add`, `git switch -c`, `git merge` yazmadan önce DUR. Bu üçü artık izin ister.
- Tema tabanını worktree ile alma — **düzenlemeden ÖNCE aynı ağaçta** dökümü al (2026-08-20'de
  böyle yapıldı: A/B/C dökümü, `@Sınıf@NN` normalize edilip diff'lendi).
- Geri dönüş noktası gerekiyorsa **lokal etiket** kullan (`pre-merge/*` gibi), push etme.
- İş bitince "bitti, şunlar değişti" de ve DUR. Push için Erdem'in "push et" demesini bekle.

İlgili: [[concurrent-session-hazard]], [[github-repo-projectunicorn]], [[project-unicorn-current-stage]]
