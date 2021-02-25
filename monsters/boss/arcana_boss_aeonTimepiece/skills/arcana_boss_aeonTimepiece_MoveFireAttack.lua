--------------------------------------------------------------------------------
arcana_boss_aeonTimepiece_MoveFireAttack = {
  attackTimer = 0,
  fireTimer = 0,
  cooldownTimer = 0,
  firing = false
}

function arcana_boss_aeonTimepiece_MoveFireAttack.enter()
  if not hasTarget() then return nil end

  rangedAttack.setConfig(config.getParameter("arcana_boss_aeonTimepiece_MoveFireAttack.projectile.type"), config.getParameter("arcana_boss_aeonTimepiece_MoveFireAttack.projectile.config"), config.getParameter("arcana_boss_aeonTimepiece_MoveFireAttack.fireInterval"))

  arcana_boss_aeonTimepiece_MoveFireAttack.attackTime = config.getParameter("attackTime", 1)
  arcana_boss_aeonTimepiece_MoveFireAttack.cooldownTime = config.getParameter("cooldownTime", 0)
  arcana_boss_aeonTimepiece_MoveFireAttack.sourceOffset = config.getParameter("projectileSourcePosition", {0, 0})

  return {
    timer = 0,
    bobTime = config.getParameter("arcana_boss_aeonTimepiece_MoveFireAttack.bobTime"),
    bobHeight = config.getParameter("arcana_boss_aeonTimepiece_MoveFireAttack.bobHeight"),
    skillTime = config.getParameter("arcana_boss_aeonTimepiece_MoveFireAttack.skillTime"),
    direction = util.randomDirection(),
    basePosition = self.spawnPosition,
    cruiseDistance = config.getParameter("cruiseDistance")
  }
end

function arcana_boss_aeonTimepiece_MoveFireAttack.enteringState(stateData)
  monster.setActiveSkillName(nil)
end

function arcana_boss_aeonTimepiece_MoveFireAttack.fire()
  local pOffset = config.getParameter("arcana_boss_aeonTimepiece_MoveFireAttack.projectileOffset")
  local toTarget = vec2.norm(world.distance(self.targetPosition, monster.toAbsolutePosition(pOffset)))
  
  local pType = config.getParameter("arcana_boss_aeonTimepiece_MoveFireAttack.projectile.type")
  local pConfig = config.getParameter("arcana_boss_aeonTimepiece_MoveFireAttack.projectile.config")
  local pCount = config.getParameter("arcana_boss_aeonTimepiece_MoveFireAttack.projectileCount")
  local pDirection = toTarget
  
  pDirection = vec2.rotate(pDirection, (((2 * math.pi) / pCount) / -1.2) * ((pCount - 1) * 0.3))
 
  for i = 1, pCount do
  
	world.spawnProjectile(pType, monster.toAbsolutePosition(rangedAttack.sourceOffset), entity.id(), pDirection, false, pConfig)
	pDirection = vec2.rotate(pDirection, ((2 * math.pi) / pCount) / 1.2)
  
  end
end

function arcana_boss_aeonTimepiece_MoveFireAttack.fireContinuous()
  if not arcana_boss_aeonTimepiece_MoveFireAttack.firing then
    arcana_boss_aeonTimepiece_MoveFireAttack.firing = true
    arcana_boss_aeonTimepiece_MoveFireAttack.attackTimer = arcana_boss_aeonTimepiece_MoveFireAttack.attackTime
  elseif arcana_boss_aeonTimepiece_MoveFireAttack.cooldownTimer <= 0 then
    arcana_boss_aeonTimepiece_MoveFireAttack.attackTimer = arcana_boss_aeonTimepiece_MoveFireAttack.attackTimer - script.updateDt()
    if arcana_boss_aeonTimepiece_MoveFireAttack.attackTimer <= 0 then
      arcana_boss_aeonTimepiece_MoveFireAttack.cooldownTimer = arcana_boss_aeonTimepiece_MoveFireAttack.cooldownTime
      arcana_boss_aeonTimepiece_MoveFireAttack.attackTimer = arcana_boss_aeonTimepiece_MoveFireAttack.attackTime
    else
      arcana_boss_aeonTimepiece_MoveFireAttack.fireTimer = arcana_boss_aeonTimepiece_MoveFireAttack.fireTimer - script.updateDt()
      if arcana_boss_aeonTimepiece_MoveFireAttack.fireTimer <= 0 then
        arcana_boss_aeonTimepiece_MoveFireAttack.fire()
        arcana_boss_aeonTimepiece_MoveFireAttack.fireTimer = config.getParameter("arcana_boss_aeonTimepiece_MoveFireAttack.fireInterval")
      end
    end
  else
    arcana_boss_aeonTimepiece_MoveFireAttack.cooldownTimer = arcana_boss_aeonTimepiece_MoveFireAttack.cooldownTimer - script.updateDt()
  end
end

function arcana_boss_aeonTimepiece_MoveFireAttack.stopFiring()
  arcana_boss_aeonTimepiece_MoveFireAttack.firing = false
end

function arcana_boss_aeonTimepiece_MoveFireAttack.update(dt, stateData)
  mcontroller.controlFace(1)
  if not hasTarget() then return true end

  arcana_boss_aeonTimepiece_MoveFireAttack.fireContinuous()

  local position = mcontroller.position()

  local toTarget = world.distance(self.targetPosition, position)
  if toTarget[1] < -stateData.cruiseDistance or checkWalls(1) then
    stateData.direction = -1
  elseif toTarget[1] > stateData.cruiseDistance or checkWalls(-1) then
    stateData.direction = 1
  end

  stateData.timer = stateData.timer + dt
  local angle = 2.0 * math.pi * stateData.timer / stateData.bobTime
  local targetPosition = {
    position[1] + stateData.direction * 5,
    stateData.basePosition[2] + stateData.bobHeight * math.cos(angle)
  }
  flyTo(targetPosition)

  if stateData.timer > stateData.skillTime then
    return true
  else
    return false
  end
end

function arcana_boss_aeonTimepiece_MoveFireAttack.leavingState(stateData)
end
