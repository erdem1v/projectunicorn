#!/usr/bin/env bash
# audit_all.sh <tree> <outdir>: every surface the D audits cover, one windowed run at a time.
D="C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/0e406678-a661-4d23-90af-2e43deb375cc/scratchpad/d4"
bash "$D/audit.sh" "$1" "$2" events finance hr marketing personal product rnd sales \
  modal:confirm modal:confirm3 modal:mentor modal:month modal:rnd-discovery-line modal:rnd-discovery \
  modal:rnd-note modal:saveload modal:settings modal:system onboard:0 onboard:1 onboard:2 onboard:3 \
  probe probe_menajer
