#!/usr/bin/env bash
# Birleşik ağaçta kod haritasını yeniden üretir (ORTAK_CALISMA §3 adım 3). Usage: regen.sh <etiket>
. "$(dirname "$0")/env.sh"
M="$S/m_$1/project-unicorn"
( cd "$M" && GIT_DIR="$R/.git" PYTHONIOENCODING=utf-8 python -I tools/kod_haritasi/uret.py ) || { echo "REGEN FAIL"; exit 3; }
echo "regen ok: $M/docs/kod_haritasi"
