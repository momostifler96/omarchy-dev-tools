#!/usr/bin/env bash
# Installe le plugin Omarchy Dev Tools :
#   - copie l'app et le launcher
#   - ajoute le raccourci clavier Hyprland (Super+T)
#   - prépare le module Waybar (fusion manuelle, voir instructions affichées)
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BIN_DIR="${HOME}/.local/bin"
DATA_DIR="${HOME}/.local/share/omarchy-dev-tools"
HYPR_PLUGINS_DIR="${HOME}/.config/hypr/plugins"
HYPR_CONF="${HOME}/.config/hypr/hyprland.conf"
WAYBAR_MODULES_DIR="${HOME}/.config/waybar/modules"

echo "==> Installation d'Omarchy Dev Tools"

mkdir -p "$BIN_DIR" "$DATA_DIR" "$HYPR_PLUGINS_DIR" "$WAYBAR_MODULES_DIR"

# 1. App + launcher
rm -rf "$DATA_DIR/src"
cp -r "$PLUGIN_DIR/src" "$DATA_DIR/"
cat > "$BIN_DIR/omarchy-dev-tools" <<EOF
#!/usr/bin/env bash
# Généré par omarchy-dev-tools/bin/install.sh — ne pas éditer à la main.
set -euo pipefail
INDEX_FILE="${DATA_DIR}/src/index.html"

BROWSER_BIN=""
for candidate in chromium chromium-browser google-chrome google-chrome-stable; do
  if command -v "\$candidate" >/dev/null 2>&1; then
    BROWSER_BIN="\$candidate"
    break
  fi
done

if [[ -z "\$BROWSER_BIN" ]]; then
  exec xdg-open "\$INDEX_FILE"
fi

exec "\$BROWSER_BIN" \\
  --app="file://\$INDEX_FILE" \\
  --window-size=1000,680 \\
  --class=omarchy-dev-tools \\
  --name=omarchy-dev-tools
EOF
chmod +x "$BIN_DIR/omarchy-dev-tools"
echo "  - launcher installé: $BIN_DIR/omarchy-dev-tools"
echo "  - app installée:     $DATA_DIR/src/index.html"

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo "  ! $BIN_DIR n'est pas dans ton PATH. Ajoute-le à ton shell rc si besoin:"
  echo "      export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# 1bis. Outils CLI complémentaires (vhost, ngrok)
cp "$PLUGIN_DIR/bin/omarchy-vhost" "$BIN_DIR/omarchy-vhost"
cp "$PLUGIN_DIR/bin/omarchy-ngrok" "$BIN_DIR/omarchy-ngrok"
chmod +x "$BIN_DIR/omarchy-vhost" "$BIN_DIR/omarchy-ngrok"
echo "  - CLI installées: $BIN_DIR/omarchy-vhost, $BIN_DIR/omarchy-ngrok"

# 2. Raccourci clavier Hyprland
cp "$PLUGIN_DIR/hypr/omarchy-dev-tools.conf" "$HYPR_PLUGINS_DIR/omarchy-dev-tools.conf"
echo "  - config Hyprland copiée dans: $HYPR_PLUGINS_DIR/omarchy-dev-tools.conf"

if [[ -f "$HYPR_CONF" ]] && ! grep -q "hypr/plugins/\*.conf" "$HYPR_CONF" 2>/dev/null; then
  {
    echo ""
    echo "# Omarchy plugins (ajouté par omarchy-dev-tools)"
    echo "source = ~/.config/hypr/plugins/*.conf"
  } >> "$HYPR_CONF"
  echo "  - ligne 'source = ~/.config/hypr/plugins/*.conf' ajoutée à hyprland.conf"
elif [[ ! -f "$HYPR_CONF" ]]; then
  echo "  ! hyprland.conf introuvable ($HYPR_CONF)."
  echo "    Ajoute manuellement: source = ~/.config/hypr/plugins/*.conf"
else
  echo "  - hyprland.conf source déjà les plugins, rien à faire"
fi

# 3. Module Waybar (copié, fusion manuelle pour ne pas casser la config existante)
cp "$PLUGIN_DIR/waybar/omarchy-dev-tools.jsonc" "$WAYBAR_MODULES_DIR/omarchy-dev-tools.jsonc"
echo "  - module Waybar copié dans: $WAYBAR_MODULES_DIR/omarchy-dev-tools.jsonc"
cat <<'EOF'

==> Étape manuelle pour Waybar :
  1. Dans ~/.config/waybar/config.jsonc, ajoute "custom/omarchy-dev-tools"
     à la liste "modules-right" (ou modules-left).
  2. Ajoute au niveau racine de ce même fichier :
       "include": ["~/.config/waybar/modules/omarchy-dev-tools.jsonc"]
     (ou fusionne directement le contenu du module copié ci-dessus).
  3. Recharge Waybar : pkill -SIGUSR2 waybar   (ou relance ta session).

==> Recharge Hyprland pour activer le raccourci :
  hyprctl reload

Raccourci par défaut : Super + T
EOF

echo "==> Installation terminée."
