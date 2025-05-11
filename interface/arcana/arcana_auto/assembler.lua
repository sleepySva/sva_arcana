require "/scripts/util.lua"

function init()
  local configPath = config.getParameter("configPath", "/objects/workshop/workshop_auto_assembler/config.config")
  self.config = root.assetJson(configPath)
  self.recipeBack = "/interface/arcana/arcana_auto/recipe_back.png"
  self.recipes = self.config.recipes
  self.rateLable = "lblRate"
  self.descrptionLable = "lblText"
  self.inputwidget = "scrollArea.inputList"
  self.leftwidget = "scrollArea.leftList"
  
  self.entity = pane.containerEntityId()
  self.progressWidget = "progress"
  
  populateFields()
  populateList()
end

function update(dt)
  if not self.promise then 
    self.promise = world.sendEntityMessage(self.entity, "getProgress")
  end
  if self.promise:succeeded() then
    if self.promise:finished() then
      local progress = self.promise:result()
      widget.setProgress(self.progressWidget, progress)
	  self.promise = nil
    end
  end
end


function tablelength(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

-- Autofill description and other texts based on config
function populateFields()
  widget.setText(self.rateLable, string.format("Rate: %s", tostring(self.config.craftingTime or 1)))
  widget.setText(self.descrptionLable, self.config.description or "Replace Me")
end

-- Add recipes to the scroll menu
function populateList()
  widget.clearListItems(self.inputwidget)
  local itemName = ""
  local pos = {0,0}
  local i = 1
  for _, v in pairs(self.recipes) do
    i = i + 1
	local newwidget = widget.addListItem(self.inputwidget)
	local newwidgetinput = string.format("%s.%s.input", self.inputwidget, newwidget)
	itemName = root.itemConfig(v.output).config.shortdescription
	widget.setText(string.format("%s.%s.text", self.inputwidget, newwidget), itemName)
	widget.setItemSlotItem(string.format("%s.%s.outitem", self.inputwidget, newwidget), v.output)
	
    for j=1, tablelength(v.input) do
	  local inputlist = widget.addListItem(newwidgetinput)
	  --itemName = root.itemConfig(v.input[j]).config.shortdescription
	  widget.setItemSlotItem(string.format("%s.%s.input.%s.initem", self.inputwidget, newwidget, inputlist), v.input[j])
	end
	
  end
end