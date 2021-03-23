--------------------------------------------------------------------------------
arcana_boss_hue_MoveFireAttack_2 = {
  attackTimer = 0,
  fireTimer = 0,
  cooldownTimer = 0,
  firing = false
}

function arcana_boss_hue_MoveFireAttack_2.enter()
  if not hasTarget() then return nil end

  rangedAttack.setConfig(config.getParameter("arcana_boss_hue_MoveFireAttack_2.projectile.type"), config.getParameter("arcana_boss_hue_MoveFireAttack_2.projectile.config"), config.getParameter("arcana_boss_hue_MoveFireAttack_2.fireInterval"))

  arcana_boss_hue_MoveFireAttack_2.attackTime = config.getParameter("attackTime", 1)
  arcana_boss_hue_MoveFireAttack_2.cooldownTime = config.getParameter("cooldownTime", 0)
  arcana_boss_hue_MoveFireAttack_2.sourceOffset = config.getParameter("projectileSourcePosition", {0, 0})

  return {
    timer = 0,
    bobTime = config.getParameter("arcana_boss_hue_MoveFireAttack_2.bobTime"),
    bobHeight = config.getParameter("arcana_boss_hue_MoveFireAttack_2.bobHeight"),
    skillTime = config.getParameter("arcana_boss_hue_MoveFireAttack_2.skillTime"),
    direction = util.randomDirection(),
    basePosition = self.spawnPosition,
    cruiseDistance = config.getParameter("cruiseDistance")
  }
end

function arcana_boss_hue_MoveFireAttack_2.enteringState(stateData)
  monster.setActiveSkillName(nil)
end

function arcana_boss_hue_MoveFireAttack_2.fire()
  local pOffset = config.getParameter("arcana_boss_hue_MoveFireAttack_2.projectileOffset")
  local toTarget = vec2.norm(world.distance(self.targetPosition, monster.toAbsolutePosition(pOffset)))
  
  local pType = config.getParameter("arcana_boss_hue_MoveFireAttack_2.projectile.type")
  local pConfig = config.getParameter("arcana_boss_hue_MoveFireAttack_2.projectile.config")
  local pCount = config.getParameter("arcana_boss_hue_MoveFireAttack_2.projectileCount")
  local pDirection = toTarget
  
  pDirection = vec2.rotate(pDirection, (((2 * math.pi) / pCount) / -1.2) * ((pCount - 1) * 0.3))
 
  for i = 1, pCount do
  
	world.spawnProjectile(pType, monster.toAbsolutePosition(rangedAttack.sourceOffset), entity.id(), pDirection, false, pConfig)
	pDirection = vec2.rotate(pDirection, ((2 * math.pi) / pCount) / 1.2)
  
  end
end

function arcana_boss_hue_MoveFireAttack_2.fireContinuous()

	local pOffset = config.getParameter("arcana_boss_hue_MoveFireAttack_2.projectileOffset")
	local toTarget = vec2.norm(world.distance(self.targetPosition, monster.toAbsolutePosition(pOffset)))
		  
	local pType = config.getParameter("arcana_boss_hue_MoveFireAttack_2.projectile.type")
	local pConfig = config.getParameter("arcana_boss_hue_MoveFireAttack_2.projectile.config")
	local pCount = config.getParameter("arcana_boss_hue_MoveFireAttack_2.projectileCount")
	local pDirection = toTarget
		  
	pDirection = vec2.rotate(pDirection, math.random(2000))

  if not arcana_boss_hue_MoveFireAttack_2.firing then
    arcana_boss_hue_MoveFireAttack_2.firing = true
    arcana_boss_hue_MoveFireAttack_2.attackTimer = arcana_boss_hue_MoveFireAttack_2.attackTime
  elseif arcana_boss_hue_MoveFireAttack_2.cooldownTimer <= 0 then
    arcana_boss_hue_MoveFireAttack_2.attackTimer = arcana_boss_hue_MoveFireAttack_2.attackTimer - script.updateDt()
    if arcana_boss_hue_MoveFireAttack_2.attackTimer <= 0 then
      arcana_boss_hue_MoveFireAttack_2.cooldownTimer = arcana_boss_hue_MoveFireAttack_2.cooldownTime
      arcana_boss_hue_MoveFireAttack_2.attackTimer = arcana_boss_hue_MoveFireAttack_2.attackTime
    else
      arcana_boss_hue_MoveFireAttack_2.fireTimer = arcana_boss_hue_MoveFireAttack_2.fireTimer - script.updateDt()
      if arcana_boss_hue_MoveFireAttack_2.fireTimer <= 0 then
        
		
		world.spawnProjectile(pType, monster.toAbsolutePosition(rangedAttack.sourceOffset), entity.id(), pDirection, false, pConfig)
		pDirection = vec2.rotate(pDirection, math.random(2000))
		
		
        arcana_boss_hue_MoveFireAttack_2.fireTimer = config.getParameter("arcana_boss_hue_MoveFireAttack_2.fireInterval")
      end
    end
  else
    arcana_boss_hue_MoveFireAttack_2.cooldownTimer = arcana_boss_hue_MoveFireAttack_2.cooldownTimer - script.updateDt()
  end
end

function arcana_boss_hue_MoveFireAttack_2.stopFiring()
  arcana_boss_hue_MoveFireAttack_2.firing = false
end

function arcana_boss_hue_MoveFireAttack_2.update(dt, stateData)
  mcontroller.controlFace(1)
  if not hasTarget() then return true end

  arcana_boss_hue_MoveFireAttack_2.fireContinuous()

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

function arcana_boss_hue_MoveFireAttack_2.leavingState(stateData)
end
