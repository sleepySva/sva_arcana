require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rect.lua"

function init()
end

function update(dt)
  teleportButtonCheck("beamToShipButton")
  teleportButtonCheck("activateButton")
end

function teleport()
  self.destinationName = widget.getSelectedData("destinationTabs")
  if (self.destinationName) then
	player.warp(string.format("instanceWorld:%s", self.destinationName), "beam")
	pane.dismiss()
  end
end

function teleportToShip()
  if player.worldId() ~= player.ownShipWorldId() then
    player.warp("OwnShip", "beam")
    pane.dismiss()
  end
end

function setDestinationImage()
  self.destinationName = widget.getSelectedData("destinationTabs")
  if (self.destinationName) then
   widget.setImage("destinationImage", string.format("/interface/scripted/arcana_galacticAtlas/%s.png", self.destinationName))
  end
end

function teleportLegalCheck()
  local available 
  if not player.isAdmin() then
    local playerPos = world.entityPosition(player.id())
    if world.terrestrial() then
      if world.material(playerPos, "background") == false and world.underground(playerPos) == false then
        available = true
      else
        available = false
      end
    else available = true
    end
  else available = true
  end
  return available
end

function teleportButtonCheck(button)
  widget.setButtonEnabled(button, teleportLegalCheck())
end

