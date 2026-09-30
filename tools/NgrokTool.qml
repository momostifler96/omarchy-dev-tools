import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

ToolHeader {
  id: root
  title: "Exposer un serveur local avec ngrok"
  description: "Génère la commande pour exposer un port local publiquement, et affiche en direct le(s) tunnel(s) actif(s) via l'API locale d'ngrok (http://127.0.0.1:4040)."

  property bool active: false

  function updateCmd() {
    var p = port.text.trim() || "3000"
    var o = opts.text.trim()
    cmdBox.text = "omarchy-ngrok " + p + (o ? " " + o : "")
    cmdBox.kind = "ok"
  }

  DevTextField { id: port; label: "Port local à exposer"; placeholder: "3000"; onTextChanged: root.updateCmd(); onAccepted: root.updateCmd() }
  DevTextField { id: opts; label: "Options ngrok supplémentaires (optionnel)"; placeholder: "--domain=mondomaine.ngrok-free.app"; onTextChanged: root.updateCmd(); onAccepted: root.updateCmd() }

  Text {
    text: "Commande à lancer dans un terminal"
    color: Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }
  ResultBox { id: cmdBox }
  CopyButton { value: cmdBox.text }

  Text {
    text: "Tunnels actifs (rafraîchi toutes les 2s)"
    color: Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }
  ResultBox { id: statusBox; text: "Vérification…" }

  Timer {
    interval: 2000
    repeat: true
    triggeredOnStart: true
    running: root.active

    onTriggered: {
      var xhr = new XMLHttpRequest()
      xhr.open("GET", "http://127.0.0.1:4040/api/tunnels", true)
      xhr.onreadystatechange = function() {
        if (xhr.readyState !== XMLHttpRequest.DONE) return
        if (xhr.status !== 200) {
          statusBox.text = "Agent ngrok injoignable (lance d'abord la commande ci-dessus)."
          statusBox.kind = "err"
          return
        }
        try {
          var data = JSON.parse(xhr.responseText)
          if (!data.tunnels || !data.tunnels.length) {
            statusBox.text = "Aucun tunnel actif pour le moment."
            statusBox.kind = "neutral"
          } else {
            statusBox.text = data.tunnels.map(function(t) {
              return t.proto.toUpperCase() + "  " + t.public_url + "  →  " + t.config.addr
            }).join("\n")
            statusBox.kind = "ok"
          }
        } catch (e) {
          statusBox.text = "Réponse inattendue de l'agent ngrok."
          statusBox.kind = "err"
        }
      }
      xhr.send()
    }
  }

  Component.onCompleted: updateCmd()
}
