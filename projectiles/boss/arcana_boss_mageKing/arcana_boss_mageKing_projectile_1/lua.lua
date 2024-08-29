require "/scripts/vec2.lua"

function init()
  self.acceleration = config.getParameter("acceleration") or {0,60}
end

function update(dt)
  mcontroller.accelerate({self.acceleration[1], self.acceleration[2]})
  mcontroller.setRotation(math.atan(mcontroller.velocity()[2], mcontroller.velocity()[1]))
end