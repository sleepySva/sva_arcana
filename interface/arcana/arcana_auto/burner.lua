require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rect.lua"

function init()
  self.entity = pane.containerEntityId()
  self.progressWidget = "progress"
  self.stateWidget = "stateToggle"
  self.init = false
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
  
  if self.init == false then
    stateToggle()
  end
end

function stateToggle()
  local checked = widget.getChecked(self.stateWidget)
  if not self.state or self.init == true then 
    if checked ~= nil and self.init == true then 
      self.state = world.sendEntityMessage(self.entity, "getState", checked)
	else
	  self.state = world.sendEntityMessage(self.entity, "getState")
	end
  end
  if self.init == false and self.state:succeeded() then
    if self.state:finished() then
      local result = self.state:result()
      widget.setChecked(self.stateWidget, result)
	  self.state = nil
	  self.init = true
    end
  end
end
