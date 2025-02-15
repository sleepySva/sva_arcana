require "/scripts/vec2.lua"

function init()
  self.approach = vec2.norm(mcontroller.velocity())

  self.triggered = false
  self.delayTimer = config.getParameter("delayTime")
  self.controlForce = config.getParameter("controlForce")
  self.triggerSpeed = config.getParameter("triggerSpeed")
  self.rotateSpeed = config.getParameter("rotateSpeed", 5)
end

function update(dt)
  if self.delayTimer then
    mcontroller.approachVelocity({0, 0}, self.controlForce)
    self.delayTimer = math.max(0, self.delayTimer - dt)
    if self.delayTimer == 0 then
      self.delayTimer = nil
      trigger()
    end
  end
  
  local currentRotation = mcontroller.rotation()
  mcontroller.setRotation(currentRotation + self.rotateSpeed * dt)
end

function trigger()
  self.triggered = true
  mcontroller.setVelocity(vec2.mul(vec2.norm(self.approach), self.triggerSpeed))
end