function init()
  self.speed = config.getParameter("speed", nil)
end

function update(dt)
  mcontroller.controlModifiers({speedModifier = self.speed})
end

function uninit()
  
end
