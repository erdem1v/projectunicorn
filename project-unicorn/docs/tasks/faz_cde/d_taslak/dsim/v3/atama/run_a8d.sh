#!/bin/bash
# A8 ek ablasyon: ileri oynatmasiz P (P_sabit) tum hucrelerde (hafif kip: plan ekraninda her "+" tiklamasinda tek oynatma), ilke yer degisimi yok (P_ns) buyuk ekiplerde. run_a8c.sh bitince baslar. En cok 2 isci.
cd "$(dirname "$0")"
while [ ! -f out8/run_a8c.done ]; do sleep 20; done
ALL="S1,S2,S3,S4,S5,S6,PR|S1,PR|S2,PR|S3,PR|S4,PR|S5,PR|S6"
echo "H4 P_sabit tum hucreler" ; bash chain8.sh ana H P_sabit "$ALL" 20
echo "H5 P_ns buyuk ekipler" ; bash chain8.sh ana H P_ns "S5,S6,PR|S5,PR|S6" 20
echo FINISHED > out8/run_a8d.done
