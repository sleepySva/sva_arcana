require "/scripts/automation/arcana_power.lua"
require "/scripts/vec2.lua"

pInit = init
function init()
  if pInit then pInit() end
  local configPath = config.getParameter("configPath", "/objects/workshop/workshop_auto_extractor/extractor.config")
  self.consumptionTime = config.getParameter("consumptionTime", 1)
  self.consumptionTimer = self.consumptionTime
  self.craftingTime = config.getParameter("craftingTime", 1.0)
  self.cooldownTimer = self.craftingTime
  self.outputRate = config.getParameter("outputRate", 10)
  self.resources = root.assetJson(configPath).resources or config.getParameter("resources", nil)
  self.powerUseAmount = config.getParameter("powerUseAmount", 0)
  self.miningArea = config.getParameter("miningArea", {{0, -1}, {6, -1}})
  power.set(0)
  animator.setGlobalTag("directives", config.getParameter("directives", ""))
  
  self.isPowered, self.isWorking = false
  message.setHandler("getData", function()
    local data = {status = "", progress = 0}
	if self.isPowered and self.isWorking then
	  data.status = string.format("^white;Extraction in progress!^reset; ^orange;Rate: %s/%ss^reset;", 1, self.craftingTime)
      data.progress = power.round((1 - (self.cooldownTimer / self.craftingTime)), 1)
	else
	  data.progress = 0
	  if self.isPowered then
	    data.status = "^orange;No extractable ore node found.^reset;"
	  else
	    data.status = "^red;Machine offline. Awaiting power!^reset;"
	  end
	end
    return data
  end)
end

function uninit()

end

function tablelength(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

function output(state)
  local entityTable = object.getOutputNodeIds(0)
  local item = world.containerItemAt(entity.id(), world.containerSize(entity.id()) - 1)
  local adjustedRate = 0
  if object.isOutputNodeConnected(0) and tablelength(entityTable) >= 1 and item then
    adjustedRate = math.ceil(self.outputRate / tablelength(entityTable))
	for key, value in pairs(entityTable) do
	  if world.containerSize(key) == nil then return end
	  if world.containerItemsFitWhere(key, item)["leftover"] ~= 0 then return end
	  local isAssembler = (world.containerSize(key) < 9)

	  if isAssembler and world.containerItemsFitWhere(key, item)["slots"][1] == world.containerSize(key) - 1 then return end
	  item = world.containerTakeNumItemsAt(entity.id(), world.containerSize(entity.id()) - 1, adjustedRate)
	  world.containerAddItems(key, item)
	end
  end
end

function automation()
  
  if self.isPowered == false then return end
  local lastItem = world.containerItemAt(entity.id(), world.containerSize(entity.id()) - 1)
  
  local result = false
  for _, resource in pairs(self.resources) do
    if resource.type == "object" then
	  result = world.objectQuery(object.position(), 3, { name = resource.item.name })
	  if #result < 1 then result = false end
	  if result then
	    result = resource.item
		self.craftingTime = 1.0
		break
	  end
	elseif resource.type == "mod" then
	  local modList = modQueryList(object.position(), self.miningArea[1], self.miningArea[2])
	  if modList == false then break end
	  if next(modList) then
	    local max = {name = nil, count = 0}
	    for item, itemCount in pairs(modList) do
		  if itemCount > max.count then max.name = item max.count = itemCount end
		end
	    self.craftingTime = math.max(2.3 + ((8 - max.count) / 10), 2.3)
	    result = {name = max.name, count = 1}
	    break
	  end
	end
  end
	
  if result and self.isPowered then
	if not lastItem or lastItem.name == result.name then
	  world.containerPutItemsAt(entity.id(), result, world.containerSize(entity.id()) - 1)
	else
	  animator.setAnimationState("switchState", "off")
	  return
	end
	self.isWorking = true
	animator.setAnimationState("switchState", "on")
  else
    self.isWorking = false
    animator.setAnimationState("switchState", "off")
  end
  
end

function powerCheck()
  if power.get() >= self.powerUseAmount then 
    power.remove(self.powerUseAmount)
    self.isPowered = true
  else
    animator.setAnimationState("switchState", "off")
    self.isPowered = false
	return
  end
end

function update(dt)
  if self.consumptionTimer > 0 then
    self.consumptionTimer = math.max(0, self.consumptionTimer - dt)
    if self.consumptionTimer == 0 then
      powerCheck()
	  self.consumptionTimer = self.consumptionTime
    end
  end
  if self.cooldownTimer > 0 then
    self.cooldownTimer = math.max(0, self.cooldownTimer - dt)
    if self.cooldownTimer == 0 then
      automation()
	  output(true)
	  self.cooldownTimer = self.craftingTime
    end
  end
end

--Improved code by The Punslinger!
function modQueryList(position, p1, p2)
  --sb.logInfo(string.format("Origin at (%s, %s)", position[1], position[2]))
  local resourcesList = {}
  
  local min_x, max_x = math.min(p1[1], p2[1]), math.max(p1[1], p2[1])
  local min_y, max_y = math.min(p1[2], p2[2]), math.max(p1[2], p2[2])
  for x = min_x, max_x do
    for y = min_y, max_y do
      local offsetPosition = vec2.add(position, {x, y})
      local result = world.mod(offsetPosition, "foreground")
      if result then
        local blockMod = root.modConfig(result)
        if blockMod then
            local resourceInBlock = sb.jsonQuery(blockMod.config, "itemDrop", nil)
            if resourceInBlock then
                if resourcesList[resourceInBlock] then
                    resourcesList[resourceInBlock] = resourcesList[resourceInBlock] + 1
                else
                    resourcesList[resourceInBlock] = 1
                end
            end
        end
      end

    end
  end
  
  if next(resourcesList) then return resourcesList else return false end
end