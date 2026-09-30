import QtQuick
import qs.Commons
import qs.Ui
import "../Helpers.js" as Helpers

ToolHeader {
  id: root
  title: "Convertisseur de casse"
  description: "camelCase, snake_case, kebab-case, PascalCase, CONSTANT_CASE…"

  function run() {
    var c = Helpers.casesFrom(input.text)
    out.text = "camelCase:     " + c.camel +
             "\nPascalCase:    " + c.pascal +
             "\nsnake_case:    " + c.snake +
             "\nkebab-case:    " + c.kebab +
             "\nCONSTANT_CASE: " + c.constant
    out.kind = "ok"
  }

  DevTextArea { id: input; label: "Texte"; placeholder: "Hello World Example" }

  Row {
    spacing: Style.space(8)
    Button {
      text: "Convertir"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
      onClicked: root.run()
    }
    CopyButton { value: out.text }
  }

  ResultBox { id: out }
}
