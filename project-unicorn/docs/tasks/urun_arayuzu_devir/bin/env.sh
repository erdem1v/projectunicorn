# Ortak değişkenler: . env.sh
S=/c/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/cb69ca60-0d91-4669-bf47-f4c28dfeaca0/scratchpad
R="/c/Users/erdem/Desktop/Project Unicorn"
K=/c/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/kilit
GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe
export APPDATA='C:\Users\erdem\AppData\Local\Temp\claude\C--Users-erdem-Desktop-Project-Unicorn\cb69ca60-0d91-4669-bf47-f4c28dfeaca0\scratchpad\appdata'
UDIR="$S/appdata/Godot/app_userdata/Project Unicorn"
free_mb() { powershell -NoProfile -c '[int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1024)' | tr -d '\r'; }
mem_ok() { local f; f=$(free_mb); [ "${f:-0}" -ge 2000 ] || { echo "STOP free=${f}MB < 2000"; return 1; }; }
lock_take() { mkdir -p "$K" && mkdir "$K/$1" 2>/dev/null && echo "URUN_ARAYUZU $2 $(date +%FT%T) pid=$$" > "$K/$1/sahip"; }
lock_drop() { rm "$K/$1/sahip" && rmdir "$K/$1"; }
# Godot koşusu: gd <appdata adı> <ağaç/project-unicorn> <args...>; sessiz kilidi başkasındaysa ya da bellek azsa koşmaz.
gd() {
  local ad="$1" tree="$2"; shift 2
  if [ -d "$K/sessiz" ] && ! grep -q '^URUN_ARAYUZU' "$K/sessiz/sahip" 2>/dev/null; then echo "WAIT sessiz: $(cat "$K/sessiz/sahip" 2>/dev/null)"; return 99; fi
  mem_ok || return 98
  mkdir -p "$S/appdata_$ad"
  ( cd "$tree" && APPDATA="$(cygpath -w "$S/appdata_$ad")" "$GODOT" "$@" )
}
