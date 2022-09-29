require "/scripts/interp.lua"
require "/scripts/vec2.lua"
require "/scripts/util.lua"

BeamMine = WeaponAbility:new()

function BeamMine:init()
  self.weapon:setStance(self.stances.idle)

  self.impactSoundTimer = 0

  self.weapon.onLeaveAbility = function()
    activeItem.setScriptedAnimationParameter("chains", {})
    animator.setParticleEmitterActive("beamCollision", false)
    animator.stopAllSounds("fireLoop")
    self.weapon:setStance(self.stances.idle)
  end
end

function BeamMine:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.impactSoundTimer = math.max(self.impactSoundTimer - self.dt, 0)

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.weapon.currentAbility
    and not self:blocked()
    and not status.resourceLocked("energy") then

    self:setState(self.fire)
  end
end

function BeamMine:blocked()
  local startLine = mcontroller.position()
  local endLine = self:firePosition()
  local inBlock = vec2.floor(endLine)
  for _,block in ipairs(world.collisionBlocksAlongLine(startLine, endLine)) do
    if not compare(block, inBlock) then
      return true
    end
  end
  return false
end

function BeamMine:fire()
  self.weapon:setStance(self.stances.fire)

  animator.playSound("fireStart")
  animator.playSound("fireLoop", -1)

  local wasColliding = false
  local damageTimer = 0
  while self.fireMode == (self.activatingFireMode or self.abilitySlot)
      and not self:blocked()
      and status.overConsumeResource("energy", (self.energyUsage or 0) * self.dt) do
    local beamStart = self:firePosition()
    local aimDir = self:aimVector(0)
    local beamLength = self.beamLength
    local beamEnd = vec2.add(beamStart, vec2.mul(vec2.norm(aimDir), beamLength))

    local collidePoint = world.lineCollision(beamStart, beamEnd)
    local tileCollisionPoint = world.lineTileCollisionPoint(beamStart, beamEnd)
    if collidePoint and tileCollisionPoint then
      beamEnd = collidePoint

      beamLength = world.magnitude(beamStart, beamEnd)

      animator.setParticleEmitterActive("beamCollision", true)
      animator.resetTransformationGroup("beamEnd")
      animator.translateTransformationGroup("beamEnd", {beamLength, 0})

      if self.impactSoundTimer == 0 then
        animator.setSoundPosition("beamImpact", {self.beamLength, 0})
        animator.playSound("beamImpact")
        self.impactSoundTimer = self.damageInterval
      end
      
      damageTimer = damageTimer - script.updateDt()
      while damageTimer <= 0 do
        damageTimer = damageTimer + self.damageInterval

        local collideX = tileCollisionPoint[1][1]
        local collideY = tileCollisionPoint[1][2]
        if tileCollisionPoint[2][1] > 0 then
          collideX = math.ceil(collideX)
        else
          collideX = math.floor(collideX)
        end
        if tileCollisionPoint[2][2] > 0 then
          collideY = math.ceil(collideY)
        else
          collideY = math.floor(collideY)
        end
        if tileCollisionPoint[2][1] < 0 then
          collideX = collideX - 1
        end
        if tileCollisionPoint[2][2] < 0 then
          collideY = collideY - 1
        end
        local collideTile = {collideX, collideY}
        if vec2.mag(tileCollisionPoint[2]) == 0 then
          collideTile = vec2.floor(self:firePosition())
        end
        world.debugPoint(tileCollisionPoint[1], "yellow")
        world.debugLine(tileCollisionPoint[1], vec2.add(tileCollisionPoint[1], tileCollisionPoint[2]), "yellow")
        world.debugPoint(collideTile, "red")
        
        world.damageTileArea(collideTile, self.tileRadius or 1, "foreground", self:firePosition(), "blockish", self.tileDamage, self.harvestLevel, activeItem.ownerEntityId())
		world.damageTileArea(collideTile, self.tileRadius or 1, "background", self:firePosition(), "blockish", (self.tileDamage - 10), self.harvestLevel, activeItem.ownerEntityId())
      end
    else
      animator.setParticleEmitterActive("beamCollision", false)
    end

    self:drawBeam(beamEnd, collidePoint)

    coroutine.yield()
  end

  self:reset()
  animator.playSound("fireEnd")
end

function BeamMine:drawBeam(endPos, didCollide)
  local newChain = copy(self.chain)
  newChain.startOffset = self.weapon.muzzleOffset
  newChain.endPosition = endPos

  if didCollide then
    newChain.endSegmentImage = nil
  end

  activeItem.setScriptedAnimationParameter("chains", {newChain})
end

function BeamMine:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function BeamMine:aimVector(inaccuracy)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(inaccuracy, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function BeamMine:uninit()
  self:reset()
end

function BeamMine:reset()
  self.weapon:setDamage()
  activeItem.setScriptedAnimationParameter("chains", {})
  animator.setParticleEmitterActive("beamCollision", false)
  animator.stopAllSounds("fireStart")
  animator.stopAllSounds("fireLoop")
end
