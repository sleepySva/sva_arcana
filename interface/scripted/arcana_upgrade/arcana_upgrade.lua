require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
  local configPath = "/interface/scripted/arcana_upgrade/levels.config"
  self.levels = root.assetJson(configPath).levels
  
  self.itemList = "itemScrollArea.itemList"
  self.costList = "costScrollArea.itemList"
  self.maxLevel = config.getParameter("maxLevel")

  self.upgradeableWeaponItems = {}
  self.selectedItem = nil
  self.cost = nil
  self.upgradeable = false
  populateItemList()
end

function update(dt)
  populateItemList()
end

function upgradeCost(itemConfig)
  if itemConfig == nil then return 0 end
  local prevLevel = itemConfig.parameters.level or itemConfig.config.level or 1
  local newLevel = math.floor(prevLevel + 1)

  local prevValue = root.evalFunction("weaponEssenceValue", prevLevel)
  local newValue = root.evalFunction("weaponEssenceValue", newLevel) 

  return math.floor(newValue - prevValue)
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function populateItemList(forceRepop)
  local upgradeableWeaponItems = player.itemsWithTag("weapon")
  for i = 1, #upgradeableWeaponItems do
    upgradeableWeaponItems[i].count = 1
  end

  local playerEssence = player.currency("essence")

  if forceRepop or not compare(upgradeableWeaponItems, self.upgradeableWeaponItems) then
    self.upgradeableWeaponItems = upgradeableWeaponItems
    widget.clearListItems(self.itemList)
    widget.setButtonEnabled("btnUpgrade", false)

    local showEmptyLabel = true

    for i, item in pairs(self.upgradeableWeaponItems) do
      local config = root.itemConfig(item)
	  local itemLevel = (config.parameters.level or config.config.level or 1)

      if itemLevel < self.maxLevel then
        showEmptyLabel = false

        local listItem = string.format("%s.%s", self.itemList, widget.addListItem(self.itemList))
        local name = config.config.shortdescription

        widget.setText(string.format("%s.itemName", listItem), name)
        widget.setItemSlotItem(string.format("%s.itemIcon", listItem), item)

        local price = upgradeCost(config)
        widget.setData(listItem,
          {
            index = i,
            price = price,
			cost = self.levels[math.min(self.maxLevel,(itemLevel + 1))]
          })
		  
        widget.setVisible(string.format("%s.unavailableoverlay", listItem), price > playerEssence)
      end
    end

    self.selectedItem = nil

    widget.setVisible("emptyLabel", showEmptyLabel)
  end
end

function costSelected()
end

function itemSelected()
  local listItem = widget.getListSelected(self.itemList)

  self.selectedItem = listItem
  if listItem then
    local itemData = widget.getData(string.format("%s.%s", self.itemList, listItem))
    local weaponItem = self.upgradeableWeaponItems[itemData.index]
	for _, cost in pairs(itemData.cost) do
	  showCost(weaponItem, cost)
	end
  end
end

function showCost(weapon, cost)
  widget.clearListItems(self.costList)
  
  self.cost = cost
  self.upgradeable = true
  
  if weapon then
    for i, item in pairs(cost) do
      local config = root.itemConfig(item)

      local listItem = string.format("%s.%s", self.costList, widget.addListItem(self.costList))
      local name = config.config.shortdescription
	  
	  local count = player.hasCountOfItem(item)
	  if item.name == "essence" then count = player.currency(item.name) end
	  local positive = count >= item.count
	  
	  if not positive then self.upgradeable = false end

      widget.setText(string.format("%s.itemName", listItem), name)
	  widget.setText(string.format("%s.itemCost", listItem), string.format("%s/%s", count, item.count))
	  widget.setFontColor(string.format("%s.itemCost", listItem), positive and {79, 230, 70} or {255, 73, 66})
      widget.setItemSlotItem(string.format("%s.itemIcon", listItem), item)
	  widget.setVisible(string.format("%s.unavailableoverlay", listItem), false)
    end
  end
  
  widget.setButtonEnabled("btnUpgrade", self.upgradeable)
end

function doUpgrade()
  if self.selectedItem then
    local selectedData = widget.getData(string.format("%s.%s", self.itemList, self.selectedItem))
    local upgradeItem = self.upgradeableWeaponItems[selectedData.index]
	local itemConfig = root.itemConfig(upgradeItem)
	local prevLevel = itemConfig.parameters.level or itemConfig.config.level or 1

    if upgradeItem then
      local consumedItem = player.consumeItem(upgradeItem, false, true)
      if consumedItem then
	    local consumedCurrency = true
		for i, item in pairs(self.cost) do
		  
		  if item.name == "essence" then
		    player.consumeCurrency("essence", item.count)
		  else
		    player.consumeItem(item)
		  end

		end
        local upgradedItem = copy(consumedItem)
        if consumedCurrency then
          upgradedItem.parameters.level = math.min(math.floor(prevLevel + 1), self.maxLevel)
		  --sb.logInfo("Weapon Upgraded! New Level: ".. upgradedItem.parameters.level)
          itemConfig = root.itemConfig(upgradedItem)
          if itemConfig.config.upgradeParameters then
            upgradedItem.parameters = util.mergeTable(upgradedItem.parameters, itemConfig.config.upgradeParameters)
          end
        end
        player.giveItem(upgradedItem)
      end
    end
    populateItemList(true)
  end
end
