function init()
  local bounds = mcontroller.boundBox()
  self.statusGroup = nil
end

function update(dt)
  local condition = status.resourcePercentage("health") >= 0.99
  if self.statusGroup == nil and condition then
    self.statusGroup = effect.addStatModifierGroup(config.getParameter("statModifiers", {}))
  elseif self.statusGroup ~= nil and not condition then
    effect.removeStatModifierGroup(self.statusGroup)
	self.statusGroup = nil
  end
end

function uninit()
  
end
