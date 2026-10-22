#!/bin/bash
# A8 "kalir" kuralinin bedeli: T_plan'in kalir kapali hali (tani), P_np ile birlikte okunur. run_a8e.sh bitince baslar. En cok 2 isci.
cd "$(dirname "$0")"
while [ ! -f out8/run_a8e.done ]; do sleep 20; done
SMALL="S2,S3,S4,PR|S2,PR|S3,PR|S4"
echo "H7 T_plan_np" ; bash chain8.sh ana H T_plan_np "$SMALL" 20
echo FINISHED > out8/run_a8f.done
