"""8. adım sayfasının ek verisi: page/extra.json (onay listesi, karar 9 tablosu, ilk geliş haftaları, değiştirici)."""
import os as _os
_HERE = _os.path.dirname(_os.path.dirname(_os.path.abspath(__file__)))
import csv
import io
import json
import re

S = _os.environ.get("OLAY_S", _HERE)
W = _os.environ.get("OLAY_PROJ", _os.path.abspath(_HERE + "/../../.."))
OUT = S + "/page"

data = json.load(open(OUT + "/data.json", encoding="utf-8"))

# strings.csv: anahtar → (tr, en)
raw = open(W + "/localization/strings.csv", encoding="utf-8").read()
rd = csv.reader(io.StringIO(raw))
head = next(rd)
ki, ti, ei = head.index("keys"), head.index("tr"), head.index("en")
strings = {r[ki]: (r[ti], r[ei]) for r in rd if len(r) > max(ki, ti, ei)}

KEYS = [
    ("Olaylar 1", "EFFECT_CHANCE EFFECT_LATER EFFECT_LATER_ONE EFFECT_LATER_RANGE"),
    ("Olaylar 2", "HR_NEWS_BACK_TO_WORK EFFECT_LEAVE_SHIFT EFFECT_LEAVE_TOGETHER EFFECT_SICK_LEAVE EFFECT_PROMOTION "
                  "FIN_ONETIME_EQUIPMENT FIN_ONETIME_GIFT FIN_ONETIME_AWARD"),
    ("Olaylar 3", "EFFECT_ACCOUNT_NOTICE EFFECT_ACCOUNT_TO_FOUNDER EFFECT_PROSPECT_LOST EFFECT_OFFER_DISCOUNT "
                  "EFFECT_OFFER_PROMISE EFFECT_PITCH_FOCUS EFFECT_TRUST_NEW_ACCOUNTS SALES_EXIT_RUDE_CALL_SUBJECT "
                  "SALES_EXIT_RUDE_CALL_BODY SALES_LOG_NOTICE_ENDED SALES_LOG_DISCOUNT_ENDED SALES_TIMED_DISCOUNT "
                  "SALES_OFFER_DISCOUNT SALES_OFFER_PROMISE SALES_MOD_PITCH_FOCUS SALES_MEMORY_EVENT"),
    ("Olaylar 4", "PRODUCT_SERVER_LOCK_REASON EFFECT_SERVER_PRICE EFFECT_SERVER_PRICE_TIERS EFFECT_SERVER_LOCK_SEATS "
                  "EFFECT_SERVER_LOCK_USERS"),
    ("Olaylar 5", "EFFECT_PIN EFFECT_QUEUE_CARD EFFECT_AFTER_TEST"),
    ("Olaylar 6", "EV_LOCK_REQUEST_CLOSED MAIL_SENDER_SERVER_PROVIDER MAIL_SENDER_IT_DIRECTOR"),
]
anahtarlar = []
for commit, ks in KEYS:
    for k in ks.split():
        tr, en = strings.get(k, ("", ""))
        anahtarlar.append({"commit": commit, "anahtar": k, "tr": tr, "en": en, "bulundu": k in strings})

# kart metinleri: revize3 tr_en_onay_bekliyor
onay_kartlar = [{"no": r["no"], "kart": r["kart"], "durum": r["durum"]}
                for r in data["kartlar"] if r["onay"] == "bekliyor" and r["durum"] == "bagli"]

# karar 9 tablosu: PLAN.md §7
plan = open(S + "/plan/PLAN.md", encoding="utf-8").read()
sec = plan.split("## 7. Karar 9")[1].split("\n## ")[0]
karar9 = []
for ln in sec.splitlines():
    if ln.startswith("| #"):
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        karar9.append({"kart": cells[0], "kosul": cells[1], "secilen": cells[2], "reddedilen": cells[3]})

# ilk geliş haftaları: c6b/plaus_table.md
pt = open(S + "/groups/c6b/plaus_table.md", encoding="utf-8").read()
ilk = []
for m in re.finditer(r"^(\S+) (full_run(?:_staff25|_b2c)?): n=(\d+)/(\d+)(?: min=(\d+) median=([\d.]+) max=(\d+))?", pt, re.M):
    ilk.append({"kart": m.group(1), "preset": m.group(2), "n": int(m.group(3)), "kosu": int(m.group(4)),
                "min": m.group(5), "medyan": m.group(6), "max": m.group(7)})

degistirici = open(S + "/step2/degistirici.md", encoding="utf-8").read()
# 2. adımda #19'un kâğıdı PM sütununa yazılmıştı; oyundaki id test sütunudur (plan Ç15)
degistirici = degistirici.replace("product.sprint_pm_rival_batch", "product.sprint_test_rival_batch")

json.dump({"anahtarlar": anahtarlar, "onay_kartlar": onay_kartlar, "karar9": karar9, "ilk_gelis": ilk,
           "degistirici_md": degistirici},
          open(OUT + "/extra.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("anahtar", len(anahtarlar), "eksik", [a["anahtar"] for a in anahtarlar if not a["bulundu"]])
print("onay kart", len(onay_kartlar), "karar9", len(karar9), "ilk", len(ilk))
