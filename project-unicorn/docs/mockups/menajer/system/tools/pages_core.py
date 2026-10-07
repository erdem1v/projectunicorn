"""Sheet pages 1 to 9: palette, type, controls, data, inbox, decision, shell, colour-blind, layout."""
import re

import common
from common import T, ic, avatar, portrait, hx, cr, STD, ALT, ROOT, CSS_TOKENS, ART
from kit import (tag, pill, stamp, mor, xp, trait, fx, opt, opt_armed, stake_frank, topbar, rail, ticker, buildhud,
                 notice, toast, ekip_window, ekip_table, ekip_row, PEOPLE, TRAITS, WID, ib_row, olay_window,
                 tb_week_bar_len)

TOTAL = 15   # pages in the main sheet (set by build_components)


def page(no, title, sub, body, attrs=""):
    return ('<section class="page" %s><div class="doc-h"><span class="no t-label">%s/%d</span><span class="t t-h2">%s</span>'
            '<span class="s t-meta">%s</span></div><div class="doc-mark t-micro" lang="tr">Menajer Masası · tasarım sistemi · A1 rev 2</div>%s</section>'
            % (attrs, no, TOTAL, title, sub, body))


# ------------------------------------------------------------------ page 1: palette
def sw_row(name, sub, extra="", h=44):
    return ('<div class="sw-row" style="height:%dpx"><span class="sw" style="background:var(%s)"></span><div class="sw-txt"><span class="sw-n">%s</span>'
            '<span class="sw-m">%s · %s%s</span></div></div>' % (h, name, name[2:], hx(name), sub, extra))


def paper_band():
    """The newspaper island at the static faces Godot ships: Source Serif 4 at opsz 20 everywhere (review finding 24)."""
    sheet = ('<div style="width:820px;height:204px;background:var(--paper-bg);border:1px solid var(--paper-edge);border-radius:2px;padding:12px 24px;flex:none" class="paper">'
             '<div style="display:flex;justify-content:space-between;align-items:baseline">'
             '<span style="font-family:var(--f-sansc);font-weight:400;font-size:12px;line-height:17px;letter-spacing:1px;color:var(--paper-ink-meta)" lang="tr">HAFTA 14 · NİSAN 2026 · SAYI 3</span>'
             '<span style="font-family:var(--f-serif);font-variant-caps:all-small-caps;font-size:14px;line-height:17px;letter-spacing:1px;color:var(--paper-ink-meta)">Hafta 14 · Nisan 2026 · Sayı 3</span></div>'
             '<div style="font-family:var(--f-serif);font-weight:600;font-size:52px;line-height:64px;color:var(--paper-ink-mast);text-align:center;border-bottom:2px solid var(--paper-rule)">EKONOMİ POSTASI</div>'
             '<div style="font-family:var(--f-serif);font-weight:600;font-size:32px;line-height:42px;color:var(--paper-ink);margin-top:8px">Unicorn Inc. Series A Turunu Kapattı</div>'
             '<div style="font-family:var(--f-serif);font-style:italic;font-size:16px;line-height:22px;color:var(--paper-ink-deck);margin-top:4px">"Temiz bir tur; kurucu masaya sağlam oturmuş." değerlendirmesi yatırım çevrelerinde dolaşıyor.</div>'
             '</div>')
    sw = "".join('<div class="sw-row" style="height:28px"><span class="sw" style="width:40px;height:20px;background:var(%s)"></span><span class="sw-m">%s %s · %s</span></div>'
                  % (n, n[2:], hx(n), (cr(n, "--paper-bg") + ":1") if n != "--paper-bg" else "zemin")
                  for n in ("--paper-bg", "--paper-ink", "--paper-ink-body", "--paper-ink-deck", "--paper-ink-meta", "--paper-rule"))
    note = ('<div class="note" style="max-width:520px;font-size:14px;line-height:21px;color:var(--ink-3)">Gazete son ekranında krem kalır (tek diegetik ada); '
            'çevresindeki ray ve düğmeler koyu dile geçer. Yüzler Godot\'nun taşıdığı statik dosyalar: Source Serif 4 Regular, Semibold ve It '
            '(hepsi opsz 20; burada da 20\'ye sabit, değişken opsz kullanılmadı). Manşet 600 52, başlık 600 32, spot italik 16, gövde 15, meta 12. '
            'Meta satırı mono\'dan çıkar: önerilen <b>IBM Plex Sans Condensed 12, büyük harf, iz +1</b> (solda); seçenek Source Serif küçük büyük harf (sağda). '
            'Meta mürekkebi 2,9:1\'den 4,8:1\'e koyulaştı.</div>')
    return ('<div class="abs" style="left:48px;top:800px;width:1824px"><div class="cap t-label">Gazete adası (son ekranı)</div>'
            '<div style="display:flex;gap:24px;align-items:flex-start">%s<div style="display:flex;flex-direction:column">%s</div>%s</div></div>' % (sheet, sw, note))


def p1():
    surf = [("--surface-0", "zemin, şerit, ipucu"), ("--surface-1", "kabuk: üst bar ve ray"), ("--surface-2", "pencere içi sütun, alan"),
            ("--surface-3", "pencere gövdesi"), ("--surface-4", "başlık, seçili, kutu, menü"), ("--surface-5", "kontrol dolgusu")]
    col_a = '<div class="cap t-label">Yüzeyler</div>' + "".join(
        sw_row(n, r, " · ink-2 %s · ink-3 %s" % (cr("--ink-2", n), cr("--ink-3", n))) for n, r in surf)
    lines = [("--line-1", "kural, satır ayracı"), ("--line-2", "bileşen kenarı"), ("--line-3", "güçlü kenar, etiket, avatar çemberi"),
             ("--line-hover", "üstünde: kenar, %s:1" % cr("--line-hover", "--surface-3")), ("--focus", "odak halkası (ink-1), 2 px, 2 px boşluk")]
    col_a += '<div class="cap t-label" style="margin-top:12px">Çizgiler ve durum</div>' + "".join(sw_row(n, r) for n, r in lines)
    col_a += ('<div class="cap t-label" style="margin-top:12px">Portre zemini ve masa dili</div>'
              '<div style="display:flex;gap:16px;align-items:center">'
              '<span class="av av-48" style="flex:none"></span>%s'
              '<div class="sw-txt"><span class="sw-n">portrait-lit, portrait-edge</span><span class="sw-m">%s → %s · çizgili yüz için ışıklı zemin</span></div></div>'
              '<div style="display:flex;gap:16px;align-items:center;margin-top:10px"><span class="stamp t-stamp" style="flex:none">Cevaplandı</span>'
              '<span style="flex:none;width:72px;height:36px;background:var(--surface-4);border:1px solid var(--line-2)" class="doc"></span>'
              '<div class="sw-txt"><span class="sw-n">stamp · cut %s</span><span class="sw-m">damga ink-3, 2 px · belge köşesi pahı</span></div></div>'
              % (avatar("burak", 48), hx("--portrait-lit"), hx("--portrait-edge"), ROOT["--cut"][0]))

    inks = [("--ink-1", "vurgu: KASA, başlık, isim", "Unicorn Inc. $10.000"), ("--ink-2", "ana metin", "Yapımda görev alıyor"),
            ("--ink-3", "ikincil, anahtar, sütun, boşta ikon", "Aylık maaş yükü"), ("--ink-4", "üçüncül, raydaki kilit gerekçesi", "Yakında")]
    col_b = '<div class="cap t-label">Mürekkep (pencere gövdesinde)</div><div class="pane-demo" style="padding:6px 16px">'
    for n, r, smp in inks:
        col_b += ('<div class="sw-row" style="height:36px"><span class="t-body-strong" style="color:var(%s);width:210px">%s</span>'
                  '<span class="sw-m">%s %s · %s:1 · %s</span></div>' % (n, smp, n[2:], hx(n), cr(n, "--surface-3"), r))
    col_b += ('<div class="sw-row" style="height:36px"><span style="display:flex;align-items:center;gap:8px;width:210px">%s'
              '<span class="t-subhead" style="color:var(--ink-off)">Reddet</span></span><span class="sw-m">ink-off %s · %s:1 · kapalı öğe, muaf; gerekçe değil</span></div></div>'
              % (ic("lock", 18, "var(--ink-off)"), hx("--ink-off"), cr("--ink-off", "--surface-3")))
    col_b += ('<div class="cap t-label" style="margin-top:14px">Vurgu: tek iş</div>'
              '<div style="display:flex;gap:10px;align-items:center">'
              '<span class="btn btn-primary">%sİşe alım başlat</span><span class="btn btn-primary is-hover">Üstünde</span>'
              '<span class="btn btn-primary is-pressed">Basılı</span>'
              '<span style="display:flex;align-items:center;gap:12px;padding:0 16px;height:40px;background:var(--surface-1);box-shadow:inset 0 0 0 2px var(--accent)">'
              '<span class="gate-dot"></span><span class="t-gate" style="color:var(--accent)">Cevap bekliyor</span></span>'
              '<span class="spd-k is-on" style="width:40px">II</span></div>'
              '<div class="note" style="margin-top:8px">accent %s · üstünde %s · basılı %s · üstündeki yazı %s (%s:1). '
              '<b>Dolgu</b> yalnız ekrandaki tek birincil eylem; çok seçenekli kararda yalnız oyuncu bir seçeneği kurunca. <b>Çerçeve ve yazı</b> yalnız saat durumu.</div>'
              % (ic("plus"), hx("--accent"), hx("--accent-hover"), hx("--accent-pressed"), hx("--on-accent"), cr("--on-accent", "--accent")))
    sem = [("--pos", "kazanç, Artıda, moral 50+", "+$2,5K"), ("--neg", "yalnız tehlike", "−$4.200"),
           ("--warn", "dikkat: moral 35-49, son hafta", "Moral 38"), ("--info", "nötr bildirim noktası", "Rapor")]
    col_b += '<div class="cap t-label" style="margin-top:14px">Anlam: standart ve renk körü ikizi</div><div class="pane-demo" style="padding:4px 16px">'
    for n, r, smp in sem:
        col_b += ('<div class="sw-row" style="height:38px"><span class="sw" style="width:24px;height:24px;background:var(%s)"></span>'
                  '<span class="sw" data-palette="cb" style="width:24px;height:24px;background:var(%s)"></span>'
                  '<span class="t-body-strong" style="color:var(%s);width:96px">%s</span><span class="t-body-strong" data-palette="cb" style="color:var(%s);width:96px">%s</span>'
                  '<span class="sw-m" style="white-space:normal">%s %s / %s · %s</span></div>'
                  % (n, n, n, smp, n, smp, n[2:], hx(n), hx(n, ALT), r))
    col_b += ('</div><div class="note" style="margin-top:8px">Kırmızı yalnız tehlike: eksi kasa, ayrılık, kepenk, müşteri kaybı. Hisse bedeli mürekkeple yazılır. '
              'Renk körü kipinde uyarı açık sarı, olumsuz cıva turuncusu, bilgi açık mavi (artık okunmamış noktasıyla aynı değil).</div>')
    col_b += ('<div class="cap t-label" style="margin-top:14px">Veri görselleştirme</div><div style="display:flex;gap:6px;align-items:center">%s</div>'
              '<div class="note" style="margin-top:6px">ızgara · eksen · seri · tahmin · sıfır altı · iz · dolgu · vurgu: tek renk ailesi; kırmızı yalnız sıfırın altı.</div>'
              % "".join('<span class="sw" style="width:28px;height:20px;background:var(%s)"></span>' % n
                        for n in ("--chart-grid", "--chart-axis", "--chart-line", "--chart-proj", "--chart-neg-area", "--bar-track", "--bar-fill", "--bar-emph")))

    ramp = '<div class="cap t-label">Beceri rampası: parlaklık değerle artar</div>'
    for label, attr, pal in (("standart", "", STD), ("renk körü", ' data-palette="cb"', ALT)):
        big = "".join('<div style="display:flex;flex-direction:column;align-items:center;width:58px"><span class="t-value" style="font-weight:700;color:var(--skill-%d)">%s</span>'
                      '<span class="sw-m" style="font-size:12px;line-height:17px">%s</span></div>' % (i + 1, t, hx("--skill-%d" % (i + 1), pal))
                      for i, t in enumerate(["1-2", "3-4", "5-6", "7-8", "9-10"]))
        grey = "".join('<span class="t-value" style="font-weight:700;width:30px;text-align:center;color:var(--skill-%d)">%d</span>' % (i + 1, i * 2 + 2)
                       for i in range(5))
        ramp += ('<div style="display:flex;align-items:center;gap:10px;margin-bottom:8px"%s><span class="sw-m" style="width:64px">%s</span>'
                 '<div class="pane-demo" style="display:flex;padding:6px 4px">%s</div>'
                 '<div class="pane-demo" style="display:flex;padding:6px 4px;height:56px;align-items:center;filter:grayscale(1)">%s</div></div>'
                 % (attr, label, big, grey))
    ramp += ('<div class="note">Sağda gri kopya: renk gidince sıra kalır. 1-2 rol bandında %s:1, seçili satırın bandında %s:1. '
             'Ana beceri kalın ve altı çizili, ikincil yarı kalın; lejant ikisini de yazar.</div>'
             % (cr("--skill-1", ("--role-band", "--surface-3")), cr("--skill-1", ("--role-band", "--surface-4"))))
    topics = ["mentor", "customer", "team", "product", "funding", "market", "agenda"]
    ramp += '<div class="cap t-label" style="margin-top:12px">Konu etiketleri (EVENT_TAG_* ve YATIRIM)</div>'
    for attr in ("", ' data-palette="cb"'):
        ramp += ('<div style="display:flex;gap:7px;align-items:center;padding:8px 12px;background:var(--surface-2);border-radius:4px;margin-bottom:6px"%s>%s'
                 '<span class="sw-m" style="margin-left:auto">%s</span></div>'
                 % (attr, "".join(pill(k) for k in topics), "renk körü" if attr else "standart"))
    ramp += ('<div class="note">ÜRÜN artık adaçayı (%s): limon 7-8 beceri rengiyle 4,3 ΔE çakışıyordu, şimdi en yakın komşusuna 15 ΔE. '
             'GÜNDEM nötr; EŞİK ve ATLAS hatırlatıcıları renksiz anahat etiketi.</div>' % hx("--topic-product"))
    ramp += '<div class="cap t-label" style="margin-top:12px">Yayınlar (WORLD_OUTLET_*)</div>'
    for attr in ("", ' data-palette="cb"'):
        ramp += ('<div style="display:flex;gap:20px;align-items:center;height:32px;padding:0 12px;background:var(--surface-0);border:1px solid var(--line-1);border-radius:4px;margin-bottom:6px"%s>'
                 '<span class="tk-pub sektor t-meta">Sektör Telgrafı</span><span class="tk-pub ekonomi t-meta">Ekonomi Postası</span>'
                 '<span class="tk-pub teknogundem t-meta">TeknoGündem</span><span class="tk-pub girisim t-meta">Girişim Bülteni</span></div>' % attr)
    ramp += ('<div class="cap t-label" style="margin-top:12px">Ofis örtüleri</div><div style="display:flex;gap:10px">'
             '<div style="position:relative;width:176px;height:76px;border-radius:4px;overflow:hidden"><div class="office" style="background-image:url(%s/office_game.png);background-position:62%% 40%%"></div></div>'
             '<div style="position:relative;width:176px;height:76px;border-radius:4px;overflow:hidden"><div class="office is-dimmed" style="background-image:url(%s/office_game.png);background-position:62%% 40%%"></div></div>'
             '<div style="position:relative;width:176px;height:76px;border-radius:4px;overflow:hidden"><div class="office" style="background-image:url(%s/office_game.png);background-position:62%% 40%%"></div><div class="scrim"></div></div></div>'
             '<div class="note" style="margin-top:6px">ofis · pencere açıkken çarpan %s (self_modulate) · gerçek modalın perdesi %s</div>'
             % (ART, ART, ART, ROOT["--dim"][0], ROOT["--scrim"][0]))
    body = ('<div class="abs" style="left:48px;top:92px;width:560px">%s</div>'
            '<div class="abs" style="left:640px;top:92px;width:640px">%s</div>'
            '<div class="abs" style="left:1324px;top:92px;width:548px">%s</div>%s' % (col_a, col_b, ramp, paper_band()))
    return page("1", "Renk", "Rol adlı token'lar, standart ve renk körü ikizi. Oranlar tools/contrast.py ile hesaplandı.", body)


# ------------------------------------------------------------------ page 2: type
TYPE_ROWS_COND = [
    ("t-h1", "Ekip", "pencere başlığı"), ("t-h2", "Frank'in teklifi", "mesaj başlığı; büyük harfe çevrilmez"),
    ("t-cta", "Kabul et", "büyük birincil düğme"), ("t-subhead", "Unicorn Inc.", "şirket adı, seçenek etiketi"),
    ("t-button", "İşe alım başlat", "düğme, cümle düzeni"), ("t-tab", "Kadro", "bölüm sekmesi"),
    ("t-gate", "Cevap bekliyor", "saat durumu"), ("t-button-sm", "Düzeltme başlat", "küçük düğme"),
    ("t-nav", "Satış", "ray satırı"), ("t-group", "Geliştirme Ekibi", "tablo grubu"),
    ("t-label", "Aylık maaş yükü", "KPI anahtarı, sütun başı"), ("t-stamp", "Cevaplandı", "damga, -3 derece"),
    ("t-tag", "Ayrılabilir", "etiket, konu hapı"), ("t-micro", "Bootstrap", "evre, ikinci satır anahtarı, Yakında"),
]
TYPE_ROWS_SANS = [
    ("t-stake", "+$25K", "bedel satırı: ekrandaki en büyük veri"), ("t-hero", "$10.000", "KASA, tek kahraman"),
    ("t-kpi", "$43.600", "KPI değeri, kurulmuş seçeneğin bedeli"), ("t-clock", "11:00", "saat"), ("t-value", "$4,0K", "üst bar değeri"),
    ("t-body-strong", "Büyüme talebi masada", "mesaj konusu, gönderen"), ("t-body", "Hafta 14 · Nisan 2026", "tarih, gövde"),
    ("t-skill", None, "beceri hücresi: ana 700 ve çizgi, ikincil 600"), ("t-data-strong", "Selin Kaya", "satırdaki isim"),
    ("t-data-med", "+$2,5K", "NET, ikinci satır değeri"), ("t-data", "$11.200", "tablo verisi"),
    ("t-cdata", "Yapımda görev alıyor", "dar sütun verisi (Condensed)"),
    ("t-key", "Nakit", "bedel anahtarı, Sıradaki satırı"), ("t-meta", "Karar · Hafta 14 · Nisan 2026", "önizleme, üst satır (cümle düzeni)"),
    ("t-caption", "Frank Köseoğlu", "gönderen, ipucu, gün ayracı"), ("t-ccaption", "UX/UI Designer", "rol unvanı, huy etiketi"),
    ("t-badge", "1", "rozet sayısı"), ("t-small", "08:00", "hafta çubuğu saatleri"),
]


def spec_of(cls):
    m = re.search(r"^\.%s\s*\{([^}]*)\}" % re.escape(cls), CSS_TOKENS, re.M)
    body = dict((k.strip(), v.strip()) for k, v in (d.split(":", 1) for d in m.group(1).split(";") if ":" in d))
    fam = {"var(--f-cond)": "Barlow Condensed", "var(--f-sans)": "IBM Plex Sans", "var(--f-sansc)": "Plex Sans Condensed",
           "var(--f-serif)": "Source Serif 4"}[body["font-family"]]
    size = ROOT[body["font-size"][4:-1]][0]
    lh = ROOT[body["line-height"][4:-1]][0]
    track = "+1" if "track-caps" in body["letter-spacing"] else "0"
    case = "BÜYÜK" if body.get("text-transform") == "uppercase" else "olduğu gibi"
    return "%s %s · %s/%s · iz %s · %s" % (fam, body["font-weight"], size.replace("px", ""), lh.replace("px", ""), track, case)


def type_rows(rows):
    out = []
    for cls, sample, use in rows:
        if sample is None:
            sample = ('<span style="display:inline-flex;gap:18px"><span class="sk v4 is-main" style="height:24px;width:22px">7</span>'
                      '<span class="sk v3 is-sec" style="height:24px;width:22px">6</span><span class="sk v2" style="height:24px;width:22px">4</span></span>')
        style = "transform:rotate(-3deg);display:inline-flex" if cls == "t-stamp" else ""
        inner = ('<span class="stamp t-stamp">%s</span>' % sample) if cls == "t-stamp" else sample
        out.append('<div style="display:flex;align-items:center;gap:16px;min-height:34px;padding:2px 0;border-bottom:1px solid var(--line-1)">'
                   '<span class="%s" style="width:330px;flex:none;color:var(--ink-1);white-space:nowrap">%s</span>'
                   '<div style="display:flex;flex-direction:column"><span class="t-caption" style="color:var(--ink-2)">.%s · %s</span>'
                   '<span class="t-caption" style="color:var(--ink-3)">%s</span></div></div>'
                   % ("" if cls == "t-stamp" else cls, inner, cls, use, spec_of(cls)))
    return "".join(out)


def p2():
    left = ('<div class="cap t-label">Barlow Condensed: başlık, gezinme, etiket</div>%s'
            '<div class="cap t-label" style="margin-top:12px">Source Serif 4: yalnız Frank\'in sözleri (ve gazete)</div>'
            '<div style="display:flex;gap:16px;padding:6px 0;border-bottom:1px solid var(--line-1)"><span class="t-quote" style="width:330px;flex:none;color:var(--ink-1)">"Pazarlık yok. Bir kere soruyorum: alıyor musun?"</span>'
            '<div style="display:flex;flex-direction:column"><span class="t-caption" style="color:var(--ink-2)">.t-quote · düz tırnak veriden gelir, değiştirilmez</span>'
            '<span class="t-caption" style="color:var(--ink-3)">%s · satır arası +2 · statik dosya, opsz 20</span></div></div>' % (type_rows(TYPE_ROWS_COND), spec_of("t-quote")))
    rules = ('<div class="cap t-label" style="margin-top:14px">Büyük harf kuralı</div>'
             '<div class="pane-demo" style="padding:10px 16px;display:grid;grid-template-columns:250px 60px 1fr;row-gap:6px;column-gap:16px;align-items:center">'
             '<span class="t-label" style="color:var(--ink-1)">Ekip · Aylık maaş yükü</span><span class="t-caption" style="color:var(--pos)">doğru</span><span class="note">en çok üç kelimelik CSV etiketi (anahtar, sütun, sekme, ray, etiket); Fmt.upper</span>'
             '<span class="t-meta" style="color:var(--ink-1)">Karar · Hafta 14 · Nisan 2026</span><span class="t-caption" style="color:var(--pos)">doğru</span><span class="note">tarih ve üst satır cümle düzeni (üst bardaki tarihle aynı)</span>'
             '<span class="t-button" style="color:var(--ink-1)">İşe alım başlat</span><span class="t-caption" style="color:var(--pos)">doğru</span><span class="note">düğme ve cümle: cümle düzeni</span>'
             '<span class="t-label" style="color:var(--ink-3);text-decoration:line-through">Nordica · UX/UI Designer</span><span class="t-caption" style="color:var(--neg-ink)">yanlış</span><span class="note">özel ad ve unvan büyük harfe çevrilmez; Label.uppercase yok</span>'
             '</div>')
    right = ('<div class="cap t-label">IBM Plex Sans ve Condensed: veri, gövde, tablo</div>%s'
             '<div class="cap t-label" style="margin-top:14px">Rakam ve satır yüksekliği</div>'
             '<div class="pane-demo" style="padding:10px 16px;display:flex;gap:28px;align-items:flex-start">'
             '<div style="display:flex;flex-direction:column;align-items:flex-end;flex:none"><span class="t-data">$11.200</span><span class="t-data">−$9.800</span><span class="t-data">$7.400</span></div>'
             '<div class="note" style="font-size:14px;line-height:20px;color:var(--ink-3)">Rakamlar eş genişlikte (Plex doğal, Barlow\'da tnum). Eksi işareti U+2212 (−), artıyla aynı genişlik. '
             'Satır yüksekliği Godot Label ölçüsü: yüz ve Plex yedeği. Noto Symbols 2 metin zincirine girmez; ★ ▲ ▼ ✦ ⏎ ✕ ✗ ⇠ ikon ya da yeniden yazım (SPEC §3.1 glif envanteri).</div></div>'
             % type_rows(TYPE_ROWS_SANS))
    body = ('<div class="abs" style="left:48px;top:92px;width:880px">%s%s</div>'
            '<div class="abs" style="left:976px;top:92px;width:896px">%s</div>' % (left, rules, right))
    return page("2", "Yazı", "12 adım, 12 ile 40 arası, adı boyutuyla. Tam sayı harf aralığı; satır yüksekliği Godot'un ölçtüğü.", body)


# ------------------------------------------------------------------ page 3: controls
def p3():
    states = [("", "Normal"), ("is-hover", "Üstünde"), ("is-pressed", "Basılı"), ("is-focus", "Odak"), ("is-disabled", "Kapalı")]
    kinds = [("btn-primary", "Birincil", "İşe alım başlat", "plus"), ("btn-secondary", "İkincil", "Değerlendir", None),
             ("btn-ghost", "Hayalet", "Ofisi taşı", "move"), ("btn-danger", "Tehlike", "İşten çıkar", None),
             ("btn-secondary btn-sm", "Küçük", "Değiştir", None), ("btn-primary btn-lg", "Büyük", "Kabul et", None)]
    grid = '<div class="state-grid" style="grid-template-columns:96px repeat(5, 196px);row-gap:10px"><span></span>' + "".join('<span class="h t-label">%s</span>' % s for _, s in states)
    for k, label, txt, icn in kinds:
        grid += '<span class="h t-label">%s</span>' % label
        for st, _ in states:
            grid += '<div><span class="btn %s %s">%s%s</span></div>' % (k, st, ic(icn) if icn else "", txt)
    grid += '</div>'
    locked = ('<div class="cap t-label" style="margin-top:14px">Kilitli: yalnız etiket ve ikon soluk, gerekçe tam mürekkep</div>'
              '<div style="display:flex;gap:28px;align-items:center">'
              '<span class="locked"><span class="btn btn-secondary is-disabled">%sReddet</span><span class="why t-data">Zor modda açılır.</span></span>'
              '<span class="locked"><span class="btn btn-primary is-disabled">Cevapla</span><span class="why t-data">Önce bekleyen kararı cevapla.</span></span></div>'
              % ic("lock"))
    tabs = ('<div class="cap t-label" style="margin-top:14px">Bölüm sekmesi</div><div style="display:flex;align-items:stretch;height:44px;border-bottom:1px solid var(--line-1);gap:24px">'
            '<span class="seg-tab t-tab is-active">Özet</span><span class="seg-tab t-tab is-hover">Yatırım<span class="n">2</span></span>'
            '<span class="seg-tab t-tab is-focus">Görevler</span><span class="seg-tab t-tab is-disabled">Rakipler</span>'
            '<span class="note" style="align-self:center;margin-left:16px">etkin · üstünde · odak · kapalı. Etkin: mürekkep ve 2 px çizgi, amber değil.</span></div>')
    tags = ('<div class="cap t-label" style="margin-top:14px">Etiket, hap, rozet, ilişki</div><div style="display:flex;flex-wrap:wrap;gap:8px;align-items:center">'
            + tag("Yeni") + tag("Ayrılabilir", "risk") + tag("Risk altında", "risk") + tag("Büyümek istiyor", "pos")
            + tag("Son hafta", "warn") + tag("Sağlıklı", "outline") + tag("İzinde", "neutral")
            + '<span style="width:10px"></span>' + pill("mentor") + pill("customer") + pill("team")
            + '<span style="width:10px"></span><span class="badge badge-danger">1</span><span class="badge badge-count">3</span><span class="badge badge-gate"></span>'
            + '</div><div style="display:flex;gap:8px;margin-top:10px;align-items:center">'
            + '<span class="rel ally">Müttefik</span><span class="rel friendly">Dost</span><span class="rel">Nötr</span><span class="rel wary">Temkinli</span><span class="rel hostile">Düşman</span>'
            + '<span class="note" style="margin-left:8px">ilişki kelimeleri yer tutucu (Erdem\'in sözcükleri); ham enum ekrana çıkmaz</span></div>')
    tips = ('<div style="display:flex;gap:20px;margin-top:16px;align-items:flex-start"><div style="flex:1"><div class="cap t-label">İpucu</div><div style="display:flex;flex-direction:column;gap:8px;align-items:flex-start">'
            '<span class="tip">Müşteri İlişkileri</span>'
            '<span class="tip rich"><span class="tip-t">Titiz</span><span class="tip-b">Geliştirmede çok daha az hata çıkarır, ama yavaş çalışır.</span></span></div></div>'
            '<div style="width:300px"><div class="cap t-label">Boş durum</div><div class="pane-demo"><div class="empty" style="padding:16px 12px">%s<span class="empty-t">Masada bekleyen bir şey yok.</span></div></div></div></div>'
            % ic("olaylar"))
    motif = ('<div class="cap t-label" style="margin-top:14px">Masa dili: belge köşesi ve damga</div>'
             '<div style="display:flex;gap:20px;align-items:center">'
             '<div class="doc" style="width:150px;height:64px;background:var(--surface-4);border:1px solid var(--line-2);padding:10px 14px"><div class="t-micro" style="color:var(--ink-3)">Karar</div><div class="t-body-strong" style="color:var(--ink-1)">Bedel kutusu</div></div>'
             '<div class="doc-sm" style="width:150px;height:44px;background:var(--surface-4);border:1px solid var(--line-2);padding:12px 14px" ><span class="t-meta">Toast, bildirim</span></div>'
             '%s%s'
             '<span class="note" style="max-width:330px">Belge olan her şeyin (karar, kağıt, rapor, dosya, toast, bildirim, kurulmuş seçenek) sağ üst köşesi 12 px pahlı; '
             'mobilya (pencere, ray, bar, tablo, kontrol) değil. Biten belgeye damga basılır.</span></div>'
             % (stamp("Cevaplandı", "H12"), stamp("İmzalandı")))
    scale = ('<div style="display:flex;gap:40px;margin-top:14px;align-items:flex-start">'
             '<div><div class="cap t-label">Boşluk</div><div style="display:flex;gap:7px;align-items:flex-end">%s</div></div>'
             '<div><div class="cap t-label">Köşe</div><div style="display:flex;gap:12px;align-items:center">%s</div></div>'
             '<div><div class="cap t-label">Gölge (ofisin üstünde)</div><div style="position:relative;display:flex;gap:24px;align-items:center;padding:20px 24px;border-radius:6px;overflow:hidden">'
             '<div class="office is-dimmed" style="background-image:url(%s/office_game.png);background-position:40%% 60%%"></div>'
             '<div style="position:relative;width:80px;height:48px;background:var(--surface-3);border:1px solid var(--line-2);border-radius:8px;box-shadow:var(--shadow-window)"></div>'
             '<div style="position:relative;width:80px;height:48px;background:var(--surface-3);border:1px solid var(--line-1);border-radius:6px;box-shadow:var(--shadow-float)"></div>'
             '<div style="position:relative;width:80px;height:28px;background:var(--surface-0);border:1px solid var(--line-2);border-radius:4px;box-shadow:var(--shadow-tooltip)"></div></div></div></div>'
             % ("".join('<div style="display:flex;flex-direction:column;align-items:center;gap:4px"><div style="width:%dpx;height:%dpx;background:var(--ink-4)"></div><span class="sw-m">%d</span></div>' % (sz, sz, sz)
                        for sz in (2, 4, 6, 8, 12, 16, 20, 24, 32, 40, 48)),
                "".join('<div style="display:flex;flex-direction:column;align-items:center;gap:4px"><div style="width:46px;height:30px;border:1px solid var(--line-3);border-radius:%s;background:var(--surface-3)"></div><span class="sw-m">%s</span></div>' % (r, n)
                        for r, n in (("2px", "2"), ("4px", "4"), ("6px", "6"), ("8px", "8"), ("999px", "hap"))), ART))
    left = '<div class="cap t-label">Düğmeler</div>%s%s%s%s%s%s' % (grid, locked, tabs, tags, motif, scale)

    form = ('<div class="cap t-label">Alan, onay kutusu, anahtar, kaydırıcı</div><div style="display:grid;grid-template-columns:1fr 1fr;gap:12px 20px">'
            '<div class="field"><span class="field-k t-label">Şirket adı</span><div class="input"><span class="ph">Şirketine bir ad ver</span></div></div>'
            '<div class="field"><span class="field-k t-label">Şirket adı · odak</span><div class="input is-focus" style="outline:2px solid var(--focus);outline-offset:2px">Unicorn Inc.<span class="caret"></span><span class="cnt">12/24</span></div></div>'
            '<div class="field"><span class="field-k t-label">Şirket adı · hata</span><div class="input is-error">Unicorn Inc. Uluslararası Yazılım</div><span class="field-msg is-error">Ad 24 harfi geçemez. (örnek metin)</span></div>'
            '<div class="field"><span class="field-k t-label">Şirket adı · kapalı</span><div class="input is-disabled">Unicorn Inc.</div></div>'
            '</div>'
            '<div style="display:flex;gap:24px;margin-top:14px;align-items:center;flex-wrap:wrap">'
            '<span class="check is-on"><span class="check-box">%s</span>Odak kaybında sessize al</span>'
            '<span class="check is-hover"><span class="check-box">%s</span>Arka plan müziği</span>'
            '<span class="check is-disabled"><span class="check-box">%s</span>Dikey eşitleme</span></div>'
            '<div style="display:flex;gap:24px;margin-top:12px;align-items:center">'
            '<span class="switch is-on"><span class="switch-t"></span>Renk körü paleti</span>'
            '<span class="switch"><span class="switch-t"></span>Kapalı</span><span class="switch is-disabled"><span class="switch-t"></span>Kapalı, kilitli</span></div>'
            '<div style="display:flex;gap:16px;margin-top:12px;align-items:center"><span class="t-key" style="color:var(--ink-3);width:70px">Ana ses</span>'
            '<div class="slider"><div class="slider-t"></div><div class="slider-f" style="width:70%%"></div><div class="slider-g" style="left:70%%"></div></div>'
            '<span class="t-data">%%70</span></div>'
            '<div class="note" style="margin-top:6px">Anahtar ve kaydırıcı tutamağı A2\'nin theme/ çiftiyle aynı biçim (40×22, açıkta mürekkep, amber değil).</div>') % (ic("check"), ic("check"), ic("check"))
    menu = ('<div class="cap t-label" style="margin-top:14px">Açılır liste ve menü</div><div style="display:flex;gap:20px;align-items:flex-start">'
            '<div style="display:flex;flex-direction:column;gap:6px;width:220px"><span class="field-k t-label" style="color:var(--ink-3)">Arayüz ölçeği</span>'
            '<span class="select is-open">%%100%s</span>'
            '<div class="menu" style="min-width:220px"><div class="menu-item"><span class="chk">%s</span>%%100</div>'
            '<div class="menu-item is-hover"><span class="chk"></span>%%110</div><div class="menu-item is-disabled"><span class="chk"></span>%%125<span class="why">ekran dar</span></div></div></div>'
            '<div style="display:flex;flex-direction:column;gap:6px"><span class="field-k t-label" style="color:var(--ink-3)">Satır menüsü</span>'
            '<div class="menu"><div class="menu-head t-micro">Selin Kaya</div><div class="menu-item">%sDosyayı aç</div>'
            '<div class="menu-item is-hover">%sZam yap</div><div class="menu-item is-disabled">%sEğitime gönder<span class="why">bütçe yok</span></div>'
            '<div class="menu-sep"></div><div class="menu-item is-danger">%sİşten çıkar</div></div></div></div>'
            '<div class="note" style="margin-top:8px">Menüde de üstünde kenar. Kapalı satırın kısa gerekçesi sağda ink-3, uzunu ipucunda (örnek metin).</div>'
            % (ic("chevdown"), ic("check"), ic("doc"), ic("raise"), ic("training"), ic("departed")))
    toasts = ('<div class="cap t-label" style="margin-top:14px">Tek bildirim (toast)</div>'
              '<div style="display:flex;flex-direction:column;gap:8px;align-items:flex-start">%s%s</div>'
              '<div class="note" style="margin-top:6px">Toast bir not kağıdı: pahlı köşe, ikon kuyusu, kalın baş, ikincil satır. Tek bileşen: kayıt, saat kilidi, taşınma, erteleme, paylaşım.</div>'
              % (toast("ok", "Kaydedildi", "Hafta 14 · 11:00", "check"), toast("", "Saat kilitli", "Önce Frank'in teklifini cevapla.", "pause")))
    body = ('<div class="abs" style="left:48px;top:92px;width:1100px">%s</div>'
            '<div class="abs" style="left:1200px;top:92px;width:672px">%s%s%s%s</div>' % (left, form, menu, toasts, tips))
    return page("3", "Kontroller ve durumlar", "Üstünde kenar, seçili mürekkep, odak beyaz halka, kapalıda gerekçe tam okunur.", body)


# ------------------------------------------------------------------ page 4: data
def p4():
    win = ekip_window(48, 88, states={"deniz": "is-hover", "elif": "is-selected"})
    side = '<div class="cap t-label">Moral: 35 çentiği ayrılma eşiği</div><div style="display:flex;flex-direction:column;gap:8px">'
    for m, note in ((22, "35 altı: tehlike; risk şeridi, rozet"), (38, "35-49: dikkat; hız ×0,85"), (61, "50 ve üstü: iyi"), (100, "80 ve üstü: hız ×1,10")):
        side += '<div style="display:flex;align-items:center;gap:16px">%s<span class="note">%s</span></div>' % (mor(m), note)
    side += '</div><div class="cap t-label" style="margin-top:14px">Deneyim</div><div style="display:flex;gap:28px">%s%s%s</div>' % (xp(0), xp(45), xp(100))
    side += '<div class="note" style="margin-top:6px">Dolgu bar-fill (ink-3): deneyim iyi ya da kötü değil, ilerleme.</div>'
    side += '<div class="cap t-label" style="margin-top:14px">Huy hücresi: A2 glifi ve etiket</div><div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px 8px">'
    side += "".join(trait(i, t) for i, t in TRAITS) + '</div><div class="note" style="margin-top:6px">Etki ipucunda. Etiket cümle düzeni (CSV bugün büyük harf, TR onayı). Glifler A2 ailesinden okunur; anlamları A2\'de kesinleşir.</div>'
    side += ('<div class="cap t-label" style="margin-top:14px">İzindeki çalışan (Mert)</div>'
             '<div class="note" style="font-size:13px;line-height:19px;color:var(--ink-3)">Sayılar tam rampada kalır: oyuncunun planladığı canlı veri, kapalı kontrol değil. '
             'İzin üç işaretle okunur: gri yüz (Godot avatar_grey.gdshader), ink-3 ad, Durum hücresinde nötr İZİNDE etiketi ve kalan süre.</div>')
    side += ('<div class="cap t-label" style="margin-top:14px">Sıralama ve grup kapama</div>'
             '<div class="pane-demo" style="padding:0 12px 8px">%s</div>'
             '<div class="note" style="margin-top:6px">Sıralanan başlık ink-1 ve 12 px yön işareti; üstünde alt kenar çizgisi. Grup başı tıklanınca kapanır, kapalı grup kişi sayısını gösterir.</div>'
             % ('<div class="grid tbl-head" style="grid-template-columns:1fr 70px 96px;height:32px;padding-bottom:6px">'
                '<div class="th t-label">Çalışan</div><div class="th t-label r is-hover">Maaş</div><div class="th t-label is-sorted" style="padding-left:8px">Moral%s</div></div>'
                '<div class="tbl-group t-group is-collapsed" style="height:30px">%s%sGeliştirme Ekibi<span class="n">2</span></div>'
                '<div class="tbl-group t-group" style="height:30px">%s%sSatış</div>'
                % (ic("sort_down", 12, cls="sort"), ic("chev", 16, cls="tw"), ic("d_dev"), ic("chevdown", 16, cls="tw"), ic("d_sales"))))
    widths = " · ".join("%s %d" % (n, w) for n, w in zip(
        ["yüz", "çalışan", "6 rol", "", "", "", "", "", "liderlik", "görev", "deneyim", "durum", "huy", "maaş", "moral"], WID) if n)
    body = win + '<div class="abs" style="left:1432px;top:88px;width:440px">%s</div>' % side
    body += ('<div class="abs" style="left:48px;top:800px;width:1352px"><div class="cap t-label">Notlar</div><div class="note" style="font-size:14px;line-height:21px;color:var(--ink-3)">'
             'Satırın tek dikdörtgeni var: üstünde kenarı (Deniz), seçili dolgusu ve 3 px işareti (Elif) aynı kenarlara oturur. Rol bandı %%5 mürekkep: 1-2 bant üstünde %s:1. '
             'Kırmızı yalnız Selin (moral 22). Pencere 1352 (1920\'de BuildHUD\'a 16 px kalır; 1536\'da alana sığar). Sütunlar EN ve TR\'nin en uzun değerine göre, Godot payı ×1,08 + 2 px '
             '(px, toplam 1302): %s. EN\'de taşan başlıklar ("EXPERIENCE", "LEADERSHIP") ve "Takes Them Under", "At risk of leaving" bu genişliklere sığar (sayfa 15).</div></div>'
             % (cr("--skill-1", ("--role-band", "--surface-3")), widths.replace("6 rol 44", "6 rol 44×6")))
    body += col_ruler()
    return page("4", "Veri bileşenleri", "Pencere çerçevesi, KPI başlığı, kontrol şeridi, risk şeridi, tablo, beceri hücresi.", body)


def col_ruler():
    """Each column with its width and the widest TR or EN value it must hold, drawn in the column's real class."""
    import kit as _k
    en = ' lang="en"'
    cells = [
        ("yüz", WID[0], 'padding-left:12px', avatar("burak", 32)),
        ("çalışan", WID[1], 'padding-left:8px', '<span class="t-ccaption" style="color:var(--ink-3)"%s>Customer Success Manager</span>' % en),
        ("6 rol", sum(WID[2:8]), '', '<span style="display:flex;justify-content:space-around">%s</span>' % "".join(ic(k) for k, _ in _k.SKILL_HEADS)),
        ("liderlik", WID[8], 'text-align:center', '<span class="t-label" style="color:var(--ink-3)"%s>Leadership</span>' % en),
        ("görev", WID[9], 'padding-left:12px', '<span class="t-cdata">Hesaplarda görev alıyor</span>'),
        ("deneyim", WID[10], 'padding-left:4px', '<span class="t-label" style="color:var(--ink-3)"%s>Experience</span>' % en),
        ("durum", WID[11], '', '<span%s>%s</span>' % (en, tag("At risk of leaving", "risk"))),
        ("huy", WID[12], 'padding-left:4px', '<div class="trait"><span class="trait-box">%s</span><span class="trait-label">Takes Them Under</span></div>' % ic("tr_lead")),
        ("maaş", WID[13], 'padding-right:12px;text-align:right', '<span class="t-label" style="color:var(--ink-3)"%s>Salary</span>' % en),
        ("moral", WID[14], '', mor(100)),
    ]
    segs = "".join('<div style="width:%dpx;flex:none;border-left:1px solid var(--line-3)"><div class="t-micro" style="color:var(--ink-3);padding:4px 6px;white-space:nowrap">%s %d</div>'
                   '<div style="height:32px;display:flex;align-items:center;%s"><div style="flex:1;min-width:0;%s">%s</div></div></div>'
                   % (w, n, w, "justify-content:flex-end" if "right" in st else "", st, html) for n, w, st, html in cells)
    return ('<div class="abs" style="left:73px;top:920px;width:1302px"><div class="cap t-label">Sütun cetveli: her sütun en uzun TR ya da EN değeriyle, kendi sınıfında (genişlik ×1,08 + 2 ile ölçüldü)</div>'
            '<div style="display:flex;border-right:1px solid var(--line-3);border-top:1px solid var(--line-2);background:var(--surface-3)">%s</div></div>' % segs)


# ------------------------------------------------------------------ page 5: inbox
def p5():
    win = olay_window(48, 88, h=944)
    legend = ('<div class="cap t-label">Kutu satırı türleri</div><div class="pane-demo" style="padding:12px 16px;display:grid;grid-template-columns:28px 1fr;row-gap:10px;column-gap:10px;align-items:center">'
              '<span class="gate-dot" style="width:8px;height:8px;margin-left:6px;box-shadow:0 0 0 3px var(--accent-glow)"></span><span class="t-caption"><b style="color:var(--ink-1)">Karar bekliyor.</b> Amber nokta, saat durumu ailesi. Kutu kendiliğinden açılır, kart seçili gelir.</span>'
              '<span style="width:6px;height:6px;border-radius:3px;background:var(--ink-2);margin-left:7px"></span><span class="t-caption"><b style="color:var(--ink-1)">Okunmamış.</b> Mürekkep nokta; konu yarı kalın, beyaz.</span>'
              '<span style="color:var(--ink-3)">%s</span><span class="t-caption"><b style="color:var(--ink-1)">Süreli kağıt.</b> Kalan hafta saatle; son hafta turuncu (uyarı, tehlike değil).</span>'
              '<span style="color:var(--ink-3)">%s</span><span class="t-caption"><b style="color:var(--ink-1)">Sıradaki kararlar.</b> Yalnız sayı; seçilmez.</span>'
              '<span style="color:var(--ink-3)">%s</span><span class="t-caption"><b style="color:var(--ink-1)">Dikkat.</b> Riskteki müşteri, ayrılabilir çalışan: etiket konu yerine.</span>'
              '<span style="color:var(--ink-3)">%s</span><span class="t-caption"><b style="color:var(--ink-1)">Rapor.</b> Dönem özeti, haftalık satış, Ar-Ge notu, tanışma.</span>'
              '<span style="color:var(--ink-3)">%s</span><span class="t-caption"><b style="color:var(--ink-1)">Geçmiş.</b> Seçilen seçenek ve damga; konu ink-3.</span>'
              '<span style="color:var(--ink-3)">%s</span><span class="t-caption"><b style="color:var(--ink-1)">Ayrılmış gönderici.</b> Ad kalır, yanında "Ayrıldı" (ink-4), yüz gri.</span>'
              '</div>' % (ic("clock", 16), ic("queue", 16), ic("warn", 16), ic("doc", 16), ic("check", 16), ic("departed", 16)))
    paper = ('<div class="cap t-label" style="margin-top:18px">Kağıt önizlemesi: seçmek saati durdurmaz</div>'
             '<div class="paper-bar"><span class="when is-lastweek t-key">%sBu hafta son</span><span class="btn btn-primary">%sCevapla</span></div>'
             '<div class="paper-bar" style="margin-top:8px"><span class="when t-key" style="color:var(--ink-3)">%s2 hafta</span>'
             '<span class="locked" style="margin-left:auto"><span class="why t-data">Önce bekleyen kararı cevapla.</span><span class="btn btn-primary is-disabled">Cevapla</span></span></div>'
             '<div class="note" style="margin-top:6px">Cevapla kağıdı açar, saat durur (GDD §11.4). Esc ya da × açık kağıdı kenara koyar, geçmişe yazmaz.</div>'
             % (ic("clock"), ic("reply"), ic("clock")))
    keys = ('<div class="cap t-label" style="margin-top:18px">Klavye</div><div class="pane-demo" style="padding:12px 16px;display:grid;grid-template-columns:110px 1fr;row-gap:6px">'
            '<span class="t-label" style="color:var(--ink-1)">↑ ↓</span><span class="t-caption">satır seç; bölme önizler, saat durmaz</span>'
            '<span class="t-label" style="color:var(--ink-1)">Enter</span><span class="t-caption">kağıtta Cevapla; kararda ilk seçeneğe odak; odakta seçeneği kurar; kurulunca Seç</span>'
            '<span class="t-label" style="color:var(--ink-1)">← → Tab</span><span class="t-caption">seçenekler arası; Space ve 1-4 hiçbir zaman seçmez</span>'
            '<span class="t-label" style="color:var(--ink-1)">400 ms</span><span class="t-caption">karar açıldıktan ve seçenek kurulduktan sonra Enter yok sayılır</span>'
            '<span class="t-label" style="color:var(--ink-1)">Esc</span><span class="t-caption">kurulmuş seçeneği bırakır; sonra pencereyi kapatır</span></div>')
    ro = ('<div class="cap t-label" style="margin-top:18px">Karar beklerken öteki pencere: yalnız okunur</div>'
          '<div class="pane-demo" style="overflow:hidden"><div class="win-ro"><span class="gate-dot"></span><span class="t-key" style="color:var(--ink-2)">Karar bekliyor. Bu pencere yalnız okunur.</span>'
          '<div class="grow"></div><span class="btn btn-secondary btn-sm">%sKarara dön</span></div>'
          '<div class="win-ctl" style="padding:0 16px"><div class="seg"><span class="seg-tab t-tab is-active">Kadro</span><span class="seg-tab t-tab">Görevler</span></div><div class="grow"></div>'
          '<span class="btn btn-primary is-disabled">%sİşe alım başlat</span></div></div>' % (ic("reply"), ic("plus")))
    side = '<div class="abs" style="left:1320px;top:88px;width:552px">%s%s%s%s</div>' % (legend, paper, keys, ro)
    return page("5", "Gelen kutusu", "Olaylar: liste, okuma bölmesi, bekleyen karar. Seed: hafta 14, Frank'in teklifi (portre: aday D, seçim A3'te).", win + side)


# ------------------------------------------------------------------ page 6: decision parts
def p6():
    s1 = ('<div class="cap t-label">Bedel satırı: kazanç, bedel, tehlike, şans</div>%s'
          '<div class="stake" style="margin-top:10px"><div class="part cost"><span class="part-k">Müşteri kalır</span><span class="part-v">%sMRR −$300</span></div><span class="part-sep"></span>'
          '<div class="part danger"><span class="part-k">Reddedersen</span><span class="part-v txt">%sMüşteriyi kaybet</span></div></div>'
          '<div class="stake" style="margin-top:10px"><div class="part chance"><span class="part-k">Şans</span><span class="part-v">%s%%60</span></div><span class="part-sep"></span>'
          '<div class="part gain"><span class="part-k">Tutarsa</span><span class="part-v">%sKoltuk +8</span></div><span class="part-sep"></span>'
          '<div class="part cost"><span class="part-k">Tutmazsa</span><span class="part-v">%sMemnuniyet −10</span></div></div>'
          '<div class="note" style="margin-top:8px">Yalnız <b>tehlike</b> kırmızı. Hisse, indirim ve düşüş <b>bedel</b>: mürekkep ve eksi. Şans zarla. Sözlü sonuç bir basamak küçük (26). Tek açık seçenek (Frank) baştan kurulu gelir. 2. ve 3. satırın değerleri örnek.</div>'
          % (stake_frank(), ic("cost"), ic("warn"), ic("dice"), ic("up"), ic("cost")))
    s2 = ('<div class="cap t-label" style="margin-top:18px">Çok seçenekli karar: oyuncu kurar, sonra seçer</div>'
          '<div class="perm">%s<span class="t-meta">Seçim kalıcıdır · Oyun duraklatıldı</span></div><div style="height:10px"></div>%s%s%s%s%s'
          '<div class="note" style="margin-top:8px">Önce hiçbiri amber değil (normal, üstünde, odak). Tıklama ya da Enter seçeneği <b>kurar</b>: çubuk bedel kutusuna açılır, tek amber "Seç" '
          'oyuncunun kendi seçimi üstünde belirir; Vazgeç ya da Esc bırakır. Ok yok: çubuk bir yere gitmez. Üç etki çipine kadar sığmazsa çipler ikinci satıra iner, çubuk 88 px olur.</div>'
          % (ic("pause"),
             opt("Listede olduğunu söyle", fx("gain", "Memnuniyet +3"), "is-hover"),
             opt_armed("Tarih ver", [("gain", "Memnuniyet", "up", "+8"), ("cost", "Müşteri kalır", "cost", "söz borcu")]),
             opt("Şimdilik olmaz de", fx("cost", "Memnuniyet −6"), "is-focus"),
             opt("Daha düşük fiyatla yenile", fx("cost", "MRR −$300/ay") + fx("gain", "Memnuniyet +12") + fx("chance", "%40 · Koltuk +4", "dice"), "is-wrap"),
             opt("Düzeltme sözü ver", state="is-locked", why="Bu hesaba verilmiş, henüz tutulmamış bir söz var.")))
    left = s1 + s2
    hist = ('<div class="cap t-label">Geçmiş karar (bölmenin geçmiş kipi)</div>'
            '<div class="pane-demo doc" style="position:relative;padding:16px 24px"><div class="pane-kicker">%s<span class="t-meta">Cevaplandı · Hafta 12 · Mart 2026</span></div>'
            '<div class="t-subhead" style="color:var(--ink-1);margin-top:6px">Müşteri talebi</div>'
            '<div style="display:flex;align-items:center;gap:8px;margin-top:8px"><span class="t-key" style="color:var(--ink-3)">Seçimin</span>'
            '<span class="t-body-strong" style="color:var(--ink-2)">Listede olduğunu söyle</span></div>'
            '<div style="display:flex;gap:6px;margin-top:10px">%s%s</div><div style="position:absolute;right:28px;top:30px">%s</div></div>'
            % (pill("customer"), fx("gain", "Memnuniyet +3"), fx("cost", "Yol haritasına eklendi"), stamp("Cevaplandı", "H12")))
    beat = ('<div class="cap t-label" style="margin-top:18px">Tek seçenekli Frank anı</div>'
            '<div class="pane-demo" style="padding:12px 24px;display:flex;align-items:center;gap:16px">%s<div style="flex:1"><div class="t-subhead" style="color:var(--ink-1)">Tek kişilik şirket</div>'
            '<div class="t-meta" style="color:var(--ink-3)">Frank\'ten mesaj.</div></div><span class="btn btn-primary">İK\'ya git</span></div>'
            '<div class="note" style="margin-top:6px">Tek eylem birincildir. Düğme bugün "İK\'ya git" (sekmenin adı Ekip: TR onayı).</div>' % avatar("frank", 48))
    variants = ('<div class="cap t-label" style="margin-top:18px">Okuma bölmesi: konuşmacı türleri</div>'
                '<div style="display:flex;gap:12px">'
                '<div class="pane-demo" style="flex:1;padding:12px;display:flex;gap:12px;align-items:center">%s<div><div class="t-micro" style="color:var(--ink-3)">Karşı taraf büstü</div>'
                '<div class="t-body-strong" style="color:var(--ink-1)">Tolga Erdem</div><div class="t-caption" style="color:var(--ink-3)">Meridian Growth</div></div></div>'
                '<div class="pane-demo" style="flex:1;padding:12px;display:flex;gap:12px;align-items:center"><span class="mono t-subhead" style="width:64px;height:64px">ES</span><div><div class="t-micro" style="color:var(--ink-3)">Kişisiz şirket</div>'
                '<div class="t-body-strong" style="color:var(--ink-1)">Ege Sigorta</div><div class="t-caption" style="color:var(--ink-3)">Destek hattı</div></div></div>'
                '<div class="pane-demo" style="flex:1;padding:12px;display:flex;gap:12px;align-items:center"><span class="mono" style="width:64px;height:64px">%s</span><div><div class="t-micro" style="color:var(--ink-3)">Portresiz rapor</div>'
                '<div class="t-body-strong" style="color:var(--ink-1)">Dönem özeti</div><div class="t-caption" style="color:var(--ink-3)">Hafta 13 · 2026</div></div></div></div>'
                '<div class="note" style="margin-top:6px">Portre kuyusu yalnız kişi konuşunca: Frank ve çalışanlar 256×320 kart, karşı taraf 64 px büst (mevcut büst seti), şirket monogram, rapor belge glifi.</div>'
                % (avatar(common.menajer("art/busts/vc/bust_meridian_0_vc_lead.png"), 64), ic("doc", 32, "var(--ink-3)")))
    report = ('<div class="cap t-label" style="margin-top:18px">Rapor mesajı: haftalık satış özeti (saat durmaz)</div>'
              '<div class="pane-demo doc" style="padding:12px 24px"><div class="pane-kicker">%s<span class="t-meta">Rapor · Hafta 13 · Nisan 2026</span></div>'
              '<div style="display:grid;grid-template-columns:1fr 70px 92px 110px;margin-top:8px;row-gap:2px">'
              '<span class="th t-label">Müşteri</span><span class="th t-label r">Koltuk</span><span class="th t-label r">Fiyat</span><span class="th t-label r">MRR</span>'
              '<span class="t-data-strong" style="color:var(--ink-1)">Karadeniz Fabrika</span><span class="t-data num">12</span><span class="t-data num">$85</span><span class="t-data num" style="color:var(--pos)">+$1,0K/ay</span>'
              '<span class="t-data-strong" style="color:var(--ink-1)">Efes Emlak</span><span class="t-data num">8</span><span class="t-data num">$75</span><span class="t-data num" style="color:var(--pos)">+$600/ay</span>'
              '</div><div class="t-meta" style="color:var(--ink-3);margin-top:8px;border-top:1px solid var(--line-1);padding-top:8px">Toplam: 2 anlaşma · $1,6K/ay</div></div>'
              % pill("customer"))
    rows2 = ('<div class="cap t-label" style="margin-top:18px">Kutu satırı: tanışma ve ayrılmış gönderici</div>'
             '<div style="display:flex;gap:16px"><div class="ib-list" style="width:428px;border:1px solid var(--line-2);border-radius:6px">%s</div>'
             '<div class="ib-list" style="width:428px;border:1px solid var(--line-2);border-radius:6px">%s</div></div>'
             % (ib_row("Frank Köseoğlu", "mentor", "İlk sabah", ic("doc") + "tanışma", "İstifadan sonraki ilk sabah. Alarm çalıyor.", "is-unread"),
                ib_row('Selin Kaya <span class="gone">· Ayrıldı</span>', "team", "Ayrılık mektubu", "",
                       "Test Mühendisi · Test ediyor", "is-history", stamp_html=stamp("Ayrıldı"))))
    right = hist + beat + report + variants + rows2
    body = ('<div class="abs" style="left:48px;top:92px;width:900px">%s</div>'
            '<div class="abs" style="left:1000px;top:92px;width:872px">%s</div>' % (left, right))
    return page("6", "Karar parçaları", "Bedel satırı, kurulan seçenek, kalıcılık satırı, geçmiş ve damga, rapor, konuşmacı türleri.", body)


# ------------------------------------------------------------------ page 7: shell
def p7():
    L = tb_week_bar_len(False, 1920)
    bars = [("Normal: yuva Sıradaki'yi gösterir (görüşme 14:00). Hafta çubuğu 08:00 ile 17:00; mesai öncesi ince, 14:00 işareti, 17:00 mesai sonu çentiği.", topbar("normal")),
            ("Cevap bekliyor: amber çerçeve, nokta ve yazı; hız tuşları kapalı. Bütün sütunlar sabit: hafta çubuğu her durumda %d px." % L, topbar("gated")),
            ("Birden çok karar: alt satır sayıyı söyler. Yuvaya tıklamak Olaylar'ı kararla açar.", topbar("gated2")),
            ("Alarm: kasa eksi; RUNWAY hücresi KEPENK olur (sayaç orada, yuvada değil). Yuva sıradaki teklifi gösterir (uyarı). Amber yok.", topbar("alarm", slot="offer")),
            ("Boş gün: yuva hiç boş kalmaz, haftanın bitimine kalan saati söyler (Mesai bitimi).", topbar("normal", slot="end")),
            ("Sıkışık kip, 1536 mantıksal (ölçek 1.25): marka yalnız logo, tarih kısa, tuşlar 30 px, yuva 216 px; hafta çubuğu %d px." % tb_week_bar_len(True, 1536),
             topbar("normal", compact=True, width=1536))]
    body = ""
    for i, (note, bar) in enumerate(bars):
        y = 62 + i * 80
        body += '<div class="abs note" style="left:48px;top:%dpx">%s</div><div class="abs" style="left:0;top:%dpx;width:1920px;height:64px">%s</div>' % (y, note, y + 18, bar)
    strip_top = 560
    body += ('<div class="abs" style="left:0;top:%dpx;width:1920px;height:%dpx;overflow:hidden">'
             '<div class="office is-dimmed" style="background-image:url(%s/office_full.png);background-position:0 -%dpx;background-size:1920px 1080px"></div>'
             '%s%s%s%s%s'
             '<div class="abs" style="left:880px;top:236px"><span class="float fbtn">%sOfisi taşı<span class="tag tag-neutral">2 hafta</span></span></div>'
             '<div class="abs" style="left:880px;top:296px">%s</div>'
             '<div class="abs" style="left:1140px;top:236px">%s</div>'
             '<div class="abs" style="left:300px;top:150px;display:flex;align-items:center;gap:14px;background:var(--surface-0);padding:8px 12px 8px 8px;border-radius:4px">'
             '<div style="position:relative;width:57px;height:40px">%s</div><span class="note" style="width:420px">Şerit kapalı: yalnız 57×40 düğme kalır, ofis 40 px alta uzar; tercih oyuncu ayarı.</span></div>'
             '%s</div>'
             % (strip_top, 1080 - strip_top, ART, strip_top,
                rail("ekip", hover="finans", top=0, bottom=40), rail("ekip", icons=True, style="left:204px;border-left:1px solid var(--line-1)", top=0, bottom=40),
                buildhud("position:absolute;left:1576px;top:16px"),
                notice("position:absolute;left:1544px;top:236px", "is-risk", "Ege Sigorta", "Risk altında"),
                notice("position:absolute;left:1544px;top:296px", "", "Nordica", "Büyüme talebi masada", '<span class="badge badge-count more">+2</span>'),
                ic("move"), toast("", "Saat kilitli", "Önce Frank'in teklifini cevapla.", "pause"), toast("ok", "Kaydedildi", "Hafta 14 · 11:00", "check"),
                ticker("position:absolute;left:0;bottom:0", collapsed=True), ticker("bottom:0")))
    body += ('<div class="abs note" style="left:300px;top:%dpx;width:520px;color:var(--ink-3);background:var(--surface-0);padding:8px 12px;border-radius:4px">'
             'Ray: boşta ikon ink-4, ad ink-3; etkin ikon ink-2, ad ink-1, surface-4 ve işaret; üstünde kenar (Finans); kilitli ikon ve ad ink-off, "Yakında" ink-4 okunur. '
             'Rozetin ardında 2 px zemin rengi kesik halka. Simge kipinde ad gizlenir, sayılı rozet ikonun köşesine iner (nokta değil), kilit küçük asma kilit; ad ipucunda.</div>'
             % (strip_top + 16))
    return page("7", "Kabuk", "Üst bar durumları (sabit sütunlar), ray (etiketli ve simge), haber şeridi, yüzen öğeler.", body)


# ------------------------------------------------------------------ page 8: colour-blind
def p8():
    ekip = ('<div class="pane-demo" style="padding:0 24px 12px;width:1352px">%s</div>' % ekip_table({}))
    ib = ('<div class="ib-list" style="height:auto;border:1px solid var(--line-2);border-radius:6px">%s</div>' % "".join([
        ib_row("Frank Köseoğlu", "mentor", "Frank'in teklifi", "11:00", "Ürün para kazandırmaya başladı.", "is-gate is-selected"),
        ib_row("Kuzey İnşaat", "customer", "Yenileme sinyali", ic("clock") + "bu hafta", "Yenileme görüşmesi bu hafta kapanıyor.", "is-unread is-lastweek"),
        ib_row("Selin Kaya", "team", tag("Ayrılabilir", "risk"), '<span class="t-label" style="color:var(--ink-3)">Moral</span><b style="color:var(--neg)">22</b>', "Test Mühendisi · Test ediyor", "is-unread"),
        ib_row("Nordica", "customer", tag("Büyümek istiyor", "pos"), "$2,0K/ay", "<i>Başka departmana yaymak istiyor.</i>", ""),
    ]))
    stake = ('<div class="stake" style="width:440px"><div class="part gain"><span class="part-k">Nakit</span><span class="part-v">%s+$25K</span></div><span class="part-sep"></span>'
             '<div class="part cost"><span class="part-k">Frank\'e</span><span class="part-v">%s%%4 hisse</span></div></div>'
             '<div style="display:flex;gap:8px;margin-top:12px;flex-wrap:wrap">%s%s%s%s%s%s%s</div>'
             '<div style="display:flex;gap:16px;margin-top:14px">%s%s%s</div>'
             '<div style="display:flex;gap:16px;margin-top:14px;align-items:center"><span class="notice float" style="width:auto;padding:0 16px"><span class="dt is-info"></span><span class="tx">Rapor</span></span>'
             '<span style="width:6px;height:6px;border-radius:3px;background:var(--ink-2)"></span><span class="note">bilgi noktası okunmamış noktasından ayrı</span></div>'
             % (ic("up"), ic("pie"), tag("Risk altında", "risk"), tag("Büyümek istiyor", "pos"), tag("Son hafta", "warn"),
                pill("funding"), pill("market"), pill("product"), pill("agenda"), mor(22), mor(38), mor(72)))
    sim = ('<div class="cap t-label" style="margin-top:20px">Deutan gözüyle: beceri ve moral sütunları</div>'
           '<div style="display:flex;flex-direction:column;gap:8px">'
           '<div><div class="sw-m" style="margin-bottom:4px">standart palet (Machado 2009, şiddet 1,0)</div><img src="pages/sim_std_deutan.png" style="display:block;border:1px solid var(--line-1);border-radius:4px" alt=""></div>'
           '<div><div class="sw-m" style="margin-bottom:4px">renk körü paleti</div><img src="pages/sim_cb_deutan.png" style="display:block;border:1px solid var(--line-1);border-radius:4px" alt=""></div></div>')
    body = ('<div class="abs" style="left:0;top:76px;width:1920px;height:64px">%s</div>'
            '<div class="abs" style="left:48px;top:156px">%s</div>'
            '<div class="abs" style="left:1424px;top:156px;width:448px"><div class="cap t-label">Bedel, etiket, moral, bilgi</div>%s%s</div>'
            '<div class="abs" style="left:48px;top:640px">%s</div>'
            '<div class="abs" style="left:520px;top:640px;width:860px"><div class="cap t-label">Renk körü kipinde değişenler</div><div class="note" style="font-size:14px;line-height:21px;color:var(--ink-3)">'
            'Olumlu mavi (%s), olumsuz cıva turuncusu (%s), uyarı açık sarı (%s), bilgi açık mavi (%s). Beceri rampasının 7-8 ve 9-10 basamakları maviye döner; '
            'sıra parlaklıkta kaldığı için iki palet de griye çevrildiğinde aynı okunur. Konu ve yayın renkleri dört görüş türünde en az 9,7 ΔE ayrı. '
            'Amber değişmez. Odak halkası beyaz (artık bilgi mavisiyle ve renk körü beceri mavisiyle çakışmaz). Şekil ikinci kanaldır: kazanç ok, bedel eksi, tehlike üçgen, moral 35 çentiği.<br><br>'
            'Faz F görsel kabulü için kalıcı olmayan <b>--palette=cb</b> bayrağı (UiTokens.set_colorblind); ayarlardaki anahtar settings.json\'a yazar.</div></div>'
            '<div class="abs" style="left:0;bottom:0;width:1920px;height:40px">%s</div>'
            % (topbar("gated"), ekip, stake, sim, ib, hx("--pos", ALT), hx("--neg", ALT), hx("--warn", ALT), hx("--info", ALT), ticker("bottom:0")))
    return page("8", "Renk körü paleti", "Aynı bileşenler [data-palette=cb] altında: Ekip, Olaylar, bedel satırı, üst bar, şerit.", body, 'data-palette="cb"')


# ------------------------------------------------------------------ page 9: layout and window sizes
WINDOW_TABLE = [
    # name, today, 1920 (w x h), 1536 (w x h), BuildHUD at 1920
    ("Ekip", "1200×720", "1352 × ≤928", "1352 × ≤712", "açık"),
    ("Olaylar", "900×640", "1240 × 900", "1240 × 712", "açık"),
    ("Ürün", "1424×960", "1424 × 928", "1424 × 712*", "gizli"),
    ("Satış", "1280×760", "1280 × 760", "1280 × 712*", "açık"),
    ("Finans", "1410×700", "1344 × 720", "1344 × 712*", "açık"),
    ("Ar-Ge", "1280×780", "1280 × 780", "1280 × 712*", "açık"),
    ("Kişisel", "1000×640", "1000 × 680", "1000 × 680", "açık"),
    ("Pazarlama", "900×640", "720 × 400", "720 × 400", "açık"),
    ("Dosya", "380×580", "360 × ≤928", "360, üstte", "gizli"),
    ("Atlas", "1440, 1560", "1440, 1560", "≤1424", "üstte"),
]


def p9():
    def frame(W, H, k, rail_w, wins, label, x0, y0):
        out = ['<div class="abs" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx;overflow:hidden;border:1px solid var(--line-2)">' % (x0, y0, W * k, H * k)]
        out.append('<div class="office is-dimmed" style="background-image:url(%s/office_full.png);background-size:cover;background-position:center"></div>' % ART)
        out.append('<div class="abs" style="left:0;top:0;width:100%%;height:%dpx;background:var(--surface-1);border-bottom:1px solid var(--line-1)"></div>' % (64 * k))
        out.append('<div class="abs" style="left:0;top:%dpx;width:%dpx;bottom:%dpx;background:var(--surface-1);border-right:1px solid var(--line-1)"></div>' % (64 * k, rail_w * k, 40 * k))
        out.append('<div class="abs" style="left:0;bottom:0;width:100%%;height:%dpx;background:var(--surface-0);border-top:1px solid var(--line-1)"></div>' % (40 * k))
        out.append('<div class="abs" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx;border:1px dashed var(--ink-3);border-radius:3px"></div>'
                   % ((W - 24 - 320) * k, 88 * k, 320 * k, 124 * k))
        for name, x, y, w, h, c, anchor in wins:
            out.append('<div class="abs" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx;border:2px solid %s;border-radius:4px;background:rgba(30,27,24,.35)"></div>' % (x * k, y * k, w * k, h * k, c))
            ly = (y + h) * k - 20 if anchor == "bottom" else y * k + 4
            out.append('<div class="abs t-caption" style="left:%dpx;top:%dpx;color:%s;background:var(--surface-0);padding:0 6px;border-radius:2px">%s %d×%d</div>' % (x * k + 6, ly, c, name, w, h))
        out.append('</div><div class="abs t-label" style="left:%dpx;top:%dpx;color:var(--ink-3)">%s</div>' % (x0, y0 - 22, label))
        return "".join(out)
    c1, c2 = "var(--ink-1)", "var(--topic-mentor)"
    k = 0.27
    body = frame(1920, 1080, k, 184, [("Ürün", 208, 88, 1424, 928, c2, "bottom"), ("Ekip", 208, 88, 1352, 720, c1, "top")],
                 "1920×1080 · ray 184 · alan 1688×928", 48, 116)
    body += frame(1536, 864, k, 64, [("Ürün", 88, 88, 1424, 712, c2, "bottom"), ("Ekip", 88, 88, 1352, 712, c1, "top")],
                  "1536×864 (1.25) · simge ray · 1424×712", 606, 116)
    body += frame(1536, 960, k, 64, [("Ürün", 88, 88, 1424, 808, c2, "bottom"), ("Ekip", 88, 88, 1352, 720, c1, "top")],
                  "1536×960 (16:10, 1.25) · 1424×808", 1062, 116)
    body += frame(1920, 1200, k, 184, [("Ürün", 208, 88, 1424, 928, c2, "bottom"), ("Ekip", 208, 88, 1352, 720, c1, "top")],
                  "1920×1200 (16:10) · yalnız boy kazanır", 48, 470)
    body += frame(2560, 1080, k, 184, [("Ürün", 208, 88, 1424, 928, c2, "bottom"), ("Ekip", 208, 88, 1352, 720, c1, "top")],
                  "2560×1080 (21:9) · pencereler solda, hafta çubuğu 720'de durur", 606, 470)
    body += frame(3413, 960, 0.109, 184, [("Ekip", 208, 88, 1352, 720, c1, "top")],
                  "32:9 (5120×1440, mantıksal 3413×960)", 1500, 116)
    rows = "".join('<span class="t-data-strong" style="color:var(--ink-1)">%s</span><span class="t-data" style="color:var(--ink-3)">%s</span>'
                   '<span class="t-data">%s</span><span class="t-data">%s</span><span class="t-data" style="color:%s">%s</span>'
                   % (n, t, a, b, "var(--ink-3)" if h != "gizli" else "var(--ink-1)", h) for n, t, a, b, h in WINDOW_TABLE)
    body += ('<div class="abs" style="left:1340px;top:470px;width:532px"><div class="cap t-label">Pencere ölçüleri (mantıksal px)</div>'
             '<div style="display:grid;grid-template-columns:92px 96px 116px 104px 1fr;row-gap:3px;column-gap:8px">'
             '<span class="th t-label">Pencere</span><span class="th t-label">Bugün</span><span class="th t-label">1920</span><span class="th t-label">1536</span><span class="th t-label">BuildHUD</span>%s</div></div>'
             '<div class="abs" style="left:48px;top:860px;width:1824px"><div class="note" style="font-size:14px;line-height:21px;color:var(--ink-3)">Pencere x = ray + 24, y = 64 + 24; yükseklik içeriğe göre, en çok alan kadar. '
             "* 1536'da gövde kayar, başlık ve kontrol şeridi sabit. BuildHUD pencerelerin altında çizilir, açık pencere dikdörtgenine değerse gizlenir (kesik çerçeve). "
             "Dosya penceresi 1920'de Ekip'in sağına (x 1576), 1536'da Ekip'in üstüne sağdan biner. "
             "32:9 (5120×1440, mantıksal 3413×960; 1.25'te 2731×768): pencereler solda, ofis genişler, hafta çubuğu 720'de durur. "
             "Ölçek kapısı mantıksal 1536×864'e göre (SPEC §8): 1280×720'de %%125 yasal olur ve 12 px yazı 10 px çizilir (sayfa l2).</div></div>" % rows)
    return page("9", "Yerleşim", "Mantıksal genişliğe göre pencere alanı; 1536 en dar durum. 16:10 ve 21:9 ayrıca.", body)
