function init()
  effect.setParentDirectives("fade=FF1100=1.0")
  
  script.setUpdateDelta(5)

  self.tickDamagePercentage = 0.4
  self.tickTime = 0.0
  self.tickTimeLong = 999.0
  self.tickTimer = self.tickTime
end

function update(dt)
  if effect.duration() and world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}) then
    effect.expire()
  end

  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTimeLong
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1,
        damageSourceKind = "hidden",
        sourceEntityId = entity.id()
      })
  end
end

function uninit()
  
end
