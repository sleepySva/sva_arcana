require "/scripts/vec2.lua"

function init()
  npcType = config.getParameter("npcType")
  npcSpecies = config.getParameter("npcSpecies", "human")
  npcLevel = config.getParameter("npcLevel", 1)
  npcSpawnOffset = config.getParameter("npcSpawnOffset", {0,0})
end

function update(dt)
end

function uninit()
  local npcPosition = vec2.add(entity.position(), npcSpawnOffset)
  world.spawnNpc(npcPosition, npcSpecies, npcType, npcLevel)
end