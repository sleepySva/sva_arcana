function init()
  effect = config.getParameter("itemStatus")
  addEphemeralEffect = status.addEphemeralEffect
end

function update(dt)
  addEphemeralEffect(effect,0.1)
end