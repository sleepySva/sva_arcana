function init()
  self.damageFlashTime = 0
  self.hitInvulnerabilityTime = 0

  message.setHandler("applyStatusEffect", function(_, _, effectConfig, duration, sourceEntityId)
    status.addEphemeralEffect(effectConfig, duration, sourceEntityId)
  end)
  
  if root.hasTech("stardustlib:enable-extenders") then
    require "/sys/stardust/statusext.lua"
  end
end

function applyDamageRequest(damageRequest)
  if self.hitInvulnerabilityTime > 0 or world.getProperty("nonCombat") then
    return {}
  end

  -- don't get hit by knockback attacks if immune to knockback
  if damageRequest.damageType == "Knockback" and status.stat("grit") >= 1 then
    return {}
  end

  local damage = 0
  if damageRequest.damageType == "Damage" or damageRequest.damageType == "Knockback" then
    damage = damage + root.evalFunction2("protection", damageRequest.damage, status.stat("protection"))
  elseif damageRequest.damageType == "IgnoresDef" then
    damage = damage + damageRequest.damage
  elseif damageRequest.damageType == "Status" then
    -- only apply status effects
    status.addEphemeralEffects(damageRequest.statusEffects, damageRequest.sourceEntityId)
    return {}
  elseif damageRequest.damageType == "Environment" then
    return {}
  end

  if damageRequest.hitType == "ShieldHit" and status.statPositive("shieldHealth") and status.resourcePositive("shieldStamina") then
    status.modifyResource("shieldStamina", -damage / status.stat("shieldHealth"))
    status.setResourcePercentage("shieldStaminaRegenBlock", 1.0)
    damage = 0
    damageRequest.statusEffects = {}
    damageRequest.damageSourceKind = "shield"
  end

  local hitType = damageRequest.hitType
  local elementalStat = root.elementalResistance(damageRequest.damageSourceKind)
  local resistance = status.stat(elementalStat)
  damage = damage - (resistance * damage)
  if resistance ~= 0 and damage > 0 then
    hitType = resistance > 0 and "weakhit" or "stronghit"
  end
  
  local healthLost = math.min(damage, status.resource("health"))
  if healthLost > 0 and damageRequest.damageType ~= "Knockback" then
    status.modifyResource("health", -healthLost)
    self.damageFlashTime = 0.07
    if hitType == "stronghit" then
      self.damageFlashType = "strong"
    elseif hitType == "weakhit" then
      self.damageFlashType = "weak"
    else
      self.damageFlashType = "default"
    end
    if status.statusProperty("hitInvulnerability") then
      local damageHealthPercentage = healthLost / status.resourceMax("health")
      if damageHealthPercentage > status.statusProperty("hitInvulnerabilityThreshold") then
        self.hitInvulnerabilityTime = status.statusProperty("hitInvulnerabilityTime")
      end
    end
  end

  status.addEphemeralEffects(damageRequest.statusEffects, damageRequest.sourceEntityId)

  local knockbackFactor = (1 - status.stat("grit"))
  local momentum = knockbackMomentum(vec2.mul(damageRequest.knockbackMomentum, knockbackFactor))
  if status.resourcePositive("health") and vec2.mag(momentum) > 0 then
    mcontroller.setVelocity({0,0})
    if vec2.mag(momentum) > status.stat("knockbackThreshold") then
      mcontroller.addMomentum(momentum)
      status.setResource("stunned", math.max(status.resource("stunned"), status.stat("knockbackStunTime")))
    end
  end

  local hitType = damageRequest.hitType
  if not status.resourcePositive("health") then
    hitType = "kill"
  end
  return {{
    sourceEntityId = damageRequest.sourceEntityId,
    targetEntityId = entity.id(),
    position = mcontroller.position(),
    damageDealt = damage,
    healthLost = healthLost,
    hitType = hitType,
    kind = "Normal",
    damageSourceKind = damageRequest.damageSourceKind,
    targetMaterialKind = status.statusProperty("targetMaterialKind")
  }}
end

function notifyResourceConsumed(resourceName, amount)
  if resourceName == "energy" and amount > 0 then
    status.setResourcePercentage("energyRegenBlock", 1.0)
  end
end

function knockbackMomentum(momentum)
  local knockback = vec2.mag(momentum)
  if mcontroller.baseParameters().gravityEnabled and math.abs(momentum[1]) > 0  then
    local dir = momentum[1] > 0 and 1 or -1
    return {dir * knockback / 1.41, knockback / 1.41}
  else
    return momentum
  end
end

function update(dt)
  if self.damageFlashTime > 0 then
    status.setPrimaryDirectives("fade=ff0000=0.85")
  else
    status.setPrimaryDirectives()
  end
  self.damageFlashTime = math.max(0, self.damageFlashTime - dt)

  if status.statusProperty("hitInvulnerability") then
    self.hitInvulnerabilityTime = math.max(self.hitInvulnerabilityTime - dt, 0)
    local flashTime = status.statusProperty("hitInvulnerabilityFlash")

    if self.hitInvulnerabilityTime > 0 then
      if math.fmod(self.hitInvulnerabilityTime, flashTime) > flashTime / 2 then
        status.setPrimaryDirectives(status.statusProperty("damageFlashOffDirectives"))
      else
        status.setPrimaryDirectives(status.statusProperty("damageFlashOnDirectives"))
      end
    else
      status.setPrimaryDirectives()
    end
  end

  if status.resource("energy") == 0 then
    status.setResourceLocked("energy", true)
  elseif status.resourcePercentage("energy") == 1 then
    status.setResourceLocked("energy", false)
  end

  if not status.resourcePositive("energyRegenBlock") then
    status.modifyResourcePercentage("energy", status.stat("energyRegenPercentageRate") * dt)
  end

  if not status.resourcePositive("shieldStaminaRegenBlock") then
    status.modifyResourcePercentage("shieldStamina", status.stat("shieldStaminaRegen") * dt)
  end

  if mcontroller.atWorldLimit(true) then
    status.setResourcePercentage("health", 0)
  end
end
