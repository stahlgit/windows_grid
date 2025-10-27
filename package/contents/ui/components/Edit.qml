import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kwin

Rectangle {
  property var dragging: false
  property int cols: 8
  property int rows: 6
  property double storeX: 0
  property double storeY: 0
  property double previewWidth: 0
  property double previewHeight: 0
  property double previewX: 0
  property double previewY: 0
  property string backgroundColor: "#5f5f5f"
  property string selectionColor: "#ffffff"
  property string hoverColor: "#4996ff"
  property double selectedDisplay: 0

  id: edit
  color: "transparent"

  ColumnLayout {
    anchors.fill: parent

    RowLayout {

      PlasmaComponents.SpinBox {
        width: 0
        height: 0
        value: cols
        from: 1
        to: 20
        onValueChanged: {
          cols = value
          lines.requestPaint()
        }
      }

      PlasmaComponents.Label {
        text: "x"
      }

      PlasmaComponents.SpinBox {
        width: 0
        height: 0
        value: rows
        from: 1
        to: 20
        onValueChanged: {
          rows = value
          lines.requestPaint()
        }
      }

      PlasmaComponents.Label {
        text: "|"
      }

      PlasmaComponents.SpinBox {
        width: 0
        height: 0
        to: 24
      }

      PlasmaComponents.Label {
        text: "|"
        visible: screenList.length > 2
      }

      PlasmaComponents.ComboBox {
        id: displayCombo
        width: 200
        model: screenList
        visible: screenList.length > 2

        onCurrentIndexChanged: {
          selectedDisplay = displayCombo.currentIndex - 1
        }
        
        Component.onCompleted: {
          displayCombo.currentIndex = 0
        }
      }

      PlasmaComponents.Button {
        Layout.fillWidth: true
        enabled: false
        opacity: 0
      }
      


      PlasmaComponents.Button {
        icon.name: "dialog-close"
        onClicked: {
          mainDialog.visible = false
        }
      }
    }

    Rectangle {
      Layout.fillWidth: true
      Layout.fillHeight: true
      color: backgroundColor
      
      MouseArea {
        id: grid
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        property double cellWidth: parent.width / cols
        property double cellHeight: parent.height / rows

        onPositionChanged: (mouse) => {
          var getGridX = Math.floor(mouse.x / cellWidth)
          var getGridY = Math.floor(mouse.y / cellHeight)

          if(
            mouse.x >= 0 &&
            mouse.x <= parent.width &&
            mouse.y >= 0 &&
            mouse.y <= parent.height &&
            getGridX < cols &&
            getGridY < rows
          ) {
            if(!dragging) {
              // mouse hover
              hoverBox.width = (cellWidth)
              hoverBox.height = (cellHeight)
              hoverBox.x = ((cellWidth * getGridX))
              hoverBox.y = ((cellHeight * getGridY))

            } else {
              // mouse drag
              var directionX = getGridX - storeX
              var directionY = getGridY - storeY

              var cellCountX = (directionX < 0 ? directionX * -1 : directionX) + 1
              var cellCountY = (directionY < 0 ? directionY * -1 : directionY) + 1

              if(directionX < 1) {
                hoverBox.x = ((cellWidth * getGridX))
                previewX = (cellWidth * getGridX)
              }

              if(directionY < 1) {
                hoverBox.y = ((cellHeight * getGridY))
                previewY = (cellHeight * getGridY)
              }

              hoverBox.width = ((cellWidth * cellCountX))
              hoverBox.height = ((cellHeight * cellCountY))

              previewWidth = (cellWidth * cellCountX)
              previewHeight = (cellHeight * cellCountY)
            }
          }
        }

        onPressed: (mouse) => {
          dragging = true
          storeX = Math.floor(mouse.x / (parent.width / cols))
          storeY = Math.floor(mouse.y / (parent.height / rows))
        }

        onReleased: {
          dragging = false
          
          shapePreview.width = hoverBox.width
          shapePreview.height = hoverBox.height
          shapePreview.x = hoverBox.x
          shapePreview.y = hoverBox.y

          // Apply tiling immediately on release
          if (previewWidth > 0 && previewHeight > 0) {
            var tileConfig = {
              width: (100 * previewWidth) / grid.width,
              height: (100 * previewHeight) / grid.height,
              x: (100 * previewX) / grid.width,
              y: (100 * previewY) / grid.height,
              display: selectedDisplay
            }

            tileWindow(Workspace.activeWindow, tileConfig)
          }
        }
      }

      Rectangle {
        id: shapePreview
        width: 0
        height: 0
        x: 0
        y: 0
        color: selectionColor
      }

      Rectangle {
        id: hoverBox
        width: 0
        height: 0
        color: hoverColor
      }

      Canvas {
        property double cellWidth: parent.width / cols
        property double cellHeight: parent.height / rows
        id: lines
        anchors.fill: parent
        visible: true
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.lineWidth = 1
          ctx.strokeStyle = "black"
          ctx.beginPath()

          var nrows = parent.height/cellHeight
          for(var i=0; i < nrows+1; i++){
            ctx.moveTo(0, cellHeight*i)
            ctx.lineTo(parent.width, cellHeight*i)
          }

          var ncols = parent.width/cellWidth
          for(var j=0; j < ncols+1; j++){
            ctx.moveTo(cellWidth*j, 0)
            ctx.lineTo(cellWidth*j, parent.height)
          }

          ctx.closePath()
          ctx.stroke()
        }
      }
    }
  }
}