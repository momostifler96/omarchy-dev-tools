// Logique pure portée depuis src/index.html (version web).
// Fonctions entrée → sortie, aucun accès DOM.
.pragma library

// ---------- Encodage ----------

function utf8ToBase64(s) {
  return Qt.btoa(unescape(encodeURIComponent(s)))
}

function base64ToUtf8(s) {
  return decodeURIComponent(escape(Qt.atob(s)))
}

function b64urlDecode(str) {
  str = String(str).replace(/-/g, "+").replace(/_/g, "/")
  while (str.length % 4) str += "="
  return base64ToUtf8(str)
}

// ---------- Générateurs ----------

function uuidV4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0
    var v = c === 'x' ? r : (r & 0x3 | 0x8)
    return v.toString(16)
  })
}

var LOREM_WORDS = ("lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod " +
  "tempor incididunt ut labore et dolore magna aliqua ut enim ad minim veniam quis nostrud " +
  "exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat").split(" ")

function loremParagraph() {
  var n = 30 + Math.floor(Math.random() * 30)
  var words = []
  for (var i = 0; i < n; i++) words.push(LOREM_WORDS[Math.floor(Math.random() * LOREM_WORDS.length)])
  var s = words.join(" ")
  return s.charAt(0).toUpperCase() + s.slice(1) + "."
}

// ---------- Texte & données ----------

function caseWords(s) {
  return s.replace(/([a-z])([A-Z])/g, "$1 $2")
          .replace(/[_\-]+/g, " ")
          .trim().split(/\s+/).filter(Boolean).map(function(w) { return w.toLowerCase() })
}

function casesFrom(s) {
  var w = caseWords(s)
  function cap(x) { return x.charAt(0).toUpperCase() + x.slice(1) }
  return {
    camel:    w.map(function(x, i) { return i === 0 ? x : cap(x) }).join(""),
    pascal:   w.map(cap).join(""),
    snake:    w.join("_"),
    kebab:    w.join("-"),
    constant: w.join("_").toUpperCase()
  }
}

function diffLines(aText, bText) {
  var a = aText.split("\n"), b = bText.split("\n")
  var max = Math.max(a.length, b.length), lines = []
  for (var i = 0; i < max; i++) {
    var la = i < a.length ? a[i] : undefined
    var lb = i < b.length ? b[i] : undefined
    if (la === lb) lines.push("  " + (la !== undefined ? la : ""))
    else {
      if (la !== undefined) lines.push("- " + la)
      if (lb !== undefined) lines.push("+ " + lb)
    }
  }
  return lines.join("\n")
}

var CRON_FIELDS = ["minute", "heure", "jour du mois", "mois", "jour de la semaine"]

function describeCronField(val, name) {
  if (val === "*") return "chaque " + name
  if (val.indexOf("/") !== -1) {
    var p = val.split("/")
    return (p[0] === "*" ? "chaque" : p[0]) + " " + name + " par pas de " + p[1]
  }
  if (val.indexOf("-") !== -1) return name + " de " + val.replace("-", " à ")
  if (val.indexOf(",") !== -1) return name + " ∈ {" + val + "}"
  return name + " = " + val
}

function explainCron(expr) {
  var parts = expr.trim().split(/\s+/)
  if (parts.length !== 5) return null
  var out = []
  for (var i = 0; i < 5; i++) out.push(describeCronField(parts[i], CRON_FIELDS[i]))
  return out.join("\n")
}

function regexMatches(pattern, flags, text) {
  var reAll = new RegExp(pattern, flags.indexOf("g") !== -1 ? flags : flags + "g")
  var matches = [], m
  while ((m = reAll.exec(text)) !== null) {
    matches.push({
      index: m.index,
      value: m[0],
      groups: m.length > 1 ? JSON.stringify(m.slice(1)) : ""
    })
    if (m.index === reAll.lastIndex) reAll.lastIndex++
  }
  return matches
}

// ---------- Couleurs ----------

function parseColor(v) {
  v = v.trim()
  var rgb
  if (v.charAt(0) === "#") {
    var hex = v.replace("#", "")
    if (hex.length === 3) hex = hex.split("").map(function(c) { return c + c }).join("")
    if (!/^[0-9a-fA-F]{6}$/.test(hex)) throw new Error("hex invalide")
    var n = parseInt(hex, 16)
    rgb = [(n >> 16) & 255, (n >> 8) & 255, n & 255]
  } else if (v.indexOf("rgb") === 0) {
    var pr = v.match(/[\d.]+/g)
    if (!pr || pr.length < 3) throw new Error("rgb invalide")
    rgb = [Number(pr[0]), Number(pr[1]), Number(pr[2])]
  } else if (v.indexOf("hsl") === 0) {
    var ph = v.match(/[\d.]+/g)
    if (!ph || ph.length < 3) throw new Error("hsl invalide")
    var h = Number(ph[0]), s = Number(ph[1]), l = Number(ph[2])
    var c = (1 - Math.abs(2 * l / 100 - 1)) * s / 100
    var x = c * (1 - Math.abs((h / 60) % 2 - 1))
    var m = l / 100 - c / 2
    var r1, g1, b1
    if (h < 60)       { r1 = c; g1 = x; b1 = 0 }
    else if (h < 120) { r1 = x; g1 = c; b1 = 0 }
    else if (h < 180) { r1 = 0; g1 = c; b1 = x }
    else if (h < 240) { r1 = 0; g1 = x; b1 = c }
    else if (h < 300) { r1 = x; g1 = 0; b1 = c }
    else              { r1 = c; g1 = 0; b1 = x }
    rgb = [Math.round((r1 + m) * 255), Math.round((g1 + m) * 255), Math.round((b1 + m) * 255)]
  } else {
    throw new Error("format non reconnu")
  }
  return rgb
}

function rgbToHex(rgb) {
  return "#" + rgb.map(function(c) {
    return Math.round(Math.min(255, Math.max(0, c))).toString(16).padStart(2, "0")
  }).join("")
}

function rgbToHsl(rgb) {
  var r = rgb[0] / 255, g = rgb[1] / 255, b = rgb[2] / 255
  var max = Math.max(r, g, b), min = Math.min(r, g, b)
  var h, s, l = (max + min) / 2
  if (max === min) { h = s = 0 }
  else {
    var d = max - min
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
    if (max === r) h = (g - b) / d + (g < b ? 6 : 0)
    else if (max === g) h = (b - r) / d + 2
    else h = (r - g) / d + 4
    h /= 6
  }
  return [Math.round(h * 360), Math.round(s * 100), Math.round(l * 100)]
}

// ---------- Palette Tailwind ----------

var TAILWIND_SHADES = [
  { key: "50",  mix: "white", amount: 0.95 },
  { key: "100", mix: "white", amount: 0.90 },
  { key: "200", mix: "white", amount: 0.75 },
  { key: "300", mix: "white", amount: 0.60 },
  { key: "400", mix: "white", amount: 0.30 },
  { key: "500", mix: "base",  amount: 0 },
  { key: "600", mix: "black", amount: 0.10 },
  { key: "700", mix: "black", amount: 0.25 },
  { key: "800", mix: "black", amount: 0.40 },
  { key: "900", mix: "black", amount: 0.55 },
  { key: "950", mix: "black", amount: 0.75 }
]

function relativeLuminance(rgb) {
  var f = function(c) { c /= 255; return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4) }
  return 0.2126 * f(rgb[0]) + 0.7152 * f(rgb[1]) + 0.0722 * f(rgb[2])
}

function textColorFor(rgb) {
  return relativeLuminance(rgb) > 0.4 ? "#14151a" : "#f5f5f7"
}

function tailwindPalette(baseHex) {
  var base = parseColor("#" + String(baseHex).trim().replace("#", ""))
  var white = [255, 255, 255], black = [0, 0, 0]
  return TAILWIND_SHADES.map(function(sh) {
    var rgb
    if (sh.mix === "base") rgb = base
    else {
      var t = sh.mix === "white" ? white : black
      rgb = base.map(function(c, i) { return c + (t[i] - c) * sh.amount })
    }
    return { key: sh.key, hex: rgbToHex(rgb), rgb: rgb.map(Math.round) }
  })
}

// ---------- Timestamp ----------

function timestampReport(v) {
  if (Math.abs(v) < 1e11) v *= 1000
  var d = new Date(v)
  if (isNaN(d.getTime())) return null
  return "ISO:    " + d.toISOString() +
       "\nUTC:    " + d.toUTCString() +
       "\nLocal:  " + d.toString() +
       "\nUnix s: " + Math.floor(d.getTime() / 1000) +
       "\nUnix ms:" + d.getTime()
}

function dateReport(s) {
  var d = new Date(s.trim())
  if (isNaN(d.getTime())) return null
  return timestampReport(d.getTime())
}
