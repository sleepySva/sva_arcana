--http://lua-users.org/wiki/SimpleRound
require "/scripts/automation/arcana_power.lua"

pInit = init
function init()
  if pInit then pInit() end
  self.consumptionTime = config.getParameter("consumptionTime", 1)
  self.consumptionTimer = self.consumptionTime
  self.craftingTime = config.getParameter("craftingTime", 1.0)
  self.cooldownTimer = self.craftingTime
  self.outputRate = config.getParameter("outputRate", 10)
  self.resources = config.getParameter("resources", nil)
  self.powerUseAmount = config.getParameter("powerUseAmount", 0)
  power.set(config.getParameter("maxPower", 10))
  animator.setGlobalTag("directives", config.getParameter("directives", ""))
  
  self.isPowered = true
  message.setHandler("getProgress", function()
    local progress = power.round((1 - (self.cooldownTimer / self.craftingTime)), 1)
	--if self.isPowered == true then sb.logInfo("Powered On: " .. tostring(progress)) else sb.logInfo("Powered Off: " .. tostring(progress)) end
    if self.isPowered == true then return progress else return 0 end
  end)
end

function uninit()

end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
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
  local powered = true
  local lastItem = world.containerItemAt(entity.id(), world.containerSize(entity.id()) - 1)
  
  local ironquery = world.objectQuery(object.position(), 3, { name = "workshop_auto_node_iron" })
  local dustriumquery = world.objectQuery(object.position(), 3, { name = "workshop_auto_node_dustrium" })
  local galvasteelquery = world.objectQuery(object.position(), 3, { name = "workshop_auto_node_galvasteel" })
  local resource = nil
  
  if self.resources ~= nil then
    if tablelength(ironquery) > 0 then resource = self.resources.iron
    elseif tablelength(dustriumquery) > 0 then resource = self.resources.dustrium
    elseif tablelength(galvasteelquery) > 0 then resource = self.resources.galvasteel
    else powered = false
    end
  else powered = false
  end
	
  if powered then
	if not lastItem or lastItem.name == resource.name then
	  world.containerPutItemsAt(entity.id(), resource, world.containerSize(entity.id()) - 1)
	else
	  animator.setAnimationState("switchState", "off")
	  return
	end
	  
	animator.setAnimationState("switchState", "on")
  else
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