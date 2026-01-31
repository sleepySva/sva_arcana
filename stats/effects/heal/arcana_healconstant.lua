function init()
  animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
  animator.setParticleEmitterEmissionRate("healing", config.getParameter("emissionRate", 3))
  animator.setParticleEmitterActive("healing", false)

  script.setUpdateDelta(5)
  self.healImmediate = config.getParameter("healImmediate", 0)
  self.healDuration = config.getParameter("healDuration", 1)
  self.cooldownTimer = self.healDuration
  self.healingRate = config.getParameter("healAmount", 10)
  status.giveResource("health", self.healImmediate)
end

function update(dt)
  if self.cooldownTimer > 0 then
	self.cooldownTimer = self.cooldownTimer - dt
  else
    status.giveResource("health", self.healingRate)
    self.cooldownTimer = self.healDuration
  end
end

function uninit()
  
end
