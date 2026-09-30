import QtQuick
import qs.Commons
import qs.Ui
import "../Helpers.js" as Helpers

ToolHeader {
  id: root
  title: "Testeur de regex"
  description: "Teste une expression régulière JavaScript contre un texte."

  function run() {
    try {
      var matches = Helpers.regexMatches(pattern.text, flags.text, text.text)
      if (!matches.length) { out.text = "Aucune correspondance."; out.kind = "neutral"; return }
      var lines = []
      for (var i = 0; i < matches.length; i++) {
        var m = matches[i]
        lines.push("#" + i + ": \"" + m.value + "\" @" + m.index + (m.groups ? "  groupes: " + m.groups : ""))
      }
      out.text = lines.join("\n")
      out.kind = "ok"
    } catch (e) { out.text = "Regex invalide: " + e.message; out.kind = "err" }
  }

  Row {
    width: parent.width
    spacing: Style.space(8)
    DevTextField { id: pattern; label: "Regex"; placeholder: "\\d+"; width: (parent.width - Style.space(8)) / 2 }
    DevTextField { id: flags; label: "Flags"; placeholder: "g, i, m…"; text: "g"; width: (parent.width - Style.space(8)) / 2 }
  }

  DevTextArea { id: text; label: "Texte à tester"; placeholder: "123 abc 456" }

  Button {
    text: "Tester"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
    onClicked: root.run()
  }

  ResultBox { id: out }
}
