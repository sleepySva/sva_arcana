require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rect.lua"

function init()
  self.entity = pane.containerEntityId()
  self.progressWidget = "progress"
  self.statusWidget = "lblStatus"
end

function update(dt)
  if not self.promise then 
    self.promise = world.sendEntityMessage(self.entity, "getData")
  end
  if self.promise:succeeded() then
    if self.promise:finished() then
	  local data = self.promise:result()
	  if data then
        widget.setText(self.statusWidget, data.status)
	    widget.setProgress(self.progressWidget, data.progress)
	    self.promise = nil
	  end
    end
  end
end
