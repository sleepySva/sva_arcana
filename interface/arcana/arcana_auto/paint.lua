require "/scripts/util.lua"

function init()
  self.hexnum = 5
  self.tag = "factorypaint"
  self.colortypegroup = "groupPaintType"
  self.colorbuttonimage = "/interface/arcana/arcana_auto/coloricon.png"
  self.colorswidget = "scrollArea.colorsList"
  self.colorlabel = "lblColor"
  self.alertlabel = "lblAlert"
  self.itemimage = "itemImage"
  self.paintcolors = root.assetJson("/interface/arcana/arcana_auto/paintcolors.config").paintcolors
  widget.registerMemberCallback(self.colorswidget, "paintselect", paintselect)
  self.selectedcolor = 1
  self.selectedcolor2 = 2
  paintupdate("0")
  paintupdate("1")
  populateList()
end

function update(dt)
  local item = world.containerItemAt(pane.containerEntityId(),0)
  if item ~= nil then
    local itemConfig = root.itemConfig(item)
	if tableContains(itemConfig.config.colonyTags, self.tag) then
	  widget.setText(self.alertlabel, "^green;Ready to paint!^reset;")
	  widget.setVisible(self.itemimage, true)
      updateItemImage(item)
	else
	  widget.setText(self.alertlabel, "^red;This object cannot be painted.^reset;")
	  widget.setVisible(self.itemimage, false)
	  widget.setImage(self.itemimage,"")
	end
  else
    widget.setText(self.alertlabel, "^#534f4f;No factory object found.^reset;")
	widget.setVisible(self.itemimage, false)
  end
end

function updateItemImage(item)
  local itemConfig = root.itemConfig(item)
  local imagePath = util.absolutePath(itemConfig.directory, "body.png")
  
  local dstr = "?border=1;FFFFFF;FFFFFF?replace"
  local defaultslot = 1
  local slot = self.selectedcolor
  for i=1, self.hexnum do
    dstr = string.format("%s;%s=%s", dstr, self.paintcolors[defaultslot].directives[i], self.paintcolors[slot].directives[i])
  end
  defaultslot = 2
  slot = self.selectedcolor2
  for i=1, self.hexnum do
    dstr = string.format("%s;%s=%s", dstr, self.paintcolors[defaultslot].directives[i], self.paintcolors[slot].directives[i])
  end
  
  widget.setImage(self.itemimage,imagePath..dstr)
end

function tablelength(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

function tableContains(table, value)
  for _, v in pairs(table) do
    if v == value then
      return true
    end
  end
  return false
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

function paintempty(id)
end

function colorreset1()
  local btn = self.colortypegroup..".0"
  self.selectedcolor = 1
  paintupdate("0")
end

function colorreset2()
  local btn = self.colortypegroup..".1"
  self.selectedcolor2 = 2
  paintupdate("1")
end

function paintupdate(id)
  local btn = self.colortypegroup.."."..id
  local clr = 1
  if id == "0" then
    clr = self.selectedcolor
  else
    clr = self.selectedcolor2
  end
  widget.setText(btn, string.format("^#%s;%s^reset;", self.paintcolors[clr].directives[2], self.paintcolors[clr].name))
end

-- Updates currenctly selected color & related widgets
function paintselect()
  local btn = widget.getListSelected(self.colorswidget)
  btn = string.format("%s.%s.button", self.colorswidget, btn)
  local clr = widget.getData(btn)
  local type = widget.getSelectedOption(self.colortypegroup)
  if type == "0" or type == 0 then
    self.selectedcolor = clr
	paintupdate("0")
  else
    self.selectedcolor2 = clr
	paintupdate("1")
  end
  widget.setText(self.colorlabel, string.format("^#%s;%s^reset;", self.paintcolors[clr].directives[2], self.paintcolors[clr].name))
end

-- Paints the item in slot
function paintitem()
  local item = world.containerItemAt(pane.containerEntityId(),0)
  if item ~= nil then
    local itemConfig = root.itemConfig(item)
	if tableContains(itemConfig.config.colonyTags, self.tag) then
	  --sb.logInfo(itemConfig.config.inventoryIcon..getDirectives())
      world.containerTakeAt(pane.containerEntityId(),0)
      world.containerAddItems(pane.containerEntityId(), {name = item.name, count = item.count, parameters = setDirectives(itemConfig)})
	end
  end
end

-- Returns currenctly selected color directives
function setDirectives(itemConfig)
  local newparameters = {}
  newparameters = util.mergeTable(newparameters, {directives = getDirectives()})
  newparameters = util.mergeTable(newparameters, {inventoryIcon = itemConfig.config.inventoryIcon..getDirectives()})
  --sb.logInfo(dump(newparameters))
  return newparameters
end

function getDirectives()
  local dstr = "?replace"
  local defaultslot = 1
  local slot = self.selectedcolor
  for i=1, self.hexnum do
    dstr = string.format("%s;%s=%s", dstr, self.paintcolors[defaultslot].directives[i], self.paintcolors[slot].directives[i])
  end
  defaultslot = 2
  slot = self.selectedcolor2
  for i=1, self.hexnum do
    dstr = string.format("%s;%s=%s", dstr, self.paintcolors[defaultslot].directives[i], self.paintcolors[slot].directives[i])
  end
  return dstr
end


-- Create color buttons
function populateList()
  widget.clearListItems(self.colorswidget)
  local defaultslot = 2
  for i=1,tablelength(self.paintcolors) do
    local btnimg = self.colorbuttonimage
    local newwidget = widget.addListItem(self.colorswidget)
	local buttonwidget = string.format("%s.%s.button", self.colorswidget, newwidget)
	local dstr = "?replace"
	for j=1, self.hexnum do
      dstr = string.format("%s;%s=%s", dstr, self.paintcolors[defaultslot].directives[j], self.paintcolors[i].directives[j])
    end
	btnimg = btnimg..(dstr or "")
	widget.setData(buttonwidget,i)
    --widget.setText(buttonwidget, self.paintcolors[i].name)
	widget.setButtonImages(buttonwidget, 
	  {
	    base = btnimg, 
		hover = btnimg.."?brightness=20?saturation=-10;",
		pressed = btnimg.."?brightness=-20?saturation=-10;"
	  }
	)
  end
end