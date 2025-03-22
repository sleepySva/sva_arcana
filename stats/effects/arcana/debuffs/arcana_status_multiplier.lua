function init()
  self.stats = config.getParameter("stats", nil)
  local bounds = mcontroller.boundBox()
  
  effect.addStatModifierGroup(config.getParameter("statModifiers", {}))

end

function update(dt)

end

function uninit()
  
end
