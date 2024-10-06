require "/scripts/vec2.lua"

function init()
  self.rotationRate = 3.0
  self.rotation = mcontroller.rotation()
end

function update(dt)
  self.rotation = self.rotation + self.rotationRate
  mcontroller.setRotation(self.rotation)
end