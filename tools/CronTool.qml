import QtQuick
import qs.Commons
import qs.Ui
import "../Helpers.js" as Helpers

ToolHeader {
  id: root
  title: "Explicateur d'expression cron"
  description: "Décrit en texte une expression cron classique (5 champs)."

  function run() {
    var res = Helpers.explainCron(input.text)
    if (res === null) { out.text = "Erreur: une expression cron standard a 5 champs (minute heure jour mois jour_semaine)"; out.kind = "err"; return }
    out.text = res
    out.kind = "ok"
  }

  DevTextField { id: input; label: "Expression cron"; placeholder: "*/5 9-17 * * 1-5"; onAccepted: root.run() }

  Button {
    text: "Expliquer"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
    onClicked: root.run()
  }

  ResultBox { id: out }
}
