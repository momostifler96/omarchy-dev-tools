import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

ToolHeader {
  id: root
  title: "Exposer un serveur local avec ngrok"
  description: "Génère la commande pour exposer un port local publiquement, configure l'authtoken si absent, et affiche en direct le(s) tunnel(s) actif(s) via l'API locale d'ngrok (http://127.0.0.1:4040)."

  property bool active: false
  property bool ngrokInstalled: true
  property bool tokenConfigured: false
  property string tokenStatus: "Vérification…"
  property bool installLaunched: false

  // Ouvre un terminal interactif pour l'installation (prompt sudo/mot de passe),
  // puis re-vérifie automatiquement toutes les 4s.
  function installNgrok() {
    installLaunched = true
    installProc.command = ["foot", "-e", "bash", "-c",
      "yay -S --needed ngrok; echo; echo 'Installation terminée (ou interrompue) — ferme cette fenêtre.'; read -r _"]
    installProc.running = true
    installPoll.restart()
  }

  function updateCmd() {
    var p = port.text.trim() || "3000"
    var o = opts.text.trim()
    cmdBox.text = "omarchy-ngrok " + p + (o ? " " + o : "")
    cmdBox.kind = "ok"
  }

  function checkToken() {
    tokenProc.running = true
  }

  function saveToken() {
    var t = tokenField.text.trim()
    if (t === "") {
      tokenStatus = "Entre un authtoken d'abord (gratuit sur dashboard.ngrok.com)."
      return
    }
    tokenSaveProc.command = ["ngrok", "config", "add-authtoken", t]
    tokenSaveProc.running = true
  }

  DevTextField { id: port; label: "Port local à exposer"; placeholder: "3000"; onTextChanged: root.updateCmd(); onAccepted: root.updateCmd() }
  DevTextField { id: opts; label: "Options ngrok supplémentaires (optionnel)"; placeholder: "--domain=mondomaine.ngrok-free.app"; onTextChanged: root.updateCmd(); onAccepted: root.updateCmd() }

  // ---------- Authtoken + installation ----------

  // Proposition d'installation si ngrok est absent
  Row {
    visible: !root.ngrokInstalled && !root.installLaunched
    width: root.width
    spacing: Style.space(8)

    Text {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - installBtn.width - revokeBtn.width - parent.spacing * 2
      text: "ngrok n'est pas installé. L'installer via yay (AUR) ?"
      color: Color.urgent
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }

    Button {
      id: installBtn
      anchors.verticalCenter: parent.verticalCenter
      text: "Installer"
      accent: Color.accent
      fontFamily: Style.font.family
      fontSize: Style.font.caption
      onClicked: root.installNgrok()
    }

    Button {
      id: revokeBtn
      anchors.verticalCenter: parent.verticalCenter
      text: "Non"
      fontFamily: Style.font.family
      fontSize: Style.font.caption
      onClicked: root.installLaunched = true   // masque la proposition
    }
  }

  Text {
    visible: !root.ngrokInstalled && root.installLaunched
    text: "Installation en cours dans un terminal (mot de passe sudo demandé)… vérification automatique toutes les 4s."
    color: Util.alpha(Color.popups.text, 0.7)
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
    wrapMode: Text.WordWrap
    width: root.width
  }

  Timer {
    id: installPoll
    interval: 4000
    repeat: true
    running: root.installLaunched && !root.ngrokInstalled
    onTriggered: root.checkToken()
  }

  Process {
    id: installProc
    running: false
  }

  Row {
    width: root.width
    spacing: Style.space(8)

    Text {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - tokenBadge.width - parent.spacing
      text: "Authtoken ngrok"
      color: Color.popups.text
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      font.weight: Font.DemiBold
    }

    Text {
      id: tokenBadge
      anchors.verticalCenter: parent.verticalCenter
      text: !root.ngrokInstalled ? "✗ ngrok non installé" : root.tokenConfigured ? "✓ configuré" : "✗ absent"
      color: !root.ngrokInstalled ? Color.urgent : root.tokenConfigured ? Color.accent : Color.urgent
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }
  }

  Row {
    width: root.width
    spacing: Style.space(8)
    DevTextField {
      id: tokenField
      label: !root.ngrokInstalled
        ? "Installe ngrok d'abord (sudo pacman -S ngrok, ou voir ngrok.com/download)"
        : "Authtoken (dashboard.ngrok.com → Your Authtoken)"
      placeholder: root.tokenConfigured ? "déjà configuré — coller un nouveau token pour le remplacer" : "2abc…_xyz"
      width: parent.width - Style.space(180)
      enabled: root.ngrokInstalled
      onAccepted: root.saveToken()
    }
    Button {
      anchors.bottom: parent.bottom
      text: tokenSaveProc.running ? "…" : "Enregistrer"
      enabled: root.ngrokInstalled && !tokenSaveProc.running
      accent: Color.accent
      fontFamily: Style.font.family
      fontSize: Style.font.caption
      onClicked: root.saveToken()
    }
  }

  Text {
    visible: root.tokenStatus !== ""
    text: root.tokenStatus
    color: root.tokenConfigured ? Color.accent : Color.urgent
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
    wrapMode: Text.WordWrap
    width: root.width
  }

  // ---------- Commande + tunnels ----------

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

  // ---------- Processus ----------

  // Vérifie : ngrok installé ? authtoken configuré ?
  Process {
    id: tokenProc
    command: ["bash", "-c", "command -v ngrok >/dev/null 2>&1 && ngrok config check 2>&1 || echo __MISSING__"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var t = text.trim()
        if (t.indexOf("__MISSING__") !== -1) {
          root.ngrokInstalled = false
          root.tokenConfigured = false
          root.tokenStatus = "ngrok n'est pas installé sur cette machine."
        } else {
          root.ngrokInstalled = true
          root.tokenConfigured = t.indexOf("authtoken") === -1 && t.indexOf("ERROR") === -1 && t.indexOf("error") === -1
          root.tokenStatus = root.tokenConfigured
            ? "Authtoken configuré" + (t !== "" ? " — " + t.split("\n")[0] : "") + "."
            : "Aucun authtoken : colle-le ci-dessus puis clique sur Enregistrer."
        }
      }
    }
  }

  Process {
    id: tokenSaveProc
    stdout: StdioCollector { waitForEnd: true }
    stderr: StdioCollector { waitForEnd: true }
    onExited: function(code) {
      if (code === 0) {
        tokenField.text = ""
        root.checkToken()
      } else {
        var out = (stderrCollector.text || stdoutCollector.text).trim()
        root.tokenStatus = "Erreur : " + (out !== "" ? out.split("\n").pop() : "échec de l'enregistrement")
      }
    }
  }

  Component.onCompleted: { updateCmd(); checkToken() }
}
