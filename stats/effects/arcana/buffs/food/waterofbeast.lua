function init()
  self.statName = "arcana_waterofbeaststack"
  status.setStatusProperty(self.statName, 0)
  self.group = effect.addStatModifierGroup(getEffects())
  self.lastStack = 0
  self.limit = 4
  script.setUpdateDelta(30)
  
  animator.setParticleEmitterOffsetRegion("embers", mcontroller.boundBox())
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterOffsetRegion("limit", mcontroller.boundBox())
  animator.setParticleEmitterActive("embers", true)
end

function update(dt)
  effect.setStatModifierGroup(self.group, getEffects())
end

function uninit()
   status.setStatusProperty(self.statName, 0)
end

function getEffects()
  local stacks = status.statusProperty(self.statName, 0)
  effect.setParentDirectives("fade=BF3300="..tostring(0.05*stacks))
  if stacks ~= self.lastStack then
    self.lastStack = stacks
	animator.burstParticleEmitter("flames")
  end
  if stacks == self.limit then
    animator.setParticleEmitterActive("limit", true)
  end
  local effects = {{ stat = "powerMultiplier", effectiveMultiplier = 1+(stacks*0.2) },{ stat = "maxHealth", effectiveMultiplier = 1-(stacks*0.2) }}
  return effects
end