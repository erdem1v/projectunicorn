---
name: ekip-verim-destek-task-2026-10-11
description: "PRD_EKIP_VERIM_DESTEK uygulaması (oturum 2610fb6d, co-director project-steam-ad'den, Erdem onaylı): 11 madde 5 commit grubunda (EG1–EG5), tek şerit, tek Godot; ekip.js workflow'u, EKIP_BRIEF.md"
metadata:
  node_type: memory
  type: project
  originSessionId: 2610fb6d-cae0-4e43-9d47-4e478120fb43
  modified: 2026-10-11T22:49:22.650Z
---

2026-10-11 12:05'te başladı.

- **Görev:** co-director `project-steam-ad` (Erdem onaylı) verdi: "PRD_EKIP_VERIM_DESTEK.md dosyasını oku ve uygula"
  (commit 8b4ccad + 3434eca). İş: destek (D1–D4), verim ve moral (V1–V4), sprint akışı (S1–S3).
- **Gruplama:** co-director 11 maddeyi 5 commit'e topladı; hedef 5–6 saat (Erdem 10 saati aşmak istemiyor).
  - EG1 = V2 + D1 + D3 + D2
  - EG2 = V4
  - EG3 = V1 (ölçüm tablosu burada)
  - EG4 = S3 + S1 + S2
  - EG5 = D4 + V3
  - Bir grup takılırsa bölünür, kalan gruplar sürer. Her grup bitince co-director'a tek satır yazılır.
- **Model:** kod Opus. Kapı ve çekim Haiku. Diff ve karelerin tek incelemesini Sonnet yapar, mesajı da o taslar. En
  çok 1 Opus düzeltme turu. Commit Sonnet.
- **Kısıtlar:**
  - Bellek dar: tek şerit (Açılış makinesi `bin/`, `acl/t`), tek Godot süreci.
  - TR/EN çekim; 1536 yalnız dar yerleşimli yeni satırlarda.
  - Erdem görsel kabulde titiz: her satır "burada doğru mu, oyuncu anlıyor mu".
- **Dosyalar:**
  - Brif: `<eski scratchpad 027d2566>/acilis/EKIP_BRIEF.md`; makine Açılış'ınki.
  - Workflow: `<yeni scratchpad 2610fb6d>/ekip.js`, args `{items: ["EGn"], notes}`; grup başına ayrı koşu.
  - EG1 koşusu `wf_b2436dff-b47`.
- **Ortak ağaç:** 2d (Onarım O19–O22: Satış, B2B, inbox, satış görüşmesi) ve 51 (ana menü: menu, save_manager,
  onboarding, tema) aynı ağaçta. Ortak dosyalarda (strings.csv, endgame_smoke.gd, main.gd) yalnız kendi hunk'larımız.

- **15:00 G1 main'de: `88aedb6`.** Süre 2 sa 50 dk; kapılar üç kez baştan koştu.
  - Ölçüm: D1 temsilcisiz 11,2/hafta, tek temsilciyle 39,2/hafta.
  - Hızlandırma (co-director onaylı): fixer yalnız etkilenen kapıları koşup alt kümeyle mühürler; regates ajanı yok.
    Gate runner aynı ağaçta PASS olan kapıyı tekrar koşmaz. Commit'te exit 3 olursa ve dosya kesişimi yoksa yalnız dört
    hızlı kapı koşar.
- **Co-director'ın G1 kararları:** EG2'ye "EG2 extra" olarak katıldı, commit gövdesinde "G1 kararları" başlığıyla.
  1. Aşırı yük ve Mood Buster 8 saatte eski 0,25/gün tabanı × çarpanla aşındırır.
  2. Destek'e atanan max(taban, CS) ile doğrular.
  3. "Gelen {n} · bu hafta {m} kaçırıldı" tek satır.
  4. CLAUDE.md §5 ödünç listesine "hotfix" ve "onboarding".
- G2 koşusu `wf_e22f6a97-111` (15:05). **16:31 G2 main'de: `4091900`** (1 sa 26 dk, düzeltmesiz).
  - Sahip soruları co-director'a gitti: izin tekrarlanabilir, 2 hafta baskın değil; elle izin yaz iznini yer;
    izin/tatil terim karışıklığı; GDD ve GUNCELLEMELER girdisi G5 sonuna mı.
- G3 koşusu `wf_676ba609-d96` (16:33). Notlar: izindeki kişide "VERIM %100" yazmasın; moral hız vaadi veren metinler
  güncellenir.
- Co-director'ın G2 kararları G5'e kondu ("EG5 extra"; G3 o sırada koşuyordu): izin +12/+25 ve 8 hafta bekleme, yaz izni
  yan cümlesi, tek kelime "izin", belgeler (GUNCELLEMELER V1–V4/D1–D4/S1–S3, GDD cümlesini geçersiz kılan girdi, HARITA).
- **18:19 G3 main'de: `b730f49`** (1 sa 46 dk). Tablo, eski → yeni %2:
  - 8 sa: 1,000 → 1,000.
  - 10 sa: 1,125 → 1,219 (MVP 7. → 5. hafta).
  - 12 sa: 1,250 → 1,422.
- **G3'te çıkan kusur:** Haiku kapı ajanı, kapılar zaten PASS olduğu için kareleri çekmedi. ekip.js'e "kareler zorunlu" ve
  bir kez yalnız kare deneme kuralı eklendi.
- G3'ün sahip soruları co-director'a gitti: işe giriş morali 75 tam +%5 kademesinde; kurucunun uzun günü güçlendi; gün
  sonu %90 mı %88 mi.
- G4 koşusu `wf_42e977e9-388` (18:30).
- Co-director'ın G3 kararları G5'e kondu:
  - +%5 kademesi 76'dan başlar; işe giriş morali 75 kalır.
  - Dosyada kaydırma çubuğu yasak: en güçlü 3 gerekçe görünür, kalanı "+{n} neden" satırına toplanır.
  - Gün sonu rakamı son saatin verimi kalır (%90).
  - Kurucunun uzun günü sabah Erdem'e açık karar olarak gider: mesai düşüşü %5–6 ya da kurucuya taşınan yorgunluk.
    Done raporunda 8/10/12/15 saat tablosu kurucu ve çalışan için ayrı verilecek; tabloyu G5 ölçer.
- **21:27 G4 main'de: `6660058`** (~3 sa).
  - S3 probe: 6 kişilik ekibi açık kart sayısı sınırlıyor (haftada ~2,4 kişi boşta); 1 haftalık sprintte karar kâğıdı
    ve demo_day yok; sprint sayılı kurallar takvimde iki kat hızlı; vc_cautious Series A 64. gün.
  - Planlama ekranında kesilen kart adı fix turunda düzeldi.
- G5 koşusu `wf_331b3a9a-180` (21:30): D4, V3, G2 ve G3 kararları, belgeler (motor md §27 ve GUNCELLEMELER:196 dahil;
  ACIK 103'e dokunulmaz).
- Co-director'ın G4 kararları → **G6** (G5'ten sonra; brif "### EG6", ekip.js `EG6`):
  1. Sprint sayılı kurallar takvime: talep 8 hf, çeyrek 12 hf, rakip 6 hf, söz aynı ilkeyle; 2 haftalık sprintte
     bayt-eşlik kanıtı run_gate, taban ve yeni ağaçta.
  2. 1 haftalık sprintte karar kâğıdı ve demo_day ilk haftada çekilir.
  3. Boştaki kişi satırı "{n} kişi boşta · iş bekliyor".
  Açık kart havuzu ve vc_cautious 64 yalnız Done notu.
- **00:13 (10-12) G5 main'de: `af5b7d1`** (2 sa 43 dk).
  - İnceleme 1 engel ve 2 büyük bulgu buldu, fix turunda kapandı: izin dönüşü dosyada kaydırma çubuğu;
    `hr_manual_leave_` bayrağı TYPE_INT oldu; ZAMAN MODELİ md doğrudan düzeltildi (GUNCELLEMELER başlığı böyle diyor).
  - Saat tablosu: kurucu ve nötr çalışan aynı; 8/10/12/15 sa → 1,000 / 1,219 / 1,422 / 1,696.
- G6 koşusu `wf_e0c5ccd8-10b` (00:16): takvim çevirisi + 1 haftalık sprint çekilişi + "iş bekliyor"; run_gate kanıtı
  EG6base ve EG6 ağacında.
- **01:47 (10-12) TAMAM: G6 `aeae8a9`** (düzeltmesiz). 2 haftalık sprint bayt-eş: run_gate 104/104/64 iki ağaçta aynı.
  - Toplam 13,5 saat (Erdem'in 10 saat sınırının üstünde): tek Godot, kayan HEAD, iki grupta fix turu.
  - Done raporu co-director'a gitti. Açık kararlar: kurucunun uzun günü; büyük ekip kart havuzu; vc_cautious 64;
    rivals.json sprint sayıyor; lead_overtime ve password_rule 1 haftalık sprintte hiç gelmiyor; ACIK 103 bayat.
  - **Tuzak:** canlı ağacın sınıf önbelleği motor portundan beri bayat ("EvDelays not declared"). Canlıda başsız
    koşulardan önce `--import` gerekir; commit ağaçları etkilenmez. 2d ve 51'e bildirildi.

İlgili: [[feedback-subagent-token-budget]] · [[acilis-task-2026-10-10]]


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Ekip verimi/destek task 2026-10-11](ekip-verim-destek-task-2026-10-11.md) — PRD_EKIP_VERIM_DESTEK **TAMAM 2026-10-12 01:47**: 6 commit G1 `88aedb6` … G6 `aeae8a9` (push yok), 13,5 saat; açık sahip kararları dosyada; motor v3 portu `5933acc`; canlı sınıf önbelleği bayat (`--import` gerekir)
