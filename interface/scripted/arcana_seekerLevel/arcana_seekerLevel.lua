require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rect.lua"

function init()
  self.max = 8
  self.upgradeitem = "arcana_misc_elementalHeart"
  self.stats = root.assetJson("/scripts/arcana_levelstats.config")
  self.dict = root.assetJson("/scripts/arcana_namedict.config")
  self.list = "scrollArea.collectionList"
  self.stathealth = "lbl_stathealth"
  self.statenergy = "lbl_statenergy"
  self.statpower = "lbl_statpower"
  populateList()
end

function update(dt)
  displayHeart()
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

function resetLevel()
  local playerlevel = player.currency("arcana_seekerlevel")
  local refund = {}
  refund.name = self.upgradeitem
  refund.count = playerlevel
  if playerlevel > 0 then
    player.consumeCurrency("arcana_seekerlevel", playerlevel)
	player.giveItem(refund)
  end
  populateList()
end

function displayHeart()
  local playerlevel = player.currency("arcana_seekerlevel")
  local amount = player.hasCountOfItem(self.upgradeitem)
  if amount == 0 then widget.setText("lbl_heartamount","^#606060;".."0 / 1")
  else
    widget.setText("lbl_heartamount","^#5ae300;"..amount.." / 1")
  end
  if playerlevel == self.max then
    widget.setVisible("lbl_upgrade", true)
	widget.setVisible("lbl_heartamount", false)
	widget.setButtonEnabled("upgradeButton", false)
  else
    widget.setVisible("lbl_upgrade", false)
	widget.setVisible("lbl_heartamount", true)
	if amount ~= 0 then
	  widget.setButtonEnabled("upgradeButton", true)
	else
	  widget.setButtonEnabled("upgradeButton", false)
	end
  end
end

function displayStats()
  local playerlevel = player.currency("arcana_seekerlevel")
  sb.logInfo(dump(self.stats))
  sb.logInfo("-----")
  for i=1,self.max do 
    sb.logInfo("---")
    sb.logInfo("i: "..i)
	for k, v in pairs(self.stats[""..i]) do 
	  sb.logInfo("stat: "..self.dict[v.stat].." amount: +"..v.amount)
	end
  end
  sb.logInfo("-----")
end

function populateList()
  local playerlevel = player.currency("arcana_seekerlevel")
  widget.clearListItems(self.list)
  
  local total = { maxHealth = 0, powerMultiplier = 0, maxEnergy = 0 }
  for i=1,self.max do
    local item = widget.addListItem(self.list)
    local color = ""
    widget.setText(string.format("%s.%s.index", self.list, item), "Lv "..i)
	if playerlevel >= i then
	  widget.setVisible(string.format("%s.%s.border", self.list, item), true)
	  color = "^#ffffff;"
	else
	  widget.setVisible(string.format("%s.%s.border", self.list, item), false)
	  color = "^#262626;"
	end
	local length = 0
	local s = color
	for k, v in pairs(self.stats[""..i]) do 
	  length = length + 1 
	  if length > 1 then s = s..", " end
	  s = s.."+"..v.amount.." "..self.dict[v.stat]
	  if playerlevel >= i then total[v.stat] = total[v.stat] + v.amount end
	end
	widget.setText(string.format("%s.%s.description", self.list, item), s)
	s = "^reset;"
  end
  
  widget.setText(self.stathealth, "^#5ae300;+"..total.maxHealth)
  widget.setText(self.statenergy, "^#5ae300;+"..total.maxEnergy)
  widget.setText(self.statpower, "^#5ae300;+"..total.powerMultiplier)
  s = "^reset;"
end

function upgrade()
  if player.hasCountOfItem(self.upgradeitem) >= 1 then
    player.consumeItem({name = self.upgradeitem, count = 1})
	player.addCurrency("arcana_seekerlevel", 1)
	populateList()
	widget.playSound("/sfx/objects/terraformer_deactivate.ogg")
  end
end