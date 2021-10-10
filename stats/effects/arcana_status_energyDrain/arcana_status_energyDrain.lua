function init()
  animator.setParticleEmitterOffsetRegion("emitter", mcontroller.boundBox())
  animator.setParticleEmitterActive("emitter", true)

  effect.setParentDirectives(config.getParameter("directives", ""))
  
  script.setUpdateDelta(config.getParameter("tickRate", 1))

  effect.addStatModifierGroup({{stat = "energyRegenPercentageRate", effectiveMultiplier = config.getParameter("energyRegenRate", 1)}})

  world.sendEntityMessage(entity.id(), "queueRadioMessage", "arcana_status_energyDrain", 5.0)
end

function update(dt)

end

function uninit()

end
