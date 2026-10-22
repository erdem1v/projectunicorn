#!/bin/bash
# A3 besinci grup: ustalik aramasi (sprint ici net is olcusuyle). run_rest4.sh bitince baslar.
cd "$(dirname "$0")"
while [ ! -f out/chain_rest4.done ]; do sleep 20; done
bash chain.sh usta R,E,USTA S1,S2,S3,S4 20 > out/chain_usta.log 2>&1
bash chain.sh usta R,E,USTA S5 8 >> out/chain_usta.log 2>&1
bash chain.sh usta R,E,USTA S6 4 >> out/chain_usta.log 2>&1
echo FINISHED > out/chain_rest5.done
