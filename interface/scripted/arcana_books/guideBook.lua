require "/scripts/util.lua"

function init()
  local configPath = "/objects/workshop/workshop_auto_essenceextractor/config.config"
  local bossPath = "/interface/scripted/arcana_books/bosses.config"
  self.recipes = root.assetJson(configPath).recipes
  self.bosses = root.assetJson(bossPath).bosses
  self.list = "liquidPane.liquidArea.liquidList"
  self.bossList = "bossPane.bossArea.bossList"
  self.bossSelected = nil
  self.bossCollection = "arcana_bosses"
  self.tabs = "radioMain"
  populateList()
  populateBossList()
  tabSwitch("0")
end

function update(dt)

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
      return tostring(o) or "NIL"
   end
end

function tabSwitch(id)
  widget.setVisible("liquidPane", false)
  widget.setVisible("tutorialPane", false)
  widget.setVisible("bossPane", false)
  if id == "0" then
    widget.setVisible("tutorialPane", true)
  elseif id == "1" then
    widget.setVisible("liquidPane", true)
  else
    widget.setVisible("bossPane", true)
  end
end

function bossSelect()
  local selected = widget.getListSelected(self.bossList)
  self.bossSelected = widget.getData(string.format("%s.%s", self.bossList, selected))
  
  local playerCollectables = {}
  for _,collectable in pairs(player.collectables(self.bossCollection)) do
    playerCollectables[collectable] = true
  end
  
  local unlocked = true
  if not playerCollectables[self.bossSelected.filename] then unlocked = false end
  
  local pane = "bossPane"
  local path = "/interface/scripted/arcana_books/bosses/"
  if unlocked == false then
    path = path .. self.bossSelected.filename .. ".png" .. "?brightness=-100"
	widget.setText(string.format("%s.name", pane), "???")
  else 
    path = path .. self.bossSelected.filename .. ".png" .. "?border=1;FFFFFF;FFFFFF"
	widget.setText(string.format("%s.name", pane), self.bossSelected.name)
  end
  widget.setImage(string.format("%s.icon", pane), path)
  widget.setText(string.format("%s.description", pane), self.bossSelected.description)
end

function populateBossList()
  widget.clearListItems(self.bossList)
  
  local playerCollectables = {}
  for _,collectable in pairs(player.collectables(self.bossCollection)) do
    playerCollectables[collectable] = true
  end

  for _, boss in pairs(self.bosses) do
    local item = widget.addListItem(self.bossList)
    local path = "/interface/scripted/arcana_books/bosses/"
	path = path .. boss.filename .. ".png"
	if not playerCollectables[boss.filename] then 
      widget.setText(string.format("%s.%s.name", self.bossList, item), "???")
	  widget.setFontColor(string.format("%s.%s.name", self.bossList, item), "gray")
	else
	  widget.setText(string.format("%s.%s.name", self.bossList, item), boss.name)
	  widget.setFontColor(string.format("%s.%s.name", self.bossList, item), "white")
	end
	widget.setData(string.format("%s.%s", self.bossList, item), boss)
  end
end

function populateList()
  widget.clearListItems(self.list)

  for _, recipe in pairs(self.recipes) do
    local item = widget.addListItem(self.list)
    local liquid = recipe.input
	local liquidImage = util.absolutePath(root.itemConfig(liquid).directory, root.itemConfig(liquid).config.inventoryIcon)
	widget.setImage(string.format("%s.%s.icon", self.list, item), liquidImage)
    widget.setText(string.format("%s.%s.name", self.list, item), root.itemConfig(liquid).config.shortdescription)
	widget.setText(string.format("%s.%s.description", self.list, item), root.itemConfig(liquid).config.description)
	
	for _, output in ipairs(recipe.output) do
	  local outputItem = widget.addListItem(string.format("%s.%s.outputList", self.list, item))
	  liquid = output.item
      liquidImage = util.absolutePath(root.itemConfig(liquid).directory, root.itemConfig(liquid).config.inventoryIcon)
	  widget.setImage(string.format("%s.%s.outputList.%s.icon", self.list, item, outputItem), liquidImage)
	end
  end
end