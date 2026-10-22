#!/bin/bash
# A3 altinci grup: PM kapisi (sprintteki hazirliksiz kartlar plan sirasiyla hazirlanir). run_rest5.sh bitince baslar.
cd "$(dirname "$0")"
while [ ! -f out/chain_rest5.done ]; do sleep 20; done
bash chain.sh main R_gate,E_gate S1,S2,S3,S4,S5,S6,S4_1PM,S5_1PM,S6_2PM 20 > out/chain_gate2.log 2>&1
echo FINISHED > out/chain_rest6.done
