---
name: sanat-yonu-ikinci-tur-2026-10-20
description: "Sanat yönü 2. tur (artifact 5bg2Xgcz…): skill taraması sonucu (create-game-assets + kendi co-director skill'imiz kuruldu), 3 yön, ortak taban, Erdem'den 4 karar bekleniyor; doğrulanmış gerçekler"
metadata:
  node_type: memory
  type: project
  originSessionId: 3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869
  modified: 2026-10-19T23:01:50.091Z
---

2026-10-20: İlk sanat araştırması reddedildi ([[feedback-art-direction-timeless]]). Erdem iki şey istedi: GitHub'da
co-director ve sanat skill'leri taransın, sanat araştırması o yöntemle baştan yapılsın.

**Kurulanlar** (proje `.claude/skills/`, commit yok):
- `create-game-assets`: Apache-2.0, gamedev-skills deposundan. Adım 5 değiştirildi: yönü her zaman Erdem seçer.
- `co-director`: bizim skill'imiz. tronghieu, gstack-game ve superpowers depolarından (üçü de MIT) damıtıldı.
- `project-unicorn/docs/design/ART_BIBLE.md`: iskelet.
- Kurulmayanlar: superpowers, gstack ve CCGS. Gerekçe hook, telemetri ve token yükü.

**Sayfa:** https://claude.ai/artifact/5bg2XgczC5DPzkGzRkFgSf. Ham raporlar scratchpad'te:
- `sanat2/1_referanslar.md`: 18 oyun, eksen tabloları.
- `sanat2/2_teshis_teknik.md`: teşhis ve 14 teknik.
- `skills/2a`, `skills/2b`, `skills/6_blender.md`.

**Üç yön** (kimliği taşıyan katmana göre):
1. Sessiz dünya, konuşan renk. "Şimdi seçilecekse" önerim bu: ortak taban dahil 36–79 saat.
2. Çizilmiş an: kurucuları, Frank'i ve yatırımcıları illüstratör çizer.
3. Elle yapılmış biçim: ölçülmedi, en pahalısı.

Ortak taban yönden bağımsız, 22–48 saat: açık koyu düzeni, rol rengi, şirket adı ve logosu, klişe temizliği.

**Erdem'den 4 karar bekleniyor:**
1. Ortak tabana onay. Ardından iş hanında tek önce/sonra çifti.
2. Yön şimdi mi seçilsin, yoksa ortak tabandan sonra 2–3 illüstratöre ücretli boyama denemesinden sonra mı? Önerim deneme.
3. Portreler: a, b ya da c. Önerim (a) oran düzelt ve yeniden çek.
4. Dönem değişimi yıla mı bağlansın, ofis taşınmasına mı? Önerim taşınma.

**Doğrulanmış gerçekler:**
- Oyunun takvimi kodda 1 Ocak 2026'da başlıyor (`game_state.gd:8` START_DATE). Erdem'in tarifi 2012. Çelişki açık.
- Portre klasörü 12 kişi: 11 kurucu ve Frank. Çalışan portreleri sabit set değil, çalışırken render ediliyor.
- Olay kartlarında görsel alanı yok (134 kart).
- Roller 7: müşteri temsilcisi dahil. Tasarım kaynağındaki rol renkleri 6 rolü kapsıyor ve oyunda kullanılmıyor.
- Ofis geometrisi Claude'un yazdığı koddan üretiliyor, bu yüzden YZ beyanına girer. Hazır paketten gelenler karakterler,
  animasyonlar ve Lucide ikonları.
- Blender bu makinede kurulu değil. Blender MCP yolu 100–250 saat tutar; bu bir tahmin, kaynaklı ölçüm yok.

İlgili: [[steam-coming-soon-draft-2026-10-19]] · [[feedback-design-research-first]] · [[feedback-visual-research-one-pair]] · [[feedback-bespoke-assets-over-packs]]
