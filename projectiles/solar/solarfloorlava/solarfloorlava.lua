require "/scripts/vec2.lua"

function init()
  mcontroller.setRotation(0)

  self.spawn = mcontroller.position()
  self.goal = vec2.add(self.spawn, {0, 2})

  self.speed = 2
  self.sinkSpeed = 2

  message.setHandler("sink", function(_, _)
    self.sinking = true
  end)
end

function update(dt)
  -- Clear lava if source dies
  if not world.entityExists(projectile.sourceEntity()) then
    self.sinking = true
    self.sinkSpeed = 10
  end

  local height = mcontroller.localBoundBox()[4] - mcontroller.localBoundBox()[2]
  local sinkTime = self.sinkSpeed / height
  if projectile.timeToLive() <= sinkTime then
    self.sinking = true
  end

  local toGoal = world.distance(self.goal, mcontroller.position())
  local toSpawn = world.distance(self.spawn, mcontroller.position())

  if not self.sinking and world.magnitude(toGoal) > self.speed * dt then
    local velocity = vec2.mul(vec2.norm(toGoal), self.speed)
    mcontroller.approachVelocity(velocity, 200)
  elseif self.sinking then
    if world.magnitude(toSpawn) > self.sinkSpeed * dt then
      local velocity = vec2.mul(vec2.norm(toSpawn), self.sinkSpeed)
      mcontroller.approachVelocity(velocity, 200)
    else
      projectile.die()
    end
  else
    mcontroller.setPosition(self.goal)
    mcontroller.setVelocity({0,0})
  end
end
