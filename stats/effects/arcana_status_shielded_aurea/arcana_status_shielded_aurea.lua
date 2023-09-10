require "/scripts/util.lua"
require "/scripts/status.lua"

function init()
  self.maxShieldHealth = status.stat("maxHealth") * config.getParameter("shieldHealthMultiplier")
  status.setStatusProperty("arcana_status_shielded", self.maxShieldHealth)
  
  script.setUpdateDelta(5)

  self.active = true
  self.expirationTimer = config.getParameter("expirationTime") or 0

  addVisualEffect()
  
  self.modifierGroup = effect.addStatModifierGroup({
    {stat = "protection", amount = 10.0},
  })
end

function update(dt)

  if not status.statusProperty("arcana_status_shielded") or status.statusProperty("arcana_status_shielded") < 0 then
    if self.active then
      removeVisualEffect()
    end

    if self.expirationTimer <= 0 then
      effect.expire()
    end
    self.expirationTimer = self.expirationTimer - dt

    self.active = false
  else
  
    if not self.active then
      addVisualEffect()
    end

    self.active = true
    self.expirationTimer = config.getParameter("expirationTime") or 0
  end
  
  self.damageListener = damageListener("damageTaken", function(notifications)
    for _,notification in pairs(notifications) do
	  sb.logInfo("[DEBUG] shield damaged")
	  sb.logInfo("[DEBUG] damage:" .. notification.damageDealt)
	  local stack = (status.statusProperty("arcana_status_shielded") or 0) - notification.damageDealt
	  status.setStatusProperty("arcana_status_shielded", stack)
    end
  end)
  status.modifyResource("health", 9999)

end

function addVisualEffect()
  if not config.getParameter("hideBorder") then effect.setParentDirectives("border=3;00FFFF99;00000000") end
  animator.setAnimationState("shield", "on")
end

function removeVisualEffect()
  animator.setAnimationState("shield", "off")
  effect.setParentDirectives("")
end

function onExpire()
  status.setStatusProperty("arcana_status_shielded", 0)
  effect.removeStatModifierGroup(self.modifierGroup)
  status.setResource("health", self.maxShieldHealth)
  sb.logInfo("[DEBUG] effect expired")
end
