import QtQuick
import qs.Commons
import qs.Ui
import "../Helpers.js" as Helpers

ToolHeader {
  id: root
  title: "Comparateur de texte (ligne à ligne)"
  description: "Compare deux blocs de texte ligne par ligne."

  function run() {
    var res = Helpers.diffLines(a.text, b.text)
    out.text = res === "" ? "Identiques." : res
    out.kind = "ok"
  }

  Row {
    width: root.width
    spacing: Style.space(8)
    DevTextArea { id: a; label: "Texte A"; areaHeight: Style.space(100); width: (root.width - Style.space(8)) / 2 }
    DevTextArea { id: b; label: "Texte B"; areaHeight: Style.space(100); width: (root.width - Style.space(8)) / 2 }
  }

  Button {
    text: "Comparer"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
    onClicked: root.run()
  }

  ResultBox { id: out }
}
