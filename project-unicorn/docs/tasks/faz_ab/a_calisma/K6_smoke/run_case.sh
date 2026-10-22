#!/usr/bin/env bash
c="$1"
cd "C:/Users/erdem/Desktop/Project Unicorn/project-unicorn" || exit 1
d="C:/Users/erdem/AppData/Local/Temp/fazA/K6_case_$c"
mkdir -p "/c/Users/erdem/AppData/Local/Temp/fazA/K6_case_$c"
log="docs/tasks/faz_ab/a_calisma/K6_smoke/$c.log"
CASE_TIMEOUT=300 APPDATA="C:\Users\erdem\AppData\Local\Temp\fazA\K6_case_$c" HOME="C:\Users\erdem\AppData\Local\Temp\fazA\K6_case_$c" bash tools/smoke_run.sh "$c" > "$log" 2>&1
rc=$?
echo "$c rc=$rc $(grep -ao 'SMOKE \(PASS\|FAIL\)[^\r]*' "$log" | head -1)"
