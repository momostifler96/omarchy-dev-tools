import QtQuick
import qs.Commons
import qs.Ui

// Ligne titre + description réutilisée en tête de chaque outil.
Column {
  id: root
  property string title: ""
  property string description: ""
  property color fg: Color.popups.text
  default property alias content: inner.data

  spacing: Style.space(6)
  width: parent ? parent.width : 0

  Text {
    text: root.title
    color: root.fg
    font.family: Style.font.family
    font.pixelSize: Style.font.heading
    font.weight: Font.DemiBold
  }

  Text {
    visible: root.description !== ""
    text: root.description
    color: Color.muted
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
    wrapMode: Text.WordWrap
    width: parent ? parent.width : 0
  }

  Column {
    id: inner
    width: parent ? parent.width : 0
    spacing: Style.space(8)
    topPadding: Style.space(4)
  }
}
