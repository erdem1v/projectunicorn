#!/bin/bash
# A3 yedinci grup: ustalik, teslim agirlikli olcu. run_rest6.sh bitince baslar.
cd "$(dirname "$0")"
while [ ! -f out/chain_rest6.done ]; do sleep 20; done
bash chain.sh usta USTA1 S1,S2,S3,S4 20 > out/chain_usta1.log 2>&1
bash chain.sh usta USTA1 S5 8 >> out/chain_usta1.log 2>&1
bash chain.sh usta USTA1 S6 4 >> out/chain_usta1.log 2>&1
echo FINISHED > out/chain_rest7.done
