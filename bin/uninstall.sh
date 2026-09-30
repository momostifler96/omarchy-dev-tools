#!/usr/bin/env bash
# Désinstalle le plugin Omarchy Dev Tools : retire les fichiers copiés par install.sh.
set -euo pipefail

BIN_DIR="${HOME}/.local/bin"
DATA_DIR="${HOME}/.local/share/omarchy-dev-tools"
HYPR_PLUGINS_DIR="${HOME}/.config/hypr/plugins"
WAYBAR_MODULES_DIR="${HOME}/.config/waybar/modules"

echo "==> Désinstallation d'Omarchy Dev Tools"

rm -f "$BIN_DIR/omarchy-dev-tools"
echo "  - launcher retiré: $BIN_DIR/omarchy-dev-tools"

rm -f "$BIN_DIR/omarchy-vhost" "$BIN_DIR/omarchy-ngrok"
echo "  - CLI retirées: $BIN_DIR/omarchy-vhost, $BIN_DIR/omarchy-ngrok"
echo "    (les vhosts déjà créés dans /etc/hosts et nginx ne sont pas retirés automatiquement;"
echo "     utilise 'sudo omarchy-vhost remove <domaine>' avant de désinstaller si besoin)"

rm -rf "$DATA_DIR"
echo "  - données retirées: $DATA_DIR"

rm -f "$HYPR_PLUGINS_DIR/omarchy-dev-tools.conf"
echo "  - config Hyprland retirée: $HYPR_PLUGINS_DIR/omarchy-dev-tools.conf"

rm -f "$WAYBAR_MODULES_DIR/omarchy-dev-tools.jsonc"
echo "  - module Waybar retiré: $WAYBAR_MODULES_DIR/omarchy-dev-tools.jsonc"

cat <<'EOF'

==> Étapes manuelles restantes :
  - Retire "custom/omarchy-dev-tools" de modules-right/left dans
    ~/.config/waybar/config.jsonc, et l'entrée "include" si tu l'as ajoutée.
  - Recharge Hyprland (hyprctl reload) et Waybar (pkill -SIGUSR2 waybar).

La ligne "source = ~/.config/hypr/plugins/*.conf" dans hyprland.conf
n'est pas retirée automatiquement (elle peut servir à d'autres plugins).

==> Désinstallation terminée.
EOF
