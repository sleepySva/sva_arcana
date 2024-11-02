require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rect.lua"

function init()
  self.entity = pane.containerEntityId()
  self.progressWidget = "progress"
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
