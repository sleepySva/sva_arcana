function init()
  self.damage = config.getParameter("damage")
  status.applySelfDamageRequest({
	damage = self.damage.amount,
	damageSourceKind = self.damage.type,
	sourceEntityId = entity.id()
  })
end