# Faz Q · Q0b taban ölçümü (eski kod, K0 harness'i `beb797e`)
Bot koşuları tohum 7 ve 11, 104 hafta, `--lang=tr`. "Yeni formül U" sütunları bugünkü ürünün PRD Karar 5/6 formülüyle
çevrimdışı hesaplanmış U'sudur (yıldız tablosu, sektör vurgusu, ağırlıklar, tavan 0,25, oran kesiği 1,5, rakip penceresi;
onay bekleyen değerler PRD'nin önerisi). Bugünkü kodda U yoktur; bu sütun E1'in "bugün" satırıdır. Bu dosya commit'lenmez.

## 1. B2B imzalar (MVP sonrası 26 hafta ve bütün koşu)
| koşu | MVP hf | 26 hf imza | kurucu | satışçı | bütün imza | 1★/2★/3★ | son |
|---|---|---|---|---|---|---|---|
| full_run_fix_due_11 | 7 | 82 | 82 | 0 | 355 | 214/131/10 | running_on_fumes hf 104 |
| full_run_fix_due_7 | 7 | 83 | 83 | 0 | 351 | 259/83/9 | running_on_fumes hf 104 |
| full_run_fix_none_11 | 7 | 82 | 82 | 0 | 354 | 223/109/22 | running_on_fumes hf 104 |
| full_run_fix_none_7 | 7 | 83 | 83 | 0 | 353 | 201/141/11 | running_on_fumes hf 104 |
| full_run_fix_off_11 | 7 | 82 | 82 | 0 | 349 | 246/86/17 | running_on_fumes hf 104 |
| full_run_fix_off_7 | 7 | 82 | 82 | 0 | 349 | 239/101/9 | running_on_fumes hf 104 |
| full_run_fix_worst_11 | 7 | 82 | 82 | 0 | 350 | 247/86/17 | running_on_fumes hf 104 |
| full_run_fix_worst_7 | 7 | 83 | 83 | 0 | 352 | 242/100/10 | running_on_fumes hf 104 |
| full_run_vc_cautious_11 | 7 | 82 | 82 | 0 | 202 | 127/65/10 | series_a_close hf 64 |
| full_run_vc_cautious_7 | 7 | 83 | 83 | 0 | 215 | 137/69/9 | series_a_close hf 67 |


Satışçı kapanışı: bütün koşularda `by=rep` 0. Bot kurucusu her adayla kendisi görüşüyor; temsilciler aday almıyor. Karar 14'ün
satışçı zarı kapıları bu botla ölçülemez, K8'de botun temsilcilere aday bırakması gerekir (harness değişikliği).

## 2. Aday yıldız karışımı (PROBE LEAD), evre başına
| koşu | Bootstrap 1/2/3★ | Traction 1/2/3★ | Series A Avı 1/2/3★ | Series A Avı 3★ payı |
|---|---|---|---|---|
| full_run_fix_due_11 | 12/4/0 | 184/269/82 | 234/333/99 | 15% |
| full_run_fix_due_7 | 8/3/1 | 227/325/100 | 202/281/84 | 15% |
| full_run_fix_none_11 | 12/4/0 | 255/373/108 | 98/132/38 | 14% |
| full_run_fix_none_7 | 8/3/1 | 291/404/121 | 117/167/51 | 15% |
| full_run_fix_off_11 | 12/4/0 | 223/320/94 | 188/270/86 | 16% |
| full_run_fix_off_7 | 8/3/1 | 237/333/102 | 195/275/83 | 15% |
| full_run_fix_worst_11 | 12/4/0 | 223/320/94 | 188/269/85 | 16% |
| full_run_fix_worst_7 | 8/3/1 | 239/336/100 | 188/268/83 | 15% |
| full_run_vc_cautious_11 | 12/4/0 | 202/291/87 | 14/22/8 | 18% |
| full_run_vc_cautious_7 | 8/3/1 | 228/328/101 | 20/20/2 | 5% |

## 3. Bugünkü ürün, yeni formül: imza anındaki U
Satır başına iki okuma: bütün imzalar ve yalnız 2★ ile 3★ (Karar 8). Kapılar: U = 100 payı en çok %25; Traction ortancası 70 ile 85.
| koşu | küme | n | U=100 payı | Traction ortanca U | tavan devrede | kayıp alanı dağılımı | U < tol+10 payı |
|---|---|---|---|---|---|---|---|
| full_run_fix_due_11 | bütün | 355 | 68% | 99 | 1% | onboarding 45, core 24 | 4% |
| full_run_fix_due_11 | 2★+3★ | 141 | 41% | 76 | 4% | onboarding 45, core 24 | 11% |
| full_run_fix_due_7 | bütün | 351 | 77% | 100 | 0% | onboarding 23, core 16, trust 2 | 5% |
| full_run_fix_due_7 | 2★+3★ | 92 | 43% | 72 | 1% | onboarding 23, core 16, trust 2 | 18% |
| full_run_fix_none_11 | bütün | 354 | 73% | 100 | 1% | onboarding 36, core 21 | 4% |
| full_run_fix_none_11 | 2★+3★ | 131 | 46% | 77 | 2% | onboarding 36, core 21 | 10% |
| full_run_fix_none_7 | bütün | 353 | 75% | 100 | 1% | onboarding 39, core 15, trust 2 | 5% |
| full_run_fix_none_7 | 2★+3★ | 152 | 59% | 77 | 1% | onboarding 39, core 15, trust 2 | 11% |
| full_run_fix_off_11 | bütün | 349 | 73% | 100 | 1% | onboarding 34, core 23 | 4% |
| full_run_fix_off_11 | 2★+3★ | 103 | 36% | 72 | 4% | onboarding 34, core 23 | 14% |
| full_run_fix_off_7 | bütün | 349 | 75% | 100 | 1% | onboarding 30, core 18, trust 2 | 4% |
| full_run_fix_off_7 | 2★+3★ | 110 | 47% | 72 | 5% | onboarding 30, core 18, trust 2 | 14% |
| full_run_fix_worst_11 | bütün | 350 | 73% | 100 | 1% | onboarding 34, core 23 | 4% |
| full_run_fix_worst_11 | 2★+3★ | 103 | 36% | 72 | 4% | onboarding 34, core 23 | 14% |
| full_run_fix_worst_7 | bütün | 352 | 73% | 100 | 2% | onboarding 34, core 19, trust 2 | 5% |
| full_run_fix_worst_7 | 2★+3★ | 110 | 42% | 73.50 | 5% | onboarding 34, core 19, trust 2 | 16% |
| full_run_vc_cautious_11 | bütün | 202 | 58% | 100 | 2% | core 24, onboarding 19 | 7% |
| full_run_vc_cautious_11 | 2★+3★ | 75 | 31% | 72 | 7% | core 24, onboarding 19 | 20% |
| full_run_vc_cautious_7 | bütün | 215 | 60% | 100 | 3% | onboarding 26, core 19, trust 2 | 8% |
| full_run_vc_cautious_7 | 2★+3★ | 78 | 28% | 73 | 8% | onboarding 26, core 19, trust 2 | 22% |

## 4. Bugünkü ürün, yeni formül: imza anındaki U, yıldız ve evre başına (p10 / ortanca / p90)
| koşu | yıldız | Bootstrap | Traction | Series A Avı |
|---|---|---|---|---|
| full_run_fix_due_11 | 1★ | 70 / 70 / 70 (n=3) | 76 / 100 / 100 (n=89) | 100 / 100 / 100 (n=122) |
| full_run_fix_due_11 | 2★ | 51 / 51 / 51 (n=1) | 54 / 76 / 100 (n=73) | 76 / 100 / 100 (n=57) |
| full_run_fix_due_11 | 3★ | - | 35 / 39 / 64 (n=9) | 70 / 70 / 70 (n=1) |
| full_run_fix_due_7 | 1★ | 70 / 70 / 70 (n=3) | 76 / 100 / 100 (n=123) | 100 / 100 / 100 (n=133) |
| full_run_fix_due_7 | 2★ | - | 51 / 83 / 100 (n=66) | 100 / 100 / 100 (n=17) |
| full_run_fix_due_7 | 3★ | - | 30 / 35 / 62 (n=9) | - |
| full_run_fix_none_11 | 1★ | 70 / 70 / 70 (n=3) | 76 / 100 / 100 (n=163) | 100 / 100 / 100 (n=57) |
| full_run_fix_none_11 | 2★ | 51 / 51 / 51 (n=1) | 62 / 99 / 100 (n=89) | 100 / 100 / 100 (n=19) |
| full_run_fix_none_11 | 3★ | - | 39 / 62 / 77 (n=18) | 73 / 84 / 84 (n=4) |
| full_run_fix_none_7 | 1★ | 70 / 70 / 70 (n=3) | 76 / 100 / 100 (n=149) | 100 / 100 / 100 (n=49) |
| full_run_fix_none_7 | 2★ | - | 59 / 99 / 100 (n=100) | 100 / 100 / 100 (n=41) |
| full_run_fix_none_7 | 3★ | - | 30 / 42 / 71 (n=11) | - |
| full_run_fix_off_11 | 1★ | 70 / 70 / 70 (n=3) | 76 / 100 / 100 (n=123) | 100 / 100 / 100 (n=120) |
| full_run_fix_off_11 | 2★ | 51 / 51 / 51 (n=1) | 59 / 76 / 100 (n=67) | 100 / 100 / 100 (n=18) |
| full_run_fix_off_11 | 3★ | - | 35 / 42 / 67 (n=10) | 73 / 77 / 84 (n=7) |
| full_run_fix_off_7 | 1★ | 70 / 70 / 70 (n=3) | 76 / 100 / 100 (n=127) | 100 / 100 / 100 (n=109) |
| full_run_fix_off_7 | 2★ | - | 51 / 76 / 100 (n=65) | 100 / 100 / 100 (n=36) |
| full_run_fix_off_7 | 3★ | - | 30 / 35 / 67 (n=9) | - |
| full_run_fix_worst_11 | 1★ | 70 / 70 / 70 (n=3) | 76 / 100 / 100 (n=123) | 100 / 100 / 100 (n=121) |
| full_run_fix_worst_11 | 2★ | 51 / 51 / 51 (n=1) | 59 / 76 / 100 (n=67) | 100 / 100 / 100 (n=18) |
| full_run_fix_worst_11 | 3★ | - | 35 / 42 / 67 (n=10) | 73 / 77 / 84 (n=7) |
| full_run_fix_worst_7 | 1★ | 70 / 70 / 70 (n=3) | 76 / 100 / 100 (n=129) | 100 / 100 / 100 (n=110) |
| full_run_fix_worst_7 | 2★ | - | 51 / 76 / 100 (n=68) | 76 / 100 / 100 (n=32) |
| full_run_fix_worst_7 | 3★ | - | 30 / 35 / 67 (n=10) | - |
| full_run_vc_cautious_11 | 1★ | 70 / 70 / 70 (n=3) | 76 / 100 / 100 (n=117) | 100 / 100 / 100 (n=7) |
| full_run_vc_cautious_11 | 2★ | 51 / 51 / 51 (n=1) | 54 / 83 / 100 (n=62) | 100 / 100 / 100 (n=2) |
| full_run_vc_cautious_11 | 3★ | - | 35 / 42 / 64 (n=9) | 77 / 77 / 77 (n=1) |
| full_run_vc_cautious_7 | 1★ | 70 / 70 / 70 (n=3) | 76 / 100 / 100 (n=125) | 100 / 100 / 100 (n=9) |
| full_run_vc_cautious_7 | 2★ | - | 49 / 76 / 100 (n=66) | 76 / 100 / 100 (n=3) |
| full_run_vc_cautious_7 | 3★ | - | 30 / 35 / 67 (n=9) | - |

## 5. İmza anındaki alan seviyeleri (ham), yıldız ve evre başına, bütün B2B koşuları birlikte (p10 / ortanca / p90)
Yıldız beklenti tablosu bundan kalibre edilir (PRD §5).
| yıldız | evre | n | Çekirdek | İlk kullanım | Entegrasyonlar | Güven |
|---|---|---|---|---|---|---|
| 1★ | Bootstrap | 30 | 0.60 / 0.60 / 0.60 | 0.00 / 0.00 / 0.00 | 1.00 / 1.00 / 1.00 | 0.00 / 0.00 / 0.00 |
| 1★ | Traction | 1268 | 1.20 / 2.00 / 2.00 | 0.00 / 0.00 / 0.00 | 1.00 / 3.00 / 3.00 | 1.00 / 2.50 / 3.00 |
| 1★ | Series A Avı | 837 | 2.00 / 2.00 / 2.00 | 0.00 / 1.00 / 1.00 | 3.00 / 3.00 / 3.00 | 3.00 / 3.00 / 3.00 |
| 2★ | Bootstrap | 5 | 0.60 / 0.60 / 0.60 | 0.00 / 0.00 / 0.00 | 1.00 / 1.00 / 1.00 | 0.50 / 0.50 / 0.50 |
| 2★ | Traction | 723 | 1.00 / 1.60 / 2.00 | 0.00 / 0.00 / 0.00 | 1.00 / 2.00 / 3.00 | 1.00 / 2.50 / 3.00 |
| 2★ | Series A Avı | 243 | 2.00 / 2.00 / 2.00 | 0.00 / 1.00 / 1.00 | 3.00 / 3.00 / 3.00 | 3.00 / 3.00 / 3.00 |
| 3★ | Traction | 104 | 1.00 / 1.20 / 2.00 | 0.00 / 0.00 / 0.00 | 1.00 / 1.00 / 3.00 | 1.00 / 2.00 / 3.00 |
| 3★ | Series A Avı | 20 | 2.00 / 2.00 / 2.00 | 0.00 / 1.00 / 1.00 | 3.00 / 3.00 / 3.00 | 3.00 / 3.00 / 3.00 |

## 6. Aday U'su (bugünkü ürün, yeni formül)
Traction'ın ilk 12 haftasında gelen 2★ adayların U ortancası (kapı önerisi en az 48) ve Traction haftalarında 13 sektörün 2★ U farkı
(en yüksek eksi en düşük; kapı önerisi ortancada en az 8).
| koşu | Traction başı hf | ilk 12 hf 2★ aday n | ortanca U | 13 sektör 2★ farkı, Traction haftalarının ortancası |
|---|---|---|---|---|
| full_run_fix_due_11 | 12 | 36 | 68 | 24 |
| full_run_fix_due_7 | 11 | 38 | 62 | 24 |
| full_run_fix_none_11 | 12 | 36 | 68 | 24 |
| full_run_fix_none_7 | 11 | 38 | 62 | 24 |
| full_run_fix_off_11 | 12 | 36 | 68 | 24 |
| full_run_fix_off_7 | 11 | 38 | 62 | 24 |
| full_run_fix_worst_11 | 12 | 36 | 68 | 24 |
| full_run_fix_worst_7 | 11 | 38 | 62 | 24 |
| full_run_vc_cautious_11 | 12 | 36 | 68 | 24 |
| full_run_vc_cautious_7 | 11 | 38 | 62 | 24 |

## 7. B2C: kitle ve kitle bağlamında U (bugünkü ürün, yeni formül; eşikler 1.000 / 10.000 / 50.000 önerisi)
| koşu | MVP hf | kitle hf 26 / 52 / 104 | U hf 26 / 52 / 104 | kitleden gelen en büyük haftalık U kayması | son |
|---|---|---|---|---|---|
| full_run_b2c_fix_due_11 | 7 | 773 / 5612 / 197717 | 88 / 100 / 100 | 12 | running_on_fumes hf 104 |
| full_run_b2c_fix_due_7 | 7 | 768 / 5110 / 154415 | 51 / 92 / 100 | 12 | running_on_fumes hf 104 |
| full_run_b2c_fix_none_11 | 7 | 1030 / 7965 / 45587 | 67 / 100 / 100 | 3 | running_on_fumes hf 104 |
| full_run_b2c_fix_none_7 | 7 | 1231 / 7766 / 13136 | 66 / 100 / 100 | 3 | running_on_fumes hf 104 |
| full_run_b2c_fix_off_11 | 7 | 827 / 6112 / 200800 | 51 / 100 / 100 | 12 | running_on_fumes hf 104 |
| full_run_b2c_fix_off_7 | 7 | 851 / 5858 / 272523 | 51 / 95 / 100 | 12 | running_on_fumes hf 104 |
| full_run_b2c_fix_worst_11 | 7 | 824 / 6005 / 130278 | 51 / 100 / 100 | 12 | running_on_fumes hf 104 |
| full_run_b2c_fix_worst_7 | 7 | 846 / 5703 / 216576 | 51 / 95 / 100 | 12 | running_on_fumes hf 104 |
| full_run_b2c_vc_cautious_11 | 7 | 754 / 4609 / 40209 | 38 / 99 / 100 | 12 | series_a_close hf 82 |
| full_run_b2c_vc_cautious_7 | 7 | 775 / 4343 / 41063 | 38 / 94 / 100 | 12 | series_a_close hf 84 |

## 8. VC ürün sorusu (PROBE VCQ)
| koşu | VCQ satırı | weak_dim | how_big | anahtarlar |
|---|---|---|---|---|
| full_run_b2c_fix_due_11 | 1 | 0 | 0 | first_customers 1 |
| full_run_b2c_fix_due_7 | 1 | 0 | 0 | first_customers 1 |
| full_run_b2c_fix_none_11 | 1 | 0 | 0 | first_customers 1 |
| full_run_b2c_fix_none_7 | 1 | 0 | 0 | first_customers 1 |
| full_run_b2c_fix_off_11 | 1 | 0 | 0 | first_customers 1 |
| full_run_b2c_fix_off_7 | 1 | 0 | 0 | first_customers 1 |
| full_run_b2c_fix_worst_11 | 1 | 0 | 0 | first_customers 1 |
| full_run_b2c_fix_worst_7 | 1 | 0 | 0 | first_customers 1 |
| full_run_b2c_vc_cautious_11 | 3 | 0 | 0 | clean 2, first_customers 1 |
| full_run_b2c_vc_cautious_7 | 3 | 0 | 0 | clean 2, first_customers 1 |
| full_run_fix_due_11 | 1 | 0 | 0 | clean 1 |
| full_run_fix_due_7 | 1 | 0 | 0 | clean 1 |
| full_run_fix_none_11 | 1 | 0 | 0 | clean 1 |
| full_run_fix_none_7 | 1 | 0 | 0 | clean 1 |
| full_run_fix_off_11 | 1 | 0 | 0 | clean 1 |
| full_run_fix_off_7 | 1 | 0 | 0 | clean 1 |
| full_run_fix_worst_11 | 1 | 0 | 0 | clean 1 |
| full_run_fix_worst_7 | 1 | 0 | 0 | clean 1 |
| full_run_vc_cautious_11 | 3 | 0 | 0 | clean 2, churn 1 |
| full_run_vc_cautious_7 | 3 | 0 | 0 | clean 2, churn 1 |

## 9. Sprint probu
- `sprint_b2c`: 8 MISMATCH satırı
  - `SPRINTPROBE SUMMARY|match=191/199|mvp_days=3x1`
  - `SPRINTPROBE LOADSUM|team=3|weeks=2|sprints=49|planned=197|finished=184|idle=28|limits=ceiling:5,pool:44`
  - `SPRINTPROBE PAPERSUM|weeks=2|sprints=49|papers=1|empty=48|empty_rate=0.98`
  - `SPRINTPROBE CLOSE|424242|2|feat:line_note_tool_linking_k2|0|2.57|MISMATCH|cause=team`
  - `SPRINTPROBE CLOSE|424242|3|fix:line_note_tool_search|0|0.36|MISMATCH|cause=team.burnout`
  - `SPRINTPROBE CLOSE|424242|3|feat:line_note_tool_sync_k2|0|1.39|MISMATCH|cause=team.burnout`
  - `SPRINTPROBE CLOSE|424242|3|res:onboarding|0|0.39|MISMATCH|cause=team.burnout`
  - `SPRINTPROBE CLOSE|424242|4|feat:line_shared_security_k1@note_tool|0|1.00|MISMATCH|cause=product.sprint_design_first_screen`
  - `SPRINTPROBE CLOSE|424242|5|fix:line_shared_mobile@note_tool|0|0.16|MISMATCH|cause=team.burnout`
  - `SPRINTPROBE CLOSE|424242|5|fix:line_shared_integrations@note_tool|0|0.00|MISMATCH|cause=team.burnout`
  - `SPRINTPROBE CLOSE|424242|5|plan:cap_paid_plan|0|0.60|MISMATCH|cause=team.burnout`
- `sprint_b2b`: 7 MISMATCH satırı
  - `SPRINTPROBE SUMMARY|match=155/162|mvp_days=3x1`
  - `SPRINTPROBE LOADSUM|team=3|weeks=2|sprints=51|planned=162|finished=148|idle=10|limits=ceiling:4,pool:47`
  - `SPRINTPROBE PAPERSUM|weeks=2|sprints=51|papers=2|empty=49|empty_rate=0.96`
  - `SPRINTPROBE CLOSE|424242|2|feat:line_erp_cashflow_k2|0|2.57|MISMATCH|cause=team`
  - `SPRINTPROBE CLOSE|424242|3|fix:line_erp_ledger|0|0.36|MISMATCH|cause=team.burnout`
  - `SPRINTPROBE CLOSE|424242|3|feat:line_erp_stock_k2|0|1.39|MISMATCH|cause=team.burnout`
  - `SPRINTPROBE CLOSE|424242|3|res:onboarding|0|0.39|MISMATCH|cause=team.burnout`
  - `SPRINTPROBE CLOSE|424242|4|req:co_probe_manufacturing.6|0|0.80|MISMATCH|cause=product.sprint_design_empty_state`
  - `SPRINTPROBE CLOSE|424242|5|fix:line_shared_mobile@erp|0|0.96|MISMATCH|cause=team.burnout`
  - `SPRINTPROBE CLOSE|424242|5|fix:line_shared_integrations@erp|0|0.00|MISMATCH|cause=team.burnout`

## 10. Tik probu (3 koşu, ortanca)
- `tick_old` (3 koşu): hour_p50 ortanca 2.42, hour_p95 ortanca 2.86, night_max ortanca 30.49, night_each ortanca 20.50, first_night ortanca 30.49
- `tick_new` (3 koşu): hour_p50 ortanca 5.02, hour_p95 ortanca 5.99, night_max ortanca 153.04, night_each ortanca 141.10, first_night ortanca 107.01; TICK WORLD accounts=330 mrr=3300
