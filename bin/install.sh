#!/usr/bin/env bash
# Installe les binaires CLI du plugin Omarchy Dev Tools.
#
# Le widget de barre (Widget.qml) et le manifest sont chargés directement par
# le shell Omarchy depuis le dossier du plugin (installé via
# `omarchy plugin add <git-url>`). Ce script n'installe que les commandes
# optionnelles du terminal :
#   - omarchy-dev-tools : ouvre l'app hors barre (raccourci clavier perso)
#   - omarchy-vhost     : gestion de vhosts locaux
#   - omarchy-ngrok     : exposition ngrok
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="${HOME}/.local/bin"

echo "==> Installation des binaires Omarchy Dev Tools"

mkdir -p "$BIN_DIR"
for bin in omarchy-dev-tools omarchy-vhost omarchy-ngrok; do
  cp "$PLUGIN_DIR/bin/$bin" "$BIN_DIR/$bin"
  chmod +x "$BIN_DIR/$bin"
  echo "  - $BIN_DIR/$bin"
done

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo "  ! $BIN_DIR n'est pas dans ton PATH. Ajoute-le à ton shell rc si besoin :"
  echo "      export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

cat <<'EOF'

==> Raccourci clavier (optionnel) :
  Ajoute dans ~/.config/hypr/bindings.lua :
    o.bind("SUPER + T", "Omarchy Dev Tools", "omarchy-dev-tools")

EOF

echo "==> Installation terminée."
