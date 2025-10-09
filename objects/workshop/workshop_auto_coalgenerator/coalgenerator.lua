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
  self.isPowered, self.isWorking = false
  self.isPlayingSound = false
  animator.setGlobalTag("directives", config.getParameter("directives", ""))
  
  message.setHandler("getProgress", function()
    local progress = power.round((1 - (1 - self.consumptionTimer / self.consumptionTime)), 1)
    if self.isPowered == true then return progress else return 0 end
  end)
end


function uninit()

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
  if power.getState() == true then
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
		  setAnimation(true)
	      power.set(self.maxPower)
	    else
	      object.setOutputNodeLevel(0, false)
		  setAnimation(false)
		  power.set(0)
	    end 
	    power.send(0, power.get())
	    self.productionTimer = self.productionTime
	  end
    end
  else
    setAnimation(false)
  end
end

function setAnimation(s)
  if s == true then 
    if self.isPlayingSound == false then
	  animator.playSound("onloop", -1)
	  self.isPlayingSound = true
	end
    animator.setAnimationState("switchState", "on")
	animator.setParticleEmitterActive("smoke", true)
  else
    animator.setAnimationState("switchState", "off")
	animator.setParticleEmitterActive("smoke", false)
	animator.stopAllSounds("onloop")
	self.isPlayingSound = false
  end
end