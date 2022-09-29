function init()
  self.visualProjectileType = config.getParameter("visualProjectileType")

  local stack = (status.statusProperty("arcana_status_shivery") or 0) + 1
  status.setStatusProperty("arcana_status_shivery", stack)
  if stack < 6 then
    status.applySelfDamageRequest({
      damageType = "IgnoresDef",
      damage = stack,
      damageSourceKind = "iceplasmabullet",
      sourceEntityId = entity.id()
    })
    effect.expire()
    return
  end
  
  local damageAmount = math.floor(status.resourceMax("health") * 0.2) + 1
  if damageAmount < 30 then damageAmount = 30 end
  if damageAmount > 400 then damageAmount = 400 end
  status.applySelfDamageRequest({
    damageType = "IgnoresDef",
    damage = damageAmount,
    damageSourceKind = "ice",
    sourceEntityId = entity.id()
  })
  spawnVisualThorns(6)
  
  status.setStatusProperty("arcana_status_shivery", 0)
  effect.expire()
end

function spawnVisualThorns(count)
  if count == nil then count = 1 end
  local pi = 3.14

  local randAngle = math.random() * 2 * pi --Random radian
  local angleInterval = math.pi * 2 / count
  for x = 0, count - 1 do
    local angle = randAngle + angleInterval * x
    local needleVector = {math.cos(angle), math.sin(angle)}

    local position = mcontroller.position()
    local visualConfig = {
      power = 2,
      timeToLive = 1,
      speed = 20,
      physics = "default"
    }
    world.spawnProjectile(self.visualProjectileType, position, entity.id(), needleVector, true, visualConfig)
  end
end