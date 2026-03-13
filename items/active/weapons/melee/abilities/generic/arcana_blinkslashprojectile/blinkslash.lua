require "/scripts/util.lua"
require "/scripts/rect.lua"
require "/scripts/vec2.lua"
require "/scripts/pathutil.lua"
require "/items/active/weapons/weapon.lua"

BlinkSlash = WeaponAbility:new()

function BlinkSlash:init()
  self:reset()

  self.cooldownTimer = 0
end

function BlinkSlash:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.weapon.currentAbility == nil
     and self.fireMode == "alt"
     and mcontroller.onGround()
     and self.cooldownTimer == 0
     and not status.statPositive("activeMovementAbilities")
     and not status.resourceLocked("energy") then

    self:setState(self.windup)
  end
end

function BlinkSlash:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})

  util.wait(self.stances.windup.duration)

  self.blinkPosition = self:findBlinkPosition()
  if self.blinkPosition and status.overConsumeResource("energy", self.energyUsage) then
    self:setState(self.slash)
  else
    self.cooldownTimer = self.cooldownTime
  end
end

function BlinkSlash:slash()
  local suppressMove = function()
    mcontroller.controlModifiers({movementSuppressed = true})
    mcontroller.controlParameters({
      gravityEnabled = false
    })
    mcontroller.setVelocity({0,0})
  end

  local slash = coroutine.create(self.slashAction)
  coroutine.resume(slash, self)

  while util.parallel(suppressMove, slash) do
    coroutine.yield()
  end
end

function BlinkSlash:slashAction()
  status.addEphemeralEffect("blink")
  util.wait(0.25)

  local fromPosition = mcontroller.position()
  mcontroller.setPosition(self.blinkPosition)
  self.weapon.aimDirection = -self.weapon.aimDirection
  self.weapon:setStance(self.stances.slash)
  self.weapon:updateAim()

  util.wait(0.1)

  animator.setAnimationState("blinkSwoosh", "fire")
  animator.playSound("fire")
  
  local projectileTimesAndAngles = copy(self.projectileTimesAndAngles)

  util.wait(self.stances.slash.duration, function(dt)
    local damageArea = partDamageArea("blinkSwoosh")
    self.weapon:setDamage(self.damageConfig, damageArea)
	
      mcontroller.controlApproachVelocity({0, 0}, 1000)

      local newTimesAndAngles = {}
      for _, timeAndAngle in pairs(projectileTimesAndAngles) do
        if timeAndAngle[1] <= dt then
          self:spawnProjectile(timeAndAngle[2])
        else
          table.insert(newTimesAndAngles, {timeAndAngle[1] - dt, timeAndAngle[2]})
        end
      end
      projectileTimesAndAngles = newTimesAndAngles
  end)

  status.removeEphemeralEffect("blink")
  status.addEphemeralEffect("blink")
  util.wait(0.25)
  mcontroller.setPosition(fromPosition)
  self.weapon.aimDirection = -self.weapon.aimDirection

  self.cooldownTimer = self.cooldownTime
end

function BlinkSlash:reset()
  status.clearPersistentEffects("weaponMovementAbility")
  animator.setGlobalTag("directives", "")
end

function BlinkSlash:uninit()
  self:reset()
end

function BlinkSlash:findBlinkPosition()
  local searchPosition = vec2.add(mcontroller.position(), {self.blinkDistance * mcontroller.facingDirection(), 0})
  local groundPosition = findGroundPosition(searchPosition, -self.blinkYTolerance, self.blinkYTolerance, false, {"Null", "Block", "Dynamic", "Platform"})
  if groundPosition and (not self.requireLineOfSight or not world.lineTileCollision(mcontroller.position(), groundPosition, {"Null", "Block", "Dynamic", "Slippery"})) then
    return groundPosition
  end
end

function BlinkSlash:spawnProjectile(angleAdjust)
  local position = vec2.add(mcontroller.position(), {self.projectileOffset[1] * self.weapon.aimDirection, self.projectileOffset[2]})
  local params = {
    powerMultiplier = activeItem.ownerPowerMultiplier(),
    power = self:damageAmount()
  }
  local aimVector = vec2.withAngle(util.toRadians(angleAdjust))
  aimVector[1] = aimVector[1] * self.weapon.aimDirection
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), aimVector, false, params)
end

function BlinkSlash:damageAmount()
  return self.baseDamage * config.getParameter("damageLevelMultiplier")
end