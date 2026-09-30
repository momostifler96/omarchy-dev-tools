import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "tools" as Tools

// Panneau Dev Tools : sidebar (recherche + outils groupés) + zone outil active.
// Hérite de qs.Ui.Panel ; l'ouverture/fermeture est pilotée par le widget de
// barre (Widget.qml) qui injecte bar/settings/anchorItem/hostWidget.
Panel {
  id: root
  moduleName: "momoledev.dev-tools"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root
  readonly property color fg: bar ? bar.foreground : Color.popups.text

  property string currentTool: ""

  function open(payloadJson) {
    root.controller.show()
    Qt.callLater(function() { if (root.opened) keyCatcher.forceActiveFocus() })
  }
  function close() { root.controller.hide() }
  function toggle() { root.opened ? root.close() : root.open() }
  function closeForPopoutSwitch() { root.close() }
  function switchPanel(direction) {
    return root.bar && root.bar.switchPanelFrom ? root.bar.switchPanelFrom(root.barIdentity, direction) : false
  }

  // Persistance du dernier outil (fichier JSON dans ~/.local/state)
  readonly property string statePath: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/dev-tools.json"
  property string lastTool: "base64"

  FileView {
    id: stateFile
    path: root.statePath
    watchChanges: false
    printErrors: false
    onLoaded: {
      try {
        var s = JSON.parse(text())
        if (s.lastTool) root.lastTool = s.lastTool
        if (root.currentTool === "") root.selectTool(root.lastTool)
      } catch (e) {}
    }
    onLoadFailed: function(error) { root.selectTool(root.lastTool) }
  }

  function saveState() {
    stateFile.setText(JSON.stringify({ lastTool: root.currentTool }))
    stateFile.writeAdapter()
  }

  // ---------- Registre des outils ----------
  readonly property var toolRegistry: [
    { id: "base64",   name: "Base64",                   category: "Encodage",        file: "Base64Tool.qml" },
    { id: "url",      name: "URL Encode/Decode",        category: "Encodage",        file: "UrlTool.qml" },
    { id: "jwt",      name: "JWT Decoder",              category: "Sécurité",        file: "JwtTool.qml" },
    { id: "hash",     name: "Hash SHA",                 category: "Sécurité",        file: "HashTool.qml" },
    { id: "uuid",     name: "Générateur UUID",          category: "Générateurs",     file: "UuidTool.qml" },
    { id: "lorem",    name: "Lorem Ipsum",              category: "Générateurs",     file: "LoremTool.qml" },
    { id: "json",     name: "JSON Formatter",           category: "Texte & données", file: "JsonTool.qml" },
    { id: "regex",    name: "Testeur Regex",            category: "Texte & données", file: "RegexTool.qml" },
    { id: "textcase", name: "Convertisseur de casse",   category: "Texte & données", file: "TextCaseTool.qml" },
    { id: "diff",     name: "Comparateur de texte",     category: "Texte & données", file: "DiffTool.qml" },
    { id: "color",    name: "Convertisseur couleurs",   category: "Design",          file: "ColorTool.qml" },
    { id: "tailwind", name: "Palette Tailwind",         category: "Design",          file: "TailwindTool.qml" },
    { id: "timestamp",name: "Convertisseur Timestamp",  category: "Date & heure",    file: "TimestampTool.qml" },
    { id: "cron",     name: "Explicateur Cron",         category: "Date & heure",    file: "CronTool.qml" },
    { id: "vhost",    name: "Gestionnaire de vhosts",   category: "Réseau local",    file: "VhostTool.qml" },
    { id: "ngrok",    name: "Exposer via ngrok",        category: "Réseau local",    file: "NgrokTool.qml" }
  ]

  function selectTool(id) {
    var tool = null
    for (var i = 0; i < toolRegistry.length; i++) if (toolRegistry[i].id === id) tool = toolRegistry[i]
    if (!tool) return
    currentTool = id
    root.saveState()
  }

  function toolById(id) {
    for (var i = 0; i < toolRegistry.length; i++) if (toolRegistry[i].id === id) return toolRegistry[i]
    return toolRegistry[0]
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    centerOnBar: true
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(760))
    contentHeight: panel.fittedContentHeight(Style.space(520))

    Rectangle {
      anchors.fill: parent
      color: Color.popups.background
      border.width: Style.normalBorderWidth
      border.color: Color.popups.border
      radius: Style.cornerRadius

      Row {
        id: layout
        anchors.fill: parent
        anchors.margins: Style.space(12)
        spacing: Style.space(12)

        // ---------- Sidebar ----------
        Column {
          id: sidebar
          height: parent.height
          width: Style.space(210)
          spacing: Style.space(8)

          Text {
            text: "Dev Tools"
            color: root.fg
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            font.weight: Font.DemiBold
          }

          TextField {
            id: searchField
            width: parent.width
            placeholderText: "Rechercher…"
            foreground: root.fg
            font.pixelSize: Style.font.bodySmall
          }

          // Liste groupée par catégorie
          ScrollView {
            id: listScroll
            width: parent.width
            height: sidebar.height - Style.space(56)
            contentWidth: availableWidth
            clip: true

            Column {
              width: listScroll.availableWidth
              spacing: Style.space(2)

              Repeater {
                model: root.toolRegistry

                delegate: Column {
                  id: entryCol
                  required property var modelData
                  required property int index
                  visible: {
                    var f = searchField.text.trim().toLowerCase()
                    return f === "" || modelData.name.toLowerCase().indexOf(f) !== -1
                  }
                  width: parent.width

                  Text {
                    visible: entryCol.isFirstOfCategory
                    text: entryCol.modelData.category
                    color: Style.muted
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    font.weight: Font.DemiBold
                    topPadding: Style.space(6)
                    bottomPadding: Style.space(2)
                  }

                  // astuce: isFirstOfCategory calculé via le modèle
                  readonly property bool isFirstOfCategory: {
                    var f = searchField.text.trim().toLowerCase()
                    var cat = entryCol.modelData.category
                    var regs = root.toolRegistry
                    for (var i = 0; i < entryCol.index; i++) {
                      if (regs[i].category === cat && (f === "" || regs[i].name.toLowerCase().indexOf(f) !== -1)) return false
                    }
                    return true
                  }

                  Rectangle {
                    width: parent.width
                    height: toolLabel.implicitHeight + Style.space(10)
                    radius: Style.cornerRadius
                    color: root.currentTool === entryCol.modelData.id ? Util.alpha(Color.accent, 0.22)
                         : toolBtn.containsMouse ? Util.alpha(root.fg, 0.08) : "transparent"

                    Text {
                      id: toolLabel
                      anchors.left: parent.left
                      anchors.leftMargin: Style.space(8)
                      anchors.verticalCenter: parent.verticalCenter
                      text: entryCol.modelData.name
                      color: root.currentTool === entryCol.modelData.id ? Color.accent : root.fg
                      font.family: Style.font.family
                      font.pixelSize: Style.font.bodySmall
                      elide: Text.ElideRight
                      width: parent.width - Style.space(16)
                    }

                    MouseArea {
                      id: toolBtn
                      anchors.fill: parent
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      onClicked: root.selectTool(entryCol.modelData.id)
                    }
                  }
                }
              }
            }
          }
        }

        // ---------- Zone outil ----------
        Column {
          width: parent.width - sidebar.width - Style.space(12)
          spacing: Style.space(8)

          Text {
            text: root.toolById(root.currentTool).name
            color: root.fg
            font.family: Style.font.family
            font.pixelSize: Style.font.subtitle
            font.weight: Font.DemiBold
          }

          Rectangle { width: parent.width; height: 1; color: Util.alpha(root.fg, 0.12) }

          ScrollView {
            width: parent.width
            height: layout.height - Style.space(30)
            contentWidth: availableWidth
            clip: true

            Loader {
              id: toolLoader
              width: parent.width
              source: root.currentTool !== "" ? Qt.resolvedUrl("tools/" + root.toolById(root.currentTool).file) + "?v=" + Date.now() : ""
            }
          }
        }
      }
    }

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      // Bloqué dès qu'un autre item (champ de recherche, champs d'outils,
      // TextArea…) a le focus — sinon le catcher avale les touches.
      blocked: {
        var win = panel.contentItem ? panel.contentItem.window : null
        if (!win) return false
        var fi = win.activeFocusItem
        return fi && fi !== keyCatcher
      }
      onCloseRequested: root.close()
    }
  }

  onOpenedChanged: {
    if (opened && currentTool === "") selectTool(root.lastTool)
  }

  Component.onCompleted: if (currentTool === "") selectTool(root.lastTool)
}
