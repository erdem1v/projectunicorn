#!/usr/bin/env bash
# Makinenin toplam işlemci yükü, süre ölçümünün önünde ve arkasında kayda girsin diye (sessiz kilidi yalnız Godot
# süreçlerine bakar; başka bir oyun ya da test koşusu ölçümü kirletir). Tek satır basar:
#   CPU <ortalama>% (<n> örnek) · en çok: <süreç> <pay>%, … · Godot dışı <toplam>% · <TEMİZ|KİRLİ>
# Godot dışı süreçlerin toplam payı CPU_DIRTY'yi (varsayılan 10, makinenin tamamının yüzdesi) aşarsa KİRLİ; çıkış 0
# temiz, 1 kirli, 2 okunamadı. Ölçümün kendi süreçleri (powershell, WmiPrvSE) sayılmaz. Usage: cpu_load.sh [örnek sayısı, varsayılan 5]
n="${1:-5}"; dirty="${CPU_DIRTY:-10}"
out=$(powershell -NoProfile -Command "
\$cores = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
\$tot = @(); \$procs = @{}
for (\$i = 0; \$i -lt $n; \$i++) {
  \$tot += (Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -Filter \"Name='_Total'\").PercentProcessorTime
  Get-CimInstance Win32_PerfFormattedData_PerfProc_Process | Where-Object { \$_.Name -notin @('_Total','Idle') -and \$_.Name -notmatch '^(powershell|WmiPrvSE)' } |
    ForEach-Object { \$k = (\$_.Name -replace '#\d+\$',''); \$procs[\$k] = [double](\$procs[\$k]) + \$_.PercentProcessorTime / \$cores }
  Start-Sleep -Milliseconds 500
}
\$avg = [math]::Round(((\$tot | Measure-Object -Average).Average), 0)
\$top = \$procs.GetEnumerator() | ForEach-Object { [pscustomobject]@{ n = \$_.Key; v = \$_.Value / $n } } |
  Sort-Object v -Descending
\$other = [math]::Round(((\$top | Where-Object { \$_.n -notlike 'Godot*' } | Measure-Object v -Sum).Sum), 0)
\$list = (\$top | Select-Object -First 4 | ForEach-Object { '{0} {1}%' -f \$_.n, [math]::Round(\$_.v, 0) }) -join ', '
Write-Output (\"{0}|{1}|{2}\" -f \$avg, \$list, \$other)
" 2>/dev/null | tr -d '\r' | tail -1)
[ -n "$out" ] || { echo "CPU okunamadı"; exit 2; }
IFS='|' read -r avg list other <<<"$out"
state=TEMİZ; rc=0
[ "${other:-0}" -gt "$dirty" ] && { state=KİRLİ; rc=1; }
echo "CPU ${avg}% ($n örnek) · en çok: $list · Godot dışı ${other}% · $state"
exit $rc
