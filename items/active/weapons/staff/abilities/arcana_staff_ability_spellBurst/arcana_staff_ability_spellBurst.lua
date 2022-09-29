require "/items/active/weapons/staff/abilities/arcana_instantProjectile.lua"

function ControlProjectile:createProjectiles()

  local aimPosition = vec2.add(mcontroller.position(), {(self.projectileOffset[1] or 0) * mcontroller.facingDirection(), (self.projectileOffset[2] or 0)})
  local fireDirection = world.distance(aimPosition, self:focusPosition())[1] > 0 and 1 or -1
  local pOffset = {fireDirection * (self.projectileDistance or 0), 0}

  local pCount = self.projectileCount or 1

  local pParams = copy(self.projectileParameters)
  pParams.power = self.baseDamageFactor * pParams.baseDamage * config.getParameter("damageLevelMultiplier") / pCount
  pParams.powerMultiplier = activeItem.ownerPowerMultiplier()

  for i = 1, pCount do
    pParams.delayTime = self.projectileDelayFirst + (i - 1) * self.projectileDelayEach

    local projectileId = world.spawnProjectile(
        self.projectileType,
        vec2.add(aimPosition, pOffset),
        activeItem.ownerEntityId(),
        self:firePosition(),
        false,
        pParams
      )

    if projectileId then
      table.insert(storage.projectiles, projectileId)
      world.sendEntityMessage(projectileId, "updateProjectile", aimPosition)
    end

    pOffset = vec2.rotate(pOffset, (2 * math.pi) / pCount)
  end
end

function ControlProjectile:firePosition()
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(0, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end