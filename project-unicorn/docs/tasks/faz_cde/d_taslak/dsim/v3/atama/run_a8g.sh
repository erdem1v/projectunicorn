#!/bin/bash
# A8 ek ablasyon (satir secimi ve yer degisimi): P_ns (ileri oynatma yok, yer degisimi yok; satir secimi ihtiyaca gore) ve P_rp (tam P, satir secimi eski kuralla). En cok 2 isci.
cd "$(dirname "$0")"
SMALL="S2,S3,S4,PR|S2,PR|S3,PR|S4"
echo "H8 P_ns" ; bash chain8.sh ana H P_ns "$SMALL,S5,S6,PR|S5,PR|S6" 20
echo "H9 P_rp" ; bash chain8.sh ana H P_rp "$SMALL,S5,S6" 20
echo FINISHED > out8/run_a8g.done
