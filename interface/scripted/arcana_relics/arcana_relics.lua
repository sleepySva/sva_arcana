require "/scripts/util.lua"

function init()
  slotInit()
end

function update(dt)
end

-- Updates selected slot
function slotUpdate(slot)
  
  -- Get existing slots info
  if player.getProperty("arcana_relics") == nil then player.setProperty("arcana_relics", {}) end
  local relics = player.getProperty("arcana_relics")
  local previousItem = relics[""..slot]
  
  -- Check if item is valid
  local item = player.swapSlotItem()
  if item == nil then
    -- Grab item from slot, then empty it
    if previousItem ~= nil then
      player.setSwapSlotItem(previousItem)
	  widget.setItemSlotItem(slot, nil)
	  relics[""..slot] = nil
	  player.setProperty("arcana_relics", relics)
	end
    return
  end
  if not root.itemHasTag(item.name, "arcana_relic") then return end
  
  -- Insert selected slot with item, return any existing item
  widget.setItemSlotItem(slot, item)
  player.setSwapSlotItem(nil)
  if previousItem then player.giveItem(previousItem) end
  
  -- Update player relic property
  relics[""..slot] = item
  player.setProperty("arcana_relics", relics)
end

-- Inits all item slots
function slotInit()
  if player.getProperty("arcana_relics") == nil then player.setProperty("arcana_relics", {}) end
  local relics = player.getProperty("arcana_relics")
  for k, v in pairs(relics) do
    widget.setItemSlotItem(k, v)
  end
end


  