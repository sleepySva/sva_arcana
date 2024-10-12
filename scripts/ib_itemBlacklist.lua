function init()
  self.blacklist = player.getProperty("itemblacklist") or {}
end

function update(dt)
  removeItems(player.getProperty("itemblacklist") or nil)
end

function removeItems(list)
  if list == nil then return end
  for _, item in pairs(list) do
    local count = player.hasCountOfItem(item)
	if count >= 1 then 
      local itemDescriptor = {name = item, count = count}
      player.consumeItem(itemDescriptor)
	end
  end
end