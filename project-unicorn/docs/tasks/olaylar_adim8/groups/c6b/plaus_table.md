RUNS per preset: {'full_run': 40, 'full_run_b2c': 40, 'full_run_staff25': 40}  incomplete: []
SUMMARY: {'full_run_fires': 8254, 'full_run_fails': 0, 'full_run_b2c_fires': 1780, 'full_run_b2c_fails': 0, 'full_run_staff25_fires': 8462, 'full_run_staff25_fails': 0}
FAILS: 0
ERRS: 2
  full_run_8_early: PROBE ERROR day=24 plan unstartable   | last fire before: PLAUS FIRE id=team.rude_client src=pool week=23 phase=2 hc=4 slots=customer:14,employee:16,founder:-
  full_run_staff25_8_early: PROBE ERROR day=24 plan unstartable   | last fire before: PLAUS FIRE id=team.rude_client src=pool week=23 phase=2 hc=4 slots=customer:14,employee:16,founder:-

| card | full_run | full_run_staff25 | full_run_b2c | total |
|---|---|---|---|---|
| team.work_laptop | 7 | 7 | 7 | 21 |
| team.wedding_invite | 114 | 111 | 131 | 356 |
| team.master_degree | 13 | 13 | 18 | 44 |
| team.master_degree_farewell | 0 | 0 | 0 | 0 |
| team.rude_client | 345 | 343 | 0 | 688 |
| team.same_leave_pm | 0 | 0 | 0 | 0 |
| team.same_leave_dev | 0 | 2 | 0 | 2 |
| team.same_leave_tester | 0 | 0 | 0 | 0 |
| product.sprint_dev_code_review | 0 | 0 | 0 | 0 |
| team.promise_made | 0 | 0 | 0 | 0 |
| customer.training_request | 13 | 13 | 0 | 26 |
| customer.own_data_error | 192 | 191 | 0 | 383 |
| customer.finance_team | 1 | 1 | 0 | 2 |
| customer.old_browser | 57 | 45 | 0 | 102 |
| rival.outage | 112 | 114 | 0 | 226 |
| product.sprint_test_rival_batch | 0 | 0 | 0 | 0 |
| rival.new_firm_warning | 50 | 51 | 0 | 101 |
| world.server_price_hike | 40 | 40 | 40 | 120 |
| world.cloud_price_cut | 39 | 39 | 40 | 118 |
| world.data_location | 39 | 39 | 0 | 78 |
| world.data_claim_exposed | 0 | 0 | 0 | 0 |
| world.quarterly_bulletin | 36 | 36 | 0 | 72 |
| world.award_final | 6 | 6 | 20 | 32 |
| product.encryption_flaw | 0 | 0 | 40 | 40 |
| product.encryption_flaw_b2b | 39 | 39 | 0 | 78 |
| product.encryption_flaw_press | 0 | 0 | 0 | 0 |
| product.encryption_flaw_press_b2b | 0 | 0 | 0 | 0 |
| product.sprint_pm_hospital | 0 | 0 | 0 | 0 |

NEVER FIRED in plaus: team.master_degree_farewell, team.same_leave_pm, team.same_leave_tester, product.sprint_dev_code_review, team.promise_made, product.sprint_test_rival_batch, world.data_claim_exposed, product.encryption_flaw_press, product.encryption_flaw_press_b2b, product.sprint_pm_hospital

FINANCE_TEAM fires: 2
  full_run_16_plain week=16 req=queue_request:locked,rep_shows:open,carry_on:open
  full_run_staff25_16_plain week=16 req=queue_request:locked,rep_shows:open,carry_on:open

FIRST WEEK of 4 cards (earliest per run; n=runs fired / runs):
customer.training_request full_run: n=12/40 min=9 median=10.5 max=17  by-run=1p:17 2e:10 5e:10 8p:17 9e:10 12e:9 13e:11 14e:9 14p:17 17p:17 18p:17 19e:10
customer.training_request full_run_staff25: n=12/40 min=9 median=10.5 max=17  by-run=1p:17 2e:10 5e:10 8p:17 9e:10 12e:9 13e:11 14e:9 14p:17 17p:17 18p:17 19e:10
customer.training_request full_run_b2c: n=0/40 never
customer.finance_team full_run: n=1/40 min=16 median=16 max=16  by-run=16p:16
customer.finance_team full_run_staff25: n=1/40 min=16 median=16 max=16  by-run=16p:16
customer.finance_team full_run_b2c: n=0/40 never
customer.old_browser full_run: n=26/40 min=17 median=55.0 max=92  by-run=1p:37 2e:89 2p:37 3p:92 4p:69 5p:58 7e:63 7p:45 8p:52 9p:60 10p:17 11e:46 11p:23 12p:34 13e:41 13p:31 14p:37 15e:88 15p:79 16p:71 17p:48 18e:68 18p:22 19e:88 19p:59 20p:85
customer.old_browser full_run_staff25: n=24/40 min=17 median=50.0 max=89  by-run=1p:37 2e:89 2p:37 4p:69 5p:58 7e:63 7p:45 8p:52 9p:60 10p:17 11e:46 11p:23 12p:34 13e:41 13p:31 14p:37 15e:88 15p:79 16p:71 17p:48 18e:68 18p:22 19e:88 19p:59
customer.old_browser full_run_b2c: n=0/40 never
rival.outage full_run: n=39/40 min=24 median=32 max=55  by-run=1e:41 1p:42 2e:26 2p:28 3e:29 3p:27 4e:32 4p:30 5e:27 5p:32 6e:29 6p:33 7e:27 7p:35 8p:29 9e:37 9p:32 10e:35 10p:38 11e:28 11p:28 12e:39 12p:30 13e:30 13p:32 14e:35 14p:35 15e:30 15p:39 16e:41 16p:30 17e:24 17p:36 18e:25 18p:25 19e:33 19p:39 20e:55 20p:31
rival.outage full_run_staff25: n=39/40 min=24 median=32 max=55  by-run=1e:41 1p:42 2e:26 2p:28 3e:29 3p:27 4e:32 4p:30 5e:27 5p:32 6e:29 6p:33 7e:27 7p:35 8p:29 9e:37 9p:32 10e:35 10p:38 11e:28 11p:28 12e:39 12p:30 13e:30 13p:32 14e:35 14p:35 15e:30 15p:39 16e:41 16p:30 17e:24 17p:36 18e:25 18p:25 19e:33 19p:39 20e:55 20p:31
rival.outage full_run_b2c: n=0/40 never
