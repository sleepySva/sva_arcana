require "/scripts/vec2.lua"

function init()
  self.staticRotation = config.getParameter("rotation", 0) * math.pi / 180
  mcontroller.setVelocity(config.getParameter("velocity", {0,0}))
  mcontroller.setRotation(self.staticRotation)
end

function update(dt)
  mcontroller.setRotation(self.staticRotation)
end