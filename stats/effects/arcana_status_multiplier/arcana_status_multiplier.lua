function init()
   effect.addStatModifierGroup({{stat = config.getParameter("stat", "powerMultiplier"), effectiveMultiplier = config.getParameter("modifier", 0.20)}})

   script.setUpdateDelta(0)
end

function update(dt)

end

function uninit()
  
end
