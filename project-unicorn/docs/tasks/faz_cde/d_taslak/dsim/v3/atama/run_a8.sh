#!/bin/bash
# A8 ana olcum (K-H): P kolu 12 hucrede 20 tohum; R, T, T_plan A6'nin kayitlarindan (out6/ana/H) okunur. En cok 2 isci.
cd "$(dirname "$0")"
ALL="S1,S2,S3,S4,S5,S6,PR|S1,PR|S2,PR|S3,PR|S4,PR|S5,PR|S6"
SMALL="S2,S3,S4,PR|S2,PR|S3,PR|S4"
mkdir -p out8
echo "H1 P ana" ; bash chain8.sh ana H P "$ALL" 20
echo FINISHED > out8/run_a8.done
echo "H2 ablasyon (arama yok / saklama yok / ilke yok / kalir yok)" ; bash chain8.sh ana H P_sabit,P_core5,P_ns,P_np "$SMALL" 20
echo FINISHED > out8/run_a8b.done
echo "H3 gereksinim kapisi yok (ilkenin teslim bedeli)" ; bash chain8.sh ana H P_gyok "S4,S5,PR|S4" 20
echo FINISHED > out8/run_a8c.done
