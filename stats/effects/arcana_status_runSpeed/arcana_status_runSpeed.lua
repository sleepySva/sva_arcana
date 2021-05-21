function init()
  local bounds = mcontroller.boundBox()
end

function update(dt)
  mcontroller.controlModifiers({
      speedModifier = config.getParameter("modifier", 1.20)
    })
end

function uninit()
  
end
