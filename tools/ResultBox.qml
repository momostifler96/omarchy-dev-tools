import QtQuick
import qs.Commons

// Bloc de résultat monospace, états ok / err / neutre.
Rectangle {
  id: root
  property string text: ""
  property string kind: "neutral"   // "ok" | "err" | "neutral"
  property color fg: Color.popups.text
  readonly property color stateColor: kind === "err" ? Color.urgent
                                    : kind === "ok" ? Color.accent : Color.muted

  width: parent ? parent.width : 0
  implicitHeight: Math.max(Style.space(36), body.implicitHeight + Style.space(16))
  color: Util.alpha(Color.popups.background, 0.5)
  border.width: Style.normalBorderWidth
  border.color: Util.alpha(root.fg, 0.15)
  radius: Style.cornerRadius

  Text {
    id: body
    anchors.fill: parent
    anchors.margins: Style.space(8)
    text: root.text
    visible: root.text !== ""
    color: root.fg
    font.family: "monospace"
    font.pixelSize: Style.font.caption
    wrapMode: Text.WrapAnywhere
  }

  Text {
    anchors.centerIn: parent
    visible: root.text === ""
    text: "…"
    color: Color.muted
    font.family: "monospace"
    font.pixelSize: Style.font.caption
  }
}
