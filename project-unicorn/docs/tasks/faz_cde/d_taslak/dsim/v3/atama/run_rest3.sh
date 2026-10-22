#!/bin/bash
# A3 ucuncu grup: PM'i az ekiplerde PM kapisi. run_rest2.sh bitince baslar.
cd "$(dirname "$0")"
while [ ! -f out/chain_rest2.done ]; do sleep 20; done
bash chain.sh main R,R_gate,E,E_gate S4_1PM,S5_1PM,S6_2PM 20 > out/chain_pmpoor.log 2>&1
echo FINISHED > out/chain_rest3.done
