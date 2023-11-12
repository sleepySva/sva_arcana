require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/items/active/weapons/melee/meleeslash.lua"

-- Axe primary attack
-- Extends default melee attack and overrides windup and fire
AxeCleave = MeleeSlash:new()

function AxeCleave:init()

  self.elementalType = self.elementalType or self.weapon.elementalType
  self.baseDamageFactor = config.getParameter("baseDamageFactor", 1.0)
  
  self.stances.windup.duration = self.windupTime

  MeleeSlash.init(self)
  self:setupInterpolation()

end

function AxeCleave:firePosition()
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(0, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function AxeCleave:createProjectiles()

  local aimPosition = activeItem.ownerAimPosition()
  local pCount = self.projectileCount or 1
  local pRotation = self.projectileRotation or 2
  local position = vec2.add(mcontroller.position(), {self.projectileOffset[1] * mcontroller.facingDirection(), self.projectileOffset[2]})
  local pParams = copy(self.projectileParameters)
  local fireDirection = self:firePosition()
  
  pParams.power = self.baseDamageFactor * pParams.baseDamage * config.getParameter("damageLevelMultiplier") / pCount
  pParams.powerMultiplier = activeItem.ownerPowerMultiplier()
  
  fireDirection = vec2.rotate(fireDirection, (((pRotation  * math.pi) / pCount) / -10) * (pCount / 2 - 0.5))
  
  for i = 1, pCount do
  
    local projectileId = world.spawnProjectile(
        self.projectileType,
        position,
        activeItem.ownerEntityId(),
        fireDirection,
        false,
        pParams
      )
	  
	fireDirection = vec2.rotate(fireDirection, ((pRotation  * math.pi) / pCount) / 10)
	
  end
  
end

function AxeCleave:windup(windupProgress)
  self.weapon:setStance(self.stances.windup)

  local windupProgress = windupProgress or 0
  local bounceProgress = 0
  while self.fireMode == "primary" and (self.allowHold ~= false or windupProgress < 1) do
    if windupProgress < 1 then
      windupProgress = math.min(1, windupProgress + (self.dt / self.stances.windup.duration))
      self.weapon.relativeWeaponRotation, self.weapon.relativeArmRotation = self:windupAngle(windupProgress)
    else
      bounceProgress = math.min(1, bounceProgress + (self.dt / self.stances.windup.bounceTime))
      self.weapon.relativeWeaponRotation = self:bounceWeaponAngle(bounceProgress)
    end
    coroutine.yield()
  end

  if windupProgress >= 1.0 then
    if self.stances.preslash then
      self:setState(self.preslash)
    else
      self:setState(self.fire)
    end
  else
    self:setState(self.winddown, windupProgress)
  end
end

function AxeCleave:winddown(windupProgress)
  self.weapon:setStance(self.stances.windup)

  while windupProgress > 0 do
    if self.fireMode == "primary" then
      self:setState(self.windup, windupProgress)
      return true
    end

    windupProgress = math.max(0, windupProgress - (self.dt / self.stances.windup.duration))
    self.weapon.relativeWeaponRotation, self.weapon.relativeArmRotation = self:windupAngle(windupProgress)
    coroutine.yield()
  end
end

function AxeCleave:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  animator.setAnimationState("swoosh", "fire")
  animator.playSound("fire")
  animator.burstParticleEmitter(self.weapon.elementalType .. "swoosh")
  
  self:createProjectiles()

  local chargeTimer = 0
  local chargeTime = self.stances.fire.duration or 0.2
  
  util.wait(self.stances.fire.duration, function()
    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.damageConfig, damageArea, self.fireTime)
	  
	chargeTimer = math.min(chargeTime, chargeTimer + self.dt)
	local chargeRatio = math.sin(chargeTimer / chargeTime * 1.57)
    self.weapon.relativeArmRotation = util.toRadians(util.lerp(chargeRatio, {self.stances.fire.armRotation, self.stances.fire.endArmRotation or self.stances.fire.armRotation}))
    self.weapon.relativeWeaponRotation = util.toRadians(util.lerp(chargeRatio, {self.stances.fire.weaponRotation, self.stances.fire.endWeaponRotation or self.stances.fire.weaponRotation}))
  end)

  self.cooldownTimer = self:cooldownTime()
end

function AxeCleave:setupInterpolation()
  for i, v in ipairs(self.stances.windup.bounceWeaponAngle) do
    v[2] = interp[v[2]]
  end
  for i, v in ipairs(self.stances.windup.weaponAngle) do
    v[2] = interp[v[2]]
  end
  for i, v in ipairs(self.stances.windup.armAngle) do
    v[2] = interp[v[2]]
  end
end

function AxeCleave:bounceWeaponAngle(ratio)
  return util.toRadians(interp.ranges(ratio, self.stances.windup.bounceWeaponAngle))
end

function AxeCleave:windupAngle(ratio)
  local weaponRotation = interp.ranges(ratio, self.stances.windup.weaponAngle)
  local armRotation = interp.ranges(ratio, self.stances.windup.armAngle)

  return util.toRadians(weaponRotation), util.toRadians(armRotation)
end
