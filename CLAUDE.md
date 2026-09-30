# CLAUDE.md

Instructions pour Claude Code (ou tout agent IA) travaillant sur ce dépôt.

## Ce que c'est

**Omarchy Dev Tools** : plugin pour [Omarchy](https://omarchy.org) (Hyprland/Arch) qui
reproduit en local une partie des outils de [it-tools.tech](https://it-tools.tech)
(base64, JWT, hash, JSON, regex, couleurs, timestamp, cron…), plus deux outils réseau
(`omarchy-vhost`, `omarchy-ngrok`). Accessible via `Super + T` et une icône Waybar.

Portfolio de suivi : projet "Omarchy Dev Tools" sur le MCP `momoledev` (portfolio perso
de l'utilisateur) — les phases de roadmap et les tâches y sont tenues à jour en parallèle
du code. Si tu avances sur ce projet depuis une session avec accès à ce MCP, mets à jour
les tâches/phases correspondantes plutôt que de laisser le portfolio désynchronisé du repo.

## Pas de build

Tout le code utilisateur (`src/index.html`) est en HTML/CSS/JS vanilla, une seule page,
zéro dépendance npm/pip, zéro transpilation. `bin/install.sh` ne fait que **copier des
fichiers** vers `~/.local/...` et `~/.config/...` — il n'y a rien à "compiler". Ne
propose pas d'introduire un bundler, un framework front, ou un package.json sans raison
explicite : ça irait à l'encontre de l'objectif (outil instantané, zéro friction).

## Structure

```
plugin.json              # manifest (nom, version, bindings clavier/Waybar)
bin/
  omarchy-dev-tools       # launcher de référence (install.sh en génère une variante adaptée au chemin d'install)
  omarchy-vhost           # CLI bash : vhosts locaux (/etc/hosts + nginx)
  omarchy-ngrok           # CLI bash : wrapper ngrok
  install.sh / uninstall.sh
src/index.html            # toute l'app : UI + logique de chaque outil
hypr/omarchy-dev-tools.conf   # snippet Hyprland (bind + windowrulev2)
waybar/omarchy-dev-tools.jsonc # snippet module Waybar
README.md                 # doc utilisateur (installation, usage, dépannage)
CHANGELOG.md               # suivi des versions (Keep a Changelog)
```

## Conventions à respecter

- **Commentaires et messages utilisateur en français**, cohérents avec l'existant
  (README, scripts, UI).
- **Scripts bash** : toujours `set -euo pipefail` en tête. Messages de progression
  préfixés `  - ` (fait), `  ! ` (avertissement), `==> ` (étape/titre). Valider avec
  `bash -n <script>` avant de committer — aucun linter externe requis.
- **Ajouter un outil UI** : dupliquer un bloc `registerTool({ id, name, category, render(root) {...} })`
  dans `src/index.html`. Réutiliser les helpers existants (`$`, `showResult`,
  `copyToClipboard`) plutôt que d'en recréer. Une nouvelle `category` crée
  automatiquement une nouvelle section dans la sidebar.
- **Thème** : variables CSS dans `:root` en haut de `src/index.html`. Ne pas coder des
  couleurs en dur ailleurs dans le fichier.
- **Actions système réelles** (écrire dans `/etc/hosts`, piloter nginx, lancer un
  process) ne peuvent pas se faire depuis le JS de la page (sandbox navigateur). Le
  pattern retenu : un panneau UI qui **génère la commande CLI exacte** à copier-coller
  (voir les outils "Gestionnaire de vhosts" et "Exposer via ngrok"), pas d'appel réseau
  vers un backend maison. Rester sur ce pattern pour toute nouvelle fonctionnalité du
  même type, sauf décision explicite d'ajouter un petit serveur local.
- **install.sh / uninstall.sh** doivent rester idempotents et non destructifs : ne
  jamais réécrire `~/.config/waybar/config.jsonc` ou `~/.config/hypr/hyprland.conf`
  directement (fusion manuelle assistée par des instructions affichées), seulement les
  fichiers propres au plugin dans `plugins/` / `modules/`.

## Vérifications avant de committer

```bash
bash -n bin/install.sh bin/uninstall.sh bin/omarchy-dev-tools bin/omarchy-vhost bin/omarchy-ngrok

python3 -c "
html = open('src/index.html').read()
assert html.count('<script>') == html.count('</script>')
print('registerTool count:', html.count('registerTool({'))
"
```

Il n'y a pas de suite de tests automatisés (pas de framework de test en place) : les
vérifications ci-dessus + une relecture manuelle du diff suffisent pour ce projet.
Les tests réels (raccourci clavier, clic Waybar, vhost/ngrok en conditions live) ne
peuvent se faire que sur une vraie machine Omarchy, pas dans ce sandbox — le journaliser
dans le portfolio plutôt que de prétendre l'avoir fait.

## Ce qu'il ne faut pas faire

- Ne pas ajouter de dépendance réseau aux outils utilitaires (base64, hash, JSON…) :
  l'intérêt du plugin est de fonctionner 100 % hors-ligne.
- Ne pas faire exécuter de commande shell arbitraire depuis `src/index.html` (pas de
  `fetch` vers un endpoint local qui `exec` des commandes) : seul `fetch` en lecture
  vers l'API locale d'ngrok (`127.0.0.1:4040`) est acceptable, car en lecture seule et
  sans élévation de privilège.
- Ne pas committer de token ngrok, mot de passe, ou tout secret dans le dépôt — ils
  restent dans la config locale de l'utilisateur (`ngrok config add-authtoken`).
