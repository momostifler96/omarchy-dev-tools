import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

ToolHeader {
  id: root
  title: "Générateur de token"
  description: "Génère des tokens / mots de passe aléatoires (source : /dev/urandom, sans biais de modulo)."

  readonly property string upper: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  readonly property string lower: "abcdefghijklmnopqrstuvwxyz"
  readonly property string digits: "0123456789"
  readonly property string symbols: "!@#$%^&*()-_=+[]{};:,.<>?/~"
  readonly property string ambiguous: "0Oo1lI|"

  readonly property string charset: {
    var s = ""
    if (useUpper.checked) s += upper
    if (useLower.checked) s += lower
    if (useDigits.checked) s += digits
    if (useSymbols.checked) s += symbols
    if (noAmbiguous.checked) s = s.split("").filter(function(c) { return ambiguous.indexOf(c) === -1 }).join("")
    return s
  }

  readonly property int tokenLength: Math.max(1, Math.min(512, parseInt(len.text) || 32))
  readonly property int tokenCount: Math.max(1, Math.min(50, parseInt(count.text) || 1))
  readonly property real entropyBits: charset.length > 1 ? tokenLength * Math.log(charset.length) / Math.LN2 : 0

  function run() {
    if (charset.length === 0) {
      result.text = "Sélectionne au moins un jeu de caractères."
      result.kind = "err"
      return
    }
    // Valeurs 16 bits : rejet quasi nul pour un alphabet ≤ 94 caractères,
    // marge de 25 % pour absorber les rejets restants.
    var needed = Math.ceil(tokenLength * tokenCount * 1.25) + 16
    randProc.command = ["od", "-An", "-tu2", "-N" + (needed * 2), "-v", "/dev/urandom"]
    randProc.running = true
  }

  function build(raw) {
    var cs = charset, n = cs.length
    var limit = 65536 - (65536 % n)
    var values = raw.trim().split(/\s+/)
    var tokens = [], cur = ""
    for (var i = 0; i < values.length && tokens.length < tokenCount; i++) {
      var v = parseInt(values[i])
      if (isNaN(v) || v >= limit) continue
      cur += cs.charAt(v % n)
      if (cur.length === tokenLength) { tokens.push(cur); cur = "" }
    }
    // Pas assez d'octets acceptés (très improbable) : on relance.
    if (tokens.length < tokenCount) { Qt.callLater(root.run); return }
    result.text = tokens.join("\n")
    result.kind = "ok"
  }

  Row {
    spacing: Style.space(8)
    DevTextField { id: len; label: "Longueur (1-512)"; placeholder: "32"; text: "32"; width: Style.space(120); onAccepted: root.run() }
    DevTextField { id: count; label: "Quantité (1-50)"; placeholder: "1"; text: "1"; width: Style.space(120); onAccepted: root.run() }
    Button {
      anchors.bottom: parent.bottom
      text: "Générer"; accent: Color.accent; fontFamily: Style.font.family; fontSize: Style.font.caption
      onClicked: root.run()
    }
    CopyButton { anchors.bottom: parent.bottom; value: result.text }
  }

  Grid {
    id: opts
    width: root.width
    columns: 2
    spacing: Style.space(8)
    readonly property real cellWidth: (width - spacing) / 2
    Toggle {
      id: useUpper; label: "Majuscules"; checked: true
      width: opts.cellWidth; titleSize: Style.font.bodySmall
      foreground: Color.popups.text; accent: Color.accent; fontFamily: Style.font.family
      onClicked: { checked = !checked; root.run() }
    }
    Toggle {
      id: useLower; label: "Minuscules"; checked: true
      width: opts.cellWidth; titleSize: Style.font.bodySmall
      foreground: Color.popups.text; accent: Color.accent; fontFamily: Style.font.family
      onClicked: { checked = !checked; root.run() }
    }
    Toggle {
      id: useDigits; label: "Chiffres"; checked: true
      width: opts.cellWidth; titleSize: Style.font.bodySmall
      foreground: Color.popups.text; accent: Color.accent; fontFamily: Style.font.family
      onClicked: { checked = !checked; root.run() }
    }
    Toggle {
      id: useSymbols; label: "Symboles"; checked: false
      width: opts.cellWidth; titleSize: Style.font.bodySmall
      foreground: Color.popups.text; accent: Color.accent; fontFamily: Style.font.family
      onClicked: { checked = !checked; root.run() }
    }
    Toggle {
      id: noAmbiguous; label: "Sans ambigus (0 O 1 l I)"; checked: false
      width: opts.cellWidth; titleSize: Style.font.bodySmall
      foreground: Color.popups.text; accent: Color.accent; fontFamily: Style.font.family
      onClicked: { checked = !checked; root.run() }
    }
  }

  Text {
    text: root.charset.length + " caractères possibles · ≈ " + Math.round(root.entropyBits) + " bits d'entropie"
          + (root.entropyBits >= 128 ? " (fort)" : root.entropyBits >= 64 ? " (correct)" : " (faible)")
    color: Util.alpha(Color.popups.text, 0.7)
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }

  ResultBox { id: result }

  Process {
    id: randProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.build(text)
    }
    onExited: function(code) {
      if (code !== 0) { result.text = "Erreur: lecture de /dev/urandom impossible"; result.kind = "err" }
    }
  }

  Component.onCompleted: run()
}
