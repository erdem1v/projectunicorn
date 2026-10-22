#!/bin/bash
# A6 ana olcum: hata modeli yeni (K-H ana, K-E yan) ve bugunku modelle referans. En cok 2 isci.
cd "$(dirname "$0")"
ALL="S1,S2,S3,S4,S5,S6,PR|S1,PR|S2,PR|S3,PR|S4,PR|S5,PR|S6"
PM="S3,S4,S5,S6,PR|S3,PR|S4,PR|S5,PR|S6"
mkdir -p out6
echo "G1 K-H ana kollar" ; bash chain6.sh ana H R,T,BK "$ALL" 20
echo "G2 K-H PM kollari" ; bash chain6.sh ana H T_zor,T_d,T_zord,E "$PM" 20
echo "G3 K-E yan"        ; bash chain6.sh ana E R,T,BK "$ALL" 20
echo "G4 bugunku model"  ; bash chain6.sh ana 0 R,T,BK "$ALL" 20
echo FINISHED > out6/run_a6.done
