require "/scripts/util.lua"
require "/scripts/status.lua"

function init()
  animator.setParticleEmitterActive("sparks", true)
  animator.playSound("burn", -1)
  effect.setParentDirectives("fade=201e21=0.10")

  script.setUpdateDelta(5)

  self.triggerDamageThreshold = config.getParameter("triggerDamageThreshold")

  self.timeUntilActive = config.getParameter("activateDelay")
  
  self.tickDamagePercentage = 0.06
  self.tickTime = 0.8
  self.tickTimer = self.tickTime
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1,
        damageSourceKind = "arcana_abyss",
        sourceEntityId = entity.id()
      })
  end
  if self.timeUntilExpire then
    self.timeUntilExpire = self.timeUntilExpire - dt
    if self.timeUntilExpire <= 0 then
      effect.expire()
    end
  elseif self.timeUntilActive > 0 or not self.damageListener then
    self.timeUntilActive = self.timeUntilActive - dt
    if self.timeUntilActive <= 0 then
      self.damageListener = damageListener("damageTaken", function(notifications)
        local totalDamage = 0
        for _, notification in pairs(notifications) do
          if notification.hitType == "Hit" then
            totalDamage = totalDamage + notification.damageDealt
            if totalDamage >= self.triggerDamageThreshold then
              trigger()
              break
            end
          end
        end
      end)
    end
  else
    self.damageListener:update()
  end
end

function uninit()

end

function trigger()
  status.applySelfDamageRequest({
      damageType = "IgnoresDef",
      damage = config.getParameter("explosionDamageAmount"),
      damageSourceKind = "arcana_abyss",
      sourceEntityId = entity.id()
    })
  animator.burstParticleEmitter("sparks")
  animator.setParticleEmitterActive("sparks", false)
  animator.setLightActive("glow", false)
  self.timeUntilExpire = config.getParameter("deactivateDelay")
end
