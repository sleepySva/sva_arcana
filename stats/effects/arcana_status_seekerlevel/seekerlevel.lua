function init()
  self.max = 8
  self.stats = root.assetJson("/scripts/arcana_levelstats.config")
  self.list = "scrollArea.collectionList"
  applystats()
end

function update(dt)

end

function uninit()
  
end

function applystats()
  local playerlevel = effect.duration() + 0.5
  
  local total = { maxHealth = 0, powerMultiplier = 0, maxEnergy = 0 }
  for i=1,self.max do
	for k, v in pairs(self.stats[""..i]) do 
	  if playerlevel >= i and playerlevel <= self.max + 1 then total[v.stat] = total[v.stat] + v.amount end
	end
  end
  
  for k, v in pairs(total) do 
	effect.addStatModifierGroup({{stat = k, amount = v}})
  end
end