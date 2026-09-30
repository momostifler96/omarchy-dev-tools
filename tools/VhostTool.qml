import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

ToolHeader {
  id: root
  title: "Gestionnaire de vhosts"
  description: "Ajoute un domaine local (ex: monapp.test) pointé vers un port, avec reverse proxy nginx en option. La création/suppression exécutent la commande via pkexec (dialogue mot de passe graphique)."

  property var vhosts: []          // [{domain, scheme, source}]
  property string status: ""
  property string statusKind: "neutral"
  property bool busy: listProc.running || execProc.running
  property bool hasNginx: true
  property bool hasMkcert: false
  property bool installLaunched: false

  // Dépendances manquantes selon les options choisies
  readonly property var missingDeps: {
    var m = []
    if (!hasNginx) m.push("nginx")
    if (useHttps.checked && hasNginx && !hasMkcert) m.push("mkcert")
    return m
  }

  function installDeps() {
    installLaunched = true
    installProc.command = ["foot", "-e", "bash", "-c",
      "yay -S --needed " + missingDeps.join(" ") +
      "; echo; echo 'Installation terminée (ou interrompue) — ferme cette fenêtre.'; read -r _"]
    installProc.running = true
    depsPoll.restart()
  }

  function checkDeps() {
    depsProc.running = true
  }

  // ---------- Commandes ----------

  function addFlags() {
    var flags = []
    if (!useNginx.checked) flags.push("--no-nginx")
    if (useHttps.checked) flags.push("--https")
    return flags
  }

  function addCommand() {
    var d = domain.text.trim() || "monapp.test"
    var p = port.text.trim() || "3000"
    var f = addFlags()
    return "pkexec omarchy-vhost add " + d + " " + p + (f.length ? " " + f.join(" ") : "")
  }

  function updateCmd() {
    addCmd.text = addCommand()
    addCmd.kind = "neutral"
    otherCmds.text = "omarchy-vhost list\npkexec omarchy-vhost remove " + (domain.text.trim() || "monapp.test")
  }

  function runCreate() {
    setStatus("Création en cours (validez le dialogue mot de passe)…", "neutral")
    var args = ["omarchy-vhost", "add", domain.text.trim() || "monapp.test", port.text.trim() || "3000"].concat(addFlags())
    execProc.mode = "add"
    execProc.command = ["pkexec"].concat(args)
    execProc.running = true
  }

  function runRemove(d) {
    setStatus("Suppression de « " + d + " » (validez le dialogue mot de passe)…", "neutral")
    execProc.mode = "remove"
    execProc.command = ["pkexec", "omarchy-vhost", "remove", d]
    execProc.running = true
  }

  function runList() {
    listProc.running = true
  }

  function refreshList(output) {
    var found = []
    var lines = output.split("\n")
    var inNginx = false
    for (var i = 0; i < lines.length; i++) {
      var l = lines[i]
      if (l.indexOf("nginx") !== -1) { inNginx = true; continue }
      var mHosts = l.match(/^\s*127\.0\.0\.1\s+(\S+)/)
      if (mHosts) { found.push({ domain: mHosts[1], scheme: "", source: inNginx ? "nginx" : "hosts" }); continue }
      var mNgx = l.match(/^\s*-\s+(\S+)\s+\[(\w+)\]/)
      if (mNgx) { found.push({ domain: mNgx[1], scheme: mNgx[2], source: "nginx" }) }
    }
    // dédoublonne (même domaine présent dans hosts + nginx)
    var seen = {}, uniq = []
    for (var j = 0; j < found.length; j++) {
      var k = found[j].domain + "|" + found[j].scheme
      if (!seen[k]) { seen[k] = true; uniq.push(found[j]) }
    }
    root.vhosts = uniq
  }

  function setStatus(msg, kind) {
    status = msg
    statusKind = kind
  }

  // ---------- Dépendances ----------

  Process {
    id: depsProc
    command: ["bash", "-c", "for c in nginx mkcert; do command -v $c >/dev/null 2>&1 && echo \"$c:1\" || echo \"$c:0\"; done"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var lines = text.trim().split("\n")
        for (var i = 0; i < lines.length; i++) {
          var p = lines[i].split(":")
          if (p[0] === "nginx") root.hasNginx = p[1] === "1"
          if (p[0] === "mkcert") root.hasMkcert = p[1] === "1"
        }
      }
    }
  }

  Process {
    id: installProc
    running: false
  }

  Timer {
    id: depsPoll
    interval: 4000
    repeat: true
    running: root.installLaunched && root.missingDeps.length > 0
    onTriggered: root.checkDeps()
  }

  // ---------- Exécution ----------

  Process {
    id: listProc
    command: ["omarchy-vhost", "list"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.refreshList(text)
    }
    onExited: function(code) {
      if (code !== 0) root.setStatus("Erreur lors du listage.", "err")
    }
  }

  Process {
    id: execProc
    property string mode: "add"
    stdout: StdioCollector { waitForEnd: true }
    stderr: StdioCollector { waitForEnd: true }

    onExited: function(code) {
      var out = (stdoutCollector.text + "\n" + stderrCollector.text).trim()
      if (code === 0) {
        root.setStatus(execProc.mode === "add" ? "Vhost créé avec succès." : "Vhost supprimé.", "ok")
        root.runList()
      } else {
        // 126 = annulé dans pkexec (mot de passe refusé / dialogue fermé)
        root.setStatus(code === 126 || code === 127
          ? "Action annulée ou pkexec indisponible."
          : "Erreur (" + code + ") : " + out.split("\n").pop(), "err")
      }
    }
  }

  // ---------- UI ----------

  Row {
    width: root.width
    spacing: Style.space(8)
    DevTextField { id: domain; label: "Domaine"; placeholder: "monapp.test"; width: (root.width - Style.space(8)) / 2; onTextChanged: root.updateCmd(); onAccepted: root.runCreate() }
    DevTextField { id: port; label: "Port local"; placeholder: "3000"; width: (root.width - Style.space(8)) / 2; onTextChanged: root.updateCmd(); onAccepted: root.runCreate() }
  }

  Row {
    spacing: Style.space(16)
    Toggle {
      id: useNginx
      label: "Reverse proxy nginx"
      checked: true
      foreground: Color.popups.text
      accent: Color.accent
      fontFamily: Style.font.family
      onClicked: { checked = !checked; if (!checked) useHttps.checked = false; root.updateCmd() }
    }
    Toggle {
      id: useHttps
      label: "HTTPS local"
      checked: false
      foreground: Color.popups.text
      accent: Color.accent
      fontFamily: Style.font.family
      onClicked: { checked = useNginx.checked ? !checked : false; root.updateCmd() }
    }
  }

  // ---------- Dépendances manquantes ----------

  Row {
    visible: root.missingDeps.length > 0 && !root.installLaunched
    width: root.width
    spacing: Style.space(8)

    Text {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - installDepsBtn.width - noBtn.width - parent.spacing * 2
      text: "Dépendance(s) manquante(s) : " + root.missingDeps.join(", ") +
            (root.missingDeps.indexOf("mkcert") !== -1 ? " — après installation, lance « mkcert -install » une fois pour faire confiance au CA local." : "") +
            " Installer via yay ?"
      color: Color.urgent
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }

    Button {
      id: installDepsBtn
      anchors.verticalCenter: parent.verticalCenter
      text: "Installer"
      accent: Color.accent
      fontFamily: Style.font.family
      fontSize: Style.font.caption
      onClicked: root.installDeps()
    }

    Button {
      id: noBtn
      anchors.verticalCenter: parent.verticalCenter
      text: "Non"
      fontFamily: Style.font.family
      fontSize: Style.font.caption
      onClicked: root.installLaunched = true
    }
  }

  Text {
    visible: root.installLaunched && root.missingDeps.length > 0
    text: "Installation en cours dans un terminal (mot de passe sudo demandé)… vérification automatique toutes les 4s."
    color: Util.alpha(Color.popups.text, 0.7)
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
    wrapMode: Text.WordWrap
    width: root.width
  }

  Row {
    spacing: Style.space(8)
    Button {
      text: root.busy ? "…" : "Créer le vhost"
      accent: Color.accent
      enabled: !root.busy
      fontFamily: Style.font.family
      fontSize: Style.font.caption
      onClicked: root.runCreate()
    }
    Button {
      text: "Lister"
      enabled: !root.busy
      fontFamily: Style.font.family
      fontSize: Style.font.caption
      onClicked: root.runList()
    }
    CopyButton { value: root.addCommand(); label: "Copier la commande" }
  }

  ResultBox { id: addCmd; kind: "neutral" }

  Text {
    text: "Autres commandes utiles"
    color: Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }
  ResultBox { id: otherCmds; kind: "neutral" }

  // ---------- Liste des vhosts ----------

  Row {
    spacing: Style.space(8)
    Text {
      text: "Vhosts existants"
      color: Color.popups.text
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      font.weight: Font.DemiBold
    }
    Button {
      anchors.verticalCenter: parent.verticalCenter
      text: "↻"
      enabled: !root.busy
      tooltipText: "Rafraîchir"
      fontFamily: Style.font.family
      fontSize: Style.font.caption
      onClicked: root.runList()
    }
  }

  Text {
    visible: root.vhosts.length === 0
    text: root.busy ? "Chargement…" : "Aucun vhost géré par omarchy-vhost."
    color: Util.alpha(Color.popups.text, 0.7)
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }

  Column {
    width: root.width
    spacing: Style.space(4)

    Repeater {
      model: root.vhosts

      delegate: Rectangle {
        id: row
        required property var modelData
        width: root.width
        implicitHeight: Style.space(30)
        radius: Style.cornerRadius
        color: Util.alpha(Color.popups.background, 0.5)

        Row {
          anchors.left: parent.left
          anchors.leftMargin: Style.space(8)
          anchors.right: removeBtn.left
          anchors.rightMargin: Style.space(8)
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(8)

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: row.modelData.domain
            color: Color.popups.text
            font.family: "monospace"
            font.pixelSize: Style.font.caption
            elide: Text.ElideRight
            width: parent.width - schemeTag.width - parent.spacing
          }

          Text {
            id: schemeTag
            anchors.verticalCenter: parent.verticalCenter
            visible: row.modelData.scheme !== ""
            text: row.modelData.scheme
            color: Color.accent
            font.family: "monospace"
            font.pixelSize: Style.font.caption
          }
        }

        Button {
          id: removeBtn
          anchors.right: parent.right
          anchors.rightMargin: Style.space(6)
          anchors.verticalCenter: parent.verticalCenter
          text: "Supprimer"
          enabled: !root.busy
          foreground: Color.urgent
          fontFamily: Style.font.family
          fontSize: Style.font.caption
          onClicked: root.runRemove(row.modelData.domain)
        }
      }
    }
  }

  Text {
    visible: root.status !== ""
    text: root.status
    color: root.statusKind === "err" ? Color.urgent : root.statusKind === "ok" ? Color.accent : Util.alpha(Color.popups.text, 0.7)
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
    wrapMode: Text.WordWrap
    width: root.width
  }

  Component.onCompleted: { updateCmd(); runList(); checkDeps() }
}
