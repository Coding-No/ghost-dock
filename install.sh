#!/usr/bin/env bash
# ============================================================
#  ghost-dock — dock GNOME tanpa background + animasi genie Mac
#  Author: LALA
#  Pakai : git clone ... && ./install.sh
# ============================================================
set -euo pipefail

ICON_SIZE="${ICON_SIZE:-36}"          # override: ICON_SIZE=48 ./install.sh
SKIP_RESTART="${SKIP_RESTART:-0}"
DTD='dash-to-dock@micxgx.gmail.com'
ML='compiz-alike-magic-lamp-effect@hermes83.github.com'
UB='ubuntu-dock@ubuntu.com'
EXT_DIR="$HOME/.local/share/gnome-shell/extensions"
HERE="$(cd "$(dirname "$0")" && pwd)"
UA='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36'
MARK='===== LALA: DOCK TANPA BACKGROUND'

log()  { printf '\033[1;32m[ghost-dock]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[ghost-dock]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[ghost-dock]\033[0m %s\n' "$*" >&2; exit 1; }

# --- 0. cek lingkungan ---------------------------------------------------
command -v gnome-shell >/dev/null 2>&1 || die "GNOME Shell gak ketemu. Ini khusus GNOME (Ubuntu 24.04 / Fedora / Debian desktop)."
command -v curl unzip python3 dconf gsettings >/dev/null 2>&1 || die "butuh curl unzip python3 dconf — sudo apt install curl unzip"
SHELL_VER="$(gnome-shell --version | grep -oE '[0-9]+' | head -1)"
[ "${SHELL_VER:-0}" -ge 45 ] 2>/dev/null || die "GNOME Shell ${SHELL_VER:-?} — butuh 45 ke atas."
log "GNOME Shell $SHELL_VER terdeteksi."

# --- 1. pasang ekstensi resmi dari extensions.gnome.org ------------------
pasang_ext() {
  local uuid="$1" dest="$EXT_DIR/$1" json url tmp
  if [ -f "$dest/metadata.json" ]; then log "$uuid udah ada ✓"; return 0; fi
  log "download $uuid ..."
  json="$(curl -fsS -A "$UA" "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$SHELL_VER" 2>/dev/null \
       || curl -fsS -A "$UA" "https://extensions.gnome.org/extension-info/?uuid=$uuid")" \
    || die "info $uuid gagal — cek koneksi ke extensions.gnome.org"
  url="$(printf '%s' "$json" | python3 -c 'import sys,json; print(json.load(sys.stdin)["download_url"])')"
  tmp="$(mktemp /tmp/ghost-dock.XXXXXX.zip)"
  curl -fsSL -A "$UA" "https://extensions.gnome.org$url" -o "$tmp" || die "download zip $uuid gagal"
  mkdir -p "$dest"
  unzip -oq "$tmp" -d "$dest" || die "unzip $uuid gagal"
  rm -f "$tmp"
  [ -d "$dest/schemas" ] && glib-compile-schemas "$dest/schemas/" 2>/dev/null || true
  log "$uuid kepasang ✓"
}
pasang_ext "$DTD"
pasang_ext "$ML"

# --- 2. patch CSS: buang background total (idempoten) --------------------
CSS="$EXT_DIR/$DTD/stylesheet.css"
if grep -qF "$MARK" "$CSS" 2>/dev/null; then
  log "patch CSS udah nyangkut."
else
  [ -f "$CSS" ] && cp -n "$CSS" "$CSS.bak-ghostdock" 2>/dev/null || true
  printf '\n/* %s ===== */\n' "$MARK" >> "$CSS"
  cat "$HERE/ghost-dock.css" >> "$CSS"
  log "patch CSS dock tanpa background ✓"
fi

# --- 3. setelan dock (dconf) + ukuran ikon -------------------------------
dconf load /org/gnome/shell/extensions/dash-to-dock/ < "$HERE/settings.dconf"
dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size "$ICON_SIZE"
log "setelan dock ke-load — transparan FIXED alpha 0.0, ikon $ICON_SIZE ✓"

# --- 4. animasi genie Mac (magic lamp): 250ms, tile 6x35 -----------------
ML_SCHEMA='org.gnome.shell.extensions.com.github.hermes83.compiz-alike-magic-lamp-effect'
if [ -d "$EXT_DIR/$ML/schemas" ]; then
  gsettings --schemadir "$EXT_DIR/$ML/schemas" set "$ML_SCHEMA" effect "'default'" 2>/dev/null || true
  gsettings --schemadir "$EXT_DIR/$ML/schemas" set "$ML_SCHEMA" duration '250.0' 2>/dev/null || true
  gsettings --schemadir "$EXT_DIR/$ML/schemas" set "$ML_SCHEMA" x-tiles '6.0' 2>/dev/null || true
  gsettings --schemadir "$EXT_DIR/$ML/schemas" set "$ML_SCHEMA" y-tiles '35.0' 2>/dev/null || true
  log "animasi genie Mac — 250ms, rambatan lembut ✓"
fi

# --- 5. nyalain ekstensi kita, matiin ubuntu-dock ------------------------
python3 - <<'PYEOF'
import ast, subprocess
def gs(k):   return ast.literal_eval(subprocess.check_output(["gsettings","get","org.gnome.shell",k], text=True))
def gss(k,v): subprocess.check_call(["gsettings","set","org.gnome.shell",k,v])
DTD='dash-to-dock@micxgx.gmail.com'
ML='compiz-alike-magic-lamp-effect@hermes83.github.com'
UB='ubuntu-dock@ubuntu.com'
en, dis = gs("enabled-extensions"), gs("disabled-extensions")
for u in (DTD, ML):
    if u not in en: en.append(u)
    if u in dis: dis.remove(u)
if UB not in dis: dis.append(UB)
if UB in en: en.remove(UB)
gss("enabled-extensions", str(en))
gss("disabled-extensions", str(dis))
print("[ghost-dock] ekstensi enabled, ubuntu-dock dimatiin (biar gak rebutan) ✓")
PYEOF
gnome-extensions enable "$DTD" 2>/dev/null || true
gnome-extensions enable "$ML" 2>/dev/null || true

# --- 6. restart GNOME Shell ---------------------------------------------
if [ "$SKIP_RESTART" = "1" ]; then
  log "restart dilewati (SKIP_RESTART=1)."
else
  RES="$(gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell \
         --method org.gnome.Shell.Eval 'Meta.restart("[ghost-dock] reload")' 2>/dev/null || true)"
  case "$RES" in
    *true*) log "GNOME Shell restart sendiri — tunggu 2 detik." ;;
    *)
      if [ -n "${WAYLAND_DISPLAY:-}" ]; then
        warn "Wayland: logout -> login lagi biar dock muncul."
      else
        warn "X11: tekan Alt+F2, ketik r, Enter (restart shell tanpa logout)."
      fi ;;
  esac
fi

# --- 7. verifikasi --------------------------------------------------------
echo
log "=== VERIFIKASI ==="
log "icon-size      : $(dconf read /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size)"
log "transparency   : $(dconf read /org/gnome/shell/extensions/dash-to-dock/transparency-mode)"
log "bg-opacity     : $(dconf read /org/gnome/shell/extensions/dash-to-dock/background-opacity)"
log "click-action   : $(dconf read /org/gnome/shell/extensions/dash-to-dock/click-action)"
if grep -qF "$MARK" "$CSS" 2>/dev/null; then
  log "CSS patch      : nyangkut ✓"
else
  die "CSS patch GAGAL — jangan lanjut, buka issue di repo."
fi
echo
log "DONE. Dock kiri transparan total, autohide, klik-tengah = minimize, animasi genie Mac aktif."
log "github.com/Coding-No/ghost-dock — Author: LALA"
