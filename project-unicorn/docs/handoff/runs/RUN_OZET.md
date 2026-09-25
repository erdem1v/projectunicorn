# Ölçüm koşuları özeti (cloud, 2026-09-25)

**Koşu:** `--run-log=full_run:700:sim:<seed>`, tohum 1–5, commit `de6ab7f` (K1–K12 uygulanmış; `fc58e7c` öncesi). Ham loglar yaklaşık 170K satır; repoya alınmadı. Lokalde yeniden üretilebilir.

**Genel bulgular:**
- Kapı 5 tohumun 5'inde açıldı.
- Hiçbir koşuda Series A teklifi alınmadı. `run_probe.gd` içinde VC görüşmesi oynayan bir politika bulunamadı (`VCPitchSystem` / `request_meeting` çağrısı yok), yani bot görüşme oynamıyor. Masa ve teklif yolu yalnız smoke vakalarıyla doğrulandı.
- Script hatası yok.

## Kapının açıldığı gündeki durum (`PROBE STATE`)

| Tohum | Kapı günü | `gate_series_a` | Çalışan | Günlük burn | Müşteri | Marka | Kârlı ay serisi | Nakit | MRR |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 305 | 306 | 7 | 709 | 156 | 0 | 10 | 355250 | 120736 |
| 2 | 357 | 358 | 12 | 1078 | 176 | 21 | 11 | 391918 | 120423 |
| 3 | 287 | 288 | 10 | 1008 | 162 | 19 | 8 | 333754 | 120443 |
| 4 | 442 | 443 | 13 | 1226 | 186 | 13 | 10 | 330665 | 122190 |
| 5 | 261 | 262 | 12 | 1079 | 172 | 43 | 7 | 261841 | 120705 |

**Ay kapanışları:** kapı civarında aylık gider yaklaşık 28–37K, gelir yaklaşık 117–145K, marj yaklaşık %70–76. Bu sorunun (B2) araştırması HANDOFF §C'de.

## Tohum 1

**Frank kartları (23):** 9:first_ship, 11:gate_traction, 19:version_ship, 20:frank_cheque, 22:hire_nudge, 25:version_ship, 29:version_ship, 33:version_ship, 38:version_ship, 43:version_ship, 49:seed_door, 53:version_ship, 59:version_ship, 111:version_ship, 118:version_ship, 162:frank_approach_half, 227:frank_approach_near, 228:version_ship, 267:version_ship, 273:version_ship, 280:frank_approach_close, 305:frank_door_open, 306:gate_series_a

**Ay kapanışları (`PROBE MONTH`):**
```
day=32 n=1 mrr_close=11174 income=3681 expense=3532 net=149 red=0 growth_pct=n/a streak=0 profit_streak=1
day=60 n=2 mrr_close=28389 income=18201 expense=12627 net=5574 red=0 growth_pct=154.1 streak=1 profit_streak=2
day=91 n=3 mrr_close=27251 income=30030 expense=21293 net=8737 red=0 growth_pct=-4.0 streak=0 profit_streak=3
day=121 n=4 mrr_close=30599 income=27687 expense=24513 net=3174 red=0 growth_pct=12.3 streak=1 profit_streak=4
day=152 n=5 mrr_close=53544 income=45284 expense=25779 net=19505 red=0 growth_pct=75.0 streak=2 profit_streak=5
day=182 n=6 mrr_close=66670 income=62229 expense=30651 net=31578 red=0 growth_pct=24.5 streak=3 profit_streak=6
day=213 n=7 mrr_close=82950 income=78301 expense=33714 net=44587 red=0 growth_pct=24.4 streak=4 profit_streak=7
day=244 n=8 mrr_close=94991 income=93117 expense=37262 net=55855 red=0 growth_pct=14.5 streak=5 profit_streak=8
day=274 n=9 mrr_close=106243 income=100698 expense=37819 net=62879 red=0 growth_pct=11.8 streak=0 profit_streak=9
day=305 n=10 mrr_close=120436 income=116659 expense=28447 net=88212 red=0 growth_pct=13.4 streak=1 profit_streak=10
day=335 n=11 mrr_close=135394 income=128036 expense=27062 net=100974 red=0 growth_pct=12.4 streak=2 profit_streak=11
day=366 n=12 mrr_close=166044 income=154150 expense=37107 net=117043 red=0 growth_pct=22.6 streak=3 profit_streak=12
day=397 n=12 mrr_close=186762 income=179634 expense=37274 net=142360 red=0 growth_pct=12.5 streak=4 profit_streak=12
day=425 n=12 mrr_close=208428 income=185308 expense=34661 net=150647 red=0 growth_pct=11.6 streak=0 profit_streak=12
day=456 n=12 mrr_close=239464 income=231202 expense=40189 net=191013 red=0 growth_pct=14.9 streak=1 profit_streak=12
day=486 n=12 mrr_close=263346 income=251596 expense=41300 net=210296 red=0 growth_pct=10.0 streak=0 profit_streak=12
day=517 n=12 mrr_close=285935 income=285251 expense=42348 net=242903 red=0 growth_pct=8.6 streak=0 profit_streak=12
day=547 n=12 mrr_close=295589 income=291503 expense=35519 net=255984 red=0 growth_pct=3.4 streak=0 profit_streak=12
day=578 n=12 mrr_close=313984 income=315295 expense=40630 net=274665 red=0 growth_pct=6.2 streak=0 profit_streak=12
day=609 n=12 mrr_close=354179 income=345021 expense=43515 net=301506 red=0 growth_pct=12.8 streak=1 profit_streak=12
day=639 n=12 mrr_close=382760 income=367658 expense=42671 net=324987 red=0 growth_pct=8.1 streak=0 profit_streak=12
day=670 n=12 mrr_close=410608 income=408968 expense=45209 net=363759 red=0 growth_pct=7.3 streak=0 profit_streak=12
day=700 n=12 mrr_close=431584 income=423191 expense=44925 net=378266 red=0 growth_pct=5.1 streak=0 profit_streak=12
```

## Tohum 2

**Frank kartları (24):** 9:first_ship, 11:gate_traction, 18:frank_cheque, 19:version_ship, 20:hire_nudge, 25:version_ship, 29:version_ship, 33:version_ship, 41:version_ship, 45:seed_door, 51:version_ship, 58:version_ship, 65:version_ship, 102:version_ship, 119:version_ship, 203:frank_approach_half, 227:version_ship, 247:version_ship, 252:version_ship, 272:version_ship, 294:frank_approach_near, 326:frank_approach_close, 357:frank_door_open, 358:gate_series_a

**Ay kapanışları (`PROBE MONTH`):**
```
day=32 n=1 mrr_close=12584 income=4066 expense=3584 net=482 red=0 growth_pct=n/a streak=0 profit_streak=1
day=60 n=2 mrr_close=25742 income=19250 expense=12742 net=6508 red=0 growth_pct=104.6 streak=1 profit_streak=2
day=91 n=3 mrr_close=29323 income=32037 expense=21274 net=10763 red=0 growth_pct=13.9 streak=2 profit_streak=3
day=121 n=4 mrr_close=30995 income=29167 expense=24520 net=4647 red=0 growth_pct=5.7 streak=0 profit_streak=4
day=152 n=5 mrr_close=42414 income=39712 expense=23756 net=15956 red=0 growth_pct=36.8 streak=1 profit_streak=5
day=182 n=6 mrr_close=49917 income=45436 expense=23293 net=22143 red=0 growth_pct=17.7 streak=2 profit_streak=6
day=213 n=7 mrr_close=67404 income=60999 expense=28269 net=32730 red=0 growth_pct=35.0 streak=3 profit_streak=7
day=244 n=8 mrr_close=73215 income=72172 expense=33524 net=38648 red=0 growth_pct=8.6 streak=0 profit_streak=8
day=274 n=9 mrr_close=79822 income=77068 expense=34638 net=42430 red=0 growth_pct=9.0 streak=0 profit_streak=9
day=305 n=10 mrr_close=98917 income=92654 expense=35587 net=57067 red=0 growth_pct=23.9 streak=1 profit_streak=10
day=335 n=11 mrr_close=109088 income=104856 expense=36488 net=68368 red=0 growth_pct=10.3 streak=0 profit_streak=11
day=366 n=12 mrr_close=125741 income=119846 expense=35877 net=83969 red=0 growth_pct=15.3 streak=1 profit_streak=12
day=397 n=12 mrr_close=139736 income=139204 expense=36054 net=103150 red=0 growth_pct=11.1 streak=0 profit_streak=12
day=425 n=12 mrr_close=165688 income=141604 expense=32646 net=108958 red=0 growth_pct=18.6 streak=1 profit_streak=12
day=456 n=12 mrr_close=167246 income=169897 expense=36789 net=133108 red=0 growth_pct=0.9 streak=0 profit_streak=12
day=486 n=12 mrr_close=183263 income=171718 expense=36369 net=135349 red=0 growth_pct=9.6 streak=0 profit_streak=12
day=517 n=12 mrr_close=220111 income=209402 expense=35186 net=174216 red=0 growth_pct=20.1 streak=1 profit_streak=12
day=547 n=12 mrr_close=232275 income=221696 expense=35669 net=186027 red=0 growth_pct=5.5 streak=0 profit_streak=12
day=578 n=12 mrr_close=238922 income=246228 expense=40691 net=205537 red=0 growth_pct=2.9 streak=0 profit_streak=12
day=609 n=12 mrr_close=273187 income=264294 expense=40843 net=223451 red=0 growth_pct=14.3 streak=1 profit_streak=12
day=639 n=12 mrr_close=303132 income=287874 expense=41132 net=246742 red=0 growth_pct=11.0 streak=0 profit_streak=12
day=670 n=12 mrr_close=301764 income=302651 expense=40287 net=262364 red=0 growth_pct=-0.5 streak=0 profit_streak=12
day=700 n=12 mrr_close=316956 income=309868 expense=40010 net=269858 red=0 growth_pct=5.0 streak=0 profit_streak=12
```

## Tohum 3

**Frank kartları (25):** 9:first_ship, 14:gate_traction, 19:frank_cheque, 21:hire_nudge, 22:version_ship, 27:version_ship, 31:version_ship, 35:version_ship, 47:version_ship, 48:seed_door, 57:version_ship, 64:version_ship, 69:version_ship, 100:version_ship, 116:version_ship, 161:frank_approach_half, 196:version_ship, 216:version_ship, 221:version_ship, 231:frank_approach_near, 246:version_ship, 266:frank_approach_close, 271:version_ship, 287:frank_door_open, 288:gate_series_a

**Ay kapanışları (`PROBE MONTH`):**
```
day=32 n=1 mrr_close=9204 income=2699 expense=3600 net=-901 red=0 growth_pct=n/a streak=0 profit_streak=0
day=60 n=2 mrr_close=28303 income=19372 expense=12375 net=6997 red=0 growth_pct=207.5 streak=1 profit_streak=1
day=91 n=3 mrr_close=35680 income=38319 expense=22631 net=15688 red=0 growth_pct=26.1 streak=2 profit_streak=2
day=121 n=4 mrr_close=42427 income=36914 expense=22630 net=14284 red=0 growth_pct=18.9 streak=3 profit_streak=3
day=152 n=5 mrr_close=57910 income=54695 expense=25565 net=29130 red=0 growth_pct=36.5 streak=4 profit_streak=4
day=182 n=6 mrr_close=63468 income=59638 expense=29334 net=30304 red=0 growth_pct=9.6 streak=0 profit_streak=5
day=213 n=7 mrr_close=84661 income=78173 expense=32948 net=45225 red=0 growth_pct=33.4 streak=1 profit_streak=6
day=244 n=8 mrr_close=93731 income=92497 expense=36916 net=55581 red=0 growth_pct=10.7 streak=0 profit_streak=7
day=274 n=9 mrr_close=110814 income=103035 expense=35127 net=67908 red=0 growth_pct=18.2 streak=1 profit_streak=8
day=305 n=10 mrr_close=132510 income=127389 expense=34387 net=93002 red=0 growth_pct=19.6 streak=2 profit_streak=9
day=335 n=11 mrr_close=163264 income=148596 expense=31095 net=117501 red=0 growth_pct=23.2 streak=3 profit_streak=10
day=366 n=12 mrr_close=193417 income=185231 expense=39558 net=145673 red=0 growth_pct=18.5 streak=4 profit_streak=11
day=397 n=12 mrr_close=219649 income=212912 expense=39572 net=173340 red=0 growth_pct=13.6 streak=5 profit_streak=12
day=425 n=12 mrr_close=244685 income=215988 expense=36670 net=179318 red=0 growth_pct=11.4 streak=0 profit_streak=12
day=456 n=12 mrr_close=266132 income=263732 expense=42442 net=221290 red=0 growth_pct=8.8 streak=0 profit_streak=12
day=486 n=12 mrr_close=285824 income=276910 expense=41213 net=235697 red=0 growth_pct=7.4 streak=0 profit_streak=12
day=517 n=12 mrr_close=308218 income=309386 expense=36710 net=272676 red=0 growth_pct=7.8 streak=0 profit_streak=12
day=547 n=12 mrr_close=334326 income=322344 expense=41266 net=281078 red=0 growth_pct=8.5 streak=0 profit_streak=12
day=578 n=12 mrr_close=359471 income=359070 expense=43071 net=315999 red=0 growth_pct=7.5 streak=0 profit_streak=12
day=609 n=12 mrr_close=389630 income=388048 expense=43521 net=344527 red=0 growth_pct=8.4 streak=0 profit_streak=12
day=639 n=12 mrr_close=409400 income=398333 expense=43943 net=354390 red=0 growth_pct=5.1 streak=0 profit_streak=12
day=670 n=12 mrr_close=438654 income=438438 expense=45372 net=393066 red=0 growth_pct=7.1 streak=0 profit_streak=12
day=700 n=12 mrr_close=470328 income=453282 expense=43167 net=410115 red=0 growth_pct=7.2 streak=0 profit_streak=12
```

## Tohum 4

**Frank kartları (22):** 9:first_ship, 11:gate_traction, 19:version_ship, 26:frank_cheque, 27:version_ship, 28:hire_nudge, 33:version_ship, 37:version_ship, 42:version_ship, 56:seed_door, 64:version_ship, 119:version_ship, 179:version_ship, 245:version_ship, 265:version_ship, 289:version_ship, 309:version_ship, 322:frank_approach_half, 397:frank_approach_near, 423:frank_approach_close, 442:frank_door_open, 443:gate_series_a

**Ay kapanışları (`PROBE MONTH`):**
```
day=32 n=1 mrr_close=8754 income=1854 expense=1622 net=232 red=0 growth_pct=n/a streak=0 profit_streak=1
day=60 n=2 mrr_close=20458 income=13749 expense=10860 net=2889 red=0 growth_pct=133.7 streak=1 profit_streak=2
day=91 n=3 mrr_close=21428 income=21648 expense=19377 net=2271 red=0 growth_pct=4.7 streak=0 profit_streak=3
day=121 n=4 mrr_close=15432 income=15745 expense=18263 net=-2518 red=0 growth_pct=-28.0 streak=0 profit_streak=0
day=152 n=5 mrr_close=32077 income=24410 expense=19975 net=4435 red=0 growth_pct=107.9 streak=1 profit_streak=1
day=182 n=6 mrr_close=23309 income=27960 expense=24627 net=3333 red=0 growth_pct=-27.3 streak=0 profit_streak=2
day=213 n=7 mrr_close=33004 income=29630 expense=20523 net=9107 red=0 growth_pct=41.6 streak=1 profit_streak=3
day=244 n=8 mrr_close=38527 income=37801 expense=25196 net=12605 red=0 growth_pct=16.7 streak=2 profit_streak=4
day=274 n=9 mrr_close=44629 income=42218 expense=23498 net=18720 red=0 growth_pct=15.8 streak=3 profit_streak=5
day=305 n=10 mrr_close=53667 income=50162 expense=29326 net=20836 red=0 growth_pct=20.3 streak=4 profit_streak=6
day=335 n=11 mrr_close=65400 income=59483 expense=27840 net=31643 red=0 growth_pct=21.9 streak=5 profit_streak=7
day=366 n=12 mrr_close=76797 income=72378 expense=34735 net=37643 red=0 growth_pct=17.4 streak=6 profit_streak=8
day=397 n=12 mrr_close=90467 income=87105 expense=36204 net=50901 red=0 growth_pct=17.8 streak=7 profit_streak=9
day=425 n=12 mrr_close=108582 income=93252 expense=33504 net=59748 red=0 growth_pct=20.0 streak=8 profit_streak=10
day=456 n=12 mrr_close=124388 income=122196 expense=37945 net=84251 red=0 growth_pct=14.6 streak=9 profit_streak=11
day=486 n=12 mrr_close=151429 income=138715 expense=37504 net=101211 red=0 growth_pct=21.7 streak=10 profit_streak=12
day=517 n=12 mrr_close=152930 income=152491 expense=40567 net=111924 red=0 growth_pct=1.0 streak=0 profit_streak=12
day=547 n=12 mrr_close=167324 income=160142 expense=29033 net=131109 red=0 growth_pct=9.4 streak=0 profit_streak=12
day=578 n=12 mrr_close=165607 income=178045 expense=35201 net=142844 red=0 growth_pct=-1.0 streak=0 profit_streak=12
day=609 n=12 mrr_close=188364 income=181677 expense=39836 net=141841 red=0 growth_pct=13.7 streak=1 profit_streak=12
day=639 n=12 mrr_close=221297 income=204808 expense=38059 net=166749 red=0 growth_pct=17.5 streak=2 profit_streak=12
day=670 n=12 mrr_close=228248 income=227502 expense=40948 net=186554 red=0 growth_pct=3.1 streak=0 profit_streak=12
day=700 n=12 mrr_close=233806 income=236992 expense=40053 net=196939 red=0 growth_pct=2.4 streak=0 profit_streak=12
```

## Tohum 5

**Frank kartları (25):** 9:first_ship, 16:gate_traction, 24:frank_cheque, 24:version_ship, 26:hire_nudge, 29:version_ship, 33:version_ship, 37:version_ship, 42:version_ship, 52:version_ship, 61:seed_door, 62:version_ship, 69:version_ship, 118:version_ship, 132:version_ship, 148:version_ship, 157:frank_approach_half, 168:version_ship, 224:frank_approach_near, 228:version_ship, 247:frank_approach_close, 248:version_ship, 261:frank_door_open, 262:gate_series_a, 263:version_ship

**Ay kapanışları (`PROBE MONTH`):**
```
day=32 n=1 mrr_close=5184 income=1346 expense=2950 net=-1604 red=0 growth_pct=n/a streak=0 profit_streak=0
day=60 n=2 mrr_close=19107 income=12190 expense=9683 net=2507 red=0 growth_pct=268.6 streak=1 profit_streak=1
day=91 n=3 mrr_close=25099 income=28577 expense=19998 net=8579 red=0 growth_pct=31.4 streak=2 profit_streak=2
day=121 n=4 mrr_close=34706 income=28278 expense=21660 net=6618 red=0 growth_pct=38.3 streak=3 profit_streak=3
day=152 n=5 mrr_close=54531 income=44669 expense=23672 net=20997 red=0 growth_pct=57.1 streak=4 profit_streak=4
day=182 n=6 mrr_close=70787 income=64972 expense=30280 net=34692 red=0 growth_pct=29.8 streak=5 profit_streak=5
day=213 n=7 mrr_close=86535 income=81487 expense=32855 net=48632 red=0 growth_pct=22.2 streak=6 profit_streak=6
day=244 n=8 mrr_close=104889 income=96689 expense=34978 net=61711 red=0 growth_pct=21.2 streak=7 profit_streak=7
day=274 n=9 mrr_close=130413 income=119769 expense=35554 net=84215 red=0 growth_pct=24.3 streak=8 profit_streak=8
day=305 n=10 mrr_close=145422 income=144417 expense=35364 net=109053 red=0 growth_pct=11.5 streak=0 profit_streak=9
day=335 n=11 mrr_close=161666 income=152874 expense=35144 net=117730 red=0 growth_pct=11.2 streak=0 profit_streak=10
day=366 n=12 mrr_close=181256 income=174979 expense=39708 net=135271 red=0 growth_pct=12.1 streak=1 profit_streak=11
day=397 n=12 mrr_close=196440 income=196816 expense=39946 net=156870 red=0 growth_pct=8.4 streak=0 profit_streak=12
day=425 n=12 mrr_close=210052 income=190987 expense=36762 net=154225 red=0 growth_pct=6.9 streak=0 profit_streak=12
day=456 n=12 mrr_close=228225 income=226545 expense=41418 net=185127 red=0 growth_pct=8.7 streak=0 profit_streak=12
day=486 n=12 mrr_close=239837 income=233722 expense=41384 net=192338 red=0 growth_pct=5.1 streak=0 profit_streak=12
day=517 n=12 mrr_close=262978 income=256863 expense=43001 net=213862 red=0 growth_pct=9.6 streak=0 profit_streak=12
day=547 n=12 mrr_close=288794 income=278086 expense=37944 net=240142 red=0 growth_pct=9.8 streak=0 profit_streak=12
day=578 n=12 mrr_close=313812 income=310275 expense=40849 net=269426 red=0 growth_pct=8.7 streak=0 profit_streak=12
day=609 n=12 mrr_close=343858 income=340049 expense=41450 net=298599 red=0 growth_pct=9.6 streak=0 profit_streak=12
day=639 n=12 mrr_close=377471 income=362210 expense=42206 net=320004 red=0 growth_pct=9.8 streak=0 profit_streak=12
day=670 n=12 mrr_close=404911 income=405323 expense=46355 net=358968 red=0 growth_pct=7.3 streak=0 profit_streak=12
day=700 n=12 mrr_close=429877 income=418003 expense=43841 net=374162 red=0 growth_pct=6.2 streak=0 profit_streak=12
```
