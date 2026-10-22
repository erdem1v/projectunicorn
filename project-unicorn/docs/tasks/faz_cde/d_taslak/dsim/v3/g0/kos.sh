#!/bin/bash
# D0t.2 sim zinciri: her cagri 420 sn butceli, eksik is kalirsa yeniden calisir (onbellek). Tum cagrilar python -I, en cok 2 isci.
cd "$(dirname "$0")"
V="orig,map,cut2:0.125,cut2:0.25,cut2:0.5,cut3:0.125,cut3:0.25,cut3:0.5,ser:8,ser:9,ser:11,ser:17"
while true; do
  out=$(python -I sim_g0.py main "$V" S1,S2,S3,S4,S5,S6 420 2>&1)
  echo "$out" | tail -3
  echo "$out" | grep -q "KALDI" || break
done
