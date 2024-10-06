function init()
  animator.burstParticleEmitter("name")
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=284fd5=0.25")
  animator.playSound("burn", -1)
  
  script.setUpdateDelta(5)

  self.tickDamage = config.getParameter("tickDamage", 10)
  self.tickTime = 0.5
  self.tickTimer = self.tickTime
end

function update(dt)

  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.tickDamage,
        damageSourceKind = "arcana_azure",
        sourceEntityId = entity.id()
      })
  end
end

function uninit()
  
end
