function init()
  --Health Scale
  self.healthModifier = config.getParameter("healthModifier", 0)
  effect.addStatModifierGroup({{stat = "maxHealth", effectiveMultiplier = self.healthModifier}})
end

function update(dt)
end

function uninit()
end
