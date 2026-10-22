#!/bin/bash
cd "/c/Users/erdem/Desktop/Project Unicorn/project-unicorn/docs/tasks/faz_cde/d_taslak/dsim/v3"
unset D3_NSEEDS
runb() { local tag=$1 grp=$2; shift 2; local out
  while true; do out=$(env "$@" python -I dsim3.py exec dbatch.py "$tag" "$grp" 470 2>&1); echo "$out" | tail -2; echo "$out" | grep -q "KALDI" || break; done; }
R="D3_KEYMODE=plan D3_SHIELD=0 D3_PMRULE=karar4h"
case "$1" in
  main) for g in S G R PR DEP; do runb R5 $g $R; done ;;
  arms)
    runb R5_asgsprint SK $R D3_ASSIGN=sprint
    runb R5_nopull SK $R D3_PULL=0
    runb R5_early SK $R D3_EARLY=1
    runb R5_slice40 SK $R D3_SLICE=40
    runb R5_size SK D3_KEYMODE=size D3_SHIELD=0 D3_PMRULE=karar4
    runb R5_pf1 PR $R D3_PROMISEFIRST=1
    runb R5_size_pf0 PR D3_KEYMODE=size D3_SHIELD=0 D3_PMRULE=karar4
    runb R5_size_pf1 PR D3_KEYMODE=size D3_SHIELD=0 D3_PMRULE=karar4 D3_PROMISEFIRST=1 ;;
esac
echo DONE $1
