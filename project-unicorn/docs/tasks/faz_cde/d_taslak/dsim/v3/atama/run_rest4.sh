#!/bin/bash
# A3 dorduncu grup: gereksinim yok karsilastirmasi. run_rest3.sh bitince baslar.
cd "$(dirname "$0")"
while [ ! -f out/chain_rest3.done ]; do sleep 20; done
bash chain.sh main E_gyok S1,S2,S3,S4,S5,S6 20 > out/chain_gyok.log 2>&1
echo FINISHED > out/chain_rest4.done
