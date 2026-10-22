import os
HERE = os.path.dirname(os.path.abspath(__file__))
p = os.path.join(HERE, "template.md")
s = open(p, encoding="utf-8").read()


def rep(a, b):
    global s
    assert a in s, a[:70]
    s = s.replace(a, b, 1)


rep("""- "Eski, aynı U" kolunda 21 adsız düşüş (4 kol toplamı): hedef yüksek olduğu için kayma yukarı yönde; adsız düşüşler 4. haftada tabanın kalkması ve güven defterinin affı (+6'nın günde 0,4 erimesi).""",
    """- "Eski, aynı U" kolunda 21 adsız düşüş (4 kol toplamı): hedef yüksek olduğu için kayma yukarı yönde; adsızların 16'sı imzadan 1 hafta sonra (imza 50'den hedefe iniş), 5'i 4. haftada (taban kalkışı).""")
rep("""- D: 40-120 arası 80 hafta sessizlik; 104. haftada yaş terimi -12 ve çıta okuması: 78. 120'de sürüm gelince 97'ye dönüyor.""",
    """- D: 40-120 arası 80 hafta sessizlik; 104. haftada yaş terimi -12, "Zam -2" ve Series A çıtası okuması (U 100 → 93): 78. 120'de sürüm gelince yaş terimi siliniyor, 208. haftada 97.""")
rep("""Okuma: `fix_worst` %86,4 geçiriyor (≥ %80: GEÇTİ). Dönenler hafta 16-20'de, ürünün Çekirdek'i 0,6'da ve açık hata 20-29 iken imza atmak isteyen adaylar.""",
    """Okuma: `fix_worst` %86,4 geçiriyor (≥ %80: GEÇTİ). Dönenler hafta 16-20 imzaları: ürünün Çekirdek'i 0,6'da, açık hata 9'dan 29'a çıkarken.""")
rep("""Bantlar [ÇALIŞMA]; Erdem kararı.

### 2.11""", """Bantlar [ÇALIŞMA]; Erdem kararı.

Pazar çıtası ölçeği, bilgi koşusu (çıta ×1,0 bugünkü öneri; ×1,5 ve ×2,0 Traction ve Series A beklentilerinin çarpımı):

@@O2@@

### 2.11""")
rep("""Pazar çıtasını iki katına çıkaran bilgi koşusunda ortalama memnuniyet 75'e iniyor, ama tutum hâlâ %97 "Zamma açık" (§5, O2): çıtayı oynatmak yetmiyor, bantlar oynamalı.""",
    """Pazar çıtasını iki katına çıkaran bilgi koşusunda ortalama memnuniyet 75'e iniyor, ama tutum hâlâ %97 "Zamma açık" (aşağıdaki tablo): çıtayı oynatmak yetmiyor, bantlar oynamalı.""")
rep("""Neden: p_max 0,30 tavanı. Ekonomik'in ham olasılığı 0,31-0,63'e çıkıyor ve 0,30'da kesiliyor; Standart'ın ham olasılığı da 0,30'a yetişiyor. Kademe çarpanı **tavandan önce** uygulandığı için tavan kademeleri eşitliyor.""",
    """Neden: p_max 0,30 tavanı. Bu üç hücrede Ekonomik'in ham olasılığı 0,44 / 0,38 / 0,63 ve 0,30'da kesiliyor; Standart'ınki 0,22 / 0,19 / 0,31 (sonuncuda o da kesiliyor). Kademe çarpanı **tavandan önce** uygulandığı için kesik Ekonomik, Standart'a yaklaşıyor ya da onunla eşitleniyor.""")
rep("""- Kurumsal bile %100 üstü yükte ayda 10 olay verir (104 haftada); Ekonomik %70 yükte 8,6. "Yükü %90'ın altında tut" mesajı oyuncuya görünür olur.""",
    """- Kurumsal bile yük %100'ün üstünde ve açık hata tavanda iken 104 haftada 10 kesinti yaşıyor; Ekonomik %70 yükte ve az hatada 8,6. "Yükü %90'ın altında tut" mesajı oyuncuya görünür olur.""")
rep("""Kurucu satırı ve kira, sunucu artışıyla birlikte kalkan iki kalemin yaklaşık beşte birini geri getiriyor.""",
    """Yeni kalemler (sunucu artışı, kurucu satırı, kira) kalkan iki kalemin ($80K / $92K) ancak $20K / $18K'sını geri getiriyor.""")
rep("""**Tanı.** Formül `hata terimi = min(3 x H, 60)`, H = açık hata / canlı hat (`C_ICERIK_v3.md` §5.2). `none` kolunda geç dönemde H 24-40 (167-325 açık hata, 7-8 canlı hat): terim 17 haftadan fazla sürekli tavanda. Memnuniyet = U - 60. U = 100 iken 40 kalıyor; eşik 30 / 33 / 36 (+2 inşaat): fark 4-10 puan **pozitif**. Hesap kaybetmiyor, "İndirim ister" (fark 5-11) diye yenileniyor. Kayıp yalnız U < 100 olan ya da 3★ ve inşaat hesaplarda (3 ile 15 hesap).""",
    """**Tanı.** Formül `hata terimi = min(3 x H, 60)`, H = açık hata / canlı hat (`C_ICERIK_v3.md` §5.2). `none` kolunda 50. haftadan sonra H 20-40 (140-325 açık hata, 7-8 canlı hat): terim hep tavanda. Memnuniyet = U - 60. U = 100 iken 40 kalıyor; eşik 30 / 33 / 36 (+2 inşaat): fark 2-10 puan **pozitif**. Hesap kaybetmiyor, "İndirim ister" (fark 5-11) diye yenileniyor. Kayıp yalnız eşiği yüksek (3★, inşaat) ya da kesinti satırı alan hesaplarda: iki tohumda 18 hesap (8'i 3★, 7'si 2★, 3'ü 1★; 14'ü Risk, 4'ü bütçe kesintisi).""")
rep("""Okuma: tavan 62 M5'i tutturuyor (%13,4 / %11,9); 64'te %35 / %59. Basamaklı çünkü `none` kolunda terim sürekli tavanda ve eşikler 30-38'de kümeleniyor: her tavan değeri bir eşik bandını açıyor (64: 3★ ve çoğu 2★ gider, 1★ tutunur; 68: 2★ ve 3★ hep; 70: hepsi). M3 ve M4 değişmiyor (`worst/due/off`'ta H 0,5-4,8, terim en çok 15: tavana hiç dayanmıyor); ortalama memnuniyet (worst 92,5) ve imza kapısı reddi (23 / 705) aynı. **Öneri: tavan 64.** Sınır: `none` kolunun 190-325 açık hatası uç bir oyuncudur; arada kalan oyuncu tavana dayanmaz.""",
    """Okuma: tavan 62 M5'i tutturuyor (%13,4 / %11,9); 64'te %35 / %59. Basamaklı çünkü `none` kolunda terim sürekli tavanda ve eşikler 30-38'de kümeleniyor: tavan her artışta bir eşik bandını daha açıyor. Tavan 64'te kayıp 118 hesap (246 imzadan): 2★ 101 / 111, 3★ 13 / 13, 1★ 4 / 122; yani 2★ ve 3★ gider, 1★ tutunur. Tavan 68'de 2★ ve 3★ hep, 70'te hepsi gider. İmza kapısı da sertleşiyor: tavan 64'te `none` kolunda imza 437'den 246'ya iniyor (imza anında terim daha büyük). M3 ve M4 değişmiyor (`worst/due/off`'ta H 0,5-4,8, terim en çok 15: tavana hiç dayanmıyor); ortalama memnuniyet (worst 92,5) ve `worst` kapı reddi (23 / 705) aynı. **Öneri: tavan 64.** Sınır: `none` kolunun 140-325 açık hatası uç bir oyuncudur; arada kalan oyuncu tavana dayanmaz.""")
rep("""304 hesapta 38 temsilci, aylık yaklaşık $71K: kalkan servisin evre 3 ortalamasıyla ($69K-81K) aynı büyüklük. Yani telafi, maaş bantlarını çarpmadan, "hesap sayısına göre temsilci tutmak" oyuncu kararı olarak gelirse ekonomi kendiliğinden dengelenir; ama bunu modelde hiçbir kural zorlamıyor (temsilcisiz hesap bugün yalnız yavaş affeder, §2.7). Bu soru M11'in dışında; Erdem'e açık.""",
    """304 hesapta 38 temsilci, aylık yaklaşık $71K: kalkan servisin evre 3 ortalamasıyla ($69K-81K) aynı büyüklük. Yani telafi, maaş bantlarını çarpmadan, "hesap sayısına göre temsilci tutmak" oyuncu kararı olarak gelirse ekonomi kendiliğinden dengelenir. Ama bunu modelde hiçbir kural zorlamıyor ve bu raporda temsilci kapasitesini aşan hesabın sonucu ölçülmedi. Bu soru M11'in dışında; Erdem'e açık.""")
rep("""Kayıtta bot "oyala" oynuyordu (sayaç 3 görünüyor).""", """Kayıtta ilk Risk haftasında sayaç 3 görünüyor (2 olmalı); botun "oyala" oynadığını varsayıyorum, doğrulamadım.""")
rep("""**Söz yok** bot kollarında (kayıttaki 42 söz tekrar oynatılmadı); söz yalnız M6 ve R9 senaryolarında.""", """**Söz yok** bot kollarında (kayıttaki söz olayları, ör. `worst` tohum 7'de 20 söz, tekrar oynatılmadı); söz yalnız M6 ve R9 senaryolarında.""")
rep("""6. **Açık hata terimi** hesap bağlamında alan ağırlığı değil, toplam canlı hat sayısıyla: orantılı dağıtım varsayımında iki aynı sonucu verir (§6).""", """6. **Açık hata terimi** alan ağırlığıyla değil toplam canlı hat sayısıyla hesaplandı: açık hata alanlara canlı hat sayısıyla orantılı dağıldığı için iki yol aynı sonucu verir (§6).""")
rep("""2. **Eski kolda eşik** bugünkü kod (33 / 42 / 51); ayrı bir kol "eski mekanizma, yeni eşik" de koşuldu (nedensiz 10, kayıp 0; tablo dışında).""", """2. **Eski kolda eşik** bugünkü kod (33 / 42 / 51); ayrı bir kol "eski mekanizma, yeni eşik" de koşuldu (4 kol toplamı nedensiz 10, kayıp 0; tablo dışında).""")
rep("""| Ofis koşulları | İş hanı nakit 6.500; Plaza ekip 12, nakit 45K, marka 40; Loft 35, 110K, 70 | `office_constants.gd:26-57` |""", """| Ofis koşulları | İş hanı nakit 6.500; Plaza ekip 12, nakit 45K, marka 40; Loft 35, 110K, 70 | `office_constants.gd:15-62` |""")
rep("taşınma koşulları `office_constants.gd:26-57`", "taşınma koşulları `office_constants.gd:15-62`")
rep("""Olumlu delta eski modelde 1 hafta, yeni modelde kalıcı satır ve +10 tavanına sayılıyor (yorum 12).""", """Olumlu delta eski modelde 1 hafta, yeni modelde kalıcı satır (60 haftalık pencerenin tamamı) ve +10 tavanına sayılıyor (yorum 12).""")
open(p, "w", encoding="utf-8").write(s)
print("ok")
