#!/bin/bash
# A6 duyarlilik: gereksinim kuvveti p = 0 ve 2 (c her biri icin hacim-notr kalibre). run_a6b.sh bitince baslar. En cok 2 isci.
cd "$(dirname "$0")"
while [ ! -f out6/run_a6b.done ]; do sleep 20; done
SC="S2,S3,S4,S6,PR|S2,PR|S3"
echo "G6 p=0" ; bash chain6.sh duy 0.297@0 R,T,BK,T_plan "$SC" 20
echo "G7 p=2" ; bash chain6.sh duy 0.137@2 R,T,BK,T_plan "$SC" 20
echo FINISHED > out6/run_a6c.done
