# Changelog

Toutes les évolutions notables du projet sont documentées ici.
Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/).

## [0.4.0] — 2026-10-21

### Security
- `omarchy-vhost` (exécuté en root) n'accepte plus qu'un nom d'hôte en minuscules
  et un port 1-65535 : un domaine comme `../..` ou contenant un retour à la ligne
  pouvait écrire ou supprimer (`rm -rf`) hors de `/etc/omarchy-vhost` et injecter
  de la configuration dans `/etc/hosts` ou nginx.
- Clés privées HTTPS créées en `0600` dans un dossier `0700`.

### Fixed
- `--https` : les messages de `ensure_cert` polluaient le chemin du certificat
  écrit dans la config nginx.
- Palette Tailwind : les 11 nuances tiennent dans la largeur du panneau (950 était coupée).
- Sauvegarde du dernier outil : suppression de l'appel `writeAdapter()` invalide.
- Installation des dépendances : terminal par défaut (`xdg-terminal-exec`) au lieu
  de `foot` codé en dur.

### Added
- Fichier LICENSE (MIT), README réécrit (dépendances, désinstallation, droits root),
  capture d'écran `preview.png`.
- Générateur de token / mot de passe : longueur, quantité, jeux de caractères
  (majuscules, minuscules, chiffres, symboles), exclusion des caractères ambigus,
  estimation de l'entropie. Aléa tiré de `/dev/urandom` avec rejet (sans biais).
- Générateur de palette Tailwind (façon uicolors.app) : à partir d'une couleur de
  base, génère les 11 nuances 50→950 avec aperçu, export config
  `tailwind.config.js` et variables CSS.
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

## [0.1.0] — 2026-09-30

### Added
- Première version du plugin Omarchy Dev Tools.
- 13 outils type it-tools.tech : Base64, URL encode/decode, JWT decoder, générateur
  UUID, hash (SHA-1/256/384/512), JSON formatter, testeur regex, convertisseur de
  couleurs, convertisseur de timestamp, explicateur cron, générateur Lorem Ipsum,
  convertisseur de casse, comparateur de texte.
- Raccourci clavier Hyprland (`Super + T`) et module Waybar (icône dans la barre du haut).
- `bin/install.sh` / `bin/uninstall.sh` pour une installation/désinstallation en une commande.
