require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

chargeslash = WeaponAbility:new()

function chargeslash:init()
  self.cooldownTimer = self.cooldownTime
end

function chargeslash:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.weapon.currentAbility == nil and self.fireMode == "alt" and self.cooldownTimer == 0 and status.overConsumeResource("energy", self.energyUsage) then
    self:setState(self.windup)
  end
end

function chargeslash:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()
  local stance = self.stances["windup"]
  local chargeTimer = 0
  local chargeTime = stance.duration or 0.3
  while chargeTimer < chargeTime do
	chargeTimer = math.min(chargeTime, chargeTimer + self.dt)
	local chargeRatio = math.sin(chargeTimer / chargeTime * 1.57)
    self.weapon.relativeArmRotation = util.toRadians(util.lerp(chargeRatio, {self.stances["windup"].armRotation, self.stances["windup"].endArmRotation or self.stances["windup"].armRotation}))
    self.weapon.relativeWeaponRotation = util.toRadians(util.lerp(chargeRatio, {self.stances["windup"].weaponRotation, self.stances["windup"].endWeaponRotation or self.stances["windup"].weaponRotation}))
	coroutine.yield()
  end
  util.wait(0.1)

  self:setState(self.fire)
end

function chargeslash:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  local position = vec2.add(mcontroller.position(), {self.projectileOffset[1] * mcontroller.facingDirection(), self.projectileOffset[2]})
  local params = {
    powerMultiplier = activeItem.ownerPowerMultiplier(),
    power = self:damageAmount()
  }
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), self:aimVector(), false, params)

  animator.playSound("chargefire")

  util.wait(self.stances.fire.duration)
  self.cooldownTimer = self.cooldownTime
end

function chargeslash:aimVector()
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(0, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function chargeslash:damageAmount()
  return self.baseDamage * config.getParameter("damageLevelMultiplier")
end

function chargeslash:uninit()
end
