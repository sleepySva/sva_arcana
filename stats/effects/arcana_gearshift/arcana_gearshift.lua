function init()
  self.percent = config.getParameter("percent", nil)
  self.cooldown = config.getParameter("cooldown", nil)
  self.duration = config.getParameter("duration", nil)
  self.timer = self.cooldown
end

function update(dt)
  if self.timer <= 0 then
    local health = world.entityHealth(entity.id())
    local condition = (health[1] < (health[2] * self.percent))
	if condition == true then
      status.addEphemeralEffect("arcana_gearshifthaste", self.duration)
	  status.setResourcePercentage("health", 1.0)
      self.timer = self.cooldown
	end
  end

  if self.timer > 0 then
    self.timer = self.timer - dt
  end
end

function uninit()
  
end
