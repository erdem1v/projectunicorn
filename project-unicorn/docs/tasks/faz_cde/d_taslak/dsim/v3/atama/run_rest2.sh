#!/bin/bash
# A3 ikinci grup: ustalik aramasi, kalite aciklamasi, uymayan is. run_rest.sh bitince baslar (en cok 2 isci).
cd "$(dirname "$0")"
while [ ! -f out/chain_rest1.done ]; do sleep 20; done
bash chain.sh kal R,E S3,S4,S5,S6 20 > out/chain_kal.log 2>&1
bash chain.sh main R,E S3_PM_testkutulu 20 > out/chain_unfit.log 2>&1
bash chain.sh usta R,E,USTA S1,S2,S3,S4 20 > out/chain_usta.log 2>&1
bash chain.sh usta R,E,USTA S5 8 >> out/chain_usta.log 2>&1
bash chain.sh usta R,E,USTA S6 4 >> out/chain_usta.log 2>&1
echo FINISHED > out/chain_rest2.done
