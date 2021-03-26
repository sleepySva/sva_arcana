function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", false)
  animator.playSound("burn", -1)
  
  script.setUpdateDelta(5)

  self.tickDamagePercentage = 0.025
  self.tickTime = 999999999
  self.tickTimer = self.tickTime
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
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
