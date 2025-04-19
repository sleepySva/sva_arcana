function init()
end
function update(dt)
end

function setWidget(widgetName)
  player.interact("scriptPane", widget.getData(widgetName))
end

function setWidgetwithPaneDismiss(widgetName)
  setWidget(widgetName)
  pane.dismiss()
end