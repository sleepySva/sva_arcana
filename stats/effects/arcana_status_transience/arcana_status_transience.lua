function init()
  self.minRange = config.getParameter("minRange") or 0.5

  self.damageProjectileType = config.getParameter("damageProjectileType") or "armorthornburst"
  self.damageMultiplier = config.getParameter("damageMultiplier") or 0.01

  self.cooldown = config.getParameter("cooldown") or 5

  self.removeInWater = config.getParameter("removeInWater")

  self.minTriggerDamage = config.getParameter("minTriggerDamage") or 0

  resetThorns()
  self.cooldownTimer = 0

  self.queryDamageSince = 0
end

function resetThorns()
  self.cooldownTimer = self.cooldown
  self.triggerThorns = false
  self.thornsTimer = 0
  self.spawnedThorns = 0
  self.thornDamage = 0
end

function update(dt)
  if self.cooldownTimer <= 0 then
    local damageNotifications, nextStep = status.damageTakenSince(self.queryDamageSince)
    self.queryDamageSince = nextStep
    for _, notification in ipairs(damageNotifications) do
      if notification.healthLost > self.minTriggerDamage and notification.sourceEntityId ~= notification.targetEntityId then
        self.triggerThorns = true
        self.cooldownTimer = self.cooldown
        break
      end
    end
  end

  if self.removeInWater then
    if effect.duration() and world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}) then
      effect.expire()
    end
  end

  if self.cooldownTimer > 0 then
    self.cooldownTimer = self.cooldownTimer - dt
  end

  if self.triggerThorns then
    resetThorns()
    status.addEphemeralEffect("cultistshield", 4)
	status.addEphemeralEffect("arcana_status_transienceBoost", 4)
  end
end
