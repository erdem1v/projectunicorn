# D0s elle dogrulama ve gate mikro-testleri (PRD Karar 2, 4, 6, 8, 11). python -I dsim3.py exec dcheck.py   -> out/dcheck.json
# Her satir: (ad, beklenen, bulunan, gecti mi). Bu dosya sim'in kurallarini tek tek, kucuk ornekle sinar; olcum degildir.
import json, itertools, random
RES = []


def chk(ad, beklenen, bulunan, ok):
    RES.append({"ad": ad, "beklenen": beklenen, "bulunan": bulunan, "gecti": bool(ok)})


def tekil(people, cards, seed=1, weeks=2, front=(False, False)):
    """Kartlari tek hucrede ve sprint boyunca (cekmesiz, onden issiz) oynat; atama kaydini (alog) doner."""
    Sim._uniq(people)
    team = Team(people, weeks)
    alog = []
    for k in range(weeks):
        st = WSt(team.n, len(cards))
        week2(team, cards, st, seed, k, weeks, k, front=front, alog=alog)
    return team, alog


def K(prof, tier, line=0, pos=0):
    c = Card("feature", line, tier, prof)
    c.pos = pos
    c.fix_start()
    return c


# 1. Y x U tabani (PRD Karar 2): PM 1,0 yildiz Test kutusu: 10 x max(0,3; Y(qa)x0,4); qa=2 -> Y=0,64 x 0,4 = 0,256 -> 0,3 -> 3,0
pm = Person("PM", "pm", {"product": 6, "design": 5, "qa": 2, "eng": 0}, ("build", "test"))
chk("Uymayan is tabani (PM, Test kutusu, qa 2)", "3,0 puan/hf (0,256 -> 0,3)", "%.2f" % pm.rate("qa"), abs(pm.rate("qa") - 3.0) < 1e-9)
pm0 = Person("PM0", "pm", {"product": 6, "design": 0, "qa": 8, "eng": 0}, ("build", "test"))
chk("Uymayan is, yuksek Test puani (qa 8)", "10 x Y(8) x 0,4 = 6,16 (taban islemez)", "%.2f" % pm0.rate("qa"), abs(pm0.rate("qa") - 10 * Y(8) * 0.4) < 1e-9)
# 2. huy
d0 = Person("d", "dev", {"eng": 6, "qa": 5, "design": 0, "product": 0})
dg = Person("g", "dev", {"eng": 6, "qa": 5, "design": 0, "product": 0}, gozu=True)
dt = Person("t", "dev", {"eng": 6, "qa": 5, "design": 0, "product": 0}, titiz=True)
chk("Huy: GOZU YUKSEKTE x1,15, TITIZ x0,85", "11,6 / 13,34 / 9,86 (Y(6) = 1,16)", "%.2f / %.2f / %.2f" % (d0.rate("eng"), dg.rate("eng"), dt.rate("eng")),
    abs(dg.rate("eng") / d0.rate("eng") - 1.15) < 1e-9 and abs(dt.rate("eng") / d0.rate("eng") - 0.85) < 1e-9)
# 3. duzeltme karti 2 puan/hata, alt sinir yok
chk("Duzeltme karti", "1 hata 2 - 3 hata 6 - 5 hata 10 - 12 hata 24", " - ".join("%d hata %g" % (b, Card("fix", 0, bugs=b).size) for b in (1, 3, 5, 12)),
    [Card("fix", 0, bugs=b).size for b in (1, 3, 5, 12)] == [2, 6, 10, 24])
# 4. Karar 4: uc kart (gelistirme ihtiyaci 26, 16, 10; kadro tavani 4, 2, 2) ve altı gelistirici (5*, 5*, 3*, 3*, 1*, 1*); plan sirasi buyuklugu ele vermez
def dev_set():
    Card._n = 0
    ds = [Person("dev_5a", "dev", {"eng": 10, "qa": 9, "design": 0, "product": 0}), Person("dev_5b", "dev", {"eng": 10, "qa": 9, "design": 0, "product": 0}),
          Person("dev_3a", "dev", {"eng": 6, "qa": 5, "design": 0, "product": 0}), Person("dev_3b", "dev", {"eng": 6, "qa": 5, "design": 0, "product": 0}),
          Person("dev_1a", "dev", {"eng": 2, "qa": 1, "design": 0, "product": 0}), Person("dev_1b", "dev", {"eng": 2, "qa": 1, "design": 0, "product": 0})]
    cs = [K("logic", 1, 6, 0), K("logic", 2, 5, 1), K("logic", 3, 4, 2)]      # plan sirasi: kucuk, orta, buyuk
    for c in cs:
        c.prog[0] = c.need[0]
    return ds, cs


def kim(mode):
    global KEYMODE
    old_ = KEYMODE
    KEYMODE = mode
    try:
        ds, cs = dev_set()
        Sim._uniq(ds)
        tm = Team(ds, 2)
        st = WSt(tm.n, 3)
        assign_k4(tm, cs, st, (False, False), None, None)
        return {cs[ci].need[1]: sorted(tm.ids[pi][4:] for pi in crew) for ci, crew in st.crews.items()}
    finally:
        KEYMODE = old_


g_size, g_plan = kim("size"), kim("plan")
chk("Karar 4 (PRD birebir, KEYMODE=size): 5*,5*,3*,3*,1*,1* gelistirici; kartlar 26, 16, 10", "26'ya en hizli dort (5a 5b 3a 3b), 16'ya kalan iki (1a 1b), 10'a kimse",
    str(g_size), g_size.get(26) == ["3a", "3b", "5a", "5b"] and g_size.get(16) == ["1a", "1b"] and 10 not in g_size)
chk("Karar 4 (KEYMODE=plan): ayni girdi, kadroyu plan sirasi belirler", "10'a, 16'ya, 26'ya ikiser kisi; en hizli iki 26'da, sonraki iki 16'da, son iki 10'da",
    str(g_plan), g_plan.get(26) == ["5a", "5b"] and g_plan.get(16) == ["3a", "3b"] and g_plan.get(10) == ["1a", "1b"])
# 5. Ayni girdi ayni atama: kisi listesi ters ve karisik; iki kip
runs = []
for mode in ("size", "plan"):
    KEYMODE = mode
    ds0, _ = dev_set()
    Sim._uniq(ds0)
    for perm in (ds0, list(reversed(ds0)), random.Random(3).sample(ds0, 6)):
        _, cc = dev_set()
        tm = Team(list(perm), 2)
        s_ = WSt(tm.n, 3)
        assign_k4(tm, cc, s_, (False, False), None, None)
        runs.append(sorted((tm.ids[pi], cc[ci].id) for ci, crew in s_.crews.items() for pi in crew))
KEYMODE = _c("KEYMODE", "size")
chk("Ayni girdi ayni atama (kisi listesi ters ve karisik, iki kip)", "uc listede de ayni (kisi, kart) ciftleri", "size: %s, plan: %s" % (runs[0] == runs[1] == runs[2], runs[3] == runs[4] == runs[5]),
    runs[0] == runs[1] == runs[2] and runs[3] == runs[4] == runs[5])
# 6. uymayan is yalniz bosta kalacaksa: PM + Test kutusu; onden is (hazirlik) varsa Test'e girmez, yoksa girer
pmx = Person("PMx", "pm", {"product": 6, "design": 5, "qa": 2, "eng": 0}, ("build", "test"))
Sim._uniq([pmx])
Card._n = 0
ct = K("risk", 1, 8, 0)
ct.prog[0], ct.prog[1] = ct.need[0], ct.need[1]       # asama Test
tm = Team([pmx], 2)
s1 = WSt(1, 1)
assign_k4(tm, [ct], s1, (True, False), None, None)     # PM'in hazirlayacagi kart var
s2 = WSt(1, 1)
assign_k4(tm, [ct], s2, (False, False), None, None)    # hazirlik yok
chk("Uymayan is koşulu (PM, Test kutusu)", "hazirlik varken Test'e girmez; hazirlik yokken girer", "hazirlik var: %s; yok: %s" % (bool(s1.crews.get(0)), bool(s2.crews.get(0))),
    not s1.crews.get(0) and bool(s2.crews.get(0)))
# 7. kendi karti x0,6 (kurucu dahil) ve baskasinin karti
rows = []
ok7 = True
for lab, own, who, qa in (("kurucu kendi karti, qa 0", True, "founder", 0), ("gelistirici kendi karti, qa 6", True, "dev", 6), ("testci basqasinin karti, qa 6", False, "test", 6)):
    Card._n = 0
    c = K("risk", 2, 0, 0)
    if who == "founder":
        pr = founder()
    elif who == "dev":
        pr = Person("G", "dev", {"eng": 5, "qa": qa, "design": 0, "product": 0}, ("build", "test"))
    else:
        pr = Person("T", "test", {"qa": qa, "eng": 0, "design": 0, "product": 0})
    ppl = [pr] if own else [Person("G", "dev", {"eng": 5, "qa": 0, "design": 0, "product": 0}), pr]
    tm = Team(ppl, 2)
    if own:
        c.log = {0: [0, c.need[1], c.t0, 0]}
    else:
        c.log = {0: [0, c.need[1], 0, 0], 1: [0, 0, c.t0, 0]}
    on_test_done(c, tm, 1)
    exp = min(1.0, C_REF * math.sqrt(Y(pr.sk.get("qa", 0))) * (SELF_TEST if own else 1.0))
    ok7 &= abs(c.C - exp) < 1e-12
    rows.append("%s C=%.4f (beklenen %.4f)" % (lab, c.C, exp))
chk("Kendi karti x0,6 (kurucu dahil)", "C = 0,57 x sqrt(Y(qa)) x 0,6 (kendi) / x 1,0 (baskasi)", "; ".join(rows), ok7)
# 8. PM esleme (Karar 4/8): 5*, 3*, 1* PM ve uc kart (40, 25, 15): iyi PM buyuk kartta, sonra kucuk; ayni kart tek PM; yeni PM mevcut karti almaz
Card._n = 0
pms = [Person("pm_5", "pm", {"product": 10, "design": 9, "qa": 2, "eng": 0}), Person("pm_1", "pm", {"product": 2, "design": 1, "qa": 2, "eng": 0})]
Sim._uniq(pms)
tm = Team(pms, 2)
cs = [K("logic", 1, 0, 0), K("logic", 3, 1, 1), K("logic", 2, 2, 2)]
for c in cs:
    c.fixed = False
    c.need = list(c.base_need)
left = [1.0, 1.0]
prep_k4(tm, cs, left)
own = {c.size: c.preparer for c in cs}
chk("PM esleme: 5* ve 1* PM; kartlar 40, 25, 15", "pm_5 buyuk karttan baslar (40, sonra 25); pm_1 kalani alir; her kartin tek hazirlayani",
    str(own), own[40] == "pm_5" and own[25] == "pm_5" and own[15] in ("pm_5", "pm_1"))
# yeni (daha dusuk) PM mevcut hazirlayani olan karti almaz
pms2 = pms + [Person("pm_3", "pm", {"product": 6, "design": 5, "qa": 2, "eng": 0})]
Sim._uniq(pms2)
tm2 = Team(pms2, 2)
before = {c.id: c.preparer for c in cs}
cs2 = [K("logic", 3, 3, 3)]
cs2[0].fixed = False
cs2[0].need = list(cs2[0].base_need)
left2 = [0.0, 0.0, 1.0]       # yalniz yeni PM bos
prep_k4(tm2, cs + cs2, left2)
chk("Yeni PM daha once baslanmis karti almaz, hazirlanmamisi alir", "eski kartlarin hazirlayani degismez; yeni kart pm_3'te", "%s; yeni=%s" % ({c.id: c.preparer for c in cs} == before, cs2[0].preparer),
    {c.id: c.preparer for c in cs} == before and cs2[0].preparer == "pm_3")
# 9. cekme: iki kisi, tek kart biter, siradaki kart ayni hafta cekilir; tahmin ayni
Card._n = 0
class FakeSim:      # Puller yalniz sim.seed ister
    seed = 1
pp = [Person("dv", "dev", {"eng": 6, "qa": 5, "design": 0, "product": 0}), Person("ds", "des", {"design": 6, "product": 5, "eng": 0, "qa": 0}),
      Person("tt", "test", {"qa": 6, "eng": 5, "design": 0, "product": 0})]
Sim._uniq(pp)
tm = Team(pp, 2)
cell = Cell(pp, 2)
c1 = K("ui", 1, 0, 0)
nxt = [K("ui", 1, 1, 1), K("ui", 1, 2, 2)]
pl = Puller(FakeSim, cell, nxt, None)
cards = [c1]
pulled = []
for k in range(2):
    st = WSt(tm.n, len(cards))
    week2(tm, cards, st, 1, k, 2, k, puller=pl)
chk("Cekme: ekip bosta kalinca siradaki kart sprinte girer", "ekip bosta kalinca en az bir kart ayni sprintte cekilir", "%d kart sprintte; bitenler: %s" % (len(cards), [c.phase() == 4 for c in cards]), len(cards) >= 2)
json.dump(RES, open("out/dcheck.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
for r in RES:
    print("%-5s %s | beklenen: %s | bulunan: %s" % ("GECTI" if r["gecti"] else "KALDI", r["ad"], r["beklenen"], r["bulunan"]))
