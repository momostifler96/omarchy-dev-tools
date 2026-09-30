import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

// Champ texte simple avec label, style shell Omarchy.
Column {
  id: root
  property string label: ""
  property string placeholder: ""
  property alias text: field.text
  property color fg: Color.popups.text
  signal accepted()

  spacing: Style.space(4)
  width: parent ? parent.width : 0

  Text {
    visible: root.label !== ""
    text: root.label
    color: root.fg
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }

  TextField {
    id: field
    width: parent.width
    placeholderText: root.placeholder
    foreground: root.fg
    font.pixelSize: Style.font.bodySmall
    Keys.onReturnPressed: root.accepted()
  }
}
