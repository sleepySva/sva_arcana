local acinit = init or function() end
local acupdate = update or function() end

function init()
  acinit()
  self.relictable = root.assetJson("/scripts/arcana_relictable.config")
  self.relictname = "arcana_reliceffects"
  self.lastPrimary = nil
  self.lastAlt = nil
  self.tags = {}
end

function seekerleveleffect()
  local effect = "arcana_status_seekerlevel"
  local seekerlevel = player.currency("arcana_seekerlevel")
  status.removeEphemeralEffect(effect)
  if seekerlevel > 0 then status.addEphemeralEffect(effect,seekerlevel) end
end

function playerrelics()
  if player.getProperty("arcana_relics") == nil then player.setProperty("arcana_relics", {}) return end
  local relics = player.getProperty("arcana_relics")
  for _, relic in pairs(relics) do
    for k, v in pairs(relic.parameters.perks) do
      relic.parameters.perks[k].mapped = self.relictable[v.id]
	end
  end
  sortrelic(relics)
end

function update(dt)
  acupdate(dt)
  seekerleveleffect()
  playerrelics()
end

function sortrelic(relics)
  local effects = {}
  self.tags = getTags(self.tags)
  
  for _, relic in pairs(relics) do
    for _, v in pairs(relic.parameters.perks) do
      if v.mapped then
	    local value = v.value
		if v.mapped.statConversion and v.mapped.statConversion == "multiplier" then value = 1 + (value / 100)
		elseif v.mapped.statConversion == "res" then value = value / 100 end
	    if v.mapped.type == "direct" then
	      if v.mapped.statType == "amount" then 
	        table.insert(effects, {stat = v.mapped.stat, amount = value})
	      else
	        table.insert(effects, {stat = v.mapped.stat, effectiveMultiplier = value})
	      end
	    elseif v.mapped.type == "tag" and contains(self.tags, v.mapped.tag) then
	      if v.mapped.statType == "amount" then 
	        table.insert(effects, {stat = v.mapped.stat, amount = value})
	      else
	        table.insert(effects, {stat = v.mapped.stat, effectiveMultiplier = value})
	      end
	    end
	  end
    end
  end
  
  --sb.logInfo(dump(relics))
  --sb.logInfo("\n")
  --sb.logInfo(dump(effects))
  --sb.logInfo(relics.poke.poke)
 
  status.setPersistentEffects(self.relictname, effects)
  if #effects == 0 then status.clearPersistentEffects(self.relictname) end
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function getTags(tags)
  local primaryTags = {}
  local altTags = {}
  
  local primary = world.entityHandItem(entity.id(), "primary")
  local alt = world.entityHandItem(entity.id(), "alt")
  if primary == self.lastPrimary and alt == self.lastAlt then
    return tags
  else
    if primary == nil and alt == nil then return {} end
    self.lastPrimary = primary
    self.lastAlt = alt
    if primary then primaryTags = root.itemTags(primary) end
    if alt then altTags = root.itemTags(alt) end
	for _, value in pairs(altTags) do
	  table.insert(primaryTags, value)
	end
	return primaryTags
  end
end