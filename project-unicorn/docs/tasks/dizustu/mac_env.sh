# Dizüstü (Mac, M1, 8 GB) ortak değişkenleri ve Godot koşucusu. Kullanım:
#   S=<oturumun scratchpad'i>; ETIKET=URUN_ARAYUZU   # ya da OLAYLAR; ayrı satırda, öne ek olarak değil
#   . "<repo>/project-unicorn/docs/tasks/dizustu/mac_env.sh"
# Windows'taki APPDATA yalıtımının karşılığı HOME'dur: her Godot süreci kendi HOME'unu alır ve user:// oraya iner
# (<HOME>/Library/Application Support/Godot/app_userdata/Project Unicorn/). Erdem'in gerçek HOME'una hiçbir koşu yazmaz.
: "${S:?S (scratchpad) yok}" "${ETIKET:?ETIKET yok}"
R="/Users/tugbauysal/Desktop/project steam/Project Unicorn"
K="/Users/tugbauysal/Desktop/project steam/.kilit"
GODOT=/Users/tugbauysal/Downloads/Godot.app/Contents/MacOS/Godot
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"   # smoke_run.sh GNU timeout ister
GODOT_MAX=2      # makinede aynı anda en çok bu kadar Godot süreci (iki oturum + MCP editörü dahil)
FREE_MIN_MB=1500

free_mb() {
  vm_stat | awk '/page size of/ {ps=$8} /Pages (free|inactive|speculative)/ {gsub("\\.","",$NF); p+=$NF} END {print int(p*ps/1048576)}'
}
mem_ok() { local f; f=$(free_mb); [ "${f:-0}" -ge "$FREE_MIN_MB" ] || { echo "STOP free=${f}MB < ${FREE_MIN_MB}"; return 1; }; }
godots() { pgrep -f "$GODOT" | wc -l | tr -d ' '; }
lock_take() { mkdir -p "$K" && mkdir "$K/$1" 2>/dev/null && echo "$ETIKET $2 $(date +%FT%T) pid=$$" > "$K/$1/sahip"; }
lock_drop() { rm "$K/$1/sahip" && rmdir "$K/$1"; }
# Bir koşunun user:// klasörü: udir <ad>
udir() { echo "$S/home_$1/Library/Application Support/Godot/app_userdata/Project Unicorn"; }
# Godot koşusu: gd <ad> <ağaç/project-unicorn> <args...>
# 99 sessiz kilidi başkasında, 98 bellek az, 97 makinede GODOT_MAX süreç koşuyor; üçünde de bekle ve yeniden dene.
gd() {
  local ad="$1" tree="$2"; shift 2
  if [ -d "$K/sessiz" ] && ! grep -q "^$ETIKET" "$K/sessiz/sahip" 2>/dev/null; then echo "WAIT sessiz: $(cat "$K/sessiz/sahip" 2>/dev/null)"; return 99; fi
  mem_ok || return 98
  [ "$(godots)" -lt "$GODOT_MAX" ] || { echo "WAIT godot=$(godots)"; return 97; }
  mkdir -p "$S/home_$ad"
  ( cd "$tree" && HOME="$S/home_$ad" "$GODOT" "$@" )
}
# Bekleyen sürüm: 97/98/99'da 20 saniyede bir yeniden dener (xargs işçileri ve betikler bunu kullanır; Godot'yu doğrudan
# başlatan her betik satırı gdw'ye çevrilir). Godot'nun kendi çıkış kodu aynen döner.
gdw() {
  local rc
  while :; do gd "$@"; rc=$?; case $rc in 97|98|99) sleep 20 ;; *) return $rc ;; esac; done
}
# MCP'nin bağlandığı oyun sunucusu 127.0.0.1:7777'yi ilk açan Godot sürecine aittir (addons/godot_mcp_runtime).
port7777() { lsof -nP -iTCP:7777 -sTCP:LISTEN 2>/dev/null | awk 'NR>1 {print $1, $2}'; }
export S ETIKET R K GODOT GODOT_MAX FREE_MIN_MB
# Bash'te işlevler alt kabuklara (xargs işçileri) geçer; zsh'te (Claude'un Bash aracı) geçmez, orada yalnız bu kabukta.
[ -n "$BASH_VERSION" ] && export -f free_mb mem_ok godots lock_take lock_drop udir gd gdw port7777
