#!/bin/bash
# D0s kosu zinciri: her adim kendi butcesinde biter ve eksik is kalirsa yeniden calisir (onbellek).
cd "$(dirname "$0")"
unset D3_NSEEDS
runb() {   # runb <etiket> <grup[,grup]> [ortam degiskenleri...]
  local tag=$1 grp=$2; shift 2
  local out
  while true; do
    out=$(env "$@" python -I dsim3.py exec dbatch.py "$tag" "$grp" 470 2>&1)
    echo "$out" | tail -3
    echo "$out" | grep -q "KALDI" || break
  done
}
R="D3_KEYMODE=plan D3_SHIELD=0 D3_PMRULE=karar4h"
step=$1
case "$step" in
  main)
    for g in A SK S E D B F G R I PR DEP HUY UF PMC; do runb R $g $R; done ;;
  curve)  runb R C $R ;;
  rep)    runb R REP $R ;;
  pm)
    runb R PM3 $R
    runb R_pm4w PM3,PMC $R D3_PMRULE=karar4
    runb R_pmbest PM3,PMC $R D3_PMRULE=best
    runb R_pmpreparer PM3,PMC $R D3_PMRULE=preparer ;;
  arms)
    runb R_asgsprint S,SK $R D3_ASSIGN=sprint
    runb R_nopull S,SK $R D3_PULL=0
    runb R_early S,SK $R D3_EARLY=1
    runb R_slice40 S,SK $R D3_SLICE=40
    runb R_size S,SK D3_KEYMODE=size D3_SHIELD=0 D3_PMRULE=karar4
    runb R_pf1 PR $R D3_PROMISEFIRST=1
    runb R_size_pf0 PR D3_KEYMODE=size D3_SHIELD=0 D3_PMRULE=karar4
    runb R_size_pf1 PR D3_KEYMODE=size D3_SHIELD=0 D3_PMRULE=karar4 D3_PROMISEFIRST=1
    runb R_tf0 TST $R D3_TESTERFIX=0
    runb R_tfm TST $R D3_TESTERFIX=-1
    runb R_tf1 TST $R
    runb R_unfit0 UF $R D3_UNFITCOND=0 ;;
  repro)   # PRD'nin "-2,5" adimi: eski oynatma, hazirlayanin yildizi (prototipin ayari: duzeltme karti en az 5, eski derinlik sabitleri)
    runb L_pmpreparer PM3 D3_LEGACY=1 D3_PMRULE=preparer D3_FIXMIN=5 D3_DEPTHMAX=4 D3_DEPTHDIV=10 D3_FILLSKIP=0
    runb L_pmbest PM3 D3_LEGACY=1 D3_PMRULE=best D3_FIXMIN=5 D3_DEPTHMAX=4 D3_DEPTHDIV=10 D3_FILLSKIP=0 ;;
  shield)
    runb P S,SK
    runb R_shield S,SK $R D3_SHIELD=1 ;;
  legacy)
    runb L A,SK,S,G D3_LEGACY=1
    runb L PMC D3_LEGACY=1 ;;
  final)   # tek kart kipinde cekme kapali (S12), kurucu satiri varyanti, R_shield S
    runb R A $R
    runb R_frow E,S $R D3_FOUNDERROW=1
    runb R_shield S $R D3_SHIELD=1 ;;
esac
