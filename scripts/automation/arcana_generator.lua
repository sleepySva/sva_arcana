require "/scripts/automation/arcana_power.lua"
require "/scripts/automation/arcana_transfer.lua"

pInit = init
function init()
  if pInit then pInit() end
  local configPath = config.getParameter("configPath", "/objects/workshop/auto_generator/config.config")
  self.consumptionTime = config.getParameter("consumptionTime", 1.0)
  self.consumptionTimer = 1
  self.productionTime = 1
  self.productionTimer = self.productionTime
  self.recipes = root.assetJson(configPath).recipes or nil
  power.set(0)
  animator.setGlobalTag("directives", config.getParameter("directives", ""))
  
  self.isPowered = false
  self.isPlayingSound = false
  message.setHandler("getProgress", function()
    local progress = power.round((1 - (self.consumptionTimer / self.consumptionTime)), 1)
    if self.isPowered == true and animator.animationState("switchState") ~= "off" then return progress else return 0 end
  end)
end

-- recipe checking
function automation()
  local craftable = true
  
  --loops until a valid recipe is found and powers on, or none are avaliable and powers off
  for i, recipe in pairs(self.recipes) do
  
    craftable = true
    for j, input in pairs(recipe.input) do
      if not (world.containerAvailable(entity.id(), input) > 0) then craftable = false break end
    end
	
	if craftable then
	  --generator runs
	  power.setMax(recipe.output) --need function
	  self.isPowered = true
	  
	  --consume inputs
	  for k, input in pairs(recipe.input) do
        world.containerConsume(entity.id(), input)
      end
	  return
	end
  end
  self.isPowered = false
end

function update(dt)
  --only runs when button is turned on
  if power.getState() == true then
    -- check recipes and consume items
    if self.consumptionTimer > 0 then
      self.consumptionTimer = math.max(0, self.consumptionTimer - dt)
      if self.consumptionTimer == 0 then
        automation()
	    self.consumptionTimer = self.consumptionTime
      end
    end
	-- distribute power
    if self.productionTimer > 0 then
      self.productionTimer = math.max(0, self.productionTimer - dt)
	  if self.productionTimer == 0 then
	    if self.isPowered == true then
	      object.setOutputNodeLevel(0, true)
		  setAnimation(true)
	      power.set(power.max())
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