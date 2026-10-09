CLAUDE.md §8 istisnası: bu rapor `docs/tasks/PRD_RENDER_ASSETLAB.md` gereği ve sahibin kararıyla repoda tutulur.

# Performans

Makine: AMD Radeon RX 9070 XT, D3D12, Forward+, Godot 4.6.2. Ölçü: ofisin 3B alt görüntüsünün (1736×976) GPU ve CPU
süresi, `RenderingServer.viewport_get_measured_render_time_*`, vsync kapalı. Her çift ABABABAB bloklarla koşar; blok
başına 120 kare, ilk 30'u atılır (kol başına 360 kare). Aynı süreçte A/A çifti gürültü tabanını verir. Komut:
`--office-shot=<ofis>:13 --pan=0,0 --pan-gpu='<A>/<B>;…'`.

## Önce (`a878ce3`, Soft Low, atlas 4096)

| Ofis | Çift | GPU medyan (ms) | GPU p95 | Video belleği (MiB) |
|---|---|---|---|---|
| ishani | atlas 4096 / 8192 | 0,902 / 1,039 | 0,974 / 1,146 | 569,1 / 668,1 |
| ishani | soft 2 / soft 0 | 0,901 / 0,892 | 0,984 / 0,973 | 569,1 |
| ishani | soft 2 / soft 3 | 0,878 / 0,917 | 0,973 / 0,994 | 569,1 |
| ishani | A/A (soft 2) | 0,906 / 0,900 | 0,984 / 0,972 | 569,1 |
| loft | atlas 4096 / 8192 | 1,061 / 1,217 | 1,145 / 1,321 | 633,1 / 732,1 |
| loft | soft 2 / soft 0 | 1,061 / 1,050 | 1,151 / 1,135 | 633,1 |
| loft | soft 2 / soft 3 | 1,060 / 1,078 | 1,144 / 1,174 | 633,1 |
| loft | A/A (soft 2) | 1,059 / 1,061 | 1,151 / 1,149 | 633,1 |

## Sonra (`e78b922`; aynı süreçte Soft Low ile Hard, SSAO kapalı ile açık)

Ölçüm boyunca makinede başka Godot süreci yoktu (her koşudan önce ve sonra sayıldı: 0).

| Ofis | Çift | GPU medyan (ms) | GPU p95 | Video belleği (MiB) |
|---|---|---|---|---|
| ishani 13 | soft 2 / soft 0 | 0,894 / 0,891 | 0,986 / 0,982 | 569,1 |
| ishani 13 | SSAO kapalı / açık | 0,893 / 0,938 | 0,936 / 1,022 | 578,4 |
| ishani 13 | A/A (soft 0) | 0,896 / 0,895 | 0,979 / 0,989 | 578,4 |
| loft 13 | soft 2 / soft 0 | 1,070 / 1,061 | 1,150 / 1,139 | 633,1 |
| loft 13 | SSAO kapalı / açık | 1,058 / 1,102 | 1,130 / 1,176 | 642,4 |
| loft 13 | A/A (soft 0) | 1,057 / 1,056 | 1,133 / 1,136 | 642,4 |
| ishani 22:full | soft 2 / soft 0 | 0,902 / 0,864 | 0,984 / 0,940 | 569,1 |
| ishani 22:full | SSAO kapalı / açık | 0,865 / 0,923 | 0,929 / 1,015 | 578,4 |
| ishani 22:full | A/A (soft 0) | 0,866 / 0,865 | 0,938 / 0,929 | 578,4 |

SSAO bir kez açılınca tamponları kalır (+9,3 MiB); bu yüzden SSAO çiftinden sonraki satırlar 578,4 / 642,4 okur.

## Okuma

- Hard filtre GPU'yu artırmaz: gündüz 0,003-0,009 ms azaltır (ishani 0,894 → 0,891, loft 1,070 → 1,061; aynı koşudaki
  A/A farkı 0,001 ms), gece %4 azaltır (ishani 22:full 0,902 → 0,864).
- SSAO +%4-7 GPU ve +9,3 MiB; görüntüye katkısı `ssao_acik_<ofis>.png` / `ssao_kapali_<ofis>.png`. Varsayılan
  kapalı kalır.
- Atlas 8192 +%15 GPU ve +99 MiB video belleği: desen inceltir ama kaldırmaz; uygulanmadı.
- ACIK_KARARLAR 71 bağlamı: loft'un 70 kişilik kare süresi (~8,4-9,9 ms) 3B alt görüntünün GPU süresinin çok üstünde
  (loft ~1,06 ms, ishani ~0,90 ms); bu denetimin değişiklikleri GPU süresini artırmıyor.
