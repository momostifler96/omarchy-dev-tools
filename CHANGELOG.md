# Changelog

Toutes les évolutions notables du projet sont documentées ici.
Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/).

## [0.4.4] — 2026-10-22

### Added
- Palette Tailwind : choix de la version (v4 ou v3). La v4 exporte un bloc `@theme`
  à coller dans le CSS principal, la v3 l'objet de couleurs pour
  `theme.extend.colors` de `tailwind.config.js`. Un seul bouton copie l'export choisi.

## [0.4.3] — 2026-10-22

### Security
- L'outil Hash envoie le texte à `shaNNNsum` par stdin au lieu de le passer en argument
  de `bash -c`, où il était lisible par les autres utilisateurs dans `/proc/<pid>/cmdline`.

### Fixed
- Le `nginx.conf` fourni par Arch n'inclut pas `sites-enabled/`, si bien que les vhosts
  n'étaient jamais servis. `omarchy-vhost add` ajoute `include /etc/nginx/sites-enabled/*.conf;`
  (marqué `# omarchy-vhost`) en tête du bloc `http` quand aucun include n'existe, après une
  copie `nginx.conf.omarchy-vhost.bak`, et restaure le fichier si `nginx -t` échoue.

## [0.4.2] — 2026-10-21

### Security
- `omarchy-vhost` n'écrase ni ne supprime plus une config nginx qu'il n'a pas créée :
  `add` s'arrête sans rien modifier si `sites-available/<domaine>.conf` n'a pas le
  marqueur `# omarchy-vhost` ou si `sites-enabled/<domaine>.conf` n'est pas un lien vers
  cette config ; `remove` laisse ces fichiers intacts.
- Le reverse proxy écoute sur `127.0.0.1:80` / `127.0.0.1:443` au lieu de toutes les
  interfaces : il n'est plus joignable depuis le réseau.

## [0.4.1] — 2026-10-21

### Security
- L'authtoken ngrok n'est plus passé en argument (`ngrok config add-authtoken <token>`,
  lisible par les autres utilisateurs dans `/proc/<pid>/cmdline`). Nouvelle commande
  `omarchy-ngrok set-authtoken` : token lu dans l'environnement ou en saisie masquée,
  écrit dans `ngrok.yml` en `0600` par remplacement atomique, validé par
  `ngrok config check` (fichier inchangé si invalide).

### Fixed
- Outils vhost et ngrok : les messages d'erreur référençaient des collecteurs de sortie
  inexistants (ReferenceError au lieu du message).

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
