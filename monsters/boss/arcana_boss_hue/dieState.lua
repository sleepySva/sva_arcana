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

  local players = world.players()
end

function dieState.update(dt, stateData)
  mcontroller.controlFace(1)
  mcontroller.controlParameters({gravityEnabled = false})

  if mcontroller.onGround() then
    if stateData.timer > 1.6 then
      stateData.timer = 1.6
    end
  end

  if stateData.timer <= 0.0 then
	world.spawnMonster("arcana_boss_voidDeformity", mcontroller.position(), { level = 8 })
	world.spawnMonster("arcana_monster_envy", vec2.add(mcontroller.position(), {-18,10}), { level = 8 })
	world.spawnMonster("arcana_monster_isolation", vec2.add(mcontroller.position(), {18,10}), { level = 8 })
	world.spawnMonster("arcana_monster_fury", vec2.add(mcontroller.position(), {-18,-8}), { level = 8 })
	world.spawnMonster("arcana_monster_fear", vec2.add(mcontroller.position(), {18,-8}), { level = 8 })
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
