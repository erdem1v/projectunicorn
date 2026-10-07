# The pages of ../icons.html. Text is for Erdem (Turkish, no dashes); meanings quote strings.csv.
import os, re, sys
from glyphs import HEAD, HEAD_ORDER, BREAK

HERE = os.path.dirname(os.path.abspath(__file__))
ART = "../art"   # relative to system/icons.html
TOTAL = 8

CSS2 = """
/* rail context (SPEC: rows 48, icon 24 ink-4, name t-nav ink-3) */
.ctx{display:flex;gap:16px;align-items:flex-start}
.rail{width:184px;background:var(--surface-1);border-radius:6px;padding:12px 0;flex:none}
.rr{height:48px;display:flex;align-items:center;gap:14px;padding:0 16px 0 20px;position:relative}
.rr svg{color:var(--ink-4)}
.rr .t{font-family:var(--f-cond);font-weight:600;font-size:16px;line-height:22px;letter-spacing:1px;text-transform:uppercase;color:var(--ink-3)}
.rr .s{font-family:var(--f-cond);font-weight:600;font-size:12px;line-height:14px;letter-spacing:1px;text-transform:uppercase;color:var(--ink-4)}
.rr.on{background:var(--surface-4)}
.rr.on::before{content:"";position:absolute;left:0;top:8px;bottom:8px;width:3px;background:var(--selected-mark);border-radius:0 2px 2px 0}
.rr.on svg{color:var(--ink-2)}.rr.on .t{color:var(--ink-1)}
.rr.hv{box-shadow:inset 0 0 0 1px var(--line-hover)}
.rr.lk svg,.rr.lk .t{color:var(--ink-off)}
.bdg{margin-left:auto;min-width:22px;height:22px;border-radius:11px;font-weight:700;font-size:13px;display:flex;align-items:center;justify-content:center;padding:0 6px}
.bdg.dg{background:var(--neg);color:var(--on-neg)}
.bdg.ct{background:var(--surface-5);color:var(--ink-2);box-shadow:inset 0 0 0 1px var(--line-2)}
.bdg.gt{min-width:10px;width:10px;height:10px;padding:0;border-radius:5px;background:var(--accent);box-shadow:0 0 0 3px var(--accent-glow)}
.nrail{width:64px;background:var(--surface-1);border-radius:6px;padding:12px 0;flex:none}
.nrail .rr{padding:0;justify-content:center;gap:0}
.nrail .bdg{position:absolute;left:34px;top:5px;margin:0;min-width:18px;height:18px;border-radius:9px;font-size:12px;padding:0 5px;box-shadow:0 0 0 2px var(--surface-1)}
.nrail .rr.on .bdg{box-shadow:0 0 0 2px var(--surface-4)}
.nrail .bdg.ct{box-shadow:inset 0 0 0 1px var(--line-2),0 0 0 2px var(--surface-1)}
.nrail .bdg.gt{left:38px;top:9px;min-width:8px;width:8px;height:8px;box-shadow:0 0 0 2px var(--surface-1)}
.nrail .lkg{position:absolute;left:37px;top:26px;padding:1px;border-radius:3px;background:var(--surface-1)}
.cmp{display:flex;gap:10px}
.cmp .col{background:var(--surface-1);border-radius:6px;padding:10px 0;width:76px;display:flex;flex-direction:column;align-items:center;gap:20px}
.cmp .col svg{color:var(--ink-4)}
.cmp .lab{font-family:var(--f-cond);font-weight:600;font-size:12px;letter-spacing:1px;color:var(--ink-4);text-align:center;width:76px;margin-top:6px}
/* ekip context */
.tb{font-size:15px}
.th{display:flex;align-items:flex-end;height:56px;border-bottom:1px solid var(--line-1);padding:0 0 8px}
.th .c,.tr .c{flex:none;display:flex;align-items:center;justify-content:center}
.th .lbl{font-family:var(--f-cond);font-weight:600;font-size:14px;letter-spacing:1px;text-transform:uppercase;color:var(--ink-3)}
.span{position:relative}
.spanlbl{position:absolute;left:0;right:0;top:-26px;text-align:center;font-family:var(--f-cond);font-weight:600;font-size:14px;letter-spacing:1px;color:var(--ink-3);border-bottom:1px solid var(--line-2);padding-bottom:3px}
.grp{height:40px;display:flex;align-items:center;gap:10px;font-family:var(--f-cond);font-weight:600;font-size:15px;letter-spacing:1px;color:var(--ink-2)}
.grp svg{color:var(--ink-4)}
.grp::after{content:"";flex:1;height:1px;background:var(--line-1)}
.tr{display:flex;align-items:center;height:40px;border-bottom:1px solid var(--row-rule)}
.face{width:32px;height:32px;border-radius:16px;overflow:hidden;background:radial-gradient(circle at 50% 38%,#4A4239 0,#2E2924 55%,#1E1B18 100%);box-shadow:inset 0 0 0 1px var(--line-3)}
.face img{width:100%;height:100%;display:block}
.nm2{display:flex;flex-direction:column;line-height:17px;padding-left:10px}
.nm2 b{font-weight:600;font-size:15px;color:var(--ink-1)}
.nm2 span{font-family:var(--f-sansc);font-size:13px;color:var(--ink-3)}
.sk{font-weight:500;font-size:16px}
.huy{display:flex;align-items:center;gap:8px;justify-content:flex-start!important}
.huy .bx{width:26px;height:26px;border-radius:5px;background:var(--surface-5);border:1px solid var(--line-2);display:flex;align-items:center;justify-content:center;flex:none}
.huy .bx svg{color:var(--ink-2)}
.huy .tx{font-family:var(--f-sansc);font-size:14px;color:var(--ink-2)}
.tip{background:var(--surface-0);border:1px solid var(--line-2);border-radius:4px;padding:8px 10px;font-size:14px;line-height:20px;color:var(--ink-2);max-width:320px}
.tip b{display:flex;align-items:center;gap:8px;font-weight:600;margin-bottom:2px}
/* sprint card, stake */
.card{width:300px;background:var(--surface-4);border:1px solid var(--line-2);border-radius:6px;padding:12px 14px;display:flex;flex-direction:column;gap:10px}
.card .k1{display:flex;align-items:center;gap:8px;font-family:var(--f-cond);font-weight:600;font-size:14px;letter-spacing:1px;color:var(--ink-3)}
.card .k1 svg{color:var(--ink-2)}
.card .tt{font-weight:600;font-size:16px;line-height:22px;color:var(--ink-1)}
.card .k2{display:flex;align-items:center;gap:6px}
.card .k2 svg{color:var(--ink-3)}
.chipx{margin-left:auto;display:flex;align-items:center;gap:4px;height:22px;padding:0 6px;border-radius:3px;font-weight:600;font-size:13px}
.chipx.bug{background:var(--neg-tag-bg);border:1px solid var(--neg-tag-line);color:var(--neg-ink)}
.chipx.vo{border:1px solid var(--line-3);color:var(--ink-2);margin-left:0}
.stake{height:104px;background:var(--surface-4);border-radius:6px;display:flex;align-items:center;padding:0 24px;gap:22px}
.part .k{font-family:var(--f-cond);font-weight:600;font-size:14px;letter-spacing:1px;color:var(--ink-3);line-height:19px}
.part .v{display:flex;align-items:center;gap:10px;font-weight:700;font-size:36px;line-height:47px;color:var(--ink-2)}
.part .v.pos{color:var(--pos)}.part .v.neg{color:var(--neg)}
.dotsep{color:var(--ink-4);font-size:28px}
/* inline glyphs in text (the Noto replacements) */
.inl{display:flex;align-items:center;gap:6px;height:32px;padding:0 12px;border-radius:4px;background:var(--surface-3);font-family:var(--f-cond);font-weight:600;font-size:16px;letter-spacing:1px;color:var(--ink-2)}
.inl.sans{font-family:var(--f-sans);font-weight:500;letter-spacing:0}
.tbl{width:100%%;border-collapse:collapse;font-size:14px;line-height:20px}
.tbl th{font-family:var(--f-cond);font-weight:600;font-size:13px;letter-spacing:1px;text-transform:uppercase;color:var(--ink-3);text-align:left;padding:6px 10px;border-bottom:1px solid var(--line-2)}
.tbl td{padding:8px 10px;border-bottom:1px solid var(--row-rule);color:var(--ink-3);vertical-align:middle}
.tbl td b{color:var(--ink-2);font-weight:600}
.tbl code{font-family:var(--f-sansc);font-size:13px;color:var(--ink-2)}
.big{font-size:22px;color:var(--ink-2);white-space:nowrap}
.icn{display:flex;gap:6px;align-items:center}
/* office */
.heads{display:flex;gap:22px;align-items:flex-end;flex-wrap:wrap}
.heads figure{display:flex;flex-direction:column;align-items:center;gap:6px}
.heads figcaption{font-family:var(--f-sansc);font-size:13px;color:#2B2722}
.floor{background:#C9C2B4;border-radius:6px;padding:14px 16px}
.hls{display:flex;flex-direction:column;gap:16px}
.hl{width:200px;height:300px;display:flex;flex-direction:column;justify-content:center;gap:6px;border-left:3px solid var(--line-2);padding-left:14px}
.hl b{font-family:var(--f-cond);font-weight:700;font-size:16px;letter-spacing:1px;color:var(--ink-2)}
.hl span{font-size:14px;line-height:20px;color:var(--ink-3)}
.set{display:flex;align-items:center;gap:16px;height:48px;border-bottom:1px solid var(--line-1);font-size:15px}
.set .grow{flex:1}
.track{width:180px;height:4px;background:var(--line-2);border-radius:2px;position:relative}
.track .fill{position:absolute;left:0;top:0;bottom:0;width:64%%;background:var(--ink-3);border-radius:2px}
.track img{position:absolute;left:calc(64%% - 12px);top:-10px}
.mapchip{display:inline-flex;align-items:center;gap:8px;height:32px;padding:0 12px 0 8px;border-radius:16px;background:var(--surface-3);border:1px solid var(--line-2);font-weight:500;font-size:14px;color:var(--ink-2)}
.mapchip svg{color:var(--ink-3)}
.mapchip.on{background:var(--surface-4);border-color:var(--line-hover)}
.mapchip.on svg{color:var(--ink-1)}
.orig{width:150px;background:var(--surface-3);border:1px solid var(--line-2);border-radius:6px;padding:14px;display:flex;flex-direction:column;gap:10px;align-items:flex-start}
.orig svg{color:var(--ink-2)}
.orig b{font-family:var(--f-cond);font-weight:700;font-size:18px;letter-spacing:1px;text-transform:uppercase;color:var(--ink-1)}
.orig span{font-size:13px;line-height:18px;color:var(--ink-3)}
""".replace("%%", "%")

# ---------------------------------------------------------------- meanings (TR for Erdem; CSV strings quoted)
NEW, CHG = ("new", "YENİ"), ("chg", "DEĞİŞTİ")
M_RAIL = {
    "rail/product": ("ÜRÜN", None, "Kutu; gölge yüzü tonda. BuildHUD başlığı da bu glifi okur (eski build/monitor)."),
    "rail/sales": ("SATIŞ", None, "Huni: boru hattı. Oyma çizgi iki aşama, alttaki nokta kapanan anlaşma."),
    "rail/hr": ("EKİP", None, "İki kişi; arkadaki tonda. Ofiste toplantıdaki kişinin glifi de bu."),
    "rail/finance": ("FİNANS", CHG, "İki banknot, arkadaki kayık: kasa. Silindir deste \"veritabanı\" okunuyordu."),
    "rail/personal": ("KİŞİSEL", None, "Tek kişi: kurucunun kendisi. Ekip'ten sayıyla ayrılır."),
    "rail/marketing": ("PAZARLAMA", None, "Megafon, sapı tonda. Bugün kilitli (Yakında)."),
    "rail/rnd": ("AR-GE", None, "Deney şişesi: sıvı dolu, cam tonda, bir kabarcık oyulmuş."),
    "rail/events": ("OLAYLAR", None, "Zarf, kâğıt çentiğiyle. Okunmamış mesaj satırı da bu glifi kullanır."),
    "rail/settings": ("AYARLAR", None, "Altı dişli çark."),
    "rail/rivals": ("RAKİPLER", None, "İsteğe bağlı: rakip dünyası dokuzuncu sekme olursa. Kürsü: pazar payı sırası."),
}
M_SKILL = {
    "skill/product": ("ÜRÜN", CHG, "Özellik kararları ve tasarım tavanı",
                      "Tabela: yön seçmek. Hedef glifi çeyrek \"hedef\"iyle çakışıyordu."),
    "skill/design": ("TASARIM", None, "Deneyim ekseninin tavanı", "Kalem ucu, yarık ve delik oyulmuş."),
    "skill/engineering": ("YAZILIM", None, "Geliştirme hızı ve hata oranı", "Kod ayracı; eğik çizgi tonda."),
    "skill/qa": ("TEST", CHG, "Beta keşif hızı ve canlı hata aşınması",
                 "Böcek ve içinden geçen onay: bulur ve doğrular. Yalın böcek product/bug, hata sayısı."),
    "skill/sales": ("SATIŞ", None, "Kapanış olasılığı ve anlaşma boyutu", "Fiyat etiketi."),
    "skill/customer_success": ("MÜŞTERİ İLİŞKİLERİ", None, "Bilet çözümü ve churn", "Kulaklık; mikrofon tonda."),
}
M_DEPT = {
    "dept/product_design": ("ÜRÜN & TASARIM", "Ampul, yansıma oyulmuş: fikir masası. Ürün Yöneticisi ve Tasarımcı."),
    "dept/development": ("GELİŞTİRME EKİBİ", "Terminal penceresi. Geliştirici ve Test Mühendisi."),
    "dept/sales": ("SATIŞ", "Evrak çantası. Satış Temsilcisi."),
    "dept/customer_success": ("MÜŞTERİ İLİŞKİLERİ", "İki konuşma balonu, arkadaki tonda. Müşteri Temsilcisi."),
}
M_TRAIT = [
    ("trait/loyal", "SADIK", "Loyal", "Moral düşükken bile kolay kolay ayrılmaz; rakip teklifine dayanır.",
     "Çapa: yerinde kalır.", "", None),
    ("trait/picks_it_up_fast", "ÇABUK KAPAR", "Picks It Up Fast", "Deneyimi belirgin şekilde hızlı kazanır.",
     "Şimşek: hızlı.", "", None),
    ("trait/last_one_out", "İŞKOLİK", "Last One Out", "Mesai morali onda çok daha yavaş erir.",
     "Hilal ve yıldız: ofisten en son çıkan.", "Etkinin motorda okuyucusu yok (overtime_morale_mult).", None),
    ("trait/takes_them_under", "GERÇEK LİDER", "Takes Them Under",
     "Sorumlusu olduğu alanda herkes daha hızlı öğrenir; ayrılıkları ağır alır.",
     "Şemsiye altında küçük bir kişi: ekibini korur, altına alır.",
     "Kep \"Eğitime gönder\" ile çakışıyordu, kanat 16 px'te okunmadı; şemsiye seçildi. Onay Erdem'in.", CHG),
    ("trait/double_checker", "TİTİZ", "Double Checker", "Geliştirmede çok daha az hata çıkarır, ama yavaş çalışır.",
     "Çift onay; ilk geçiş tonda.", "Hata etkisi sprint motorunda bağlı değil (bug_rate_mult).", None),
    ("trait/cant_say_no", "HAYIR DİYEMEZ", "Can't Say No", "Hesapları daha memnun, ama üzerinde daha çok söz birikir.",
     "Onaylı konuşma balonu, altında biriken kâğıtlar: her isteğe evet, sözler yığılır.",
     "Başparmak \"beğendi\" diye hüküm okunuyordu.", CHG),
    ("trait/bag_packed", "GÖZÜ YÜKSEKTE", "Bag Packed", "Yüksek verimle çalışır, ama rakip teklifinde tutması zor.",
     "Tekerlekli bavul: EN adının kendisi, gitmeye hazır.",
     "Basamak ve ok adayı terfi ya da puan okunuyordu; bavul kaldı. Bölüm çantasından dik duruşu, sapı ve tekerleğiyle ayrılır.", CHG),
    ("trait/mood_buster", "TAT KAÇIRAN", "Mood Buster", "Ekibinin morali normalden hızlı erir.",
     "Yağmur bulutu; yağmur tonda.", "", None),
    ("trait/unspecified", "BELİRSİZ", "Unspecified",
     "Çizilmemiş huy: kurucunun huyları (Vizyoner, Disiplinli, Ağ Kurucu, Dayanıklı, İnatçı, Mikro Yönetici, Risk Körü, Yalnız Kurt) ve bilinmeyen id.",
     "Baklava, ortası oyulmuş: nötr işaret.", "", None),
]
M_PRODUCT = {
    "product/kind_feature": ("ÖZELLİK KARTI", None, "Parıltı: yeni özellik."),
    "product/kind_polish": ("CİLA KARTI", None, "Çift şerit yukarı: var olanı iyileştirir; alttaki tonda."),
    "product/kind_fix": ("DÜZELTME KARTI", None, "Yara bandı, yastığı tonda: \"{capability} düzeltmesi\"."),
    "product/kind_research": ("ARAŞTIRMA KARTI", None, "Mercekte kişi: \"{n} kullanıcıyla görüş\"."),
    "product/voices": ("SESLER", None, "Konuşma balonu: ses sayacı ve bekleyen karar (eski bubble)."),
    "product/bug": ("HATA", NEW, "Yalın böcek: kartın hata çipi ve canlı hata sayısı (eski role_test bu işi de görüyordu)."),
}
M_STAKE = {
    "stake/cash_in": ("KAZANÇ", None, "Dolu daire, yukarı ok oyulmuş. Nakit girişi; yeşil boyanır."),
    "stake/cost": ("BEDEL", NEW, "Dolu daire, eksi oyulmuş: indirim, moral düşüşü gibi tehlike olmayan bedel; mürekkep."),
    "stake/equity": ("HİSSE DİLİMİ", None, "Çekilmiş dilim verilen pay; bedel, tehlike değil: mürekkep."),
}
M_UTIL = {
    "util/warn": ("UYARI", "Dolu üçgen, ünlem oyulmuş. Bedelde tehlike işareti de bu (SPEC kural 5)."),
    "util/lock": ("KİLİT", "\"Yapamazsın\"; gerekçe hep yanında."), "util/clock": ("SAAT", "Mesai düğmesi."),
    "util/pause": ("DURAKLAT", "Saat; kalıcı seçim satırı."), "util/play": ("BAŞLAT", "Düzeltme başlat (eski build/decision)."),
    "util/check": ("ONAY", "Bitti, sevk edildi (eski product/tick)."), "util/plus": ("ARTI", "İşe alım başlat."),
    "util/minus": ("EKSİ", "Daralt, azalt."), "util/close": ("KAPAT", "Pencere kapatma; görüşme sonucunda ✕."),
    "util/arrow_right": ("OK", "Devreden kart (eski product/arrow)."), "util/revert": ("GERİ AL", "Varsayılan mesaiye dön."),
    "util/flat": ("DÜZ", "Moral yönü düz."), "util/chevron_up": ("YUKARI", "Moral yönü, sıralama."),
    "util/chevron_down": ("AŞAĞI", "Açılır liste."), "util/chevron_left": ("SOL", "Geri."),
    "util/chevron_right": ("SAĞ", "Satır aç."), "util/search": ("ARA", "Atlas aday arama; kurucunun ofis glifi."),
    "util/filter": ("SÜZ", "Kaydırıcılar; huni Satış'a ayrıldı."), "util/inbox": ("GELEN KUTUSU", "Liste başlığı, boş durum."),
    "util/mail_open": ("OKUNDU", "Açık zarf."), "util/reply": ("CEVAPLA", "Mesaja dön."),
    "util/calendar": ("TAKVİM", "Hafta, son tarih."), "util/news": ("HABER", "Haber şeridi düğmesi; gazete, çentikli."),
    "util/move": ("OFİSİ TAŞI", "Nakliye kamyonu."), "util/shield": ("KALKAN", "Destek evresi (eski build/phase_support)."),
    "util/dice": ("RİSK", "Olasılık; bedelde şans işareti."), "util/star_full": ("YILDIZ", "★ kural birimi."),
    "util/star_half": ("YARIM YILDIZ", "Buçuk."), "util/star_empty": ("BOŞ YILDIZ", "Boş yuva, tonda."),
    "util/tri_up": ("ARTIŞ", "▲ yerine: zar satırı, eğilim."), "util/tri_down": ("AZALIŞ", "▼ yerine."),
    "util/sparkle": ("AYIN OLAYI", "✦ yerine: dönem özetinin olayı."), "util/enter": ("ENTER", "⏎ yerine: görüşme seçeneği."),
    "util/history": ("GEÇMİŞ", "Cevaplanmış olaylar."), "util/info": ("BİLGİ", "Bilgi notu."),
    "util/queue": ("SIRADA", "\"2 karar daha sırada\"."), "util/doc": ("BELGE", "Rapor, dönem özeti; çentikli kâğıt."),
    "util/keyboard": ("KLAVYE", "Kısayol ipucu."), "util/save": ("KAYDET", "Kayıt yuvası."),
    "util/load": ("YÜKLE", "Açık klasör."), "util/menu": ("MENÜ", "Sistem menüsü."),
    "util/language": ("DİL", "Dil seçimi (TR/EN)."),
}
M_WORLD = {
    "world/person_left": ("AYRILDI", "Kişi ve dışarı ok: ayrılan çalışan."),
    "world/seat": ("KOLTUK", "\"{n} koltuk\": B2B lisans koltuğu."),
    "world/milestone": ("KİLOMETRE TAŞI", "Tepeye dikilmiş bayrak: Kişisel'deki Kilometre Taşları, kilometre taşı sonu."),
    "world/shutter": ("KEPENK", "\"KEPENK: {n} HAFTA\": inmekte olan dükkân kepengi."),
    "world/term_sheet": ("TERM SHEET", "İmza satırlı çentikli kâğıt."),
    "world/fund": ("FON", "Sütunlu bina: yatırımcı, VC fonu."),
    "world/runway": ("RUNWAY", "Pist: kasanın kaç ay yettiği."),
    "world/crown": ("TAÇ", "Kurucunun işareti: yolculuk çipleri, kule tacı."),
    "world/training": ("EĞİTİM", "Kep: \"Eğitime gönder\". Gerçek lider'den bu yüzden ayrıldı."),
    "world/raise": ("ZAM", "Finans parası ve yukarı ok: \"Zam kalıcıdır\". Banknotlu aday kamera okunuyordu."),
    "world/map": ("HARİTA", "Katlanmış harita: \"Ofis seç\", şehir haritası."),
}
M_PLACE = {
    "place/home": ("EV", "Ev."), "place/ishani": ("İŞ HANI", "Kemerli kapılı taş han, pencere sıraları."),
    "place/plaza": ("PLAZA KATI", "Pencereli kule, yan bloklar tonda."), "place/loft": ("DEPO LOFT", "Testere çatılı depo."),
}
M_ORIGIN = {
    "origin/self_made": ("SELF-MADE", "Fide: \"Hiçbir şey yoktu. Her satırı ben yazdım.\" Toprak tonda."),
    "origin/heir": ("THE HEIR", "Anahtar: \"Aile sermayesi arkanda.\""),
    "origin/corporate": ("CORPORATE REFUGEE", "Kravat: \"On yıl büyük şirkette. Şimdi kendi adına.\""),
}
UTIL_ORDER = list(M_UTIL)

SENTENCE = {"trait/loyal": "Sadık", "trait/picks_it_up_fast": "Çabuk kapar", "trait/last_one_out": "İşkolik",
            "trait/takes_them_under": "Gerçek lider", "trait/double_checker": "Titiz", "trait/cant_say_no": "Hayır diyemez",
            "trait/bag_packed": "Gözü yüksekte", "trait/mood_buster": "Tat kaçıran", "trait/unspecified": "Belirsiz"}


# ---------------------------------------------------------------- the two earlier rails, for the comparison strip
def _v0():
    sys.path.insert(0, os.path.normpath(os.path.join(HERE, "..", "tools")))
    import icons as v0
    return v0.ICON


def _v1_symbols():
    sys.path.insert(0, os.path.join(HERE, "rounds", "v1"))
    import glyphs_v1 as v1
    attr = {"p": 'fill="none" stroke="currentColor" stroke-width="{w}" stroke-linecap="round" stroke-linejoin="round"',
            "ts": 'fill="none" stroke="currentColor" stroke-opacity="0.4" stroke-width="{w}" stroke-linecap="round" stroke-linejoin="round"',
            "t": 'fill="currentColor" fill-opacity="0.4"', "f": 'fill="currentColor"', "fe": 'fill="currentColor" fill-rule="evenodd"',
            "fp": 'fill="currentColor" stroke="currentColor" stroke-width="{w}" stroke-linecap="round" stroke-linejoin="round"'}

    def conv(mk):
        def rep(m):
            tag, cls, rest = m.group(1), m.group(2), m.group(3)
            w = 2.0
            wm = re.search(r'\s*data-w="([\d.]+)"', rest)
            if wm:
                w = float(wm.group(1)); rest = rest.replace(wm.group(0), "")
            return "<%s %s%s" % (tag, attr[cls].format(w="%g" % w), rest)
        return re.sub(r'<(path|circle|ellipse|rect)\s+class="(\w+)"([^>]*)', rep, mk)
    return "".join('<symbol id="v1-%s" viewBox="0 0 24 24">%s</symbol>' % (k.split("/")[1], conv(v1.G[k]))
                   for k in v1.G if k.startswith("rail/"))


def extra_symbols():
    return _v1_symbols()


RAIL_ORDER = ["rail/product", "rail/sales", "rail/hr", "rail/finance", "rail/personal", "rail/marketing", "rail/rnd",
              "rail/events", "rail/settings"]
RAIL_NAMES = {"rail/product": "Ürün", "rail/sales": "Satış", "rail/hr": "Ekip", "rail/finance": "Finans",
              "rail/personal": "Kişisel", "rail/marketing": "Pazarlama", "rail/rnd": "Ar-Ge", "rail/events": "Olaylar",
              "rail/settings": "Ayarlar"}
V0_NAMES = ["urun", "satis", "ekip", "finans", "kisisel", "pazarlama", "arge", "olaylar", "ayarlar"]


def p1(cell, grid, page, ic):
    rules = '''<div class="rules">
<div class="rule"><b>Dolu şekil, oyulmuş ayrıntı</b>Ana şekil doludur; ayrıntı oyulur ve zemin görünür. Her oyma ve iki parça arası
boşluk 24'te 2 px, 16'da 1,33 px. Çizgi glifleri (chevron, artı, kapat, oklar) 2,6: ofisteki kafa ikonlarıyla aynı kalınlık.</div>
<div class="rule"><b>İki ton</b>Aynı renk, ikinci düzlem %40: arkadaki kişi, boş yarı, gölge yüzü, ikincil parça.
Anlam her zaman dolu şekildedir; ton görünmese de glif okunur.</div>
<div class="rule"><b>Kâğıt çentiği</b>Ailenin imzası: kâğıt olan her nesnenin (zarf, belge, gazete, term sheet, gelen kutusundaki kâğıt)
sağ üst köşesi 45 derece kesik. Masada kâğıt diye okunur; kâğıt satırı ve bedel kutusu için önerilen çentikle aynı kesik.</div>
<div class="rule"><b>Godot</b>Dosyalar #FFFFFF ve yalnız dolgu yolu (fill-rule evenodd); stroke, maske, filtre, CSS yok. Renk modulate ile,
ton fill-opacity 0,4 olarak gelir. Her boy için bir kez rasterlenir (sayfa 4).</div></div>'''
    cells = [cell(k, v[0], v[2], v[1]) for k, v in M_RAIL.items()]
    rows, nrows = [], []
    for k in RAIL_ORDER:
        if k == "rail/settings":
            rows.append('<div style="height:40px"></div>')
            nrows.append('<div style="height:40px"></div>')
        cls = {"rail/hr": "rr on", "rail/finance": "rr hv", "rail/marketing": "rr lk"}.get(k, "rr")
        b = {"rail/sales": '<span class="bdg dg">1</span>', "rail/hr": '<span class="bdg dg">1</span>',
             "rail/rnd": '<span class="bdg ct">2</span>', "rail/events": '<span class="bdg gt"></span>'}.get(k, "")
        lab = '<span class="t">%s</span>' % RAIL_NAMES[k]
        if k == "rail/marketing":
            lab = '<span style="display:flex;flex-direction:column"><span class="t">%s</span><span class="s">Yakında</span></span>' % RAIL_NAMES[k]
        rows.append('<div class="%s">%s%s%s</div>' % (cls, ic(k, 24), lab, b))
        lk = ('<span class="lkg">%s</span>' % ic("util/lock", 12, "var(--ink-4)")) if k == "rail/marketing" else ""
        nrows.append('<div class="%s">%s%s%s</div>' % (cls.replace(" hv", ""), ic(k, 24), b, lk))
    v0 = _v0()
    cmp_cols = []
    for lab, items in (("V0 TASLAĞI", [v0[n].replace("<svg ", '<svg width="24" height="24" ', 1) for n in V0_NAMES]),
                       ("İLK GEÇİŞ", ['<svg width="24" height="24"><use href="#v1-%s"/></svg>' % k.split("/")[1] for k in RAIL_ORDER]),
                       ("BU GEÇİŞ", [ic(k, 24) for k in RAIL_ORDER])):
        cmp_cols.append('<div><div class="col">%s</div><div class="lab">%s</div></div>' % (
            "".join('<span style="color:var(--ink-4)">%s</span>' % s for s in items), lab))
    ctx = ('<h2>Bağlam: ray <span class="n">SPEC kuralıyla: boşta ikon ink-4 ve ad ink-3, seçili ikon ink-2 ve ad ink-1, üstünde durunca '
           'line-hover çerçeve, kilitli ikon ve ad ink-off</span></h2><div class="ctx"><div class="rail">%s</div><div class="nrail">%s</div>'
           '<div class="cmp">%s</div><div class="box" style="flex:1"><div class="cap">Ray için okuma</div>'
           '<p>Dokuz glif dar rayda etiketsiz kalır; siluetleri bu yüzden birbirinden ayrık: küp, huni, iki kişi, iki banknot, tek kişi, '
           'megafon, şişe, zarf, çark. İlk geçişin ince çizgisi rayda v0 taslağından hafif kalıyordu (yandaki üç sütun); dolu dil v0\'ın ağırlığını '
           'geri getiriyor, ama glifler v0\'ın kopyası değil.</p>'
           '<p><b>Rozet kuralı tek:</b> geniş rayda rozet satırın sağında; dar rayda (1536) ikonun sağ üst köşesine taşınır ve satırın '
           'zemin rengiyle 2 px oyuk halka alır (boşta surface-1, seçili surface-4). Glifin üstüne binse de glif kesik okunur, rozetle '
           'kaynaşmaz. Kilitli satırın köşesinde 12 px kilit, ink-4. İlk geçişteki %%45 ve ink-3 kuralı geri çekildi: SPEC\'in ink-off ve '
           'ink-4 kuralı geçerli; noktalar yerine sayılı rozet.</p></div></div>' % ("".join(rows), "".join(nrows), "".join(cmp_cols)))
    return page("Dil ve ray", 1, TOTAL,
                "Menajer Masası'nın kendi ikon ailesi, ikinci geçiş. İlk geçişin ince çizgili iki tonlu ailesi bir yönetim yazılımını "
                "andırıyordu; bu geçişte aile <b>ofis kafa ikonlarının diline</b> taşındı: dolu ana şekil, oyulmuş ayrıntı, 2,6 çizgi. Ofisteki "
                "ikon ile penceredeki ikon artık aynı glif. Her hücrede 4 kat büyütme (24 ızgara; kesikli çizgi 20 px canlı alan), sonra 24, 20 ve "
                "16 px'te pencere gövdesi (surface-3 #1E1B18, ink-2) ve ray (surface-1 #15120F, ink-4) üstünde.",
                rules + '<h2>Ray <span class="n">8 sekme, ayarlar ve isteğe bağlı bir dokuzuncu</span></h2>' + grid(cells, 5) + ctx)


def p2(cell, grid, page, ic):
    sk = [cell(k, v[0], '<b>%s</b>. <span class="gl">%s</span>' % (v[2], v[3]), v[1]) for k, v in M_SKILL.items()]
    dp = [cell(k, v[0], v[1]) for k, v in M_DEPT.items()]
    people = [("ÜRÜN & TASARIM", "dept/product_design", [
                  ("deniz", "Deniz Arslan", "UX/UI Designer", [5, 6, 3, 3, 3, 3], "trait/last_one_out"),
                  ("elif", "Elif Demir", "Ürün Yöneticisi", [7, 6, 4, 4, 4, 4], "trait/takes_them_under")]),
              ("GELİŞTİRME EKİBİ", "dept/development", [
                  ("selin", "Selin Kaya", "Test Mühendisi", [3, 3, 4, 5, 3, 3], "trait/double_checker"),
                  ("mert", "Mert Yıldız", "Yazılım Mühendisi", [4, 4, 8, 7, 4, 4], "trait/loyal")]),
              ("SATIŞ", "dept/sales", [
                  ("burak", "Burak Şahin", "Satış Temsilcisi", [3, 3, 3, 3, 6, 3], "trait/bag_packed")]),
              ("MÜŞTERİ İLİŞKİLERİ", "dept/customer_success", [])]

    def band(v):
        return "var(--skill-%d)" % min(5, (v + 1) // 2)
    skills = ["skill/product", "skill/design", "skill/engineering", "skill/qa", "skill/sales", "skill/customer_success"]
    th = ['<div class="c" style="width:44px"></div><div class="c lbl" style="width:190px;justify-content:flex-start;padding-left:10px">ÇALIŞAN</div>',
          '<div class="span" style="display:flex"><div class="spanlbl">ROLLER</div>%s</div>' % "".join(
              '<div class="c" style="width:48px">%s</div>' % ic(s, 20, "var(--ink-3)") for s in skills),
          '<div class="c lbl" style="width:180px;justify-content:flex-start;padding-left:16px">HUY</div>']
    body = []
    for gname, gic, rows in people:
        body.append('<div class="grp">%s%s</div>' % (ic(gic, 18), gname))
        if not rows:
            body.append('<div class="tr" style="height:44px;border:0;color:var(--ink-3);font-size:15px">Henüz kimse yok</div>')
        for slug, name, role, sk_, tr_ in rows:
            c = ['<div class="c" style="width:44px"><div class="face"><img src="%s/bust64_%s.png"></div></div>' % (ART, slug),
                 '<div class="c" style="width:190px;justify-content:flex-start"><div class="nm2"><b>%s</b><span>%s</span></div></div>' % (name, role)]
            c += ['<div class="c sk" style="width:48px;color:%s">%d</div>' % (band(v), v) for v in sk_]
            c.append('<div class="c huy" style="width:180px;padding-left:16px"><span class="bx">%s</span><span class="tx">%s</span></div>'
                     % (ic(tr_, 16), SENTENCE[tr_]))
            body.append('<div class="tr">%s</div>' % "".join(c))
    table = '<div class="box tb" style="padding:30px 24px 16px">%s%s</div>' % ('<div class="th">%s</div>' % "".join(th), "".join(body))
    side = ('<div class="box"><div class="cap">Beceri ve bölüm ayrımı</div>'
            '<p>Beceri glifi bir yeteneği (aletini) gösterir ve sütun başında 20 px, ink-3 durur. Bölüm glifi bir masayı (ekibi) gösterir ve '
            'grup başlığında 18 px, ink-4 durur. İki aile çakışmaz: Ürün tabela, Ürün & Tasarım ampul; Yazılım ve Test ayraç ve onaylı böcek, '
            'Geliştirme Ekibi terminal; Satış etiket ve çanta; Müşteri İlişkileri kulaklık ve iki balon.</p>'
            '<p><b>Ürün artık tabela.</b> Hedef glifi çeyrek hedefiyle (\"hedef\") çakışıyordu. Tabela yön seçmektir: özellik kararı.</p>'
            '<p><b>Test, onaylı böcek.</b> Sprint kartında yalın böcek hata sayısıdır (product/bug); beceri ise hatayı bulan ve doğrulayan el.</p>'
            '<p>Sprint kartının rol ikonları (role_product, role_design, role_dev, role_test) ayrı dosya olarak kalmaz, beceri glifini okur. '
            'Liderlik sütunu SPEC\'teki gibi metin başlık; ilk geçişteki bayrak Kilometre Taşı\'na geçti.</p>'
            '<p>Yüzler, AD notundaki gibi aydınlık zeminde (ortası line-2, kenarı surface-3, 1 px line-3 kenar): koyu saç kömür zeminde kaybolmuyor.</p></div>')
    return page("Beceri ve bölüm", 2, TOTAL,
                "Altı beceri (anlamlar strings.csv'deki HR_AREA_MEANING satırlarından) ve dört kadro grubu. Altta Ekip tablosunun başlığı ve grup "
                "satırları, v0 seed verisiyle, gerçek büstlerle ve A1'in beceri merdiveniyle.",
                '<h2>Beceri <span class="n">altı sütun başı, sprint kartında rol</span></h2>' + grid(sk, 3)
                + '<h2>Bölüm <span class="n">dört kadro grubu</span></h2>' + grid(dp, 4)
                + '<h2>Bağlam: Ekip tablosu <span class="n">beceri başlığı 20 px, grup 18 px, huy 16 px kutu içinde</span></h2>'
                + '<div style="display:grid;grid-template-columns:770px 1fr;gap:16px">%s%s</div>' % (table, side))


def p3(cell, grid, page, ic):
    cells = []
    for k, lab, en, eff, gl, q, tag in M_TRAIT:
        m = '<b>%s</b> <span class="en">· %s</span><br>%s<br><span class="gl">%s</span>' % (lab, en, eff, gl)
        if q:
            m += '<br><span class="q">%s</span>' % q
        cells.append(cell(k, lab, m, tag))
    col = "".join('<div class="tr" style="gap:10px"><div class="c huy"><span class="bx">%s</span><span class="tx">%s</span></div></div>'
                  % (ic(k, 16), SENTENCE[k]) for k, *_ in M_TRAIT)
    tip = ('<div class="tip"><b>%sGerçek lider</b>Sorumlusu olduğu alanda herkes daha hızlı öğrenir; ayrılıkları ağır alır.</div>'
           % ic("trait/takes_them_under", 16, "var(--ink-2)"))
    ctx = ('<h2>Bağlam: huy sütunu <span class="n">26 px kutu, 16 px glif, etiket her zaman yanında; etki ipucunda</span></h2>'
           '<div style="display:grid;grid-template-columns:300px 380px 1fr;gap:16px;align-items:start">'
           '<div class="box">%s</div><div class="box"><div class="cap">İpucu</div>%s</div>'
           '<div class="box"><div class="cap">Anlam kontrolü</div><p>Huylar iyi ya da kötü değildir; glif hüküm vermez. Hiçbir huy kırmızı '
           'ya da yeşil boyanmaz.</p><p><b>AD notundan sonra üç huy değişti:</b> Gerçek lider şemsiye (kep artık Eğitime gönder\'in), '
           'Hayır diyemez onaylı balon ve biriken kâğıtlar (başparmak hüküm okunuyordu), Gözü yüksekte bavul (basamak terfi okunuyordu). '
           'Turuncu satırlar onayını isteyen anlamlar.</p><p>Kurucu huyları bu turda da çizilmedi, "belirsiz" glifine düşer.</p></div></div>'
           % (col, tip))
    return page("Huy", 3, TOTAL,
                "Sekiz çalışan huyu ve belirsiz. Her hücrenin altında CSV'deki ad, İngilizce ad, etki metni ve glifin söylediği. Turuncu satırlar "
                "onayını isteyen değişiklikler ya da motorda okuyucusu olmayan etkiler.",
                grid(cells, 3) + ctx)


def p4(cell, grid, page, ic):
    pr = [cell(k, v[0], v[2], v[1]) for k, v in M_PRODUCT.items()]
    st = [cell(k, v[0], v[2], v[1]) for k, v in M_STAKE.items()]
    card = ('<div class="card"><div class="k1">%s ARAŞTIRMA<span style="margin-left:auto;display:flex;gap:6px">%s%s</span></div>'
            '<div class="tt">5 kullanıcıyla görüş</div>'
            '<div class="k2">%s%s<span class="chipx vo">%s 3</span><span class="chipx bug">%s 2</span></div></div>'
            % (ic("product/kind_research", 16), ic("skill/product", 16, "var(--ink-3)"), ic("skill/design", 16, "var(--ink-3)"),
               ic("skill/engineering", 16), ic("skill/qa", 16), ic("product/voices", 16, "var(--ink-2)"), ic("product/bug", 16, "var(--neg-ink)")))
    card2 = ('<div class="card"><div class="k1">%s DÜZELTME<span style="margin-left:auto;display:flex;gap:6px">%s</span></div>'
             '<div class="tt">Kayıt akışı düzeltmesi</div><div class="k2">%s%s<span class="chipx vo">%s devreder</span></div></div>'
             % (ic("product/kind_fix", 16), ic("skill/engineering", 16, "var(--ink-3)"), ic("product/kind_feature", 16),
                ic("product/kind_polish", 16), ic("util/arrow_right", 16, "var(--ink-2)")))
    stake = ('<div class="stake"><div class="part"><div class="k">NAKİT</div><div class="v pos">%s+$25K</div></div><span class="dotsep">·</span>'
             '<div class="part"><div class="k">FRANK\'E</div><div class="v">%s%%4</div></div><span class="dotsep">·</span>'
             '<div class="part"><div class="k">MORAL</div><div class="v">%s8</div></div></div>'
             '<div class="stake" style="margin-top:10px"><div class="part"><div class="k">KASA</div><div class="v neg">%s−$12K</div></div>'
             '<span class="dotsep">·</span><div class="part"><div class="k">ŞANS</div><div class="v">%s%%40</div></div></div>'
             % (ic("stake/cash_in", 32, "var(--pos)"), ic("stake/equity", 32, "var(--ink-2)"), ic("stake/cost", 32, "var(--ink-2)"),
                ic("util/warn", 32, "var(--neg)"), ic("util/dice", 32, "var(--ink-2)")))
    sizes = ('<div class="box"><div class="cap">Godot\'ta boy ve raster (Faz B\'de doğrulanacak)</div>'
             '<p>Kullanılan boylar: 12 yalnız düz işaretler (oynat, kilit köşesi, chevron); 16 huy, sprint kartı, satır içi; 18 bölüm, birincil artı, '
             'saat; 20 beceri başlığı, kapat, haber; 22 ile 24 uyarı ve ray; 32 bedel (36 px rakamın yanında; 28 px glif rakamdan küçük kalıyor).</p>'
             '<p>Godot SVG\'yi içe aktarırken bir kez rasterler ve TextureRect onu mipmapsiz küçültür; 24\'lük dokuyu 16\'da çizmek oymaları '
             'kapatır. Öneri: ikon ve boy başına bir kez Image.load_svg_from_string(svg, px / 24.0) ile ImageTexture üretip tek evde (UiFactory) '
             'önbelleğe almak. Sprint kartının 12 px ikonları (PRODUCT_ICON_PX) 16\'ya çıkmalı.</p></div>')
    return page("Ürün ve bedel", 4, TOTAL,
                "Sprint kartı türleri, ses sayacı ve hata, sonra karar bedelinin glifleri. SPEC kural 5 ile aynı: kazanç yukarı ok (yeşil), "
                "bedel eksi ya da dilim (mürekkep), tehlike üçgen (kırmızı), şans zar. Eski ayrı nakit çıkışı glifi kalktı: eksi nakit tehlikedir, üçgen taşır.",
                '<h2>Ürün <span class="n">dört kart türü, sesler, hata</span></h2>' + grid(pr, 3)
                + '<h2>Bedel <span class="n">karar seçeneğinin en büyük verisi</span></h2>' + grid(st, 3)
                + '<h2>Bağlam <span class="n">sprint kartı 16 px, bedel kutusu 32 px</span></h2>'
                + '<div style="display:grid;grid-template-columns:316px 640px 1fr;gap:16px;align-items:start">'
                + '<div style="display:flex;flex-direction:column;gap:10px">%s%s</div><div>%s</div>%s</div>' % (card, card2, stake, sizes))


def p5(cell, grid, page, ic):
    ut = [cell(k, M_UTIL[k][0], M_UTIL[k][1], NEW if k in NEW_UTIL else None) for k in UTIL_ORDER]
    return page("Yardımcı", 5, TOTAL,
                "Arayüzün yardımcı glifleri. YENİ işaretliler bu geçişte eklendi: A1 sayfalarının taslak glifleri (geçmiş, bilgi, sıra, belge, klavye, "
                "kaydet), Noto kalkınca yazı tipinde olmayan semboller (▲ ▼ ✦ ⏎) ve AD listesindeki eksikler. Süzgeç artık kaydırıcı; huni Satış'ın.",
                grid(ut, 5))


NEW_UTIL = {"util/tri_up", "util/tri_down", "util/sparkle", "util/enter", "util/history", "util/info", "util/queue", "util/doc",
            "util/keyboard", "util/save", "util/load", "util/menu", "util/language", "util/filter"}


def p6(cell, grid, page, ic):
    w = [cell(k, v[0], v[1], NEW) for k, v in M_WORLD.items()]
    pl = [cell(k, v[0], v[1], NEW) for k, v in M_PLACE.items()]
    og = [cell(k, v[0], v[1], NEW) for k, v in M_ORIGIN.items()]
    noto = ('<table class="tbl"><tr><th>Sembol</th><th>Bugün nerede</th><th>Karar</th><th>İkon</th></tr>'
            '<tr><td class="big">★</td><td><code>star_rating.gd:16</code> beş glif, yarım kırpma ile; <code>sprint_catalog.gd:16</code>; '
            '<code>sales_ledger.gd:399</code>; CSV <code>SALES_BAND_STAR</code> "{n}★"</td><td>StarRating beş TextureRect çizer, yarım için star_half; '
            'metindeki "{n}★" RichTextLabel [img] ile</td><td><span class="icn">%s%s%s</span></td></tr>'
            '<tr><td class="big">▲ ▼</td><td><code>dice.gd:65</code> zar satırı işareti; <code>finance_ozet_view.gd:569</code> eğilim</td>'
            '<td>Kod metne sembol koymaz, etiketin yanına ikon koyar; CSV değişmez</td><td><span class="icn">%s%s</span></td></tr>'
            '<tr><td class="big">✦</td><td>CSV <code>MONTH_EVENT_OF_THE_MONTH</code>, <code>SUMMARY_EVENT_WEEK / QUARTER / YEAR</code> "✦ AYIN OLAYI"</td>'
            '<td>Sembol metinden çıkar, etiket önüne ikon gelir; dört satır TR/EN onayı ister</td><td><span class="icn">%s</span></td></tr>'
            '<tr><td class="big">⏎</td><td><code>meeting_panel.gd:57</code> ENTER_MARK</td><td>Seçenek etiketinin sağında ikon</td><td><span class="icn">%s</span></td></tr>'
            '<tr><td class="big">✕</td><td><code>meeting_panel.gd:55</code> RESULT_GLYPHS negatif</td><td>Sonuç renginde 16 px ikon; ✓ Plex\'te var, '
            'simetri için o da ikon olabilir</td><td><span class="icn">%s%s</span></td></tr>'
            '<tr><td class="big">⋯</td><td>Bugün kullanılmıyor (yalnız bir smoke yorumunda)</td><td>Yapılacak bir şey yok</td><td></td></tr>'
            '</table>' % (ic("util/star_full", 16), ic("util/star_half", 16), ic("util/star_empty", 16), ic("util/tri_up", 16, "var(--pos)"),
                          ic("util/tri_down", 16, "var(--neg)"), ic("util/sparkle", 16), ic("util/enter", 16), ic("util/close", 16, "var(--neg)"),
                          ic("util/check", 16, "var(--pos)")))
    inl = ('<div style="display:flex;flex-wrap:wrap;gap:10px;margin-top:12px">'
           '<span class="inl">%sAYIN OLAYI</span><span class="inl sans">Satış bandı 3%s</span>'
           '<span class="inl sans">%s +%%12</span><span class="inl sans">Kabul et%s</span></div>'
           % (ic("util/sparkle", 14, "var(--ink-2)"), ic("util/star_full", 14), ic("util/tri_up", 12, "var(--pos)"), ic("util/enter", 14, "var(--ink-3)")))
    chips = ('<div style="display:flex;flex-wrap:wrap;gap:10px">%s</div>' % "".join(
        '<span class="mapchip%s">%s%s</span>' % (" on" if k == "place/ishani" else "", ic(k, 20), n)
        for k, n in (("place/home", "Ev"), ("place/ishani", "İş hanı"), ("place/plaza", "Plaza katı"), ("place/loft", "Depo loft"))))
    origs = '<div style="display:flex;gap:10px">%s</div>' % "".join(
        '<div class="orig">%s<b>%s</b><span>%s</span></div>' % (ic(k, 40), n, q) for k, n, q in (
            ("origin/self_made", "Self-Made", "Hiçbir şey yoktu. Her satırı ben yazdım."),
            ("origin/heir", "The Heir", "Aile sermayesi arkanda. Ama gözler de üzerinde."),
            ("origin/corporate", "Corporate Refugee", "On yıl büyük şirkette. Şimdi kendi adına.")))
    return page("Dünya, yer, köken", 6, TOTAL,
                "AD'nin eksik listesindeki kavramlar: ayrılan kişi, koltuk, kilometre taşı, kepenk, term sheet, fon, runway, taç, eğitim, zam, harita; "
                "dört ofis yeri ve üç köken. Altta Noto Symbols 2 kalkınca yazı tipinde olmayan sembollerin dökümü.",
                '<h2>Dünya <span class="n">oyunun kavramları</span></h2>' + grid(w, 4)
                + '<h2>Yer ve köken <span class="n">harita çipi, ofis kartı, açılış kartı</span></h2>' + grid(pl + og, 4)
                + '<div style="display:grid;grid-template-columns:1fr 520px;gap:16px;margin-top:16px">'
                + '<div class="box"><div class="cap">Noto Symbols 2 kalkınca: sembolden ikona</div>%s%s</div>' % (noto, inl)
                + '<div style="display:flex;flex-direction:column;gap:16px"><div class="box"><div class="cap">Harita çipleri</div>%s</div>'
                  '<div class="box"><div class="cap">Köken kartı (40 px)</div>%s</div></div></div>' % (chips, origs))


def p7(cell, grid, page, ic):
    names = {"code": "Kod", "design": "Tasarım", "test": "Test", "research": "Araştırma / plan", "phone": "Telefon",
             "meeting": "Toplantı / ziyaret", "coffee": "Kahve", "food": "Yemek", "wc": "WC"}
    big = "".join('<figure><img src="icons/office/%s.svg" width="96" height="96"><img src="icons/office/%s.svg" width="40" height="40">'
                  '<img src="icons/office/%s.svg" width="26" height="26"><figcaption>%s</figcaption></figure>' % (n, n, n, names[n])
                  for n in HEAD_ORDER)
    labels = (("ÖNERİLEN", "Çalışan koyu disk; molada disk krem, glif koyu."),
              ("İLK GEÇİŞ", "Koyu disk; molada renkli halka (dört renk)."),
              ("BUGÜN", "Lucide türevi, açık disk."))
    lab = "".join('<div class="hl"><b>%s</b><span>%s</span></div>' % l for l in labels)
    comp = ('<div class="box"><div class="cap">Oyunun kendi render\'ında, gerçek kafa konumu ve boyunda, 1:1. Solda iş hanı (32 px), sağda depo loft '
            '(26 px). Kahve, toplantı, WC ve yemek mola; ötekiler iş.</div><div style="display:flex;gap:16px;align-items:flex-start">'
            '<img src="icons/review/heads_office.png" width="856" height="932" style="display:block;border-radius:4px">'
            '<div class="hls">%s</div><div><img src="icons/review/heads_zoom.png" width="460" height="616" style="display:block;border-radius:4px">'
            '<p style="margin-top:10px">Önerilen satır 2 kat büyütülmüş: üstte iş hanı, altta depo loft.</p></div></div></div>' % lab)
    theme = ('<div class="box"><div class="cap">Tema SVG\'leri, koyu</div>'
             '<div class="set"><span>Müzik</span><span class="grow"></span><span class="track"><span class="fill"></span><img src="icons/theme/slider_grabber.svg" width="24" height="24"></span></div>'
             '<div class="set"><span>Kapalı ayar</span><span class="grow"></span><img src="icons/theme/switch_off.svg" width="40" height="22"></div>'
             '<div class="set" style="border:0"><span>Açık ayar</span><span class="grow"></span><img src="icons/theme/switch_on.svg" width="40" height="22"></div>'
             '<p style="margin-top:10px">Açık anahtar mürekkep, amber değil: seçili durum mürekkeptir, amber dolgu yalnız birincil eylemde. Renkler '
             'dosyaya gömülü (surface-5 iz, line-2 kenar, ink-2 ve ink-4 düğme).</p></div>')
    note = ('<div class="box"><div class="cap">Kafa ikonları için kararlar</div>'
            '<p><b>Glifler arayüzle aynı dosyadan:</b> kod ayracı, kalem ucu, onaylı böcek, büyüteç, iki kişi. Ofiste görülen glif pencerede aynı '
            'anlamı taşır.</p>'
            '<p><b>Mola, disk ters döner:</b> çalışan kişinin diski koyu (surface-3), molada (kahve, yemek, toplantı, WC) disk krem ve glif koyu. '
            'Ofise bakınca kim çalışıyor, kim molada tek bakışta ayrılıyor ve dört renkli halka gerekmiyor; ilk geçişin halka renkleri pos ve warn '
            'tonlarını yankılıyordu. Renkler sahne verisidir: OfficeConstants\'ta HEAD_DISC, HEAD_EDGE, HEAD_GLYPH ve HEAD_BREAK_DISC, '
            'HEAD_BREAK_EDGE, HEAD_BREAK_GLYPH adlarıyla durmalı.</p>'
            '<p>Dosya biçimi bugünküyle aynı (128 × 128, disk ve gölge dahil); office_actor.gd değişmez. "plan" (kurucu) ve "visit" bugünkü gibi '
            'büyüteç ve iki kişiyi okur.</p></div>')
    return page("Ofis kafa ikonları ve tema", 7, TOTAL,
                "Dokuz kafa ikonu (Sprite3D), 96, 40 ve 26 px; sonra oyunun kendi render'ında. Ve kaydırıcı ile anahtarın koyu sürümleri.",
                '<h2>Kafa ikonları <span class="n">ofis zemini renginde</span></h2><div class="floor"><div class="heads">%s</div></div>' % big
                + '<h2>Ofiste</h2>' + comp
                + '<div style="display:grid;grid-template-columns:1fr 520px;gap:16px;margin-top:16px">%s%s</div>' % (note, theme))


def p8(cell, grid, page, ic):
    return page("Godot'ta doğrulama", 8, TOTAL,
                "Aynı 98 dosya Godot 4.6.2'nin kendi SVG yükleyicisiyle (Image.load_svg_from_string, ThorVG) 96, 24, 20 ve 16 px'te "
                "rasterlendi; glif rengi #E9E4DA, zemin #1E1B18, 1:1. Oymalar, ton ve evenodd Chrome'daki gibi çıkıyor; hiçbir dosya hata vermedi. "
                "Betik: icons/godot_check.gd.",
                '<img src="icons/review/godot_sheet.png" width="1540" height="1008" style="display:block;border-radius:4px">')


def all_pages(cell, grid, page, ic):
    return CSS2, "".join(f(cell, grid, page, ic) for f in (p1, p2, p3, p4, p5, p6, p7, p8))
