#!/usr/bin/env bash
# Désinstalle les binaires CLI du plugin Omarchy Dev Tools.
# Le widget de barre lui-même est retiré via `omarchy plugin remove momoledev.dev-tools`.
set -euo pipefail

BIN_DIR="${HOME}/.local/bin"

echo "==> Désinstallation des binaires Omarchy Dev Tools"

rm -f "$BIN_DIR/omarchy-dev-tools" "$BIN_DIR/omarchy-vhost" "$BIN_DIR/omarchy-ngrok"
echo "  - binaires retirés de $BIN_DIR"
echo "    (les vhosts déjà créés dans /etc/hosts et nginx ne sont pas retirés automatiquement;"
echo "     utilise 'sudo omarchy-vhost remove <domaine>' avant de désinstaller si besoin)"

cat <<'EOF'

==> Étapes manuelles restantes :
  - Retire le widget de la barre : omarchy bar remove momoledev.dev-tools
    (ou omarchy plugin remove momoledev.dev-tools pour tout retirer)
  - Retire le raccourci o.bind("SUPER + T", ...) de ~/.config/hypr/bindings.lua si présent.

==> Désinstallation terminée.
EOF
