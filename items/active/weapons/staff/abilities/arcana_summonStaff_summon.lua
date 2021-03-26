require "/scripts/vec2.lua"
require "/scripts/util.lua"

ControlProjectile = WeaponAbility:new()

function ControlProjectile:init()

  storage.projectiles = storage.projectiles or {}

  self.elementalType = self.elementalType or self.weapon.elementalType

  self.baseDamageFactor = 10
  self.stances = config.getParameter("stances")

  activeItem.setCursor("/cursors/reticle0.cursor")
  self.weapon:setStance(self.stances.idle)

  self.weapon.onLeaveAbility = function()
    self:reset()
  end
end

function ControlProjectile:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  world.debugPoint(self:focusPosition(), "blue")

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.weapon.currentAbility
    and not status.resourceLocked("energy") then

    self:setState(self.charge)
  end
end

function ControlProjectile:charge()
  self.weapon:setStance(self.stances.charge)

  animator.playSound(self.elementalType.."charge")
  animator.setAnimationState("charge", "charge")
  animator.setParticleEmitterActive(self.elementalType .. "charge", true)
  activeItem.setCursor("/cursors/charge2.cursor")

  local chargeTimer = self.stances.charge.duration
  while chargeTimer > 0 and self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    chargeTimer = chargeTimer - self.dt

    mcontroller.controlModifiers({runningSuppressed=true})

    coroutine.yield()
  end

  animator.stopAllSounds(self.elementalType.."charge")

  if chargeTimer <= 0 then
    self:setState(self.charged)
  else
    animator.playSound(self.elementalType.."discharge")
    self:setState(self.cooldown)
  end
end

function ControlProjectile:charged()
  self.weapon:setStance(self.stances.charged)

  animator.playSound(self.elementalType.."fullcharge")
  animator.playSound(self.elementalType.."chargedloop", -1)
  animator.setParticleEmitterActive(self.elementalType .. "charge", true)

  local targetValid
  while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    targetValid = self:targetValid(activeItem.ownerAimPosition())
    activeItem.setCursor(targetValid and "/cursors/chargeready.cursor" or "/cursors/chargeinvalid.cursor")

    mcontroller.controlModifiers({runningSuppressed=true})

    coroutine.yield()
  end

  self:setState(self.discharge)
end

function ControlProjectile:discharge()
  self.weapon:setStance(self.stances.discharge)

  activeItem.setCursor("/cursors/reticle0.cursor")

  if self:targetValid(activeItem.ownerAimPosition()) and status.overConsumeResource("energy", self.energyCost * 1) then
    animator.playSound(self.elementalType.."activate")
    self:createMonsters()
  else
    animator.playSound(self.elementalType.."discharge")
    self:setState(self.cooldown)
    return
  end

  util.wait(self.stances.discharge.duration, function(dt)
    status.setResourcePercentage("energyRegenBlock", 1.0)
  end)

  animator.playSound(self.elementalType.."discharge")
  animator.stopAllSounds(self.elementalType.."chargedloop")

  self:setState(self.cooldown)
end

function ControlProjectile:cooldown()
  self.weapon:setStance(self.stances.cooldown)
  self.weapon.aimAngle = 0

  animator.setAnimationState("charge", "discharge")
  animator.setParticleEmitterActive(self.elementalType .. "charge", false)
  activeItem.setCursor("/cursors/reticle0.cursor")

  util.wait(self.stances.cooldown.duration, function()

  end)
end

function ControlProjectile:targetValid(aimPos)
  local focusPos = self:focusPosition()
  return world.magnitude(focusPos, aimPos) <= self.maxCastRange
      and not world.lineTileCollision(mcontroller.position(), focusPos)
      and not world.lineTileCollision(focusPos, aimPos)
end

function ControlProjectile:createMonsters(monsterType)
  local aimPosition = activeItem.ownerAimPosition()
  local fireDirection = world.distance(aimPosition, self:focusPosition())[1] > 0 and 1 or -1
  local pOffset = {fireDirection * (self.monsterDistance or 0), 0}
  local basePos = activeItem.ownerAimPosition()

  local pCount = self.monsterCount or 1

  local mParams = copy(self.monsterParameters)
  mParams.power = 10
  mParams.powerMultiplier = activeItem.ownerPowerMultiplier()
  
  local tempmonsterType = copy(self.monsterType)

  for i = 1, pCount do
  
	if not monsterType then
		monsterType = self.monsterType
	end
	
    local monsterId = world.spawnMonster(
		monsterType,
        vec2.add(basePos, pOffset),
        mParams
      )

    pOffset = vec2.rotate(pOffset, (2 * math.pi) / pCount)
  end
end

function ControlProjectile:focusPosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(animator.partPoint("stone", "focalPoint")))
end

function ControlProjectile:reset()
  self.weapon:setStance(self.stances.idle)
  animator.stopAllSounds(self.elementalType.."chargedloop")
  animator.stopAllSounds(self.elementalType.."fullcharge")
  animator.setAnimationState("charge", "idle")
  animator.setParticleEmitterActive(self.elementalType .. "charge", false)
  activeItem.setCursor("/cursors/reticle0.cursor")
end

function ControlProjectile:uninit(weaponUninit)
  self:reset()
end
