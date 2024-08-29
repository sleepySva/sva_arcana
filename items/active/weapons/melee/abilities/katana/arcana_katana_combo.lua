-- Melee primary ability
MeleeCombo = WeaponAbility:new()

function MeleeCombo:init()
  self.comboStep = 1

  self.energyUsage = self.energyUsage or 0

  self:computeDamageAndCooldowns()

  self.weapon:setStance(self.stances.idle)

  self.edgeTriggerTimer = 0
  self.flashTimer = 0
  self.cooldownTimer = self.cooldowns[1]

  self.animKeyPrefix = self.animKeyPrefix or ""

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

-- Ticks on every update regardless if this is the active ability
function MeleeCombo:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  if self.cooldownTimer > 0 then
    self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
    if self.cooldownTimer == 0 then
      self:readyFlash()
    end
  end

  if self.flashTimer > 0 then
    self.flashTimer = math.max(0, self.flashTimer - self.dt)
    if self.flashTimer == 0 then
      animator.setGlobalTag("bladeDirectives", "")
    end
  end

  self.edgeTriggerTimer = math.max(0, self.edgeTriggerTimer - dt)
  if self.lastFireMode ~= (self.activatingFireMode or self.abilitySlot) and fireMode == (self.activatingFireMode or self.abilitySlot) then
    self.edgeTriggerTimer = self.edgeTriggerGrace
  end
  self.lastFireMode = fireMode

  if not self.weapon.currentAbility and self:shouldActivate() then
    self:setState(self.windup)
  end
end

-- State: windup
function MeleeCombo:windup()
  local stance = self.stances["windup"..self.comboStep]

  self.weapon:setStance(stance)

  self.edgeTriggerTimer = 0
  
  local chargeTimer = 0
  local chargeTime = stance.duration or 0.3
  while chargeTimer < chargeTime do
	chargeTimer = math.min(chargeTime, chargeTimer + self.dt)
	local chargeRatio = math.sin(chargeTimer / chargeTime * 1.57)
    self.weapon.relativeArmRotation = util.toRadians(util.lerp(chargeRatio, {self.stances["windup"..self.comboStep].armRotation, self.stances["windup"..self.comboStep].endArmRotation or self.stances["windup"..self.comboStep].armRotation}))
    self.weapon.relativeWeaponRotation = util.toRadians(util.lerp(chargeRatio, {self.stances["windup"..self.comboStep].weaponRotation, self.stances["windup"..self.comboStep].endWeaponRotation or self.stances["windup"..self.comboStep].weaponRotation}))
	coroutine.yield()
  end

  if stance.hold then
    while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
      coroutine.yield()
    end
  else
	if (self.comboStep ~= 3 and self.comboStep ~= 1) then
      util.wait(stance.duration)
	end
  end

  if self.energyUsage then
    status.overConsumeResource("energy", self.energyUsage)
  end

  if self.stances["preslash"..self.comboStep] then
    self:setState(self.preslash)
  else
    self:setState(self.fire)
  end
end

-- State: wait
-- waiting for next combo input
function MeleeCombo:wait()
  local stance = self.stances["wait"..(self.comboStep - 1)]

  self.weapon:setStance(stance)

  util.wait(stance.duration, function()
    if self:shouldActivate() then
      self:setState(self.windup)
      return
    end
  end)

  self.cooldownTimer = math.max(0, self.cooldowns[self.comboStep - 1] - stance.duration)
  self.comboStep = 1
end

-- State: preslash
-- brief frame in between windup and fire
function MeleeCombo:preslash()
  local stance = self.stances["preslash"..self.comboStep]

  self.weapon:setStance(stance)
  self.weapon:updateAim()

  util.wait(stance.duration)

  self:setState(self.fire)
end

-- State: fire
function MeleeCombo:fire()
  local stance = self.stances["fire"..self.comboStep]

  self.weapon:setStance(stance)
  self.weapon:updateAim()

  local animStateKey = self.animKeyPrefix .. (self.comboStep > 1 and "fire"..self.comboStep or "fire")
  animator.setAnimationState("swoosh", animStateKey)
  animator.playSound(animStateKey)

  local swooshKey = self.animKeyPrefix .. (self.elementalType or self.weapon.elementalType) .. "swoosh"
  animator.setParticleEmitterOffsetRegion(swooshKey, self.swooshOffsetRegions[self.comboStep])
  animator.burstParticleEmitter(swooshKey)
  
  local chargeTimer = 0
  local chargeTime = stance.duration or 0.2
  
  
  local momentum = {50,0}
  if mcontroller.groundMovement() then 
    momentum[2] = 20
  end
  
    self.scoutProjectileId = world.spawnProjectile(
      self.shakeProjectileType,
      self:shakeFirePosition(),
      activeItem.ownerEntityId(),
      self:aimVector(),
      false,
      self.shakeProjectileParameters
    )

  activeItem.setCameraFocusEntity(self.scoutProjectileId)

  util.wait(stance.duration, function()
    if self.comboStep == 4 then
	  animator.setParticleEmitterActive("dashParticles", true)
      mcontroller.controlMove(self.weapon.aimDirection)
      mcontroller.controlApproachVelocity({(vec2.rotate({1, 0}, self.weapon.aimAngle))[1] * momentum[1] * self.weapon.aimDirection, (vec2.rotate({1, 0}, self.weapon.aimAngle))[2] * momentum[2]}, 4000)
	end
    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.stepDamageConfig[self.comboStep], damageArea)
	
	chargeTimer = math.min(chargeTime, chargeTimer + self.dt)
	local chargeRatio = math.sin(chargeTimer / chargeTime * 1.57)
    self.weapon.relativeArmRotation = util.toRadians(util.lerp(chargeRatio, {self.stances["fire"..self.comboStep].armRotation, self.stances["fire"..self.comboStep].endArmRotation or self.stances["fire"..self.comboStep].armRotation}))
    self.weapon.relativeWeaponRotation = util.toRadians(util.lerp(chargeRatio, {self.stances["fire"..self.comboStep].weaponRotation, self.stances["fire"..self.comboStep].endWeaponRotation or self.stances["fire"..self.comboStep].weaponRotation}))
  end)

  if self.comboStep < self.comboSteps then
    self.comboStep = self.comboStep + 1
    self:setState(self.wait)
  else
    self.cooldownTimer = self.cooldowns[self.comboStep]
    self.comboStep = 1
  end
  
  animator.setParticleEmitterActive("dashParticles", false)
end


function MeleeCombo:shakeFirePosition()
  return vec2.add(mcontroller.position(), {(-0.4 * mcontroller.facingDirection()),0})
end

function MeleeCombo:aimVector()
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + self.weapon.relativeWeaponRotation + self.weapon.relativeArmRotation + (math.pi / 2))
  aimVector[1] = aimVector[1] * self.weapon.aimDirection
  return aimVector
end

function MeleeCombo:shouldActivate()
  if self.cooldownTimer == 0 and (self.energyUsage == 0 or not status.resourceLocked("energy")) then
    if self.comboStep > 1 then
      return self.edgeTriggerTimer > 0
    else
      return self.fireMode == (self.activatingFireMode or self.abilitySlot)
    end
  end
end

function MeleeCombo:readyFlash()
  animator.setGlobalTag("bladeDirectives", self.flashDirectives)
  self.flashTimer = self.flashTime
end

function MeleeCombo:computeDamageAndCooldowns()
  local attackTimes = {}
  for i = 1, self.comboSteps do
    local attackTime = self.stances["windup"..i].duration + self.stances["fire"..i].duration
    if self.stances["preslash"..i] then
      attackTime = attackTime + self.stances["preslash"..i].duration
    end
    table.insert(attackTimes, attackTime)
  end

  self.cooldowns = {}
  local totalAttackTime = 0
  local totalDamageFactor = 0
  for i, attackTime in ipairs(attackTimes) do
    self.stepDamageConfig[i] = util.mergeTable(copy(self.damageConfig), self.stepDamageConfig[i])
    self.stepDamageConfig[i].timeoutGroup = "primary"..i

    local damageFactor = self.stepDamageConfig[i].baseDamageFactor
    self.stepDamageConfig[i].baseDamage = damageFactor * self.baseDps * self.fireTime

    totalAttackTime = totalAttackTime + attackTime
    totalDamageFactor = totalDamageFactor + damageFactor

    local targetTime = totalDamageFactor * self.fireTime
    local speedFactor = 1.0 * (self.comboSpeedFactor ^ i)
    table.insert(self.cooldowns, (targetTime - totalAttackTime) * speedFactor)
  end
end

function MeleeCombo:uninit()
  animator.setParticleEmitterActive("dashParticles", false)
  self.weapon:setDamage()
end
