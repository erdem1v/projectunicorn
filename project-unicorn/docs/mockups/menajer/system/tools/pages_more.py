"""Sheet pages 10 to 16: portraits and avatars, charts and progress, Ürün/Ar-Ge/Satış parts, meeting and
onboarding, dialogs/tables/text, and the two English width pages."""
import json
import math
import os

import common
import crops
from common import T, ic, avatar, portrait, frank_candidates, founders, menajer, MENAJER, ART
from kit import (tag, pill, stamp, mor, xp, trait, fx, opt, opt_armed, stake_frank, topbar, rail, toast, buildhud, notice, ticker,
                 ekip_window, ib_row, stars, band_of)
from pages_core import page


# ------------------------------------------------------------------ page 10: portraits and avatars
def _guide(path, scale, label_x):
    """The crop rule drawn on one render: top, neck, hh, the small and large disc and the 4:5 card."""
    f = crops.figure(path)
    w, h = f["w"] * scale, f["h"] * scale
    x0, y0, d0 = crops.disc_box(path, 32)
    x1, y1, d1 = crops.disc_box(path, 96)
    cx, cy, cw, ch = crops.card_box(path, 256, 320)
    s = scale
    svg = ('<svg width="%d" height="%d" style="position:absolute;left:0;top:0">'
           '<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="none" stroke="var(--line-hover)" stroke-width="1.5" stroke-dasharray="6 4"/>'
           '<circle cx="%.1f" cy="%.1f" r="%.1f" fill="none" stroke="var(--ink-1)" stroke-width="1.5"/>'
           '<circle cx="%.1f" cy="%.1f" r="%.1f" fill="none" stroke="var(--ink-3)" stroke-width="1.5" stroke-dasharray="3 3"/>'
           '<line x1="0" x2="%d" y1="%.1f" y2="%.1f" stroke="var(--ink-3)" stroke-width="1"/>'
           '<line x1="0" x2="%d" y1="%.1f" y2="%.1f" stroke="var(--ink-3)" stroke-width="1"/>'
           '</svg>' % (w, h, cx * s, cy * s, cw * s, ch * s, (x0 + d0 / 2) * s, (y0 + d0 / 2) * s, d0 / 2 * s,
                       (x1 + d1 / 2) * s, (y1 + d1 / 2) * s, d1 / 2 * s, w, f["top"] * s, f["top"] * s, w, f["neck"] * s, f["neck"] * s))
    img = '<img src="%s" style="position:absolute;left:0;top:0;width:%dpx;height:%dpx" alt="">' % (common._src(path), w, h)
    lbl = ('<div class="abs t-caption" style="left:%dpx;top:%dpx;color:var(--ink-3)">top</div>'
           '<div class="abs t-caption" style="left:%dpx;top:%dpx;color:var(--ink-3)">boyun (hh = %d px)</div>' % (w + 8, f["top"] * s - 9, w + 8, f["neck"] * s - 9, f["hh"]))
    return ('<div style="position:relative;width:%dpx;height:%dpx;background:radial-gradient(ellipse 78%% 60%% at 50%% 32%%, var(--portrait-lit), var(--portrait-edge));border:1px solid var(--line-2);border-radius:6px;overflow:visible">%s%s%s</div>'
            % (w, h, img, svg, lbl))


def p10():
    f5 = menajer("portraits/founder_05.png")
    guide = _guide(f5, 0.4, 0)
    rule = ('<div class="cap t-label">Kırpım kuralı (Faz C bu kırpımları pişirir)</div><div style="display:flex;gap:120px;align-items:flex-start">%s'
            '<div style="display:grid;grid-template-columns:150px 1fr;row-gap:8px;column-gap:16px;align-items:baseline;width:420px">'
            '<span class="t-label" style="color:var(--ink-3)">Ölçü</span><span class="t-caption" style="color:var(--ink-2)">top: saçın tepesi · boyun: 25-70 %% bandındaki en dar satır · hh = boyun - top (baş ve boyun; çene yaklaşık 0,91 hh)</span>'
            '<span class="t-label" style="color:var(--ink-1)">Disk 24-48 (düz)</span><span class="t-caption" style="color:var(--ink-2)">baş ve boyun: çap hh / 0,77, merkez top + 0,55 hh; baş diskin yaklaşık %%70\'i</span>'
            '<span class="t-label" style="color:var(--ink-3)">Disk 64-96 (noktalı)</span><span class="t-caption" style="color:var(--ink-2)">baş ve omuz: çap hh / 0,55, merkez top + 0,78 hh</span>'
            '<span class="t-label" style="color:var(--line-hover)">Kart 4:5 (kesik)</span><span class="t-caption" style="color:var(--ink-2)">hh kartın %%53\'ü (çene-tepe %%48, 0,48 m stüdyo kadrajı), tepe üstten %%6; 256×320 kuyu, 260×325 seçim kartı</span>'
            '<span class="t-label" style="color:var(--ink-3)">Zemin</span><span class="t-caption" style="color:var(--ink-2)">ışıklı zemin (portrait-lit → portrait-edge, radyal) kırpıma pişer; arayüz yalnız 1 px line-3 çember çizer</span>'
            '<span class="t-label" style="color:var(--ink-3)">Ayrım</span><span class="t-caption" style="color:var(--ink-2)">Frank\'in baş + saç çifti (adayın) LookSystem ve CounterpartSystem\'de ayrılır: hiçbir çalışan ve karşı taraf aynı çifti almaz (A adayı bugün kadro #17 ve Bosphorus analistiyle çakışıyor)</span>'
            '</div></div>' % guide)
    # avatar ladder: lit ground vs the old flat disc, Burak's near-black hair is the test case
    sizes = [24, 32, 40, 48, 64, 96]
    lit = "".join('<div style="display:flex;flex-direction:column;align-items:center;gap:6px">%s<span class="sw-m">%d</span></div>' % (avatar("burak", s), s) for s in sizes)
    flat = "".join('<div style="display:flex;flex-direction:column;align-items:center;gap:6px">%s</div>'
                   % avatar("burak", s).replace('class="av ', 'style="background:var(--surface-5);box-shadow:0 0 0 1px var(--line-2)" class="av ') for s in sizes)
    states = ('<div style="display:flex;gap:28px;align-items:center;margin-top:16px">'
              '<div style="display:flex;flex-direction:column;align-items:center;gap:6px">%s<span class="sw-m">normal</span></div>'
              '<div style="display:flex;flex-direction:column;align-items:center;gap:6px">%s<span class="sw-m">izinde (gri)</span></div>'
              '<div style="display:flex;flex-direction:column;align-items:center;gap:6px">%s<span class="sw-m">ayrıldı</span></div>'
              '<div style="display:flex;flex-direction:column;align-items:center;gap:6px"><span class="av av-48 is-loading">%s</span><span class="sw-m">yükleniyor</span></div>'
              '<div style="display:flex;flex-direction:column;align-items:center;gap:6px">%s<span class="sw-m">kurucu</span></div>'
              '<div style="display:flex;flex-direction:column;align-items:center;gap:6px">%s<span class="sw-m">VC (Meridian)</span></div>'
              '<span class="note" style="max-width:280px">Büstler kare başına bir tane yüklenir: o sırada disk boş zemin ve baş silüeti (line-2), pop yok. '
              'Ayrılan kişi gri ve soluk; İzindeki yalnız gri (sayılar tam).</span></div>'
              % (avatar("selin", 48), avatar("mert", 48, "is-grey"),
                 avatar("selin", 48, "is-gone"), ic("head"), avatar("kurucu", 48), avatar(menajer("art/busts/vc/bust_meridian_0_vc_lead.png"), 48)))
    ladder = ('<div class="cap t-label" style="margin-top:20px">Avatar boyları: ışıklı zemin (üstte) ve eski düz disk (altta)</div>'
              '<div style="display:flex;gap:24px;align-items:flex-end">%s</div><div style="display:flex;gap:24px;align-items:flex-end;margin-top:12px">%s</div>%s'
              '<div class="note" style="margin-top:10px">Burak\'ın neredeyse siyah saçı düz surface-5 diskte kayboluyor (1,4:1); ışıklı zeminde silüet okunur (contrast.py: koyu saç ile zemin merkezi %s:1). '
              '24 konuşmacı şeridi · 32 satır ve kutu · 40 dosya · 48 tanışma · 64 karşı taraf · 96 toplantı.</div>'
              % (lit, flat, states, _hair_ratio()))
    left = '<div class="abs" style="left:48px;top:92px;width:880px">%s%s</div>' % (rule, ladder)

    # Frank candidates in the real pane
    cells = []
    for p in frank_candidates():
        letter = os.path.basename(p).split("_")[-1][0].upper()
        crops_row = "".join('<div style="display:flex;flex-direction:column;align-items:center;gap:4px">%s<span class="sw-m">%d</span></div>' % (avatar(p, s), s) for s in (48, 32, 24))
        cells.append('<div class="pane-demo" style="padding:16px;display:flex;gap:16px">%s<div style="display:flex;flex-direction:column;gap:12px;min-width:0">'
                     '<div class="t-subhead" style="color:var(--ink-1)">Aday %s</div><div style="display:flex;gap:12px;align-items:flex-end">%s</div>'
                     '<div class="t-caption" style="color:var(--ink-3)">%s</div></div></div>'
                     % (portrait(p, 256, 320), letter, crops_row, CAND_NOTE.get(letter, "")))
    right = ('<div class="abs" style="left:968px;top:92px;width:904px"><div class="cap t-label">Frank adayları okuma bölmesinde (256×320 kuyu, ışıklı zemin) ve 48 / 32 / 24 kırpımları</div>'
             '<div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">%s</div>'
             '<div class="note" style="margin-top:10px">A3\'ün güncel çekimi kırpım kuralıyla kesildi (0,48 m kadraj). Işık kurgusu (3/4 anahtar, sıcak dolgu, kontur ışığı) ve '
             'koyu takımın kuyuda erimesi A3\'te düzelir; bu sayfa her derlemede portraits/ klasörünün son halini okur.</div></div>' % "".join(cells))
    return page("10", "Portre ve avatar", "Kırpım kuralı, ışıklı zemin, boylar ve durumlar; Frank adayları gerçek okuma bölmesinde.", left + right)


CAND_NOTE = {
    "A": "Baş + saç çifti kadrodaki #17 ve Bosphorus analistiyle aynı: seçilirse çift ayrılmalı.",
    "B": "Lacivert takım kuyu zemininde eriyor (1,02:1 düz zeminde); ışıklı zemin ve kontur ışığı gerekir.",
    "C": "Kahverengi takım düz zeminde 1,8-2,3:1.",
    "D": "En yüksek ayrım (4-5:1). Sayfalardaki yer tutucu bu aday; seçim Erdem'in.",
}


def _hair_ratio():
    import contrast
    lit = common.STD.colour("--portrait-lit")
    return "%.1f" % contrast.ratio((6, 1, 0, 1.0), lit)


# ------------------------------------------------------------------ page 11: charts and progress
def cash_curve(w=1100, h=380):
    """Seed-like run (örnek): seed money in week 6, burn after hiring, cash hits zero in week 27 on the current path."""
    hist = [48, 47, 46, 45, 44, 238, 236, 232, 226, 219, 211, 202, 192, 181]       # weeks 1..14, $K
    proj = [181, 168, 155, 142, 129, 116, 103, 90, 77, 64, 51, 38, 25, 12, -1, -14, -27]   # weeks 14..30
    weeks = 30
    pad_l, pad_r, pad_t, pad_b = 64, 24, 16, 40
    ymin, ymax = -40, 250
    X = lambda wk: pad_l + (wk - 1) / (weeks - 1) * (w - pad_l - pad_r)
    Y = lambda v: pad_t + (ymax - v) / (ymax - ymin) * (h - pad_t - pad_b)
    grid = "".join('<line class="ch-grid" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/><text class="ch-lbl" x="%d" y="%.1f" text-anchor="end">%s</text>'
                   % (pad_l, w - pad_r, Y(v), Y(v), pad_l - 10, Y(v) + 4, ("$%dK" % v) if v else "$0") for v in (50, 100, 150, 200, 250))
    grid += '<text class="ch-lbl" x="%d" y="%.1f" text-anchor="end">$0</text>' % (pad_l - 10, Y(0) + 4)
    xt = "".join('<text class="ch-lbl" x="%.1f" y="%d" text-anchor="middle">H%d</text>' % (X(wk), h - 14, wk) for wk in (1, 6, 10, 14, 18, 22, 26, 30))
    line = " ".join("%.1f,%.1f" % (X(i + 1), Y(v)) for i, v in enumerate(hist))
    pline = " ".join("%.1f,%.1f" % (X(14 + i), Y(v)) for i, v in enumerate(proj))
    zero_wk = 14 + 14 - 1 / 13   # crossing between week 27 and 28
    zx = X(27.92)
    neg_poly = "%.1f,%.1f " % (zx, Y(0)) + " ".join("%.1f,%.1f" % (X(14 + i), Y(v)) for i, v in enumerate(proj) if v < 0) + " %.1f,%.1f" % (X(30), Y(0))
    pos_area = "%.1f,%.1f " % (X(1), Y(0)) + line + " %.1f,%.1f" % (X(14), Y(0))
    hover_wk, hover_v = 9, 226
    svg = ('<svg width="%d" height="%d">%s<line class="ch-axis" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/>'
           '<polygon class="ch-pos" points="%s"/><polygon class="ch-neg" points="%s"/>'
           '<polyline class="ch-line" points="%s"/><polyline class="ch-proj" points="%s"/>'
           '<line class="ch-now" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/><text class="ch-lbl" x="%.1f" y="%d">Bugün · H14</text>'
           '<line class="ch-zero-mark" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/><text class="ch-lbl neg" x="%.1f" y="%d" text-anchor="end">Kasa sıfır · H28</text>'
           '<line x1="%.1f" x2="%.1f" y1="%d" y2="%d" stroke="var(--line-hover)" stroke-width="1"/>'
           '<circle class="ch-dot" cx="%.1f" cy="%.1f" r="5" style="stroke-width:2;paint-order:stroke"/>'
           '<circle cx="%.1f" cy="%.1f" r="4" fill="var(--chart-line)" stroke="var(--surface-3)" stroke-width="2"/>'
           '%s</svg>'
           % (w, h, grid, pad_l, w - pad_r, Y(0), Y(0), pos_area, neg_poly, line, pline,
              X(14), X(14), pad_t, h - pad_b, X(14) + 6, pad_t + 12, zx, zx, pad_t, h - pad_b, zx - 6, pad_t + 12,
              X(hover_wk), X(hover_wk), pad_t, h - pad_b, X(hover_wk), Y(hover_v), X(14), Y(181), xt))
    tip = ('<div class="tip rich" style="position:absolute;left:%dpx;top:%dpx;min-width:190px"><span class="tip-t">Hafta 9 · Şubat 2026</span>'
           '<span class="tip-b" style="color:var(--ink-2)">Kasa $226.000</span><span class="tip-b">Net −$44,0K/ay · Runway 5 ay</span></span></div>'
           % (X(hover_wk) + 14, Y(hover_v) - 4))
    return '<div class="chart" style="position:relative;width:%dpx;height:%dpx">%s%s</div>' % (w, h, svg, tip)


def spark(vals, w=120, h=28):
    lo, hi = min(vals), max(vals)
    pts = " ".join("%.1f,%.1f" % (i / (len(vals) - 1) * (w - 4) + 2, h - 3 - (v - lo) / (hi - lo or 1) * (h - 6)) for i, v in enumerate(vals))
    lx, ly = pts.split()[-1].split(",")
    return ('<svg class="spark" width="%d" height="%d"><polyline class="ch-line" points="%s" style="stroke:var(--ink-3)"/>'
            '<circle cx="%s" cy="%s" r="3" fill="var(--ink-1)" stroke="var(--surface-3)" stroke-width="2"/></svg>' % (w, h, pts, lx, ly))


def p11():
    filt = ('<div style="display:flex;align-items:center;gap:16px;margin-bottom:12px"><div class="seg" style="height:32px;border-bottom:1px solid var(--line-1)">'
            '<span class="seg-tab t-tab" style="font-size:14px">6 ay</span><span class="seg-tab t-tab is-active" style="font-size:14px">12 ay</span><span class="seg-tab t-tab" style="font-size:14px">Tümü</span></div>'
            '<div class="ch-legend t-caption" style="margin-left:auto"><span><i></i>Gerçekleşen kasa</span><span><i class="proj"></i>Mevcut gidişle</span><span><i class="neg"></i>Sıfırın altı</span></div></div>')
    chart = ('<div class="cap t-label">Kasa eğrisi (Finans · Özet; CashCurve)</div><div class="pane-demo" style="padding:16px 20px">%s%s</div>'
             '<div class="note" style="margin-top:8px">Tek eksen. Izgara ve eksen kesintisiz ince çizgi; kesik çizgi yalnız tahmin ve eşik (Bugün, Kasa sıfır). Kırmızı yalnız sıfırın altındaki alan ve sıfır işareti. '
             'Üstünde dikey imleç, 2 px zemin halkalı nokta ve ipucu (hafta, kasa, net, runway). Seri etiketi mürekkep, renk değil. Veriler örnek.</div>' % (filt, cash_curve()))
    tiles = ('<div class="cap t-label" style="margin-top:20px">Değer kutusu ve kıvılcım çizgisi</div><div style="display:flex;gap:16px">'
             + "".join('<div class="pane-demo" style="padding:14px 18px;width:254px"><div class="t-label" style="color:var(--ink-3)">%s</div>'
                       '<div style="display:flex;align-items:flex-end;gap:12px;margin-top:4px"><span class="t-kpi" style="color:var(--ink-1);font-variant-numeric:normal">%s</span>%s</div>'
                       '<div class="t-caption" style="color:%s;margin-top:2px">%s</div></div>' % (k, v, spark(s), c, d)
                       for k, v, s, c, d in (("MRR", "$4,0K", [1.2, 1.4, 1.9, 2.0, 2.6, 2.8, 3.1, 3.6, 4.0], "var(--pos)", "+$1,2K bu ay"),
                                             ("Burn", "$1,5K", [1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5], "var(--ink-3)", "değişmedi"),
                                             ("Müşteri", "3", [0, 0, 1, 1, 2, 2, 2, 3, 3], "var(--pos)", "+1 bu ay")))
             + '</div><div class="note" style="margin-top:8px">Kıvılcım çizgisi ink-3, son nokta ink-1; değişim satırının rengi yön × iyi mi (artan burn kötü). Büyük sayıda orantılı rakam.</div>')
    shares = ('<div class="cap t-label">Gider dökümü: sıralı paylar</div><div class="pane-demo" style="padding:16px 20px">'
              '<div class="share">'
              '<span class="k">Maaşlar</span><span class="t"><span class="emph" style="width:95%"></span></span><span class="v">%95</span>'
              '<span class="k">Araçlar</span><span class="t"><span style="width:5%"></span></span><span class="v">%5</span></div>'
              '<div class="t-caption" style="color:var(--ink-3);margin:14px 0 8px">Daha çok kalem (örnek)</div><div class="share">'
              '<span class="k">Maaşlar</span><span class="t"><span class="emph" style="width:71%"></span></span><span class="v">%71</span>'
              '<span class="k">Ofis kirası</span><span class="t"><span style="width:16%"></span></span><span class="v">%16</span>'
              '<span class="k">Altyapı</span><span class="t"><span style="width:9%"></span></span><span class="v">%9</span>'
              '<span class="k">Araçlar</span><span class="t"><span style="width:4%"></span></span><span class="v">%4</span></div>'
              '<div class="t-caption" style="color:var(--ink-3);margin:14px 0 8px">Tek çubuk özeti</div>'
              '<div class="stackbar"><span style="width:71%;background:var(--bar-emph)"></span><span style="width:16%;background:var(--bar-fill)"></span><span style="width:9%;background:var(--bar-fill)"></span><span style="width:4%;background:var(--bar-fill)"></span></div>'
              '</div><div class="note" style="margin-top:8px">Pasta yerine sıralı çubuk: kategoriler adlı, renk kimlik taşımaz (sistemde yeni ton yok). En büyük pay vurgu mürekkebi, gerisi tek ton; '
              'değer çubuk ucunda. Tek çubuk özeti 2 px boşlukla bölünür.</div>')
    flow = ('<div class="cap t-label" style="margin-top:20px">Aylık akış</div><div class="pane-demo" style="padding:16px 20px"><div class="share">'
            '<span class="k">Gelir</span><span class="t"><span style="width:4%;background:var(--pos)"></span></span><span class="v" style="color:var(--pos)">+$1,9K</span>'
            '<span class="k">Gider</span><span class="t"><span style="width:100%;background:var(--bar-fill)"></span></span><span class="v">−$45,8K</span>'
            '<span class="k">Net</span><span class="t"><span style="width:96%;background:var(--neg)"></span></span><span class="v" style="color:var(--neg)">−$44,0K</span></div></div>')
    prog = ('<div class="cap t-label">İlerleme</div><div class="pane-demo" style="padding:16px 20px;display:flex;flex-direction:column;gap:14px">'
            '<div><div class="t-caption" style="color:var(--ink-3);margin-bottom:6px">Traction\'a · sürüm + ilk müşteri + ilk gelir</div><div class="prog is-done"><div class="prog-t"><div class="prog-f" style="width:100%"></div></div><span class="prog-v">3/3</span></div></div>'
            '<div><div class="t-caption" style="color:var(--ink-3);margin-bottom:6px">Eğitim · Selin Kaya</div><div class="prog"><div class="prog-t"><div class="prog-f" style="width:40%"></div></div><span class="prog-v">2/5 hafta</span></div></div>'
            '<div class="bb"><div class="bb-top"><span class="t-label" style="color:var(--ink-1)">Tasarım</span><span class="t-caption" style="color:var(--ink-3)">BuildBar · tek çubuk dolar, sonra yeniden başlar</span><span class="v">3/4</span></div>'
            '<div class="bb-t"><div class="bb-f" style="width:75%"></div><i class="bb-cap" style="left:25%"></i><i class="bb-cap" style="left:50%"></i><i class="bb-cap" style="left:75%"></i></div></div>'
            '<div class="bb"><div class="bb-top"><span class="t-label" style="color:var(--ink-1)">Geliştirme</span><span class="t-caption" style="color:var(--ink-3)">park edilmiş</span><span class="v">1/4</span></div>'
            '<div class="bb-t"><div class="bb-f" style="width:25%;background:var(--ink-3)"></div><i class="bb-cap" style="left:25%"></i><i class="bb-cap" style="left:50%"></i><i class="bb-cap" style="left:75%"></i></div></div>'
            '</div><div class="note" style="margin-top:8px">İlerleme rengi yargı taşımaz (bar-fill); biten ink-2. BuildBar hücre değil tek çubuk, tavan çentiklerle.</div>')
    research = ('<div class="cap t-label" style="margin-top:20px">Araştırma çubuğu (yüzen) ve yükleme perdesi</div><div style="display:flex;gap:16px;align-items:flex-start">'
                '<div class="float" style="width:320px;padding:12px 16px"><div style="display:flex;align-items:center;gap:8px">%s<span class="t-label" style="color:var(--ink-1)">Ar-Ge</span>'
                '<span class="t-caption" style="color:var(--ink-3);margin-left:auto">3 hafta kaldı</span></div><div class="t-body-strong" style="color:var(--ink-2);margin:6px 0 8px">Veri Modeli</div>'
                '<div class="prog"><div class="prog-t"><div class="prog-f" style="width:60%%"></div></div><span class="prog-v">%%60</span></div></div>'
                '<div style="position:relative;width:320px;height:180px;border:1px solid var(--line-2);border-radius:6px;overflow:hidden"><div class="curtain">'
                '<span class="t-subhead" style="color:var(--ink-1)">Unicorn Inc.</span><span class="t-meta" style="color:var(--ink-3)">Ofis hazırlanıyor</span>'
                '<div class="prog" style="width:200px"><div class="prog-t" style="height:2px"><div class="prog-f" style="width:65%%"></div></div></div></div></div></div>'
                % ic("arge", 18, "var(--ink-3)"))
    body = ('<div class="abs" style="left:48px;top:92px;width:1140px">%s%s%s</div>'
            '<div class="abs" style="left:1236px;top:92px;width:636px">%s%s</div>'
            '<div class="abs" style="left:1236px;top:640px;width:636px">%s</div>' % (chart, tiles, research, shares, flow, prog))
    return page("11", "Grafik ve ilerleme", "Kasa eğrisi, değer kutusu, gider dökümü, aylık akış, ilerleme, BuildBar, araştırma çubuğu, yükleme perdesi.", body)


# ------------------------------------------------------------------ page 12: product, R&D, sales parts
def sprint_card(title, state, step, kind, roles, bug=0, voices=0, note=""):
    steps = []
    for i, s in enumerate(("Tasarım", "Geliştirme", "Test")):
        st = "done" if i < step else ("now" if i == step else "")
        if i:
            steps.append('<span class="ln"></span>')
        steps.append('<span class="sc-step %s"><i></i>%s</span>' % (st, s))
    meta = []
    if bug:
        meta.append('<span class="bug">%s%d</span>' % (ic("bug"), bug))
    if voices:
        meta.append('<span class="bug">%s%d</span>' % (ic("voices"), voices))
    if note:
        meta.append(note)
    return ('<div class="sc %s"><div class="sc-top">%s<span class="t">%s</span><span class="roles">%s</span></div>'
            '<div class="sc-steps">%s</div>%s%s</div>'
            % (state, ic(kind, 16, "var(--ink-3)"), title, "".join(ic(r, 16) for r in roles), "".join(steps),
               ('<div class="sc-meta">%s</div>' % "".join(meta)) if meta else "", stamp("Bitti") if state == "is-done" else ""))


def p12():
    cards = ('<div class="cap t-label">Sprint kartı: planlı, sürüyor, gecikti, bitti</div><div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">'
             + sprint_card("Bulut Eşitleme", "is-planned", -1, "k_feature", ["sk_design", "sk_eng"], note='<span class="t-caption" style="color:var(--ink-3)">Sonraki sprint</span>')
             + sprint_card("Anında Arama", "", 1, "k_feature", ["sk_design", "sk_eng", "sk_qa"], bug=0, voices=2)
             + sprint_card("Not Bağlantısı", "is-late", 2, "k_fix", ["sk_eng", "sk_qa"], bug=3, note=tag("1 hafta gecikti", "warn"))
             + sprint_card("Hızlı Not", "is-done", 3, "k_polish", ["sk_design", "sk_eng", "sk_qa"])
             + '</div><div class="sc" style="margin-top:12px;display:flex;align-items:center;gap:12px"><span class="gate-dot" style="width:8px;height:8px;box-shadow:0 0 0 3px var(--accent-glow)"></span>'
             '<span class="t-data" style="color:var(--ink-2)">Metin Editörü · Elif Demir: <i>Dışarıdan destek</i></span><span class="t-caption" style="color:var(--ink-3)">karar Olaylar\'da</span>'
             '<span class="btn btn-secondary btn-sm" style="margin-left:auto">Karara git</span></div>'
             '<div class="note" style="margin-top:8px">Tür ve rol ikonları 16 px (12\'de böcek ve mercek okunmuyor). Böcek ve ses sayıları nötr çip; gecikme uyarı etiketi, tehlike değil. '
             'Sprint kararı kartta açılmaz: kart Olaylar\'daki karara gider (saat ailesi noktası). Sprint adları baseline\'dan.</div>')
    # R&D mini tree
    nodes = [("Veri Modeli", "kök · bitti", "is-done", 24, 30), ("Olay Kaydı", "araştırılıyor", "is-active", 24, 130), ("Rol Yetkisi", "araştırılabilir", "is-available", 214, 130),
             ("? Ürün", "kilitli", "is-locked", 24, 230), ("Akış Analizi", "keşfedildi", "is-discovered", 214, 230)]
    nd = "".join('<div class="rn %s" style="left:%dpx;top:%dpx"><span class="t">%s</span><span class="s">%s</span>%s</div>'
                 % (st, x, y, t, s, '<div class="prog"><div class="prog-t" style="height:4px"><div class="prog-f" style="width:60%"></div></div></div>' if st == "is-active" else "")
                 for t, s, st, x, y in nodes)
    edges = ('<svg width="420" height="300" style="position:absolute;left:0;top:0">'
             '<path class="re" d="M104 94 V112 M104 112 V130 M104 112 H294 V130"/><path class="re is-locked" d="M104 194 V230"/>'
             '<path class="re is-cross" d="M294 194 V230"/><path class="re is-cross" d="M380 250 H400"/></svg>')
    tree = ('<div class="cap t-label" style="margin-top:20px">Ar-Ge ağacı: düğüm ve bağ durumları</div><div style="display:flex;gap:20px">'
            '<div class="pane-demo" style="position:relative;width:420px;height:310px">%s%s</div>'
            '<div style="display:flex;flex-direction:column;gap:8px;padding-top:8px" class="t-caption">'
            '<span><b style="color:var(--ink-1)">Bitti</b> surface-5, ad ink-3</span><span><b style="color:var(--ink-1)">Sürüyor</b> surface-4, kenar ink-2, ilerleme</span>'
            '<span><b style="color:var(--ink-1)">Araştırılabilir</b> kenar line-hover</span><span><b style="color:var(--ink-1)">Keşfedildi</b> yeni açılan, kenar line-hover, surface-4</span>'
            '<span><b style="color:var(--ink-1)">Kilitli</b> kesik kenar, ad ink-off</span><span><b style="color:var(--ink-1)">Bağ</b> aile içi düz line-3; kilitli kesik; başka aileden gereksinim noktalı ink-4</span>'
            '<span style="color:var(--ink-3)">Amber yok: araştırma bir zaman durumu değil.</span></div></div>' % (edges, nd))
    goal = ('<div class="cap t-label" style="margin-top:20px">Çeyrek hedef şeridi</div>'
            '<div class="goal is-hover"><span class="t-label" style="color:var(--ink-3)">Ç2 hedefi</span><span class="g t-data" style="color:var(--ink-1)">Yeni kullanıcıların yarısı kalsın</span>'
            '<div class="prog"><div class="prog-t"><div class="prog-f" style="width:40%%"></div></div><span class="prog-v">şu an %%20</span></div>%s</div>'
            '<div class="note" style="margin-top:6px">Hedef menüsü üstünde kenarla açılır (PopupMenu). Hedef metni PRODUCT_GOAL_*; ilerleme yargısız dolgu. Değer örnek.</div>' % ic("chevdown", 16, "var(--ink-3)"))
    left = '<div class="abs" style="left:48px;top:92px;width:900px">%s%s%s</div>' % (cards, tree, goal)

    deal = lambda co, st, line, w: ('<div class="deal"><div class="deal-top"><span class="t">%s</span>%s<span class="w">%s</span></div><div class="line">%s</div>'
                                    '<div class="acts"><span class="btn btn-ghost btn-sm">Ayır</span><span class="btn btn-secondary btn-sm">Temsilciye ver</span>'
                                    '<span class="btn btn-secondary btn-sm">Görüşmeye git</span></div></div>' % (co, stars(st), w, line))
    pipeline = ('<div class="cap t-label">Satış: boru hattı ve aday kartı</div><div class="lane"><div class="lane-h t-label">Boru hattı<span class="n">Akış 6,5/hafta</span></div>%s%s</div>'
                '<div class="note" style="margin-top:8px">Listede her kartın eylemi ikincil; amber yalnız bölmenin tek birincil eyleminde (burada yok). Yıldızlar A2 ikonları (★ fontta yok).</div>'
                % (deal("Karadeniz Fabrika", 2, "Ölçülü bir alıcı. Önce kararlılığı sorar.", "1 hafta"), deal("Efes Emlak", 1, "Hızlı konuşur, rakama erken gelir.", "1 hafta")))
    acct = ('<div class="cap t-label" style="margin-top:20px">Müşteri kartı: memnuniyet, söz, churn</div>'
            '<div class="deal" style="border-color:var(--neg-line);background:var(--neg-bg)"><div class="deal-top"><span class="t">Ege Sigorta</span>%s%s</div>'
            '<div class="line">$1,0K/ay · 12 koltuk · 2 aydır müşteri</div><div class="line"><i>Sebep: sık kesinti şikayeti</i></div>'
            '<div style="display:flex;align-items:center;gap:16px;margin-top:10px"><span class="t-label" style="color:var(--ink-3)">Memnuniyet</span>'
            '<div class="sat lo"><span class="sat-v">25</span><div class="sat-t"><div class="sat-f" style="width:25%%"></div></div></div>'
            '<span class="churn">Churn\'e ~2 hafta<span class="pips"><i class="on"></i><i class="on"></i><i></i></span></span></div>'
            '<div style="display:flex;align-items:center;gap:8px;margin-top:10px"><span class="promise is-due">%sAçık söz: Dışa aktarım · bu hafta</span>'
            '<span class="t-caption" style="color:var(--ink-3);margin-left:auto">Müşteri temsilcisi: atanmadı</span><span class="btn btn-secondary btn-sm">Değiştir</span></div></div>'
            '<div class="deal" style="margin-top:8px"><div class="deal-top"><span class="t">Nordica</span>%s%s</div>'
            '<div style="display:flex;align-items:center;gap:16px;margin-top:8px"><span class="t-label" style="color:var(--ink-3)">Memnuniyet</span>'
            '<div class="sat hi"><span class="sat-v">72</span><div class="sat-t"><div class="sat-f" style="width:72%%"></div></div></div>'
            '<span class="promise">%sAçık söz: Rapor ekranı · 3 hafta</span></div></div>'
            '<div class="note" style="margin-top:8px">Memnuniyet ölçeri görünen katmanı çizer; ikinci katman (tolerans) gizli kalır, çizilmez (B2BSalesSystem). '
            'Churn sayacı tehlike: kalan hafta kadar dolu kare. Açık söz kesik kenarlı not; son haftası uyarı.</div>'
            % (stars(3), tag("Risk altında", "risk"), ic("calendar"), stars(3), tag("Büyümek istiyor", "pos"), ic("calendar")))
    desk = ('<div class="cap t-label" style="margin-top:20px">Satış masası: temsilci ve bant</div>'
            '<div class="deal" style="display:flex;align-items:center;gap:16px">%s<div><div class="t-body-strong" style="color:var(--ink-1)">Burak Şahin</div>%s</div>'
            '<div style="margin-left:auto;display:flex;align-items:center;gap:12px"><span class="t-caption" style="color:var(--ink-3)">Çalıştığı bant:</span>'
            '<span class="segpick"><span>1%s</span><span>2%s</span><span>3%s</span><span class="is-on">Kendi ligi</span></span></div></div>'
            '<div class="note" style="margin-top:6px">Bant seçici bölüm sekmesinin küçüğü: seçili mürekkep ve alt çizgi, amber değil. Yıldız fontta değil, ikon.</div>'
            % (avatar("burak", 40), stars(3), ic("star"), ic("star"), ic("star")))
    right = '<div class="abs" style="left:996px;top:92px;width:876px">%s%s%s</div>' % (pipeline, acct, desk)
    return page("12", "Ürün, Ar-Ge ve Satış parçaları", "Sprint kartı durumları, Ar-Ge düğümleri ve bağları, boru hattı, müşteri kartı.", left + right)


# ------------------------------------------------------------------ page 13: meeting and onboarding
def p13():
    vc = menajer("art/busts/vc/bust_meridian_0_vc_lead.png")
    vc2 = menajer("art/busts/vc/bust_meridian_1_vc_partner.png")
    vc3 = menajer("art/busts/vc/bust_meridian_2_vc_analyst.png")
    seat = lambda p, n, pct, lead=False: ('<div class="seat%s"><div class="ring" style="--p:%d;--ring-c:%s">%s</div><span class="n">%s · %%%d</span></div>'
                                           % (" is-lead" if lead else "", pct, "var(--ink-1)" if lead else "var(--ink-3)", avatar(p, 48), n, pct))
    key = lambda k: ('<span class="t-label" style="width:24px;height:24px;flex:none;border:1px solid var(--line-3);border-radius:4px;display:flex;align-items:center;'
                     'justify-content:center;color:var(--ink-3)">%s</span>' % k)
    dock = ('<div class="cap t-label">Görüşme paneli (sağ dok, 0,34 W)</div><div class="pane-demo" style="padding:20px 24px">'
            '<div class="t-meta" style="color:var(--ink-3)">Yatırımcı görüşmesi · Odayı oku · 1/4</div>'
            '<div style="display:flex;align-items:center;gap:16px;margin-top:10px">%s<div><div class="t-h2" style="color:var(--ink-1)">Tolga Erdem</div>'
            '<div class="t-caption" style="color:var(--ink-3)">Büyüme Ortağı · Meridian Growth</div></div>'
            '<div style="margin-left:auto;display:flex;gap:16px;align-items:flex-start">%s%s%s</div></div>'
            '<div style="height:1px;background:var(--line-1);margin:16px 0"></div>'
            '<div class="dlg">%s<div class="dlg-b"><div class="dlg-n t-micro">Tolga Erdem</div><div class="dlg-t t-quote" style="font-size:18px;line-height:26px">"Meridian Growth. Otur. Vaktim kısa. Beni neden buraya çağırdığını göster."</div></div></div>'
            '<div class="dlg is-you" style="margin-top:12px">%s<div class="dlg-b"><div class="dlg-n t-micro">Kurucu</div><div class="dlg-t">Rakamlarla başlayayım: üç ayda MRR üç katına çıktı.</div></div></div>'
            '<div style="height:1px;background:var(--line-1);margin:16px 0"></div>'
            '<div class="t-meta" style="color:var(--ink-3)">Satış görüşmesi · Rakam</div>'
            '<div style="display:flex;align-items:center;gap:16px;margin-top:10px"><span class="t-label" style="color:var(--ink-3)">Koltuk fiyatı</span>'
            '<div class="stepper"><span class="b">%s</span><span class="v">$50</span><span class="b">%s</span></div>'
            '<span class="t-data" style="color:var(--ink-2)">49 koltuk × $50 = <b style="color:var(--ink-1)">$2.450 MRR</b></span>'
            '<span style="margin-left:auto;display:flex;align-items:center;gap:6px"><span class="t-label" style="color:var(--ink-3)">Sabır</span>'
            '<i style="width:12px;height:12px;border-radius:2px;background:var(--ink-2)"></i><i style="width:12px;height:12px;border-radius:2px;background:var(--ink-2)"></i><i style="width:12px;height:12px;border-radius:2px;border:1px solid var(--line-3)"></i></span></div>'
            '<div class="lever" style="margin-top:12px"><div class="lever-t"></div><div class="lever-g" style="left:50%%"></div>'
            '<span class="lever-tick" style="left:0%%;transform:none">$30</span><span class="lever-tick" style="left:50%%">$50</span><span class="lever-tick" style="left:100%%;transform:translateX(-100%%)">$70</span></div>'
            '<div style="display:flex;flex-direction:column;gap:8px;margin-top:28px">'
            '<div class="opt">%s<span class="opt-label" style="font-size:18px">Teklif et</span></div>'
            '<div class="opt is-hover">%s<span class="opt-label" style="font-size:18px">Masadan kalk</span></div>'
            '<div class="opt is-locked">%s<span class="opt-label" style="font-size:18px">Fiyatı indir</span><span class="opt-why">Bu masada bir kez indirdin.</span></div></div>'
            '<div class="note" style="margin-top:10px">Koltuk halkası ikna payıdır: dolgu ink-3, lider ink-1, yüzde yanında yazılı. Kurucu repliği belge köşeli kutuda. '
            'Toplantı kendi sahnesidir: 1-5 seçenek tuşları burada geçerli (Olaylar\'daki karardan farklı). Kaldıraç pazarlığın değerini gösterir; '
            'kabul aralığı gizli kaldığı için çizilmez. Kilit gerekçesi örnek.</div></div>'
            % (avatar(vc, 96), seat(vc, "Lider", 69, True), seat(vc2, "Ortak", 54), seat(vc3, "Analist", 40), avatar(vc, 32), avatar("kurucu", 32),
               ic("minus"), ic("plus"), key("1"), key("2"), ic("lock", 16)))
    left = '<div class="abs" style="left:48px;top:92px;width:900px">%s</div>' % dock

    fds = founders()
    lang = ('<div style="display:flex;flex-direction:column;gap:12px;width:316px"><div class="cap t-label">Dil kapısı</div>'
            '<div class="lang-opt is-hover" style="width:316px;height:100px"><span class="t">Türkçe</span><span class="s">Oyuna Türkçe başla</span></div>'
            '<div class="lang-opt" style="width:316px;height:100px"><span class="t">English</span><span class="s">Start the game in English</span></div>'
            '<div class="note">Dil kapısı ilk açılışta, iki eş seçenek; amber yok (birincil yok).</div></div>')
    pick = ('<div style="display:flex;gap:24px"><div><div class="cap t-label">Kurucu seçimi (260×325)</div><div style="display:flex;gap:16px">'
            '<div class="pcard is-selected">%s<span class="n">Kurucu 5</span></div><div class="pcard is-hover">%s<span class="n">Kurucu 2</span></div></div></div>%s</div>'
            % (portrait(fds[4], 260, 325), portrait(fds[1], 260, 325), lang))
    origin = ('<div class="cap t-label" style="margin-top:18px">Köken kartı</div><div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px">'
              '<div class="ocard is-selected"><div class="t">%s<span class="t-subhead" style="color:var(--ink-1)">Sıfırdan</span></div><div class="q">"Hiçbir şey yoktu. Her satırı ben yazdım."</div><div class="tags">%s%s</div></div>'
              '<div class="ocard is-locked"><div class="t">%s<span class="t-subhead">Mirasyedi</span>%s</div><div class="q">"Aile sermayesi arkanda. Ama gözler de üzerinde."</div><div class="t-caption" style="color:var(--ink-3)">Tam sürümde gelecek.</div></div>'
              '<div class="ocard is-locked"><div class="t">%s<span class="t-subhead">Kurumsal Firari</span>%s</div><div class="q">"On yıl büyük şirkette. Şimdi kendi adına."</div><div class="t-caption" style="color:var(--ink-3)">Çok yakında.</div></div></div>'
              % (ic("origin_self", 24), tag("Dayanıklı", "outline"), tag("Düşük sermaye", "outline").replace('">', '">−', 1),
                 ic("origin_heir", 24), ic("lock", 16, "var(--ink-off)"), ic("origin_corp", 24), ic("lock", 16, "var(--ink-off)")))
    skill = ('<div style="display:flex;gap:12px;margin-top:14px;align-items:stretch">'
             '<div class="sstep"><span class="t">Ürün</span><span class="d">Özellik kararları ve tasarım turları.</span><div class="pips">%s</div>'
             '<div class="stepper" style="align-self:flex-start"><span class="b">%s</span><span class="v">3</span><span class="b">%s</span></div></div>'
             '<div class="sstep" style="align-items:center;justify-content:center;width:132px"><span class="t-micro" style="color:var(--ink-3)">Kalan puan</span><span class="t-kpi" style="color:var(--ink-1)">6</span></div>'
             '<div><div class="t-label" style="color:var(--ink-3);margin-bottom:8px">Logo</div><div class="logo-pick">%s</div>'
             '<div class="note" style="margin-top:8px;max-width:270px">Köken etiketi iyi ya da kötü değil: nötr etiket, eksi işaretiyle bedel. Kilitli kartta gerekçe ink-3.</div></div></div>'
             % ("".join('<i class="%s"></i>' % ("on" if i < 3 else "") for i in range(10)), ic("minus"), ic("plus"),
                "".join('<span class="o%s">%s</span>' % (" is-selected" if i == 0 else "", _logo(i)) for i in range(4))))
    invite = ('<div class="cap t-label" style="margin-top:18px">Davet halkası, erteleme, yolculuk çipleri</div><div style="display:flex;gap:16px;align-items:center">'
              '<div class="invite" style="--p:62">%s</div>'
              '<div class="pane-demo doc" style="width:300px;padding:12px 16px"><div class="t-micro" style="color:var(--accent)">Gelen arama · 10:00</div>'
              '<div class="t-body-strong" style="color:var(--ink-1);margin-top:4px">Meridian Growth adına Sena Koç bu hafta görüşmek istiyor.</div>'
              '<div style="display:flex;gap:8px;margin-top:10px"><span class="btn btn-primary btn-sm">Kabul et</span><span class="btn btn-secondary btn-sm">Ertele</span></div></div>'
              '<div style="display:flex;flex-direction:column;gap:8px;align-items:flex-start">%s<span class="tchip is-here">%sMevcut · İş hanı</span><span class="tchip">%sYolda · Plaza katı · 2 saat</span></div></div>'
              % (avatar(vc2, 44), toast("", "Görüşme ertelendi", "Sonraki toplantıda ikna −2.", "calendar"), ic("crown"), ic("move")))
    right = '<div class="abs" style="left:996px;top:92px;width:876px">%s%s%s%s</div>' % (pick, origin, skill, invite)
    return page("13", "Toplantı ve açılış", "Görüşme dokunun parçaları; kurucu, dil, köken, beceri, logo; davet ve yolculuk.", left + right)


def _logo(i):
    shapes = ['<rect width="32" height="32" rx="6" fill="var(--ink-2)"/><path d="M9.5 8 H14 V18 A2 2 0 0 0 18 18 V8 H22.5 V18.2 A6.5 6.5 0 0 1 9.5 18.2Z" fill="var(--surface-1)"/>',
              '<circle cx="16" cy="16" r="15" fill="var(--topic-team)"/><path d="M10 10 L16 22 L22 10" fill="none" stroke="var(--surface-1)" stroke-width="3" stroke-linejoin="round"/>',
              '<rect width="32" height="32" rx="2" fill="var(--topic-mentor)"/><rect x="8" y="8" width="16" height="16" fill="var(--surface-1)"/>',
              '<path d="M16 2 L30 16 L16 30 L2 16 Z" fill="var(--topic-customer)"/><circle cx="16" cy="16" r="5" fill="var(--surface-1)"/>']
    return '<svg viewBox="0 0 32 32" width="32" height="32">%s</svg>' % shapes[i]


# ------------------------------------------------------------------ page 14: dialogs, dense table, text, office overlay
def _crowd():
    d = json.load(open(menajer("data/crowd40.json"), encoding="utf-8"))["people"]
    return d


ROLE_KEY = {"product_manager": "r_pm", "designer": "r_design", "developer": "r_dev", "tester": "r_qa", "sales_rep": "r_sales", "customer_rep": "r_cs", "founder": None}
ROLE_SAL = {"product_manager": 9800, "designer": 7400, "developer": 11200, "tester": 6900, "sales_rep": 8300, "customer_rep": 7100}


def dense_table(n=16):
    people = [p for p in _crowd() if p["role"] != "founder"][:n]
    import random as _r
    rr = _r.Random(424242)
    for p in people:
        p["_m"] = p["morale"] if p["morale"] != 50 else rr.choice([34, 46, 52, 58, 63, 67, 71, 74, 81])
    people.sort(key=lambda p: -p["_m"])
    cols = "40px 168px " + "40px " * 6 + "64px 128px 140px 74px 116px"
    heads = ['<div></div>', '<div class="th t-label">Çalışan</div>'] + ['<div class="th glyph">%s</div>' % ic(k, 16) for k in ("sk_product", "sk_design", "sk_eng", "sk_qa", "sk_sales", "sk_cs")]
    heads += ['<div class="th t-micro c" style="border-left:1px solid var(--line-1);align-self:stretch;align-items:flex-end">Liderlik</div>']
    heads += ['<div class="th t-label">Rol</div>', '<div class="th t-label">Huy</div>', '<div class="th t-label r" style="padding-right:12px">Maaş</div>', '<div class="th t-label is-sorted">Moral%s</div>' % ic("sort_down", 12, cls="sort")]
    out = ['<div class="grid tbl-head tbl-sticky is-stuck" style="grid-template-columns:%s;height:32px;padding-bottom:6px">%s</div>' % (cols, "".join(heads))]
    rows = []
    import random
    rnd = random.Random(424242)
    for i, p in enumerate(people):
        rs = p["role_stats"]
        sk = [rs[k] for k in ("product", "design", "engineering", "qa", "sales", "customer_success", "leadership")]
        mainv = max(sk[:6])
        idx = sorted(set(range(len(people))))
        img = menajer("art/busts/crowd40/bust64_%02d_%s.png" % ([q["id"] for q in _crowd()].index(p["id"]), p["id"]))
        av = avatar(img, 24) if os.path.exists(img) else '<span class="av av-24"></span>'
        m = p["_m"]
        sal = ROLE_SAL.get(p["role"], 7000) - rnd.choice([0, 300, 600, 900, 1200])
        trait_key = {"picks_it_up_fast": ("tr_fast", "t_fast"), "takes_them_under": ("tr_lead", "t_lead"), "last_one_out": ("tr_last", "t_last"),
                     "loyal": ("tr_loyal", "t_loyal"), "double_checker": ("tr_double", "t_double")}.get((p["traits"] or ["x"])[0], ("tr_unknown", "t_unknown"))
        cells = ['<div class="cell face" style="padding-left:8px">%s</div>' % av, '<div class="cell who"><span class="n">%s</span></div>' % p["character_name"]]
        for j, v in enumerate(sk):
            cells.append('<div class="sk v%d%s%s" style="font-size:15px">%d</div>' % (band_of(v), " is-main" if v == mainv and j < 6 else "", " sep" if j == 6 else "", v))
        cells.append('<div class="cell cdata" style="font-size:13px;color:var(--ink-3)">%s</div>' % T(ROLE_KEY[p["role"]]))
        cells.append('<div class="cell">%s</div>' % trait(*trait_key).replace('class="trait-box"', 'class="trait-box" style="width:20px;height:20px"'))
        cells.append('<div class="cell num t-data" style="padding-right:12px">$%s</div>' % "{:,}".format(sal).replace(",", "."))
        cells.append('<div class="cell">%s</div>' % mor(m))
        rows.append('<div class="grid row sm%s" style="grid-template-columns:%s">%s</div>' % (" is-selected" if i == 3 else "", cols, "".join(cells)))
    return ('<div class="pane-demo" style="position:relative;padding:0 16px 8px;height:%dpx;overflow:hidden">%s<div class="rows zebra">%s</div>'
            '<div class="sb" style="right:3px;top:40px;height:%dpx"><div class="sb-thumb" style="top:0;height:%dpx"></div></div></div>'
            % (32 + n * 32 + 12, "".join(out), "".join(rows), n * 32, int(n * 32 * 0.4)))


def p14():
    m2 = ('<div class="modal" style="width:440px"><div class="modal-h t-subhead" style="color:var(--ink-1)">Üzerine yazılsın mı?</div>'
          '<div class="modal-b">Kayıt 3 kaydının yerini bu kayıt alır.</div><div class="modal-f"><span class="btn btn-secondary">Vazgeç</span><span class="btn btn-danger">Üzerine yaz</span></div></div>')
    m3 = ('<div class="modal" style="width:520px;margin-top:16px"><div class="modal-h t-subhead" style="color:var(--ink-1)">Kaydedilmemiş ilerleme var.</div>'
          '<div class="modal-b">Bu kaydı açarsan son kayıttan bu yana oynadığın haftalar kaybolur.</div>'
          '<div class="modal-f"><span class="btn btn-ghost" style="margin-right:auto">Vazgeç</span><span class="btn btn-secondary">Kaydetmeden yükle</span><span class="btn btn-primary">Kaydet ve yükle</span></div></div>')
    dialogs = ('<div class="cap t-label">Onay: iki ve üç düğme</div>%s%s'
               '<div class="note" style="margin-top:8px">Gerçek modal: perde scrim 0,62. Yıkıcı onay tehlike düğmesi, amber yok; üç düğmede tek birincil sağda, Vazgeç solda hayalet. '
               'Üç düğmeli metnin ikinci ve üçüncü düğmesi örnek (oyunda confirm3).</div>' % (m2, m3))
    slots = ('<div class="cap t-label" style="margin-top:20px">Kayıt yuvaları</div>'
             '<div class="slot"><span class="ic-w">%s</span><div><div class="t">Hızlı kayıt</div><div class="m">Hafta 14 · Nisan 2026 · Kasa $10.000 · MRR $4,0K</div></div>'
             '<div class="acts"><span class="t-caption" style="color:var(--ink-3)">02.10.2026 11:00</span><span class="btn btn-secondary btn-sm">Yükle</span></div></div>'
             '<div class="slot is-hover"><span class="ic-w">%s</span><div><div class="t">Otomatik kayıt 2</div><div class="m">Hafta 13 · Nisan 2026 · Kasa $11.500 · MRR $3,8K</div></div>'
             '<div class="acts"><span class="btn btn-ghost btn-sm">Sil</span><span class="btn btn-secondary btn-sm">Yükle</span></div></div>'
             '<div class="slot is-empty"><span class="ic-w">%s</span><div><div class="t">Yeni kayıt</div><div class="m">Boş yuva</div></div><div class="acts"><span class="btn btn-primary btn-sm">Kaydet</span></div></div>'
             '<div class="slot is-blocked"><span class="ic-w">%s</span><div><div class="t">Kayıt 3</div><div class="m">Hafta 12 · Mart 2026</div></div>'
             '<div class="acts"><span class="t-caption" style="color:var(--ink-3)">Karar beklerken kaydedilemez.</span><span class="btn btn-primary btn-sm is-disabled">Kaydet</span></div></div>'
             '<div class="note" style="margin-top:8px">Engelli yuvada gerekçe kontrolün yanında okunur (bugünkü SAVE_ERR_MODAL_OPEN metni karar artık pencerede olduğu için yeni anahtar ister).</div>'
             % (ic("save", 20), ic("save", 20), ic("plus", 20), ic("lock", 20)))
    left = '<div class="abs" style="left:48px;top:92px;width:600px">%s%s</div>' % (dialogs, slots)

    table = ('<div class="cap t-label">Sıkı tablo: 13 sütun, 32 px satır, 24 px yüz (40 kişilik kadrodan ilk 16)</div>%s'
             '<div class="note" style="margin-top:8px">Sıkı kip: rol unvanı ayrı sütun (iki satır yok), beceri 15 px, huy kutusu 20. Başlık kaydırınca yapışır. Kadro crowd40\'tan; maaş ve moral örnek.</div>'
             % dense_table(16))
    text = ('<div class="cap t-label" style="margin-top:20px">Metin kuralları</div><div class="pane-demo" style="padding:12px 16px;display:grid;grid-template-columns:220px 1fr;row-gap:8px;column-gap:16px;align-items:center">'
            '<span class="t-caption" style="color:var(--ink-3)">Satır içi ikon</span><span class="t-data" style="display:flex;align-items:center;gap:4px">Karadeniz Fabrika · 2%s · 12 koltuk</span>'
            '<span class="t-caption" style="color:var(--ink-3)">Para</span><span class="t-data">$10.000 kasa tam · $4,0K / $120K / $1,2M kısaltılmış · −$4.200 (U+2212)</span>'
            '<span class="t-caption" style="color:var(--ink-3)">Yüzde ve süre</span><span class="t-data">%%4 (TR) · 4%% (EN) · 3 hafta · 14 ay · 11:00</span>'
            '<span class="t-caption" style="color:var(--ink-3)">Kısaltma ve ipucu</span><span style="display:flex;align-items:center;gap:12px"><span class="t-data-strong ell" style="color:var(--ink-1);max-width:150px;display:inline-block">Kemal Karaosmanoğlu</span>'
            '<span class="tip">Kemal Karaosmanoğlu</span></span>'
            '<span class="t-caption" style="color:var(--ink-3)">RichTextLabel</span><span class="t-caption" style="color:var(--ink-3)">[img=14] ikon taban çizgisinde (valign center); değer rengi token\'dan ([color=#..] UiTokens hex); kalın tek seviye; bağlantı yok</span></div>' % ic("star", 14))
    right = '<div class="abs" style="left:696px;top:92px;width:1176px">%s%s</div>' % (table, text)
    return page("14", "Diyalog, tablo ve metin", "Onay, kayıt yuvaları, sıkı 40 kişilik tablo, metin kuralları. Ofis katmanı: ekran s3.", left + right)


# ------------------------------------------------------------------ pages 15 and 16: English width pass
def p15():
    common.set_lang("en")
    try:
        bars = [("normal · Up next", topbar("normal")), ("gated · Answer needed", topbar("gated")), ("gated2", topbar("gated2")),
                ("alarm · Shutter", topbar("alarm", slot="sprint")), ("compact 1536", topbar("normal", compact=True, width=1536))]
        body = ""
        for i, (note, bar) in enumerate(bars):
            y = 64 + i * 80
            body += '<div class="abs note" style="left:48px;top:%dpx">%s</div><div class="abs" style="left:0;top:%dpx;width:1920px;height:64px">%s</div>' % (y, note, y + 18, bar)
        strip = 470
        body += ('<div class="abs" style="left:0;top:%dpx;width:420px;height:%dpx;overflow:hidden;background:var(--surface-0)">%s%s</div>'
                 % (strip, 1080 - strip, rail("ekip", top=0, bottom=0), rail("ekip", icons=True, style="left:204px;border-left:1px solid var(--line-1)", top=0, bottom=0)))
        rows = "".join([
            ib_row("Frank Köseoğlu", "mentor", T("frank_offer"), "11:00", "The product has started making money.", "is-gate is-selected"),
            ib_row("Ege Sigorta", "customer", T("s_complaint"), ic("clock") + T("weeks_2"), "Ege Sigorta called the support line.", "is-unread"),
            ib_row("Kuzey İnşaat", "customer", T("s_renewal"), ic("clock") + T("wk_this"), "The renewal meeting closes this week.", "is-unread is-lastweek"),
            ib_row("Selin Kaya", "team", tag(T("st_risk"), "risk"), '<span class="t-label" style="color:var(--ink-3)">Morale</span><b style="color:var(--neg)">22</b>', "QA Engineer · Testing", "is-unread"),
            ib_row("Nordica", "customer", T("s_expansion"), "$2.0K/mo", "<i>Wants to roll out to another department.</i>", ""),
        ])
        body += '<div class="abs" style="left:460px;top:%dpx"><div class="ib-list" style="height:auto;border:1px solid var(--line-2);border-radius:6px" lang="en">%s</div></div>' % (strip, rows)
        opts = (opt(T("o_list"), fx("gain", "Satisfaction +3"), "is-hover")
                + opt_armed(T("o_date"), [("gain", T("fx_sat"), "up", "+8"), ("cost", T("fx_keeps"), "minus", T("fx_debt"))])
                + opt(T("o_lower"), fx("cost", "MRR −$300/mo") + fx("gain", "Satisfaction +12") + fx("chance", "40% · Seats +4", "dice"), "is-wrap")
                + opt(T("o_fix"), state="is-locked", why=T("lock_promise")))
        body += ('<div class="abs" style="left:900px;top:%dpx;width:776px"><div class="perm">%s<span class="t-meta">%s</span></div><div style="height:10px"></div>%s%s'
                 '<div style="display:flex;gap:8px;margin-top:12px;flex-wrap:wrap">%s%s</div></div>'
                 % (strip, ic("pause"), T("permanent"), stake_frank(), opts,
                    toast("ok", T("saved"), T("saved_sub"), "check"), toast("", T("not_saved"), T("not_saved_sub"), "lock")))
        return page("15", "EN genişlik: kabuk ve kutu", "Aynı bileşenler İngilizce metinle; sütunlar ve yuvalar EN'in en uzun değerine göre. Taşma raporu bu sayfayı da ölçer.", body, 'lang="en"')
    finally:
        common.set_lang("tr")


def p16():
    common.set_lang("en")
    try:
        win = ekip_window(48, 88, states={"deniz": "is-hover", "elif": "is-selected"})
        side = ('<div class="abs" style="left:1432px;top:88px;width:440px"><div class="cap t-label">EN worst cases in fixed boxes</div>'
                '<div class="note" style="font-size:13px;line-height:20px;color:var(--ink-3)">Column heads EXPERIENCE (88), LEADERSHIP (80), SALARY, MORALE; state tags AT RISK OF LEAVING (142) and ON LEAVE + 2 weeks; '
                'trait labels Takes Them Under and Picks It Up Fast (142); role Customer Success Manager (170); task Working the accounts (172). '
                'Top bar: REPUTATION (row 2, 12 px), Default Alive (116), ANSWER NEEDED (gate key capped at 14 characters), Sprint decision · 15:00. '
                'All widths come from tools/measure.py at x1.08 + 2 px.</div>'
                '<div style="display:flex;flex-direction:column;gap:10px;margin-top:16px;align-items:flex-start">%s%s%s</div></div>'
                % (trait("tr_lead", "t_lead"), tag(T("st_risk"), "risk"), '<div class="state">%s<span class="left">%s</span></div>' % (tag(T("st_leave"), "neutral"), T("st_leave_left"))))
        pane = ('<div class="abs" style="left:48px;top:800px;width:1352px"><div class="cap t-label">Reading pane, English</div><div class="pane-demo" style="display:flex;gap:32px;padding:20px 24px">'
                '<div style="width:460px"><div class="pane-kicker">%s<span class="t-meta">%s</span></div><h2 class="pane-title t-h2">%s</h2>'
                '<div class="pane-from" style="border:0;padding:0">%s<span class="n">Frank Köseoğlu</span><span class="r">Operating Partner</span><span class="rel">Neutral</span></div>'
                '<div class="perm" style="margin-top:12px">%s<span class="t-meta">%s</span></div></div>'
                '<div style="flex:1">%s<div class="opt is-locked" style="margin-top:8px"><span class="opt-lock">%s</span><span class="opt-label">%s</span><span class="opt-why">%s</span></div></div></div></div>'
                % (pill("mentor"), T("kicker_decision"), T("frank_offer"), avatar("frank", 32), ic("pause"), T("permanent"), stake_frank(), ic("lock", 18), T("refuse"), T("refuse_lock")))
        return page("16", "EN genişlik: Ekip ve bölme", "Ekip penceresi ve okuma bölmesi İngilizce; ızgara 1302 px içinde EN'in en uzun değerine göre.", win + side + pane, 'lang="en"')
    finally:
        common.set_lang("tr")


# ------------------------------------------------------------------ screen: the office layer (city map)
def city_screen():
    """The office layer in place: the city map with its chips and card, and a person tooltip over the office."""
    chips = json.load(open(menajer("art/office_safe_1920_city_chips.json"), encoding="utf-8"))["chips"]
    ox, oy = 184, 64                       # the plate sits inside the rail, top bar and ticker
    icon = {"ishani": "crown", "home": "home", "plaza": "tower", "loft": "loft"}
    out = ['<div class="abs" style="left:%dpx;top:%dpx;width:1736px;height:976px;background:url(%s/office_safe_1920_city.png) 0 0/1736px 976px"></div>' % (ox, oy, ART)]
    for c in chips:
        if not c.get("visible"):
            continue
        cur = c["office"] == "ishani"
        txt = "Mevcut · İş hanı" if cur else c["texts"][0]
        locked = c["office"] == "plaza"
        cls = "mchip" + (" is-current" if cur else "") + (" is-locked" if locked else "")
        out.append('<span class="%s" style="position:absolute;left:%dpx;top:%dpx;transform:translate(-50%%,-50%%)">%s%s</span>'
                   % (cls, ox + c["xy"][0], oy + c["xy"][1], ic(icon.get(c["office"], "building")), txt))
    card = ('<div class="mcard" style="position:absolute;left:1520px;top:88px"><div class="img" style="background-image:url(%s/office_safe_1920_plaza.png);height:150px"></div><div class="b">'
            '<div style="display:flex;align-items:center"><span class="t-micro" style="color:var(--ink-3)">Orta kademe</span><span class="tag tag-outline" style="margin-left:auto">2 şart karşılanmadı</span></div>'
            '<div class="t-subhead" style="color:var(--ink-1)">Plaza katı</div><div class="t-caption" style="color:var(--ink-3);margin-top:-6px">Cam bir plaza kulesinin tam katı</div>'
            '<div class="kv"><div><div class="t-micro" style="color:var(--ink-3)">Masa</div><div class="t-value" style="color:var(--ink-1)">36</div></div>'
            '<div><div class="t-micro" style="color:var(--ink-3)">Kira / ay</div><div class="t-value" style="color:var(--ink-1)">$18,0K</div></div>'
            '<div><div class="t-micro" style="color:var(--ink-3)">Taşınma</div><div class="t-value" style="color:var(--ink-1)">$45,0K</div></div></div>'
            '<div class="req no">%sEkip en az 12 kişi<span class="now">şu an 5</span></div><div class="req no">%sKasada $45,0K<span class="now">şu an $10,0K</span></div>'
            '<div class="req ok">%sMarka en az 40<span class="now">şu an 50</span></div>'
            '<div style="display:flex;gap:8px"><span class="btn btn-secondary btn-sm">Vazgeç</span><span class="btn btn-primary btn-sm is-disabled" style="flex:1">Taşın</span></div></div></div>'
            % (ART, ic("close"), ic("close"), ic("check")))
    pick = ('<div class="float doc-sm" style="position:absolute;left:208px;top:952px;width:340px;padding:12px 16px;display:flex;align-items:center;gap:12px">'
            '<div><div class="t-subhead" style="color:var(--ink-1)">Ofis seç</div><div class="t-caption" style="color:var(--ink-3)">3 kademe · taşınma bir hafta sürer</div></div>'
            '<span class="win-close" style="margin-left:auto">%s</span></div>' % ic("close"))
    # inset: a person tooltip over the office plate (Selin, head at plate 875,557)
    sx, sy = 875, 557
    inset = ('<div class="abs" style="left:620px;top:690px;width:560px;height:300px;overflow:hidden;border:1px solid var(--line-2);border-radius:6px;'
             'background:url(%s/office_safe_1920_noicons.png) -%dpx -%dpx/1736px 976px">'
             '<span class="ptip" style="position:absolute;left:%dpx;top:%dpx">%s<span><div class="n">Selin Kaya</div><div class="r">Test Mühendisi · Test ediyor</div>'
             '<div class="r" style="color:var(--neg)">Moral 22 · ayrılabilir</div></span></span></div>'
             '<div class="abs t-label" style="left:620px;top:664px;color:var(--ink-2);background:var(--surface-0);padding:0 8px;border-radius:2px">Ofiste kişi ipucu (iç görsel)</div>'
             % (ART, sx - 220, sy - 150, 236, 52, avatar("selin", 32)))
    notes = ('<div class="abs note" style="left:1520px;top:620px;width:340px;background:var(--surface-0);padding:10px 12px;border-radius:4px;color:var(--ink-3)">'
             'Harita bir pencere değil: ofis kararmaz, BuildHUD gizlenir (bugünkü kural). Çipler opak zeminde: mevcut ofis taç ve ink-1 kenar, şartı tutmayan kesik kenar. '
             'Kart belge köşeli; şart satırı onay ya da çarpı ikonuyla, bugünkü değer sağda ink-3. Taşın düğmesi kapalıyken gerekçe kartın etiketinde okunur. '
             'Kişi ipucu surface-0, tek satır ad, rol ve iş; tehlike satırı yalnız riskte.</div>')
    return "".join(out) + kit_topbar() + rail(None) + ticker() + card + pick + inset + notes


def kit_topbar():
    from kit import topbar as _tb
    return '<div class="abs" style="left:0;top:0;width:1920px;height:64px">%s</div>' % _tb("normal")
