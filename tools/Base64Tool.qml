import QtQuick
import qs.Commons
import qs.Ui
import "../Helpers.js" as Helpers

ToolHeader {
  id: root
  title: "Base64"
  description: "Encode et décode du texte en Base64 (UTF-8)."

  DevTextArea { id: input; label: "Texte"; placeholder: "Texte à encoder/décoder" }

  Row {
    spacing: Style.space(8)
    Button {
      text: "Encoder"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
      onClicked: { try { out.text = Helpers.utf8ToBase64(input.text); out.kind = "ok" } catch (e) { out.text = "Erreur: " + e.message; out.kind = "err" } }
    }
    Button {
      text: "Décoder"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
      onClicked: { try { out.text = Helpers.base64ToUtf8(input.text.replace(/\s+/g, "")); out.kind = "ok" } catch (e) { out.text = "Erreur: " + e.message; out.kind = "err" } }
    }
    CopyButton { value: out.text }
  }

  ResultBox { id: out }
}
