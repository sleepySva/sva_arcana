require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

shingetsu = WeaponAbility:new()

function shingetsu:init()
  self.cooldownTimer = self.cooldownTime
end

function shingetsu:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.weapon.currentAbility == nil and self.fireMode == "alt" and self.cooldownTimer == 0 and status.overConsumeResource("energy", self.energyUsage) then
    self:setState(self.windup)
  end
end

function shingetsu:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  util.wait(self.stances.windup.duration)

  self:setState(self.fire)
end

function shingetsu:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  local position = vec2.add(mcontroller.position(), {self.projectileOffset[1] * mcontroller.facingDirection(), self.projectileOffset[2]})
  local params = {
    powerMultiplier = activeItem.ownerPowerMultiplier(),
    power = self:damageAmount()
  }
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), self:aimVector(), false, params)

  animator.playSound("shingetsu_sound")

  util.wait(self.stances.fire.duration)
  self.cooldownTimer = self.cooldownTime
end

function shingetsu:aimVector()
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(0, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function shingetsu:damageAmount()
  return self.baseDamage * config.getParameter("damageLevelMultiplier")
end

function shingetsu:uninit()
end
