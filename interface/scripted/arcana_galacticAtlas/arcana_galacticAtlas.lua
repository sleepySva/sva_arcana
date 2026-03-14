require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rect.lua"

function init()
  rearrangeLocationsList()
  self.locationList = "locationArea.locationList"
  self.locationSelected = nil
  self.buttons = {}
  populateLocationList()
  widget.setButtonEnabled("activateButton", false)
end

function update(dt)
  teleportButtonCheck("beamToShipButton")
  teleportButtonCheck("activateButton")
end

function teleport()
  local location = self.locationSelected
  if location then
	player.warp(string.format("instanceWorld:%s", location), "beam")
	pane.dismiss()
  end
end

function teleportToShip()
  if player.worldId() ~= player.ownShipWorldId() then
    player.warp("OwnShip", "beam")
    pane.dismiss()
  end
end

function rearrangeLocationsList()
  local loc = root.assetJson("/interface/scripted/arcana_galacticAtlas/locations.config")
  self.locations = {}

  for _, i in pairs(loc) do
    table.insert(self.locations, i)
  end
  table.sort(self.locations, function(a,b)
    return (a.order or 0) < (b.order or 0)
  end)
end

function populateLocationList()
  widget.clearListItems(self.locationList)
  self.buttons = {}

  for _, location in ipairs(self.locations) do
    if not (location.requiredQuest ~= "none" and not player.hasCompletedQuest(location.requiredQuest) and location.requiredHidden) then
      local item = widget.addListItem(self.locationList)
	  table.insert(self.buttons, item)
	
	  if location.requiredQuest ~= "none" and not player.hasCompletedQuest(location.requiredQuest) then
	    -- Locked
	    widget.setText(string.format("%s.%s.questName", self.locationList, item), "^shadow;"..location.requiredQuestName.."^reset;")
		widget.setVisible(string.format("%s.%s.lock", self.locationList, item), true)
		widget.setFontColor(string.format("%s.%s.name", self.locationList, item), {60, 60, 60})
		widget.setImage(string.format("%s.%s.icon", self.locationList, item), location.icon.."?brightness=-50?saturation=-100")
		widget.setText(string.format("%s.%s.name", self.locationList, item), "^shadow;???^reset;")
	  else
	    -- Normal
	    widget.setVisible(string.format("%s.%s.lock", self.locationList, item), false)
		widget.setImage(string.format("%s.%s.icon", self.locationList, item), location.icon)
		widget.setText(string.format("%s.%s.name", self.locationList, item), "^shadow;"..location.name.."^reset;")
	  end
	  
	  widget.setImage(string.format("%s.%s.preview", self.locationList, item), location.background.."?brightness=-50?saturation=-50")
	  widget.setData(string.format("%s.%s", self.locationList, item), location)
	end
  end
end

function selectLocation()
  local selected = widget.getListSelected(self.locationList)
  local data = widget.getData(string.format("%s.%s", self.locationList, selected))
  
  if data.requiredQuest ~= "none" and not player.hasCompletedQuest(data.requiredQuest) then return end
  
  for _, button in pairs(self.buttons) do
    local item = string.format("%s.%s", self.locationList, button)
	local itemData = widget.getData(item)
    widget.setImage(item..".preview", itemData.background.."?brightness=-50?saturation=-50")
	widget.setImage(item..".top", "/interface/scripted/arcana_galacticAtlas/backgrounds/top.png")
  end
  
  self.locationSelected = data.warp
  widget.setImage(string.format("%s.%s.preview", self.locationList, selected), data.background)
  widget.setImage(string.format("%s.%s.top", self.locationList, selected), "/interface/scripted/arcana_galacticAtlas/backgrounds/topselected.png")
  widget.setButtonEnabled("activateButton", true)
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
  if self.locationSelected == nil and button == "activateButton" then return end
  widget.setButtonEnabled(button, teleportLegalCheck())
end