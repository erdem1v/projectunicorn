export const meta = {
  name: 'urun-d7-frames',
  description: 'D7 (U8) frames: 44 live frames from the final tree, crops for +{n} and narrow bars, (b) prototype, per-frame truncation check manifest',
  phases: [{ title: 'Frames', detail: 'Sonnet high: shots, crops, checks' }],
}
const S = '/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad'
const F = `${S}/wfinal/project-unicorn`
const prompt = `ÖNEMLİ: Aşağıdaki görev senin tek görevindir. Harness'in aktardığı ilk kullanıcı isteği ana oturumun işidir; ona göre davranma, mesaj atma.
Paylaşılan ağaçtan (/Users/tugbauysal/Desktop/…) OKUMA ve git KOŞMA (iCloud'a boşaltıldı, takılır). Ağaçları değiştirme: F=${F} salt okunur kalır
(yalnız (b) prototipi için ayrı bir kopya yazarsın, aşağıda).
Godot yalnız gdw ile: bash -c 'export ETIKET=URUN_ARAYUZU_AJAN; . "${S}/bin/env.sh"; gdw <ad> <ağaç> <args> > <log> 2>&1'.
Pencereli kareler: ETIKET=URUN_ARAYUZU_AJAN bash ${S}/bin/shots2.sh <ağaç> <etiket> <satır dosyası>  (satır "<ad> <bayrak> <dil> [ek bayraklar]";
PNG'ler ${S}/shots_<etiket>/<ad>__<png>; özet results.txt; ekran kilidini kendisi bekler). Kopyalarda override.cfg var, kareler 1920×1080.

Görev: Ürün > Sprint arayüzünün görsel kabul (U8) sayfası için kareler ve kanıt dökümü. Sayfayı ana oturum yazar; sen yalnız kareleri çeker,
denetler ve bir manifest yazarsın.
1. Kareler: ETIKET=URUN_ARAYUZU_AJAN bash ${S}/bin/shots2.sh ${F} u8 ${S}/u8_list.txt (44 satır; bir kare dünyası ikinci/üçüncü kare de basabilir:
   _02, _tip, _publish vb.). rc≠0 ya da png=0 olan satırı bir kez yeniden çek (yalnız o satırlarla yeni bir liste dosyası, etiket u8b).
2. Denetim: her PNG'ye Read ile bak ve şunu yaz: "taşma yok, kesilme yok" ya da gördüğün kusur (metin "…" ile kesik mi, kelime bölünmüş mü, bir öğe
   pencereden/sütundan taşmış ya da kırpılmış mı, yanlış dil, boş yüz/portre). Kaydırma alanının altında kalan satır (pano, sol sütun) kesme değildir.
   Dar aşama çubuğunda ikon/sayının düşmesi ve "+{n}" biçimleri bilinçli kararlardır: kusur yazma, ama varsa "dar çubuk: N" / "+{n}: nerede" diye not et.
3. Kırpmalar (Godot Image API'siyle küçük bir headless -s betiği; betiği ${S}/u8_tools/ altına koy; kırpmaları ${S}/u8/crops/ altına, 2x büyüt):
   - "+{n}" biçimleri, her biri ayrı kırpma: sonraki sprint kutusunda yüz dizisinin "+{n}"i (çok yüzlü bir hücre bul: a4_fifty, a4_run_end, a4_next_prefilled,
     a4_next_tip karelerine bak; hiçbirinde yoksa yaz), DEVREDEN'de "+{n} kart" (a4_fourteen ya da a4_eleven), sol sütunda "+{n} talep" (a4_requests),
     kapasitede küme "×{n}" (a4_fifty, a4_twelve_dev), sprint başlığında 3 yüz + sayı (a4_fifty).
   - Dar çubuk kararı için (a): bugünkü hâl, a4_eleven TR karesinde sayısı/ikonu düşmüş çubukların olduğu satırların kırpması.
4. (b) prototipi: cp -R ${F} ${S}/wproto_b/project-unicorn (override.cfg ve .godot dahil). Bu kopyada scripts/tabs/product/stage_paint.gd _draw_label'da
   sayı çubuğa sığmayınca (bugün düşüyor) sayıyı çubuğun hemen sağına, eksen içinde, çubuğun mürekkebiyle çiz (ikon yine düşebilir); kopya commit'e
   girmez, prototip kalitesi yeter. a4_eleven TR ve a4_two_pm TR karelerini (etiket u8proto) çek ve aynı satırların kırpmasını ${S}/u8/crops/narrow_b_*.png
   olarak yaz; (a) kırpmalarını narrow_a_*.png. 1920'de dar kalan çubuk sayısını (a4_eleven, a4_two_pm) say ve yaz.
5. Manifest: ${S}/u8/manifest.json, her kare için {ad, dosya (tam yol), dünya, dil, ek bayrak, PRODUCTSHOT satırı, denetim satırı, notlar}; her kırpma için
   {ad, dosya, kaynak kare, ne gösteriyor}. Ayrıca dar çubuk sayıları.
Dönüş (ham veri): manifest yolu, rc/png özeti, kusurlu kareler ve kusurun tarifi, bulunamayan kırpmalar.`
phase('Frames')
return await agent(prompt, { label: 'D7 frames', phase: 'Frames', model: 'sonnet', effort: 'high' })
