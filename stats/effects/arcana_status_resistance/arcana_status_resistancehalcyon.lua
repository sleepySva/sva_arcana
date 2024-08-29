function init()
   effect.addStatModifierGroup({{stat = config.getParameter("resistance", "fireResistance"), amount = config.getParameter("modifier", 0.10)}})
   effect.addStatModifierGroup({{stat = config.getParameter("resistance", "iceResistance"), amount = config.getParameter("modifier", 0.10)}})
   effect.addStatModifierGroup({{stat = config.getParameter("resistance", "electricResistance"), amount = config.getParameter("modifier", 0.10)}})
   effect.addStatModifierGroup({{stat = config.getParameter("resistance", "poisonResistance"), amount = config.getParameter("modifier", 0.10)}})

   script.setUpdateDelta(0)
end

function update(dt)

end

function uninit()
  
end
