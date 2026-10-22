#!/bin/bash
# A8 plan puani duyarliligi: plan sirasi agirligi rho = 1,0 (her kart esit), 0,85; ana kol 0,5. run_a8d.sh bitince baslar. En cok 2 isci.
cd "$(dirname "$0")"
while [ ! -f out8/run_a8d.done ]; do sleep 20; done
SMALL="S2,S3,S4,PR|S2,PR|S3,PR|S4"
echo "H6 rho duyarliligi" ; bash chain8.sh ana H P_r1,P_r85 "$SMALL" 20
echo FINISHED > out8/run_a8e.done
