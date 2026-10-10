# Tasarım kaynağı

- Claude Design projesi `65a0b148-cecc-42fb-9055-08f4d4be0def` ("Office view comparison mock"),
  dosya `Ofis Gorunumu v12.dc.html`. Sahne Three.js r0.160.0 ile prosedürel kurulur.
- `src/` altındaki yedi modül 2026-09-27'de tasarım projesinden kopyalandı. Görüşme akışının
  (`Yatirimci Gorusmesi v3.dc.html`) iki modülü, `office-meet.js` ve `office-city-v2.js`,
  2026-09-29'da eklendi.
- Şehir `office-city-v2.js`'ten dışa aktarılır (yatırımcı kulesi ve `meetRoom` kipi). `office-city.js`
  delta almadan, alındığı gibi durur: `office-sim-v12.js` onu içe aktarır ve o satır değişmez.
- Kural: kopya bayt-bayt aynıdır. Değişebilen tek şey aşağıdaki deltalardır; geometri, malzeme ve
  sayı satırlarına dokunulmaz. Tasarım güncellenirse modüller yeniden kopyalanır, deltalar yeniden
  uygulanır, `bash tools/office3d/run_export.sh` ve `python tools/office3d/check_export.py` koşulur.

## Modüller

| dosya | bayt (alındığı gibi) | sha256 (alındığı gibi) | delta |
|---|---|---|---|
| `office-sim-v12.js` | 136319 | `73c41e1d3d8b62c85be004bc0902878df9f094546bb7bf45e7a659073415f92f` | var |
| `office-sim-v2.js` | 41957 | `c7ad0b65ac4657db616d082ba97f4cd8156f6cb17fbe4a4d63dd76bc996b7301` | yok |
| `people-x.js` | 8113 | `08c12e96dcc026456c787d0458bab8aba57ef5b5b581db8e00af102c99246cc1` | yok |
| `office-home.js` | 20686 | `30cd177562e75d978d4f6c13de1c5c3b66dba760359cd3c79f5d65ae1b263664` | yok |
| `office-plaza-v2.js` | 17355 | `6e2e92fe74d6a622cde726c566cbbc8d41f42f8e44988b757218e39299e75348` | yok |
| `office-loft-v2.js` | 22312 | `336a55d2f6c31c0b28f7d050fff6fe6c91b587d2fa29525668201918b5af28ae` | var |
| `office-city.js` | 19733 | `50f78b6e1a8555fc4ec49a3c38158d13a65cc302dfa3cddfef315f29d538419e` | yok |
| `office-city-v2.js` | 21691 | `8abb096f872c017f664e3ebe5e110bf094e545e681e4ae5abcf1e2b821c914f9` | var |
| `office-meet.js` | 9392 | `565d8fc6b9032f6f6f31edc4af20d247cdd6e997ecd20025e4c2f301f24d80f9` | var |

## Deltalar

Hepsi eklemedir; hiçbir tasarım satırı silinmez ya da değer değiştirmez. Eklenen satırlar
`tools/office3d` işaretini taşır.

| dosya | ne | neden |
|---|---|---|
| `office-sim-v12.js` | `createOffice` içindeki `const H = { THREE, V, … lineMat };` nesnesi modül seviyesindeki `makeH()`'e taşındı (anahtar listesi bayt-bayt aynı); `createOffice` yerinde `const H = makeH();` çağırır | Dışa aktarma sayfası builder'ları `createOffice`'in açtığı renderer olmadan, aynı `H` ile çağırır. `makeH()` `initMats()`'ten sonra çağrılır, `createOffice`'teki sırayla aynı |
| `office-sim-v12.js` | Dosya sonuna `setTier(t)`, `SHARED` (modül seviyesindeki paylaşılan malzemelerin tutamakları: `winMat … streetGlow`) ve `export { initMats, applyPalette, bake, buildA2, makeH, setTier, loadXbot, SHARED }` | `TIER` modülün `let`'idir, dışarıdan yazılamaz. Godot malzemeleri adla bağlar, adlar `SHARED` üzerinden verilir. Küçük resimler `loadXbot()`'un sözünü bekler |
| `office-city-v2.js` | `const boats = [];` satırı ve tekne döngüsünde `boats.push(bt);`; dönen nesneye `frames, pin, ferry, cars, boats, wtex, facMats, crown: crownMat` | Kapanıştaki tutamaklar: düğüm adları (`frame_<id>`, `pin`, `ferry`, `car_<i>`, `boat_<i>`), su ve cephe malzemesi adları, JSON'daki araba şeritleri; kulenin tacı (`crown`), varışta parlar |
| `office-meet.js` | Dönen nesneye `pen, penA, penB` | Masadaki kalem düğümü (`pen`) ve iki yeri (elde, masaya bırakılmış) |
| `office-loft-v2.js` | Dönen nesneye `ferry, wtex` | `ferry` düğüm adı ve su malzemesi (`water`) |

`office-home.js` ve `office-plaza-v2.js` delta almadı: ev kapısı kanadı ve plaza asansör kapıları
`L.elev.panels` üzerinden zaten açıktır; kule malzemeleri `towerMat()`'ın `userData.d/n` imzasından
bulunur.

Deltalardan sonra: `office-sim-v12.js` `fd075441c435578838e8115aa135663664d800bf3f17f0d89669179bb41fa354`,
`office-loft-v2.js` `eb7faced966c454bb72c9f27a4e0f1315487b079913db6ae35df17a225ed05cb`,
`office-city-v2.js` `0db02b70f3878550d3cab2d22ee993f11d4a3210a04218836923a4d77114d5e8`,
`office-meet.js` `9916f728a9d55aa20b24b6f3cce553657a7230fc595f34e2da175cc905209746`.

`neighbourhood.js` tasarımın değil, `export_office.js`'in `bake()`'ten önce çağırdığı ek modüldür (README, "Mahalle") ve
`src/` altında hiçbir bayt değiştirmez: yukarıdaki dokuz sha256 ve deltalardan sonraki dört değer olduğu gibi geçerlidir.
