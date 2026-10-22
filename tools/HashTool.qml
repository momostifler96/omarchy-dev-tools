import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

ToolHeader {
  id: root
  title: "Hash de texte"
  description: "Calcule le hash SHA-1 / SHA-256 / SHA-384 / SHA-512 d'un texte (via shaNNNsum)."

  // Le texte passe par stdin, jamais en argument : /proc/<pid>/cmdline est
  // lisible par tous les utilisateurs locaux.
  function run() {
    if (hashProc.running) return
    hashProc.payload = input.text
    hashProc.stdinEnabled = true
    hashProc.command = [algoSel.value.toLowerCase().replace("-", "") + "sum"]
    hashProc.running = true
  }

  DevTextArea { id: input; label: "Texte"; placeholder: "Texte à hacher" }

  Row {
    spacing: Style.space(8)
    Dropdown {
      id: algoSel
      label: "Algorithme"
      value: "SHA-256"
      options: ["SHA-1", "SHA-256", "SHA-384", "SHA-512"]
      foreground: Color.popups.text
      width: Style.space(160)
      onValueChanged: root.run()
    }
    Button {
      anchors.bottom: parent.bottom
      text: "Calculer"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
      onClicked: root.run()
    }
  }

  ResultBox { id: out }

  Process {
    id: hashProc
    property string payload: ""
    stdinEnabled: true
    onStarted: { write(payload); stdinEnabled = false }
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: { out.text = text.split(" ")[0].trim(); out.kind = "ok" }
    }
    onExited: function(code) {
      if (code !== 0) { out.text = "Erreur: hachage impossible (algo non supporté ?)"; out.kind = "err" }
    }
  }

  Component.onCompleted: run()
}
