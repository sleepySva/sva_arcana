require "/scripts/automation/arcana_power.lua"
require "/scripts/util.lua"
require "/scripts/vec2.lua"

pInit = init
function init()
  if pInit then pInit() end
  self.outputTime = 1
  self.cooldownTimer = self.outputTime
  self.settings = config.getParameter("settings", 0)
  animator.setGlobalTag("directives", config.getParameter("directives", ""))
  self.isRunning = false
  animator.setAnimationState("switchState", "off")
end

function tablelength(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
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
      return tostring(o) or "NIL"
   end
end

function getOutputs(entity, position, item, schema)
  self.isRunning = false
  local entityTable = object.getOutputNodeIds(0)
  if object.isOutputNodeConnected(0) and tablelength(entityTable) >= 1 and item then
	for key, value in pairs(entityTable) do
	  if world.containerSize(key) == nil then goto end_loop end
	  if world.containerItemsFitWhere(key, schema)["leftover"] ~= 0 then goto end_loop end
	  local settings = world.getObjectParameter(key, "containerSettings")
	  if settings and settings.allowed == false then goto end_loop end
	  --take from input container
	  local attempt = world.containerTakeNumItemsAt(entity, position-1, schema.count)
	  if settings and settings.allowedInputSlots then
	    --put into allowed slots
	    for _, pos in pairs(settings.allowedInputSlots) do
	      attempt = world.containerPutItemsAt(key, attempt, pos-1)
		  if attempt == nil or attempt == {} then self.isRunning = true goto end_loop end
	    end
		--refund leftovers to input container
		if attempt ~= nil and attempt ~= {} then
		  world.containerPutItemsAt(entity, attempt, position-1)
		end
	  else
	    world.containerAddItems(key, attempt)
	    self.isRunning = true
	  end
	  ::end_loop::
	end
  end
  if self.isRunning then
    animator.setAnimationState("switchState", "on")
  else
    animator.setAnimationState("switchState", "off")
  end
end

function update(dt)
  if self.cooldownTimer > 0 then
    self.cooldownTimer = math.max(0, self.cooldownTimer - dt)
    if self.cooldownTimer == 0 then
	  getInputs()
	  self.cooldownTimer = self.outputTime
    end
  end
end

function getInputs()
  local entityTable = object.getInputNodeIds(0)
  for entity, _ in pairs(entityTable) do
    for k, v in pairs(world.containerItems(entity)) do 
	  local schema = isValidInput(v)
      if schema then
	    getOutputs(entity, k, v, schema)
	  end
    end
  end
end

function isValidInput(item)
  for k, v in pairs(world.containerItems(entity.id())) do 
    if item.name == v.name and item.count >= v.count then return v end
  end
  return false
end

--[[
function setSettings(arg)
  self.settings = arg
  object.setConfigParameter("settings", self.settings)
end
--]]