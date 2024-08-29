require("/objects/scripts/cf_power.lua")

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

function consumeInput()
  local slots = world.containerItems(entity.id())
  local isConsumeable = true
  for i=1,tablelength(self.input) do
    if not (world.containerItemAt(entity.id(), i-1) and self.input[i].name == slots[i].name) then 
	  isConsumeable = false
	end
  end
  if isConsumeable then
    self.isPowered = true
    for i=1,tablelength(self.input) do
	  world.containerTakeNumItemsAt(entity.id(), i-1, 1)
	end
  else
    self.isPowered = false
  end
end

function update(dt)
  if self.consumptionTimer > 0 then
    self.consumptionTimer = math.max(0, self.consumptionTimer - dt)
    if self.consumptionTimer == 0 then
	  consumeInput()
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
	    cf_power.setPower(self.maxPower)
	  else
	    object.setOutputNodeLevel(0, false)
		animator.setAnimationState("switchState", "off")
		animator.setParticleEmitterActive("smoke", false)
		animator.stopAllSounds("onloop")
		self.isPlayingSound = false
	  end 
	  cf_power.pushPower(0, cf_power.getPower(), true, 0)
	  self.productionTimer = self.productionTime
	end
  end
end
