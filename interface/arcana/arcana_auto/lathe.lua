require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rect.lua"

function init()
  self.craftingTime = 2.0
  self.cooldownTimer = self.craftingTime
end

function update(dt)
  if self.cooldownTimer > 0 then
    if widget.itemSlotItem("itemGrid") then
      widget.setProgress("itemGrid", self.cooldownTimer / self.craftingTime)
	else
	  widget.setProgress("itemGrid", 0)
	  self.cooldownTimer = self.craftingTime
	end
    self.cooldownTimer = math.max(0, self.cooldownTimer - dt)
    if self.cooldownTimer == 0 then
	  self.cooldownTimer = self.craftingTime
    end
  end
end

function buttonCallback()

end

