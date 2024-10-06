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
  populateFields()
  populateList()
end

function update(dt)
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
  local str = ""
  local pos = {0,0}
  local i = 1
  for _, v in pairs(self.recipes) do
    i = i + 1
	local newwidget = widget.addListItem(self.inputwidget)
	local newwidgetinput = string.format("%s.%s.input", self.inputwidget, newwidget)
	local outputImage = util.absolutePath(root.itemConfig(v.output).directory, root.itemConfig(v.output).config.inventoryIcon)
	itemName = root.itemConfig(v.output).config.shortdescription
	str = string.format("^white;%s %s^reset;", v.output.count, itemName)
	widget.setText(string.format("%s.%s.text", self.inputwidget, newwidget), str)
	widget.setImage(string.format("%s.%s.item", self.inputwidget, newwidget), outputImage)
    for j=1, tablelength(v.input) do
	  local newwidgettext = widget.addListItem(newwidgetinput)
	  itemName = root.itemConfig(v.input[j]).config.shortdescription
	  local itemImage = util.absolutePath(root.itemConfig(v.input[j]).directory, root.itemConfig(v.input[j]).config.inventoryIcon)
	  local wtext = string.format("%s.%s.input.%s.text", self.inputwidget, newwidget, newwidgettext)
	  local witem = string.format("%s.%s.input.%s.item", self.inputwidget, newwidget, newwidgettext)
      str = string.format("^white;%s %s^reset;", v.input[j].count, itemName)
	  widget.setText(wtext, str)
	  widget.setImage(witem, itemImage)
	end
	
  end
end