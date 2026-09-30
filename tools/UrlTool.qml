import QtQuick
import qs.Commons
import qs.Ui
import "../Helpers.js" as Helpers

ToolHeader {
  id: root
  title: "URL Encode / Decode"
  description: "Encodage et décodage d'URL (percent-encoding)."

  DevTextArea { id: input; label: "Texte"; placeholder: "https://exemple.com/?q=à bientôt" }

  Row {
    spacing: Style.space(8)
    Button {
      text: "Encoder"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
      onClicked: { out.text = encodeURIComponent(input.text); out.kind = "ok" }
    }
    Button {
      text: "Décoder"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
      onClicked: { try { out.text = decodeURIComponent(input.text); out.kind = "ok" } catch (e) { out.text = "Erreur: " + e.message; out.kind = "err" } }
    }
    CopyButton { value: out.text }
  }

  ResultBox { id: out }
}
