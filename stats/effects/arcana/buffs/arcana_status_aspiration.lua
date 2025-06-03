function init()
  self.perMissingHealth = config.getParameter("perMissingHealth", nil)
  self.powerMult = config.getParameter("powerMult", nil)
  self.lastHealthPercent = 0
  local bounds = mcontroller.boundBox()
  self.statusGroup = nil
end

function update(dt)
  if self.lastHealthPercent ~= status.resourcePercentage("health") then
    self.lastHealthPercent = status.resourcePercentage("health")
	refresh()
  end
end

function uninit()
end

function refresh()
  local missing = math.floor((1 - self.lastHealthPercent) / self.perMissingHealth)
  local modifiers = {{stat = "powerMultiplier", effectiveMultiplier = (1 + self.powerMult * missing)}}
  if self.statusGroup ~= nil then
    effect.setStatModifierGroup(self.statusGroup, modifiers)
  else
    self.statusGroup = effect.addStatModifierGroup(modifiers)
  end
end