import QtQuick
import qs.Commons
import qs.Ui
import "../Helpers.js" as Helpers

ToolHeader {
  id: root
  title: "Convertisseur de timestamp"
  description: "Unix timestamp ⇄ date lisible (UTC et locale)."

  function report(d) {
    out.text = "ISO:    " + d.toISOString() +
             "\nUTC:    " + d.toUTCString() +
             "\nLocal:  " + d.toString() +
             "\nUnix s: " + Math.floor(d.getTime() / 1000) +
             "\nUnix ms:" + d.getTime()
    out.kind = "ok"
  }

  function fromTs() {
    var v = parseFloat(tsIn.text.trim())
    if (isNaN(v)) { out.text = "Timestamp invalide"; out.kind = "err"; return }
    if (Math.abs(v) < 1e11) v *= 1000
    report(new Date(v))
  }

  function fromDate() {
    var d = new Date(dateIn.text.trim())
    if (isNaN(d.getTime())) { out.text = "Date invalide"; out.kind = "err"; return }
    report(d)
  }

  Row {
    width: root.width
    spacing: Style.space(8)
    DevTextField { id: tsIn; label: "Timestamp (s ou ms)"; placeholder: "1735689600"; width: (root.width - Style.space(8)) / 2; onAccepted: root.fromTs() }
    DevTextField { id: dateIn; label: "Date ISO"; placeholder: "2026-01-01T00:00:00Z"; width: (root.width - Style.space(8)) / 2; onAccepted: root.fromDate() }
  }

  Row {
    spacing: Style.space(8)
    Button { text: "Depuis timestamp"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption; onClicked: root.fromTs() }
    Button { text: "Depuis date"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption; onClicked: root.fromDate() }
    Button {
      text: "Maintenant"; fontFamily: Style.font.family; fontSize: Style.font.caption
      onClicked: { var d = new Date(); tsIn.text = Math.floor(d.getTime() / 1000); root.report(d) }
    }
  }

  ResultBox { id: out }
}
