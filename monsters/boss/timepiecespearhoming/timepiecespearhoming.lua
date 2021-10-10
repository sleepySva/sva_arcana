require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  message.setHandler("despawn", despawn)

  monster.setDeathParticleBurst("deathPoof")
  monster.setDeathSound("deathPuff")

  self.state = FSM:new()

  self.managerUid = config.getParameter("managerUid")
  self.bossId = config.getParameter("bossId")
  self.triggerId = config.getParameter("triggerId")
  message.setHandler("setGroup", function(_,_, entityIds)
    self.group = entityIds
  end)

  self.targetRange = config.getParameter("targetRange", 150)
  self.flySpeed = mcontroller.baseParameters().flySpeed

  message.setHandler("collide", function(_, _, position)
    self.state:set(despawnState, position)
  end)

  if config.getParameter("partOfGroup", false) then
    self.state:set(blorbState)
  else
    self.state:set(spawnState)
  end
end

function update(dt)
  if self.bossId and not world.entityExists(self.bossId) then
    self.state:set(despawnState)
    self.bossId = nil
  end

  if status.resourcePositive("stunned") then
    animator.setGlobalTag("hurt", "hurt")
    self.stunned = true
    mcontroller.clearControls()
    if self.damaged then
      self.suppressDamageTimer = config.getParameter("stunDamageSuppression", 0.5)
      monster.setDamageOnTouch(false)
    end
    return
  else
    animator.setGlobalTag("hurt", "")
  end

  self.state:update()
end

function despawn()
  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)
  monster.setDeathSound(nil)
  status.addEphemeralEffect("monsterdespawn")
end

function die()
  if self.triggerId and not self.despawn then
    -- trigger boss event if last one in the group to die
	self.state:set(fireState, util.randomFromList(players))
    local group = util.filter(self.group, world.entityExists)
    if #group == 1 then
      world.sendEntityMessage(self.managerUid, "trigger", self.triggerId, mcontroller.position())
    end
  end
end

-- States

function blorbState()
  while self.group == nil do
    status.addEphemeralEffect("invulnerable", 1.0)
    coroutine.yield()
  end
  self.state:set(spawnState)
end

function spawnState()
  monster.setDamageBar("None")
  status.setResource("health", 10000)
  status.addEphemeralEffect("invulnerable", 2)
  monster.setDamageOnTouch(false)

  animator.setAnimationState("body", "spawn")
  while animator.animationState("body") == "spawn" do
    coroutine.yield()
  end

  status.removeEphemeralEffect("invulnerable")
  self.state:set(idleState)
end

function idleState()
  animator.setAnimationState("body", "idle")
  animator.resetTransformationGroup("body")
  local players = world.entityQuery(entity.position(), self.targetRange, {includedTypes = {"player"}})
  -- target valid targets in sight
  players = util.filter(players, function(playerId)
      return entity.isValidTarget(playerId)
	  end)

  if status.resource("health") < 10000 then
    self.state:set(fireState, util.randomFromList(players))
  else
    self.state:set(despawnState)
  end
end

function fireState(targetId)
  monster.setDamageOnTouch(false)

  local attack = config.getParameter("attack")
    local projectileConfig = root.projectileConfig(attack.projectileType)
  while true do
    util.wait(attack.cooldown, function()
      local targetPosition = world.entityPosition(targetId)
      return targetPosition == nil
	  end)

    local targetPosition = world.entityPosition(targetId)
    if targetPosition == nil then
      break
    end
    local toTarget = world.distance(targetPosition, entity.position())

    util.wait(attack.windup or 0.00000000001, function()
      targetPosition = world.entityPosition(targetId) or targetPosition
      toTarget = world.distance(targetPosition, entity.position())
      animator.resetTransformationGroup("body")
      animator.rotateTransformationGroup("body", vec2.angle({math.abs(toTarget[1]), toTarget[2]}))
      mcontroller.controlFace(toTarget[1])
    end)

    animator.setAnimationState("body", "fire")
    for i = 1, attack.fireCount do
      if attack.trackTarget then
        targetPosition = world.entityPosition(targetId) or targetPosition
        toTarget = world.distance(targetPosition, entity.position())
        animator.resetTransformationGroup("body")
        animator.rotateTransformationGroup("body", vec2.angle({math.abs(toTarget[1]), toTarget[2]}))
        mcontroller.controlFace(toTarget[1])
      end

      if attack.fireCount == 1 and attack.burstCount == 1 then
        animator.playSound("singleFire")
      elseif attack.fireCount == 1 then
        animator.playSound("burstFire")
      else
        animator.playSound("rapidFire")
      end

      for j = 1, attack.burstCount do
        local params = copy(attack.projectileParameters)
        params.power = params.power or projectileConfig.power or 10
        params.power = params.power * root.evalFunction("monsterLevelPowerMultiplier", monster.level())
        params.speed = (params.speed or projectileConfig.speed or 50) + util.randomInRange({-attack.fuzzSpeed, attack.fuzzSpeed})
        local angle = vec2.angle(toTarget) + util.randomInRange({-attack.fuzzAngle, attack.fuzzAngle})
        local aimPosition = vec2.add(entity.position(), vec2.withAngle(angle, math.max(vec2.mag(toTarget), attack.fuzzAimPosition)))
        aimPosition = vec2.add(aimPosition, vec2.withAngle(math.random() * math.pi * 2, math.random() * attack.fuzzAimPosition))
        if attack.fixedDistance then
          params.timeToLive = world.magnitude(targetPosition, entity.position()) / params.speed
          params.speed = world.magnitude(aimPosition, entity.position()) / params.timeToLive
        end

        local aimVector = vec2.norm(world.distance(aimPosition, entity.position()))
        local sourcePosition = animator.partPoint("body", "projectileSource")
        world.spawnProjectile(attack.projectileType, entity.position(), entity.id(), aimVector, false, params)
      end

      util.wait(attack.fireInterval, function()
        local targetPosition = world.entityPosition(targetId)
        return targetPosition == nil
      end)
    end

    animator.setAnimationState("body", "idle")
	status.addEphemeralEffect("monsterdespawn")
	status.setResource("health", 0)
    self.shouldDie = true
  end
  status.addEphemeralEffect("monsterdespawn")
  status.setResource("health", 0)
  self.shouldDie = true
end

function despawnState(pos)
  monster.setDamageOnTouch(false)

  mcontroller.setPosition(pos or entity.position())
  mcontroller.setVelocity({0, 0})

  monster.setDropPool(nil)
  monster.setDeathParticleBurst(nil)
  monster.setDeathSound(nil)

  util.wait(0.000000001)
  self.state:set(idleState)
end
