#!/bin/bash
# G3 (K-E) run_a6.sh'den kaldi; G4 (bugunku model) yalniz R ve T kollariyla (BK referansi atlandi). G3 bitince baslar.
cd "$(dirname "$0")"
while ! awk '/^G3/{f=1} f&&/^TAMAM/{ok=1} END{exit !ok}' out6/run_a6.log; do sleep 20; done
ALL="S1,S2,S3,S4,S5,S6,PR|S1,PR|S2,PR|S3,PR|S4,PR|S5,PR|S6"
echo "G4 bugunku model (R,T)" ; bash chain6.sh ana 0 R,T "$ALL" 20
echo FINISHED > out6/run_a6.done
