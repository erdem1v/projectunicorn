#!/usr/bin/env python3
"""Kod haritasi ureticisi (yalniz standart kutuphane).

Kullanim (project-unicorn icinden):  python -I tools/kod_haritasi/uret.py
Uretir:  docs/kod_haritasi/DIZIN.md, docs/kod_haritasi/SEMBOLLER.tsv, docs/kod_haritasi/KALITE.md
Yalniz okur; oyun kodu, data/ ve git index'ine dokunmaz. Ayni kodla iki kosu ayni ciktiyi verir
(baslikta yalniz git sha ve tarih degisir).
"""
import csv
import datetime
import json
import os
import re
import subprocess
import sys
import time
from collections import Counter, defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT_DIR = os.path.join(ROOT, "docs", "kod_haritasi")
MAX_LINE = 240
# .gd taranan koklar. scripts/ asil oyun kodu; tools/ ve sandbox/ yardimci (olu kod analizine girmez).
GD_ROOTS = ["scripts", "tools", "sandbox"]
TSCN_SKIP = {".godot", ".git", "addons", "__pycache__"}
LONG_FUNC = 80
AUX_PREFIXES = ("scripts/debug/", "tools/", "sandbox/")

GODOT_CALLBACKS = {
    "_init", "_ready", "_process", "_physics_process", "_input", "_unhandled_input",
    "_unhandled_key_input", "_shortcut_input", "_enter_tree", "_exit_tree", "_notification",
    "_draw", "_gui_input", "_get_minimum_size", "_to_string", "_get", "_set",
    "_get_property_list", "_validate_property", "_property_can_revert", "_property_get_revert",
    "_can_drop_data", "_drop_data", "_get_drag_data", "_make_custom_tooltip", "_has_point",
    "_get_configuration_warnings", "_static_init", "_run", "_initialize", "_finalize",
    "_clips_input", "_get_tooltip", "_structured_text_parser", "_iter_init", "_iter_next",
    "_iter_get", "_integrate_forces", "_get_import_options", "_enter_world", "_exit_world",
    "_handles", "_edit", "_make_visible", "_has_main_screen", "_get_plugin_name",
    "_get_plugin_icon", "_enable_plugin", "_disable_plugin", "_forward_canvas_gui_input",
    "_forward_3d_gui_input", "_post_import", "_accessibility_get_contextual_info",
    "_get_accessibility_container_name", "_input_event", "_mouse_enter", "_mouse_exit",
    "_on_unhandled_input", "_process_modification", "_process_modification_with_delta",
    "_setup_modification", "_unhandled_key", "_physics_process_modification",
}

# ---------------------------------------------------------------------------------- yardimcilar


def rel(path):
    return os.path.relpath(path, ROOT).replace("\\", "/")


def clip(line):
    if len(line) <= MAX_LINE:
        return line
    return line[: MAX_LINE - 1] + "…"


def read_text(path):
    with open(path, "r", encoding="utf-8-sig", errors="replace") as f:
        return f.read().replace("\r\n", "\n").replace("\r", "\n")


def walk_files(top, exts, skip=TSCN_SKIP):
    out = []
    base = os.path.join(ROOT, top) if top else ROOT
    if not os.path.isdir(base):
        return out
    for dirpath, dirnames, filenames in os.walk(base):
        dirnames[:] = sorted(d for d in dirnames if d not in skip and not d.startswith("."))
        for fn in sorted(filenames):
            if fn.lower().endswith(exts):
                out.append(os.path.join(dirpath, fn))
    return sorted(out, key=lambda p: rel(p))


def fit(head, items, limit, sep=", "):
    """head + en cok limit oge; satir MAX_LINE'i asmasin diye sigmayanlar '+N' olur."""
    shown = []
    for k, it in enumerate(items[:limit]):
        rest = len(items) - k - 1
        tail = " +%d" % rest if rest else ""
        cand = head + sep.join(shown + [it])
        if len(cand) + len(tail) + 4 > MAX_LINE and shown:
            break
        shown.append(it)
    line = head + (sep.join(shown) or "-")
    if len(items) > len(shown):
        line += " +%d" % (len(items) - len(shown))
    return clip(line)


def aux_last(paths):
    return sorted(paths, key=lambda x: (x.startswith(AUX_PREFIXES), x))


def more(items, limit):
    """items listesinden en cok limit tanesi; fazlasi '+N'."""
    shown = list(items[:limit])
    if len(items) > limit:
        shown.append("+%d" % (len(items) - limit))
    return shown


def group_locs(locs, limit=6, room=MAX_LINE):
    """[(path, line)] -> 'a.gd:1,4, b.gd:9 +N': en cok limit yer, en cok room karakter.

    Oyun kodu once; scripts/debug/, tools/, sandbox/ sona.
    """
    locs = sorted(set(locs), key=lambda x: (x[0].startswith(AUX_PREFIXES), x[0], x[1]))
    if not locs:
        return "-"
    n = min(limit, len(locs))
    while True:
        byfile = {}
        for p, ln in locs[:n]:
            byfile.setdefault(p, []).append(str(ln))
        s = ", ".join("%s:%s" % (p, ",".join(v)) for p, v in byfile.items())
        if len(locs) > n:
            s += " +%d" % (len(locs) - n)
        if len(s) <= room or n == 1:
            return s
        n -= 1


# ------------------------------------------------------------------------- GDScript ayristirici


def mask_gd(text):
    """Her fiziksel satir icin (masked, nocomment, comment, stmt_start) dondurur.

    masked:    yorum silinmis, dize icerigi '_' ile ayni uzunlukta maskelenmis (tirnaklar kalir)
    nocomment: yorum silinmis, dizeler oldugu gibi
    comment:   satirin yorum kismi ('#' sonrasi), yoksa ''
    stmt_start: satir yeni bir deyim baslatiyor mu (parantez derinligi 0, uclu dize disi,
                onceki satir '\\' ile bitmiyor)
    """
    lines = text.split("\n")
    res = []
    in_triple = None  # '"""' ya da "'''"
    in_str = None  # GDScript tek tirnakli dizeyi de satir sonunda kesmez
    depth = 0
    cont = False
    for line in lines:
        start_ok = in_triple is None and in_str is None and depth == 0 and not cont
        m = []
        n = []
        comment = ""
        i = 0
        L = len(line)
        while i < L:
            c = line[i]
            if in_triple is not None:
                if line.startswith(in_triple, i):
                    m.append(in_triple)
                    n.append(in_triple)
                    i += 3
                    in_triple = None
                    continue
                if c == "\\" and i + 1 < L:
                    m.append("__")
                    n.append(line[i:i + 2])
                    i += 2
                    continue
                m.append("_")
                n.append(c)
                i += 1
                continue
            if in_str is not None:
                if c == "\\" and i + 1 < L:
                    m.append("__")
                    n.append(line[i:i + 2])
                    i += 2
                    continue
                if c == in_str:
                    m.append(c)
                    n.append(c)
                    in_str = None
                    i += 1
                    continue
                m.append("_")
                n.append(c)
                i += 1
                continue
            if c == "#":
                comment = line[i:]
                break
            if c in "\"'":
                if line.startswith(c * 3, i):
                    in_triple = c * 3
                    m.append(c * 3)
                    n.append(c * 3)
                    i += 3
                    continue
                in_str = c
                m.append(c)
                n.append(c)
                i += 1
                continue
            if c in "([{":
                depth += 1
            elif c in ")]}":
                depth = max(0, depth - 1)
            m.append(c)
            n.append(c)
            i += 1
        masked = "".join(m)
        nocom = "".join(n)
        cont = masked.rstrip().endswith("\\") and in_triple is None and in_str is None
        has_code = masked.strip() != ""
        res.append((masked, nocom, comment, start_ok and has_code))
    return res


ANNOT_RE = re.compile(r"^(?:@\w+(?:\([^()]*(?:\([^()]*\)[^()]*)*\))?\s*)*")
RE_CLASS_NAME = re.compile(r"^class_name\s+(\w+)")
RE_EXTENDS = re.compile(r"^(?:class_name\s+\w+\s+)?extends\s+(.+?)\s*$")
RE_FUNC = re.compile(r"^(static\s+)?func\s+(\w+)")
RE_SIGNAL = re.compile(r"^signal\s+(\w+)\s*(\([^)]*\))?")
RE_VAR = re.compile(r"^(?:static\s+)?var\s+(\w+)")
RE_CONST = re.compile(r"^const\s+(\w+)")
RE_ENUM = re.compile(r"^enum\s*(\w+)?\s*\{")
RE_CLASS = re.compile(r"^class\s+(\w+)\b")
RE_EMIT = re.compile(r"\b([A-Za-z_]\w*)\s*\.emit\b")  # sig.emit(...) ve Callable olarak sig.emit
RE_CONNECT = re.compile(r"\b([A-Za-z_]\w*)\s*\.connect\s*\(\s*(?![\"'])")
RE_EMIT_STR = re.compile(r"\bemit_signal\s*\(\s*[&]?[\"']([^\"']+)[\"']")
RE_CONNECT_STR = re.compile(r"\bconnect\s*\(\s*[&]?[\"']([^\"']+)[\"']")
RE_SIGREF = re.compile(r"(?=\b([A-Za-z_]\w*)\s*\.\s*([A-Za-z_]\w*)\b)")  # ortusen: a.b.sig zincirinde sig da  # x.ad: degerle gecen sinyal adayi
RE_TODO = re.compile(r"\b(TODO|FIXME|HACK)\b")
RE_WORD = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")


def indent_of(s):
    n = 0
    for ch in s:
        if ch == "\t":
            n += 4
        elif ch == " ":
            n += 1
        else:
            break
    return n


class GdFile:
    def __init__(self, path, label_hint=None):
        self.path = path
        self.rel = rel(path)
        self.text = read_text(path)
        self.rows = mask_gd(self.text)
        self.nlines = len(self.rows) if not self.text.endswith("\n") else len(self.rows) - 1
        self.class_name = ""
        self.extends = ""
        self.symbols = []  # (name, kind, line, cls)
        self.funcs = []  # (name, start, end, cls, static)
        self.signals = []  # (name, args, line)
        self.consts = []  # (name, line, cls, is_enum_member)
        self.def_lines = defaultdict(list)  # name -> [line] (tanim satirlari)
        self.todo = 0
        self.label_hint = label_hint
        self._parse()

    def logical(self, i, key):
        """i. satirdan baslayan mantiksal deyim metni (masked=0 / nocomment=1)."""
        parts = [self.rows[i][key]]
        j = i + 1
        while j < len(self.rows) and not self.rows[j][3]:
            parts.append(self.rows[j][key])
            # deyim bir sonraki stmt_start'a kadar suruyor; enum/signal icin yeterli
            j += 1
            if j - i > 400:
                break
        return " ".join(p.strip() for p in parts)

    def _parse(self):
        rows = self.rows
        last_code = []
        lc = -1
        for idx, r in enumerate(rows):
            last_code.append(lc)  # idx'ten onceki son kod satiri
            if r[0].strip():
                lc = idx
        final_code = lc
        for r in rows:
            if RE_TODO.search(r[2]):
                self.todo += len(RE_TODO.findall(r[2]))
        # ilk gecis: class_name (sinif etiketi icin)
        for idx, r in enumerate(rows):
            if r[3] and indent_of(r[0]) == 0:
                t = ANNOT_RE.sub("", r[0].strip())
                mm = RE_CLASS_NAME.match(t)
                if mm:
                    self.class_name = mm.group(1)
                    self.symbols.append((mm.group(1), "class", idx + 1, mm.group(1)))
                    break
        base = self.class_name or self.label_hint or os.path.basename(self.path)
        stack = [("file", -1, base, 0)]  # (tur, girinti, etiket, baslangic)

        def close(top, end_idx):
            if top[0] == "func":
                name, start, cls, static = top[2]
                self.funcs.append((name, start + 1, end_idx + 1, cls, static))

        for idx, r in enumerate(rows):
            if not r[3]:
                continue
            ind = indent_of(r[0])
            while len(stack) > 1 and ind <= stack[-1][1]:
                close(stack.pop(), last_code[idx])
            top = stack[-1]
            if top[0] not in ("file", "class"):
                continue
            cls = top[2]
            raw_masked = r[0].strip()
            t = ANNOT_RE.sub("", raw_masked)
            off = len(raw_masked) - len(t)
            nocom = r[1].strip()[off:]
            line = idx + 1
            mm = RE_FUNC.match(t)
            if mm:
                name = mm.group(2)
                self.symbols.append((name, "func", line, cls))
                self.def_lines[name].append(idx)
                stack.append(("func", ind, (name, idx, cls, bool(mm.group(1))), idx))
                continue
            mm = RE_SIGNAL.match(t)
            if mm:
                name = mm.group(1)
                lg = self.logical(idx, 1)
                lg = ANNOT_RE.sub("", lg)
                am = re.match(r"^signal\s+\w+\s*(\([^)]*\))?", lg)
                args = re.sub(r"\s+", " ", am.group(1)) if am and am.group(1) else ""
                args = args.replace("( ", "(").replace(" )", ")").replace(", )", ")")
                self.signals.append((name, args, line))
                self.symbols.append((name, "signal", line, cls))
                self.def_lines[name].append(idx)
                continue
            mm = RE_CLASS.match(t)
            if mm:
                name = mm.group(1)
                self.symbols.append((name, "class", line, cls))
                self.def_lines[name].append(idx)
                stack.append(("class", ind, cls + "." + name, idx))
                continue
            mm = RE_ENUM.match(t)
            if mm:
                ename = mm.group(1)
                if ename:
                    self.symbols.append((ename, "enum", line, cls))
                    self.def_lines[ename].append(idx)
                ecls = cls + "." + ename if ename else cls
                # uyeler kendi fiziksel satirlariyla: '{' sonrasindan '}' oncesine
                j = idx
                opened = False
                pending = True  # bir sonraki parca yeni uye mi basliyor
                while j < len(self.rows):
                    seg = self.rows[j][1]
                    if not opened:
                        k = seg.find("{")
                        if k < 0:
                            j += 1
                            continue
                        seg = seg[k + 1:]
                        opened = True
                    closed = "}" in seg
                    if closed:
                        seg = seg[: seg.find("}")]
                    parts = seg.split(",")
                    for pi, part in enumerate(parts):
                        if pi > 0:
                            pending = True
                        pm = re.match(r"\s*([A-Za-z_]\w*)", part)
                        if pending and pm:
                            self.symbols.append((pm.group(1), "const", j + 1, ecls))
                            self.consts.append((pm.group(1), j + 1, ecls, True))
                            pending = False
                    if closed or j - idx > 400:
                        break
                    j += 1
                continue
            mm = RE_CONST.match(t)
            if mm:
                self.symbols.append((mm.group(1), "const", line, cls))
                self.consts.append((mm.group(1), line, cls, False))
                self.def_lines[mm.group(1)].append(idx)
                if self.logical(idx, 0).rstrip().endswith(":"):
                    stack.append(("prop", ind, cls, idx))
                continue
            mm = RE_VAR.match(t)
            if mm:
                self.symbols.append((mm.group(1), "var", line, cls))
                self.def_lines[mm.group(1)].append(idx)
                if self.logical(idx, 0).rstrip().endswith(":"):
                    stack.append(("prop", ind, cls, idx))  # set/get ya da lambda govdesi
                continue
            if top[0] == "file" and ind == 0:
                mm = RE_EXTENDS.match(nocom)
                if mm and not self.extends:
                    self.extends = mm.group(1).strip().rstrip(":")
        while len(stack) > 1:
            close(stack.pop(), final_code)
        self.funcs.sort(key=lambda f: f[1])

    def signal_uses(self):
        """(ad, 'emit'|'connect', satir) listesi."""
        out = []
        for idx, (masked, nocom, _c, _s) in enumerate(self.rows):
            if ".emit" in masked:
                for mm in RE_EMIT.finditer(masked):
                    out.append((mm.group(1), "emit", idx + 1))
            if ".connect" in masked:
                for mm in RE_CONNECT.finditer(masked):
                    out.append((mm.group(1), "connect", idx + 1))
            if "emit_signal" in masked:
                for mm in RE_EMIT_STR.finditer(nocom):
                    if masked[mm.start()] == nocom[mm.start()]:
                        out.append((mm.group(1), "emit", idx + 1))
            if "connect" in masked:
                for mm in RE_CONNECT_STR.finditer(nocom):
                    if masked[mm.start()] == nocom[mm.start()]:
                        out.append((mm.group(1), "connect", idx + 1))
        return out

    def code_tokens(self):
        """Yorumsuz metindeki (dizeler dahil) kelimeler."""
        c = Counter()
        for _m, nocom, _c, _s in self.rows:
            c.update(RE_WORD.findall(nocom))
        return c


# ------------------------------------------------------------------------------- toplayicilar


def load_autoloads():
    pg = read_text(os.path.join(ROOT, "project.godot"))
    out = []
    sec = None
    for line in pg.split("\n"):
        s = line.strip()
        if s.startswith("["):
            sec = s
            continue
        if sec == "[autoload]" and "=" in s:
            k, v = s.split("=", 1)
            out.append((k.strip(), v.strip().strip('"').lstrip("*")))
    return out


def uid_map():
    m = {}
    for top in ("scripts", "addons", "scenes", "tools", "sandbox"):
        for p in walk_files(top, (".uid",), skip={".godot", ".git", "__pycache__"}):
            u = read_text(p).strip()
            if u.startswith("uid://"):
                m[u] = "res://" + rel(p)[: -len(".uid")]
    return m


def parse_tscn(path):
    text = read_text(path)
    ext = {}
    root_type = "?"
    script = "-"
    in_root = False
    seen_root = False
    conns = []
    for ln, line in enumerate(text.split("\n"), 1):
        if line.startswith("[ext_resource"):
            idm = re.search(r'\bid="([^"]+)"', line)
            pm = re.search(r'\bpath="([^"]+)"', line)
            if idm:
                ext[idm.group(1)] = pm.group(1) if pm else "?"
            continue
        if line.startswith("[node"):
            if not seen_root and "parent=" not in line:
                seen_root = True
                in_root = True
                tm = re.search(r'\btype="([^"]+)"', line)
                im = re.search(r'instance=ExtResource\(\s*"([^"]+)"\s*\)', line)
                if tm:
                    root_type = tm.group(1)
                elif im:
                    root_type = "örnek:" + ext.get(im.group(1), "?").replace("res://", "")
            else:
                in_root = False
            continue
        if line.startswith("[connection"):
            sm = re.search(r'\bsignal="([^"]+)"', line)
            mm = re.search(r'\bmethod="([^"]+)"', line)
            if sm:
                conns.append((sm.group(1), ln, mm.group(1) if mm else ""))
            in_root = False
            continue
        if line.startswith("["):
            in_root = False
            continue
        if in_root and line.startswith("script = "):
            em = re.search(r'ExtResource\(\s*"([^"]+)"\s*\)', line)
            if em:
                script = ext.get(em.group(1), "?").replace("res://", "")
    return root_type, script, conns, text


def json_summary(path):
    try:
        with open(path, "r", encoding="utf-8-sig") as f:
            d = json.load(f)
    except Exception as e:  # noqa: BLE001
        return "JSON OKUNAMADI (%s)" % type(e).__name__
    if isinstance(d, dict):
        keys = list(d.keys())
        return "{" + ", ".join(more(keys, 10)) + "}" if keys else "{}"
    if isinstance(d, list):
        return "[liste, %d öğe]" % len(d)
    return type(d).__name__


def git_head():
    try:
        r = subprocess.run(["git", "-C", ROOT, "rev-parse", "--short", "HEAD"],
                           capture_output=True, text=True, timeout=10)
        return r.stdout.strip() or "?"
    except Exception:  # noqa: BLE001
        return "?"


def human_size(n):
    if n < 1024:
        return "%d B" % n
    if n < 1024 * 1024:
        return "%.1f KB" % (n / 1024)
    return "%.2f MB" % (n / 1024 / 1024)


# ------------------------------------------------------------------------------------- uretim


def main():
    t0 = time.time()
    os.makedirs(OUT_DIR, exist_ok=True)
    autoloads = load_autoloads()
    uids = uid_map()
    auto_by_path = {}
    auto_rows = []
    for name, p in autoloads:
        rp = uids.get(p, p) if p.startswith("uid://") else p
        auto_rows.append((name, rp.replace("res://", ""), p if p.startswith("uid://") else ""))
        auto_by_path[rp.replace("res://", "")] = name

    gd_files = []
    for top in GD_ROOTS:
        for p in walk_files(top, (".gd",)):
            gd_files.append(GdFile(p, auto_by_path.get(rel(p))))
    gd_by_rel = {g.rel: g for g in gd_files}
    game_gd = [g for g in gd_files if g.rel.startswith("scripts/")]

    tscn_paths = walk_files("", (".tscn",))
    scenes = []
    tscn_conns = defaultdict(list)  # sinyal -> [(yol, satir)]
    scene_texts = []
    for p in tscn_paths:
        rt, scr, conns, text = parse_tscn(p)
        scenes.append((rel(p), rt, scr))
        for sig, ln, _meth in conns:
            tscn_conns[sig].append((rel(p), ln))
        if rel(p).startswith("scenes/"):
            scene_texts.append(text)

    data_files = walk_files("data", (".json",))

    # ------------------------------------------------------------------ SEMBOLLER.tsv
    sym_rows = []
    for g in gd_files:
        for name, kind, line, cls in g.symbols:
            sym_rows.append((name, kind, "%s:%d" % (g.rel, line), cls))
    sym_rows = sorted(set(sym_rows), key=lambda r: (r[0].lower(), r[0], r[2].split(":")[0],
                                                    int(r[2].rsplit(":", 1)[1]), r[1]))
    with open(os.path.join(OUT_DIR, "SEMBOLLER.tsv"), "w", encoding="utf-8", newline="\n") as f:
        f.write("sembol\ttür\tyer\tsınıf\n")
        for r in sym_rows:
            f.write(clip("\t".join(r)) + "\n")

    # ------------------------------------------------------------------ sinyal kullanimlari
    emits = defaultdict(list)
    connects = defaultdict(list)
    for g in gd_files:
        for name, kind, line in g.signal_uses():
            (emits if kind == "emit" else connects)[name].append((g.rel, line))
    for sig, locs in tscn_conns.items():
        connects[sig].extend(locs)
    # Dizi ya da deger olarak gecen sinyal (`_signals = [EventBus.a, ...]` + dongude connect, `await x.a`,
    # `_until(x.a, ...)`): bunlar da baglanmadir; yoksa connect sutunu ve "yarim sinyaller" yanlis "-" der.
    sig_names = {name for g in gd_files for name, _a, _l in g.signals}
    for g in gd_files:
        for idx, (masked, _n, _c, _s) in enumerate(g.rows):
            if "." not in masked:
                continue
            for mm in RE_SIGREF.finditer(masked):
                name = mm.group(2)
                if name not in sig_names:
                    continue
                # tek kelimelik ad (back, closed) sozluk anahtariyla karisir: yalniz EventBus'ta ya da await'te say
                if "_" not in name and mm.group(1) != "EventBus" and "await" not in masked:
                    continue
                rest = masked[mm.end(2):].lstrip()
                if rest.startswith((".", "(", "=")) and not rest.startswith("=="):
                    continue  # .emit/.connect zaten sayildi; ( cagri; = atama
                loc = (g.rel, idx + 1)
                if loc not in connects[name]:
                    connects[name].append(loc)
    # Olay motoru izin listesi: EvSignals.BINDINGS'teki her ad EventBus.connect(ad, ...) ile dizeyle baglanir.
    ev = gd_by_rel.get("scripts/events/core/signals.gd")
    if ev:
        inside = False
        for idx, (masked, nocom, _c, _s) in enumerate(ev.rows):
            if not inside:
                inside = masked.lstrip().startswith("const BINDINGS")
                continue
            if masked.strip() == "}":
                break
            km = re.match(r'\s*"(\w+)"\s*:', nocom)
            if km and km.group(1) in sig_names:
                connects[km.group(1)].append((ev.rel, idx + 1))

    # ------------------------------------------------------------------ strings.csv aileleri
    csv_path = os.path.join(ROOT, "localization", "strings.csv")
    fam_count = Counter()
    with open(csv_path, "r", encoding="utf-8-sig", newline="") as f:
        rd = csv.reader(f)
        next(rd, None)
        for row in rd:
            if not row or not row[0].strip():
                continue
            fam_count["_".join(row[0].strip().split("_")[:2])] += 1
    fam_files = defaultdict(list)
    fam_src = [g.rel for g in gd_files] + [rel(p) for p in data_files]
    texts = {g.rel: g.text for g in gd_files}
    for p in data_files:
        texts[rel(p)] = read_text(p)
    for rp in sorted(fam_src):
        seen = set()
        for tok in set(RE_WORD.findall(texts[rp])):
            seen.add("_".join(tok.split("_")[:2]))
        for fam in seen & fam_count.keys():
            fam_files[fam].append(rp)

    head = git_head()
    today = datetime.date.today().isoformat()

    # ------------------------------------------------------------------ DIZIN.md
    D = []
    D.append("# Kod haritası · DIZIN")
    D.append("")
    D.append("Üretildi: git %s · %s · betik `tools/kod_haritasi/uret.py`" % (head, today))
    D.append("Yeniden üret (project-unicorn içinden): `python -I tools/kod_haritasi/uret.py` (<30 sn)")
    D.append("Dosyalar diskteki halidir (kirli ağaç dahil). Elle düzenleme; betiği koş.")
    D.append("")
    D.append("Sembol: `LC_ALL=C.UTF-8 grep -P \"^ad\\t\" docs/kod_haritasi/SEMBOLLER.tsv` (Git Bash'te LC_ALL şart) ya da "
             "`awk -F'\\t' '$1==\"ad\"' SEMBOLLER.tsv`; Grep aracında desen `^ad\\t`.")
    D.append("Sinyal: `grep \"^- ad(\" DIZIN.md`. Dosya: `grep \"yol ·\" DIZIN.md`. Kalite adayları: KALITE.md.")
    D.append("Sınırlar: ayrıştırma sözdizimseldir (tür çözümü yok); sinyal eşlemesi ada göre; ölü kod listesi aday.")
    D.append("Bölümler: Autoload'lar · Dosyalar · Sinyaller · Sahneler · Veri dosyaları · "
             "Metin anahtarı aileleri. Kalite listeleri: KALITE.md.")
    D.append("")
    D.append("## Autoload'lar (%d)" % len(auto_rows))
    D.append("")
    for name, p, uid in auto_rows:
        D.append(clip("- %s · %s%s" % (name, p, (" · " + uid) if uid else "")))
    D.append("")
    D.append("## Dosyalar (%d .gd)" % len(gd_files))
    D.append("")
    D.append("Biçim: yol · satır · class_name · extends · sinyal · func (iç sınıflar dahil). "
             "Autoload dosyalarında class_name yerine [AutoloadAdı].")
    groups = defaultdict(list)
    for g in gd_files:
        groups[os.path.dirname(g.rel)].append(g)
    for folder in sorted(groups):
        fs = groups[folder]
        D.append("")
        D.append("### %s/ (%d dosya, %d satır)" % (folder, len(fs), sum(x.nlines for x in fs)))
        for g in fs:
            cn = g.class_name or ("[%s]" % g.label_hint if g.label_hint else "-")
            D.append(clip("- %s · %d · %s · %s · %d sinyal · %d func" % (
                g.rel, g.nlines, cn, g.extends or "-", len(g.signals), len(g.funcs))))
    D.append("")
    all_sigs = []
    for g in gd_files:
        for name, args, line in g.signals:
            all_sigs.append((g.rel, line, name, args))
    D.append("## Sinyaller (%d)" % len(all_sigs))
    D.append("")
    D.append("Eşleme ada göredir (alıcı nesne çözülmez); aynı adlı iki sinyal varsa yerler ikisine de "
             "yazılır. connect yerlerine .tscn [connection] satırları ve değer olarak geçen sinyal (dizi içi bağ, await) "
             "dahil. Uzun satır `  ↳ ad` ile sürer.")
    cur = None
    name_defs = Counter(s[2] for s in all_sigs)
    for rp, line, name, args in all_sigs:
        if rp != cur:
            cur = rp
            D.append("")
            D.append("### %s" % rp)
        e = group_locs(emits.get(name, []))
        c = group_locs(connects.get(name, []))
        dup = " · (ad %d yerde tanımlı)" % name_defs[name] if name_defs[name] > 1 else ""
        one = "- %s%s · %s:%d · emit: %s · connect: %s%s" % (name, args or "()", rp, line, e, c, dup)
        if len(one) <= MAX_LINE:
            D.append(one)
        else:
            D.append(clip("- %s%s · %s:%d%s" % (name, args or "()", rp, line, dup)))
            for kind, src in (("emit", emits), ("connect", connects)):
                lead = "  ↳ %s %s: " % (name, kind)
                D.append(clip(lead + group_locs(src.get(name, []), room=MAX_LINE - len(lead))))
    D.append("")
    D.append("## Sahneler (%d .tscn)" % len(scenes))
    D.append("")
    D.append("Biçim: yol · kök düğüm türü (örnek: = miras alınan sahne) · kök betik")
    for rp, rt, scr in scenes:
        D.append(clip("- %s · %s · %s" % (rp, rt, scr)))
    D.append("")
    D.append("## Veri dosyaları (%d .json, data/)" % len(data_files))
    D.append("")
    D.append("Biçim: yol · boyut · üst düzey anahtarlar (en çok 10)")
    for p in data_files:
        D.append(clip("- %s · %s · %s" % (rel(p), human_size(os.path.getsize(p)), json_summary(p))))
    D.append("")
    D.append("## Metin anahtarı aileleri (%d aile, %d anahtar)" % (len(fam_count), sum(fam_count.values())))
    D.append("")
    D.append("Aile = anahtarın ilk iki '_' parçası. Dosyalar: aile önekini metin olarak geçiren "
             ".gd/.json (en çok 5). '-' = dinamik kurulmuş olabilir ya da kullanılmıyor.")
    for fam in sorted(fam_count):
        D.append(fit("- %s_* · %d · " % (fam, fam_count[fam]), aux_last(fam_files.get(fam, [])), 5))
    D.append("")
    with open(os.path.join(OUT_DIR, "DIZIN.md"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(D))

    # ------------------------------------------------------------------ KALITE.md
    mentions = Counter()
    for g in gd_files:
        mentions.update(g.code_tokens())
    for t in scene_texts:
        mentions.update(RE_WORD.findall(t))
    for p in walk_files("data", (".json", ".csv", ".tres", ".cfg", ".txt", ".md")):
        mentions.update(RE_WORD.findall(texts.get(rel(p)) or read_text(p)))
    def_occ = Counter()
    for g in gd_files:
        for name, idxs in g.def_lines.items():
            for idx in idxs:
                def_occ[name] += RE_WORD.findall(g.rows[idx][1]).count(name)

    K = []
    K.append("# Kod haritası · KALITE")
    K.append("")
    K.append("Üretildi: git %s · %s · `python -I tools/kod_haritasi/uret.py`" % (head, today))
    K.append("Kapsam: scripts/ altındaki %d .gd (tools/ ve sandbox/ hariç). Kod temizliği ve kıdemli "
             "denetimde başlangıç listesi; kanıt değil, aday." % len(game_gd))
    K.append("")
    K.append("## En büyük 25 .gd")
    K.append("")
    for g in sorted(game_gd, key=lambda x: (-x.nlines, x.rel))[:25]:
        K.append("- %s · %d satır · %d func" % (g.rel, g.nlines, len(g.funcs)))
    K.append("")
    longf = []
    for g in game_gd:
        for name, s, e, cls, _st in g.funcs:
            if e - s + 1 > LONG_FUNC:
                longf.append((e - s + 1, g.rel, s, name))
    longf.sort(key=lambda x: (-x[0], x[1], x[2]))
    K.append("## %d satırdan uzun fonksiyonlar (%d tane, en uzun 40)" % (LONG_FUNC, len(longf)))
    K.append("")
    K.append("Uzunluk = imza satırından gövdenin son kod satırına (boş/yorum satırları arada sayılır).")
    for ln, rp, s, name in longf[:40]:
        K.append(clip("- %s:%d · %s · %d satır" % (rp, s, name, ln)))
    K.append("")
    dead = []
    for g in game_gd:
        for name, s, e, cls, _st in g.funcs:
            if name in GODOT_CALLBACKS:
                continue
            if mentions[name] - def_occ[name] <= 0:
                dead.append((g.rel, s, name))
    dead.sort()
    K.append("## Ölü kod adayları (%d)" % len(dead))
    K.append("")
    K.append("Tanım satırı dışında scripts/, scenes/, data/ içinde adı hiç geçmeyen func (yorumlar sayılmaz, "
             "dizeler sayılır). Godot geri çağrıları hariç.")
    K.append("UYARI: call(\"a\"+b) gibi kurulmuş adlar, sinyal adıyla bağlama, harness bayrakları ve tools/*.sh "
             "çağrıları yüzünden yanlış pozitif olabilir; silmeden önce grep ile doğrula.")
    for rp, s, name in dead:
        tag = " · MCP seam (_dbg_*/debug_*, Godot MCP adla çağırır)" if name.startswith(("_dbg_", "debug_")) else (
            " · debug" if rp.startswith(AUX_PREFIXES) else "")
        K.append(clip("- %s:%d · %s%s" % (rp, s, name, tag)))
    K.append("")
    lonely = [(rp, line, name, "emit yok" if not emits.get(name) else "connect yok")
              for rp, line, name, _a in all_sigs if not emits.get(name) or not connects.get(name)]
    K.append("## Yarım sinyaller (%d)" % len(lonely))
    K.append("")
    K.append("emit'i ya da connect'i bulunamayan sinyal (ada göre). Dizi içi bağ, await ve EvSignals.BINDINGS connect "
             "sayılır. Yanlış pozitif: bind(sig) ile değer olarak geçip değişkenden yayılan ya da yalnız smoke'ta adı geçen sinyal.")
    for rp, line, name, why in lonely:
        K.append(clip("- %s:%d · %s · %s" % (rp, line, name, why)))
    K.append("")
    cdefs = defaultdict(list)
    for g in game_gd:
        for name, line, cls, is_enum in g.consts:
            if not is_enum:
                cdefs[name].append((g.rel, line))
    dups = sorted(((n, locs) for n, locs in cdefs.items() if len({p for p, _ in locs}) > 1),
                  key=lambda x: (-len({p for p, _ in x[1]}), x[0]))
    K.append("## Birden çok dosyada tanımlı const (%d ad)" % len(dups))
    K.append("")
    K.append("Enum üyeleri hariç. Aynı değer mi, kopya mı, yalnız ad çakışması mı: elle bakılmalı.")
    for n, locs in dups:
        locs = sorted(set(locs), key=lambda x: (x[0].startswith(AUX_PREFIXES), x[0], x[1]))
        K.append(fit("- %s · %d dosya · " % (n, len({p for p, _ in locs})), ["%s:%d" % x for x in locs], 6))
    K.append("")
    todos = sorted(((g.todo, g.rel) for g in game_gd if g.todo), key=lambda x: (-x[0], x[1]))
    K.append("## TODO/FIXME/HACK (yorumlarda, %d dosya, toplam %d)" % (len(todos), sum(t for t, _ in todos)))
    K.append("")
    for t, rp in todos:
        K.append("- %s · %d" % (rp, t))
    if not todos:
        K.append("- (yok)")
    K.append("")
    with open(os.path.join(OUT_DIR, "KALITE.md"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(K))

    dt = time.time() - t0
    print("kod_haritasi: %d .gd, %d sembol, %d sinyal, %d sahne, %d json, %d aile, %.1f sn" % (
        len(gd_files), len(sym_rows), len(all_sigs), len(scenes), len(data_files), len(fam_count), dt))
    return 0


if __name__ == "__main__":
    sys.exit(main())
