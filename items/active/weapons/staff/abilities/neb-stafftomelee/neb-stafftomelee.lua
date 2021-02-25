require "/items/active/weapons/weapon.lua"
require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/interp.lua"

NebStaffToMelee = WeaponAbility:new()

function NebStaffToMelee:init()
  self.weapon:addTransformationGroup("swoosh", {0,0}, math.pi/2)
  
  self.damageConfig.baseDamage = self.baseDps * self.fireTime
  self.comboStep = 1
  self.edgeTriggerTimer = 0
  self.flashTimer = 0
  self.animKeyPrefix = self.animKeyPrefix or ""
  
  self.reloaded = false --Used to share data with primary ability

  self:computeDamageAndCooldowns()
  self:reset()

  self.cooldownTimer = self.cooldowns[1]
  
  self.transformCooldownTimer = self.transformCooldownTime
end

function NebStaffToMelee:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)
  
  self.transformCooldownTimer = math.max(0, self.transformCooldownTimer - self.dt)
  if self.cooldownTimer > 0 then
    self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
    if self.cooldownTimer == 0 then
      animator.setGlobalTag("bladeDirectives", self.flashDirectives)
	  self.flashTimer = self.flashTime
    end
  end
  
  self.edgeTriggerTimer = math.max(0, self.edgeTriggerTimer - dt)
  if self.lastFireMode ~= "primary" and fireMode == "primary" then
    self.edgeTriggerTimer = self.edgeTriggerGrace
  end
  self.lastFireMode = fireMode
  
  --If not already in an ability, and we press alt fire, transform the weapon
  if not self.weapon.currentAbility
	and self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and self.transformCooldownTimer == 0
	and self.transformed == false then

	self:setState(self.transitionToMelee)
  end
  
  if self.transformed then
	self.weapon.aimOffset = -1.0
  else
	self.weapon.aimOffset = 0.0
  end
end

function NebStaffToMelee:transitionToMelee()
  self.weapon:setStance(self.stances.transitionToMelee)
  self.weapon:updateAim()
	
  --Force the aim angle into a set position
  self.weapon.aimAngle = 0
  
  animator.setAnimationState("staff", "transitionToMelee")
  animator.playSound("transform")
  
  --Smoothly transition into the other form's stance
  local progress = 0
  util.wait(self.stances.transitionToMelee.duration, function()
    progress = math.min(self.stances.transitionToMelee.duration, progress + self.dt)
    local progressRatio = math.sin(progress / self.stances.transitionToMelee.duration * 1.57)
	
	local from = self.stances.transitionToMelee.weaponOffset or {0,0}
    local to = self.stances.transitionToMelee.endWeaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progressRatio, from[1], to[1]), interp.linear(progressRatio, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(util.lerp(progressRatio, {self.stances.transitionToMelee.weaponRotation, self.stances.transitionToMelee.endWeaponRotation}))
    self.weapon.relativeArmRotation = util.toRadians(util.lerp(progressRatio, {self.stances.transitionToMelee.armRotation, self.stances.transitionToMelee.endArmRotation}))
  end)
  
  self.transformed = true
  self.transformCooldownTimer = self.transformCooldownTime
  self:setState(self.meleeIdle)
end

function NebStaffToMelee:transitionToStaff()
  self.weapon:setStance(self.stances.transitionToStaff)
  self.weapon:updateAim()
	
  --Force the aim angle into a set position
  self.weapon.aimAngle = 0
  
  animator.setAnimationState("staff", "transitionToStaff")
  animator.playSound("transform")

  --Smoothly transition into the other form's stance
  local progress = 0
  util.wait(self.stances.transitionToStaff.duration, function()
    progress = math.min(self.stances.transitionToStaff.duration, progress + self.dt)
    local progressRatio = math.sin(progress / self.stances.transitionToStaff.duration * 1.57)
	
	local from = self.stances.transitionToStaff.weaponOffset or {0,0}
    local to = self.stances.transitionToStaff.endWeaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progressRatio, from[1], to[1]), interp.linear(progressRatio, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(util.lerp(progressRatio, {self.stances.transitionToStaff.weaponRotation, self.stances.transitionToStaff.endWeaponRotation}))
    self.weapon.relativeArmRotation = util.toRadians(util.lerp(progressRatio, {self.stances.transitionToStaff.armRotation, self.stances.transitionToStaff.endArmRotation}))
  end)
  
  self.transformed = false
  self.transformCooldownTimer = self.transformCooldownTime
end

function NebStaffToMelee:meleeIdle()
  self.weapon:setStance(self.stances.meleeIdle)
  
  self.weapon.aimAngle = 0
  
  while self.transformed do
	self.weapon:updateAim()
	
	if self.fireMode == "primary" and self.cooldownTimer == 0 then
	  self:setState(self.windup)
	end
	
	if self.fireMode == "alt" and self.transformCooldownTimer == 0 then
	  self:setState(self.transitionToStaff)
	end
	
	coroutine.yield()
  end
  
  self:setState(self.transitionToStaff)
end

function NebStaffToMelee:windup()
  local stance = self.stances["windup"..self.comboStep]

  self.weapon:setStance(stance)

  self.edgeTriggerTimer = 0

  if stance.hold then
    while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
      coroutine.yield()
    end
  else
    util.wait(stance.duration)
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

function NebStaffToMelee:wait()
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
  
  self:setState(self.meleeIdle)
end

function NebStaffToMelee:preslash()
  local stance = self.stances["preslash"..self.comboStep]

  self.weapon:setStance(stance)
  self.weapon:updateAim()

  util.wait(stance.duration)

  self:setState(self.fire)
end

function NebStaffToMelee:fire()
  local stance = self.stances["fire"..self.comboStep]

  self.weapon:setStance(stance)
  self.weapon:updateAim()

  local animStateKey = self.animKeyPrefix .. (self.comboStep > 1 and "fire"..self.comboStep or "fire")
  animator.setAnimationState("swoosh", animStateKey)
  animator.playSound(animStateKey)

  local swooshKey = self.animKeyPrefix .. (self.elementalType or self.weapon.elementalType) .. "swoosh"
  animator.setParticleEmitterOffsetRegion(swooshKey, self.swooshOffsetRegions[self.comboStep])
  animator.burstParticleEmitter(swooshKey)

  util.wait(stance.duration, function()
    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.stepDamageConfig[self.comboStep], damageArea)
  end)

  if self.comboStep < self.comboSteps then
    self.comboStep = self.comboStep + 1
    self:setState(self.wait)
  else
    self.cooldownTimer = self.cooldowns[self.comboStep]
    self.comboStep = 1
	self:setState(self.meleeIdle)
  end
end

function NebStaffToMelee:shouldActivate()
  if self.cooldownTimer == 0 and (self.energyUsage == 0 or not status.resourceLocked("energy")) then
    if self.comboStep > 1 then
      return self.edgeTriggerTimer > 0
    else
      return self.fireMode == "primary"
    end
  end
end

function NebStaffToMelee:computeDamageAndCooldowns()
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

function NebStaffToMelee:reset()
  animator.setGlobalTag("bladeDirectives", "")
  self.transformed = false
  self.weapon:setDamage()
end

function NebStaffToMelee:uninit()
  self:reset()
end
