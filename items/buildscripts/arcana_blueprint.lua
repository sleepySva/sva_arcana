function build(_, config, _)

  -- populate tooltip fields
  config.tooltipFields = {}
  config.tooltipFields.itemImage_1 = "/interface/elements/"..elementalType..".png"
  
  return config, parameters
end