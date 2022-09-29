require "/scripts/util.lua"
require "/scripts/rect.lua"
require "/scripts/pathing.lua"
require "/items/active/weapons/weapon.lua"

BlinkExplosion = WeaponAbility:new()

function BlinkExplosion:init()
  self.cooldownTimer = self.cooldownTime
end

function BlinkExplosion:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.weapon.currentAbility == nil
      and fireMode == "alt"
      and self.cooldownTimer == 0
      and not status.statPositive("activeMovementAbilities")
      and not status.resourceLocked("energy") then

    self:setState(self.charge)
  end
end

function BlinkExplosion:charge()
  self.weapon.aimAngle = 0
  self.weapon:setStance(self.stances.charge)

  status.setPersistentEffects("blinkexplosionability", { { stat = "invulnerable", amount = 1.0}, {stat = "activeMovementAbilities", amount = 1}, self.weapon.elementalType.."charge" })
  animator.setAnimationState("blinkCharge", "charge")

  util.wait(self.stances.charge.duration, function(dt)
    mcontroller.controlModifiers({ movementSuppressed = true })

    -- Interrupt wait if we run out of energy
    return status.resourceLocked("energy")
  end)

  if status.overConsumeResource("energy", self.energyUsage) then
    self:setState(self.blink)
  end
end

function BlinkExplosion:blink()
  status.setPersistentEffects("blinkexplosionability", { { stat = "invulnerable", amount = 1.0}, {stat = "activeMovementAbilities", amount = 1} })
  status.addEphemeralEffect("blink")

  -- wait until a certain point in the blink animation
  util.wait(0.25, function(dt)
    mcontroller.controlModifiers({ movementSuppressed = true })
  end)

  -- move to blink position
  local blinkPosition = self:findBlinkPosition()
  mcontroller.setPosition(blinkPosition)

  self.cooldownTimer = self.cooldownTime
end

function BlinkExplosion:reset()
  status.setPersistentEffects("blinkexplosionability", {})
end

function BlinkExplosion:uninit()
  self:reset()
end

function BlinkExplosion:findBlinkPosition()
  local position = mcontroller.position()

  local direction = mcontroller.facingDirection()
  for i = 0, self.maxDistance do
    if direction > 0 then
      position[1] = math.ceil(position[1])
    end

    local yDirs = {0, 1, -1}
    local lastPosition = position[1]
    for _,yDir in ipairs(yDirs) do
      local bounds = rect.translate(mcontroller.boundBox(), {position[1] + direction, position[2] + yDir})
      if not world.rectTileCollision(bounds, {"Null", "Block", "Dynamic", "Slippery"}) then
        position = {position[1] + direction, position[2] + yDir}
        break
      end
    end
    if position[1] == lastPosition or i == self.maxDistance then
      return position
    end
  end
  return mcontroller.position()
end
