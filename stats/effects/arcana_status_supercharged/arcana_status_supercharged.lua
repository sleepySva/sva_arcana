function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=9747ff=0.25")
  animator.playSound("burn", -1)
  
  script.setUpdateDelta(5)

  self.tickDamagePercentage = 0.08
  self.tickTime = 0.8
  self.tickTimer = self.tickTime
  
  world.sendEntityMessage(entity.id(), "queueRadioMessage", "arcana_status_supercharged", 5.0)
end

function update(dt)
  if effect.duration() and world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}) then
    effect.expire()
  end

  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
	self.tickDamagePercentage = self.tickDamagePercentage + 0.01
	status.addEphemeralEffect("electrified")
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1,
        damageSourceKind = "electric",
        sourceEntityId = entity.id()
      })
  end
end

function uninit()
  
end
