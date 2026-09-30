import QtQuick
import qs.Commons
import qs.Ui

ToolHeader {
  id: root
  title: "JSON Formatter / Validator"
  description: "Formate, valide et minifie du JSON."

  function parse() { return JSON.parse(input.text) }

  DevTextArea { id: input; label: "JSON source"; placeholder: '{"a":1,"b":[1,2,3]}' }

  Row {
    spacing: Style.space(8)
    Button {
      text: "Formater"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
      onClicked: { try { out.text = JSON.stringify(root.parse(), null, 2); out.kind = "ok" } catch (e) { out.text = "JSON invalide: " + e.message; out.kind = "err" } }
    }
    Button {
      text: "Minifier"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
      onClicked: { try { out.text = JSON.stringify(root.parse()); out.kind = "ok" } catch (e) { out.text = "JSON invalide: " + e.message; out.kind = "err" } }
    }
    CopyButton { value: out.text }
  }

  ResultBox { id: out }
}
