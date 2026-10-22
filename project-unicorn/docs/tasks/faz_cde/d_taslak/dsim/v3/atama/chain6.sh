#!/bin/bash
# A6 zinciri: her python cagrisi butceli (varsayilan 420 sn), eksik is kalirsa yeniden calisir (onbellek). python -I, en cok 2 isci.
#   bash chain6.sh <etiket> <kalibrasyon> <kollar> <senaryolar> [tohum]
cd "$(dirname "$0")"
TAG=$1; CAL=$2; ARMS=$3; SCENS=$4; NS=${5:-20}; BUD=${A6_BUDGET:-420}
while true; do
  out=$(python -I a6run.py run "$TAG" "$ARMS" "$SCENS" "$CAL" "$BUD" "$NS" 2>&1)
  echo "$out" | tail -3
  echo "$out" | grep -q "KALDI" || break
done
