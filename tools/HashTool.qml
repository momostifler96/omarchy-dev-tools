import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

ToolHeader {
  id: root
  title: "Hash de texte"
  description: "Calcule le hash SHA-1 / SHA-256 / SHA-384 / SHA-512 d'un texte (via shaNNNsum)."

  function run() {
    var algo = algoSel.value
    var cmd = "printf '%s' \"$1\" | " + algo.toLowerCase().replace("-", "") + "sum | cut -d' ' -f1"
    hashProc.command = ["bash", "-c", cmd, "bash", input.text]
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
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: { out.text = text.trim(); out.kind = "ok" }
    }
    onExited: function(code) {
      if (code !== 0) { out.text = "Erreur: hachage impossible (algo non supporté ?)"; out.kind = "err" }
    }
  }

  Component.onCompleted: run()
}
