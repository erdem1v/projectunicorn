# Ortak değişkenler: . env.sh   (kopyalayan oturum S'yi ve ETIKET'i kendine göre yazar)
ETIKET=URUN_ARAYUZU
S=/c/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/cb69ca60-0d91-4669-bf47-f4c28dfeaca0/scratchpad
R="/c/Users/erdem/Desktop/Project Unicorn"
K=/c/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/kilit
GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe
export APPDATA='C:\Users\erdem\AppData\Local\Temp\claude\C--Users-erdem-Desktop-Project-Unicorn\cb69ca60-0d91-4669-bf47-f4c28dfeaca0\scratchpad\appdata'
UDIR="$S/appdata/Godot/app_userdata/Project Unicorn"
free_mb() { powershell -NoProfile -c '[int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1024)' | tr -d '\r'; }
mem_ok() { local f; f=$(free_mb); [ "${f:-0}" -ge 2000 ] || { echo "STOP free=${f}MB < 2000"; return 1; }; }
lock_take() { mkdir -p "$K" && mkdir "$K/$1" 2>/dev/null && echo "$ETIKET $2 $(date +%FT%T) pid=$$" > "$K/$1/sahip"; }
# Kilit yalnız sahibi bu oturum (ETIKET) ve bu süreçse (pid) bırakılır; başkasınınki silinmez, uyarı basılır. Aynı oturumun
# başka bir sürecinin aldığı kilit (ör. ayrı komutta alınıp elle bırakılan) yalnız ikinci argüman "zorla" ile bırakılır.
lock_drop() {
  local f="$K/$1/sahip" o
  o=$(cat "$f" 2>/dev/null) || { echo "lock_drop: $1 kilidi yok"; return 1; }
  case "$o" in
    "$ETIKET "*" pid=$$") ;;
    "$ETIKET "*) [ "${2:-}" = zorla ] || { echo "lock_drop: $1 bu oturumun ama başka bir sürecin ($o); bırakmak için: lock_drop $1 zorla"; return 1; } ;;
    *) echo "UYARI lock_drop: $1 kilidi başkasında ($o), dokunulmadı"; return 1 ;;
  esac
  rm "$f" && rmdir "$K/$1"
}
# Godot koşusu: gd <appdata adı> <ağaç/project-unicorn> <args...>; sessiz kilidi başkasındaysa ya da bellek azsa koşmaz.
gd() {
  local ad="$1" tree="$2"; shift 2
  if [ -d "$K/sessiz" ] && ! grep -q "^$ETIKET" "$K/sessiz/sahip" 2>/dev/null; then echo "WAIT sessiz: $(cat "$K/sessiz/sahip" 2>/dev/null)"; return 99; fi
  mem_ok || return 98
  mkdir -p "$S/appdata_$ad"
  ( cd "$tree" && APPDATA="$(cygpath -w "$S/appdata_$ad")" "$GODOT" "$@" )
}
