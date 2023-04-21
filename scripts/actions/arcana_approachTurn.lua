require "/scripts/poly.lua"

-- param entity
-- param turnSpeed
-- output angle
-- output direction
function arcana_approachTurn(args, output, _, dt)
  local targetPosition = world.entityPosition(args.entity)
  local distance = world.magnitude(targetPosition, mcontroller.position())
  while true do
    local toTarget = world.distance(targetPosition, mcontroller.position())
    local angle = mcontroller.rotation()

    local targetAngle = vec2.angle(toTarget)
    local diff = util.angleDiff(angle, targetAngle)
    if diff ~= 0 then
      angle = angle + (util.toDirection(diff) * args.turnSpeed) * dt
      if util.angleDiff(angle, targetAngle) * diff < 0 then
        angle = targetAngle
      end
    end

    local collisionRect = rect.translate(mcontroller.boundBox(), vec2.add(mcontroller.position(), vec2.withAngle(angle, 0.25)))
    if world.rectTileCollision(collisionRect) then
      mcontroller.setVelocity(vec2.mul(mcontroller.velocity(), -0.5))
    end

    mcontroller.setRotation(angle)
    local speedRatio = math.max(0.2, vec2.dot(vec2.norm(toTarget), vec2.withAngle(angle)) ^ 3)
    local speed = speedRatio * mcontroller.baseParameters().flySpeed
    mcontroller.controlApproachVelocity(vec2.withAngle(angle, speed), mcontroller.baseParameters().airForce, true)
    mcontroller.controlApproachVelocityAlongAngle(angle + math.pi * 0.4, 0, 30, false)

    coroutine.yield(nil, {angle = angle, direction = diff})

    targetPosition = world.entityPosition(args.entity)
    distance = world.magnitude(targetPosition, mcontroller.position())
  end
end