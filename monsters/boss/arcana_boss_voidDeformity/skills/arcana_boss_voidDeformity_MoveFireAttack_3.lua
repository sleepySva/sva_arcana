--------------------------------------------------------------------------------
arcana_boss_voidDeformity_MoveFireAttack_3 = {
  attackTimer = 0,
  fireTimer = 0,
  cooldownTimer = 0,
  firing = false
}

function arcana_boss_voidDeformity_MoveFireAttack_3.enter()
  if not hasTarget() then return nil end

  rangedAttack.setConfig(config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.projectile.type"), config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.projectile.config"), config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.fireInterval"))

  arcana_boss_voidDeformity_MoveFireAttack_3.attackTime = config.getParameter("attackTime", 1)
  arcana_boss_voidDeformity_MoveFireAttack_3.cooldownTime = config.getParameter("cooldownTime", 0)
  arcana_boss_voidDeformity_MoveFireAttack_3.sourceOffset = config.getParameter("projectileSourcePosition", {0, 0})

  return {
    timer = 0,
    bobTime = config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.bobTime"),
    bobHeight = config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.bobHeight"),
    skillTime = config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.skillTime"),
    direction = util.randomDirection(),
    basePosition = self.spawnPosition,
    cruiseDistance = config.getParameter("cruiseDistance")
  }
end

function arcana_boss_voidDeformity_MoveFireAttack_3.enteringState(stateData)
  monster.setActiveSkillName(nil)
end

function arcana_boss_voidDeformity_MoveFireAttack_3.fire()
  local pOffset = config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.projectileOffset")
  local toTarget = vec2.norm(world.distance(self.targetPosition, monster.toAbsolutePosition(pOffset)))
  
  local pType = config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.projectile.type")
  local pConfig = config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.projectile.config")
  local pCount = config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.projectileCount")
  local pDirection = toTarget
  
  pDirection = vec2.rotate(pDirection, (((2 * math.pi) / pCount) / -1.2) * ((pCount - 1) * 0.3))
 
  for i = 1, pCount do
  
	world.spawnProjectile(pType, monster.toAbsolutePosition(rangedAttack.sourceOffset), entity.id(), pDirection, false, pConfig)
	pDirection = vec2.rotate(pDirection, ((2 * math.pi) / pCount) / 1.2)
  
  end
end

function arcana_boss_voidDeformity_MoveFireAttack_3.fireContinuous()

	local pOffset = config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.projectileOffset")
	local toTarget = vec2.norm(world.distance(self.targetPosition, monster.toAbsolutePosition(pOffset)))
		  
	local pType = config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.projectile.type")
	local pConfig = config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.projectile.config")
	local pCount = config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.projectileCount")
	local pDirection = toTarget
		  
	pDirection = vec2.rotate(pDirection, math.random(2000))

  if not arcana_boss_voidDeformity_MoveFireAttack_3.firing then
    arcana_boss_voidDeformity_MoveFireAttack_3.firing = true
    arcana_boss_voidDeformity_MoveFireAttack_3.attackTimer = arcana_boss_voidDeformity_MoveFireAttack_3.attackTime
  elseif arcana_boss_voidDeformity_MoveFireAttack_3.cooldownTimer <= 0 then
    arcana_boss_voidDeformity_MoveFireAttack_3.attackTimer = arcana_boss_voidDeformity_MoveFireAttack_3.attackTimer - script.updateDt()
    if arcana_boss_voidDeformity_MoveFireAttack_3.attackTimer <= 0 then
      arcana_boss_voidDeformity_MoveFireAttack_3.cooldownTimer = arcana_boss_voidDeformity_MoveFireAttack_3.cooldownTime
      arcana_boss_voidDeformity_MoveFireAttack_3.attackTimer = arcana_boss_voidDeformity_MoveFireAttack_3.attackTime
    else
      arcana_boss_voidDeformity_MoveFireAttack_3.fireTimer = arcana_boss_voidDeformity_MoveFireAttack_3.fireTimer - script.updateDt()
      if arcana_boss_voidDeformity_MoveFireAttack_3.fireTimer <= 0 then
        
		
		world.spawnProjectile(pType, monster.toAbsolutePosition(rangedAttack.sourceOffset), entity.id(), pDirection, false, pConfig)
		pDirection = vec2.rotate(pDirection, math.random(2000))
		
		
        arcana_boss_voidDeformity_MoveFireAttack_3.fireTimer = config.getParameter("arcana_boss_voidDeformity_MoveFireAttack_3.fireInterval")
      end
    end
  else
    arcana_boss_voidDeformity_MoveFireAttack_3.cooldownTimer = arcana_boss_voidDeformity_MoveFireAttack_3.cooldownTimer - script.updateDt()
  end
end

function arcana_boss_voidDeformity_MoveFireAttack_3.stopFiring()
  arcana_boss_voidDeformity_MoveFireAttack_3.firing = false
end

function arcana_boss_voidDeformity_MoveFireAttack_3.update(dt, stateData)
  mcontroller.controlFace(1)
  if not hasTarget() then return true end

  arcana_boss_voidDeformity_MoveFireAttack_3.fireContinuous()

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

function arcana_boss_voidDeformity_MoveFireAttack_3.leavingState(stateData)
end
