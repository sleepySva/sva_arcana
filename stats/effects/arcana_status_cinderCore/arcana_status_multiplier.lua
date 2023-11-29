function init()
  self.stats = config.getParameter("stats", nil)
  local bounds = mcontroller.boundBox()
  
  for i, status in pairs (self.stats) do 
	effect.addStatModifierGroup({{stat = status.name, effectiveMultiplier = status.modifier}})
  end

end

function update(dt)
  mcontroller.controlModifiers({
    speedModifier = config.getParameter("speedModifier", 1.0)
  })
end

function uninit()
  
end
