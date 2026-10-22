#!/bin/bash
# A6 tani kolu T_plan (tarif degil): run_a6.sh bitince baslar. En cok 2 isci.
cd "$(dirname "$0")"
while [ ! -f out6/run_a6.done ]; do sleep 20; done
ALL="S1,S2,S3,S4,S5,S6,PR|S1,PR|S2,PR|S3,PR|S4,PR|S5,PR|S6"
echo "G5 tani kolu T_plan (K-H)" ; bash chain6.sh ana H T_plan "$ALL" 20
echo FINISHED > out6/run_a6b.done
