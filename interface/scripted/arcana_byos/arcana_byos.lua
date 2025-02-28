require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rect.lua"

function init()
  self.dungeonName = "arcana_byos_default"
end
function update(dt)
end
function create()
  local pos = {1000, 1000}
  local result = false
  local loops = 500
  local loop = 0
  while loop < loops do
    if world.placeObject("arcana_byos_spawner", pos) then sb.logInfo("Object Placed!") result = true break end
    pos = vec2.add(pos, {1, 1})
    loop = loop + 1
  end
  if result == true then sb.logInfo("Object Placed!") sb.logInfo(tostring(pos[1])) sb.logInfo(tostring(pos[2])) else sb.logInfo("Object Failed!") end
  player.setProperty("arcanabyos", true)
  pane.dismiss()
  player.warp("ownShip", "beam")
end