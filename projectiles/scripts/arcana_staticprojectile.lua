require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  -- Delay
  self.triggered = false
  self.delayTimer = config.getParameter("delayTime")
  self.controlForce = config.getParameter("controlForce")
  self.triggerSpeed = config.getParameter("triggerSpeed")
  
  -- Static
  self.aimAtTarget = config.getParameter("aimAtTarget", true)
  self.offsets = config.getParameter("projectileOffsets", nil)
  self.offset = config.getParameter("projectileOffset", {-35, 25})
  if self.offsets then
    self.offset = self.offsets[math.random(1, tablelength(self.offsets))]
  end
  self.searchDistance = config.getParameter("searchDistance", 500)
  self.sourceEntity = projectile.sourceEntity()
  self.followEntity = nil
  self.queryParameters = {
    withoutEntityId = self.sourceEntity,
    includedTypes = {"creature"},
    order = "nearest"
  }
  search()
  setStaticPosition()
  if self.followEntity and self.aimAtTarget then
    rotate(mcontroller.position(), world.entityPosition(self.followEntity))
  end
  self.approach = vec2.norm(mcontroller.velocity())
end

function update(dt)
  -- Delay
  if self.delayTimer then
    mcontroller.approachVelocity({0, 0}, self.controlForce)
    self.delayTimer = math.max(0, self.delayTimer - dt)
    if self.delayTimer == 0 then
      self.delayTimer = nil
      trigger()
    end
  end
  
  -- Static
  setStaticPosition()
end

function trigger()
  self.triggered = true
  mcontroller.setVelocity(vec2.mul(vec2.norm(self.approach), self.triggerSpeed))
end

function search()
  local pos = mcontroller.position()
  local candidates = world.entityQuery(pos, self.searchDistance, self.queryParameters)
  if #candidates == 0 then return end

  for _, candidate in ipairs(candidates) do
    if world.entityCanDamage(self.sourceEntity, candidate) then
	  self.followEntity = candidate
      break
    end
  end
end

function rotate(pos, canPos)
  local vel = mcontroller.velocity()
  local angle = vec2.angle(vel)

  local toTarget = world.distance(canPos, pos)
  local toTargetAngle = util.angleDiff(angle, vec2.angle(toTarget))

  vel = vec2.rotate(vel, toTargetAngle)
  mcontroller.setVelocity(vel)
  mcontroller.setRotation(math.atan(vel[2], vel[1]))
end

function setStaticPosition()
  if self.followEntity and self.triggered == false then
    local target = world.entityPosition(self.followEntity)
    if target then
      mcontroller.setPosition(vec2.add(target, self.offset))
	end
  end
end

function tablelength(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end