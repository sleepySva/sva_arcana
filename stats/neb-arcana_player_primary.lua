preNebArcana_applyDamageRequest = applyDamageRequest

function applyDamageRequest(damageRequest)
  world.sendEntityMessage(entity.id(), "neb_arcana-lastDamageConfig", damageRequest)

  local oldDamageRequest = damageRequest
  if preNebArcana_applyDamageRequest then
    damageRequest = preNebArcana_applyDamageRequest(damageRequest)
  end
  return damageRequest
end