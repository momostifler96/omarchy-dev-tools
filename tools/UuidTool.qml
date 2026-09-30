import QtQuick
import qs.Commons
import qs.Ui
import "../Helpers.js" as Helpers

ToolHeader {
  id: root
  title: "Générateur UUID"
  description: "Génère des UUID v4."

  function run() {
    var n = Math.max(1, Math.min(100, parseInt(count.text) || 1))
    var out2 = []
    for (var i = 0; i < n; i++) out2.push(Helpers.uuidV4())
    result.text = out2.join("\n")
    result.kind = "ok"
  }

  Row {
    spacing: Style.space(8)
    DevTextField { id: count; label: "Quantité (1-100)"; placeholder: "5"; width: Style.space(120); onAccepted: root.run() }
    Button {
      anchors.bottom: parent.bottom
      text: "Générer"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
      onClicked: root.run()
    }
    CopyButton { anchors.bottom: parent.bottom; value: result.text }
  }

  ResultBox { id: result }
  Component.onCompleted: run()
}
