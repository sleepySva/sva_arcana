function init()
  if player.getProperty("ibsettings", nil) == nil or type(player.getProperty("ibsettings")) ~= "table" then player.setProperty("ibsettings", {enabled = true, delta = 1}) end
  self.blacklist = player.getProperty("itemblacklist") or {}
end

function update(dt)
  script.setUpdateDelta(math.max(1, player.getProperty("ibsettings").delta * 60))
  if player.getProperty("ibsettings").enabled == true then
    removeItems(player.getProperty("itemblacklist") or nil)
  end
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