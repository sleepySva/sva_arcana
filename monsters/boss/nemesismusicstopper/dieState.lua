--------------------------------------------------------------------------------
dieState = {}

dieState.enterWith = function(params)
  if not params.die then return nil end
  
  rangedAttack.setConfig(config.getParameter("projectiles.deathexplosion.type"), config.getParameter("projectiles.deathexplosion.config"), 0.2)

  return {
    timer = 6.0,
    basePosition = mcontroller.position(),
  }
end

function dieState.enteringState(stateData)
  animator.setAnimationState("movesound", "off")
  animator.setAnimationState("movement", "visible")
end

function dieState.update(dt, stateData)
  mcontroller.controlFace(1)
  mcontroller.controlParameters({gravityEnabled = true})

  if mcontroller.onGround() then
    if stateData.timer > 1.6 then
      stateData.timer = 1.6
    end

    animator.rotateGroup("all", -13 * math.pi / 180)

    if stateData.timer > 1.0 then
      mcontroller.controlMove(-1, true)
    end
  else
    if stateData.timer > 4.0 then
      local inverseTimer = 6.0 - stateData.timer
      local angle = stateData.timer * 2.0 * math.pi
      local sinAngle = math.sin(angle)
      local radius = 0.5 + stateData.timer / 2.0

      local targetPosition = {
        stateData.basePosition[1] + sinAngle * radius,
        stateData.basePosition[2]
      }
      monster.flyTo(targetPosition)

      animator.rotateGroup("all", sinAngle * inverseTimer * math.pi / 180)
    else
      monster.setDamageOnTouch(true)
      mcontroller.controlMove(-1, true)
      animator.rotateGroup("all", -13 * math.pi / 180)
    end
  end

  if stateData.timer <= 0.0 then
    self.dead = true
  else
    local explosionAngle = math.random() * math.pi * 2.0
    local explosionOffset = { math.cos(explosionAngle) * 16.0, math.sin(explosionAngle) * 3.0 }
    local explosionPosition = vec2.rotate(explosionOffset, -animator.currentRotationAngle("all"))
    rangedAttack.aim(explosionPosition, {0, 1})
    rangedAttack.fireContinuous()
  end

  stateData.timer = stateData.timer - dt
  return false
end
