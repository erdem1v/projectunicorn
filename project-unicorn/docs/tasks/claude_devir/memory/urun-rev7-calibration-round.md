---
name: urun-rev7-calibration-round
description: "Ürün rev 7 kalibrasyon düzeltme turu (2026-10-02) — Erdem'in 8 kararı (vaat→sprint, MVP ~6. hafta, B2C iki son, geç oyun sistem+olay, servis gideri eski kararı geri alır, onboarding 0,5×/3×, $50/gün→Araçlar tabanı, söz kilidi 8 hafta); plan dosyası ve ayar penceresi"
metadata:
  node_type: memory
  type: project
  originSessionId: c035abc5-791b-4063-9220-8a62d9937f33
  modified: 2026-10-02T12:16:40.387Z
---

Plan: `C:\Users\erdem\.claude\plans\task-r-n-rev-snuggly-haven.md` (onaylı 2026-10-02). Denetim kanıtı scratchpad `urun_rev7/audit/RESULT.json`.

**Kararlar (Erdem, AskUserQuestion ile):**
1. Vaat son tarihi = bir sonraki planlanabilir sprintin sonu; planlamada görünür, lider önce önerir (ACIK #80 kapanır).
2. MVP ~6. hafta: `founder_roles` → product+design+dev+test; MVP 3 hat kalır; MVP öncesine olay.
3. B2C İKİ SONA da ulaşabilir (ch01 §7) — not: profitable_bootstrap `faced_series_a` ister, yani B2C de 120K kapısından geçer.
4. Geç oyun: sistem (Araçlar + servis gideri) + nakit maliyetli kartlar; ofis kirası BAĞLANMAZ.
5. Servis gideri 27–28 Eylül "yalnız sunucu faturası" kararını GERİ ALIR (GUNCELLEMELER ch06 §1.1, ch08 §1 yeniden yazılır).
6. Onboarding "gelirin önünde harcama" terimi: Traction 0,5×, Series A Hunt 3×.
7. Kurucunun $50/gün'ü Araçlar kaleminin 1. evre tabanı (ACIK #21 A).
8. Kırık söz sonrası o hesaba 8 hafta "Söz ver" kilidi (süreli, koşu boyu değil).

**Ayar penceresi:** yalnız planda listelenen sabitler, plan değerinin ±%50'si, en fazla 2 tur; dışına çıkmak için dur ve sor.

**3. tur kararları (ilk ölçümden sonra):** 9) founder_mult 0,75→1,0 (solo sprint 3=K1 3 sıfır paydı, her saat kaybı MVP'yi 2 hafta itiyordu); 10) "Söz ver" yalnız adım planlanabilir sprintin boş kapasitesine sığarsa (tüm söz satırları + satış kapanışı); 11) B2C: önce bot destek masasını erken doldurur, kapı yine kapalıysa fiyat-her-sürümde sorulacak; 12) faz 3 ölçütü "runway sonlu" yerine "karar kalır" (pencere kartı tekrarlanır + gelirin önünde harcama kartı, sabit gider artışı yok).

**İlk ölçüm (8 seed) bulguları:** B2C iflas 32→0, Frank w24/w19, Traction w15; B2C kapı yok (zirve $48K/$70K: memnuniyet destek masası boş diye 10'da); lean bootstrap 6/8; vc_cautious 6/8 = taban; kırık vaat 6–17 (taban 6–23); MVP B2B 13 çünkü YENİ pre-MVP karar kartları solo sprinti eritiyordu (sprint_late normal hızda bile ateşleniyor, solo'ya tek seçenek bırakıyor). Ders: solo sıfır-pay kapasitesinde saat bedelli kart = 2 haftalık uçurum.

**SONUÇ 2026-10-03: commit'lendi, push yok** — `ec49028` (kod+veri+test+27 yeni kart), `b1dfcb8` (probe/bot harness), `b9b792b` (belgeler, ACIK 97–102). 8 seed ölçümde 17/18 kabul satırı geçti: MVP tik 7 (64/64), kırık söz ≤3 (taban 6–23), B2C iflas 0/40, B2C kapı 76–92 + vc imza 8/8, lean bootstrap 7/8, vc_cautious 6/8 = taban. AÇIK (Erdem'de): (1) ONBOARDING_MRR_MULT[2] 0,5→0,25 (karar 6'nın sayısı; seed 2 iflasını kapattı) onayı; (2) B2B Traction sonlu-runway 0,09–0,21 vs hedef ≥0,40 — pencere içi hiçbir gider seed öncesi iflas ettirmeden yükseltemiyor; (3) B2C 60. haftadan sonra memnuniyet ≤10 + doğrulanmış hata yığını 185–686; (4) Series A Hunt'ta 2–5 haftalık kararsız aralıklar. Ortam dersi: paralel oturum aynı ağaçta commit atıyor ve import edilmemiş varlıklarla canlı ağacı boot edilemez bıraktı → doğrulama HEAD+bizim dosyalar snapshot'ında, commit `git hash-object -w` + `update-index --cacheinfo` ile snapshot blob'larından (bkz. [[partial-staging-shared-tree]]).

**Why:** denetim MVP 13. hafta, 14–23 kırık vaat, B2C ~34. haftada iflas, faz 3 runway hep INF buldu; Erdem "detaylı kalibrasyon fix" istedi, yeni kart yazmaya izin verdi.

**How to apply:** bu turda karar sorulmuş konuları yeniden sorma; yeni sabit ihtiyacında dur-sor. Yeni metin EN önce + TR yeniden yazım, "TR/EN onay bekliyor"; Frank satırı yok. İlgili: [[urun-rev7-faz-a]] · [[smoke-verification-cadence]] · [[strings-csv-surgery]] · [[card-text-token-rules]]


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Ürün rev 7 kalibrasyon turu](urun-rev7-calibration-round.md) — 2026-10-02 Erdem'in 8 kararı (vaat→sprint, MVP ~6. hafta, B2C iki son, Araçlar+servis gideri, onboarding 0,5×/3×, söz kilidi 8 hafta); plan dosyası + ±%50 ayar penceresi; **commit ec49028/b1dfcb8/b9b792b (push yok), 17/18 kabul; açık: onboarding 0,25 onayı, B2B Traction runway, B2C geç memnuniyet**
