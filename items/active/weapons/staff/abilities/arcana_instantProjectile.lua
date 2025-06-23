require "/scripts/vec2.lua"
require "/scripts/util.lua"

ControlProjectile = WeaponAbility:new()

function ControlProjectile:init()
  storage.projectiles = storage.projectiles or {}

  self.elementalType = self.elementalType or self.weapon.elementalType

  self.baseDamageFactor = config.getParameter("baseDamageFactor", 1.0)
  self.stances = config.getParameter("stances")

  activeItem.setCursor("/cursors/reticle0.cursor")
  self.weapon:setStance(self.stances.idle)

  self.weapon.onLeaveAbility = function()
    self:reset()
  end
end

function ControlProjectile:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self:updateProjectiles()

  world.debugPoint(self:focusPosition(), "blue")

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.weapon.currentAbility
    and not status.resourceLocked("energy") then

    self:setState(self.charge)
  end
end

function ControlProjectile:charge()
  local stance = self.stances.charge
  self.weapon:setStance(stance)

  animator.playSound(self.elementalType.."charge")
  animator.setAnimationState("charge", "charge")
  animator.setParticleEmitterActive(self.elementalType .. "charge", true)
  activeItem.setCursor("/cursors/charge2.cursor")

  local chargeTimer = 0
  local chargeTime = stance.duration or 0.2
  while chargeTimer < chargeTime and self.fireMode == (self.activatingFireMode or self.abilitySlot) do
    chargeTimer = math.min(chargeTime, chargeTimer + self.dt)
    mcontroller.controlModifiers({runningSuppressed=true})
	local chargeRatio = math.sin(chargeTimer / chargeTime * 1.57)
    self.weapon.relativeArmRotation = util.toRadians(util.lerp(chargeRatio, {stance.armRotation, stance.endArmRotation or stance.armRotation}))
    self.weapon.relativeWeaponRotation = util.toRadians(util.lerp(chargeRatio, {stance.weaponRotation, stance.endWeaponRotation or stance.weaponRotation}))
    coroutine.yield()
  end

  animator.stopAllSounds(self.elementalType.."charge")

  if chargeTimer >= chargeTime then
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

  self:setState(self.discharge)
end

function ControlProjectile:discharge()
  local stance = self.stances.discharge
  self.weapon:setStance(stance)
  activeItem.setCursor("/cursors/reticle0.cursor")

  if status.overConsumeResource("energy", self.energyCost * self.baseDamageFactor) then
    animator.playSound(self.elementalType.."activate")
    self:createProjectiles()
  end
  
  local chargeTimer = 0
  local chargeTime = stance.duration or 0.2

  util.wait(stance.duration, function(dt)
    status.setResourcePercentage("energyRegenBlock", 1.0)
	chargeTimer = math.min(chargeTime, chargeTimer + self.dt)
	local chargeRatio = math.sin(chargeTimer / chargeTime * 1.57)
    self.weapon.relativeArmRotation = util.toRadians(util.lerp(chargeRatio, {stance.armRotation, stance.endArmRotation or stance.armRotation}))
    self.weapon.relativeWeaponRotation = util.toRadians(util.lerp(chargeRatio, {stance.weaponRotation, stance.endWeaponRotation or stance.weaponRotation}))
  end)

  while #storage.projectiles > 0 do
    self.lastFireMode = self.fireMode

    status.setResourcePercentage("energyRegenBlock", 1.0)
    coroutine.yield()
  end

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

function ControlProjectile:createProjectiles()
  local aimPosition = activeItem.ownerAimPosition()
  local fireDirection = world.distance(aimPosition, self:focusPosition())[1] > 0 and 1 or -1
  local pOffset = {fireDirection * (self.projectileDistance or 0), 0}
  local basePos = activeItem.ownerAimPosition()

  local pCount = self.projectileCount or 1

  local pParams = copy(self.projectileParameters)
  pParams.power = self.baseDamageFactor * pParams.baseDamage * config.getParameter("damageLevelMultiplier") / pCount
  pParams.powerMultiplier = activeItem.ownerPowerMultiplier()

  for i = 1, pCount do
    local projectileId = world.spawnProjectile(
        self.projectileType,
        vec2.add(basePos, pOffset),
        activeItem.ownerEntityId(),
        pOffset,
        false,
        pParams
      )

    if projectileId then
      table.insert(storage.projectiles, projectileId)
      world.sendEntityMessage(projectileId, "updateProjectile", aimPosition)
    end

    pOffset = vec2.rotate(pOffset, (2 * math.pi) / pCount)
  end
end

function ControlProjectile:focusPosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(animator.partPoint("stone", "focalPoint")))
end

-- give all projectiles a new aim position and let those projectiles return one or
-- more entity ids for projectiles we should now be tracking
function ControlProjectile:updateProjectiles()
  local aimPosition = activeItem.ownerAimPosition()
  local newProjectiles = {}
  for _, projectileId in pairs(storage.projectiles) do
    if world.entityExists(projectileId) then
      local projectileResponse = world.sendEntityMessage(projectileId, "updateProjectile", aimPosition)
      if projectileResponse:finished() then
        local newIds = projectileResponse:result()
        if type(newIds) ~= "table" then
          newIds = {newIds}
        end
        for _, newId in pairs(newIds) do
          table.insert(newProjectiles, newId)
        end
      end
    end
  end
  storage.projectiles = newProjectiles
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
