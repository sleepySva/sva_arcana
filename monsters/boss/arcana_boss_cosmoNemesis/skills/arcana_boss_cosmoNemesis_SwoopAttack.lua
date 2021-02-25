arcana_boss_cosmoNemesis_SwoopAttack = {}

function arcana_boss_cosmoNemesis_SwoopAttack.enter()
  if not hasTarget() then return nil end
  if self.targetPosition == nil then return nil end

  return {
    timer = 0.0,
    swoopTime = config.getParameter("arcana_boss_cosmoNemesis_SwoopAttack.swoopTime"),
    tookDamage = false
  }
end

function arcana_boss_cosmoNemesis_SwoopAttack.enteringState(stateData)
  monster.setActiveSkillName("arcana_boss_cosmoNemesis_SwoopAttack")
end

function arcana_boss_cosmoNemesis_SwoopAttack.update(dt, stateData)
  mcontroller.controlFace(1)
  if not hasTarget() then return true end

  local position = mcontroller.position()
  if stateData.basePosition == nil then
    stateData.basePosition = { self.targetPosition[1], position[2] }
    stateData.toTarget = world.distance(vec2.add(self.targetPosition, {0, 4.0}), position)

    monster.setDamageOnTouch(true)
  end

  stateData.timer = stateData.timer + dt

  local timerRatio = stateData.timer / stateData.swoopTime
  local angle = timerRatio * math.pi
  local targetPosition = {
    stateData.basePosition[1] - math.cos(angle) * stateData.toTarget[1],
    stateData.basePosition[2] + math.sin(angle) * stateData.toTarget[2]
  }
  local toTarget = world.distance(targetPosition, mcontroller.position())
  mcontroller.setVelocity(vec2.mul(toTarget, 1 / dt))

  if stateData.timer > stateData.swoopTime or checkWalls(util.toDirection(toTarget[1])) then
    return true
  else
    return false
  end
end


function arcana_boss_cosmoNemesis_SwoopAttack.leavingState(stateData)
  monster.setDamageOnTouch(false)
end
