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

  // v3 : objet à placer dans theme.extend.colors de tailwind.config.js.
  readonly property string v3Out: "'" + paletteName + "': {\n" +
    palette.map(function(p) { return "  '" + p.key + "': '" + p.hex + "'," }).join("\n") + "\n},"

  // v4 : configuration CSS-first, bloc @theme du fichier CSS principal.
  readonly property string v4Out: "@theme {\n" +
    palette.map(function(p) { return "  --color-" + paletteName + "-" + p.key + ": " + p.hex + ";" }).join("\n") + "\n}"

  readonly property bool isV4: versionSel.value === "Tailwind v4"
  readonly property string exportOut: isV4 ? v4Out : v3Out

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
    id: swatchRow
    visible: root.palette.length > 0
    spacing: Style.space(6)
    // 11 nuances sur la largeur disponible, 40 px max.
    readonly property real cell: Math.min(Style.space(40), Math.floor((root.width - spacing * 10) / 11))

    Repeater {
      model: root.palette

      delegate: Column {
        id: swatchCol
        required property var modelData
        width: swatchRow.cell
        spacing: Style.space(2)

        Rectangle {
          width: swatchRow.cell; height: swatchRow.cell
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
          width: swatchRow.cell
          horizontalAlignment: Text.AlignHCenter
          text: swatchCol.modelData.hex
          color: Util.alpha(Color.popups.text, 0.7)
          font.family: "monospace"
          font.pixelSize: 9
          fontSizeMode: Text.HorizontalFit
          minimumPixelSize: 6
        }
      }
    }
  }

  Text {
    visible: root.palette.length > 0
    text: "Astuce: clique sur une nuance pour copier son hex."
    color: Util.alpha(Color.popups.text, 0.7)
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }

  Dropdown {
    id: versionSel
    visible: root.palette.length > 0
    label: "Version"
    value: "Tailwind v4"
    options: ["Tailwind v4", "Tailwind v3"]
    foreground: Color.popups.text
    width: Style.space(160)
  }

  Text {
    visible: root.palette.length > 0
    width: root.width
    text: root.isV4
      ? "À coller dans votre CSS principal, après @import \"tailwindcss\"; (classes bg-" + root.paletteName + "-500…)"
      : "À coller dans theme.extend.colors de tailwind.config.js (classes bg-" + root.paletteName + "-500…)"
    color: Util.alpha(Color.popups.text, 0.7)
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
    wrapMode: Text.WordWrap
  }
  ResultBox { visible: root.palette.length > 0; text: root.exportOut }

  CopyButton {
    visible: root.palette.length > 0
    value: root.exportOut
    label: root.isV4 ? "Copier le @theme (v4)" : "Copier la config (v3)"
  }

  Component.onCompleted: run()
}
