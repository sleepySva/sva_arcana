require "/scripts/util.lua"

function build(_, config, parameters)
  if parameters.configName then
    local replacement = root.assetJson(config.configPath)[parameters.configName]
	for key, value in pairs(replacement) do config[key] = value end
  end
  return config, parameters
end