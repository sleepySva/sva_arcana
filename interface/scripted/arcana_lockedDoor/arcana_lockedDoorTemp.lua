function init()
  self.activateItem = config.getParameter("activateItem")
  self.required = config.getParameter("requiredCount")
  self.itemImagePath = config.getParameter("itemImagePath")
  widget.setImage("itemImage", self.itemImagePath)

  update()
end

function update(dt)
  local current = player.hasCountOfItem(self.activateItem)
  widget.setText("costLabel", string.format("%s / %s", current, self.required))
  widget.setFontColor("costLabel", current >= self.required and {255, 255, 255} or {255, 0, 0})
  widget.setButtonEnabled("activateButton", current >= self.required)
end

function activate()
  if player.hasItem({name = self.activateItem}) then
    world.sendEntityMessage(pane.sourceEntity(), "activate")
    pane.dismiss()
  end
end
