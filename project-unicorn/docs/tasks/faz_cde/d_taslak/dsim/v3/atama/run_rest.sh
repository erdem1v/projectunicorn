#!/bin/bash
# A3 geri kalan kosular: ana zincirin bitmesini bekler, sonra sirayla (en cok 2 isci).
cd "$(dirname "$0")"
while ! grep -q FINISHED out/chain_main.log 2>/dev/null; do sleep 20; done
bash chain.sh pr R,E PR\|S1,PR\|S2,PR\|S3,PR\|S4,PR\|S5,PR\|S6 20 > out/chain_pr.log 2>&1
D3_LEGACY=1 bash chain.sh pr L PR\|S1,PR\|S2,PR\|S3,PR\|S4,PR\|S5,PR\|S6 20 >> out/chain_pr.log 2>&1
bash chain.sh main R_uyari,E_uyari,R_uyari2,E_uyari2 S2,S3,S4,S5,S6 20 > out/chain_uyari.log 2>&1
bash chain.sh dep R,E DEP\|S3,DEP\|S4,DEP\|S5 20 > out/chain_dep.log 2>&1
D3_LEGACY=1 bash chain.sh dep L DEP\|S3,DEP\|S4,DEP\|S5 20 >> out/chain_dep.log 2>&1
echo FINISHED > out/chain_rest1.done
