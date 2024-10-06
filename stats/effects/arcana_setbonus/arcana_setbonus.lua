require "/scripts/util.lua"

function init()
  self.lastPrimary = nil
  self.lastAlt = nil
  self.hasTag = false
  self.set = config.getParameter("set")
  self.minParts = config.getParameter("minParts", 3)
  self.statModifiers = config.getParameter("statModifiers", {})
  self.movementModifiers = config.getParameter("movementModifiers", {})
  self.weaponBuff = config.getParameter("weaponBuff")
  self.effectGroup = nil
  self.weaponGroup = nil
  updateBonus(nil)
end

function updateBonus(id)
  local hasSet = false
  if status.stat(self.set) >= self.minParts then hasSet = true end
  
  if hasSet then
    self.hasTag = hasTag()
    if self.weaponGroup == nil and self.hasTag == true then
      self.weaponGroup = effect.addStatModifierGroup(self.weaponBuff.modifiers)
    elseif self.weaponGroup ~= nil and self.hasTag == false then
      effect.removeStatModifierGroup(self.weaponGroup)
      self.weaponGroup = nil
    end
  end
  if id == nil and hasSet then 
    self.effectGroup = effect.addStatModifierGroup(self.statModifiers)
  elseif not hasSet then
   if id ~= nil then effect.removeStatModifierGroup(self.effectGroup) self.effectGroup = nil end
   if self.weaponGroup ~= nil then effect.removeStatModifierGroup(self.weaponGroup) self.weaponGroup = nil end
  end
end

function hasTag()
  local primary = world.entityHandItem(entity.id(), "primary")
  local alt = world.entityHandItem(entity.id(), "alt")
  if primary == self.lastPrimary and alt == self.lastAlt then return self.hasTag end
  local primaryTags = {}
  local altTags = {}
  if primary then primaryTags = root.itemTags(primary) end
  if alt then altTags = root.itemTags(alt) end
  if primary == nil and alt == nil then return end
  local hasTag = false
  
  for _, value in pairs(altTags) do
	table.insert(primaryTags, value)
  end
  for _, tag in pairs(self.weaponBuff.tags) do
    if contains(primaryTags, tag) then hasTag = true break end
  end
  
  self.lastPrimary = primary
  self.lastAlt = alt
  
  if hasTag then
    return true
  else 
    return false
  end
end

function update(dt)
  updateBonus(self.effectGroup)
end
