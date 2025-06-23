require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.projectileType = config.getParameter("projectileType")
  self.projectileParameters = config.getParameter("projectileParameters", {})
  self.projectileParameters.power = config.getParameter("power")
  self.projectileParameters.powerMultiplier = projectile.powerMultiplier()

  self.spawnTime = config.getParameter("spawnRate")
  self.spawnTimer = self.spawnTime

  self.pendingProjectiles = {entity.id()}

  message.setHandler("updateProjectile", function(_, _, aimPosition)
      self.aimPosition = aimPosition
      local projectileIds = copy(self.pendingProjectiles)
      self.pendingProjectiles = {entity.id()}
      return projectileIds
    end)

  message.setHandler("kill", function()
      projectile.die()
    end)
end

function update(dt)
  self.spawnTimer = math.max(0, self.spawnTimer - dt)
  if self.spawnTimer == 0 then
    createProjectile()
    self.spawnTimer = self.spawnTime
  end
end

function createProjectile()
  local aimVec = vec2.withAngle(math.random() * 2 * math.pi)

  local projectileId = world.spawnProjectile(
      self.projectileType,
      mcontroller.position(),
      projectile.sourceEntity(),
      aimVec,
      false,
      self.projectileParameters
    )

  if projectileId then
    table.insert(self.pendingProjectiles, projectileId)
  end
end
