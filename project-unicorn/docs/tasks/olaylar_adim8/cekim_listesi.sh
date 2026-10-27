#!/usr/bin/env bash
# Olaylar 7b kanıt kareleri + sayfadaki çipi değişen 11 kartın yeniden çekimi (pencereli, ekran kilidi c7c_win.sh içinde, sırayla).
# Çıktı: groups/c7c/shots/<kart>/{A,B}_{tr,en}.{png,log} ve groups/c7c/extra/<ad>_<dil>.{png,log}
S=/c/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/eeffbe9c-d5c1-4a8e-8ce4-9e4b60603345/scratchpad
cd $S
w() { bash tools/c7c_win.sh "$1" "$2" "$3" "$4" > /dev/null 2>&1; echo "$(date +%H:%M:%S) $4/$3_$2 $([ -f groups/c7c/$4/$3_$2.png ] && echo ok || echo YOK)"; }
pair() { # card A-spec B-spec
  for l in tr en; do w "$2" $l A shots/$1; done
  [ -n "$3" ] && for l in tr en; do w "$3" $l B shots/$1; done
}
# kanıt
# sayfa
pair world.data_location world.data_location world.data_location:customer=co_kuzey:long=1
pair team.rude_client team.rude_client team.rude_client:employee=char_emp_shot_1:long=1
pair team.promise_made team.promise_made team.promise_made:employee=char_emp_shot_1:long=1
pair customer.training_request customer.training_request customer.training_request:customer=co_kuzey:rep=char_emp_shot_4:long=1
pair customer.own_data_error customer.own_data_error customer.own_data_error:long=1
pair customer.finance_team customer.finance_team customer.finance_team:customer=co_kuzey:rep=char_emp_shot_4:long=1
pair product.sprint_test_rival_batch product.sprint_test_rival_batch product.sprint_test_rival_batch:employee=char_emp_shot_1:acct_1=co_kuzey:acct_2=co_ege_metal:acct_3=co_marmara:long=1
pair product.encryption_flaw_b2b product.encryption_flaw_b2b product.encryption_flaw_b2b:long=1
pair product.sprint_pm_hospital product.sprint_pm_hospital product.sprint_pm_hospital:employee=char_emp_shot_1:customer=co_ege_metal:dev=char_emp_shot_4:long=1
echo done > groups/c7c/shots_done.txt
