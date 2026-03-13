require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/scripts/activeitem/stances.lua"

function init()
  self.projectileType = config.getParameter("projectileType")
  self.projectileParameters = config.getParameter("projectileParameters")
  self.critRate = config.getParameter("critRate")
  self.critDamage = config.getParameter("critDamage")
  self.critStatusEffect = config.getParameter("critStatusEffect")
  self.critVisualStatus = config.getParameter("critVisualStatus")
  self.projectileParameters.power = self.projectileParameters.power * root.evalFunction("weaponDamageLevelMultiplier", config.getParameter("level", 1))
  initStances()

  self.cooldownTime = config.getParameter("cooldownTime", 0)
  self.cooldownTimer = self.cooldownTime

  checkProjectiles()
  if storage.projectileIds then
    setStance("throw")
  else
    setStance("idle")
  end
end

function update(dt, fireMode, shiftHeld)
  updateStance(dt)
  checkProjectiles()

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.stanceName == "idle" and fireMode == "primary" and self.cooldownTimer == 0 then
    self.cooldownTimer = self.cooldownTime
    setStance("windup")
  end

  if self.stanceName == "throw" then
    if not storage.projectileIds then
      setStance("catch")
    end
  end

  updateAim()
end

function uninit()

end

function fire()
  if world.lineTileCollision(mcontroller.position(), firePosition()) then
    setStance("idle")
    return
  end

  local params = copy(self.projectileParameters)
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.ownerAimPosition = activeItem.ownerAimPosition()
  if self.aimDirection < 0 then params.processing = "?flipx" end
  
  -- Crits
  local critDamageMultiplier = status.stat("arcana_critDamageMultiplier") or 0
	local critRateStat = status.stat("arcana_critRate") or 0

  local effects = jarray()
  for key, value in ipairs(params.statusEffects or jarray()) do
    effects[key] = value
  end

  local critRate = (self.critRate or 0) + critRateStat
  if critRate > 0 and math.random() <= critRate then
    params.powerMultiplier = params.powerMultiplier * ((self.critDamage or 1) + critDamageMultiplier)
    table.insert(effects, self.critVisualStatus or "arcana_crit")
	if self.critStatusEffect then
	  table.insert(effects, self.critStatusEffect)
	end
	params.statusEffects = effects
  end
  --
  
  local projectileId = world.spawnProjectile(
      self.projectileType,
      firePosition(),
      activeItem.ownerEntityId(),
      aimVector(),
      false,
      params
    )
  if projectileId then
    storage.projectileIds = {projectileId}
  end
  animator.playSound("throw")
end

function checkProjectiles()
  if storage.projectileIds then
    local newProjectileIds = {}
    for i, projectileId in ipairs(storage.projectileIds) do
      if world.entityExists(projectileId) then
        local updatedProjectileIds = world.callScriptedEntity(projectileId, "projectileIds")

        if updatedProjectileIds then
          for j, updatedProjectileId in ipairs(updatedProjectileIds) do
            table.insert(newProjectileIds, updatedProjectileId)
          end
        end
      end
    end
    storage.projectileIds = #newProjectileIds > 0 and newProjectileIds or nil
  end
end
