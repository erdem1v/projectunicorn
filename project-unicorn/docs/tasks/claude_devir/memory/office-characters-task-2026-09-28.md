---
name: office-characters-task-2026-09-28
description: "Ofis mankenleri → gerçek karakterler task'ı (2026-09-28): Erdem'in 8 kararı, Quaternius 2022 rig tuzakları, lisans kuralı, zaman modeli task'ıyla paralel çalışma sınırı"
metadata:
  node_type: memory
  type: project
  originSessionId: 9302b799-42ab-4012-bf64-ed89ec2c6218
  modified: 2026-09-28T22:49:57.114Z
---

**Plan:** `C:\Users\erdem\.claude\plans\pasted-content-id-59fa-g-rev-mankenleri-effervescent-snowglobe.md` (onaylı 2026-09-28).

**Erdem'in kararları:** (1) makro ritim (geliş/çıkış, öğle, all-hands, kurucu yatağı) oyun saatinde, mikro ritim (mola, yürüyüş, kuyruk, toplantı) ambiyans saatinde `k = min(tempo, 2)`; (2) gövde = Quaternius Ultimate Modular Men/Women 2022 (UBC'ye uyumlu modern kıyafet YOK — rapor edildi) + UAL1/UAL2 Standard; (3) klip boşlukları yalnız CC0 (KayKit, Mesh2Motion) + prosedürel; (4) huylar kapsam dışı, trait task'ına; (5) bust = çalışan+aday+kurucu, kapsam sınırı: "Kurucu portresi → karakter seçimi ve VC bust'ları toplantı sahnesi task'ında" (ACIK_KARARLAR'a tek satır); (6) kurucu gecesi zaman modelini izler (pencere bitiminde yatağa); (7) lisans: ticari kullanım + oyun içi dağıtım serbestse (QAL/CC-BY dahil) atıf dosyasıyla devam, yalnız ticari kullanım yasaksa dur; (8) Faz 0–2 zaman modeli task'ıyla paralel, Faz 3 zaman modeli commit'lendikten sonra.

**Why:** zaman merdiveni insan ölçeğinde harekete sığmıyor; haftalık zaman modeli (plan `pasted-content-id-c587-...-flickering-pizza.md`) paralel yürüyor ve `office_people.gd`, `main.gd`, `character*`, `hr_search_system`, `tabs/hr/*`, `game_state`, `save_manager`, `endgame_smoke`, `strings.csv`'yi onun ajanları yazıyor.

**How to apply:** Faz 0–2'de o dosyalara dokunma; yalnız yeni dosyalar + `office_ink.gdshader`, `ui_factory.gd`, `training_modal.gd`, `tools/office3d/*`, `art/office3d/*`. Görsel kapılar commit'lenmeyen `scenes/debug/people_lab.tscn` ile; kapılar checkout-index kopyasında ayrı APPDATA ile. Commit'lerde yalnız kendi yolların.

**Q22 rig gerçekleri (poly.pizza GLB'lerinden):** 62 eklem, Men/Women aynı liste ama parçalar cinsiyetler arası oturmaz; `Foot.L/R` ve `PT.*` Root'a bağlı (retarget öncesi LowerLeg altına taşınmalı); düğüm rest'i Idle, bind T-poz; armatür ×100 ve −90° X; UV'ler dejenere, metallic 0.4; her cinsiyette tek yüz, saç Head mesh'inin yüzeyi; yüzey adları güvenilmez. quaternius.com/license.html 2026-08-28'den beri QAL v1.0 (paket sayfaları hâlâ CC0) — zip'teki lisans metni arşivlenir.

**Faz 0–1 bulguları (2026-09-28, uncommitted, Erdem onayı bekliyor):**
- Quaternius Drive klasörleri "Quota exceeded" (License.txt dahil); poly.pizza kopyaları kullanıldı: erkekler CC0, kadın Suit/Soldier/SciFi/Worker CC-BY 3.0 → `assets/art/people/ATTRIBUTION.md`. UAL/KayKit itch.io'dan betikle iner: `POST <page>/download_url` (csrf) → download sayfası `data-upload_id` → `POST <page>/file/<id>?source=game_download` (key YOK) → CDN url.
- **Godot 4.6 import tuzağı:** `retarget/remove_tracks/except_bone_transform` başka bir remover'la birlikte açıksa bütün dönüş izlerini siler (645× "p_track out of bounds"). except=false, unimportant/unmapped=true. İçe aktarma klip adlarındaki `_Loop` ekini düşürür (`Walk_Loop` → `Walk`).
- Tasarımın spot `face`'i baktığı yön: Q22 gövdesinde `rotation.y = face` (+PI DEĞİL).
- GDScript Packed dizileri başvuruyla geçer: yürürken tüketilen yol `duplicate()` edilmeli.
- Tasarımda cam kapılar AÇIK duruyor, cam duvarlarda boşluk var → nav fırını cam dahil pişirir, kapı adlandırma deltası GEREKSİZ. Tribün/asma kat: zincirden türeyen bağlantılar (`bake_nav.gd` meta "links"), küçük spotsuz parçalar atılır. Navmesh zemini görsel zeminin ~0.1 m üstünde → `path_height_offset` + her adım y kıstırma.
- Maliyet (RX 9070 XT, vsync kapalı, LOD açık): plaza 40 kişi +2,9 ms, loft 70 kişi +4,2 ms.
- Lab düzeni: `scratchpad/lab/project-unicorn` (git archive HEAD + `.godot` kopyası) + `scratchpad/sync_lab.sh <yollar>`; paralel oturumun yarım işi (TimeModel) canlı ağaçta autoload'ları kırıyor.

**Faz 1 kapanış bulguları (2026-09-28 öğleden sonra):**
- Erdem resmî paketleri `assets/art/people/raw/Ultimate Modular {Men,Women}...`'e koydu (CC0, 487 MB; `.git/info/exclude`'da). Kullanılan 14 glTF `raw/q22/<id>.gltf`'e kopyalandı, `fix_rig.py` glTF okur; çıktı poly.pizza'dan üretilenle birebir (eklem farkı 0). ATTRIBUTION.md ve KayKit silindi. Paket klasörlerinin silinmesi Erdem'e sorulacak.
- Erdem'in yeni kuralı (karar 9): kurucu Ev'deyken işe alınan uzaktan çalışır, eve gelmez; Faz 3'te `office_people.gd`.
- KayKit `Lie_*` retarget'ta yere oturup havada yatıyor → yatak = UAL `Sitting_Enter` ile uca oturma + M2M `Sleeping`'e uzanma; kök y'si poz karışımıyla, xz kayma ease ile (yoksa kalça yatağa gömülür).
- UAL `Idle_Loop` sağ ayağı 0.4 m geride: durağanken adım gibi okunur → ayakta idle M2M `Idle_Subtle`.
- `look.hash()` negatif olabilir → LOD kare yuvası `posmod` şart, yoksa uzak zoomda poz hiç ilerlemez.
- `go_to` yarım oturma/yatma/dönüş/kuyruk yolunu kesmez; biter, sonra `_leave()` (tek çıkış yolu: kalk → girişin tersi → yürü).
- Lab: `scenes/debug/people_lab_checks.gd -- home star pause switch zooms` (commit'lenmez).

**Faz 2 (Erdem onayı 2026-09-28 akşam) + kararlılık turu:**
- Erdem: "14 dosya" itirazı → 487 MB aynı 21 karakterin 5 formatı; kostüm olmayan her parça alındı (m_farmer buzz kafa+tulum, m_adventurer gömlek/kargo/bot, punk yırtık kotlar, w_worker kargo, w_scifi/w_witch kafası şapka/kulaklıksız). Punk mohawk kafaları ve w_adventurer gövdesi (sırtta rulo) ALINMADI. fix_rig çıktıda parçaları `Part_<kind>` adlandırır (Farmer'ın bacağı "Pants").
- Gözlük kodla kuruluyor (gözlerin AABB'si etrafında kutular, Head kemiğine %100), LookSystem.unique/apart/sex_of, saç rengi ağırlıklı.
- Uç durum workflow'u (wf_1fd6e6e7-9e2): 55 doğrulanmış / 16 çürütülmüş bulgu; lab `scenes/debug/people_lab_edges.gd` 13 senaryo, monitör tik başı `p._prev_pos` ile ölçer (avoidance callback'i tik SONUNDA ve bir tik gecikmeli gelir — monitörü position'dan okumak sahte sıçrama sayar).
- Kararlar: duraklatmada poz TAMAMEN donar (nefes yok); ekran dışı kişi 6 karede bir poz alır (catch-up tablosu yerine); linkler statik `set_links()`; geç gelen avoidance hızı `limit_length(WALK_SPEED*k)`; zemine çekme yarım adım + next noktaya 1 m içinde çekme yok (link ağzı zemin dışında olabilir); FOLLOW bekleme segment başına kümülatif (düğüm her zaman çözülür).
- Canlı ağaçtaki *_nav.tres BAYATTI (Faz 1'de lab'dakiler kopyalanmamıştı) → yeniden pişirilip kopyalandı.

**Faz 2 onaylandı (2026-09-28 gece), Faz 3 başladı** — zaman modeli commit'lendi (`1b8f2f3`, `d57bdb2`).
- Erdem'in bilek bulgusu: bota sokulan kadın pantolonları (w_soldier/w_punk, etek 0,33–0,37 m) alçak ayakkabıyla boşluk bırakıyordu → `PeopleParts.HEM`/`SHOE_TOP` tablosu, LookSystem yalnız `SHOE_TOP >= HEM` ayakkabı seçer.
- Canlı ağaçta 4 yeni gövdenin (m_farmer, w_punk, w_scifi, w_witch) `.import` retarget dosyası yoktu (yalnız eski lab'da vardı) → yeni lab'da setup_import ile üretilip kopyalandı. Lab yeniden kurulum: `git archive HEAD` (alt klasörden çalıştırınca yalnız o klasör) + porcelain yollarının `project-unicorn/` öneki SİLİNEREK kopya + eski `.godot` taşınır + `--import`.

**Faz 3 kuruldu (2026-09-28 gece, uncommitted, Erdem görsel onayı bekliyor):** yeni office_people/actor/venue + crowd probe; smoke hedefli 20/20, lint/loc temiz. Bulgular:
- **UAL1 `Walk`/`Walk_Formal` adımını Root kemiğinde taşıyor** (döngüde 0→1,4 m): gövde kökün önüne kayıp geri sıçrıyordu; Faz 2'nin kök izleyicisi göremezdi. Çare `AnimationTree.root_motion_track = "%GeneralSkeleton:Root"` (okunmaz). Kalça–kök yatay farkını ölçmek şart.
- `NavigationServer3D.map_changed` bölge haritaya katılınca gelir ama zemini sonraki async derlemede girer: yerleştirmeyi "kapıdan masa 0'a yol boş değil" koşuluna bağla (bir fizik karesi beklemek yetmedi; yollar 2–4 m ölçülüyordu).
- Kapı/ortak giriş noktası yığılması: FOLLOW'da kaçınma yok. Çözümler: çıkışta kapı sırası (DOOR_S, fiziksel kuyruk koridoru tıkıyor), son metrelerin ağzında bekleme, "önde" ±60° koni + aynı hedefe girenlerden yakın olan önce, geçilen ara noktaya geri dönülmez; sınırsız bekleme kilitlenir (DOOR_WAIT 6 sn).
- Gece: yeni yürüyüş başlamaz, yüklem yalnız kapıya/yatağa yürüyeni bekler, kalan herkes CUT_FADE kararmasında kesilir.
- `APPDATA`'yı scratchpad'e çevirince Python user site (PIL) kaybolur: python'u o env olmadan koş. `smoke_run.sh` tek vaka alır (döngü). Uzun koşudan önce `--check-only --script` ayrıştırma kapısı (scratchpad/parsecheck.sh); bir parse hatası 13 dk'lık koşuyu boşa harcadı.
- Laboratuvarlar ağaçtan `scratchpad/labs_moved/`'a taşındı. Performans: loft 70 4× ~8,4 ms (hedef aşıldı, ACIK_KARARLAR 71).

**COMMIT'LENDİ 2026-09-29 (push yok):** `74a1bb8` varlıklar + tools/people (raw/q22 18 glTF 56 MB dahil; yalnız iki paket klasörü exclude'da), `1004b5c` çalışma zamanı, `daad3f6` belgeler. Plan 4 commit diyordu; 3'e indi çünkü görünüş/gövde/kişi dosyaları birbirini çağırıyor (ara commit derlenmezdi). Ayrı Opus inceleme 5 hata buldu (lane temizliği sırası, WAIT_LINK'ten çıkışta `_lane`, kayıp satır devamı, bayat `_build_meeting`, fix_rig raporu); hepsi + ölü kod/tekrarlar düzeltildi. `OfficePerson.way_in/floor_near/FLOOR_RISE/DOWN/MOVING/ANY_GAITS`, `CharacterRegistry.employees_by_hire`, `PeopleParts.bottom_is_top`, `HRConstants.FIRST_NAME_SEX`, salt'lar SalesConstants'ta (`mix_seed(mix(..), k)`). bake_nav `-s` altında OfficePerson sabitlerini okuyabiliyor; `nm.duplicate()` artık `filter_baking_aabb`'yi de yazıyor (çalışma zamanında etkisiz).

İlgili: [[office-3d-task-2026-09-27]] · [[partial-staging-shared-tree]] · [[concurrent-session-hazard]] · [[design-work-lessons]]


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Office characters task 2026-09-28](office-characters-task-2026-09-28.md) — mankenler → Quaternius 2022 karakterler: 8 karar (makro oyun saati / mikro ambiyans, CC0 boşluklar, bust kapsamı, lisans kuralı), Q22 rig tuzakları, zaman modeli task'ıyla paralel dosya sınırı; **COMMIT'LENDİ 2026-09-29 `74a1bb8`/`1004b5c`/`daad3f6` (push yok)**; UAL yürüyüşü Root'ta adım taşıyor, map_changed zeminden önce gelir, kapı sırası
