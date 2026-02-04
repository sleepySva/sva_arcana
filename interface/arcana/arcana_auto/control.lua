require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rect.lua"

function init()
  self.entity = pane.containerEntityId()
  self.itemList = "itemList"
  self.progressWidget = "progress"
  self.stateWidget = "stateToggle"
  self.settings = world.getObjectParameter(self.entity, "settings")
  --sb.logInfo(dump(self.settings))
end

function update(dt)
end

--[[
function addAllowedItem()
  world.callScriptedEntity(pane.containerEntityId(), "setSettings", self.settings)
end
--]]

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o) or "NIL"
   end
end

-- display allowed items
function populateList()
  widget.clearListItems(self.itemList)
  if self.settings.allowedItems ~= nil then
    for _, item in pairs(self.settings.allowedItems) do
      local new = widget.addListItem(self.itemList)
      widget.setItemSlotItem(string.format("%s.%s.item", self.itemList, new), item)
	  widget.setData(string.format("%s.%s", self.itemList, new), item)
    end
  end
end

function itemCallback()
  sb.logInfo("itemCallback")
  local selected = widget.getListSelected(self.itemList)
end