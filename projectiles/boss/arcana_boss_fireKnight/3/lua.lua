require "/scripts/vec2.lua"

function init()
  self.acceleration = config.getParameter("acceleration") or {0,8}
  self.floatacceleration = config.getParameter("floatacceleration") or {0,-30}
  self.floattimermax = config.getParameter("floattimermax") or 2
  self.floattimer = self.floattimermax
end

function update(dt)
  self.floattimer = math.max(0, self.floattimer - dt)
  if self.floattimer == 0 then
    self.acceleration = self.floatacceleration
  end
  mcontroller.accelerate({self.acceleration[1], self.acceleration[2]})
  mcontroller.setRotation(math.atan(mcontroller.velocity()[2], mcontroller.velocity()[1]))
end