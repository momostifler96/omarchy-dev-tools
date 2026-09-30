import QtQuick
import qs.Commons
import qs.Ui
import "../Helpers.js" as Helpers

ToolHeader {
  id: root
  title: "JWT Decoder"
  description: "Décode un JSON Web Token (header + payload). Ne vérifie pas la signature."

  function run() {
    var parts = input.text.trim().split(".")
    if (parts.length < 2) { out.text = "Erreur: JWT invalide (attendu header.payload.signature)"; out.kind = "err"; return }
    try {
      var header = JSON.parse(Helpers.b64urlDecode(parts[0]))
      var payload = JSON.parse(Helpers.b64urlDecode(parts[1]))
      out.text = "HEADER\n" + JSON.stringify(header, null, 2) + "\n\nPAYLOAD\n" + JSON.stringify(payload, null, 2)
      out.kind = "ok"
    } catch (e) { out.text = "Erreur de décodage: " + e.message; out.kind = "err" }
  }

  DevTextArea { id: input; label: "Token JWT"; placeholder: "eyJhbGciOi..." }

  Button {
    text: "Décoder"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
    onClicked: root.run()
  }

  ResultBox { id: out }
}
