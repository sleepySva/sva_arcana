function init()
  script.setUpdateDelta(60)
  self.powerPerEnemy = config.getParameter("powerPerEnemy", nil)
  self.critDamagePerEnemy = config.getParameter("critDamagePerEnemy", nil)
  self.stackMax = config.getParameter("stackMax", 10)
  self.lastEnemyCount = 0
  self.statusGroup = nil
end

function update(dt)
  local count = queryEnemies(40)
  if self.lastEnemyCount ~= count then
    self.lastEnemyCount = count
    refresh()
  end
end

function uninit()
end

function refresh()

  local power = 1.0 + (self.lastEnemyCount * self.powerPerEnemy)
  local critDamage = 0.0 + (self.lastEnemyCount * self.critDamagePerEnemy)
  local modifiers = {{ stat = "powerMultiplier", effectiveMultiplier = power }, { stat = "arcana_critDamageMultiplier", effectiveMultiplier = critDamage }}

  if self.statusGroup ~= nil then
    effect.setStatModifierGroup(self.statusGroup, modifiers)
  else
    self.statusGroup = effect.addStatModifierGroup(modifiers)
  end

end

function queryEnemies(radius)
  local monsters = world.monsterQuery(entity.position(), radius)
  local count = 0
  if not next(monsters) then return 0 end 
  for _, monster in pairs(monsters) do 
    if world.entityDamageTeam(monster).type == "enemy" then count = count + 1 end
  end
  return math.min(count, self.stackMax)
end
