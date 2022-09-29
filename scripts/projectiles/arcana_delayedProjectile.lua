require "/scripts/vec2.lua"

function init()
  self.delayTime = config.getParameter("delayTime" or 1.0)
  self.delayAcceleration = config.getParameter("delayAcceleration" or 10.0)

  self.delayTimer = config.getParameter("delayTime" or 1.0)
  self.fire = false
  

  local curVel = mcontroller.velocity()
end

function update(dt)
  self.delayTimer = math.max(0, self.delayTimer - dt)
  if self.delayTimer == 0 and self.fire == false then
    local curVel = mcontroller.velocity()
    mcontroller.setVelocity(vec2.mul(mcontroller.velocity(), self.delayAcceleration))
    self.fire = true
  end
end