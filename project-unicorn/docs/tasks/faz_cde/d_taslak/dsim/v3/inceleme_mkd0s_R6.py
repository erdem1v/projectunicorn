# D0s rapor tablolari: sonuc dosyalarindan (out/<etiket>/) markdown uretir. python -I dsim3.py exec mkd0s.py -> out/d0s_tablolar_R6.md
# Tum sayilar kosulardan gelir; metin yorumu rapora elle yazilir (D0s_SIM.md).
exec(open("dan.py", encoding="utf-8").read())
exec(open("dgroups.py", encoding="utf-8").read())
SCL = [("S1", 1), ("S2", 3), ("S3", 6), ("S4", 12), ("S5", 25), ("S6", 50)]
SECT = {}


def sec(name, text):
    SECT[name] = text


CFG = [("L", "Eski kural (D_SIM_v3: sprint sirasi, erken kapanis, cekme yok, PM haftanin en iyisi)"),
       ("R6", "R: Karar 4 (kadroyu plan sirasi, kisiyi buyukluk), PM ufuklu, sabit 2 hf + cekme, kalkan yalniz talep"),
       ("R5_asgsprint", "R, atama eski (kart sirasiyla doldur)"),
       ("R5_nopull", "R, cekme yok"),
       ("R5_early", "R, erken kapanis var"),
       ("R5_size", "PRD birebir Karar 4 ve 8 (kadro ve kisi buyukluge gore, haftalik PM), kalkan yalniz talep"),
       ("P", "PRD birebir tam (R_size + bitecek-kart kalkani)"),
       ("R_shield", "R + bitecek-kart kalkani")]


def cfg_table(names, key, fm, tags=None, idx=None, head=None, extra=""):
    rows = []
    for tg, lab in (tags or CFG):
        vs = []
        any_ = False
        for n in names:
            v = md(tg, n, key, idx) if have(tg, n) else None
            any_ |= v is not None
            vs.append(fm(v) if v is not None else "-")
        if any_:
            rows.append([lab] + vs)
    return table(rows, head or ["Kural"] + ["%d kisi" % k for _, k in SCL])


# ------------------------------------------------------------- olcek tablolari (sinirsiz arz)
def sec_scale():
    t = []
    for key, ad, fm in (("deliv", "Teslim (puan/hf)", f1), ("idle_pct", "Bosta payi", pc), ("fillplan", "Plan anindaki doluluk (medyan)", pc), ("open_med", "Acik hata (medyan)", f1), ("mvp", "MVP (hafta, medyan)", f1), ("pulls", "Sprintte cekilen kart (ortalama)", lambda x: f1(x, 2))):
        sec("olcek_" + key, cfg_table([n for n, _ in SCL], key, fm))
        t.append("**%s** (sinirsiz arz, 21-60. hafta, 20 tohum medyani)\n\n%s" % (ad, SECT["olcek_" + key]))
    sec("olcek", "\n\n".join(t))


# ------------------------------------------------------------- kaynakli arz: S1..S6 ve buyume egrisi
KAY = ["A|%s|kaynakli|2" % b for b, _ in SCL] + ["GC|kaynakli"]
KAYH = ["%d kisi" % k for _, k in SCL] + ["Buyume 1->10"]


def sec_kay():
    t = []
    for key, ad, fm in (("deliv", "Teslim (puan/hf)", f1), ("idle_pct", "Bosta payi", pc), ("fillplan", "Plan anindaki doluluk (medyan)", pc), ("pool_ok", "Acik aday >= hedef olan sprint", pc), ("nocard", "Kart yok sprinti", pc), ("pulls", "Sprintte cekilen kart (ortalama)", lambda x: f1(x, 2))):
        sec("kay_" + key, cfg_table(KAY, key, fm, head=["Kural"] + KAYH))
        t.append("**%s** (kaynakli arz)\n\n%s" % (ad, SECT["kay_" + key]))
    sec("kaynakli", "\n\n".join(t))


# ------------------------------------------------------------- SLICE 8 ve 40
def sec_slice():
    def cell(tg, n, key, fm):
        v = md(tg, n, key) if have(tg, n) else None
        return fm(v) if v is not None else "-"
    rows1 = [[lab, ad] + [cell(tg, n, key, fm) for n, _ in SCL] for tg, lab in (("R6", "8"), ("R5_slice40", "40"))
             for key, ad, fm in (("deliv", "Teslim (puan/hf)", f1), ("idle_pct", "Bosta payi", pc), ("fillplan", "Plan doluluk", pc), ("open_med", "Acik hata", f1))]
    rows2 = [[lab, ad] + [cell(tg, n, key, fm) for n in KAY] for tg, lab in (("R6", "8"), ("R5_slice40", "40"))
             for key, ad, fm in (("deliv", "Teslim (puan/hf)", f1), ("idle_pct", "Bosta payi", pc), ("pool_ok", "Arz yeterli sprint", pc), ("nocard", "Kart yok sprinti", pc))]
    NL = chr(10)
    sec("slice", "**Sinirsiz arz**" + NL + NL + table(rows1, ["SLICE", "Olcu"] + ["%d kisi" % k for _, k in SCL]) +
        NL + NL + "**Kaynakli arz** (arz yetersizligi = acik aday havuzunun hedefin altinda kaldigi sprint payi = 1 - 'arz yeterli sprint'; ayrica 'planlanacak kart kalmadi' sprinti)" + NL + NL +
        table(rows2, ["SLICE", "Olcu"] + KAYH))


# ------------------------------------------------------------- tek kurucu hata sprinti
def sec_founder():
    rows = []
    for tg, lab in (("L", "Eski (2 hf, erken kapanis)"), ("R6", "R (2 hf sabit, cekme)"), ("R5_size", "PRD birebir"), ("P", "PRD birebir tam")):
        for n, ad in (("S1", "S1 sinirsiz"), ("A|S1|kaynakli|2", "S1 kaynakli")):
            if have(tg, n):
                rows.append([lab, ad, "%s (%s)" % (hs(tg, n, "bs_all"), pc(tsum(tg, n, "bs_all", 0) / max(1, tsum(tg, n, "bs_all", 1)))),
                             "%s (%s)" % (hs(tg, n, "bs_late"), pc(tsum(tg, n, "bs_late", 0) / max(1, tsum(tg, n, "bs_late", 1)))), pc(md(tg, n, "fix_early")), pc(md(tg, n, "fix_late")), f1(md(tg, n, "deliv")), f1(md(tg, n, "mvp"))])
    sec("kurucu", table(rows, ["Kural", "Arz", "Hata sprinti (MVP sonrasi hepsi)", "Hata sprinti (21-60 hf)", "Duzeltme payi erken", "Duzeltme payi gec", "Teslim", "MVP hf"]))


def hs(tg, n, key):
    return "%d/%d" % (tsum(tg, n, key, 0), tsum(tg, n, key, 1))


# ------------------------------------------------------------- soz karti
def sec_promise():
    rows = []
    for tg, lab in (("R6", "R, saf buyukluk (PROMISEFIRST=0)"), ("R5_pf1", "R, soz once (PROMISEFIRST=1)"), ("R5_size_pf0", "PRD birebir, saf buyukluk"), ("R5_size_pf1", "PRD birebir, soz once")):
        for b, k in SCL:
            n = "PR|%s" % b
            if not have(tg, n):
                continue
            tot = {}
            for m in D(tg, n).values():
                for kk, v in m["prom"].items():
                    tot[kk] = tot.get(kk, 0) + v
            k3 = [l[1] for m in D(tg, n).values() for l in m["leads"] if l[0] == 40 and not l[2]]
            k3p = [l[1] for m in D(tg, n).values() for l in m["leads"] if l[0] == 40 and l[2]]
            due = max(1, tot["due"])
            rows.append([lab, "%d kisi" % k, tot["made"], tot["due"], "%d (%s)" % (tot["late"] + tot["undel"], pc((tot["late"] + tot["undel"]) / due)),
                         f1(tot["delay_sum"] / max(1, tot["delay_n"]), 2), tot["undel"], "%d/%d" % (tot["small_missed"], tot["small_due"]),
                         f1(statistics.mean(k3), 2) if k3 else "-", f1(md(tg, n, "deliv")), pc(mn(tg, n, "linked_q"))])
    sec("soz", table(rows, ["Sira", "Ekip", "Verilen soz", "Vadesi gelen", "Kacan (gec + teslim edilmemis)", "Ortalama gecikme (sprint, teslimlerde)", "Teslim edilmemis", "Kucuk kart (<=25) kacan", "Buyuk kart (40) ort. sure (hf)", "Teslim (puan/hf)", "Bagli soru sprintleri"]))


# ------------------------------------------------------------- testci duzeltir mi
def sec_tester():
    rows = []
    names = ["S3", "S4", "S5", "S6", "S7", "S9b", "S10"] + ["T3_1", "T3_3", "T3_5", "T3_yok", "T4_3", "T5_3"]
    for tg, lab in (("R_tfm", "Testci yalniz Test (kutu yok)"), ("R_tf0", "Testci Gelistirme x0,7, Duzeltme yok (TESTERFIX=0)"), ("R_tf1", "Testci Gelistirme ve Duzeltme x0,7 (tablo, TESTERFIX=1)")):
        for key, ad, fm in (("deliv", "teslim", f1), ("esc100", "kacan/100 puan", lambda x: f1(x, 2)), ("open_med", "acik hata", f1), ("idle_pct", "bosta", pc)):
            vs = [fm(md(tg, n, key)) if have(tg, n) and md(tg, n, key) is not None else "-" for n in names]
            if any(v != "-" for v in vs):
                rows.append([lab, ad] + vs)
    sec("testci", table(rows, ["Kol", "Olcu"] + names))
    g = []
    for tg, lab in (("R_tfm", "Testci yalniz Test"), ("R_tf0", "Testci Gelistirme x0,7, Duzeltme yok"), ("R_tf1", "Testci Gelistirme ve Duzeltme x0,7")):
        cells = [lab]
        ok9 = ok10 = True
        for pre in ("T3", "T4", "T5"):
            if not all(have(tg, pre + x) for x in ("_1", "_5", "_3", "_yok")):
                cells += ["-", "-"]
                continue
            e1, e5 = md(tg, pre + "_1", "esc100"), md(tg, pre + "_5", "esc100")
            f1_, f5_ = md(tg, pre + "_1", "found_sp"), md(tg, pre + "_5", "found_sp")
            ok9 &= (1 - e5 / e1) >= 0.40 and f5_ / f1_ >= 2.0
            d0, d3, e0, e3 = md(tg, pre + "_yok", "deliv"), md(tg, pre + "_3", "deliv"), md(tg, pre + "_yok", "esc100"), md(tg, pre + "_3", "esc100")
            ok10 &= d3 >= d0 and (1 - e3 / e0) >= 0.20
            cells += ["kacan -%s, bulunan x%s" % (pc(1 - e5 / e1), f1(f5_ / f1_)), "teslim %s%s, kacan -%s" % ("+" if d3 >= d0 else "", pc(d3 / d0 - 1), pc(1 - e3 / e0))]
        cells += ["GECTI" if ok9 else "KALDI", "GECTI" if ok10 else "KALDI"]
        g.append(cells)
    sec("testci_kapi", table(g, ["Kol", "6 kisi: 1*->5* testci", "6 kisi: testcisiz->3*", "12 kisi: 1*->5*", "12 kisi: testcisiz->3*", "25 kisi: 1*->5*", "25 kisi: testcisiz->3*", "Kapi 9 testci_yildizi", "Kapi 10 testci_degeri"]))


# ------------------------------------------------------------- derinlik karti tuketimi
def sec_depth():
    rows = []
    for tg in ("R6",):
        for n, lab, wk in [("DEP|%s" % b, "%d kisi" % k, 104) for b, k in SCL] + [("GC|kaynakli", "Buyume 1->10", 130)]:
            if not have(tg, n):
                continue
            mx_, md_, fm_, mxall, over6, nl = [], [], [], 0, 0, 0
            for m in D(tg, n).values():
                ds = m["depth_seq"][:9]
                fin = m["depth_fin"][:9]
                mx_.append(max(ds))
                md_.append(statistics.median(ds))
                fm_.append(max(fin))
                mxall = max(mxall, max(ds))
                over6 += sum(1 for x in ds if x > 6)
                nl += len(ds)
            rows.append([lab, wk, f1(statistics.median(md_)), f1(statistics.median(mx_)), mxall, f1(statistics.median(fm_)), pc(over6 / nl)])
    sec("derinlik", table(rows, ["Ekip", "Hafta", "Hat basina acilan derinlik karti: medyan hat", "en cok kullanilan hat (medyan kosu)", "en cok (tum kosular)", "Hat basina biten: en cok (medyan kosu)", "6 adi asan hat payi"]))


# ------------------------------------------------------------- uc karisimlar
def sec_extreme():
    names = [("S7", "5 testci, kucuk kartlar"), ("S8", "10 gelistirici, Test kutusu yok"), ("S8_hepsi_testkutulu", "10 gelistirici, hepsinde Test kutusu"), ("S9a", "8 testci, yalniz Test"), ("S9b", "8 testci, Yapim ve Test"),
             ("S3_PMsiz", "PM yok (5 kisi)"), ("S4_PMsiz", "PM yok (10 kisi)"), ("S10", "PM yok (30 kisi)"), ("S11", "Testci yok (25 kisi, kutu yok)"), ("S11b", "Testci yok (25 kisi, gelistiricide Test kutusu)"), ("S12", "Tek karta 12 kisi")]
    rows = []
    for n, lab in names:
        row = [lab, n]
        for tg in ("L", "R6"):
            if have(tg, n):
                row += [f1(md(tg, n, "deliv")), pc(md(tg, n, "idle_pct")), f1(md(tg, n, "esc_card"), 2), f1(md(tg, n, "open_med"))]
            else:
                row += ["-"] * 4
        rows.append(row)
    sec("uc", table(rows, ["Karisim", "Kod", "Eski: teslim", "bosta", "kacan/kart", "acik hata", "R: teslim", "bosta", "kacan/kart", "acik hata"]))


# ------------------------------------------------------------- ekleme_dusurmez ayrintisi
def sec_ekleme():
    st = json.load(open("out/dgates_R6.json", encoding="utf-8"))["steps"] if os.path.exists("out/dgates_R5.json") else []
    rows = []
    for g, ad in (("B", "Taban ekibe bir kisi (S2-S6 x 5 ekleme)"), ("C", "Kisi ekleme egrisi 1->50"), ("E", "Kurucu buyumesi (4 tip x 6 sira x 3 alim)"), ("REP", "Bir kisiyi ayni roldeki daha iyisiyle degistirme")):
        xs = [x for x in st if x[2] == g]
        if xs:
            w = min(xs)
            rows.append([ad, len(xs), f1(w[0]), w[1], sum(1 for x in xs if x[0] < -1e-9), sum(1 for x in xs if abs(x[0]) <= 1e-9), f1(statistics.median(x[0] for x in xs))])
    sec("ekleme", table(rows, ["Aile", "Adim", "En kotu (puan/hf)", "En kotu adim", "Eksi adim", "Sifir adim", "Adim medyani"]))
    worst = sorted(st)[:12]
    sec("ekleme_kotu", table([[a[1], a[2], f1(a[0])] for a in worst], ["Adim", "Aile", "Fark (puan/hf)"]))
    # degistirme matrisi
    rows = []
    for b in ["S2", "S3", "S4", "S5", "S6"]:
        row = [b + " (%d kisi)" % dict(SCL)[b], f1(md("R6", b, "deliv")) if have("R6", b) else "-"]
        for r_ in REP_ROLES:
            for m_ in ("+1", "5"):
                n = "REP|%s|%s|%s" % (b, r_, m_)
                row.append(f1(md("R6", n, "deliv") - md("R6", b, "deliv")) if have("R6", n) and have("R6", b) else ("." if n not in SCEN else "-"))
        rows.append(row)
    sec("rep", table(rows, ["Taban", "Taban teslim"] + ["%s %s" % (r_, "+1*" if m_ == "+1" else "5*") for r_ in REP_ROLES for m_ in ("+1", "5")]))


# ------------------------------------------------------------- PM kollari
def sec_pm():
    arms = [("R6", "karar4h: Karar 4 + ufuklu (yalniz hazirliksiz kalacak kart)"), ("R_pm4w", "karar4: Karar 4 haftalik (PRD birebir)"), ("R_pmbest", "best: fayda haftanin en iyi PM'inden"), ("R_pmpreparer", "preparer: fayda kartin hazirlayanindan, kuyruk sirasi")]
    # C36 -> C37 (100 tohum)
    rows = []
    for tg, lab in arms:
        a, b = D(tg, "C36", hi=100), D(tg, "C37", hi=100)
        if not a or not b:
            continue
        sd = sorted(set(a) & set(b))
        da, db = [a[s]["deliv"] for s in sd], [b[s]["deliv"] for s in sd]
        diff = [y - x for x, y in zip(da, db)]
        se = statistics.stdev(diff) / math.sqrt(len(diff)) if len(diff) > 1 else 0
        f20 = [s for s in sd if s <= 20]
        rows.append([lab, len(sd), f1(statistics.median(da)), f1(statistics.median(db)), f1(statistics.median(db) - statistics.median(da)),
                     f1(statistics.median([b[s]["deliv"] for s in f20]) - statistics.median([a[s]["deliv"] for s in f20])),
                     "%s +- %s" % (f1(statistics.mean(diff), 2), f1(se, 2)), "%d/%d" % (sum(1 for d in diff if d < 0), len(diff))])
    for tg, lab in (("L_pmpreparer", "ESKI oynatma + preparer (prototipin ayari: duzeltme karti en az 5, eski derinlik) - PRD'nin -2,5'i"), ("L_pmbest", "ESKI oynatma + best (v3 kurali)")):
        a, b = D(tg, "C36", hi=100), D(tg, "C37", hi=100)
        if a and b:
            sd = sorted(set(a) & set(b))
            da, db = [a[s]["deliv"] for s in sd], [b[s]["deliv"] for s in sd]
            diff = [y - x for x, y in zip(da, db)]
            f20 = [s for s in sd if s <= 20]
            se = statistics.stdev(diff) / math.sqrt(len(diff))
            rows.append([lab, len(sd), f1(statistics.median(da)), f1(statistics.median(db)), f1(statistics.median(db) - statistics.median(da)),
                         f1(statistics.median([b[s]["deliv"] for s in f20]) - statistics.median([a[s]["deliv"] for s in f20])),
                         "%s +- %s" % (f1(statistics.mean(diff), 2), f1(se, 2)), "%d/%d" % (sum(1 for d in diff if d < 0), len(diff))])
    sec("pm37", table(rows, ["Kural", "Tohum", "36. kisi: teslim (medyan)", "37. kisi (PM)", "Fark (medyan, tum tohum)", "Fark (ilk 20 tohum, kapi okumasi)", "Ortalama fark +- SE", "Eksi tohum"]))
    # tum PM adimlari
    names = []
    for i in range(len(PMSTEP) // 2):
        names.append(("C%s" % PMSTEP[2 * i][1:], PMSTEP[2 * i], PMSTEP[2 * i + 1]))
    names += [("S%d" % i, "S%d" % i, "S%d +3* PM" % i) for i in range(2, 7)] + [("1 kisi + PM", "G|orta|pm-gel-tas|0", "G|orta|pm-gel-tas|1")]
    rows = []
    for lab, a, b in names:
        row = [lab if lab.startswith("1") or lab.startswith("S") else "egri %s->%s" % (a[1:], b[1:])]
        for tg, _ in arms:
            row.append(f1(md(tg, b, "deliv") - md(tg, a, "deliv")) if have(tg, a) and have(tg, b) else "-")
        rows.append(row)
    sec("pmadim", table(rows, ["PM adimi (teslim farki, puan/hf, 20 tohum medyani)"] + [a[1].split(":")[0] for a in arms]))
    # PM kapi ozeti
    sec("pmozet", "")


# ------------------------------------------------------------- atama sirasi ve dogrulama
def sec_assign():
    tot = {k: 0 for k in ("rows", "inv", "stale", "wk_rows", "wk_inv", "unfit", "unfit_front")}
    perscale = []
    for n, k in SCL:
        if have("R6", n):
            r = {kk: aud("R6", n, kk) for kk in tot}
            perscale.append([k, r["rows"], r["inv"], r["wk_rows"], r["wk_inv"], r["stale"], r["unfit"], r["unfit_front"]])
    for tg in ("R6",):
        for nm in ("HUY|S3", "HUY|S4", "S3_PM_testkutulu", "S4_PMsiz"):
            if have(tg, nm):
                r = {kk: aud(tg, nm, kk) for kk in tot}
                perscale.append([nm, r["rows"], r["inv"], r["wk_rows"], r["wk_inv"], r["stale"], r["unfit"], r["unfit_front"]])
    sec("atama", table(perscale, ["Ekip (kisi)", "Atama satiri (asama x an)", "Ters (yeni atananlar arasinda)", "Hafta basi tam esleme", "Hafta basi ters", "Surerken kartinda kalan yavas kisi (bilgi)", "Uymayan is verilen", "Onden isi varken verilen"]))
    dchk = json.load(open("out/dcheck.json", encoding="utf-8")) if os.path.exists("out/dcheck.json") else []
    sec("dcheck", table([[x["ad"], x["beklenen"], x["bulunan"], "GECTI" if x["gecti"] else "KALDI"] for x in dchk], ["Mikro test", "Beklenen", "Bulunan", "Sonuc"]))
    ddet = json.load(open("out/ddet.json", encoding="utf-8")) if os.path.exists("out/ddet.json") else []
    sec("ddet", table([[x["senaryo"], x["atama_kaydi"], "evet" if x["ayni"] else "HAYIR", f1(x["deliv"], 2), "%.1e" % x["pred"]] for x in ddet], ["Senaryo (16 hf)", "Atama kaydi (satir)", "Kisi listesi ters ve karisik: ayni atama", "Teslim", "Plan-kapanis farki"]))


for fn in (sec_scale, sec_kay, sec_slice, sec_founder, sec_promise, sec_tester, sec_depth, sec_extreme, sec_ekleme, sec_pm, sec_assign):
    try:
        fn()
    except Exception as e:      # veri henuz tam degilse
        SECT[fn.__name__] = "(tablo uretilemedi: %s)" % repr(e)
with open("out/d0s_tablolar_R6.md", "w", encoding="utf-8") as f:
    for k, v in SECT.items():
        f.write("<!-- %s -->\n%s\n\n" % (k, v))
print("yazildi: out/d0s_tablolar_R6.md", len(SECT), "bolum")
