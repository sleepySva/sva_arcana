require "/scripts/automation/arcana_power.lua"

pInit = init
function init()
  if pInit then pInit() end
  local configPath = config.getParameter("configPath", "/objects/workshop/workshop_auto_assembler/config.config")
  self.consumptionTime = config.getParameter("consumptionTime", 1.0)
  self.consumptionTimer = self.consumptionTime
  self.craftingTime = root.assetJson(configPath).craftingTime or 1
  self.cooldownTimer = self.craftingTime
  self.outputRate = root.assetJson(configPath).outputRate or 1
  self.recipes = root.assetJson(configPath).recipes or nil
  self.powerUseAmount = config.getParameter("powerUseAmount", 0)
  power.set(0)
  animator.setGlobalTag("directives", config.getParameter("directives", ""))
  
  self.isPowered, self.isWorking = false
  message.setHandler("getProgress", function()
    local progress = power.round((1 - (self.cooldownTimer / self.craftingTime)), 1)
    if self.isPowered == true and animator.animationState("switchState") ~= "off" then return progress else return 0 end
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
  local craftable = true
  local lastItem = world.containerItemAt(entity.id(), world.containerSize(entity.id()) - 1)
  
  for i, recipe in pairs(self.recipes) do
  
    craftable = true
    for j, input in pairs(recipe.input) do
	  if lastItem then
	    if lastItem.name == input.name then craftable = false end
	  end
      if not (world.containerAvailable(entity.id(), input) > 0) then craftable = false end
    end
	
	if craftable then
	  if not lastItem or lastItem.name == recipe.output.name then
	    world.containerPutItemsAt(entity.id(), recipe.output, world.containerSize(entity.id()) - 1)
		self.isWorking = true
	  else
	    animator.setAnimationState("switchState", "off")
		self.isWorking = false
	    return
	  end
	  
	  for k, input in pairs(recipe.input) do
        world.containerConsume(entity.id(), input)
      end
	  animator.setAnimationState("switchState", "on")
	  return
	end
	
  end
  animator.setAnimationState("switchState", "off")
  
end

function powerCheck()
  if power.get() >= self.powerUseAmount then 
	if self.isWorking then
	  power.remove(self.powerUseAmount)
	end
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
