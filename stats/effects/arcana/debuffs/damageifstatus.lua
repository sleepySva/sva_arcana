require "/scripts/util.lua"
function init()
  self.status = config.getParameter("status")
  self.damage = config.getParameter("damage")
  self.bonus = config.getParameter("bonus")
  
  local apply = false
  for _, stat in pairs(status.activeUniqueStatusEffectSummary()) do
    if stat[1] == self.status then
      status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.damage.amount,
        damageSourceKind = self.damage.type,
        sourceEntityId = entity.id()
      })
	  if self.bonus then status.addEphemeralEffect(self.bonus) end 
	  apply = true
	  break
    end
  end
  if apply == false then status.addEphemeralEffect(self.status) end
end