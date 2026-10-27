---
name: feedback-subagent-token-budget
description: "Erdem 2026-10-11: alt ajanlarda token tasarrufu: model zorluğa göre (Haiku mekanik, Sonnet normal, Opus yalnız zor), commit başına en çok 1 inceleme (belgede yok), en çok 1 düzeltme turu, delta/ölçüm turu yok"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 2610fb6d-cae0-4e43-9d47-4e478120fb43
  modified: 2026-10-26T15:12:53.470Z
---

2026-10-11 08:00. Kural Erdem'in co-director oturumu `project-steam-ad` üzerinden geldi (eski co-director c4 artık
kullanılmıyor). Aynı gece Erdem bana doğrudan da yazdı: "harcadığın kaynağın haddi hesabı yok".

1. **Model seçimi:** modeli işin zorluğuna göre ben seçerim.
   - Mekanik iş Haiku'ya gider: CSV, belge, kopya, kapı ve smoke koşturma, ekran çekimi, port, okuma/grep.
   - Normal uygulama ve inceleme Sonnet'e gider.
   - Opus yalnız gerçekten zor motor mantığında ya da Sonnet iki kez takılınca.
2. **İnceleme:** commit başına en çok tek inceleme ajanı (Haiku ya da Sonnet, yalnız diff). Yalnız belge, CSV ya da
   metin taşıyan commit'te ayrı inceleme yok. Çok mercekli inceleme, çapraz kontrol ve ikinci tur yok.
3. **Düzeltme:** en çok 1 tur; ek delta ya da ölçüm turu yok.
   - PRD'nin istediği kapılar koşulur, fazlası koşulmaz.
   - TR+EN çekimi yalnız metni değişen ekranda yapılır.
   - Kalite çıtası aynı: kapı yeşil olmadan commit yok.
4. **Koşan ajanlar:** koşanlar durdurulmaz; kural bundan sonra başlayanlara uygulanır.

**Why:** iki $200 hesabın haftalık limiti 1,5 günde bitti; bu hesap %65'teydi. Erdem bir task'ın 10 saat sürmesini de
istemiyor.

**How to apply:**
- Workflow yazarken her `agent()` çağrısına `model`'i işe göre ver. Varsayılan Opus devralmasına bırakma.
- Açılış'ta bu kural `lean.js` olarak uygulandı (scratchpad 2610fb6d). Koşan workflow aşama sınırında kesildi
  (journal izleyici + TaskStop), kalan aşamalar lean.js ile sürdü.
- Erdem'in eski "subagent olarak opus 5.5 kullan" talimatının yerini aldı.
- **Ultracode açık olsa da bu kural geçerlidir** (2026-10-26 OLAYLAR: yazı turuna ve plana eleştirmen ajanı koydum,
  co-director "metin ve JSON adımlarında inceleme yok, kod commit'inde tek inceleme" diye düzeltti). Plan/tasarım
  belgesinde ayrı eleştirmen yerine üreten ajana öz denetim (koddan grep'le doğrulama) yazdırılır.
- Co-director PRD yazarken her commit için model ve kapı bütçesini PRD'ye yazar (PRD kısa, kapı yalnız gereken).

İlgili: [[acilis-task-2026-10-10]] · [[codirector-session-2026-10-07]]
