import QtQuick
import QtQuick.Controls
import qs.Commons

// Zone de texte multi-lignes avec label (les TextArea de QtQuick.Controls,
// stylées à la main — qs.Ui n'a pas d'équivalent multi-ligne).
Column {
  id: root
  property string label: ""
  property string placeholder: ""
  property alias text: area.text
  property real areaHeight: Style.space(90)
  property color fg: Color.popups.text

  spacing: Style.space(4)
  width: parent ? parent.width : 0

  Text {
    visible: root.label !== ""
    text: root.label
    color: root.fg
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }

  ScrollView {
    id: scroller
    width: parent.width
    height: root.areaHeight
    contentWidth: availableWidth

    TextArea {
      id: area
      color: root.fg
      placeholderText: root.placeholder
      placeholderTextColor: Color.muted
      wrapMode: TextArea.Wrap
      font.family: Style.font.family
      font.pixelSize: Style.font.bodySmall
      background: Rectangle {
        color: Util.alpha(Color.popups.background, 0.6)
        border.width: Style.normalBorderWidth
        border.color: area.activeFocus ? Color.accent : Color.muted
        radius: Style.cornerRadius
      }
    }
  }
}
