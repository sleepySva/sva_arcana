function init()
  self.stats = config.getParameter("stats", nil)
  self.effects = config.getParameter("effects", nil)
  effect.addStatModifierGroup(config.getParameter("statModifiers", {}))
end

function onExpire()
  status.addEphemeralEffect(self.effects[math.random(#self.effects)])
end
