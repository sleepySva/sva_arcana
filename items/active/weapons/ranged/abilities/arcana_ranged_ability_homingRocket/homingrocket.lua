require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

HomingRocketAttack = GunFire:new()

function HomingRocketAttack:new(abilityConfig)
  local primary = config.getParameter("primaryAbility")
  return GunFire.new(self, sb.jsonMerge(primary, abilityConfig))
end

function HomingRocketAttack:init()
  self.cooldownTimer = 0
  self.activeRockets = {}
  self.newRockets = {}
end

function HomingRocketAttack:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self:updateRockets(dt)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.fireMode == "alt"
     and not self.weapon.currentAbility
     and self.cooldownTimer == 0
     and not world.lineTileCollision(mcontroller.position(), self:firePosition())
     and status.overConsumeResource("energy", self:energyPerShot()) then

    self:setState(self.fire)
  end
end

function HomingRocketAttack:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  local projectileId = self:fireProjectile()
  self.newRockets[projectileId] = self.rocketWindupTime

  animator.setPartTag("muzzleFlash", "variant", math.random(1, 3))
  animator.setAnimationState("firing", "fire")
  animator.burstParticleEmitter("altMuzzleFlash", true)
  animator.playSound("altFire")

  self:setState(self.cooldown)
end

function HomingRocketAttack:reset()
end

function HomingRocketAttack:uninit(unequipped)
  self:reset()

  if unequipped then
    for _, rocketPair in pairs(self.activeRockets) do
      if world.entityExists(rocketPair[1]) then
        world.callScriptedEntity(rocketPair[1], "setTarget", nil)
      end
    end
  end
end

function HomingRocketAttack:updateRockets(dt)
  -- Windup time for new rockets
  for rocketId,timer in pairs(self.newRockets) do
    self.newRockets[rocketId] = math.max(0, timer - dt)
    if timer == 0 then
      if world.entityExists(rocketId) then
        if self:findTarget(rocketId) then
          animator.playSound("targetAcquired")
          self.newRockets[rocketId] = nil
        else
          self.newRockets[rocketId] = 0.2
        end
      else
        self.newRockets[rocketId] = nil
      end
    end
  end

  -- Update active rocket list
  self.activeRockets = util.filter(self.activeRockets, function(rocketPair)
    return world.entityExists(rocketPair[1]) and world.entityExists(rocketPair[2])
  end)
  local targets = util.map(self.activeRockets, function(v) return v[2] end)
  activeItem.setScriptedAnimationParameter("targets", targets)
end

function HomingRocketAttack:findTarget(rocketId)
  local nearEntities = world.entityQuery(world.entityPosition(rocketId), self.queryRange, {
    includedTypes = {"npc", "monster", "player"},
    order = "nearest"
  })
  nearEntities = util.filter(nearEntities, function(entityId)
    if world.lineTileCollision(world.entityPosition(rocketId), world.entityPosition(entityId)) then
      return false
    end

    if not world.entityCanDamage(activeItem.ownerEntityId(), entityId) then
      return false
    end

    if world.entityDamageTeam(entityId).type == "passive" then
      return false
    end

    return true
  end)
  local targetId = nearEntities[1]
  if targetId then
    world.callScriptedEntity(rocketId, "setTarget", targetId)
    table.insert(self.activeRockets, {rocketId, targetId})
    return true
  end
  return false
end
