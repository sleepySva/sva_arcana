require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/interp.lua"

ChargeFire = WeaponAbility:new()

function ChargeFire:init()
  self.weapon:setStance(self.stances.idle)

  self.cooldownTimer = 0
  self.chargeTimer = 0

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function ChargeFire:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and self.cooldownTimer == 0
    and not self.weapon.currentAbility
    and not world.lineTileCollision(mcontroller.position(), self:firePosition())
    and not status.resourceLocked("energy") then

    self:setState(self.charge)
  end
end

function ChargeFire:charge()
  self.weapon:setStance(self.stances.charge)

  animator.setAnimationState("weapon", "charge")

  self.chargeTimer = 0

  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    self.chargeTimer = self.chargeTimer + self.dt

    coroutine.yield()
  end

  self.chargeLevel = self:currentChargeLevel()
  local energyCost = (self.chargeLevel and self.chargeLevel.energyCost) or 0
  if self.chargeLevel and (energyCost == 0 or status.overConsumeResource("energy", energyCost)) then
    self:setState(self.fire)
  end
end

function ChargeFire:fire()
  if world.lineTileCollision(mcontroller.position(), self:firePosition()) then
    animator.setAnimationState("weapon", "idle")
    self.cooldownTimer = self.chargeLevel.cooldown or 0
    self:setState(self.cooldown, self.cooldownTimer)
    return
  end

  self.weapon:setStance(self.stances.fire)

  animator.setAnimationState("weapon", self.chargeLevel.fireAnimationState or "fire")
  animator.playSound(self.chargeLevel.fireSound or "fire")

  self:fireProjectile()

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end

  self.cooldownTimer = self.chargeLevel.cooldown or 0

  self:setState(self.cooldown, self.cooldownTimer)
end

function ChargeFire:cooldown(duration)
  self.weapon:setStance(self.stances.cooldown)
  self.weapon:updateAim()

  local progress = 0
  util.wait(duration, function()
    local from = self.stances.cooldown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / duration))
  end)
end

function ChargeFire:fireProjectile()
  local projectileCount = self.chargeLevel.projectileCount or 1

  local params = copy(self.chargeLevel.projectileParameters or {})
  params.power = (self.chargeLevel.baseDamage * config.getParameter("damageLevelMultiplier")) / projectileCount
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  
  -- Crits
  local critDamageMultiplier = status.stat("arcana_critDamageMultiplier") or 0
	local critRateStat = status.stat("arcana_critRate") or 0

  local effects = jarray()
  for key, value in ipairs(params.statusEffects or jarray()) do
    effects[key] = value
  end

  local critRate = (self.weapon.critRate or self.critRate or 0) + critRateStat
  if critRate > 0 and math.random() <= critRate then
    params.powerMultiplier = params.powerMultiplier * ((self.weapon.critDamage or self.critDamage or 1) + critDamageMultiplier)
    table.insert(effects, self.weapon.critVisualStatus or "arcana_crit")
	params.statusEffects = effects
  end
  --

  local spreadAngle = util.toRadians(self.chargeLevel.spreadAngle or 0)
  local totalSpread = spreadAngle * (projectileCount - 1)
  local currentAngle = totalSpread * -0.5
  for i = 1, projectileCount do
    if params.timeToLive then
      params.timeToLive = util.randomInRange(params.timeToLive)
    end

    world.spawnProjectile(
        self.chargeLevel.projectileType,
        self:firePosition(),
        activeItem.ownerEntityId(),
        self:aimVector(currentAngle, self.chargeLevel.inaccuracy or 0),
        false,
        params
      )

    currentAngle = currentAngle + spreadAngle
  end
end

function ChargeFire:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function ChargeFire:aimVector(angleAdjust, inaccuracy)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + angleAdjust + sb.nrand(inaccuracy, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function ChargeFire:currentChargeLevel()
  local bestChargeTime = 0
  local bestChargeLevel
  for _, chargeLevel in pairs(self.chargeLevels) do
    if self.chargeTimer >= chargeLevel.time and self.chargeTimer >= bestChargeTime then
      bestChargeTime = chargeLevel.time
      bestChargeLevel = chargeLevel
    end
  end
  return bestChargeLevel
end

function ChargeFire:uninit()

end
