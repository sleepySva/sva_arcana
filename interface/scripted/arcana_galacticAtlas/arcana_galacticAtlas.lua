require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rect.lua"

function init()

end

function update(dt)

end

function teleport()
  self.destinationName = widget.getSelectedData("destinationTabs")
  if (self.destinationName) then
	player.warp(string.format("instanceWorld:%s", self.destinationName), "beam")
	pane.dismiss()
  end
end

function setDestinationImage()
  self.destinationName = widget.getSelectedData("destinationTabs")
  if (self.destinationName) then
   widget.setImage("destinationImage", string.format("/interface/scripted/arcana_galacticAtlas/%s.png", self.destinationName))
  end
end