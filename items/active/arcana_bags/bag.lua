function init() b = config.getParameter("bagType") activeItem.setHoldingItem(false)
local cursor = config.getParameter("bagCursor")
if cursor and player.swapSlotItem() == nil then activeItem.setCursor(cursor..".cursor") end
end
function uninit() activeItem.setCursor() end
function activate()
  activeItem.interact("scriptPane", "/interface/scripted/xrc_arcana_bag/"..b..".config")
end