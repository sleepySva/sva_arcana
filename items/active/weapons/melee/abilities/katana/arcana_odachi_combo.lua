require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

-- Melee primary ability
MeleeCombo = WeaponAbility:new()

function MeleeCombo:init()

  self.elementalType = self.elementalType or self.weapon.elementalType
  self.baseDamageFactor = config.getParameter("baseDamageFactor", 1.0)
  
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





function MeleeCombo:firePosition()
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(0, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function MeleeCombo:createProjectiles()

  local aimPosition = activeItem.ownerAimPosition()
  local pCount = self.projectileCount or 1
  local position = vec2.add(mcontroller.position(), {self.projectileOffset[1] * mcontroller.facingDirection(), self.projectileOffset[2]})
  local pParams = copy(self.projectileParameters)
  
  pParams.power = self.baseDamageFactor * pParams.baseDamage * config.getParameter("damageLevelMultiplier") / pCount
  pParams.powerMultiplier = activeItem.ownerPowerMultiplier()
  
  for i = 1, pCount do
  
    local projectileId = world.spawnProjectile(
        self.projectileType,
        position,
        activeItem.ownerEntityId(),
        self:firePosition(),
        false,
        pParams
      )
	
  end
  
end





-- State: windup
function MeleeCombo:windup()
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
  
  if self.comboStep == 4 then
	self:createProjectiles()
  end
  if self.comboStep == 5 then
    mcontroller.setVelocity({0, 0.4 * self.dashSpeed})
    mcontroller.controlMove(self.weapon.aimDirection)
  end
  if self.comboStep == 6 then
    local secondaryProjectileTimesAndAngles = copy(self.secondaryProjectileTimesAndAngles)
	util.wait(0.2, function(dt)
	  local newTimesAndAngles = {}
      for _, timeAndAngle in pairs(secondaryProjectileTimesAndAngles) do
        if timeAndAngle[1] <= dt then
          self:spawnProjectile(timeAndAngle[2])
        else
          table.insert(newTimesAndAngles, {timeAndAngle[1] - dt, timeAndAngle[2]})
        end
      end
	  secondaryProjectileTimesAndAngles = newTimesAndAngles
	end)
  end

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
  end
end


function MeleeCombo:damageAmount()
  return self.baseDamage * config.getParameter("damageLevelMultiplier")
end


function MeleeCombo:spawnProjectile(angleAdjust)
  local position = vec2.add(mcontroller.position(), {self.secondaryProjectileOffset[1] * self.weapon.aimDirection, self.secondaryProjectileOffset[2]})
  local params = {
    powerMultiplier = activeItem.ownerPowerMultiplier(),
    power = self:damageAmount()
  }
  local aimVector = self:firePosition()
  world.spawnProjectile(self.secondaryProjectileType, position, activeItem.ownerEntityId(), aimVector, false, params)
  animator.playSound("fireKunai")
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
  self.weapon:setDamage()
end
