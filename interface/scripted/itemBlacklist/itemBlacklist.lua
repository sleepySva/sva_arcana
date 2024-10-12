--https://stackoverflow.com/questions/2282444/how-to-check-if-a-table-contains-an-element-in-lua
--https://stackoverflow.com/questions/2705793/how-to-get-number-of-entries-in-a-lua-table
require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.list = "blacklistArea.list"
  self.slot = "itemSlot"
  self.blacklist = player.getProperty("itemblacklist") or {}
  self.defaultIcon = "/interface/statuses/x.png"
  self.capacity = config.getParameter("capacity", 60)
  self.capacityLbl = "capacity"
  populateList()
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
	  if config.inventoryIcon ~= nil and not contains(root.itemTags(name), "weapon") then 
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