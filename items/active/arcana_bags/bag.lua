function init() activeItem.setHoldingItem(false)
  local cursor = config.getParameter("bagCursor")
  if cursor and player.swapSlotItem() == nil then activeItem.setCursor(cursor..".cursor") end
end
function uninit() activeItem.setCursor() end

function activate()
  local bagType = config.getParameter("bagType",0)
  bagType = bagType == "i" and 0 or bagType
  local configData = root.assetJson(string.format("/interface/scripted/xrc_arcana_bag/%s.config",bagType~=0 and 1 or "i"))
  configData.bagType = bagType
  if bagType ~= 0 then configData.gui.background.fileFooter = string.format("/interface/scripted/xrc_arcana_bag/%s.png",bagType)
  configData.gui.title.value = string.format("^shadow;%s",config.getParameter("shortdescription","Inventory")) end
  activeItem.interact("scriptPane", configData)
end
