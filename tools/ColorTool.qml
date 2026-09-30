import QtQuick
import qs.Commons
import qs.Ui
import "../Helpers.js" as Helpers

ToolHeader {
  id: root
  title: "Convertisseur de couleurs"
  description: "Convertit entre HEX, RGB et HSL."

  function run() {
    try {
      var rgb = Helpers.parseColor(input.text)
      var hex = Helpers.rgbToHex(rgb)
      var hsl = Helpers.rgbToHsl(rgb)
      swatch.color = hex
      out.text = "HEX: " + hex +
               "\nRGB: rgb(" + rgb.join(", ") + ")" +
               "\nHSL: hsl(" + hsl[0] + ", " + hsl[1] + "%, " + hsl[2] + "%)"
      out.kind = "ok"
    } catch (e) {
      swatch.color = "transparent"
      out.text = "Erreur: " + e.message
      out.kind = "err"
    }
  }

  Row {
    width: parent.width
    spacing: Style.space(8)
    DevTextField {
      id: input; label: "Couleur (hex, rgb(...) ou hsl(...))"; placeholder: "#7aa2f7"
      width: parent.width - Style.space(60)
      onAccepted: root.run()
    }
    Rectangle {
      id: swatch
      anchors.bottom: parent.bottom
      width: Style.space(52); height: Style.space(36)
      color: "transparent"
      border.width: Style.normalBorderWidth
      border.color: Util.alpha(Color.popups.text, 0.2)
      radius: Style.cornerRadius
    }
  }

  Button {
    text: "Convertir"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
    onClicked: root.run()
  }

  ResultBox { id: out }
}
