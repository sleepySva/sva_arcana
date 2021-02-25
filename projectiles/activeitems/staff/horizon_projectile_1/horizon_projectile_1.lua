require "/scripts/vec2.lua"

function init()
  self.delayTimer = config.getParameter("delayTime")

  self.aimPosition = mcontroller.position()

  message.setHandler("updateProjectile", function(_, _, aimPosition)
    self.aimPosition = self.aimPosition
    return entity.id()
  end)

  message.setHandler("kill", function()
      projectile.die()
    end)
end

function update(dt)
  if self.delayTimer then
    self.delayTimer = math.max(0, self.delayTimer - dt)
    if self.delayTimer == 0 then
      self.delayTimer = nil
      trigger()
    end
  end
end

function trigger()
  mcontroller.setVelocity(vec2.mul(vec2.norm(world.distance(self.aimPosition, mcontroller.position())), config.getParameter("triggerSpeed")))
end
