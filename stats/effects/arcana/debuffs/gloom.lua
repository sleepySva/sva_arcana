function init()
  animator.setParticleEmitterOffsetRegion("debuff", mcontroller.boundBox())
  animator.setParticleEmitterActive("debuff", true)
  
  self.stats = config.getParameter("statModifiers")
  self.effects = config.getParameter("effects", nil)
  
  for _, stat in pairs(status.activeUniqueStatusEffectSummary()) do
    for _, effect in pairs(self.effects) do
      if stat[1] == effect then
        self.stats = config.getParameter("statModifiersAlt")
	    break
      end
	end
  end
  
  effect.addStatModifierGroup(self.stats)
end