--https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
require "/scripts/automation/arcana_power.lua"

pInit = init

function init()
  if pInit then pInit() end
  self.input = config.getParameter("input", nil)
  self.consumptionTime = config.getParameter("consumptionTime", 10)
  self.maxPower = config.getParameter("maxPower", 10)
  self.productionTime = 1
  self.consumptionTimer = self.consumptionTime
  self.productionTimer = self.productionTime
  self.isPowered = false
  self.isPlayingSound = false
  animator.setGlobalTag("directives", config.getParameter("directives", ""))
  
  message.setHandler("getProgress", function()
    local progress = power.round((1 - (1 - self.consumptionTimer / self.consumptionTime)), 1)
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
      return tostring(o) or "NIL"
   end
end

function tablelength(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

-- Only for single slot machines
function consumeInputSingle()
  for _, item in pairs(self.input) do
    --if world.containerAvailable(entity.id(), item) then
	if world.containerItemAt(entity.id(), 0) ~= nil and world.containerItemAt(entity.id(), 0).name == item.name then
	  self.isPowered = true
      world.containerTakeNumItemsAt(entity.id(), 0, item.count)
	  return
	end
  end
  self.isPowered = false
end

function update(dt)
  if self.consumptionTimer > 0 then
    self.consumptionTimer = math.max(0, self.consumptionTimer - dt)
    if self.consumptionTimer == 0 then
	  consumeInputSingle()
	  self.consumptionTimer = self.consumptionTime
    end
  end
  if self.productionTimer > 0 then
    self.productionTimer = math.max(0, self.productionTimer - dt)
	if self.productionTimer == 0 then
	  if self.isPowered == true then
	    object.setOutputNodeLevel(0, true)
		animator.setAnimationState("switchState", "on")
		animator.setParticleEmitterActive("smoke", true)
		if self.isPlayingSound == false then
		  animator.playSound("onloop", -1)
		  self.isPlayingSound = true
		end
	    power.set(self.maxPower)
	  else
	    object.setOutputNodeLevel(0, false)
		animator.setAnimationState("switchState", "off")
		animator.setParticleEmitterActive("smoke", false)
		animator.stopAllSounds("onloop")
		self.isPlayingSound = false
	  end 
    power.send(0, power.get())
	  self.productionTimer = self.productionTime
	end
  end
end
