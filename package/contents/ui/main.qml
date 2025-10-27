import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import "components" as Components
import org.kde.kwin

PlasmaCore.Dialog {
  id: mainDialog

  location: PlasmaCore.Types.Floating
  flags: Qt.X11BypassWindowManagerHint | Qt.FramelessWindowHint
  visible: false

  property variant screenList: getScreens()

  function getScreens() {
    var tmpList = ['Auto Display']
    for (var i = 0; i < Workspace.screens.length; i++) {
      tmpList.push("Display " + (i + 1))
    }
    return tmpList
  }

  function show() {
    var screen = Workspace.clientArea(KWin.FullScreenArea, Workspace.activeScreen, Workspace.currentDesktop)
    mainDialog.visible = true
    mainDialog.x = screen.x + screen.width/2 - mainDialog.width/2
    mainDialog.y = screen.y + screen.height/2 - mainDialog.height/2
  }

  function tileWindow(window, tileConfig) {
    if (!window.normalWindow) return

    var screen = null
    let getDisplayNum = tileConfig.display

    if(getDisplayNum > -1) {
      screen = Workspace.clientArea(KWin.FullScreenArea, Workspace.screens[getDisplayNum], Workspace.currentDesktop)
      Workspace.sendClientToScreen(window, Workspace.screens[getDisplayNum])
    } else {
      screen = Workspace.clientArea(KWin.FullScreenArea, Workspace.activeScreen, Workspace.currentDesktop)
    }

    let newWidth = ((tileConfig.width / 100) * (screen.width))
    let newHeight = ((tileConfig.height / 100) * (screen.height))
    let newX = ((tileConfig.x / 100) * (screen.width)) + screen.x
    let newY = ((tileConfig.y / 100) * (screen.height)) + screen.y

    window.setMaximize(false, false)
    window.frameGeometry = Qt.rect(newX, newY, newWidth, newHeight)

    mainDialog.visible = false
  }

  Item {
    id: shortcuts

    ShortcutHandler {
      id: mainShortcut
      name: "kTile"
      text: "kTile"
      sequence: "Ctrl+."
      onActivated: {
        if (mainDialog.visible) {
          mainDialog.visible = false
        } else {
          mainDialog.show()
        }
      }
    }
  }

  Rectangle {
    width: 850
    height: 400
    color: "transparent"

    Components.Edit {
      id: editScreen
      anchors.fill: parent
      anchors.margins: 10
    }
  }
}