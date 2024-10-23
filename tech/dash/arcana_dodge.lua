require "/tech/doubletap.lua"

function init()
  self.airDashing = false
  self.dashDirection = 0
  self.dashTimer = 0
  self.dashCooldownTimer = 0
  self.immunityCooldownTimer = 0
  self.rechargeEffectTimer = 0
  self.immunityDash = false

  self.status = config.getParameter("status") or nil
  self.dashControlForce = config.getParameter("dashControlForce")
  self.dashSpeed = config.getParameter("dashSpeed")
  self.dashDuration = config.getParameter("dashDuration")
  self.immunityDashDuration = config.getParameter("immunityDashDuration")
  self.dashCooldown = config.getParameter("dashCooldown")
  self.immunityCooldown = config.getParameter("immunityCooldown")
  self.groundOnly = config.getParameter("groundOnly")
  self.stopAfterDash = config.getParameter("stopAfterDash")
  self.rechargeDirectives = config.getParameter("rechargeDirectives", "?fade=CCCCFFFF=0.25")
  self.rechargeEffectTime = config.getParameter("rechargeEffectTime", 0.1)

  self.doubleTap = DoubleTap:new({"left", "right"}, config.getParameter("maximumDoubleTapTime"), function(dashKey)
      if self.dashTimer == 0
          and self.dashCooldownTimer == 0
          and groundValid()
          and not mcontroller.crouching()
          and not status.statPositive("activeMovementAbilities") then

        startDash(dashKey == "left" and -1 or 1)
      end
    end)

  animator.setAnimationState("dashing", "off")
end

function uninit()
  status.clearPersistentEffects("movementAbility")
  tech.setParentDirectives()
end

function update(args)
  if self.status ~= nil then status.addEphemeralEffect(self.status, 1) end
  if self.dashCooldownTimer > 0 then
    self.dashCooldownTimer = math.max(0, self.dashCooldownTimer - args.dt)
  end
  
  if self.immunityCooldownTimer > 0 then
    self.immunityCooldownTimer = math.max(0, self.immunityCooldownTimer - args.dt)
    if self.immunityCooldownTimer == 0 then
      self.rechargeEffectTimer = self.rechargeEffectTime
      tech.setParentDirectives(self.rechargeDirectives)
      animator.playSound("recharge")
    end
  end

  if self.rechargeEffectTimer > 0 then
    self.rechargeEffectTimer = math.max(0, self.rechargeEffectTimer - args.dt)
    if self.rechargeEffectTimer == 0 then
      tech.setParentDirectives()
    end
  end

  self.doubleTap:update(args.dt, args.moves)

  if self.dashTimer > 0 then
    mcontroller.controlApproachVelocity({self.dashSpeed * self.dashDirection, 0}, self.dashControlForce)
    mcontroller.controlMove(self.dashDirection, true)

    if self.airDashing then
      mcontroller.setYVelocity(0)
    end
    mcontroller.controlModifiers({jumpingSuppressed = true})

    animator.setFlipped(mcontroller.facingDirection() == -1)

    self.dashTimer = math.max(0, self.dashTimer - args.dt)

    if self.dashTimer == 0 then
      endDash()
    end
  end
end

function groundValid()
  return mcontroller.groundMovement() or not self.groundOnly
end

function startDash(direction)
  self.dashDirection = direction
  self.dashTimer = self.dashDuration
  self.airDashing = not mcontroller.groundMovement()
  status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  if self.immunityCooldownTimer == 0 then
    self.dashTimer = self.immunityDashDuration
    self.immunityDash = true
    self.immunityCooldownTimer = self.immunityCooldown
    status.addEphemeralEffect("arcana_invulnerability")
	animator.setParticleEmitterActive("immunityParticles", true)
	animator.playSound("immunityDash")
  else
    self.immunityDash = false
	animator.setParticleEmitterActive("dashParticles", true)
	animator.playSound("startDash")
  end
  animator.setAnimationState("dashing", "on")
end

function endDash()
  status.clearPersistentEffects("movementAbility")
  if self.immunityDash == true then
    status.removeEphemeralEffect("arcana_invulnerability")
  end

  if self.stopAfterDash then
    local movementParams = mcontroller.baseParameters()
    local currentVelocity = mcontroller.velocity()
    if math.abs(currentVelocity[1]) > movementParams.runSpeed then
      mcontroller.setVelocity({movementParams.runSpeed * self.dashDirection, 0})
    end
    mcontroller.controlApproachXVelocity(self.dashDirection * movementParams.runSpeed, self.dashControlForce)
  end

  self.dashCooldownTimer = self.dashCooldown

  animator.setAnimationState("dashing", "off")
  animator.setParticleEmitterActive("dashParticles", false)
  animator.setParticleEmitterActive("immunityParticles", false)
end
