require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  self.homingDistance = config.getParameter("homingDistance", 20)
  self.homingDelay = config.getParameter("homingDelay", 0)
  self.homingTimer = self.homingDelay
  self.homingActive = false
  self.rotationRate = config.getParameter("rotationRate")
  self.trackingLimit = config.getParameter("trackingLimit")
  self.sourceEntity = projectile.sourceEntity()
  self.queryParameters = {
    withoutEntityId = self.sourceEntity,
    includedTypes = {"creature"},
    order = "nearest"
  }

  local ttlVariance = config.getParameter("timeToLiveVariance")
  if ttlVariance then
    projectile.setTimeToLive(projectile.timeToLive() + sb.nrand(ttlVariance))
  end
end

function update(dt)
  local pos = mcontroller.position()
  local candidates = world.entityQuery(pos, self.homingDistance, self.queryParameters)
  
  if self.homingTimer > 0 then
    self.homingTimer = math.max(0, self.homingTimer - dt)
    if self.homingTimer == 0 then
	  self.homingActive = true
    end
  end
  
  if #candidates == 0 or self.homingActive == false then return end

  local vel = mcontroller.velocity()
  local angle = vec2.angle(vel)

  for _, candidate in ipairs(candidates) do
    if world.entityCanDamage(self.sourceEntity, candidate) then
      local canPos = world.entityPosition(candidate)
      if not world.lineTileCollision(pos, canPos) then
        local toTarget = world.distance(canPos, pos)
        local toTargetAngle = util.angleDiff(angle, vec2.angle(toTarget))

        if math.abs(toTargetAngle) > self.trackingLimit then
          return
        end

        local rotateAngle = math.max(dt * -self.rotationRate, math.min(toTargetAngle, dt * self.rotationRate))

        vel = vec2.rotate(vel, rotateAngle)
        mcontroller.setVelocity(vel)

        break
      end
    end
  end

  mcontroller.setRotation(math.atan(vel[2], vel[1]))
end
