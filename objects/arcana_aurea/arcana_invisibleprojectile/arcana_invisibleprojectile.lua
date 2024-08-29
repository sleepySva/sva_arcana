require "/scripts/vec2.lua"

function init()
  self.projectile = config.getParameter("projectile")
  self.projectileConfig = config.getParameter("projectileConfig", {})
  self.projectilePosition = config.getParameter("projectilePosition", {0, 0})
  self.projectileDirection = config.getParameter("projectileDirection", {1, 0})
  self.inaccuracy = config.getParameter("inaccuracy", 0)
  self.projectilePosition = object.toAbsolutePosition(self.projectilePosition)
end

function update(dt)
end

function onNodeConnectionChange(args)
  updateActive()
end

function onInputNodeChange(args)
  updateActive()
end

function shoot()
  animator.playSound("shoot")
  local projectileDirection = vec2.rotate(self.projectileDirection, sb.nrand(self.inaccuracy, 0))
  world.spawnProjectile(self.projectile, self.projectilePosition, entity.id(), projectileDirection, false, self.projectileConfig)
  world.breakObject(entity.id(), true)
end

function updateActive()
  local active = (not object.isInputNodeConnected(0)) or object.getInputNodeLevel(0)
  if active ~= storage.active then
    storage.active = active
    if active then
      animator.setAnimationState("trapState", "on")
      object.setLightColor(config.getParameter("activeLightColor", {0, 0, 0, 0}))
      object.setSoundEffectEnabled(true)
      animator.playSound("on");
	  shoot()
    else
      animator.setAnimationState("trapState", "off")
      object.setLightColor(config.getParameter("inactiveLightColor", {0, 0, 0, 0}))
      object.setSoundEffectEnabled(false)
      animator.playSound("off");
    end
  end
end
