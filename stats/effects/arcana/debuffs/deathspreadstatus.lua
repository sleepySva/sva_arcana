require "/scripts/util.lua"
require "/scripts/status.lua"
function init()
  self.status = config.getParameter("status")
  self.radius = config.getParameter("radius")
  
  self.damageListener = damageListener("damageTaken", function(notifications)
    for _, n in pairs(notifications) do
	  if n.hitType == "Kill" and n.healthLost > 0 then
	     local entities = world.entityQuery(entity.position(),self.radius)
		 for _, id in ipairs(entities) do
		   world.sendEntityMessage(id, "applyStatusEffect", self.status)
		 end
	  end
	end
  end)
end


function update(dt)
  self.damageListener:update()
end