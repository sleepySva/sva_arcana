function init()
  self.edges = getCollisionEdges()

  self.hoverHeight = 0
  self.initVelocityY = mcontroller.yVelocity()
  self.maxHoverHeight = config.getParameter("maxHoverHeight")
  self.hoverVelocityX = config.getParameter("hoverVelocityX")
  self.direction = -1
  if mcontroller.xVelocity() > 0 then self.direction = 1 end

  self.activeTimer = 0
  self.bobInterval = config.getParameter("bobInterval")
  self.bobAmount = config.getParameter("bobAmount")

  self.fallSpeedLimit = config.getParameter("fallSpeedLimit")

  --Add protection from mobs
  self.protectionBonus = config.getParameter("protectionBonus")
  effect.addStatModifierGroup({{stat = "protection", amount = self.protectionBonus}})

  activateVisualEffects()
end

--TODO: Add some sort of "ethereal" effect so the mob protection makes sense? Transparence?
function activateVisualEffects()
  local edges = getCollisionEdges()
  local boundBox = mcontroller.boundBox()

  --Particles at feet
  boundBox[2] = edges.bottom
  boundBox[4] = edges.bottom

  animator.setParticleEmitterOffsetRegion("feathers", boundBox)
  animator.burstParticleEmitter("feathers")

  animator.setParticleEmitterOffsetRegion("hover", boundBox)
  animator.setParticleEmitterActive("hover", true)
end

function setHoverHeight(time, dt)
  --Sin makes you bob
  local sinTime = math.sin(time / self.bobInterval * 6.28)
  self.hoverHeight = self.maxHoverHeight + sinTime * self.bobAmount
end

function getCollisionEdges()
  local collisionPoly = mcontroller.collisionPoly()

  local edges = {
    left = 0,
    top = 0,
    right = 0,
    bottom = 0
  }

  for _,point in ipairs(collisionPoly) do
    if point[1] < edges.left then edges.left = point[1] end
    if point[2] > edges.top then edges.top = point[2] end
    if point[1] > edges.right then edges.right = point[1] end
    if point[2] < edges.bottom then edges.bottom = point[2] end
  end

  return edges
end

function update(dt)
  self.activeTimer = self.activeTimer + dt
  setHoverHeight(self.activeTimer, dt)

  --Hover
  mcontroller.controlParameters({
    gravityMultiplier = 0
  })
  mcontroller.setXVelocity(self.hoverVelocityX * self.direction)

  --Limit fall speed
  local velocity = mcontroller.velocity()
  if velocity[2] < self.fallSpeedLimit then
    mcontroller.setYVelocity(self.fallSpeedLimit)
  end
  
  if math.abs(mcontroller.yVelocity() - self.initVelocityY) > 5 then effect.expire() end
end

function getClosestBlockYDistance(lineStart, lineEnd, ignorePlatforms)
  local yDistance = false

  local collisionSet = {"Null", "Block", "Dynamic", "Platform"}
  if ignorePlatforms then
    collisionSet = {"Null", "Block", "Dynamic", "Slippery"}
  end
  local blocks = world.collisionBlocksAlongLine(lineStart, lineEnd, collisionSet)
  if #blocks > 0 then
    yDistance = lineStart[2] - (blocks[1][2] + 1)
  end

  -- sb.logInfo("Block: %s Distance: %s", blocks[1], yDistance)

  return yDistance
end

function findGroundDistance()
  local position = mcontroller.position()
  --These are so rays don't start inside blocks
  local sideEdgeOffset = 0.1
  local bottomStartOffset = 0.5
  local centerBottomStartOffset = 0.1

  --Left ray
  local lineStart = {
    position[1] + self.edges.left + sideEdgeOffset,
    position[2] + self.edges.bottom + bottomStartOffset
  }
  local lineEnd = {
    lineStart[1],
    lineStart[2] - self.hoverHeight * 2 - bottomStartOffset
  }

  local leftGroundDistance = getClosestBlockYDistance(lineStart, lineEnd, false) or 9999 --Really big number
  leftGroundDistance = leftGroundDistance - bottomStartOffset

  --Right ray
  lineStart = {
    position[1] + self.edges.right - sideEdgeOffset,
    position[2] + self.edges.bottom + bottomStartOffset
  }
  local lineEnd = {
    lineStart[1],
    lineStart[2] - self.hoverHeight * 2 - bottomStartOffset
  }

  local rightGroundDistance = getClosestBlockYDistance(lineStart, lineEnd, false) or 9999 --Really big number
  rightGroundDistance = rightGroundDistance - bottomStartOffset

  --Center ray
  lineStart = {
    position[1],
    position[2] + self.edges.bottom + centerBottomStartOffset
  }
  lineEnd = {
    lineStart[1],
    lineStart[2] - self.hoverHeight * 2 - centerBottomStartOffset
  }

  local centerGroundDistance = getClosestBlockYDistance(lineStart, lineEnd, false) or 9999 --Really big number
  centerGroundDistance = centerGroundDistance - centerBottomStartOffset

  --Get the closest one
  local groundDistance = math.min(leftGroundDistance, rightGroundDistance)
  groundDistance = math.min(groundDistance, centerGroundDistance)

  return groundDistance
end
