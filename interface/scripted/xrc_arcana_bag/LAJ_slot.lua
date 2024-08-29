require "/scripts/util.lua"

function has_value()
  local a = player.swapSlotItem()
  if root.itemHasTag(a.name, "arcana_bag") then return false end
  if #AI == 2 then return a.name ~= AI[1] and a.name ~= AI[2] end
  if player.isAdmin() then return true end
  return (bagType == 4 and root.itemType(a.name) == "thrownitem") or contains(AI,a.name) or contains(AI,root.itemConfig(a).config.category) or itemHasTags(a)
end

function itemHasTags(e) for _,r in pairs(AI) do if root.itemHasTag(e.name,r) then return true end end return false end



--https://steamcommunity.com/sharedfiles/filedetails/?id=1258008544
--https://steamcommunity.com/workshop/filedetails/?id=1945946369
function leftClickSlot(slot)
  local bag = bagType
  widget.setItemSlotItem(slot, player.getProperty("arcana_bag_"..bag)[""..slot])
  if player.swapSlotItem() then
    if has_value() then
      if widget.itemSlotItem(slot) then
        local item = player.swapSlotItem()
        local maxStack = item.parameters.maxStack or root.itemConfig(item.name).config.maxStack or root.assetJson("/items/defaultParameters.config:defaultMaxStack")
        local widgetItem = widget.itemSlotItem(slot)
        if root.itemDescriptorsMatch(item, widgetItem, true) then
          if not (item.count + widgetItem.count > maxStack) then
            widgetItem.count = widgetItem.count + item.count
            widget.setItemSlotItem(slot, widgetItem)
	    setBagSlot(widgetItem,slot)
            player.setSwapSlotItem(nil)
          else
            if widgetItem.count == maxStack or item.count == maxStack then
	      setBagSlot(item,slot)
              widget.setItemSlotItem(slot, item)
              player.setSwapSlotItem(widgetItem)
            else
              item.count = item.count - (maxStack - widgetItem.count)
              widgetItem.count = maxStack
              widget.setItemSlotItem(slot, widgetItem)
	      setBagSlot(widgetItem,slot)
              player.setSwapSlotItem(item)
            end
          end
        else
	  setBagSlot(player.swapSlotItem(),slot)
          widget.setItemSlotItem(slot, player.swapSlotItem())
          player.setSwapSlotItem(widgetItem)
       end
      else
	setBagSlot(player.swapSlotItem(),slot)
        widget.setItemSlotItem(slot, player.swapSlotItem())
        player.setSwapSlotItem(nil)
	end
      end
  elseif widget.itemSlotItem(slot) then
    player.setSwapSlotItem(widget.itemSlotItem(slot))
    widget.setItemSlotItem(slot, nil)
    setBagSlot({},slot)
  end
 setBagSlot(widget.itemSlotItem(slot),slot)
end

function rightClickSlot(slot)
  local bag = config.getParameter("bagType")
  if widget.itemSlotItem(slot) then
    local item = player.swapSlotItem()
    local widgetItem = widget.itemSlotItem(slot)
    local maxStack = widgetItem.parameters.maxStack or root.itemConfig(widgetItem.name).config.maxStack or root.assetJson("/items/defaultParameters.config:defaultMaxStack")
    if item and root.itemDescriptorsMatch(item, widgetItem, true) then
      if not (item.count >= maxStack) then
        widget.setItemSlotItem(slot, {count = widgetItem.count - 1, name = widgetItem.name, parameters = widgetItem.parameters})
        item.count = item.count + 1
        player.setSwapSlotItem(item)
	setBagSlot(widget.itemSlotItem(slot),slot)
      end
    elseif not item then
      widget.setItemSlotItem(slot, {count = widgetItem.count - 1, name = widgetItem.name, parameters = widgetItem.parameters})
      player.setSwapSlotItem({count = 1, name = widgetItem.name, parameters = widgetItem.parameters})
      setBagSlot(widget.itemSlotItem(slot),slot)
    end
    if widget.itemSlotItem(slot).count < 1 then
      widget.setItemSlotItem(slot, nil)
      setBagSlot({},slot)
    end
  end
 if widget.itemSlotItem(slot) ~= nil or {} then setBagSlot(widget.itemSlotItem(slot),slot) else setBagSlot({},slot) end
end
