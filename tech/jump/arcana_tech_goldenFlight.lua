require "/scripts/vec2.lua"

function init()
  self.chargeTime = config.getParameter("chargeTime")
  self.boostTime = config.getParameter("boostTime")
  self.boostSpeed = config.getParameter("boostSpeed")
  self.boostForce = config.getParameter("boostForce")

  idle()

  self.available = true
end

function uninit()
  idle()
end

function update(args)
  local jumpActivated = args.moves["jump"] and not self.lastJump
  self.lastJump = args.moves["jump"]

  self.stateTimer = math.max(0, self.stateTimer - args.dt)

  if mcontroller.groundMovement() or mcontroller.liquidMovement() then
    if self.state ~= "idle" then
      idle()
    end

    self.available = true
  end

  if self.state == "idle" then
    if jumpActivated and canRocketJump() then
      charge()
    end
  elseif self.state == "charge" then
    if self.stateTimer > 0 then
      mcontroller.controlApproachVelocity({0, 0}, self.boostForce)
    else
      local direction = {0, 0}
      if args.moves["right"] then direction[1] = direction[1] + 1 end
      if args.moves["left"] then direction[1] = direction[1] - 1 end
      if args.moves["up"] then direction[2] = direction[2] + 1 end
      if args.moves["down"] then direction[2] = direction[2] - 1 end

      if vec2.eq(direction, {0, 0}) then direction = {0, 1} end

      boost(direction)
    end
  elseif self.state == "boost" then
    if self.stateTimer > 0 then
	
      local direction = {0, 0}
      if args.moves["right"] then direction[1] = direction[1] + 1 end
      if args.moves["left"] then direction[1] = direction[1] - 1 end
      if args.moves["up"] then direction[2] = direction[2] + 1 end
      if args.moves["down"] then direction[2] = direction[2] - 1 end

      if vec2.eq(direction, {0, 0}) then direction = {0, 1} end
	  self.boostVelocity = vec2.mul(vec2.norm(direction), self.boostSpeed)
	  
      mcontroller.controlApproachVelocity(self.boostVelocity, self.boostForce)
    else
      idle()
    end
  end

  animator.setFlipped(mcontroller.facingDirection() < 0)
end

function canRocketJump()
  return self.available
      and not mcontroller.jumping()
      and not mcontroller.canJump()
      and not mcontroller.liquidMovement()
      and not status.statPositive("activeMovementAbilities")
end

function charge()
  self.state = "charge"
  self.stateTimer = self.chargeTime
  self.available = false
  status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  tech.setParentState("fly")
  animator.setParticleEmitterActive("rocketParticles", true)
  animator.playSound("charge")
  animator.playSound("chargeLoop", -1)
end

function boost(direction)
  self.state = "boost"
  self.stateTimer = self.boostTime
  self.boostVelocity = vec2.mul(vec2.norm(direction), self.boostSpeed)
  tech.setParentState()
  animator.stopAllSounds("charge")
  animator.stopAllSounds("chargeLoop")
  animator.playSound("boost")
end

function idle()
  self.state = "idle"
  self.stateTimer = 0
  status.clearPersistentEffects("movementAbility")
  tech.setParentState()
  animator.setParticleEmitterActive("rocketParticles", false)
  animator.stopAllSounds("charge")
  animator.stopAllSounds("chargeLoop")
end
