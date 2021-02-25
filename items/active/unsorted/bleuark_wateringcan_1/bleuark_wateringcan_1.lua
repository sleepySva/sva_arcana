require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.active = false
  self.waterTimer = 0
  self.waterProjectileTimer = 0
  self.cooldownTimer = 0

  updateAim()
end

function update(dt, fireMode, shiftHeld)
  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if fireMode == "primary"
    and not self.active
    and self.cooldownTimer == 0
    and mcontroller.onGround() then

    startWatering()
  end

  if self.active then
    self.waterTimer = math.max(0, self.waterTimer - dt)
    if self.waterTimer == 0 then
      stopWatering()
    else
      mcontroller.controlModifiers({movementSuppressed = true})

      self.waterProjectileTimer = math.max(0, self.waterProjectileTimer - dt)
      if self.waterProjectileTimer == 0 then
        self.waterProjectileTimer = config.getParameter("projectileRate")
        createWaterProjectile()
      end
    end
  end

  updateAim()
end

function uninit()

end

function updateAim()
  if self.active then
    activeItem.setArmAngle(aimAngle())
  else
    self.aimAngle, self.aimDirection = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
    -- self.aimAngle, self.aimDirection = aimAngle or 0, aimDirection or 0
    activeItem.setArmAngle(self.aimAngle)
    activeItem.setFacingDirection(self.aimDirection)
  end
end

function aimAngle()
  return self.aimAngle + (0.5 - math.abs(0.5 - self.waterTimer / config.getParameter("waterTime"))) * 2 * util.toRadians(config.getParameter("waterAngle"))
end

function aimVector(inaccuracy)
  return vec2.rotate({self.aimDirection, 0}, aimAngle() + sb.nrand(inaccuracy, 0))
end

function firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(animator.partPoint("wateringcan", "waterPoint")))
end

function createWaterProjectile()
  world.spawnProjectile(
    config.getParameter("projectileType"),
    firePosition(),
    activeItem.ownerEntityId(),
    aimVector(config.getParameter("projectileInaccuracy")),
    false,
    config.getParameter("projectileParameters")
  )
end

function startWatering()
  self.active = true
  self.waterTimer = config.getParameter("waterTime")
  animator.playSound("water")
end

function stopWatering()
  self.active = false
  self.cooldownTimer = config.getParameter("cooldownTime")
end
