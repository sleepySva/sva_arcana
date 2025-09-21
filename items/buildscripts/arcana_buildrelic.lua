require "/scripts/util.lua"
require "/scripts/staticrandom.lua"

function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue)
    if parameters[keyName] ~= nil then
      return parameters[keyName]
    elseif config[keyName] ~= nil then
      return config[keyName]
    else
      return defaultValue
    end
  end

  if level and not configParameter("fixedLevel", false) then
    parameters.level = level
  end
  
  -- initialize randomization
  if seed then
    parameters.seed = seed
  else
    seed = configParameter("seed")
    if not seed then
      math.randomseed(util.seedTime())
      seed = math.random(1, 4294967295)
      parameters.seed = seed
    end
  end

  -- select the generation profile to use
  local builderConfig = {}
  if config.builderConfig then
    builderConfig = randomFromList(config.builderConfig, parameters.seed, "builderConfig")
  end

  -- build palette swap directives
  config.paletteSwaps = ""
  if builderConfig.palettes then
    for _, p in pairs(builderConfig.palettes) do 
      local palette = root.assetJson(util.absolutePath(directory, p))
      local selectedSwaps = randomFromList(palette.swaps, seed, "paletteSwaps")
      for k, v in pairs(selectedSwaps) do
        config.paletteSwaps = string.format("%s?replace=%s=%s", config.paletteSwaps, k, v)
      end
    end
  end

  -- merge extra animationCustom
  if builderConfig.animationCustom then
    config.animationCustom = util.mergeTable(config.animationCustom or {}, builderConfig.animationCustom)
  end

  -- animation parts
  if builderConfig.animationParts then
    if parameters.animationParts == nil then parameters.animationParts = {} end
    for k, v in pairs(builderConfig.animationParts) do
      if parameters.animationParts[k] == nil then
        if type(v) == "table" then
          parameters.animationParts[k] = util.absolutePath(directory, string.gsub(v.path, "<variant>", randomIntInRange({1, v.variants}, parameters.seed, "animationPart"..k)))
          if v.paletteSwap then
            parameters.animationParts[k] = parameters.animationParts[k] .. config.paletteSwaps
          end
        else
          parameters.animationParts[k] = v
        end

        if k == "body" and not parameters.inventoryIcon then
          parameters.inventoryIcon = parameters.animationParts[k] .. config.paletteSwaps
        end
      end
    end
  end

  -- rarity
  local rarityConfig = root.assetJson(builderConfig.rarityConfig)
  local rarity = randomFromList(rarityConfig.rarities, seed, "rarity")
  local perks = rarity.perks
  config.rarity = rarity.name
  config.price = rarity.price
  
    -- shuffle and randomize perks
	parameters.perks = {}
    local shuffled = shuffle(rarityConfig.perks, seed)

    local str = ""
    for i=1, perks do
      local perk = shuffled[i]
	  local stat = perk.stats[rarity.scaling]
	  local identifier = ""
	  if perk.type == "percent" then identifier = "%" end
	
	  table.insert(parameters.perks, {id = perk.id, value = stat})
	  str = str .. "^orange;+" .. tostring(stat) .. identifier .. "^reset; " .. perk.name .. "\n"
    end
  
  -- tooltip fields
  config.tooltipFields = {}
  config.tooltipFields.perksLabel = str
	
  -- name
  parameters.mainPerk = "generic"
  if perks ~= 0 then
    parameters.mainPerk = parameters.perks[1].id
  end
  
  if not parameters.shortdescription and builderConfig.nameGenerator then
    local nameConfig = root.assetJson(util.absolutePath(directory, builderConfig.nameGenerator))
	local nameFormat = randomFromList(root.assetJson(util.absolutePath(directory, builderConfig.nameFormats)).formats, seed, "nameFormat")
	--parameters.shortdescription = "temp"
    parameters.shortdescription = loreGen(nameConfig, nameFormat, seed, config, parameters)
  end
  
  -- description
  if not parameters.description and builderConfig.loreGenerator then
    local loreConfig = root.assetJson(util.absolutePath(directory, builderConfig.loreGenerator))
    parameters.description = loreGen(loreConfig, builderConfig.loreFormat, seed, config, parameters)
  end

  return config, parameters
end

-- https://gist.github.com/Uradamus/10323382
function shuffle(tbl, seed)
  for i = #tbl, 2, -1 do
    local j = randomIntInRange({1, i}, seed, 1)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function loreGen(loreConfig, format, seed, config, parameters)
  --sb.logInfo(parameters.mainPerk)
  local wordlist = {}
  local count = 1
  for _, phrase in pairs(format.read) do
	if phrase == "itemName" and parameters.shortdescription then
      table.insert(wordlist, parameters.shortdescription)
	else
	  for k, v in pairs(loreConfig) do
	    if k == phrase or (phrase == "perk" and k == parameters.mainPerk) then
		  table.insert(wordlist, randomFromList(v, seed, tostring(count)))
		  count = count + 1
		  break
		end
	  end
	end
  end
  return string.format(format.abstract, table.unpack(wordlist))
end