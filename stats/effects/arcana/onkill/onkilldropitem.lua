require "/scripts/util.lua"
require "/scripts/status.lua"
function init()
  self.item = config.getParameter("item")
  
  self.damageListener = damageListener("damageTaken", function(notifications)
    for _, n in pairs(notifications) do
	  if n.hitType == "Kill" and n.healthLost > 0 then
		 world.spawnItem(self.item, entity.position())
		 effect.expire()
	  end
	end
  end)
end

function update(dt)
  self.damageListener:update()
end