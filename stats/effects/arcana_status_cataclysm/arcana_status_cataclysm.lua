function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", false)
  effect.setParentDirectives("fade=a930f2=0.25")
  
  script.setUpdateDelta(5)

  self.tickDamagePercentage = 0.05
  self.tickTime = 3.0
  self.tickTimer = self.tickTime
  
  world.sendEntityMessage(entity.id(), "queueRadioMessage", "arcana_status_cataclysm", 5.0)
end

function update(dt)
  if effect.duration() and world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}) then
    effect.expire()
  end

  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
	self.tickDamagePercentage = self.tickDamagePercentage + 0.1
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1,
        damageSourceKind = "arcana_abyss_cataclysm",
        sourceEntityId = entity.id()
      })
  end
end

function uninit()
  
end
