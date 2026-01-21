require "/scripts/status.lua"

function init()
  self.duration = effect.duration()
  --sb.logInfo("effect init source id: "..self.duration)
  self.damageListener = damageListener("damageTaken", function(notifications)
    for _, n in pairs(notifications) do
	  if n.hitType == "Kill" and n.healthLost > 0 then
	    if world.entityExists(self.duration) then
          world.sendEntityMessage(self.duration, "arcana_onkill")
		  --sb.logInfo("message sent")
        end
	  end
	  --sb.logInfo("damage taken: "..n.hitType.." health lost: "..n.healthLost)
	end
  end)
end

function update(dt)
  self.damageListener:update()
end