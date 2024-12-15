require "/scripts/automation/arcana_power.lua"
require "/scripts/util.lua"
require "/scripts/vec2.lua"

pInit = init
function init()
  if pInit then pInit() end
  local configPath = config.getParameter("configPath", "/objects/workshop/workshop_auto_pump/config.config")
  self.pumpOffset = root.assetJson(configPath).pumpOffset or {0, 0}
  self.pumpTime = root.assetJson(configPath).pumpTime or 1
  self.consumptionTime = config.getParameter("consumptionTime", 1.0)
  self.consumptionTimer = self.consumptionTime
  self.cooldownTimer = self.pumpTime
  self.outputRate = root.assetJson(configPath).outputRate or 1
  self.recipes = root.assetJson(configPath).recipes or nil
  self.powerUseAmount = config.getParameter("powerUseAmount", 0)
  power.set(config.getParameter("maxPower", 10))
  animator.setGlobalTag("directives", config.getParameter("directives", ""))
  
  self.isPowered = true
  message.setHandler("getProgress", function()
    local progress = power.round((1 - (self.cooldownTimer / self.pumpTime)), 1)
    if self.isPowered == true and self.isEmpty == false then return progress else return 0 end
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
  if self.isPowered == false then
    animator.setAnimationState("switchState", "off")
    return
  end
  local liquidPosition = vec2.add(object.position(), self.pumpOffset)
  local liquidLevel = world.liquidAt(liquidPosition)
  local liquidItem = { name = "", count = 1 }
  if liquidLevel ~= nil and liquidLevel[2] >= 0.5 then
	world.destroyLiquid(liquidPosition)
	liquidItem.name = root.liquidConfig(liquidLevel[1]).config.itemDrop
	world.containerAddItems(entity.id(), liquidItem)
	self.isEmpty = false
	animator.setAnimationState("switchState", "on")
  else
    self.isEmpty = true
    animator.setAnimationState("switchState", "empty")
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
	  self.cooldownTimer = self.pumpTime
    end
  end
end
