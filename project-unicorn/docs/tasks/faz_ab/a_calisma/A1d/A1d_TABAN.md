# A1d - Taban koşuları (HEAD 1faeb82, kod değişikliği öncesi)

Çıktı klasörü: `docs/tasks/faz_ab/a_calisma/A1d/`. Repo'ya dokunulmadı; yalnız bu klasöre log ve durum dosyası yazıldı.

## Ortam

- GODOT=`/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe`
- Her koşu kendi APPDATA ve HOME dizininde (`plausibility_run.sh` kalıbı; Windows yolu `cygpath -w` ile çevrildi):
  - `A1d/appdata_sprint`
  - `A1d/appdata_full7`
  - `A1d/appdata_b2c7`
- Gerçek kullanıcı dizini kullanılmadı.
- Zaman aşımı: 1200 s (`timeout`).

## Komutlar

1. Sprint probe (sıralı, önce):

```
APPDATA=<cygpath -w appdata_sprint> HOME=<aynı> timeout 1200 "$GODOT" --headless --path . --lang=tr --sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1 > A1d/sprint_probe.log 2>&1
```

2. Paralel iki arka plan işi (ayrı APPDATA):

```
APPDATA=<appdata_full7> HOME=<aynı> timeout 1200 "$GODOT" --headless --path . --lang=tr --run-log=full_run:104:sim:7 > A1d/full_run_7.log 2>&1
APPDATA=<appdata_b2c7> HOME=<aynı> timeout 1200 "$GODOT" --headless --path . --lang=tr --run-log=full_run_b2c:104:sim:7 > A1d/full_run_b2c_7.log 2>&1
```

## Çıkış kodları ve süre

| Koşu | Çıkış kodu | Duvar saati (s) |
|---|---|---|
| sprint_probe | 0 | 23 |
| full_run_7 | 0 | 45 |
| full_run_b2c_7 | 0 | 32 |

Paralel iki koşu aynı anda başladı ve birlikte bitmeyi bekledi. Süreler `date +%s` farkıdır.

## sprint_probe.log

SPRINTPROBE SUMMARY satırı (verbatim):

```
SPRINTPROBE SUMMARY|match=245/251|mvp_days=3x1
```

Mismatch sayımı (`cause=` değerine göre; toplam 6 satır):

| cause | adet |
|---|---|
| product.sprint_late | 3 |
| team | 3 |

Adlandırılmış (named) ve adlandırılmamış (unnamed) ayrımı bu satırlarda yok: 6 mismatch satırının 6'sı de `cause=` taşıyor. Satır başlığı `SPRINTPROBE CLOSE|...|MISMATCH|cause=...` biçiminde.

`^ERROR` satırı: 0. `PROBE ERROR` satırı: 0.

## Tam koşu logları

### full_run_7.log

- PROBE END (verbatim):

```
PROBE END day=104 run_active=false ending=running_on_fumes finite_runway_p1=9/9 finite_runway_p2=3/55 finite_runway_p3=0/39 min_cash_pre_seed=5461 seed_day=18 first_sign_day=9 first_revenue_day=10 cheque_day=13 open_w1_12=5 idle_w1_12=0
```

- `^ERROR` satırı: 0. `PROBE ERROR` satırı: 0.
- Tür başına satır sayısı: B2C 0, SHIP 65, STATE 103, CUST 14928, CHURN 7, SPRINT 68, WEEK 104, PLAY 705.

İlk görülen satırlar (verbatim):

- PROBE B2C: yok (bu koşuda hiç üretilmedi)
- PROBE SHIP: `PROBE SHIP day=7 version=1 label=v1.0 stability=0.0 innovation=8.0 experience=4.0 bugs=0 tickets=0`
- PROBE STATE: `PROBE STATE day=1 cash=10000 mrr=0 brand=50 burn=50 runway=6.67 cust=0 emp=0 promises=0 phase=1 aud=0 sat=-1 bugs=0 q=-1.0 appetite=closed approach=0 gate_ready=false profit_streak=0`
- PROBE CUST: `PROBE CUST day=9 id=co_lead_8_1 sat=50 tol=33 target=35 trust=0.0 phase=onboarding streak=0 cd=-1 mrr=250 bugs=0`
- PROBE CHURN: `PROBE CHURN day=16 id=co_lead_8_1 sat=22 tol=33 trust=0.0 phase=churning streak=4 countdown=0 mrr=250`
- PROBE SPRINT: `PROBE SPRINT day=3 n=1 label=- shipped=feat:line_erp_cashflow_k1 carried=0 velocity=3/4`
- PROBE WEEK: `PROBE WEEK w=1 fires=0 meetings=0 signs=0`
- PROBE PLAY: `PROBE PLAY day=1 choose_type erp market=b2b`

### full_run_b2c_7.log

- PROBE END (verbatim):

```
PROBE END day=104 run_active=false ending=running_on_fumes finite_runway_p1=8/8 finite_runway_p2=9/63 finite_runway_p3=0/32 min_cash_pre_seed=4936 seed_day=39 first_sign_day=-1 first_revenue_day=9 cheque_day=17 open_w1_12=0 idle_w1_12=0
```

- `^ERROR` satırı: 1. Satır (verbatim): `ERROR: 1 resources still in use at exit (run with --verbose for details).` Bu motorun kapanış sızıntı raporudur; `tools/gate_common.sh` içindeki `ERR_IGNORE` deseniyle eşleşir.
- `PROBE ERROR` satırı: 0.
- Tür başına satır sayısı: B2C 97, SHIP 47, STATE 103, CUST 0, CHURN 0, SPRINT 60, WEEK 104, PLAY 268.

İlk görülen satırlar (verbatim):

- PROBE B2C: `PROBE B2C day=7 aud=0.0 paying=0 price=0 conv=0.000 sat=-1 sat_target=14 live_bugs=0 confirmed=0 q=9.5 interest=100.0 occ=0.00 desk=0 incoming=0 inflow_day=0.71 validation_day=0.00`
- PROBE SHIP: `PROBE SHIP day=7 version=1 label=v1.0 stability=0.0 innovation=8.0 experience=4.0 bugs=0 tickets=0`
- PROBE STATE: `PROBE STATE day=1 cash=10000 mrr=0 brand=50 burn=50 runway=6.67 cust=0 emp=0 promises=0 phase=1 aud=0 sat=-1 bugs=0 q=-1.0 appetite=closed approach=0 gate_ready=false profit_streak=0`
- PROBE CUST: bu koşuda hiç üretilmedi (0 satır).
- PROBE CHURN: bu koşuda hiç üretilmedi (0 satır).
- PROBE SPRINT: `PROBE SPRINT day=3 n=1 label=- shipped=feat:line_note_tool_capture_k1 carried=0 velocity=3/4`
- PROBE WEEK: `PROBE WEEK w=1 fires=0 meetings=0 signs=0`
- PROBE PLAY: `PROBE PLAY day=1 choose_type note_tool market=b2c`

PROBE SHIP ve PROBE PLAY alanları iki koşuda da aynı sırayla basılıyor; B2C koşusunda PROBE B2C ve PROBE PLAY, B2B koşusunda PROBE CUST ve PROBE CHURN üretiliyor.

## Ek · K4 kurtarma turu (2026-10-17): ad sayımının görmediği neden

Yukarıdaki tablo sprint başına İLK değişikliğin adını sayar, sprintteki bütün nedenleri değil. `sprint_probe.gd`
`_changed_by` sprintin bütün uyuşmazlıklarını o sprintte girdiyi ilk değiştirenin adıyla yazar (`_cause == ""`
koşulu); aynı sprintte sonra gelen olay adlanmaz.

Kanıt: bu tabanın commit'i `1faeb82` repo dışında geçici bir dizine çıkarıldı (`git archive`; koşudan
sonra silindi). Yalnız probe'a tanı satırı eklendi: girdiyi değiştiren her çağrı için `SPRINTPROBE CHANGE|<sprint>|day=|who=|team=|cards=|first=`.
Sonra aynı komutla koşuldu. PRED/CLOSE/SKIP/MVP/LOAD/SUMMARY ve `PROBE PICK` satırları bu klasördeki `sprint_probe.log`
ile bayt bayt aynı çıktı. Kayıt `../K4/rescue_diag_1faeb82.log`, tanı yaması `../K4/rescue_sprint_probe_diag.gd.txt`.

- Sprint 2, gün 4: önce günün tiki ekibi değiştirdi (`who=team|team=1|first=1`, satır 40). Sonra
  `product.sprint_two_paths` "Kısa yola geç" seçildi. Bu seçim `feat:line_note_tool_capture_k2`'nin kalanını
  4,00'ten 2,00'ye indirdi (`first=0`, satır 43).
- Bu kart tabanın uyuşmazlıklarından biridir: `SPRINTPROBE CLOSE|424242|2|feat:line_note_tool_capture_k2|0|0.00|MISMATCH|cause=team`
  (`sprint_probe.log:45`).

Yani tabanda sprint kartını değiştirip ya da taşıyıp uyuşmazlık doğuran olaylar `product.sprint_late` ve `product.sprint_two_paths`'tir;
ikincisi `team` adı altında görünür. **Tabanın neden listesi: `product.sprint_late`, `product.sprint_two_paths`,
`team`.** Yukarıdaki etiket sayıları (3 + 3) değişmez. İki olay aynı karar havuzundandır (`sprint.json`
`decision.cards`). Hangi sprintte hangi kartın hangi kâğıdı çektiğini `SprintSystem._request_decision`'ın
`hash([run_seed, kart, sprint, hafta])` zarı belirler.
