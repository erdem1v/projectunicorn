#!/bin/bash
# A3 zinciri: her cagri butceli (varsayilan 420 sn), eksik is kalirsa yeniden calisir (onbellek). python -I, en cok 2 isci.
#   bash chain.sh <etiket> <kollar> <senaryolar> [tohum]       (L kolu icin ortam: D3_LEGACY=1 bash chain.sh ...)
cd "$(dirname "$0")"
TAG=$1; ARMS=$2; SCENS=$3; NS=${4:-20}; BUD=${A3_BUDGET:-420}
while true; do
  out=$(python -I a3run.py run "$TAG" "$ARMS" "$SCENS" "$BUD" "$NS" 2>&1)
  echo "$out" | tail -3
  echo "$out" | grep -q "KALDI" || break
done
