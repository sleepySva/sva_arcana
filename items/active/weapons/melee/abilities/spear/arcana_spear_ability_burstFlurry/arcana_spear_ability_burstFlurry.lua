require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

Flurry = WeaponAbility:new()

function Flurry:init()
  self.baseDamageFactor = config.getParameter("baseDamageFactor", 1.0)
  self.cooldownTimer = self.cooldownTime
  self:reset()
end

function Flurry:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.weapon.currentAbility == nil
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy")
    and self.fireMode == "alt" then
    
    self:setState(self.swing)
  end
end

function Flurry:firePosition()
  return vec2.add(mcontroller.position(), {0.1 * 1, -0.6})
end

function Flurry:aimVector()
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle)
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function Flurry:createProjectiles()

  local aimPosition = activeItem.ownerAimPosition()
  local pCount = self.projectileCount or 1
  local fireDirection = world.distance(aimPosition, self:firePosition())[1] > 0 and 1 or -1
  local pOffset = {fireDirection * (self.projectileDistance or 0), 0}
  local pParams = copy(self.projectileParameters)
  
  pParams.power = self.baseDamageFactor * pParams.baseDamage * config.getParameter("damageLevelMultiplier") / pCount
  pParams.powerMultiplier = activeItem.ownerPowerMultiplier()
  
  pOffset = vec2.rotate(pOffset, (((2 * math.pi) / pCount) / -10) * (pCount * 0.3))
  
  for i = 1, pCount do
  
    local projectileId = world.spawnProjectile(
        self.projectileType,
        self.firePosition(),
        activeItem.ownerEntityId(),
        self:aimVector(),
        false,
        pParams
      )
	  
	pOffset = vec2.rotate(pOffset, ((2 * math.pi) / pCount) / 10)
	
  end
  
end

function Flurry:swing()
  local cooldownTime = self.maxCooldownTime
  local currentRotationOffset = 1
  while self.fireMode == "alt" do
    if not status.overConsumeResource("energy", self.energyUsage) then break end

    self.weapon:setStance(self.stances.swing)
    self.weapon.relativeWeaponRotation = util.toRadians(self.stances.swing.weaponRotation + self.cycleRotationOffsets[currentRotationOffset])
    self.weapon.relativeArmRotation = util.toRadians(self.stances.swing.armRotation + self.cycleRotationOffsets[currentRotationOffset])
    self.weapon:updateAim()

    animator.setAnimationState("swoosh", "fire")
    animator.playSound("flurry")
	
	self:createProjectiles()
	
    util.wait(self.stances.swing.duration, function(dt)
      local damageArea = partDamageArea("swoosh")
      self.weapon:setDamage(self.damageConfig, damageArea)
    end)

    -- allow changing aim during cooldown
    self.weapon:setStance(self.stances.idle)
    util.wait(cooldownTime - self.stances.swing.duration, function(dt)
      return self.fireMode ~= "alt"
    end)

    cooldownTime = math.max(self.minCooldownTime, cooldownTime - self.cooldownSwingReduction)

    currentRotationOffset = currentRotationOffset + 1
    if currentRotationOffset > #self.cycleRotationOffsets then
      currentRotationOffset = 1
    end
  end
  self.cooldownTimer = self.cooldownTime
end

function Flurry:reset()
end

function Flurry:uninit()
  self:reset()
end
