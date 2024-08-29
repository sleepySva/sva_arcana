require "/scripts/vec2.lua"

function init()
  self.acceleration = config.getParameter("acceleration") or {0,-60}
  self.accelerationFirst = config.getParameter("ay") or {0,6}
  self.accelerationTimer = config.getParameter("accelerationTimer") or 2.0
  self.accelerationStart = self.accelerationTimer
end

function update(dt)
  if self.accelerationTimer > 0 then
    self.accelerationTimer = math.max(0, self.accelerationTimer - dt)
  else
    mcontroller.accelerate({self.acceleration[1], self.acceleration[2]})
  end
  mcontroller.accelerate({self.accelerationFirst[1], self.accelerationFirst[2]})
end