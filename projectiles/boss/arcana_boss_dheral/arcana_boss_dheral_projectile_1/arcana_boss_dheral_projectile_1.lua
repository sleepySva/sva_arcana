function init()
  message.setHandler("setTarget", function(_, _, entityId)
    self.target = entityId
  end)
end

function update()
  if not self.target or not world.entityExists(self.target) then return end

  local targetPosition = world.entityPosition(self.target)
  if targetPosition then
    local toTarget = world.distance(targetPosition, mcontroller.position())
    local angle = math.atan(toTarget[2], toTarget[1])
    mcontroller.setRotation(angle)
  end

  if projectile.sourceEntity() and not world.entityExists(projectile.sourceEntity()) then
    projectile.die()
  end
end

function destroy()
  if projectile.sourceEntity() and world.entityExists(projectile.sourceEntity()) then
    local rotation = mcontroller.rotation()
    world.spawnProjectile(projectile.getParameter("secondaryProjectile"), mcontroller.position(), projectile.sourceEntity(), {math.cos(rotation), math.sin(rotation)}, false, { speed = 50, power = projectile.getParameter("power")})
    projectile.processAction(projectile.getParameter("explosionAction"))
  end
end
