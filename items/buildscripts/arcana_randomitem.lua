function build(_, config, _)
  local a = root.isTreasurePool(config.pool) and config.pool or "desertTreasure"
  a = root.createTreasure(config.pool,config.level or 1)
  a = a[math.random(#a)]
  config.itemName = a.name
  parameters = a.parameters
  --TODO: can we change count from buildscript?
  return config, parameters
end
