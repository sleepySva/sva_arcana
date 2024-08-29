require "/scripts/util.lua"

function init()
  self.lastPrimary = nil
  self.lastAlt = nil
  self.stats = config.getParameter("stats")
  self.weaponTags = config.getParameter("weaponTags")
  self.statModifiers = config.getParameter("statModifiers", {})
  self.effectGroup = nil
  updateTag(nil)

end

function updateTag(id)
  local primary = world.entityHandItem(entity.id(), "primary")
  local alt = world.entityHandItem(entity.id(), "alt")
  if primary == self.lastPrimary and alt == self.lastAlt then
    return
  end
  local primaryTags = {}
  local altTags = {}
  if primary then primaryTags = root.itemTags(primary) end
  if alt then altTags = root.itemTags(alt) end
  if primary == nil and alt == nil then return end
  local hasTag = false
  
  for _, value in pairs(altTags) do
	table.insert(primaryTags, value)
  end
  for _, tag in pairs(self.weaponTags) do
    if contains(primaryTags, tag) then hasTag = true break end
  end
  
  if id == nil and hasTag then 
    self.effectGroup = effect.addStatModifierGroup(self.statModifiers)
  elseif id ~= nil and not hasTag then
    effect.removeStatModifierGroup(id)
	self.effectGroup = nil
  end
  self.lastPrimary = primary
  self.lastAlt = alt
end

function update(dt)
  updateTag(self.effectGroup)
end
