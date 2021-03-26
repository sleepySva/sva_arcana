function update()
  if projectile.sourceEntity() and not world.entityExists(projectile.sourceEntity()) then
    projectile.die()
  end
end

function destroy()
  if projectile.sourceEntity() and world.entityExists(projectile.sourceEntity()) then
    projectile.processAction(projectile.getParameter("eruptionAction"))
  end
end
