function init()
  animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
  animator.setParticleEmitterEmissionRate("healing", config.getParameter("emissionRate", 3))
  animator.setParticleEmitterActive("healing", false)

  script.setUpdateDelta(5)
  self.cooldownTimer = config.getParameter("healDuration", 2)
  self.healingRate = config.getParameter("healAmount", 10) / self.cooldownTimer
end

function update(dt)
  if self.cooldownTimer > 0 then
    status.modifyResource("health", self.healingRate * dt)
	self.cooldownTimer = self.cooldownTimer - dt
  end
end

function uninit()
  
end
