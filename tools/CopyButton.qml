import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

// Bouton "Copier" : copie `value` au clipboard, feedback visuel 1.5s.
Button {
  id: root
  property string value: ""
  property color fg: Color.popups.text

  text: copied ? "Copié ✓" : "Copier"
  foreground: copied ? Color.accent : root.fg
  fontFamily: Style.font.family
  fontSize: Style.font.caption
  bordered: true

  readonly property bool copied: copyTimer.running

  Timer {
    id: copyTimer
    interval: 1500
  }

  onClicked: {
    if (root.value !== "") {
      Quickshell.clipboardText = root.value
      copyTimer.restart()
    }
  }
}
