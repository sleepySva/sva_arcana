require "/scripts/vec2.lua"

function init()
  if math.random(2) == 1 then
    self.acceleration = {0,10}
  else
    self.acceleration = {0,10}
  end
end

function update(dt)
  mcontroller.accelerate({self.acceleration[1], self.acceleration[2]})
  mcontroller.setRotation(math.atan(mcontroller.velocity()[2], mcontroller.velocity()[1]))
end