# Omarchy Dev Tools

Boîte à outils développeur façon [it-tools.tech](https://it-tools.tech), intégrée à
[Omarchy](https://omarchy.org) : accessible instantanément via un raccourci clavier
Hyprland et depuis une icône dans la barre du haut (Waybar). 100% local, aucune
requête réseau.

## Outils inclus (v1)

- Base64 (encode / decode)
- URL encode / decode
- JWT decoder
- Générateur UUID v4
- Hash de texte (SHA-1 / SHA-256 / SHA-384 / SHA-512)
- JSON formatter / minifier / validator
- Testeur de regex
- Convertisseur de couleurs (HEX / RGB / HSL)
- Convertisseur de timestamp Unix ⇄ date
- Explicateur d'expression cron
- Générateur Lorem Ipsum
- Convertisseur de casse (camelCase, snake_case, kebab-case, PascalCase, CONSTANT_CASE)
- Comparateur de texte ligne à ligne
- **Gestionnaire de vhosts** : génère et lance la commande pour créer un domaine
  local (`monapp.test`) pointé sur un port, avec reverse proxy nginx en option
- **Exposer via ngrok** : génère la commande `omarchy-ngrok <port>` et affiche en
  direct l'URL publique du tunnel actif

D'autres outils d'it-tools.tech (QR code, chiffrement, conversion de fichiers…)
pourront être ajoutés ensuite dans `src/index.html` en suivant le même pattern
`registerTool({...})`.

## Installation

```bash
git clone https://github.com/momostifler96/omarchy-dev-tools.git
cd omarchy-dev-tools
./bin/install.sh
```

Le script :
- installe le launcher `omarchy-dev-tools` dans `~/.local/bin`
- installe l'app dans `~/.local/share/omarchy-dev-tools`
- ajoute le raccourci clavier **Super + T** via `~/.config/hypr/plugins/omarchy-dev-tools.conf`
- copie le module Waybar dans `~/.config/waybar/modules/` (fusion manuelle
  dans `config.jsonc`, instructions affichées à la fin de l'install)

Recharge ensuite Hyprland et Waybar :

```bash
hyprctl reload
pkill -SIGUSR2 waybar
```

## Désinstallation

```bash
./bin/uninstall.sh
```

## Utilisation

- **Clavier** : `Super + T` ouvre la fenêtre d'outils (flottante, centrée, 1000×680).
- **Souris** : clique sur l'icône 󰙯 dans la barre du haut (Waybar).
- `Échap` ferme la fenêtre.

### Vhosts locaux et exposition ngrok

Ces deux outils déclenchent de vraies actions système (écriture dans
`/etc/hosts`, config nginx, lancement d'un process ngrok), ce que la page
web ne peut pas faire elle-même par sécurité. L'onglet correspondant génère
donc la commande exacte à copier-coller dans un terminal :

```bash
# Créer un vhost (avec reverse proxy nginx si détecté)
sudo omarchy-vhost add monapp.test 3000

# Lister les vhosts gérés par omarchy-vhost
omarchy-vhost list

# Retirer un vhost
sudo omarchy-vhost remove monapp.test

# Exposer un port local via ngrok
omarchy-ngrok 3000

# Voir les tunnels ngrok actifs (JSON)
omarchy-ngrok status
```

L'onglet "Exposer via ngrok" de l'app interroge en direct l'API locale
d'ngrok (`http://127.0.0.1:4040/api/tunnels`) et affiche l'URL publique dès
que `omarchy-ngrok` tourne — inutile de la chercher dans les logs.

Prérequis : [ngrok](https://ngrok.com/download) installé et authentifié
(`ngrok config add-authtoken ...`) pour l'exposition ; `nginx` installé (et
sudoers configuré pour l'utilisateur) pour le reverse proxy des vhosts —
sinon `omarchy-vhost` se limite à l'entrée `/etc/hosts`.

## Structure du projet

```
bin/
  omarchy-dev-tools   # launcher (dev, non installé tel quel)
  omarchy-vhost       # CLI: gestion des vhosts locaux (hosts + nginx)
  omarchy-ngrok       # CLI: wrapper ngrok (expose un port, affiche le statut)
  install.sh          # installation du plugin
  uninstall.sh        # désinstallation
src/
  index.html          # l'app (UI + logique de tous les outils, page unique)
hypr/
  omarchy-dev-tools.conf   # bind clavier + règles de fenêtre Hyprland
waybar/
  omarchy-dev-tools.jsonc  # module Waybar (icône + click handler)
plugin.json           # manifest du plugin
```

## Ajouter un nouvel outil

Dans `src/index.html`, dupliquer un bloc `registerTool({...})` existant :

```js
registerTool({
  id: "mon-outil",
  name: "Mon Outil",
  category: "Ma Catégorie",
  render(root) {
    root.innerHTML = `...`;
    // logique JS ici
  }
});
```

Aucune étape de build : tout est en JS/HTML/CSS vanilla dans un seul fichier.
