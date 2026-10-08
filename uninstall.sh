#!/usr/bin/env bash
# ghost-dock uninstaller — Author: LALA
set -euo pipefail

DTD='dash-to-dock@micxgx.gmail.com'
ML='compiz-alike-magic-lamp-effect@hermes83.github.com'
EXT_DIR="$HOME/.local/share/gnome-shell/extensions"

log() { printf '\033[1;32m[ghost-dock]\033[0m %s\n' "$*"; }

gnome-extensions disable "$DTD" 2>/dev/null || true
gnome-extensions disable "$ML" 2>/dev/null || true
log "ekstensi dimatiin ✓"

CSS="$EXT_DIR/$DTD/stylesheet.css"
if [ -f "$CSS.bak-ghostdock" ]; then
  mv -f "$CSS.bak-ghostdock" "$CSS"
  log "patch CSS dibalikin ke stylesheet asli ✓"
fi

log "uninstall beres. Ekstensi & folder-nya sengaja gue biarin (bisa dipasang lagi kapan aja)."
log "kalau mau bersih total: rm -rf \"$EXT_DIR/$DTD\" \"$EXT_DIR/$ML\""
