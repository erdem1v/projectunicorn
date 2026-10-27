# PRD · Render Sağlığı + Ücretsiz Asset Laboratuvarı

**Kim çalıştırır:** bir geliştirici ajanı oturumu. Başlatma cümlesi: "project-unicorn/docs/tasks/PRD_RENDER_ASSETLAB.md
dosyasını oku ve uygula."
**Durum:** yardımcı yönetmen onaylı, 2026-10-09. Sahibin (Erdem) taslağı araştırmayla düzeltildi (§0).
**Tek cümle:** Bölüm 1, ofis 3B görüntüsündeki kamera kaydırınca değişen gölge bantlarının ve gece parlamasının gerçek
nedenini görüntüyle kanıtlar ve onarır. Bölüm 2, ücretsiz ticari lisanslı paketlerle ev ve İş hanı sahnelerinin aynı
kamera ve ışıkla yeniden kurulup kurulamayacağını oyun koduna dokunmadan sandbox'ta dener.
**Çıktı:** Erdem'in F5 vereceği ekran görüntüleri ve bir hüküm raporu. Ajan kördür; her iddia görüntü ya da sayıyla
kanıtlanır.

Araştırma kanıtı: `C:\Users\erdem\Desktop\unicorn_render_research\ARASTIRMA_2026-10-09.md` (beş araştırmacı, dosya:satır ve
Godot 4.6.2 kaynak kodu alıntılarıyla). Çalışan araçlar aynı klasörde (`props_harness/`, `probes/`, `README.md`).

---

## 0. Taslaktan farklar (neden bu PRD taslağın birebir kopyası değil)

| Taslak maddesi | Bugünkü gerçek (kanıt) | Bu PRD'de |
|---|---|---|
| "Gölge haritası PSSM kademelerine bölünüyor, gölge modunu Orthogonal yap" | Güneş zaten `directional_shadow_mode = 0` (ORTHOGONAL, tek bölüm), `scenes/office/OfficeView.tscn:82`; motor `splits = 1` | Yapılmaz. Gerçek neden teşhisle bulunur (§1.2) |
| "directional_shadow_max_distance'ı sahne sınırına çek" | Ortografik kamerada Godot bunu yok sayar (`renderer_scene_cull.cpp:2145`: `shadow_max > 0 && !p_cam_orthogonal`) | Yapılmaz |
| "Kameranın near/far aralığını daralt" | Her karede yeniden hesaplanıyor (`office_camera.gd:167-175`); yatay kaydırmada değişmiyor. Ama `_lowest` GLB'deki EN ALÇAK mesh'ten alınıyor (`office_view.gd:79-81`): plaza −60,35 ve meet −54,80, oysa yerleşim tabanı −7,0 ve −0,4. Gölge küresi orada iki kat büyük | `_lowest` yerleşim sınırından alınır (§1.4) |
| "Omni/Spot ışıklarda gereksiz gölgeyi kapat" | Hiçbiri gölge açmıyor (`OfficeView.tscn:85-112`); tek gölgeli ışık güneş | Yapılmaz |
| "SSAO/SSIL/SSR açıksa bak" | Hepsi kapalı (varsayılan, hiçbir yer açmıyor) | Bilgi için tek açık/kapalı kare çifti |
| "Atlas boyutunu ve yumuşak gölge kalitesini bir basamak artır" | Proje ayarı yazılı değil; varsayılan 4096 ve Soft Low (2). Bir basamak = 8192 ve Soft Medium (3). İkisi de çalışırken RenderingServer'dan değiştirilebilir | Teşhiste A/B olarak ölçülür, kanıta göre karar verilir |
| "Malzemelerde roughness 1.0, metallic 0.0" | **Zararlı.** Malzemelerin yaklaşık %95'i `office_toon` gölgelendiricisinde; o roughness ve metallic'i okumaz ve ROUGHNESS kanalını kontur geçişine bayrak olarak yazar (0 = kontur yok, 0,5 = yalnız dış hat, 1 = tam). Değiştirmek zemine kontur çizer, kişilerde kırışık çizgileri açar. Gölgelendiricide zaten speküler yok | Yapılmaz |
| "Emission yalnız ışık kaynaklarında" | Gün ve geceye bağlı tüm emission adlı lamba, ekran, direk, araba, cephe malzemelerinde. Ama birkaç isimsiz statik prop gün boyu sabit yanıyor (home mat68, ishani mat5/44/58, plaza ve loft'ta benzerleri) | Bu proplar bulunur, kararı tek tek verilir (§1.5) |
| "Gece ambient soğuk ve düşük" | İçeride kimse yokken zaten düşük ve mavi. Biri varken sıcak, gölgesiz TopFill gecenin en güçlü ışığı (0,318; ay 0,143) ve tepeden her yüzeyi aydınlatıyor | TopFill'in gece payı ele alınır (§1.5) |
| "Kamera hızla kaydırılınca" | Görüntünün geçmişi yok (TAA yok, gölgelendiricilerde TIME yok); aynı kamera konumu aynı görüntüyü verir | Hareket değil, sabit kaydırma ofsetleri ve 1 px'lik tarama |
| "Mevcut sahneleri sandbox'a kopyala, prop'ları paketlerle değiştir" | GLB'ler malzemeye göre birleştirilmiş, prop başına düğüm yok (home 324 düğüm, 141 mesh). Konum ancak tasarımın kurucu kodundan çıkar; bu araç araştırmada kuruldu ve doğrulandı | Konumlar araçla çıkarılır (§2.2) |

Taslakta olmayan ama araştırmanın bulduğu üç kusur da bu PRD'ye girdi: akşam 19:25'te güneş yönünün 74 derece sıçraması,
gece de gölge atan bir "ay", plaza ve meet'te şişkin gölge kutusu.

## 1. Bu oturumun kuralları

- Repo: `C:\Users\erdem\Desktop\project steam\project-unicorn` (git kökü bir üstte). `CLAUDE.md` bağlayıcıdır;
  özellikle §3 (commit, tasarım sabiti), §7 (UI/STYLE LAW), §8-§9 (kod ve inceleme), §11 (görsel kabul), §12 (kapılar).
- **Ağaç paylaşımlı.** Başka oturumlar aynı ağaçta çalışıyor. 2026-10-09'da `main.gd`, `office_people.gd`,
  `meeting_cast.gd`, `office_constants.gd`, `time_model.gd`, `save_manager.gd`, `endgame_smoke.gd`, `CLAUDE.md`,
  `docs/HARITA.md` başka bir oturumun commit'lenmemiş değişikliğini taşıyordu. İşe başlarken `git status --short` al.
  Başkasının değişikliğine dokunma, onu commit'leme. Senin değişikliğin kirli bir dosyadaysa yalnız kendi hunk'larını
  stage et (`git diff` hunk'ını `git apply --cached` ile), commit ağacını doğrula. `git checkout -- <yol>`,
  `reset --hard`, `stash`, `clean` yasak.
- **Alt ajanlar Sonnet'te koşar** (`model: "sonnet"`); sahibin haftalık limiti için kesin kural.
- **İşletim sistemi düzeyinde fare ve klavye girdisi yok** (sahip makineyi kullanıyor olabilir). Ekranlı Godot
  koşuları sırayla, her biri kendi `APPDATA` dizininde; ekran gerektirmeyen her koşu `--headless`. Yalnız kendi
  başlattığın Godot süreçlerini kapat.
- Godot: `export GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe`; komutlar `project-unicorn/`'dan.
- **Portre bağı.** `OfficeLighting`'in `LIGHT_SCALE`, `TOP_FILL*`, `AMBIENT*`, `ACES_*`, `GRADE_*` sabitleri ve öğle
  satırı `PersonBust`'ın (kart portreleri) ve `tools/people/portrait_baker.gd`'nin de girdisidir. Bunlardan birine
  dokunursan portre karesini önce ve sonra çek ve aynı kaldığını göster; değiştiyse dur ve raporla.
- Push yok. Commit'ler doğrudan `main`'e; her commit'ten önce diff ayrı bir ajanca incelenir (CLAUDE §9).

---

## Bölüm 1 · Işık ve gölge

### 1.1 Teşhis aracı (önce bu, ayrı commit)

Bugün hiçbir araç kamerayı belli bir ofsete kaydırıp yalnız 3B görüntüyü kaydetmiyor; `--office-shot` bütün pencereyi
(üst bar ve kayan haber şeridi dahil) kaydediyor. CLAUDE §3: araç değişikliği serbesttir, ayrı raporlanır.

- **Yeni dosya** `scripts/debug/office_pan_probe.gd` (`extends RefCounted`, `class_name` YOK, böylece `--import`
  sırası sorunu çıkmaz). `main.gd`'de `const OFFICE_PAN := preload(...)` ve `_run_office_shot` içinde, `match extra`
  bloğundan sonra, 1,2 sn bekleyişinden önce birkaç satırlık kanca. `main.gd` başka oturumca kirliyse yalnız bu hunk
  stage edilir.
- **Bayrak:** `--pan=dx,dy[,zoomCarpani];dx,dy[,zoomCarpani];...` 3B görüntünün pikseli cinsinden (pozitif dx kamera
  sağa). Kısayol: `sweep:<baş>:<son>:<adım>[:y]`. Her adımda
  `cam.focus(base + cam.global_basis.x*(dx*upx) + cam.global_basis.y*(dy*upx), zoom0*zm, 0.0)`,
  `upx = cam.units_per_px(zoom0*zm)`; üç kare ve `RenderingServer.frame_post_draw` bekle; `Viewport3D/SubViewport`'un
  görüntüsünü `<kök>_<i>_<dx>_<dy>_3d.png` olarak kaydet. Fare penceredeyse halka ve ipucu çizilir; çekim öncesi
  `view._on_pointer_left()` ya da eşdeğeri.
- **Yalıtım düğmeleri** `--pan-set=k=v,...` (proje dosyasına dokunmadan, düğüm ve RenderingServer üstünden):
  `shadow=0` (Sun.shadow_enabled), `ink=0` (InkPass.visible), `fxaa=0`, `msaa=0`, `people=0`, `atlas=8192`
  (`RenderingServer.directional_shadow_atlas_set_size`), `soft=0..5`
  (`RenderingServer.directional_soft_shadow_filter_set_quality`), `bias=`, `nbias=`, `blur=`, `pancake=`, `glow=0`,
  `ssao=1`. `glow_intensity`'ye dokunma: `apply()` onu her karede yeniden yazar.
- **Kayıt satırı:** `PAN|i|dx|dy|zoom|size|near|far|depth|radius|texel_world|texel_px|Wx|Wy|resid_mean|resid_max|resid_n8`.
  `radius`, `Wx`, `Wy`: Godot'nun gölge kutusu hesabını GDScript'te yeniden üret (`renderer_scene_cull.cpp`
  4.6.2 satır 2271-2307: sekiz kesit uç noktası, merkez, yarıçap × N/(N−2), `unit = radius*4/N`, kenarlar ayrı ayrı
  `snappedf`). Formüller araştırma dosyasının "tools_probe" bölümünde.
- **Fark ölçüsü (motor içinde; makinede PIL ve numpy yok):** i. görüntüyü ilk görüntünün (dx, dy) kaydırılmışıyla
  karşılaştır, 6 px kenar payı bırak; ortalama mutlak fark, en büyük fark, 8/255'i aşan piksel sayısı. Önce aynı
  ofseti iki kez çek: fark sıfır olmalı (MSAA ve FXAA tamsayı kaydırmaya değişmez). Testte gölgelendiricinin
  vinyetini kapat (`vignette = 0`, ekrana sabittir); ana test yatay kaydırma (gökyüzü gradyanı `SCREEN_UV.y` okur).
- **GPU süresi:** `RenderingServer.viewport_set_measure_render_time(sub.get_viewport_rid(), true)`, 60 kare at,
  en az 300 kare `viewport_get_measured_render_time_gpu` ve `_cpu`; medyan ve p95. Atlas 4096/8192 ve yumuşak kalite
  2/3'ü aynı süreçte ABAB sırasıyla dene. `--office-shot`'ın `frame_ms`'i bütün pencereyi ölçtüğü için yalnız kaba
  göstergedir.
- **Kabul:** aynı ofsetin iki çekimi sıfır fark verir; `--pan=drag:...` (sentetik fare olaylarıyla
  `cam.handle_input`) ile tek `focus()` aynı görüntüyü verir; komut ve çıktı örneği rapora.

### 1.2 "Önce" kanıtı ve kök neden

Hiçbir ayar değişmeden. Ofisler `home` ve `ishani`; plaza ve loft yalnız kök neden doğrulandıktan sonra bir kez.

| Çekim | Saat | Kaydırma |
|---|---|---|
| Gündüz | 13 (öğle satırı, güneş 57,9°) | `-400,0;0,0;400,0` (sol, orta, sağ) |
| Gece | 22, `:full` (iç mekân aydınlık, masa lambaları açık) | aynı |
| İnce tarama | 13 ve 17 | `sweep:0:16:1` varsayılan çerçevede ve zoom ×3'te |
| Yalıtım | 13, 17 | ince taramayı şunlarla tekrarla: `shadow=0`, `ink=0`, `soft=0` (Hard), `soft=3`, `atlas=8192` |

Sahibin gördüğü bant pencere üstündeki bir **gölge** de olabilir, bir **kontur çizgisi** de. Yalıtım bunu tek
çekimde ayırır. Kök neden adayları, araştırmanın sırasıyla:
1. **Yumuşak gölge filtresinin ekrana yapışık deseni.** Soft Low 4 örnek alır ve her pikselin örnek desenini
   `gl_FragCoord`'dan üretilen gürültüyle döndürür; desen dünyaya değil ekrana bağlıdır. Belirti `soft=0` ya da
   `soft=3` ile kaybolur ya da azalırsa neden budur.
2. **Gölge kutusu kenarlarının ayrı ayrı yuvarlanması.** Kutu genişliği bir birim (iki texel) oynayabilir; texel
   adımı kaydırmayla değişir. Belirti, fark sıçramaları `Wx/Wy` değişimleriyle aynı adımlara düşüyorsa budur;
   `atlas=8192` genliği yarıya indirir.
3. **Büyük gölge sapması (bias).** Bugünkü sapma ev için 6 ile 9 cm, plaza için 16 cm: santimetrelik pencere üstü
   bantları yiyebilir. Belirti, bantlar zoom değişince boy değiştiriyorsa ve `bias`/`nbias` düşünce düzeliyorsa budur.
4. **Kontur geçişi.** Belirti `ink=0` ile kayboluyorsa neden konturdur, gölge değil.

**Teslim:** `docs/audits/render/` altında `once_gunduz_{sol,orta,sag}.png`, `once_gece_{sol,orta,sag}.png` (3B
görüntü), yalıtım taramasının kayıt satırları (`TESHIS.md`) ve kök neden hükmü (hangi aday, hangi kare kanıtlıyor).

### 1.3 Onarım (kanıta göre)

Yalnız kanıtlanan neden onarılır; taslağın kör listesi uygulanmaz.
- **Filtre nedeniyse:** `rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality` 2 → 3 (Soft
  Medium, iki kat örnek, aynı yarıçap) ya da toon dili için 0 (Hard, desen yok). Kalite yarıçapı sapmayı da ölçekler;
  `shadow_blur` (bugün 0,35) ve sapmayı yeniden ayarla.
- **Kutu yuvarlaması nedeniyse:** önce §1.4'teki kutu sıkılaştırması, sonra gerekirse
  `rendering/lights_and_shadows/directional_shadow/size` 4096 → 8192 (16 bit atlas belleği 32 → 128 MiB). Kamerayı
  texel katlarına oturtma gibi özel bir çözüm ancak bunlar yetmezse ve sahip onaylarsa.
- **Sapma nedeniyse:** önce `shadow_normal_bias`, sonra `shadow_bias`; `directional_shadow_pancake_size` 20 → 5
  civarı. Sapma kutu boyutu, pancake, blur ve filtre kalitesiyle ölçeklenir; bunlardan biri değişince yeniden ayarla.
  İki uç kareyi kaydet: sivilce (acne) eşiği ve "uçuk gölge" (peter-panning) eşiği; seçilen değer ikisinin arasında.
- **Kontur nedeniyse:** gölge ayarına dokunma; `office_ink` eşiklerini sahibe öneri olarak raporla, uygulamadan önce
  onay al.
- Ayarlar proje ayarıysa `project.godot`'a, ışık özelliğiyse `OfficeView.tscn`'deki Sun düğümüne yazılır. Editör
  `.tres` ve `project.godot`'u yeniden kaydederken fark üretir (CLAUDE §12); yalnız amaçlanan satırları commit'le.

**Teslim:** `sonra_gunduz_{sol,orta,sag}.png`, `sonra_gece_{sol,orta,sag}.png` aynı ofsetlerden; ince taramanın
sonrası (fark ölçüsü düşmüş olmalı); `bias_acne.png`, `bias_peterpan.png`.

### 1.4 Gölge kutusu sıkılaştırma

`office_view.gd:79-81` `_lowest`'ı GLB'deki tüm mesh'lerin en alçağından alıyor; plaza ve meet'te yerleşim
tabanının 50 m altındaki gölge atmayan kule parçaları kutuyu şişiriyor (plaza gölge küresi yarıçapı 85,7, sıkı kutuyla
yaklaşık 39). Onarım: `_lowest` yerleşim sınırından (`layout.bounds`) ve küçük bir paydan gelir. Ev, İş hanı ve loft'ta
fark küçük; plaza ve meet'te texel yarıya iner. Kabul: plaza ve meet'te kesilen görünür bir şey yok (önce ve sonra
tam çerçeve kareleri), kayıt satırında `radius` düşmüş.

### 1.5 Gece ve gün döngüsü

Ölçülmüş bugünkü durum (`office_lighting.gd`):
- `glow_intensity = 0.2 + 0.3*(1 − sqrt(f))`: öğlen 0,2, gece en yüksek 0,5 (:183). Eşik 0,95, `glow_hdr_scale`
  varsayılan 2,0, karışım Additive.
- Gece biri içerideyken TopFill (sıcak, gölgesiz, neredeyse tepeden) 0,318 ile gecenin en güçlü ışığı; tasarımdaki
  TopFill gölge atıyordu (`office-sim-v12.js:1094`), Godot'a gölgesiz taşınmış.
- Toon gölgelendiricisinin basamağı en az 0,373: her ışık arka yüzleri bile yüzde 37 aydınlatır. Bu tasarım dilidir;
  değiştirme, yalnız raporla.
- Güneş gece kapanmıyor: 19:26'dan sonra 55° yükseklikte gölge atan bir "ay" (enerji 0,11 ile 0,14). 19:25'te yön
  74 derece sıçrıyor (yükseklik 15° → 55°).
- İsimsiz statik emission'lı proplar gün boyu aynı parlaklıkta.

Yapılacaklar (her biri önce ve sonra kareyle):
1. **Parlama:** gece glow'u ışık kaynaklarına sınırla. Önce `glow_hdr_scale`'i düşür ve gece `glow_intensity` tavanını
   indir; gerekirse eşiği yükselt. Monitörler, masa lambaları, sokak direkleri yine ışıklı görünmeli; duvarlar ve
   eşyalar parlamamalı. Additive → Screen karışımı bir seçenek; denersen iki kareyle karşılaştır.
2. **TopFill gece payı:** `night_in` teriminin TopFill'e katkısını (:192) azalt ya da TopFill'e tasarımdaki gibi gölge
   ver; ikisini de kareyle dene, birini öner. TopFill sabitleri portreyle paylaşılır (§1 portre bağı).
3. **İsimsiz parlayan proplar:** headless sahne dökümüyle hangi nesneler olduklarını bul (GLB'de ad yok, düğüm indeksi
   var). Işık kaynağıysa (tavan paneli, ekran) gece-gündüze bağla; değilse emission'ını sıfırla. GLB tasarımdan
   üretildiği için değişiklik Godot tarafında yapılır (`OfficeMaterials` ya da `OfficeLighting`), GLB'ye dokunulmaz.
4. **Gün döngüsü:** 19:25 sıçramasını kaldır (yükseklik ve azimutu 1150-1200 dakika arasında yumuşat). Ayın gölge
   atıp atmayacağına karar ver ve gerekçele. Dört kare: `gun_dongusu_ogle.png` (13), `_aksam.png` (19),
   `_gece.png` (22, `:full`), `_sabah.png` (8).
5. **SSAO:** bilgi için `ssao_acik.png` / `ssao_kapali.png` (yalıtım düğmesiyle). Varsayılan kapalı kalır; açmak
   önerilirse gerekçe ve GPU süresiyle.

Bu maddelerdeki değerler sanat yönü kararlarıdır. Ajan önerir ve uygular, sahip F5 ile onaylar; rapor her değeri
"önce → sonra" yazar.

### 1.6 Bölüm 1 teslimi
- Commit'ler: (a) teşhis aracı, (b) kanıtlanan gölge onarımı, (c) kutu sıkılaştırma, (d) gece ve gün döngüsü. Her
  biri ayrı; mesajda değişen ayarlar.
- `docs/audits/render/`: §1.2-§1.5'in kareleri, `AYARLAR.md` (her ayarın adı, yeri, önce → sonra, neden),
  `TESHIS.md` (kayıt satırları ve hüküm), `PERFORMANS.md` (GPU süresi medyan ve p95, önce ve sonra, atlas belleği).
- Portre karesi önce ve sonra, ortak sabitlere dokunulduysa.

---

## Bölüm 2 · Ücretsiz asset laboratuvarı

### 2.1 Kurallar
- **Oyun kodu ve sahneleri değişmez.** Her şey `res://sandbox/asset_lab/` altında. Bu klasörün kökünde `.gdignore`
  olur: Godot içe aktarmaz, `.import`/`.uid` dosyası çıkmaz, smoke ve metin kapılarına girmez; sahne ve betik komut
  satırından koşar ve projenin `class_name`'lerini kullanabilir; GLB'ler çalışırken `GLTFDocument.append_from_file`
  ile yüklenir (araştırmada doğrulandı). Bedeli: editörde gezilemez.
- **Paket dosyaları git'e girmez.** `.gitignore`'a: `/sandbox/asset_lab/packs/`, `/sandbox/asset_lab/out/`,
  `/sandbox/asset_lab/tools/**/node_modules/`. Git'e girenler: betikler, sahneler, `MANIFEST.md` (paket, kaynak
  URL, lisans, sürüm, indirme tarihi, zip sha256'sı, kullanılan dosyalar), `licences/<paket>.txt` (lisans metni),
  `CREDITS.md`.
- **Lisans kuralı:** CC0 öncelikli; atıf isteyen CC-BY kabul; "kişisel kullanım", "ticari olmayan", "royalty-free ama
  ücretli" ret. Lisans doğrulanmadan hiçbir dosya kullanılmaz. Her paketin lisans metni bağlantısı ve kısa özeti
  rapora girer.
- **Quaternius uyarısı:** quaternius.com 2026-08-28'de gelecekteki sürümler için CC0 olmayan bir lisans (QAL v1.0)
  yayımladı: ticari kullanım serbest, atıf gerekmez, ama varlıkların kendisini dağıtmak yasak. Paket sayfaları bugün
  hâlâ CC0 diyor. Quaternius paketi kullanılırsa sayfanın tarihli kopyası ve zip arşivlenir; repo herkese açıksa
  ham paket repoya konmaz (zaten konmuyor). Oyundaki Quaternius 2022 karakterleri değişiklikten önce alındığı için
  etkilenmez (QAL §7 geriye işlemez).

### 2.2 Envanter ve yerleşim
- Kapsam: **ev** (`home`) ve **İş hanı** (`ishani`, oyundaki "Başlangıç" ofisi) iç mekânları, bina kabuğu ve
  çerçeveye giren sokak bağlamı (komşu cepheler, ağaç, direk, araba). Şehir haritası (`city`: 34 bina, 60 ağaç) kapsam
  dışı; cephe sorusu ev ve İş hanının kendi bloklarıyla cevaplanır.
- Konumlar GLB'den alınamaz (malzemeye göre birleşik). **Araç hazır:**
  `C:\Users\erdem\Desktop\unicorn_render_research\props_harness\`. Tasarımın Three.js kurucularını
  (`tools/office3d/src`) bellekte kancalayıp her adlı prop'un türünü, dünya konumunu, yönünü ve AABB'sini çıkarır;
  0,97 sn, belirlenimci; masa ve sandalye konumları yerleşim JSON'uyla birebir tuttu. Bunu
  `sandbox/asset_lab/tools/props_extract/`'e taşı (`three@0.160.0` gitignore'lu `node_modules`'a). Kaynak dosyalar
  `tools/office3d/src`'den okunur, kopyalanmaz ve değişmez (`DESIGN_SOURCE.md`: kaynak bayt bayt aynı kalır).
- Adı olmayan satır içi mobilya ve mimari (yatak, komodinler, dolap, sehpa, merdiven, korkuluk, duvarlar, zeminler,
  toplantı masası) kurucu koddaki sayılardan elle yazılır; araştırma dosyasındaki tablolar ölçüleri verir.
- **İş hanı aynalıdır:** iç mekân `x = 20 − x` aynalı bir grupta kurulur (`office-sim-v12.js:695`). Kurucu
  argümanını okuyan her şey bu dönüşümü uygular; yerleşim JSON'undaki konumlar zaten dünya konumudur.
- Birim: 1 birim = 1 metre (masa üstü 0,735; kat 3,2/3,3; karakter boyu 1,8 m, `office_person.gd:143`).
- **Teslim:** `docs/audits/asset_lab/ENVANTER.md`: kalem, adet, ölçü (m), renk (palet adı), kaynak (prosedürel,
  kurucu fonksiyonu ya da satır içi), konum kaynağı (araç ya da elle). Hepsi prosedürel; tek dış dosya küçük
  resimlerdeki Xbot (Mixamo kaynaklı, ticari onayı kayıtlı değil, `ACIK_KARARLAR` ~72); bu not rapora girer.

### 2.3 Paket taraması
Araştırmanın kısa listesi (lisanslar 2026-10-09'da indirilen zip'lerden okundu):
1. **Kenney ailesi (önerilen ana aile).** Furniture Kit (140 model, düz renk, doku yok), Building Kit (duvar, kapı,
   pencere, merdiven), City Kit Commercial/Suburban/Roads, Modular Buildings, Car Kit, Nature Kit. Hepsi CC0, zip'te
   GLB. Ölçek belgelenmemiş: Furniture ~1 birim = 2 m, Building ~1 birim = 1 m (ölçülmeli).
2. **KayKit** (Furniture Bits, City Builder Bits, Restaurant Bits, Prototype Bits). CC0, glTF, izometrik için
   tasarlanmış, tek gradyan atlas. Ücretsiz Furniture Bits'te masa, monitör, klavye yok (ücretli katmanda).
3. **Quaternius eski düz renkli paketler** (Ultimate House Interior, Ultimate Buildings, Modular Streets). Karakterlerle
   aynı elden; yalnız FBX/OBJ/Blend; QAL uyarısı (§2.1).
- **Ofis boşluğu:** hiçbir CC0 paket beyaz tahta, cam bölme, toplantı masası seti, dosya dolabı vermiyor. Doldurma
  sırası: MrEliptik Office Low Poly Pack (CC0, 24 parça), VNBP-Leo Low Poly 3D Office Set (CC BY 4.0, atıf gerekir,
  FBX/OBJ), CreativeTrio (Poly Pizza, CC0, stil doğrulanmadı). Cam bölme ve beyaz tahta en ucuz yoldan kutu + malzeme
  ile kurulur.
- **Ret:** Poly Haven (fotogerçekçi), Quaternius Downtown City MegaKit (gerçekçi PBR), Kenney Retro Urban (dokulu),
  lisanssız ya da Unity Asset Store sözleşmeli paketler.
- Önce **10 dakikalık stil testi:** üç ailenin her birinden 5 parça, oyunun toon gölgelendiricisi ve kontur geçişiyle,
  bir Quaternius 2022 karakterin yanında; aile seçimi bu karelerle yapılır. Kenney'nin gradyan `colormap.png`'sinin toon
  basamağında bantlanıp bantlanmadığını bu test gösterir.
- **Teslim:** `docs/audits/asset_lab/KARSILAMA.md` (paket × envanter karşılama tablosu, boşluklar listesi),
  `LISANS.md` (paket, lisans adı, lisans metni bağlantısı, tek satır özet, indirme tarihi, sha256), stil testi kareleri.

### 2.4 Laboratuvar düzeneği (araştırmada headless doğrulandı)
`res://sandbox/asset_lab/AssetLab.tscn` ve betiği; koşturma:
`"$GODOT" --path . res://sandbox/asset_lab/AssetLab.tscn --lab-shot=<varyant>:<ofis>:<saat>:<kamera>` (bayrak adı
`--lab-shot`, çünkü `SaveManager._is_harness_arg` `-shot` içeren bayrakları araç sayar ve otomatik kaydı kapatır).
1. `res://scenes/office/OfficeView.tscn`'i ağaca eklemeden örnekle, `Viewport3D/SubViewport/World`'ü ayır,
   `People` ve `City` çocuklarını at, `World`'ü laboratuvarın kendi `SubViewport`'una koy (own_world_3d, açık boyut
   1920×1080, msaa ve fxaa aynı). Böylece oyunun güneşi, TopFill'i, ortamı, kontur geçişi ve kamerası birebir gelir;
   Bölüm 1'in `OfficeView.tscn` değişiklikleri laboratuvara kendiliğinden akar.
2. `OfficeLighting.new(world)`; sentetik bir `OfficeLayout.new()` (id, kabuğun AABB'si sınır olarak, boş
   malzeme/pane/glow listeleri). `OfficeLayout.load` ve `OfficeView.load_layout` `art/office3d/<id>`'ye sabit;
   laboratuvar onları kullanmaz.
3. Paket GLB'lerini `GLTFDocument.append_from_file` ile `World` altına yükle, araçtan gelen konum ve yönle yerleştir;
   ölçeği karakter boyuyla doğrula (paket başına ölçek katsayısı tablosu `MANIFEST.md`'ye).
4. **Varyant A:** paketin kendi malzemeleri, kontur geçişi kapalı. **Varyant B:**
   `OfficeMaterials.convert_scene(scene, layout)` (oyunun toon + kontur hattı). Tuzaklar: `_convert` toon malzemenin
   `use_vertex_color`'ını hiç açmaz (vertex rengi kullanan paket beyaz çıkar; laboratuvar ön geçişte açar);
   malzemesi boş yüzey `_convert`'ü çökertir (varsayılan ver).
5. `lighting.set_layout(...)`, `cam.fit(bounds, lowest)` (açık bir kabuk AABB'si ve `lowest` ver; tüm mesh'lerin
   birleşimi kamerayı 207 birime açıyor), kamera noktaları sabit tablodan; her karede `lighting.apply(saat*60)`.
   A ve B aynı `Environment`'ı paylaştığı için sırayla çekilir.
6. **Kalibrasyon:** oyunun kendi `ishani.glb`'sini aynı laboratuvar yolundan çek ve Bölüm 1 aracının
   `--office-shot=ishani:13 --pan=0,0` 3B görüntüsüyle karşılaştır; fark ölçüsü sıfıra yakın olmalı. Bu, "mevcut"
   karelerin laboratuvarda adil çekildiğinin kanıtıdır.
7. **Karakterler:** masada oturan, yürüyen, yatakta yatan. `OfficePerson`/`OfficeBody`'nin poz API'sini kullan;
   kullanılamıyorsa Quaternius karakterini `AnimationPlayer` ile belli bir karede dondur. Hangi yolu seçtiğini raporla.
8. **Cephe:** ev ve İş hanının bina kabuğu ve pencere düzeni modüler paket parçalarıyla kurulabiliyor mu; pencere
   aralığı korunuyor mu. Kenney Building Kit ve Modular Buildings alçak katlı; orta yükseklikte düz renkli cephe paketi
   yok. Boşluk raporlanır.

### 2.5 Karşılaştırma seti
- Kameralar: ev 2, İş hanı 3, cephe 1 (sabit tablo; konum, zoom, açı `out/cameras.json`'da ve rapora).
- Her kamerada: mevcut · varyant A · varyant B; gündüz (13) ve gece (22, iç mekân aydınlık).
- Yan yana birleştirme motor içinde (`Image.blit_rect`; makinede PIL yok): sol mevcut, orta A, sağ B; üstüne küçük
  etiket. Ayrıca her kare tam boy.
- Dosya adı: `docs/audits/asset_lab/<sahne>_<kamera>_<gunduz|gece>_{mevcut,A,B,yanyana}.png`.

### 2.6 Hüküm raporu (`docs/audits/asset_lab/HUKUM.md`)
1. Ücretsiz paketlerle görsel dili bozmadan yeniden kurmak mümkün mü: evet / kısmen / hayır, nedenleriyle.
2. Mümkünse hangi paket ailesiyle, hangi varyantla (A ya da B), karelere atıfla.
3. Boşluklar ve kapanma yolu: başka CC0 paket, basit kendi modelimiz ya da mevcut geometrinin kalması.
4. Tam geçişin iş tahmini, sahne başına saat ve toplam; dışa aktarım hattının (`tools/office3d`) yerini paket
   tabanlı bir hattın alması gerekiyorsa onun maliyeti ayrı satır.
5. Lisans tablosu ve gerekiyorsa atıf metni taslağı (EN önce, TR).
6. Oyun koduna dokunulmadığının kanıtı: Bölüm 2 başında ve sonunda `git status --short` ve `git diff --stat`;
   Bölüm 2'ye ait değişiklik yalnız `sandbox/asset_lab/`, `.gitignore` ve `docs/audits/asset_lab/` altında.

---

## 3. Sahibe bırakılan kararlar (ajan önerir, uygulamaz)
- Kontur geçişi eşiklerinde değişiklik (kök neden kontur çıkarsa).
- Kamerayı gölge texel katlarına oturtan özel çözüm (yalnız standart ayarlar yetmezse).
- Ayın gece gölge atması ve TopFill'e gölge verilmesi (ajan iki seçeneği kareyle gösterir, birini önerir; uygular,
  sahip F5'te geri çevirebilir).
- Paket ailesi ve varyant seçimi (Bölüm 2 hükmü).
- CC BY paket kullanılırsa atıf metni.

## 4. Erdem'in bakacakları
- Sol, orta, sağ kaydırma karelerinde pencere üstü bantların artık aynı kalması.
- Gece karesinde duvarların ve eşyaların parlamaması; monitörlerin, lambaların, sokak direklerinin yine ışıklı olması.
- Gün döngüsünün dört karesinde 19:25 sıçramasının gitmesi, akşamın makul görünmesi.
- Varyant A ve B'nin karakterlerle aynı dünyadan görünüp görünmediği.
- Cephenin ve pencere düzeninin bugünkü siluetle aynı okunması.
- Karşılaştırma karelerinde kamera noktalarının gerçekten aynı olması (kalibrasyon karesi bunu kanıtlar).

## 5. Doğrulama listesi
1. Teşhis aracı: aynı ofset iki kez sıfır fark; sürükleme ile tek `focus()` aynı görüntü.
2. Kök neden hükmü yalıtım karelerine ve kayıt satırlarına dayanıyor; seçilmeyen adayların neden elendiği yazılı.
3. Bölüm 1 görüntü seti eksiksiz; önce ve sonra aynı kamera ofsetinden; ince taramada fark ölçüsü düşmüş.
4. Gece karelerinde duvar ve eşya parlaması yok; emission yalnız ışık kaynaklarında; ışık kaynakları görünür.
5. GPU süresi önce ve sonra ölçülmüş; düşüş varsa kabul edilebilirliği gerekçeli.
6. Ortak sabitlere dokunulduysa portre karesi aynı.
7. Bölüm 2'de oyun kodu ve sahneleri değişmemiş (`git status` kanıtı); paket dosyaları git'te değil.
8. Kullanılan her paketin lisansı rapora bağlantılı; CC0 ya da CC BY dışı paket yok; lisans metinleri `licences/`'ta.
9. Karşılama tablosu envanterin tamamını kapsıyor; boşluklar listeli.
10. İki varyant, her sahne, gündüz ve gece, aynı kamera noktaları; yan yana kareler ve kalibrasyon karesi var.
11. Hüküm raporu altı soruyu cevaplıyor; iş tahmini sahne başına.

## 6. Done mesajı
İki bölümün özeti; kök neden ve onun kanıt karesi; değişen her ayar (önce → sonra); GPU süresi; görüntü yolları;
paket ailesi önerisi ve hüküm; sahibin onaylaması gereken kararlar (§3); bilinen sorunlar; commit listesi.

## 7. Öğretici notlar

**Gölge haritası ve ortografik kamera.** Godot 4.6'da yönlü ışığın gölgesi kameranın near..far kutusunu saran bir
küreye oturur ve kenarları iki texel'lik bir ızgaraya yuvarlanır; bu, gölgeyi kamera hareketinde sabit tutmak içindir.
Ortografik kamerada `directional_shadow_max_distance` hiç kullanılmaz; çözünürlüğü near..far derinliği belirler.
Godot 3'teki "Stable/Optimized" seçeneği 4'te yoktur, çünkü sabitleme her zaman açıktır. Bu yüzden "Orthogonal'a
geç" bu projede bir şey değiştirmez; asıl kaldıraçlar kutu derinliği, atlas boyutu, filtre kalitesi ve sapmadır.

**Stilize sahnede malzeme disiplini.** Bu oyunun malzemeleri Godot'nun standart malzemesi değil, kendi toon
gölgelendiricisidir: speküler üretmez, roughness ve metallic'i okumaz, ROUGHNESS kanalını kontur geçişine bayrak
olarak kullanır. "Plastik parlama"nın kaynağı burada malzeme değil, parlama (glow) eşiği ve gece ışıklarının dengesidir.

**Sandbox'ta asset denemesi.** Oyunun kendi sahnesinin ışığı, kamerası ve gölgelendiricisi laboratuvara kopyalanmadan,
`OfficeView.tscn`'den canlı alınır; böylece karşılaştırma adil olur ve Bölüm 1'in düzeltmeleri laboratuvara da yansır.
Reddedilen deneme silinir; oyun bozulmaz.
