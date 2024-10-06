local acinit = init or function() end
local acupdate = update or function() end

function init()
  acinit()
end

function update(dt)
  acupdate(dt)
  removeItems(getTestItems())
end

function getTestItems()
  local list = {"copperbar", "ironbar"}
  return list
end

function removeItems(list)
  for _, item in pairs(list) do
    player.consumeItem(item)
  end
end