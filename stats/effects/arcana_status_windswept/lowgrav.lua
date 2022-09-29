function init()
  self.gravityModifier = config.getParameter("gravityModifier")
  self.movementParams = mcontroller.baseParameters()

  setGravityMultiplier()

  activateVisualEffects()
end

function setGravityMultiplier()
  local oldGravityMultiplier = self.movementParams.gravityMultiplier or 1

  self.newGravityMultiplier = self.gravityModifier * oldGravityMultiplier
end

function activateVisualEffects()
  animator.setParticleEmitterOffsetRegion("embers", mcontroller.boundBox())
  animator.setParticleEmitterActive("embers", true)
end

function update(dt)
  mcontroller.controlParameters({
     gravityMultiplier = self.newGravityMultiplier
  })
end

function uninit()

end
