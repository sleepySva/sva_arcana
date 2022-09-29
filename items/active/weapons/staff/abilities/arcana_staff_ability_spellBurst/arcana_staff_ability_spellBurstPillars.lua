require "/items/active/weapons/staff/abilities/arcana_instantProjectile.lua"

function ControlProjectile:createProjectiles()

  local pCount = self.projectileCount or 1
  self:fireElementalPillar(pCount)
  
end

-- Helper functions
function ControlProjectile:fireElementalPillar(charge)
  local impactPosition = self:impactPosition()
  local dir = mcontroller.facingDirection()
  local k = 0
  for j = 0, (charge - 1) do

  if impactPosition then
    impactPosition = vec2.add(impactPosition, {(2*dir), 0})
    local projectileParameters = copy(self.projectileParameters)
    projectileParameters.powerMultiplier = activeItem.ownerPowerMultiplier()
    projectileParameters.power = self.baseDamageFactor * projectileParameters.baseDamage * config.getParameter("damageLevelMultiplier")
    projectileParameters.actionOnTimeout = {
      {
        action = "projectile",
        inheritDamageFactor = 1,
        type = self.projectileType,
        config = { }
      }
    }
    local projectileCount = math.floor((self.pillarMaxHeight + k))
	k = k + 1
    animator.playSound("impact")
    for i = 0, (projectileCount - 1) do
	  util.wait(0.01, function()

	  end)
      projectileParameters.timeToLive = i * 0.01
      projectileParameters.actionOnTimeout[1].config.timeToLive = self.pillarDuration - (2 * projectileParameters.timeToLive)
      local position = vec2.add(impactPosition, {0, i})
      if not world.pointTileCollision(position, {"Null", "Block", "Dynamic", "Slippery"}) then
        world.spawnProjectile("pillarspawner", position, activeItem.ownerEntityId(), {dir, 0}, false, projectileParameters)
      end
    end
  end
  end
end

function ControlProjectile:impactPosition()
  local dir = mcontroller.facingDirection()
  local startLine = vec2.add(mcontroller.position(), {dir * self.pillarBaseDistance, self.pillarVerticalTolerance[1]})
  local endLine = vec2.add(mcontroller.position(), {dir * self.pillarBaseDistance, self.pillarVerticalTolerance[2]})

  local blocks = world.collisionBlocksAlongLine(startLine, endLine, {"Null", "Block", "Dynamic", "Slippery"})
  if #blocks > 0 then
    return vec2.add(blocks[#blocks], {0.5, 1.5})
  end
end