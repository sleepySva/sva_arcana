function init()
  self.projectile = config.getParameter("projectile", nil)
  self.projectilePower = config.getParameter("projectilePower", 20)
  local damageConfig = {
    power = self.projectilePower,
    speed = 0,
    physics = "default"
  }
  world.spawnProjectile(self.projectile, mcontroller.position(), entity.id(), {0, 0}, true, damageConfig)
end