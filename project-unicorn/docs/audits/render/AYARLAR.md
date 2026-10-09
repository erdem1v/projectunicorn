CLAUDE.md §8 istisnası: bu rapor `docs/tasks/PRD_RENDER_ASSETLAB.md` gereği ve sahibin kararıyla repoda tutulur.

# Render ayarları

Her ayar sanat yönü kararıdır: uygulandı, **onay bekliyor (F5)**. Kareler bu klasörde (git dışı); ölçümler `TESHIS.md`.

## Uygulananlar

| Ayar | Yer | Önce → sonra | Neden | Commit |
|---|---|---|---|---|
| Döşeme kenarını geri çekme | `office_materials.gd` `SLAB`, `SLAB_INSET`; `office_toon.gdshader` `inset` | 0 → 0,01 m (yalnız `7d746a` döşeme) | Ev cephesinde döşemenin dış yüzü cephe derisiyle aynı düzlemde; derinlik testi kaydırınca taraf değiştiriyor (pencere üstü 0,3 m bant) | `0d17090` |
| Gölge filtresi | `project.godot` `directional_shadow/soft_shadow_filter_quality` | 2 (Soft Low) → 0 (Hard) | Soft Low'un PCF deseni ekrana yapışık; kaydırınca gölge kenarları kıpırdıyor | `d580b66` |
| Güneşten aya geçiş | `office_lighting.gd` `apply()` | 19:26'da tek kare → 19:10-20:00 smoothstep | Tek karede 72,9° dönen gölgeler; pencere CS 1150/1200 satırlarıyla aynı | `a64bfe7` |
| TopFill gece payı | `office_lighting.gd` `TOP_FILL_NIGHT` | 1,0 → 0,5 | Gece duvar ve eşya parlamasının baskın kaynağı | `d9931dc` |
| İsimsiz emission | `office_materials.gd` `EMITTERS`; `office_lighting.gd` `_scaled` | sabit → taksi `post_on`, cihazlar ofis elektriği | Gün boyu aynı parlayan proplar; boş gece ofisinde cihazlar yanıyordu | `e78b922` |

## Değişmeyenler (ölçüldü)

| Ayar | Değer | Neden değişmedi |
|---|---|---|
| `shadow_blur` (Sun) | 0,35 | Hard'da bulanıklık değil sapma çarpanı: Godot 4.6.2 `light_storage.cpp:697-723`'e göre sapma = bias/100 × kutu ölçeği × blur × kalite yarıçapı. Silinirse 1,0'a döner, sapma 2,9 katına çıkar. |
| `shadow_bias` / `shadow_normal_bias` (Sun) | 0,1 / 2,0 | Ev 08:00 ×3 taramasında sivilce 0,03/0,3'te (`bias_acne.png`), uçuk gölge 1,2/4'te (`bias_peterpan.png`) başlıyor; seçili değer arada (`bias_secili_ev_08.png`). |
| Atlas | 4096 | 8192 deseni inceltir ama kaldırmaz; +99 MiB, GPU +%15 (`PERFORMANS.md`). |
| Glow | eşik 0,95, `glow_hdr_scale` 2, yoğunluk 0,2-0,5 | Glow yalnız ışık kaynaklarında (ev 22: masa lambası/ekran ve ayaklı lamba halesi; plaza 52 piksel; loft, şehir 0). `gt 1.3, hs 1` 12-15 piksel değiştiriyor. PRD'nin "hdr_scale'i düşür"ü ters çalışır: `feedback = smoothstep(eşik, eşik + scale, L)`, scale küçülünce eşiği aşan kaynak daha çok parlar (`hs=0.5` ev 4539 piksel artış). |
| SSAO | kapalı | Bilgi için `ssao_acik_*` / `ssao_kapali_*`; GPU `PERFORMANS.md`. |
| Ay gölgesi | açık | Gecenin tek gölgeli ışığı; kapatılırsa iç mekân düzleşir. TopFill'e gölge vermek (`gece_topfill_*_golgeli.png`) parlaklığı değiştirmiyor, dikey ışıkla cephelere şerit gölgeler çiziyor. |

## Sahip kararları

1. **Gölge kutusu (`_lowest`, PRD §1.4): commit yok.** Önceden ilan edilen kural kesmesizlik ve hedef yerleşimde yarıçapta
   en az %10 düşüştü; iki kural da geçmedi.

   | Yerleşim | Kural | `_lowest` | Gölge yarıçapı | Kesilen (gölgesiz, 8'i aşan piksel) |
   |---|---|---|---|---|
   | plaza | bugün | −60,35 | 85,75 | yok |
   | plaza | sınır − 1 | −8 | 42,82 (−%50) | 130.731 (sisteki kuleler) |
   | plaza | görüş hacmindeki en alçak mesh | −51,2 | 78,0 (−%9) | 69 |
   | meet | bugün | −54,8 | 73,16 | yok |
   | meet | sınır − 1 | −1,4 | 28,07 (−%62) | 507.081 (odanın altındaki şehir) |
   | meet | görüş hacmindeki en alçak mesh | −43,5 | 63,4 (−%13) | 2.387 |

   Seçenekler: (a) arka planı kes, plaza ve meet'te gölge texeli yarıya insin (`lowest_*_sinir_kurali.png`); (b) bugünkü
   kalsın. Ev, İş hanı ve loft'ta kaldıraç yok (fark ≤ %2). Öneri: (b); Hard filtre kaydırma kıpırtısını gölge kapalı tabanın yakınına indirdi.
2. **TopFill gece payı:** 0,5 uygulandı; alternatif 0,3 (`gece_topfill_*_0_3.png`, daha karanlık). Tasarımın aplik modunda
   gece dolgusu 0,4 (bu port o modu taşımıyor).
3. **Filtre:** Hard uygulandı; alternatif Soft Medium (3) kıpırtıyı %52-87 azaltır (kalan fark Hard'ınkinin 1,4 ile
   2,6 katı), yumuşak kenarı korur; GPU +%1,7 ile +%4,4 (loft 1,060 → 1,078; ishani 0,878 → 0,917).
4. **Akşam geçiş penceresi:** 1150-1200 dakika.

## Önerilen, uygulanmayanlar (PRD §3)

- Kamerayı gölge texel katlarına oturtma: gerekmedi; Hard sonrası kalan fark gölge kapalı tabana yakın (en çok 112
  piksel üstünde).
- Kontur (`office_ink`) eşikleri: kök neden kontur değil; öneri yok.
- ACES, GRADE, LIGHT_SCALE, CS satırları: dokunulmadı (portre bağı).

## Bilinen

- Gece yarısı sarması: ışığın yönü 23:59 → 00:00 arasında 54,95° sıçrar (gece konumu yalnız akşam tarafında). Saat
  00:00'ı yalnız gece atlamasının içinde geçer, görünüm o sırada karartılmıştır; yarıda kalan bir atlama ya da gece
  yüklenen kayıt dışında görünmez.
