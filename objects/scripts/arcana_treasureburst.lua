require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
  if storage.triggered then
    animator.setAnimationState("burstState", "open")
  end
  object.setInteractive(not storage.triggered)
end

function update(dt)
  if self.burstTimer then
    self.burstTimer = self.burstTimer - dt
    if self.burstTimer <= 0 then
      self.burstTimer = nil
      tburst()
    end
  end
end

function onInteraction(args)
  if not storage.triggered then
    storage.triggered = true
    object.setInteractive(false)

    animator.setAnimationState("burstState", "burst")
	
	local burstDelay = config.getParameter("burstDelay", nil)
	if burstDelay then
	  self.burstTimer = burstDelay
	else
      tburst()
	end
  end
end

function die()
  if not storage.triggered then
    tburst()
  end
end

function tburst()
  animator.playSound("burst")
  animator.burstParticleEmitter("burst")

  local burstIntangibleTimeRange = config.getParameter("burstIntangibleTimeRange", {0, 0})
  local burstVelocityRange = config.getParameter("burstItemVelocityRange", {20, 40})
  local burstAngleVariance = config.getParameter("burstItemAngleVariance", 0.5)
  local burstOffset = config.getParameter("burstOffset", {0, 0})
  burstOffset[1] = burstOffset[1] * object.direction()
  local burstPosition = vec2.add(entity.position(), burstOffset)
  local burstTreasure = root.createTreasure(config.getParameter("burstTreasurePool"), world.threatLevel())
  for _, item in ipairs(burstTreasure) do
    local velocity = vec2.withAngle(sb.nrand(burstAngleVariance, math.pi / 2), util.randomInRange(burstVelocityRange))
    world.spawnItem(item, burstPosition, 1, nil, velocity, util.randomInRange(burstIntangibleTimeRange))
  end
end
