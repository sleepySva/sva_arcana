require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rect.lua"

function init()
  self.spawn = {0, 0}
  self.spawnOffset = config.getParameter("spawnOffset", {1000, 0})
  self.dungeonName = config.getParameter("dungeonName", "arcana_byos_default")
  self.dungeonId = 9000
  create()
end

function update(dt)
end

function create()
  local dungeonPosition = vec2.add(self.spawn, self.spawnOffset)
  world.placeDungeon(self.dungeonName, dungeonPosition, self.dungeonId)
  sb.logInfo("Ship Placed!")
  object.smash(true)
end