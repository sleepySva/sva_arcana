function build(_, config, _)
  local b = "desertTreasure"
  local a = root.isTreasurePool(config.pool or b) and (config.pool or b) or b
  a = root.createTreasure(config.pool,config.level or 1)
  a = a[math.random(#a)]
  config.itemName = a.name
  parameters = a.parameters
  --TODO: can we change count from buildscript?
  return config, parameters
end
