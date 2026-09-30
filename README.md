# Omarchy Dev Tools

Boîte à outils développeur façon [it-tools.tech](https://it-tools.tech), packagée comme
plugin [Omarchy](https://omarchy.org) (Hyprland/Arch) : **panneau natif QML** du shell
Omarchy, ouvert en un clic sur l'icône `</>` de la barre du haut (toggle, Échap pour
fermer). 100 % local, aucune requête réseau pour les outils de conversion/texte/crypto.

- **Panneau natif** : QML/Quickshell comme les panels du shell — pas de fenêtre
  navigateur, pas de webview.
- **Aucune dépendance runtime** pour les 16 outils utilitaires (les 5 outils réseau
  ont leurs propres prérequis, voir plus bas).
- **Version web de secours** : `src/index.html` (page HTML autonome) reste ouvrable
  via la CLI `omarchy-dev-tools`.

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

D'autres outils peuvent être ajoutés en créant un fichier `tools/MonOutil.qml`
(avec `Helpers.js` pour la logique pure) et en l'enregistrant dans `toolRegistry`
de `Panel.qml` — et, pour la version web, via `registerTool({...})` dans
`src/index.html` (voir [Développement / contribuer](#développement--contribuer)).

---

## Prérequis

Obligatoires pour l'app elle-même :

- **Omarchy** (Hyprland + shell Omarchy) — ou tout environnement Hyprland équivalent
  (dans ce cas, utilise l'installation manuelle + le raccourci clavier).
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

Le plugin est au [format plugin Omarchy](https://omarchy.org) (manifest `manifest.json`
+ widget QML), donc il s'installe comme n'importe quel plugin communautaire :

```bash
omarchy plugin add https://github.com/momostifler96/omarchy-dev-tools
```

Puis active le widget dans la barre :

```bash
omarchy plugin enable momoledev.dev-tools right
```

Optionnel — les CLI du terminal (`omarchy-dev-tools` en ligne de commande,
`omarchy-vhost`, `omarchy-ngrok`) et un raccourci clavier :

```bash
cd ~/.config/omarchy/plugins/momoledev.dev-tools
./bin/install.sh
```

Puis ajoute dans `~/.config/hypr/bindings.lua` :

```lua
o.bind("SUPER + SHIFT + T", "Omarchy Dev Tools", "omarchy-dev-tools")
o.window("omarchy-dev-tools", { float = true, center = true, size = "1000 680" })
```

Installation manuelle équivalente (sans `omarchy plugin`) :

```bash
git clone https://github.com/momostifler96/omarchy-dev-tools.git ~/.config/omarchy/plugins/momoledev.dev-tools
```

### Ce que fait chaque pièce

- **`manifest.json` + `Widget.qml`** — le plugin shell Omarchy proprement dit : icône
  `</>` dans la barre du haut, clic = ouverture de l'app. Géré par le shell
  (hot-reload, activation/désactivation via `omarchy plugin ...`).
- **`bin/install.sh`** (optionnel) — copie les 3 binaires dans `~/.local/bin/`.
  Idempotent, tu peux le relancer sans risque.
- **`bin/uninstall.sh`** (optionnel) — retire les binaires ; le widget lui-même se
  retire avec `omarchy plugin remove momoledev.dev-tools`.

### Pourquoi il n'y a pas de "build" ?

`src/index.html` est une page unique sans dépendances externes ni transpilation : ce
que tu vois dans le dépôt est exactement ce qui s'exécute. `install.sh` ne fait donc
que **copier des fichiers**, pas les compiler.

---

## Vérifier l'installation

```bash
omarchy plugin list | grep dev-tools       # plugin découvert/activé
command -v omarchy-dev-tools && echo OK   # launcher présent dans le PATH
command -v omarchy-vhost && echo OK
command -v omarchy-ngrok && echo OK
```

Puis teste le lancement direct (sans passer par le raccourci) :

```bash
omarchy-dev-tools
```

Une fenêtre flottante centrée (1000×680) doit s'ouvrir avec la sidebar d'outils.

---

## Mettre à jour

```bash
omarchy plugin update momoledev.dev-tools   # si installé via git
# ou : git pull dans ~/.config/omarchy/plugins/momoledev.dev-tools
./bin/install.sh                            # réinstalle les CLI par-dessus
```

---

## Désinstaller

```bash
omarchy plugin remove momoledev.dev-tools   # retire le widget + le clone
./bin/uninstall.sh                          # retire les CLI (si install.sh a été lancé)
```

Les vhosts déjà créés dans `/etc/hosts`/nginx ne sont **pas** retirés automatiquement —
fais-le avant, si besoin, avec `sudo omarchy-vhost remove <domaine>` pour chacun. Le
raccourci `o.bind("SUPER + SHIFT + T", ...)` dans `~/.config/hypr/bindings.lua` est à
retirer à la main.

---

## Utilisation

- **Barre** : clique sur l'icône `</>` dans la barre du haut (shell Omarchy).
- **Clavier** : `Super + Shift + T` ouvre la fenêtre d'outils (si le raccourci a été ajouté).
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

- **Changer le raccourci clavier** : édite la ligne `o.bind("SUPER + SHIFT + T", ...)`
  dans `~/.config/hypr/bindings.lua` (Hyprland recharge automatiquement).
- **Déplacer l'icône** : `omarchy bar move momoledev.dev-tools --section left|center|right`.
- **Changer la taille de fenêtre** : ajuste `--window-size` dans
  `~/.local/bin/omarchy-dev-tools` et la valeur `size` du `o.window(...)` dans
  `bindings.lua`.

---

## Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| L'icône `</>` n'apparaît pas dans la barre | Widget pas activé | `omarchy plugin list \| grep dev-tools`, puis `omarchy plugin enable momoledev.dev-tools right` |
| `Super + Shift + T` ne fait rien | Raccourci pas ajouté à `bindings.lua` | Relis [Installation](#installation) ; Hyprland recharge tout seul `bindings.lua` |
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
manifest.json                     # manifest plugin Omarchy (id, version, entry points)
Widget.qml                        # widget de barre : icône </> + toggle du panel
Panel.qml                         # panel natif : sidebar (recherche + outils) + zone outil
Helpers.js                        # logique pure des outils (portage de src/index.html)
tools/
  ToolHeader.qml                  # en-tête titre/description + contenu d'un outil
  DevTextField.qml, DevTextArea.qml, ResultBox.qml, CopyButton.qml   # composants partagés
  *Tool.qml                       # un fichier par outil (16 outils)
bin/
  omarchy-dev-tools                # version web de secours (chromium --app / xdg-open)
  omarchy-vhost                    # CLI : gestion des vhosts locaux (hosts + nginx)
  omarchy-ngrok                    # CLI : wrapper ngrok (expose un port, affiche le statut)
  install.sh                       # installation optionnelle des CLI
  uninstall.sh                     # désinstallation des CLI
src/
  index.html                       # version web autonome (secours), mêmes outils
README.md
```

---

## Développement / contribuer

### Panel natif (principal)

Le hot-reload du shell Omarchy s'applique : éditer un fichier sous
`~/.config/omarchy/plugins/momoledev.dev-tools/` recharge le plugin automatiquement.
Pendant le développement, travaille directement dans le dépôt puis synchronise :

```bash
rsync -a --exclude .git ~/projects/perso/omarchy-dev-tools/ ~/.config/omarchy/plugins/momoledev.dev-tools/
```

- **Logique d'un outil** : fonctions pures dans `Helpers.js` (entrée → sortie).
- **UI d'un outil** : un fichier `tools/MonOutil.qml` racine `ToolHeader`, composants
  partagés `DevTextField` / `DevTextArea` / `ResultBox` / `CopyButton`.
- **Enregistrement** : ajouter une entrée `{ id, name, category, file }` dans
  `toolRegistry` de `Panel.qml`.
- Journal du shell : `journalctl --user -f | grep -i dev-tools` pour voir les
  erreurs QML en live.

### Version web (secours)

`src/index.html` reste une page autonome sans build :
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
