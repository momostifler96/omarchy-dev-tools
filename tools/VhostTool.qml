import QtQuick
import qs.Commons
import qs.Ui

ToolHeader {
  id: root
  title: "Créer un vhost local"
  description: "Ajoute un domaine local (ex: monapp.test) pointé vers un port, avec reverse proxy nginx en option. Nécessite sudo : la commande est générée ici, à exécuter dans un terminal."

  function update() {
    var d = domain.text.trim() || "monapp.test"
    var p = port.text.trim() || "3000"
    if (!useNginx.checked) useHttps.checked = false

    var flags = []
    if (!useNginx.checked) flags.push("--no-nginx")
    if (useHttps.checked) flags.push("--https")

    addCmd.text = "sudo omarchy-vhost add " + d + " " + p + (flags.length ? " " + flags.join(" ") : "")
    addCmd.kind = "ok"
    otherCmds.text = "omarchy-vhost list\nsudo omarchy-vhost remove " + d
  }

  Row {
    width: root.width
    spacing: Style.space(8)
    DevTextField { id: domain; label: "Domaine"; placeholder: "monapp.test"; width: (root.width - Style.space(8)) / 2; onTextChanged: root.update(); onAccepted: root.update() }
    DevTextField { id: port; label: "Port local"; placeholder: "3000"; width: (root.width - Style.space(8)) / 2; onTextChanged: root.update(); onAccepted: root.update() }
  }

  Toggle {
    id: useNginx
    label: "Reverse proxy nginx"
    description: "Sinon : juste l'entrée /etc/hosts"
    checked: true
    foreground: Color.popups.text
    accent: Color.accent
    fontFamily: Style.font.family
    onClicked: { checked = !checked; root.update() }
  }

  Toggle {
    id: useHttps
    label: "HTTPS local"
    description: useHttps.checked ? "Nécessite nginx. Utilise mkcert si installé, sinon un certificat autosigné (openssl). Port 80 redirigé vers 443." : "Certificat local, port 80 redirigé vers 443"
    checked: false
    foreground: Color.popups.text
    accent: Color.accent
    fontFamily: Style.font.family
    onClicked: { checked = !checked; root.update() }
  }

  Text {
    text: "Commande à exécuter"
    color: Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }
  ResultBox { id: addCmd }

  CopyButton { value: addCmd.text }

  Text {
    text: "Autres commandes utiles"
    color: Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }
  ResultBox { id: otherCmds; kind: "neutral" }

  Component.onCompleted: update()
}
