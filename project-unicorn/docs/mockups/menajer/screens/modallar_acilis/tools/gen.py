"""Modals, onboarding and endings (group "modallar_acilis", Faz A4): builds every frame into ../build/<name>.html.

  python gen.py            build all frames
  python gen.py <name> ... build the named frames only

Render with tools/render_all.sh (calls the menajer render.sh per frame). The system kit (tokens.css, base.css,
icons, crop rule, top bar geometry) is read from ../../../system through the copies in syskit/, whose caches
live in this folder, so nothing is ever written into the system folder.

Text: TR from localization/strings.csv unless INDEX.md lists the string as new (EN first, TR, needs approval).
The shell under the modals (top bar, rail, ticker, office plate, floats, toast) is drawn by the kabuk group's own
builders, loaded from ../../kabuk/tools/gen.py (seed: main.gd _seed_theme_surface, week 14, Unicorn Inc.). Papers:
main.gd _run_ending_shot (PromptPilot, week 23), transcribed from baseline/ending__*_gazete.png.
"""
import datetime
import importlib.util
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
BUILD = os.path.join(ROOT, "build")
sys.path.insert(0, os.path.join(HERE, "syskit"))

import common  # noqa: E402
from common import T, ic, num  # noqa: E402
from kit import tag, pill  # noqa: E402

MEN = common.MENAJER
REL = "../../../"  # build/ -> menajer/


def _src(path):
    return REL + os.path.relpath(path, MEN).replace("\\", "/")


common._src = _src  # avatar() and portrait() resolve image paths through this

FRANK = os.path.join(MEN, "portraits", "frank_cand_a.png")


def founder(n):
    return os.path.join(MEN, "portraits", "founder_%02d.png" % n)


LANG = "tr"
NARROW = False  # 1536 x 864 logical (SPEC §8): compact top bar, icon rail


def WH():
    return (1536, 864) if NARROW else (1920, 1080)


def L(tr, en):
    return tr if LANG == "tr" else en


def set_lang(lang):
    global LANG
    LANG = lang
    common.set_lang(lang)


MON_TR = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
MON_EN = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]


def date(week, hour=None):
    """`week` is the tick (GameState.day); the line prints the week of the year, as get_date_dict does."""
    d = datetime.date(2026, 1, 1) + datetime.timedelta(days=7 * (week - 1))
    w = (d - datetime.date(d.year, 1, 1)).days // 7 + 1
    s = L("Hafta %d · %s %d" % (w, MON_TR[d.month - 1], d.year), "Week %d · %s %d" % (w, MON_EN[d.month - 1], d.year))
    return s + (" · %02d:00" % hour if hour is not None else "")


# ------------------------------------------------------------------ the shell under the modals: kabuk's own builders
# The shell owner's gen.py is loaded as a module, so the top bar, rail, ticker, office plate with the A2 head icons,
# BuildHUD, notice stack, move button and toast are kabuk's, never a copy that drifts (review 2026-10-02, S1 1-3, S2
# 10-11). Its stylesheet is linked before modallar.css. A broken kabuk build stops this one with kabuk's error.
sys.dont_write_bytecode = True   # loading kabuk's file must not leave a __pycache__ in its folder
_spec = importlib.util.spec_from_file_location("kabuk_gen", os.path.join(MEN, "screens", "kabuk", "tools", "gen.py"))
K = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(K)   # its own _src resolves paths the same way (relative to menajer/)


def shell(gated=False, gate_sub=None, toast_html=""):
    """Week-14 seed shell at 1920 or 1536 (compact bar, icon rail); gated: a decision waits (Frank's offer), so the clock
    holds at kabuk's GATE_CLOCK, the move button is off with its reason and Olaylar carries the gate dot."""
    W, H = WH()
    slot = dict(slot=("gate", gate_sub), clock=K.GATE_CLOCK) if gated else {}
    floats = (K.buildhud(W - 344, 88) + K.notices(W, H, K.SEED_INBOX)
              + K.move_btn(88 if NARROW else 208, H - 108, "held" if gated else "idle") + toast_html)
    return ((K.office1536() if NARROW else K.office1920()) + floats + K.topbar(W=W, compact=NARROW, **slot)
            + K.rail(None, dict(K.B14, olaylar=("gate", "")) if gated else None, icons=NARROW) + K.ticker())


def modal_on(shell_html, modals):
    """modals: [(x, y, html)] stacked; each true modal brings its own scrim (two modals = two scrims, as in Godot)."""
    out = shell_html
    modals = [(x, y, h.replace(" is-focus", "") if i < len(modals) - 1 else h) for i, (x, y, h) in enumerate(modals)]
    for i, (x, y, h) in enumerate(modals):
        out += '<div class="scrim" style="z-index:%d"></div><div class="on-scrim" style="left:%dpx;top:%dpx;z-index:%d">%s</div>' % (5 + 2 * i, x, y, 6 + 2 * i, h)
    return '<div class="screen">%s</div>' % out


POP_JS = """<script>
document.querySelectorAll('[data-pop-for]').forEach(function (p) {
  var a = document.getElementById(p.dataset.popFor).getBoundingClientRect();
  p.style.left = a.left + 'px'; p.style.top = (a.bottom + 4) + 'px'; p.style.width = a.width + 'px';
  var tip = p.querySelector('.tip[data-tip-for]');
  if (tip) { var r = document.getElementById(tip.dataset.tipFor).getBoundingClientRect();
    tip.style.left = (a.width + 8) + 'px'; tip.style.top = (r.top - a.bottom - 4) + 'px'; }
});
</script>"""


def page(body, title, cb=False, w1536=False):
    cls = " ".join(c for c in (("cb" if cb else ""), ("w1536" if w1536 else "")) if c)
    return ('<!doctype html><html lang="%s"><head><meta charset="utf-8"><title>%s</title>'
            '<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
            '<link href="%s" rel="stylesheet"><link rel="stylesheet" href="%ssystem/tokens.css"><link rel="stylesheet" href="%ssystem/base.css">'
            '<link rel="stylesheet" href="../../kabuk/kabuk.css"><link rel="stylesheet" href="../modallar.css"></head><body%s>%s%s</body></html>'
            % (LANG, title, common.FONTS, REL, REL, (' class="%s"' % cls) if cls else "", body, POP_JS))


# ------------------------------------------------------------------ small controls
def select(text, sid=None, disabled=False, is_open=False):
    cls = "select t-data" + (" is-disabled" if disabled else "") + (" is-open" if is_open else "")
    return '<span class="%s"%s>%s%s</span>' % (cls, (' id="%s"' % sid) if sid else "", text, ic("chevdown"))


def switch(on, disabled=False):
    return '<span class="switch%s%s"><span class="switch-t"></span></span>' % (" is-on" if on else "", " is-disabled" if disabled else "")


def vol(pct, disabled=False):
    p = "%%%d" % pct if LANG == "tr" else "%d%%" % pct
    return ('<span class="vol"><span class="slider%s"><span class="slider-t"></span><span class="slider-f" style="width:%d%%"></span>'
            '<span class="slider-g" style="left:%d%%"></span></span><span class="pct t-data">%s</span></span>'
            % (" is-disabled" if disabled else "", pct, pct, p))


def btn(label, kind="secondary", size="", icon=None, disabled=False, extra="", style=""):
    cls = "btn btn-%s%s%s%s" % (kind, (" btn-" + size) if size else "", " is-disabled" if disabled else "", (" " + extra) if extra else "")
    return '<span class="%s"%s>%s%s</span>' % (cls, (' style="%s"' % style) if style else "", ic(icon) if icon else "", label)


def pct(n):
    return "%%%d" % n if LANG == "tr" else "%d%%" % n


# ------------------------------------------------------------------ Ayarlar (SettingsModal, 640 x 820)
SET_X, SET_Y, SET_W, SET_H = 640, 130, 640, 820


def settings_html(scroll="top", windowed=False, cb=False, open_id=None, res=None):
    mode = L("Pencereli", "Windowed") if windowed else L("Kenarlıksız", "Borderless")
    res = res or ("1600 × 900" if windowed else "1920 × 1080 (%s)" % L("doğal", "native"))

    def row(k, ctl, off=False):
        return '<div class="set-row"><span class="k t-body%s">%s</span>%s</div>' % (" is-off" if off else "", k, ctl)

    def sec(name):
        return '<div class="set-sec t-group">%s</div>' % name

    def note(text, glyph="info"):
        return '<div class="set-note t-caption">%s%s</div>' % (ic(glyph), text)

    o = lambda sid: sid == open_id
    parts = [sec(L("Görüntü", "Display")),
             row(L("Pencere modu", "Window mode"), select(mode, "s-mode", is_open=o("s-mode"))),
             row(L("Çözünürlük", "Resolution"), select(res, "s-res", disabled=not windowed, is_open=o("s-res")))]
    if not windowed:
        parts.append(note(L("Kenarlıksız mod her zaman ekranın doğal çözünürlüğünde çalışır.",
                            "Borderless mode always runs at the display's native resolution.")))
    parts += [row(L("Arayüz ölçeği", "Interface scale"), select(pct(100), "s-scale", is_open=o("s-scale"))),
              row(L("Dikey eşitleme", "Vertical sync"), switch(True)),
              sec(L("Ses", "Audio")),
              row(L("Ana ses", "Master volume"), vol(100)),
              row(L("Arka plan müziği", "Background music"), switch(True)),
              row(L("Müzik", "Music"), vol(35)),
              row(L("Efektler", "Effects"), vol(70)),
              row(L("Odak kaybında sessize al", "Mute when unfocused"), switch(True)),
              sec(L("Oyun", "Game")),
              row(L("Otomatik kayıt sıklığı", "Autosave frequency"), select(L("Her hafta", "Every week"), "s-auto", is_open=o("s-auto"))),
              row(L("Özet sıklığı", "Summary frequency"), select(L("Her çeyrek", "Every quarter"), "s-sum", is_open=o("s-sum"))),
              # one row under its own "Dil" heading only repeated the label: the row joins Oyun, the heading retires
              row(L("Dil", "Language"), select(L("Türkçe", "English"), "s-lang", is_open=o("s-lang"))),
              sec(L("Erişilebilirlik", "Accessibility")),
              row(L("Renk körü dostu palet", "Colourblind-friendly palette"), switch(cb)),
              note(L("Olumlu ve olumsuz renk çifti maviye ve turuncuya döner.",
                     "The positive and negative colour pair becomes blue and orange.")),
              sec(L("Veri", "Data")),
              '<div class="set-acts">%s%s</div>' % (btn(L("Kayıt klasörünü aç", "Open save folder"), size="sm"),
                                                   btn(L("Ayarları varsayılana döndür", "Reset settings to defaults"), size="sm"))]
    body_h = SET_H - 72 - 73
    content_style = "top:0" if scroll == "top" else "top:auto;bottom:0"
    thumb_h = int((body_h - 16) * 0.66)
    thumb_top = 8 if scroll == "top" else body_h - 8 - thumb_h
    sb = ('<div class="sb" style="right:6px;top:0;height:%dpx"><div class="sb-thumb" style="top:%dpx;height:%dpx"></div></div>'
          % (body_h, thumb_top, thumb_h))
    head = '<div class="dlg-h"><h1 class="t t-h1">%s</h1></div>' % L("Ayarlar", "Settings")
    body = '<div class="dlg-body" style="height:%dpx"><div class="set-scroll" style="%s">%s</div>%s</div>' % (body_h, content_style, "".join(parts), sb)
    foot = '<div class="dlg-f"><span class="grow"></span>%s</div>' % btn(L("Kapat", "Close"), extra="is-focus")
    return '<section class="modal" style="width:%dpx;height:%dpx">%s%s%s</section>' % (SET_W, SET_H, head, body, foot)


def popup(for_id, items, current, hover=None, disabled=None, tip=None):
    """items: labels; disabled: {index: short reason}; tip: (index, text) tooltip on a disabled row."""
    disabled = disabled or {}
    rows = []
    for i, label in enumerate(items):
        cls = "menu-item" + (" is-current" if i == current else "") + (" is-hover" if i == hover else "") + (" is-disabled" if i in disabled else "")
        why = '<span class="why">%s</span>' % disabled[i] if i in disabled else ""
        rows.append('<div class="%s" id="%s-i%d"><span class="chk">%s</span><span class="v">%s</span>%s</div>' % (cls, for_id, i, ic("check", 16), label, why))
    tip_html = ""
    if tip:
        tip_html = '<span class="tip" data-tip-for="%s-i%d">%s</span>' % (for_id, tip[0], tip[1])
    return '<div class="pop" data-pop-for="%s"><div class="menu">%s</div>%s</div>' % (for_id, "".join(rows), tip_html)


def f_settings(scroll="top", windowed=False, cb=False, open_id=None, pop_html="", confirm=None, res=None):
    w, h = WH()
    html = settings_html(scroll, windowed, cb, open_id, res)
    if open_id:
        html = html.replace(" is-focus", "")   # the open popup holds the focus
    modals = [((w - SET_W) // 2, (h - SET_H) // 2, html)]
    if confirm:
        modals.append(confirm)
    return modal_on(shell(), modals) + pop_html


def f_set_top():
    return f_settings("top")


def f_set_bottom():
    return f_settings("bottom")


def f_set_mode():
    return f_settings("top", open_id="s-mode", pop_html=popup("s-mode", [L("Tam ekran", "Fullscreen"), L("Kenarlıksız", "Borderless"), L("Pencereli", "Windowed")], 1, hover=2))


def f_set_res():
    items = ["1280 × 720", "1366 × 768", "1600 × 900", "1680 × 1050", "1920 × 1080 (%s)" % L("doğal", "native")]
    return f_settings("top", windowed=True, open_id="s-res", pop_html=popup("s-res", items, 2, hover=4))


def f_set_scale():
    """The steps close for a 1280 x 720 window, so the frame is that window: Pencereli at 1280 x 720 (a borderless
    1920 x 1080 display would allow every step under SPEC §8). The pointer is on %90, the row with the tooltip."""
    items = [pct(75), pct(90), pct(100), pct(110), pct(125)]
    why = L("Burada okunmaz", "Unreadable here")
    full = L("%s bu pencere boyutunda okunmuyor; daha geniş bir ekran gerekiyor." % pct(90),
             "%s is unreadable at this window size; it needs a wider display." % pct(90))
    return f_settings("top", windowed=True, res="1280 × 720", open_id="s-scale",
                      pop_html=popup("s-scale", items, 2, hover=1, disabled={0: why, 1: why}, tip=(1, full)))


def f_set_auto():
    return f_settings("bottom", open_id="s-auto", pop_html=popup("s-auto", [L("Kapalı", "Off"), L("Her hafta", "Every week"), L("Her ay", "Every month")], 1, hover=2))


def f_set_sum():
    return f_settings("bottom", open_id="s-sum", pop_html=popup("s-sum", [L("Her hafta", "Every week"), L("Her ay", "Every month"),
                                                                          L("Her çeyrek", "Every quarter"), L("Her yıl", "Every year")], 2, hover=1))


def f_set_lang():
    return f_settings("bottom", open_id="s-lang", pop_html=popup("s-lang", ["Türkçe", "English"], 0 if LANG == "tr" else 1, hover=1 if LANG == "tr" else 0))


def f_set_cb():
    return f_settings("bottom", cb=True)


def confirm_html(title, body, buttons, width=440):
    return ('<section class="modal" style="width:%dpx"><div class="modal-h t-subhead" style="color:var(--ink-1)">%s</div>'
            '<div class="modal-b">%s</div><div class="modal-f">%s</div></section>' % (width, title, body, "".join(buttons)))


def f_set_reset():
    c = confirm_html(L("Ayarlar sıfırlansın mı?", "Reset settings?"),
                     L("Görüntü, ses ve oyun ayarları varsayılana döner. Kayıtların etkilenmez.",
                       "Display, audio and game settings return to their defaults. Your saves are untouched."),
                     [btn(L("Vazgeç", "Cancel"), extra="is-focus"), btn(L("Sıfırla", "Reset"), "danger")], 460)
    return f_settings("bottom", confirm=(730, 452, c))


# ------------------------------------------------------------------ Sistem menüsü (Esc)
SYS_W = 380   # SPEC §9 Sistem 380


def save_err():
    """SAVE_ERR_DECISION_WAITING, one value everywhere (button reason, strip, toast, note): kabuk's not_saved_sub,
    whose EN is this group's short line; SPEC §13's longer EN sentence collided with the label in the 352 px button."""
    return K.s("not_saved_sub")


# A2 has no exit glyph (INVENTORY). Draft in the family's rules, for the A2 owner: the door at the 40 % tone,
# the arrow leaving it solid, 2.6 lines, plain evenodd paths.
common._svg_cache["exit"] = (
    '<svg data-src="draft:exit" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
    '<path fill="currentColor" fill-opacity="0.4" fill-rule="evenodd" d="M4.2 3 H10.7 A1.3 1.3 0 0 1 10.7 5.6 H5.6 V18.4 H10.7 '
    'A1.3 1.3 0 0 1 10.7 21 H4.2 A1.2 1.2 0 0 1 3 19.8 V4.2 A1.2 1.2 0 0 1 4.2 3 Z"/>'
    '<path fill="currentColor" fill-rule="evenodd" d="M9.8 10.7 H17.8 V13.3 H9.8 A1.3 1.3 0 0 1 9.8 10.7 Z"/>'
    '<path fill="currentColor" fill-rule="evenodd" d="M13.2 7.4 L15.04 5.56 L21.48 12 L15.04 18.44 L13.2 16.6 L17.8 12 Z"/></svg>')


def system_html(gated=False):
    save = btn(L("Kaydet", "Save"), icon="save", disabled=gated)
    if gated:
        save = ('<span class="btn btn-secondary is-disabled">%s%s<span class="t-caption" style="margin-left:auto;color:var(--ink-3);font-family:var(--f-sans);font-weight:400">%s</span></span>'
                % (ic("save"), L("Kaydet", "Save"), save_err()))
    main_menu = ('<span class="btn btn-secondary is-disabled">%s%s<span class="t-caption" style="margin-left:auto;color:var(--ink-3);font-family:var(--f-sans);font-weight:400">%s</span></span>'
                 % (ic("menu"), L("Ana menüye dön", "Return to main menu"), L("Yakında", "Soon")))
    items = [btn(L("Devam", "Resume"), "primary", icon="play", extra="is-focus"), save,
             btn(L("Yükle", "Load"), icon="load"), btn(L("Ayarlar", "Settings"), icon="ayarlar"), main_menu,
             btn(L("Masaüstüne çık", "Quit to desktop"), icon="exit")]
    head = ('<div class="dlg-h"><h1 class="t t-h1">%s</h1><span class="grow"></span><span class="sub t-meta">%s</span></div>'
            % (L("Menü", "Menu"), date(14, K.GATE_CLOCK if gated else 11)))
    return '<section class="modal" style="width:%dpx">%s<div class="sys-list">%s</div></section>' % (SYS_W, head, "".join(items))


def f_sys():
    return modal_on(shell(), [((1920 - SYS_W) // 2, 300, system_html())])


def f_sys_gated():
    return modal_on(shell(True, L("Frank Köseoğlu", "Frank Köseoğlu")), [((1920 - SYS_W) // 2, 300, system_html(True))])


# ------------------------------------------------------------------ Kayıt / Yükle (SaveLoadModal, 660 x 580)
SL_W, SL_H = 760, 660


def meta(week, phase, cash, mrr):
    return " · ".join([date(week), phase, L("Kasa %s", "Cash %s") % num(cash), "MRR %s" % num(mrr)])


def slots(mode, gated=False):
    ts = lambda tr, en: L(tr, en)
    rows = [("quick", L("Hızlı kayıt", "Quicksave"), meta(14, "Bootstrap", "$10.000", "$4,0K"), ts("02.10.2026 11:42", "10/02/2026 11:42"), True),
            ("auto", L("Otomatik kayıt 1", "Autosave 1"), meta(14, "Bootstrap", "$10.000", "$4,0K"), ts("02.10.2026 11:31", "10/02/2026 11:31"), True),
            ("m1", L("Kayıt 1", "Save 1"), meta(23, "Series A", "$24.000", "$6,4K"), ts("29.09.2026 21:14", "09/29/2026 21:14"), True),
            ("m2", L("Kayıt 2", "Save 2"), '%s' % (L("Bu kayıt eski bir sürümden; ürün verisi değiştiği için açılamıyor.",
                                                                                            "This save comes from an older version; the product data changed and it cannot be opened.")),
             ts("14.09.2026 18:05", "09/14/2026 18:05"), False)]
    out = []
    for i, (sid, label, m, stamp_txt, ok) in enumerate(rows):
        hover = not gated and ((mode == "load" and i == 2) or (mode == "save" and i == 1))
        if mode == "save":
            acts = btn(L("Sil", "Delete"), "ghost", "sm") + btn(L("Üzerine yaz", "Overwrite"), size="sm", disabled=gated)
        else:
            acts = btn(L("Sil", "Delete"), "ghost", "sm") + btn(L("Yükle", "Load"), size="sm", disabled=not ok)
        cls = "slot" + (" is-hover" if hover else "") + ("" if ok else " is-bad")
        out.append('<div class="%s"><span class="ic-w">%s</span><div><div class="t" style="display:flex;gap:8px;align-items:baseline">%s'
                   '<span class="t-caption" style="margin-left:auto;color:var(--ink-4);font-weight:400">%s</span></div><div class="m">%s</div></div>'
                   '<div class="acts">%s</div></div>' % (cls, ic("save" if ok else "warn", 20), label, stamp_txt, m, acts))
    return out


def saveload_html(mode, empty=False, gated=False):
    title = L("Kaydet", "Save") if mode == "save" else L("Yükle", "Load")
    head = '<div class="dlg-h"><h1 class="t t-h1">%s</h1></div>' % title
    parts = []
    if gated:
        # olaylar's win-ro strip: the reason, then the waiting mail's sender · subject, then the way back to it
        parts.append('<div class="sys-gate"><span class="gate-dot"></span><span class="t-key">%s</span><span class="from t-caption">%s</span>'
                     '<span class="grow"></span>%s</div>'
                     % (save_err(), "Frank Köseoğlu · %s" % L("Teklif", "An offer"),
                        btn(L("Karara dön", "Back to the decision"), size="sm", icon="reply")))
    lst = []
    if mode == "save":
        lst.append('<div class="slot is-new%s"><span class="ic-w">%s</span><div><div class="t">%s</div><div class="m">%s</div></div><div class="acts">%s</div></div>'
                   % (" is-blocked" if gated else "", ic("plus", 20), L("Yeni kayıt", "New save"), meta(14, "Bootstrap", "$10.000", "$4,0K"),
                      btn(L("Kaydet", "Save"), "primary", "sm", disabled=gated)))
    if empty:
        lst.append('<div class="sl-empty">%s<span class="t t-body">%s</span></div>' % (ic("load" if mode == "load" else "save"), L("Henüz kayıt yok.", "No saves yet.")))
    else:
        if mode == "save":
            lst.append('<div class="sl-sec t-label">%s</div>' % L("Kayıtlar", "Saves"))
        lst += slots(mode, gated)
    height = (420 if mode == "save" else 340) if empty else SL_H   # an empty list does not hold the full height
    body_h = height - 72 - 73 - (40 if gated else 0)
    body = '%s<div class="dlg-body" style="height:%dpx"><div class="sl-list">%s</div></div>' % ("".join(parts), body_h, "".join(lst))
    foot = '<div class="dlg-f"><span class="grow"></span>%s</div>' % btn(L("Kapat", "Close"), extra="is-focus")
    return '<section class="modal" style="width:%dpx;height:%dpx">%s%s%s</section>' % (SL_W, height, head, body, foot)


def f_save_empty():
    return modal_on(shell(), [((1920 - SL_W) // 2, 330, saveload_html("save", empty=True))])


def f_load_empty():
    return modal_on(shell(), [((1920 - SL_W) // 2, 370, saveload_html("load", empty=True))])


def f_save_full():
    return modal_on(shell(), [((1920 - SL_W) // 2, 210, saveload_html("save"))])


def f_load_full():
    return modal_on(shell(), [((1920 - SL_W) // 2, 210, saveload_html("load"))])


def f_save_gated():
    return modal_on(shell(True, "Frank Köseoğlu"), [((1920 - SL_W) // 2, 210, saveload_html("save", gated=True))])


def f_f5_refused():
    t = K.toast(1052, 968, "warn", "save", T("not_saved"), save_err())
    return '<div class="screen">%s</div>' % shell(True, "Frank Köseoğlu", t)


def f_delete_confirm():
    c = confirm_html(L("Kayıt silinsin mi?", "Delete this save?"),
                     L("Kayıt 1 geri getirilemez.", "Save 1 cannot be brought back."),
                     [btn(L("Vazgeç", "Cancel"), extra="is-focus"), btn(L("Sil", "Delete"), "danger")], 440)
    return modal_on(shell(), [((1920 - SL_W) // 2, 210, saveload_html("load")), (740, 460, c)])


# ------------------------------------------------------------------ Onay
def f_confirm2():
    c = confirm_html(L("Turu bu fonla açmak", "Opening the round with this fund"),
                     L("Meridian Growth ile oturacaksın. Bu turda ikinci bir görüşme yok; diğer üç fon Series A'ya kalır.",
                       "You will sit down with Meridian Growth. There is no second meeting this round, and the other three funds keep until Series A."),
                     [btn(L("Vazgeç", "Cancel"), extra="is-focus"), btn(L("Otur", "Sit down"), "primary")], 480)
    return modal_on(shell(), [(720, 440, c)])


CONF3_W = 520   # SPEC §9 Onay 440-520


def confirm3_html(gated=False):
    """'Çık' loses the weeks since the last save, so it is the danger button (SPEC §11: destructive = danger), in
    both states; with 'Kaydet ve çık' locked it is the only way out."""
    save = btn(L("Kaydet ve çık", "Save and quit"), "primary", disabled=gated)
    if gated:
        save = '<div class="locked-btn">%s<span class="why">%s</span></div>' % (save, save_err())
    return ('<section class="modal" style="width:%dpx"><div class="modal-h t-subhead" style="color:var(--ink-1)">%s</div>'
            '<div class="modal-b">%s</div><div class="modal-f" style="align-items:flex-start">%s%s%s</div></section>'
            % (CONF3_W, L("Kaydedilmemiş ilerleme var.", "You have unsaved progress."),
               L("Son kayıttan bu yana oynadığın haftalar kaybolur.", "The weeks you have played since your last save will be lost."),
               btn(L("Vazgeç", "Cancel"), "ghost", extra="cancel is-focus"), btn(L("Çık", "Quit"), "danger"), save))


def f_confirm3():
    return modal_on(shell(), [((1920 - SYS_W) // 2, 300, system_html()), ((1920 - CONF3_W) // 2, 450, confirm3_html())])


def f_confirm3_gated():
    return modal_on(shell(True, "Frank Köseoğlu"), [((1920 - SYS_W) // 2, 300, system_html(True)), ((1920 - CONF3_W) // 2, 450, confirm3_html(True))])


# ------------------------------------------------------------------ onboarding
def emblem(style, letter, size):
    """LogoEmblem: four shapes; the letter is the company initial (Fmt.upper)."""
    s = size
    r = s / 2 - 2
    c = s / 2
    if style == "minimalist":
        shape = '<circle cx="%.1f" cy="%.1f" r="%.1f" fill="none" stroke="var(--brand-mark)" stroke-width="%.1f"/>' % (c, c, r - 0.5, max(1.5, s / 28))
    elif style == "tech":
        import math
        pts = " ".join("%.1f,%.1f" % (c + math.cos(math.tau * i / 6 - math.pi / 2) * r, c + math.sin(math.tau * i / 6 - math.pi / 2) * r) for i in range(6))
        shape = '<polygon points="%s" fill="none" stroke="var(--brand-mark)" stroke-width="%.1f" stroke-linejoin="round"/>' % (pts, max(1.5, s / 28))
    elif style == "playful":
        shape = '<rect x="2" y="2" width="%.1f" height="%.1f" rx="%.1f" fill="var(--brand-mark)"/>' % (2 * r, 2 * r, r * 0.45)
    else:
        shape = '<rect x="2" y="2" width="%.1f" height="%.1f" fill="var(--ink-2)"/>' % (2 * r, 2 * r)
    fs = int(r * 1.15)
    return ('<span class="emb %s" style="width:%dpx;height:%dpx"><svg viewBox="0 0 %d %d">%s</svg><b style="font-size:%dpx">%s</b></span>'
            % (style, s, s, s, s, shape, fs, letter))


STEP_KEYS = [("Karakter", "Character"), ("Köken", "Origin"), ("Şirket", "Company")]


def onb_head(step):
    items = []
    for i, (tr, en) in enumerate(STEP_KEYS):
        if i:
            items.append('<span class="st-ln"></span>')
        cls = "st" + (" is-done" if i < step else " is-now" if i == step else "")
        no = ic("check", 14) if i < step else str(i + 1)
        items.append('<span class="%s"><span class="no">%s</span><span class="t-nav">%s</span></span>' % (cls, no, L(tr, en)))
    return ('<header class="onb-head"><span class="brand"><i></i>Project Unicorn</span><div class="steps">%s</div></header>'
            % "".join(items))


def onb_foot(step, valid=True, why=None):
    nxt = L("Kur ve başla", "Found and begin") if step == 2 else L("İleri", "Next")
    why_html = ('<span class="why t-meta">%s%s</span>' % (ic("info"), why)) if (why and not valid) else '<span class="sp"></span>'
    return ('<footer class="onb-foot"><span class="cnt t-meta">%s</span>%s%s%s</footer>'
            % (L("Adım %d / 3", "Step %d / 3") % (step + 1), why_html,
               btn(L("Geri", "Back"), "ghost", "lg", disabled=step == 0),
               btn(nxt, "primary", "lg", disabled=not valid, extra="" if valid else "")))


def onb_title(x, y, title, sub):
    return '<div class="onb-title" style="left:%dpx;top:%dpx"><h1 class="t t-h2">%s</h1><p class="s t-body">%s</p></div>' % (x, y, title, sub)


def name_cell(name, sel, focus=False):
    field = ('<span class="input%s">%s</span>' % (" is-focus" if focus else "",
             ('%s<span class="caret"></span><span class="cnt">%d/40</span>' % (name, len(name))) if name else ""))
    hint = '<span class="field-msg">%s</span>' % L("Boş bırakırsan 'Kurucu' kullanılır", "Leave empty to use 'Founder'")
    who = name or L("Kurucu", "Founder")
    return ('<div class="name-cell"><span class="k t-label">%s</span>%s%s'
            '<div class="nc-who">%s<div style="display:flex;flex-direction:column;gap:2px"><span class="n">%s</span><span class="r">%s</span></div></div></div>'
            % (L("Adın", "Your name"), field, hint, common.avatar(founder(sel), 48), who, L("Kurucu · 2026", "Founder · 2026")))


def f_character(sel=1, name="", hover=None, focus=False):
    cards = []
    for n in range(1, 12):
        cls = "pcard" + (" is-selected" if n == sel else "") + (" is-hover" if n == hover else "")
        cap = ""
        if n == sel:
            cap = '%s<span class="n">%s</span>' % (ic("check", 16), name or L("Kurucu", "Founder"))
        cards.append('<div class="%s">%s<div class="cap">%s</div></div>' % (cls, common.portrait(founder(n), 260, 325), cap))
    title = (L("Karakter", "Character"), L("Bu, aynada göreceğin yüz. Bir istatistik değil, bir kimlik.", "The face you will see in the mirror. Not a statistic, an identity."))
    if NARROW:
        # below 1680 logical: five columns that scroll under a fixed header and footer; the name field joins the title
        # row and keeps the 48 px disc preview beside it (the pick's face under the name being typed)
        field = ('<div class="abs" style="left:1030px;top:24px;width:420px;display:flex;flex-direction:column;gap:6px">'
                 '<span class="field-k t-label" style="margin-left:60px">%s</span>'
                 '<div style="display:flex;align-items:center;gap:12px">%s<span class="input%s" style="flex:1">%s</span></div>'
                 '<span class="field-msg" style="margin-left:60px">%s</span></div>'
                 % (L("Adın", "Your name"), common.avatar(founder(sel), 48), " is-focus" if focus else "",
                    ('%s<span class="caret"></span><span class="cnt">%d/40</span>' % (name, len(name))) if name else "",
                    L("Boş bırakırsan 'Kurucu' kullanılır", "Leave empty to use 'Founder'")))
        grid = '<div class="pgrid" style="left:86px;top:120px;grid-template-columns:repeat(5,260px)">%s</div>' % "".join(cards)
        sb = '<div class="sb" style="right:6px;top:8px;height:696px"><div class="sb-thumb" style="top:0;height:430px"></div></div>'
        body = (onb_head(0) + '<div class="onb-scroll">%s%s%s%s</div>' % (onb_title(86, 24, *title), field, grid, sb) + onb_foot(0))
        return '<div class="onb">%s</div>' % body
    cards.append(name_cell(name, sel, focus))
    grid = '<div class="pgrid" style="left:140px;top:196px">%s</div>' % "".join(cards)
    body = onb_head(0) + onb_title(140, 96, *title) + grid + onb_foot(0)
    return '<div class="onb">%s</div>' % body


def f_char_default():
    return f_character(1)


def f_char_filled():
    return f_character(5, "Deniz", hover=2, focus=True)


ORIGINS = [("origin_self", ("Sıfırdan", "Self-Made"), ("Hiçbir şey yoktu. Her satırı ben yazdım.", "There was nothing. I wrote every line myself."), None),
           ("origin_heir", ("Mirasyedi", "The Heir"), ("Aile sermayesi arkanda. Ama gözler de üzerinde.", "Family money at your back. And every eye on you."), ("Tam sürümde", "In the full game")),
           ("origin_corp", ("Kurumsal Firari", "Corporate Refugee"), ("On yıl büyük şirkette. Şimdi kendi adına.", "Ten years in a big company. Now in your own name."), ("Çok yakında", "Coming soon"))]
TRAITS_POS = [("visionary", ("Vizyoner", "Visionary"), ("Ar-Ge sıçramaları daha sık", "R&D breakthroughs come more often")),
              ("disciplined", ("Disiplinli", "Disciplined"), ("Geliştirme süreleri kısalır", "Development cycles run shorter")),
              ("networker", ("Ağ kurucu", "Networker"), ("Müşteri adayı kalitesi artar", "Prospect quality improves")),
              ("resilient", ("Dayanıklı", "Resilient"), ("Kriz sonrası hızlı toparlar", "Recovers quickly after a crisis"))]
TRAITS_NEG = [("stubborn", ("İnatçı", "Stubborn"), ("Pivot maliyeti yüksek", "Pivots cost more")),
              ("micromanager", ("Mikro yönetici", "Micromanager"), ("Ekip morali daha hızlı erir", "Team morale erodes faster")),
              ("risk_blind", ("Risk körü", "Risk-Blind"), ("Erken çıkış cazibesi artar", "Early launches tempt harder")),
              ("lone_wolf", ("Yalnız kurt", "Lone Wolf"), ("Mentor etkisi azalır", "Mentor guidance lands weaker"))]
SKILLS = [("Ürün", "Product", "Özellik kararları ve tasarım turları.", "Feature decisions and design rounds."),
          ("Tasarım", "Design", "Tasarım tavanı ve ürün deneyimi.", "The design ceiling and product experience."),
          ("Yazılım", "Engineering", "Geliştirme hızı ve hata oranı.", "Development speed and bug rate."),
          ("Test", "QA", "Hata bulma ve canlı ürünün aşınması.", "Finding bugs and live product wear."),
          ("Satış", "Sales", "Müşteri adayı kalitesi ve anlaşma kapama.", "Prospect quality and closing deals."),
          ("Müşteri Başarısı", "Customer Success", "Bilet çözümü, memnuniyet ve churn.", "Ticket resolution, satisfaction and churn."),
          ("Liderlik", "Leadership", "Ekip morali ve kriz yönetimi.", "Team morale and crisis management."),
          ("Karizma", "Charisma", "Yatırımcı ikna gücü, şartlar ve kriz anları.", "Investor persuasion, terms and moments of crisis.")]


def f_origin(origin=None, pos=(), neg=(), alloc=(0,) * 8, hover_trait=None, why=None):
    cw, dy = (1440, -64) if NARROW else (1824, 0)   # narrow: content sits in the scroll area under the header

    def sect(y, k, n, sub):
        return '<div class="abs onb-k t-label" style="left:48px;top:%dpx">%s%s<span class="sub">%s</span></div>' % (y + dy, k, ('<span class="n">%s</span>' % n) if n else "", sub)

    cards = []
    for i, (glyph, nm, q, lock) in enumerate(ORIGINS):
        cls = "ocard" + (" is-selected" if origin == i else "") + (" is-locked" if lock else "")
        head = '<div class="t">%s<span class="t-subhead">%s</span>' % (ic(glyph, 24), L(*nm))
        if lock:
            head += '<span class="lk">%s%s</span>' % (ic("lock", 14), tag(L(*lock), "outline"))
        elif origin == i:
            head += '<span class="chk">%s</span>' % ic("check", 20)
        head += "</div>"
        tags = ""
        if not lock:
            tags = '<div class="tags">%s%s%s</div>' % (tag(L("Dayanıklı", "Resilient"), "outline"),
                                                      tag(ic("cost", 12) + L("Düşük sermaye", "Low capital"), "outline"),
                                                      tag(L("Basın sempatisi", "Press sympathy"), "outline"))
        cards.append('<div class="%s">%s<div class="q">"%s"</div>%s</div>' % (cls, head, L(*q), tags))
    ogrid = '<div class="ogrid" style="left:48px;top:%dpx;width:%dpx">%s</div>' % (212 + dy, cw, "".join(cards))

    def tcol(title, items, chosen, cap):
        full = len(chosen) >= cap
        rows = []
        for tid, nm, ef in items:
            on = tid in chosen
            off = full and not on
            cls = "trow" + (" is-on" if on else "") + (" is-off" if off else "") + (" is-hover" if tid == hover_trait else "")
            rows.append('<div class="%s"><span class="check%s"><span class="check-box">%s</span></span><span class="tx"><span class="n">%s</span><span class="e">%s</span></span></div>'
                        % (cls, " is-on" if on else "", ic("check", 14), L(*nm), L(*ef)))
        return ('<div class="tcol"><div class="tcol-h t-label">%s<span class="c%s">%d / %d</span></div>%s</div>'
                % (title, " is-full" if full else "", len(chosen), cap, "".join(rows)))
    tgrid = '<div class="tgrid" style="left:48px;top:%dpx;width:%dpx">%s%s</div>' % (420 + dy, cw,
        tcol(L("Pozitif", "Positive"), TRAITS_POS, pos, 2), tcol(L("Negatif", "Negative"), TRAITS_NEG, neg, 1))

    remaining = 6 - sum(alloc)
    steps = []
    for (tr, en, dtr, den), v in zip(SKILLS, alloc):
        pips = "".join('<i class="%s"></i>' % ("on" if i < v * 2 else "") for i in range(10))
        minus = '<span class="b%s">%s</span>' % (" is-disabled" if v == 0 else "", ic("minus"))
        plus = '<span class="b%s">%s</span>' % (" is-disabled" if (v >= 3 or remaining <= 0) else "", ic("plus"))
        steps.append('<div class="sstep%s"><span class="t">%s</span><span class="d">%s</span><div class="pips">%s</div>'
                     '<div class="ctl"><div class="stepper">%s<span class="v">%d</span>%s</div></div></div>'
                     % (" is-set" if v else "", L(tr, en), L(dtr, den), pips, minus, v, plus))
    pts_cls = "pts" + (" is-done" if remaining == 0 else "")
    hint = ('%s%s' % (ic("check"), L("Hepsi dağıtıldı", "All spent"))) if remaining == 0 else L("tümünü dağıt", "spend them all")
    steps.append('<div class="%s"><span class="k t-micro">%s</span><span class="v t-kpi">%d</span><span class="h t-caption">%s</span></div>'
                 % (pts_cls, L("Kalan puan", "Points left"), remaining, hint))
    wrap = ";display:grid;grid-template-columns:repeat(4,1fr) 132px;grid-auto-flow:row" if NARROW else ""
    if NARROW:
        steps[-1] = steps[-1].replace('class="pts', 'style="grid-column:5;grid-row:1 / span 2" class="pts')
    sgrid = '<div class="sgrid" style="left:48px;top:%dpx;width:%dpx%s">%s</div>' % (732 + dy, cw, wrap, "".join(steps))

    valid = why is None
    if NARROW:
        inner = (onb_title(48, 32, L("Köken ve Karakter", "Origin and Character"),
                           L("Nereden geldiğin, neyi kolay, neyi zor yaşayacağını belirler.", "Where you come from decides what will come easy, and what will not."))
                 + sect(180, L("Köken", "Origin"), "", L("Nereden geldiğin, nereden başladığını belirler.", "Where you come from decides where you start."))
                 + ogrid + sect(388, L("Huylar", "Traits"), "", L("Bir pozitif seçebilirsin. İki pozitif seçersen bir negatif seçmelisin.", "Pick one strength freely. Pick two and you owe a flaw."))
                 + tgrid + sect(700, L("Yetenekler", "Skills"), "", L("Masaya ne getiriyorsun.", "What you bring to the table.")) + sgrid)
        sb = '<div class="sb" style="right:6px;top:8px;height:696px"><div class="sb-thumb" style="top:212px;height:484px"></div></div>'
        body = (onb_head(1) + '<div class="onb-scroll"><div class="abs" style="left:0;right:0;top:-320px;height:1040px">%s</div>%s</div>' % (inner, sb)
                + onb_foot(1, valid, why))
        return '<div class="onb">%s</div>' % body
    body = (onb_head(1) + onb_title(48, 96, L("Köken ve Karakter", "Origin and Character"),
                                    L("Nereden geldiğin, neyi kolay, neyi zor yaşayacağını belirler.", "Where you come from decides what will come easy, and what will not."))
            + sect(180, L("Köken", "Origin"), "", L("Nereden geldiğin, nereden başladığını belirler.", "Where you come from decides where you start."))
            + ogrid
            + sect(388, L("Huylar", "Traits"), "", L("Bir pozitif seçebilirsin. İki pozitif seçersen bir negatif seçmelisin.", "Pick one strength freely. Pick two and you owe a flaw."))
            + tgrid
            + sect(700, L("Yetenekler", "Skills"), "", L("Masaya ne getiriyorsun.", "What you bring to the table."))
            + sgrid + onb_foot(1, valid, why))
    return '<div class="onb">%s</div>' % body


def f_origin_empty():
    return f_origin(why=L("Bir köken seç.", "Choose an origin."), hover_trait="visionary")


def f_origin_owed():
    return f_origin(0, ("visionary", "disciplined"), (), (2, 0, 1, 0, 2, 0, 0, 1), why=L("İki pozitif bir negatif ister.", "Two strengths owe a flaw."))


def f_origin_filled():
    return f_origin(0, ("visionary", "disciplined"), ("stubborn",), (2, 0, 1, 0, 2, 0, 0, 1))


STYLES = [("minimalist", ("Minimalist", "Minimalist")), ("tech", ("Tekno", "Tech")), ("playful", ("Oyuncul", "Playful")), ("serious", ("Ciddi", "Serious"))]


def f_company(name="", style=None, focus=False):
    letter = name[:1].upper() if name else "?"
    cards = "".join('<div class="lp-card%s">%s<span class="t-micro">%s</span></div>'
                    % (" is-selected" if s == style else (" is-hover" if (style and s == "tech") else ""), emblem(s, letter, 32), L(*nm))
                    for s, nm in STYLES)
    name_field = ('<span class="input%s">%s</span>' % (" is-focus" if focus else "",
                  ('%s<span class="caret"></span><span class="cnt">%d/40</span>' % (name, len(name))) if name else
                  '<span class="ph">%s</span>' % L("Örn. Synaptik", "e.g. Synaptik")))
    fields = ('<div class="cfields" style="left:48px;top:196px;width:880px">'
              '<span class="field-k t-label">%s</span>%s'
              '<span class="field-k t-label">%s</span><div class="lp">%s</div>'
              '<span class="field-k t-label">%s</span><span class="input"><span class="ph">%s</span></span></div>'
              % (L("Şirket adı", "Company name"), name_field, L("Logo stili", "Logo style"), cards,
                 L("Slogan (opsiyonel)", "Slogan (optional)"), L("Bir cümlede ne yapıyorsun", "What you do in one sentence")))
    # preview: the name on the door. Under decision 14 (a) the top bar carries the game's mark, so the player's
    # logo lives here only: the 96 emblem on an ink-line plinth (the door plate), the name, the founder.
    plate = (emblem(style, letter, 96) if style else
             '<span class="emb" style="width:96px;height:96px"><b style="font-size:40px;color:var(--ink-4)">?</b></span>')
    card = ('<div class="pv-card"><div class="plinth%s">%s</div><div class="co t-h2%s">%s</div><div class="fr">%s'
            '<div style="display:flex;flex-direction:column;gap:2px"><span class="n">Deniz</span><span class="r">%s</span></div></div></div>'
            % ("" if style else " is-empty", plate, "" if name else " is-empty", name or L("[Şirket adı]", "[Company name]"), common.avatar(founder(5), 48),
               L("Kurucu · 2026", "Founder · 2026")))
    pv = ('<div class="pv" style="left:976px;top:196px;width:896px;height:740px"><span class="pv-k t-label">%s</span>%s</div>'
          % (L("Önizleme", "Preview"), card))
    valid = bool(name) and bool(style)
    why = None if valid else (L("Şirketine bir ad ver.", "Give your company a name.") if not name else L("Bir logo stili seç.", "Choose a logo style."))
    body = (onb_head(2) + onb_title(48, 96, L("Şirket", "Company"),
                                    L("Kapıya asılacak isim. Bundan sonra herkes bu adı anacak.", "The name on the door. From now on this is what they will call you."))
            + fields + pv + onb_foot(2, valid, why))
    return '<div class="onb">%s</div>' % body


def f_company_empty():
    return f_company()


def f_company_filled():
    return f_company("Unicorn Inc.", "playful", focus=True)


def f_loading():
    inner = ('%s<span class="t-h2" style="color:var(--ink-1)">Unicorn Inc.</span><span class="ld t-meta">%s</span>'
             '<div class="prog" style="width:240px"><div class="prog-t"><div class="prog-f ind"></div></div></div>'
             % (emblem("playful", "U", 64), L("Hazırlanıyor…", "Preparing…")))
    return '<div class="onb"><div class="curtain">%s</div></div>' % inner


def f_lang_gate(hover=None):
    def opt(code, t, s, focus):
        cls = "lang-opt" + (" is-hover" if hover == code else "") + (" is-focus" if focus else "")
        return '<div class="%s"><span class="t">%s</span><span class="s">%s</span></div>' % (cls, t, s)
    c = ('<div class="gate-c"><span class="brand lg"><i></i>Project Unicorn</span><div class="gate-opts">%s%s</div></div>'
         % (opt("tr", "Türkçe", "Oyuna Türkçe başla", True), opt("en", "English", "Start the game in English", False)))
    return '<div class="onb">%s</div>' % c


def f_gate():
    return f_lang_gate()


def f_gate_hover():
    return f_lang_gate("en")


# ------------------------------------------------------------------ endings: the paper island and the new rail
PAPERS = {
    "series_a_close": dict(
        head="PromptPilot Series A Turunu Kapattı",
        deck='"Temiz bir tur; kurucu masaya sağlam oturmuş." değerlendirmesi yatırım çevrelerinde dolaşıyor.',
        cap="İmza töreninden bir an.",
        stats=[("$4,0M", "Yatırım"), ("$22M", "Değerleme"), ("0", "Ödeyen"), ("%82", "Kurucu hissesi")],
        prose=["22 milyon dolar değerleme üzerinden 4 milyon dolar yatırım alındı; karşılığında yüzde 18 hisse verildi. Yönetim kurulunda yatırımcıya bir koltuk tanındı.",
               "Kurucunun kendi birikimiyle kurduğu şirket, altı aydan kısa sürede Series A kapısını araladı. Ekip üç kişilik bir kadroya ulaştı. Birden fazla masaya oturuldu; imza sonunda geldi."],
        title="Series A Kapandı",
        frank="İmzaladın. Şimdi asıl iş başlıyor. Ama o başka bir oyunun konusu.",
        frank_draft="END_META_SERIES_A_CLOSE_FRANK"),
    "series_a_agg": dict(
        head="PromptPilot Series A'yı Kapattı, Kontrol El Değiştirdi",
        deck='"Para geldi, ama koltukların çoğu artık yatırımcının." yorumu bir fon yöneticisinin ağzından duyuldu.',
        cap="Toplantı masasında yeni dengeler.",
        stats=[("$7,0M", "Yatırım"), ("$22M", "Değerleme"), ("0", "Ödeyen"), ("%68", "Kurucu hissesi")],
        prose=["22 milyon dolar değerleme üzerinden 7 milyon dolar yatırım alındı; karşılığında yüzde 32 hisse verildi. Yönetim kurulunda yatırımcıya iki koltuk tanındı. Kritik kararlarda veto hakkı da verildi.",
               "Kurucunun kendi birikimiyle kurduğu şirket, altı aydan kısa sürede Series A kapısını araladı. Ekip üç kişilik bir kadroya ulaştı. Birden fazla masaya oturuldu; imza sonunda geldi."],
        title="Series A Kapandı",
        frank="İmzaladın. Şimdi asıl iş başlıyor. Ama o başka bir oyunun konusu.",
        frank_draft="END_META_SERIES_A_CLOSE_FRANK"),
    "acquisition": dict(
        head="PromptPilot El Değiştirdi: Ekip Kaldı, Bayrak İndi",
        deck='"Ne tam bir zafer ne de bir yenilgi; temkinli bir çıkış olarak okunuyor." değerlendirmesi sektörde konuşuluyor.',
        cap="Devir sonrası boşalan bir çalışma masası.",
        stats=[("$147,8K", "Satış bedeli"), ("0", "Ödeyen"), ("3", "Çalışan"), ("$6,4K", "MRR")],
        prose=["Devir 1 milyon dolar değerleme üzerinden konuşuldu. Kurucunun kendi birikimiyle kurduğu şirket, altı aydan kısa sürede yeni bir çatının altına girdi.",
               "Ekibin üç kişilik çekirdeği alıcı şirkete geçti. Ürün, kapanışa kadar 3 kez yeni sürümle güncellenmişti. Bağımsız bir tur için birkaç kapı çalınmış, sonunda satış yolu seçilmişti."],
        title="Şirket Satıldı",
        frank="Sattın. Kazanmak değil; kaybetmek de değil. Çoğu kurucu bunu bile göremez."),
    "brand_collapse": dict(
        head="İtibar Krizi PromptPilot Şirketini Devirdi",
        deck='"Skandalı şirket değil, skandal şirketi yönetti." değerlendirmesi sektörde ortak kanaate dönüştü.',
        cap="Kapanan bir ofisin karartılmış tabelası.",
        stats=[("50", "Marka"), ("3", "Kaybedilen müşteri"), ("3", "Çalışan"), ("$6,4K", "Son MRR")],
        prose=["Kurucunun kendi birikimiyle kurduğu şirket, altı aydan kısa sürede güven kaybının altında kaldı. Kriz büyürken 3 müşteri ilişkisi teker teker koptu.",
               "Marka değeri, toparlanamayacağı bir eşiğin altına indi. Kurulan kadro, kapanışın gölgesinde dağıldı."],
        title="Marka Çöktü",
        frank="Skandalı sen yönetmedin; o seni yönetti."),
    "vc_rejection_cascade": dict(
        head="PromptPilot Yatırımcı Kapılarını Kapalı Buldu",
        deck='"Para bulamamak öldürmez; vazgeçilmiş görünmek öldürür." sözü yatırım çevrelerinde dolaşıyor.',
        cap="Boş bir toplantı masası ve kapanmış klasörler.",
        stats=[("1", "Ret"), ("2", "Pitch"), ("$6,4K", "MRR"), ("6", "Ayakta kaldığı ay")],
        prose=["Kurucunun kendi birikimiyle kurduğu şirket, altı aydan kısa sürede Series A turunu tamamlayamadı. Farklı masalarda görüşmeler yapıldı, ancak imza gelmedi.",
               "Bir ara masaya teklif geldi, fakat sonuca bağlanamadı. İşleyen bir gelir vardı, ama yatırımcıyı ikna edecek ivme yakalanamadı."],
        title="Üç Masa, Üç Ret",
        frank="Para bulamamak öldürmez. Vazgeçilmiş görünmek öldürür."),
    "running_on_fumes": dict(
        week=104, issue=104,
        head="PromptPilot İçin Yatırımcı İlgisi Söndü",
        deck='"Series A masasına oturdu ama kimse kalemi uzatmadı." değerlendirmesi yatırım çevrelerinde dolaşıyor.',
        cap="Işıkları yanan, telefonu susmuş bir ofis.",
        stats=[("25", "Ayakta kaldığı ay"), ("$6,4K", "MRR"), ("0", "Kitle"), ("0", "Ödeyen")],
        prose=["Kurucunun kendi birikimiyle kurduğu şirket, iki yıla yakın sürede ayakta kalmayı başardı; yatırımcı ilgisi ise çoktan başka masalara geçmişti. Masada imzalanmamış bir teklif kaldı.",
               "Kurulan kadro iş başındaydı; kimse bir kapanış duyurusu yapmadı. Gelir vardı; ne bir turu ne de kendi kendine yeten bir defteri taşıyacak kadar. Ürün 3 sürüm görmüştü; gelişiyordu, ama artık kimse izlemiyordu."],
        title="İlgi Söndü",
        frank="Takvim bitti. Kapı açıktı, kimse girmedi. Kaybetmedin. Sadece kazanmadın."),
    "profitable_bootstrap": dict(
        head="PromptPilot Kimseye El Açmadan Ayakta",
        deck='"Dışarıdan tek kuruş almadan büyüyen bir şirket bu piyasada nadir görülür." değerlendirmesi sektörde konuşuluyor.',
        cap="Kendi imkânlarıyla kurulmuş bir çalışma odası.",
        stats=[("$6,4K", "MRR"), ("0", "Ödeyen"), ("3", "Çalışan"), ("0", "Kitle")],
        prose=["Kurucunun kendi birikimiyle kurduğu şirket, altı aydan kısa sürede kendi ayakları üzerinde durmayı başardı.",
               "Kadro üç kişiye çıktı; hepsi kendi gelirinden ödendi. Ürün 3 kez yenilendi. Aylık gelir, gideri karşılayacak bir seviyeye taşındı."],
        title="Kendi Paranla",
        frank="Onlara ihtiyacın yokmuş. Gerçek bir şey kurdun."),
    "bankruptcy1": dict(
        quiet=True,
        head="Rakip Girişim Yeni Yatırım Turunu Kapattı",
        deck='"Bu çeyrek yatırım iştahının canlı kaldığı görülüyor." değerlendirmesi sektörde konuşuluyor.',
        notice=("Kısa Kısa:", "PromptPilot sessizce kapandı. Kurucusu yeni bir şey üzerinde çalıştığını söylüyor."),
        title="Kepenk İndi",
        frank="28 gün kırmızıda kaldın. Rakamlar kaba değildir; sadece sabırlıdır.",
        frank_draft="END_META_BANKRUPTCY_FRANK"),
    "bankruptcy2": dict(
        head="PromptPilot İçin Umut Veren Çıkış Yarıda Kaldı",
        deck='"İvmesi vardı; ama nakit yetişmedi." değerlendirmesi sektörde konuşuluyor.',
        cap="Yarım kalmış bir ürün panosu.",
        stats=[("6", "Ayakta kaldığı ay"), ("0", "Ödeyen"), ("3", "Çalışan"), ("$6,4K", "Son MRR")],
        prose=["Kurucunun kendi birikimiyle kurduğu şirket, altı aydan kısa sürede kepenk indirdi.",
               "Son aylarda 3 müşteri ilişkisi koptu. İşe alınan kadro dağıldı. Ürün 3 sürüme ulaşmıştı."],
        title="Kepenk İndi",
        frank="28 gün kırmızıda kaldın. Rakamlar kaba değildir; sadece sabırlıdır.",
        frank_draft="END_META_BANKRUPTCY_FRANK"),
    "bankruptcy3": dict(
        head="Series A Kapısındaki PromptPilot Kepenk İndirdi",
        deck='"Kapıya kadar geldi, eşiği geçemedi. Bu piyasa affetmiyor." yorumu yatırım çevrelerinde dolaşıyor.',
        cap="Kapatılmış bir ofisin önünden geçenler.",
        stats=[("6", "Ayakta kaldığı ay"), ("0", "Ödeyen"), ("3", "Çalışan"), ("$6,4K", "Son MRR")],
        prose=["Kurucunun kendi birikimiyle kurduğu şirket, altı aydan kısa sürede kepenk indirdi. Son aylarda 3 müşteri ilişkisi koptu.",
               "İşe alınan kadro dağıldı. Ürün 3 sürüme ulaşmıştı. Yatırım için masalara oturuldu, ama imza gelmedi."],
        title="Kepenk İndi",
        frank="28 gün kırmızıda kaldın. Rakamlar kaba değildir; sadece sabırlıdır.",
        frank_draft="END_META_BANKRUPTCY_FRANK"),
}


def paper(key):
    p = PAPERS[key]
    week = p.get("week", 23)
    dl = '%s · SAYI %d' % (date(week), p.get("issue", week))
    out = ['<div class="pp-mast">EKONOMİ POSTASI</div>', '<div class="pp-meta pp-date" lang="tr">%s</div>' % dl,
           '<div class="pp-rule3"></div>', '<div class="pp-head">%s</div>' % p["head"], '<div class="pp-deck">%s</div>' % p["deck"]]
    if p.get("quiet"):
        out.append('<div class="pp-quiet"></div><div class="pp-rule1"></div><div class="pp-notice"><b>%s</b> %s</div>' % p["notice"])
    else:
        out.append('<div class="pp-eng"><span class="pp-meta" lang="tr">Görsel yakında</span></div>')
        out.append('<div class="pp-cap">%s</div>' % p["cap"])
        out.append('<div class="pp-rule1"></div>')
        out.append('<div class="pp-meta pp-led" lang="tr">Rakamlarla <span class="co">PromptPilot</span></div>')
        out.append('<div class="pp-stats">%s</div>' % "".join('<div class="pp-stat"><span class="f">%s</span><span class="pp-meta" lang="tr">%s</span></div>' % s for s in p["stats"]))
        out.append('<div class="pp-prose"><p>%s</p><p>%s</p></div>' % tuple(p["prose"]))
    return '<div class="paper">%s</div>' % "".join(out)


def frank_strip(line, draft_key=None):
    """draft_key: the line is a rewrite (the dash removed) that stays a draft until Erdem approves it (CLAUDE §3);
    the mark is a mockup annotation, as olaylar's taslak sheet, not game UI."""
    mark = ('<span class="draft-k"><b>TASLAK</b>%s · onay bekliyor</span>' % draft_key) if draft_key else ""
    return ('<div class="frank-strip%s">%s<div><div class="q t-quote">%s</div><div class="fs-who"><span class="n">Frank Köseoğlu</span>%s</div></div>%s</div>'
            % (" is-draft" if draft_key else "", common.avatar(FRANK, 48), line, pill("mentor"), mark))


def tier(kicker, title, badge, body):
    return ('<div class="tier"><div class="tier-k t-meta">%s%s%s</div><div class="tier-t t-subhead">%s</div><div class="tier-b t-meta">%s</div></div>'
            % (ic("lock", 14), kicker, tag(badge, "outline"), title, body))


def run_meta(weeks):
    return '<div class="er-meta t-meta">%s%s</div>' % (ic("clock"), "Bu oyun: %d hafta · Normal mod" % weeks)


def end_actions(retry=True, toast_shown=False):
    hard = '<span class="locked">%s<span class="why t-caption">%s</span></span>' % (btn("Zor mod", "ghost", icon="lock", disabled=True), "Yakında")
    share = btn("Gazeteyi paylaş", "secondary", extra="is-pressed" if toast_shown else "")
    return '<div class="er-acts">%s%s<span class="sp"></span>%s</div>' % (btn("Tekrar dene") if retry else "", hard, share)


def share_toast():
    """The one toast with its own ghost action; it holds while the pointer is on it (drawn on 'Klasörü aç'). The
    file name drops the ending id and the seconds (proposal): gazete_<YYYYMMDD-HHMM>.png; a second share in the same
    minute writes the same paper again."""
    return ('<div class="er-toast"><span class="toast ok"><span class="well">%s</span><span class="head">%s</span><span class="sub">%s</span>%s</span></div>'
            % (ic("check"), "Gazete kaydedildi", "gazete_20261002-1142.png", btn("Klasörü aç", "ghost", "sm", extra="is-hover")))


def end_rail(key, mode="demo", toast=False, notice=None):
    p = PAPERS[key]
    weeks = p.get("week", 23)
    out = []
    if mode == "milestone":
        out.append('<span class="er-k t-label">Kilometre taşı</span>')
        out.append('<h2 class="er-title t-h2">%s</h2>' % p["title"])
        out.append('<p class="er-body t-para">Bu bir son değil. Şirket yoluna devam ediyor.</p>')
        out.append('<div class="er-cta">%s</div>' % btn("Devam et", "primary", "lg", style="width:100%", extra="is-focus"))
        if notice:
            out.append('<div class="er-note t-meta">%s<span>%s</span></div>' % (ic("warn"), notice))
        out.append('<div class="er-grow"></div><div class="er-acts">%s</div>' % btn("Ana menü", "secondary"))
        return '<aside class="end-rail">%s</aside>' % "".join(out)
    out.append('<h2 class="er-title t-h2" style="margin-top:0">%s</h2>' % p["title"])
    out.append(run_meta(weeks))
    if mode == "demo":
        # the card's kicker is the kind only; the title under it names the milestone
        out.append('<div class="er-rule"></div><h3 class="er-h t-subhead">Sırada ne var?</h3>')
        out.append(tier("Kilometre taşı", "Series B", "Erken Erişim'de",
                        "Series A oyunu bitirmez. İkinci tur para, prestij ve daha yüksek bir çıta getirir; koşu devam eder."))
        out.append(tier("Kilometre taşı", "Halka arz", "Tam sürümde",
                        "Değerleme eşiği geçildiğinde kapı görünür olur. Ardındaki oyun başka bir oyundur: regülasyon, kamu gözü, devlerle aynı pazar."))
        out.append('<div class="er-cta">%s</div>' % btn("Wishlist'e ekle", "primary", "lg", style="width:100%"))
        out.append(end_actions(toast_shown=toast))
    else:
        # EA: no store CTA and no coming-soon cards; Tekrar dene is the one primary, full width, as milestone's Devam et
        out.append('<div class="er-cta" style="margin-top:24px">%s</div>' % btn("Tekrar dene", "primary", "lg", style="width:100%"))
        out.append(end_actions(retry=False))
    if toast:
        out.append(share_toast())
    return '<aside class="end-rail">%s</aside>' % "".join(out)


def ending(key, mode="demo", toast=False, notice=None):
    p = PAPERS[key]
    strip = frank_strip(p["frank"], p.get("frank_draft")) if mode == "demo" else ""
    if NARROW:
        # 1536 x 864: the rail narrows to 520 and the gutters to 24; the paper keeps its island ladder
        col = '<div class="end-paper-col" style="left:24px;top:24px;bottom:24px;width:968px">%s%s</div>' % (paper(key), strip)
        rail_html = end_rail(key, mode, toast, notice).replace('<aside class="end-rail">', '<aside class="end-rail" style="width:520px;padding:24px 24px 24px">')
        return '<div class="end" style="width:1536px;height:864px">%s%s</div>' % (col, rail_html)
    col = '<div class="end-paper-col">%s%s</div>' % (paper(key), strip)
    return '<div class="end">%s%s</div>' % (col, end_rail(key, mode, toast, notice))


# ------------------------------------------------------------------ frames
FRAMES = {
    # Ayarlar
    "ayarlar__ust": ("tr", f_set_top),
    "ayarlar__alt": ("tr", f_set_bottom),
    "ayarlar__pencere_modu_acik": ("tr", f_set_mode),
    "ayarlar__cozunurluk_acik": ("tr", f_set_res),
    "ayarlar__olcek_acik": ("tr", f_set_scale),
    "ayarlar__oto_kayit_acik": ("tr", f_set_auto),
    "ayarlar__ozet_acik": ("tr", f_set_sum),
    "ayarlar__dil_acik": ("tr", f_set_lang),
    "ayarlar__renk_koru_acik": ("tr", f_set_cb),
    "ayarlar__sifirla_onay": ("tr", f_set_reset),
    "ayarlar__ust_en": ("en", f_set_top),
    "ayarlar__alt_en": ("en", f_set_bottom),
    # Sistem menüsü
    "sistem__normal": ("tr", f_sys),
    "sistem__karar_bekliyor": ("tr", f_sys_gated),
    "sistem__normal_en": ("en", f_sys),
    # Kayıt / Yükle
    "kayit__bos": ("tr", f_save_empty),
    "kayit__dolu": ("tr", f_save_full),
    "kayit__karar_bekliyor": ("tr", f_save_gated),
    "kayit__f5_reddedildi": ("tr", f_f5_refused),
    "yukle__bos": ("tr", f_load_empty),
    "yukle__dolu": ("tr", f_load_full),
    "yukle__sil_onay": ("tr", f_delete_confirm),
    # Onay
    "onay__iki_dugme": ("tr", f_confirm2),
    "onay__uc_dugme": ("tr", f_confirm3),
    "onay__uc_dugme_karar_bekliyor": ("tr", f_confirm3_gated),
    "onay__uc_dugme_en": ("en", f_confirm3),
    # Açılış
    "acilis__dil_kapisi": ("tr", f_gate),
    "acilis__dil_kapisi_ustunde": ("tr", f_gate_hover),
    "acilis__kurucu": ("tr", f_char_default),
    "acilis__kurucu_dolu": ("tr", f_char_filled),
    "acilis__koken": ("tr", f_origin_empty),
    "acilis__koken_negatif_eksik": ("tr", f_origin_owed),
    "acilis__koken_dolu": ("tr", f_origin_filled),
    "acilis__koken_dolu_en": ("en", f_origin_filled),
    "acilis__sirket": ("tr", f_company_empty),
    "acilis__sirket_dolu": ("tr", f_company_filled),
    "acilis__yukleniyor": ("tr", f_loading),
    # Son ekranı
    "son__series_a_demo": ("tr", lambda: ending("series_a_close")),
    "son__series_a_agresif_demo": ("tr", lambda: ending("series_a_agg")),
    "son__satis_demo": ("tr", lambda: ending("acquisition")),
    "son__marka_coktu_demo": ("tr", lambda: ending("brand_collapse")),
    "son__vc_ret_demo": ("tr", lambda: ending("vc_rejection_cascade")),
    "son__ilgi_sondu_demo": ("tr", lambda: ending("running_on_fumes")),
    "son__kendi_paranla_demo": ("tr", lambda: ending("profitable_bootstrap")),
    "son__iflas_1_demo": ("tr", lambda: ending("bankruptcy1")),
    "son__iflas_2_demo": ("tr", lambda: ending("bankruptcy2")),
    "son__iflas_3_demo": ("tr", lambda: ending("bankruptcy3")),
    "son__series_a_ea": ("tr", lambda: ending("series_a_close", "ea")),
    "son__kilometre_tasi_ea": ("tr", lambda: ending("profitable_bootstrap", "milestone")),
    "son__kilometre_tasi_ea_kayit_engelli": ("tr", lambda: ending("profitable_bootstrap", "milestone", notice=save_err())),
    "son__paylasildi_demo": ("tr", lambda: ending("series_a_close", toast=True)),
    # 1536 x 864 logical (scale 1.25): the narrowest layout
    "ayarlar__ust_1536": ("tr", f_set_top),
    "acilis__kurucu_dolu_1536": ("tr", f_char_filled),
    "acilis__koken_dolu_1536": ("tr", f_origin_filled),
    "son__series_a_demo_1536": ("tr", lambda: ending("series_a_close")),
    # English width pass for the narrow places
    "sistem__karar_bekliyor_en": ("en", f_sys_gated),
    "acilis__sirket_dolu_en": ("en", f_company_filled),
}


def build(names):
    global NARROW
    os.makedirs(BUILD, exist_ok=True)
    for n in names:
        lang, fn = FRAMES[n]
        set_lang(lang)
        NARROW = n.endswith("_1536")
        cb = n == "ayarlar__renk_koru_acik"
        html = page(fn(), n.split("__")[0].capitalize(), cb=cb, w1536=NARROW)
        with open(os.path.join(BUILD, n + ".html"), "w", encoding="utf-8") as f:
            f.write(html)
        print(n)
    set_lang("tr")


if __name__ == "__main__":
    build(sys.argv[1:] or list(FRAMES))
