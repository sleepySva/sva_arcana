require "/scripts/keybinds.lua"

function init()
  self.cooldownTimer = 0
  self.rechargeEffectTimer = 0

  self.cooldown = config.getParameter("cooldown")
  self.effectDuration = config.getParameter("effectDuration")

  self.rechargeDirectives = config.getParameter("rechargeDirectives", "?fade=B7862CFF=0.25")
  self.rechargeEffectTime = config.getParameter("rechargeEffectTime", 0.1)

  Bind.create("f", energize)
end

function energize()
  if self.cooldownTimer == 0 and not status.statPositive("activeMovementAbilities") then
      self.cooldownTimer = self.cooldown
      status.addEphemeralEffect("arcana_status_energized", self.effectDuration)
	  status.addEphemeralEffect("arcana_status_attackPercent_10_voltaicSurge", self.effectDuration)
  end
end

function uninit()
  tech.setParentDirectives()
  status.removeEphemeralEffect("arcana_status_energized")
  status.removeEphemeralEffect("arcana_status_attackPercent_10_voltaicSurge")
end

function update(args)
  self.shiftHeld = not args.moves["run"]

  if self.cooldownTimer > 0 then
    self.cooldownTimer = math.max(0, self.cooldownTimer - args.dt)
    if self.cooldownTimer == 0 then
      --self.rechargeEffectTimer = self.rechargeEffectTime
      --tech.setParentDirectives(self.rechargeDirectives)
      --animator.playSound("recharge")
    end
  end
end
