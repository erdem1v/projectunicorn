#!/usr/bin/env bash
# shots_d4.sh <tree> <outdir>: D4's own frames: the toast through its real callers (1080, 1.25,
# 16:10 and 21:9), the kit page (standard and colour-blind), the ending's share and the dark confirm.
D="C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/0e406678-a661-4d23-90af-2e43deb375cc/scratchpad/d4"
TREE="$1"; OUT="$2"
for lang in tr en; do
  "$D/shot.sh" "$TREE" "$OUT/toast/1920x1080" toast $lang --office-shot=ishani:11:toast
  "$D/shot.sh" "$TREE" "$OUT/toast/1536x864" toast $lang --office-shot=ishani:11:toast --shot-scale=1.25
  "$D/shot.sh" "$TREE" "$OUT/toast/2560x1080" toast $lang --office-shot=ishani:11:toast --shot-size=2560x1080
  "$D/shot.sh" "$TREE" "$OUT/kit" kit $lang --probe-shot=kit
  "$D/shot_cb.sh" "$TREE" "$OUT/kit_cb" kit $lang --probe-shot=kit
  "$D/shot.sh" "$TREE" "$OUT/ending" share $lang --ending-shot=series_a_close
  "$D/shot.sh" "$TREE" "$OUT/confirm_dark" confirm_dark $lang --modal-shot=confirm_dark
done
