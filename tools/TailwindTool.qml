import QtQuick
import Quickshell
import qs.Commons
import qs.Ui
import "../Helpers.js" as Helpers

ToolHeader {
  id: root
  title: "Générateur de palette Tailwind"
  description: "Génère les 11 nuances (50 → 950) d'une couleur de base, façon uicolors.app. La nuance 500 correspond à la couleur saisie."

  property var palette: []
  property string paletteName: "brand"

  readonly property string configOut: paletteName + ": {\n" +
    palette.map(function(p) { return "  " + p.key + ": '" + p.hex + "'," }).join("\n") + "\n},"

  readonly property string cssOut: ":root {\n" +
    palette.map(function(p) { return "  --color-" + paletteName + "-" + p.key + ": " + p.hex + ";" }).join("\n") + "\n}"

  function run() {
    try {
      palette = Helpers.tailwindPalette(hexIn.text)
      errLabel.visible = false
    } catch (e) {
      palette = []
      errLabel.text = "Couleur invalide: " + e.message
      errLabel.visible = true
    }
    paletteName = (nameIn.text.trim() || "brand").toLowerCase().replace(/[^a-z0-9-]/g, "-")
  }

  Row {
    width: root.width
    spacing: Style.space(8)
    DevTextField { id: hexIn; label: "Couleur de base"; placeholder: "#ccae12"; text: "#ccae12"; width: (root.width - Style.space(8)) / 2; onAccepted: root.run() }
    DevTextField { id: nameIn; label: "Nom (pour l'export)"; placeholder: "brand"; text: "brand"; width: (root.width - Style.space(8)) / 2; onAccepted: root.run() }
  }

  Text {
    id: errLabel
    visible: false
    color: Color.urgent
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }

  Row {
    visible: root.palette.length > 0
    spacing: Style.space(6)

    Repeater {
      model: root.palette

      delegate: Column {
        id: swatchCol
        required property var modelData
        spacing: Style.space(2)

        Rectangle {
          width: Style.space(40); height: Style.space(40)
          radius: Style.cornerRadius
          color: swatchCol.modelData.hex
          border.width: Style.normalBorderWidth
          border.color: Util.alpha(Color.popups.text, 0.15)

          Text {
            anchors.centerIn: parent
            text: swatchCol.modelData.key
            color: Helpers.textColorFor(swatchCol.modelData.rgb)
            font.family: "monospace"
            font.pixelSize: Style.font.caption
          }

          MouseArea {
            anchors.fill: parent
            onClicked: Quickshell.clipboardText = swatchCol.modelData.hex
          }
        }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: swatchCol.modelData.hex
          color: Color.muted
          font.family: "monospace"
          font.pixelSize: 9
        }
      }
    }
  }

  Text {
    visible: root.palette.length > 0
    text: "Astuce: clique sur une nuance pour copier son hex."
    color: Color.muted
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }

  Text {
    visible: root.palette.length > 0
    text: "Config Tailwind (tailwind.config.js)"
    color: Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }
  ResultBox { visible: root.palette.length > 0; text: root.configOut }

  Row {
    visible: root.palette.length > 0
    spacing: Style.space(8)
    CopyButton { value: root.configOut; label: "Copier la config" }
    CopyButton { value: root.cssOut; label: "Copier le CSS" }
  }

  Text {
    visible: root.palette.length > 0
    text: "Variables CSS"
    color: Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }
  ResultBox { visible: root.palette.length > 0; text: root.cssOut }

  Component.onCompleted: run()
}
