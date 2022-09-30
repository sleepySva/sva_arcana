function init()
   effect.addStatModifierGroup({
   {stat ="physicalResistance", amount = -0.10},
   {stat ="poisonResistance", amount = 0.10},
   {stat ="fireResistance", amount = 0.10},
   {stat ="iceResistance", amount = 0.10},
   {stat ="electricResistance", amount = 0.10}
   })

   script.setUpdateDelta(0)
end

function update(dt)

end

function uninit()
  
end
