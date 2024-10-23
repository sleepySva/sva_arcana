--https://stackoverflow.com/questions/2282444/how-to-check-if-a-table-contains-an-element-in-lua
--https://stackoverflow.com/questions/2705793/how-to-get-number-of-entries-in-a-lua-table
require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.list = "blacklistArea.list"
  self.slot = "itemSlot"
  self.checkbox = "checkbox"
  self.slider = "slider"
  self.sliderLbl = "sliderlabel"
  self.blacklist = player.getProperty("itemblacklist") or {}
  self.defaultIcon = "/interface/statuses/x.png"
  self.capacity = config.getParameter("capacity", 80)
  self.capacityLbl = "capacity"
  populateList()
  if player.getProperty("ibsettings", nil) == nil or type(player.getProperty("ibsettings")) ~= "table" then player.setProperty("ibsettings", {enabled = true, delta = 1}) end
  widget.setChecked(self.checkbox, player.getProperty("ibsettings").enabled)
  widget.setSliderValue(self.slider, math.floor(player.getProperty("ibsettings").delta))
  frequency()
end

function update(dt)
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function removeElement(tbl, element)
  local list = {}
  for _, value in pairs(tbl) do
    if value ~= element then
      table.insert(list, value)
    end
  end
  return list
end

function select()
  local selected = widget.getListSelected(self.list)
  selected = widget.getData(string.format("%s.%s", self.list, selected))
  self.blacklist = removeElement(self.blacklist, selected)
  player.setProperty("itemblacklist", self.blacklist)
  populateList()
end

function populateList()
  local length = 0
  widget.clearListItems(self.list)
  if self.blacklist ~= nil then
    for _, name in pairs(self.blacklist) do
      length = length + 1
	  local itemImage = ""
      local item = widget.addListItem(self.list)
	  local config = root.itemConfig(name).config
	  local isString = ((type(root.itemConfig(name).directory) == "string") and (type(config.inventoryIcon) == "string"))
	  if (config.inventoryIcon ~= nil and not contains(root.itemTags(name), "weapon")) and isString == true then
	    itemImage = util.absolutePath(root.itemConfig(name).directory, config.inventoryIcon)
	  else
	    itemImage = self.defaultIcon
	  end
      widget.setText(string.format("%s.%s.name", self.list, item), config.shortdescription)
	  widget.setImage(string.format("%s.%s.icon", self.list, item), itemImage)
	  widget.setData(string.format("%s.%s", self.list, item), name)
    end
  end
  local color = "^green;"
  if tablelength(self.blacklist) >= self.capacity then color = "^red;" end
  widget.setText(self.capacityLbl, string.format("Capacity: %s%s^reset;/%s", color, length, self.capacity))
end

function slotUpdate()
  if tablelength(self.blacklist) >= self.capacity then return end
  local item = player.swapSlotItem().name
  if not contains(self.blacklist, item) then
    table.insert(self.blacklist, item)
	player.setProperty("itemblacklist", self.blacklist)
    populateList()
  end
end

function checkbox()
  local checked = widget.getChecked(self.checkbox)
  player.setProperty("ibsettings", {enabled = checked, delta = player.getProperty("ibsettings").delta})
end

function frequency()
  local value = math.max(0, math.floor(widget.getSliderValue(self.slider)))
  local str = "Trash every ^orange;" .. tostring(value) .. "^reset;s"
  widget.setText(self.sliderLbl, str)
  player.setProperty("ibsettings", {enabled = player.getProperty("ibsettings").enabled, delta = value})
end