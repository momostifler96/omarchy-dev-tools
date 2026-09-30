# Changelog

Toutes les évolutions notables du projet sont documentées ici.
Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/).

## [Unreleased]

### Added
- Gestionnaire de vhosts locaux (`bin/omarchy-vhost`) : ajoute/retire/liste des vhosts
  (`/etc/hosts` + reverse proxy nginx optionnel).
- Support HTTPS pour les vhosts (`--https`) : certificat local via `mkcert` si
  disponible, sinon certificat autosigné `openssl` ; redirection automatique du port 80
  vers 443.
- Installation assistée de nginx : si nginx manque et qu'un reverse proxy est demandé,
  `omarchy-vhost` demande confirmation avant de l'installer (`pacman -S nginx`) —
  jamais d'installation silencieuse.
- Exposition de serveur local via ngrok (`bin/omarchy-ngrok`) : wrapper `ngrok http`,
  commande `status`, et panneau UI avec affichage live des tunnels actifs.
- README complet (installation, build, dépannage, configuration, contribution).
- CLAUDE.md pour guider les futures sessions d'agent sur ce dépôt.

## [0.1.0] — 2026-09-30

### Added
- Première version du plugin Omarchy Dev Tools.
- 13 outils type it-tools.tech : Base64, URL encode/decode, JWT decoder, générateur
  UUID, hash (SHA-1/256/384/512), JSON formatter, testeur regex, convertisseur de
  couleurs, convertisseur de timestamp, explicateur cron, générateur Lorem Ipsum,
  convertisseur de casse, comparateur de texte.
- Raccourci clavier Hyprland (`Super + T`) et module Waybar (icône dans la barre du haut).
- `bin/install.sh` / `bin/uninstall.sh` pour une installation/désinstallation en une commande.
