# Omarchy Dev Tools

Boîte à outils développeur façon [it-tools.tech](https://it-tools.tech), packagée comme
plugin [Omarchy](https://omarchy.org) (Hyprland/Arch) : accessible instantanément via un
raccourci clavier et une icône dans la barre du haut (Waybar). 100 % local, aucune
requête réseau pour les outils de conversion/texte/crypto.

- **Aucun build requis** : HTML/CSS/JS vanilla en page unique, ouverte directement par le navigateur.
- **Aucune dépendance runtime** pour les 13 outils utilitaires.
- Deux outils optionnels (`omarchy-vhost`, `omarchy-ngrok`) pilotent des actions système réelles et ont leurs propres prérequis (voir plus bas).

---

## Sommaire

- [Aperçu des outils](#aperçu-des-outils)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Vérifier l'installation](#vérifier-linstallation)
- [Mettre à jour](#mettre-à-jour)
- [Désinstaller](#désinstaller)
- [Utilisation](#utilisation)
- [Vhosts locaux et exposition ngrok](#vhosts-locaux-et-exposition-ngrok)
- [Configuration](#configuration)
- [Dépannage](#dépannage)
- [Structure du projet](#structure-du-projet)
- [Développement / contribuer](#développement--contribuer)
- [Licence](#licence)

---

## Aperçu des outils

| Catégorie | Outils |
|---|---|
| Encodage | Base64, URL encode/decode |
| Sécurité | JWT decoder, Hash (SHA-1/256/384/512) |
| Générateurs | UUID v4, Lorem Ipsum |
| Texte & données | JSON formatter/minifier/validator, testeur regex, convertisseur de casse, comparateur de texte |
| Design | Convertisseur de couleurs (HEX/RGB/HSL), générateur de palette Tailwind (50→950) |
| Date & heure | Convertisseur timestamp Unix, explicateur d'expression cron |
| Réseau local | Gestionnaire de vhosts (`omarchy-vhost`), exposition via ngrok (`omarchy-ngrok`) |

D'autres outils d'it-tools.tech (QR code, chiffrement, conversion de fichiers…) peuvent
être ajoutés ensuite en suivant le pattern `registerTool({...})` dans `src/index.html`
(voir [Développement / contribuer](#développement--contribuer)).

---

## Prérequis

Obligatoires pour l'app elle-même :

- **Omarchy** (Hyprland + Waybar) — ou tout environnement Hyprland équivalent.
- **Bash** (scripts d'installation et launchers).
- Un navigateur en mode app : **Chromium**, **chromium-browser**, **google-chrome** ou
  **google-chrome-stable** (le premier trouvé dans le `PATH` est utilisé). Sans eux,
  l'app s'ouvre via `xdg-open` dans le navigateur par défaut (moins intégré visuellement).

Optionnels, uniquement si tu utilises les outils réseau :

- **nginx** (pour le reverse proxy automatique des vhosts — sans lui, `omarchy-vhost`
  se limite à l'entrée `/etc/hosts`).
- **ngrok** installé et authentifié (`ngrok config add-authtoken <token>`), voir
  [ngrok.com/download](https://ngrok.com/download).
- **curl** (utilisé par `omarchy-ngrok status`).

Aucun gestionnaire de paquets (npm, pip…) n'est nécessaire : il n'y a pas d'étape de
build, tout le code est prêt à l'emploi.

---

## Installation

```bash
git clone https://github.com/momostifler96/omarchy-dev-tools.git
cd omarchy-dev-tools
./bin/install.sh
```

`install.sh` est idempotent (tu peux le relancer sans risque) et fait, dans l'ordre :

1. **App + launcher** — copie `src/` dans `~/.local/share/omarchy-dev-tools/` et génère
   `~/.local/bin/omarchy-dev-tools` (lance le navigateur en mode `--app`, fenêtre
   dédiée sans onglets ni barre d'adresse).
2. **CLI complémentaires** — copie `omarchy-vhost` et `omarchy-ngrok` dans
   `~/.local/bin/`.
3. **Raccourci clavier Hyprland** — copie `hypr/omarchy-dev-tools.conf` dans
   `~/.config/hypr/plugins/` (bind `Super + T` + règles de fenêtre flottante/centrée) et
   ajoute `source = ~/.config/hypr/plugins/*.conf` à `hyprland.conf` s'il n'y est pas déjà.
4. **Module Waybar** — copie `waybar/omarchy-dev-tools.jsonc` dans
   `~/.config/waybar/modules/` et affiche les 2 lignes à ajouter toi-même dans
   `~/.config/waybar/config.jsonc` (volontairement manuel : on ne réécrit jamais ta
   config Waybar existante pour éviter de la casser).

À la fin du script, applique les changements :

```bash
hyprctl reload
pkill -SIGUSR2 waybar
```

Si `~/.local/bin` n'est pas dans ton `PATH`, le script te le signale — ajoute alors à
ton `~/.bashrc` / `~/.zshrc` :

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Pourquoi il n'y a pas de "build" ?

`src/index.html` est une page unique sans dépendances externes ni transpilation : ce
que tu vois dans le dépôt est exactement ce qui s'exécute. `install.sh` ne fait donc
que **copier des fichiers**, pas les compiler.

---

## Vérifier l'installation

```bash
command -v omarchy-dev-tools && echo OK   # launcher présent dans le PATH
command -v omarchy-vhost && echo OK
command -v omarchy-ngrok && echo OK
ls ~/.config/hypr/plugins/omarchy-dev-tools.conf
ls ~/.config/waybar/modules/omarchy-dev-tools.jsonc
```

Puis teste le lancement direct (sans passer par le raccourci) :

```bash
omarchy-dev-tools
```

Une fenêtre flottante centrée (1000×680) doit s'ouvrir avec la sidebar d'outils.

---

## Mettre à jour

```bash
cd omarchy-dev-tools
git pull
./bin/install.sh   # réinstalle par-dessus (écrase l'app + les CLI, pas ta config Waybar)
```

---

## Désinstaller

```bash
./bin/uninstall.sh
```

Retire le launcher, les CLI, les données de l'app et les fichiers de config copiés
(`hypr/plugins/omarchy-dev-tools.conf`, `waybar/modules/omarchy-dev-tools.jsonc`). Les
vhosts déjà créés dans `/etc/hosts`/nginx ne sont **pas** retirés automatiquement — fais-le
avant, si besoin, avec `sudo omarchy-vhost remove <domaine>` pour chacun. Les étapes
manuelles restantes (retirer l'entrée Waybar, `hyprctl reload`, `pkill -SIGUSR2 waybar`)
sont rappelées à la fin du script.

---

## Utilisation

- **Clavier** : `Super + T` ouvre la fenêtre d'outils.
- **Souris** : clique sur l'icône 󰙯 dans la barre du haut (Waybar).
- `Échap` ferme la fenêtre.
- La sidebar a un champ de recherche pour filtrer les outils par nom.
- Le dernier outil ouvert est mémorisé (`localStorage`) et réaffiché à la prochaine ouverture.

## Vhosts locaux et exposition ngrok

Ces deux outils déclenchent de vraies actions système (écriture dans `/etc/hosts`,
config nginx, lancement d'un process ngrok) que la page web ne peut pas faire
elle-même par sécurité (sandbox navigateur). L'onglet correspondant dans l'app génère
donc la commande exacte à copier-coller dans un terminal.

### `omarchy-vhost` — vhosts locaux

```bash
# Créer un vhost (avec reverse proxy nginx si nginx est détecté)
sudo omarchy-vhost add monapp.test 3000

# Créer un vhost sans toucher à nginx (entrée /etc/hosts uniquement)
sudo omarchy-vhost add monapp.test 3000 --no-nginx

# Créer un vhost en HTTPS (certificat local, port 80 redirige vers 443)
sudo omarchy-vhost add monapp.test 3000 --https

# Lister les vhosts gérés par omarchy-vhost (affiche le schéma http/https)
omarchy-vhost list

# Retirer un vhost (hosts + config nginx + certificat associés)
sudo omarchy-vhost remove monapp.test
```

Ce que fait `add` :
- ajoute `127.0.0.1 <domaine>` à `/etc/hosts` (marqué `# omarchy-vhost` pour un retrait propre) ;
- si `nginx` **n'est pas** installé (et que `--no-nginx` n'est pas passé), demande une
  confirmation explicite avant de l'installer (`sudo pacman -S nginx`) — jamais
  d'installation silencieuse ; en cas de refus ou d'échec, le vhost reste limité à
  l'entrée `/etc/hosts` ;
- si `nginx` est disponible (déjà présent ou installé après confirmation), écrit
  `/etc/nginx/sites-available/<domaine>.conf` (reverse proxy vers `127.0.0.1:<port>`,
  support WebSocket inclus), l'active dans `sites-enabled/`, teste la config
  (`nginx -t`) puis recharge nginx ;
- avec `--https` : génère (si besoin) un certificat local dans
  `/etc/omarchy-vhost/certs/<domaine>/` — via [`mkcert`](https://github.com/FiloSottile/mkcert)
  si installé (certificat de confiance, sans avertissement navigateur), sinon un
  certificat autosigné via `openssl` (avertissement navigateur tant qu'il n'est pas
  importé manuellement). Le vhost écoute alors en HTTPS sur le 443, et le port 80
  redirige automatiquement vers HTTPS. Nécessite nginx (ignoré avec `--no-nginx`).

`add` et `remove` nécessitent `sudo` (écriture système) ; `list` ne le nécessite pas.

### `omarchy-ngrok` — exposition via ngrok

```bash
# Exposer le port 3000
omarchy-ngrok 3000

# Avec des options ngrok supplémentaires (passées telles quelles)
omarchy-ngrok 3000 --domain=mondomaine.ngrok-free.app

# Voir les tunnels actifs (JSON brut de l'API locale ngrok)
omarchy-ngrok status
```

L'onglet "Exposer via ngrok" de l'app interroge en direct l'API locale d'ngrok
(`http://127.0.0.1:4040/api/tunnels`, toutes les 2 secondes) et affiche l'URL publique
dès que `omarchy-ngrok` tourne quelque part — inutile de la chercher dans les logs du
terminal.

---

## Configuration

- **Changer le raccourci clavier** : édite `~/.config/hypr/plugins/omarchy-dev-tools.conf`
  (ligne `bind = SUPER, T, exec, omarchy-dev-tools`), puis `hyprctl reload`. Pour que le
  changement survive à une réinstallation, modifie plutôt `hypr/omarchy-dev-tools.conf`
  dans le dépôt avant de relancer `install.sh`.
- **Déplacer l'icône Waybar** : dans `~/.config/waybar/config.jsonc`, `"custom/omarchy-dev-tools"`
  peut être placé dans `modules-left`, `modules-center` ou `modules-right`.
- **Changer la taille de fenêtre** : ajuste `--window-size` dans le launcher généré
  (`~/.local/bin/omarchy-dev-tools`) et les valeurs `size` dans
  `hypr/omarchy-dev-tools.conf` (`windowrulev2 = size ...`).

---

## Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| `Super + T` ne fait rien | Hyprland n'a pas rechargé sa config | `hyprctl reload` ; vérifie que `hyprland.conf` contient bien `source = ~/.config/hypr/plugins/*.conf` |
| L'icône n'apparaît pas dans Waybar | Module pas ajouté à `config.jsonc` | Relis l'étape 4 de [Installation](#installation), puis `pkill -SIGUSR2 waybar` |
| `omarchy-dev-tools: command not found` | `~/.local/bin` absent du `PATH` | Ajoute `export PATH="$HOME/.local/bin:$PATH"` à ton shell rc, puis ouvre un nouveau terminal |
| L'app s'ouvre dans un onglet de navigateur classique (pas en fenêtre dédiée) | Aucun binaire Chromium/Chrome trouvé | Installe `chromium` (ou `google-chrome`), sinon c'est `xdg-open` qui prend le relais |
| `omarchy-vhost: cette commande nécessite sudo` | `add`/`remove` appelés sans `sudo` | Préfixe la commande par `sudo` |
| `omarchy-vhost` ne configure pas nginx | `nginx` absent et installation refusée, ou `--no-nginx` passé | Relance et réponds `o` à la question d'installation, ou installe `nginx` toi-même (`sudo pacman -S nginx`) |
| `omarchy-vhost` ne propose pas d'installer nginx | Commande lancée sans terminal interactif (script, CI) ou `pacman` absent (hors Arch) | Installe `nginx` manuellement puis relance `omarchy-vhost add` |
| HTTPS affiche un avertissement navigateur | Certificat autosigné (pas de `mkcert`) | Installe [`mkcert`](https://github.com/FiloSottile/mkcert) puis recrée le vhost (`remove` + `add --https`) |
| L'onglet ngrok affiche "Agent ngrok injoignable" | `omarchy-ngrok`/`ngrok` pas lancé, ou tourne sur une autre machine/conteneur | Lance `omarchy-ngrok <port>` sur la même machine que le navigateur qui affiche l'app |
| `ngrok` refuse de démarrer | Pas authentifié | `ngrok config add-authtoken <ton-token>` (compte gratuit sur ngrok.com) |

---

## Structure du projet

```
plugin.json                       # manifest du plugin (nom, version, bindings)
bin/
  omarchy-dev-tools                # launcher de dev (référence ; install.sh en génère une copie adaptée)
  omarchy-vhost                    # CLI : gestion des vhosts locaux (hosts + nginx)
  omarchy-ngrok                    # CLI : wrapper ngrok (expose un port, affiche le statut)
  install.sh                       # installation (copie fichiers + config Hyprland/Waybar)
  uninstall.sh                     # désinstallation
src/
  index.html                       # l'app : UI + logique de tous les outils (page unique)
hypr/
  omarchy-dev-tools.conf           # bind clavier + règles de fenêtre Hyprland
waybar/
  omarchy-dev-tools.jsonc          # module Waybar (icône + click handler)
README.md
```

---

## Développement / contribuer

Aucune étape de build : édite `src/index.html` et rafraîchis la page (`F5`) dans le
navigateur pour voir le résultat — inutile même de réinstaller pendant le développement,
tu peux ouvrir le fichier directement :

```bash
xdg-open src/index.html
# ou, en conditions proches de la prod :
chromium --app="file://$(pwd)/src/index.html" --window-size=1000,680
```

### Ajouter un nouvel outil

Dupliquer un bloc `registerTool({...})` existant dans `src/index.html` :

```js
registerTool({
  id: "mon-outil",
  name: "Mon Outil",
  category: "Ma Catégorie",     // nouvelle catégorie = nouvelle section dans la sidebar
  render(root) {
    root.innerHTML = `...`;     // markup de l'outil
    // logique JS ici, utiliser $() / showResult() / copyToClipboard() (helpers existants)
  }
});
```

### Avant de committer

```bash
bash -n bin/install.sh bin/uninstall.sh bin/omarchy-dev-tools bin/omarchy-vhost bin/omarchy-ngrok
```

vérifie la syntaxe des scripts bash (aucune dépendance à installer pour ça).

### Conventions

- Scripts bash : `set -euo pipefail`, commentaires en français, messages utilisateur préfixés (`  - `, `  ! `, `==> `).
- UI : thème sombre défini par les variables CSS `:root` en haut de `src/index.html` — modifie-les pour changer la palette plutôt que de dupliquer des couleurs en dur.
- Un outil = un `registerTool`, autonome, sans état partagé avec les autres (sauf les helpers communs `$`, `showResult`, `copyToClipboard`).

---

## Licence

MIT — voir `plugin.json`.
