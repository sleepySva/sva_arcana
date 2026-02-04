require "/scripts/automation/arcana_transfer.lua"

function init()
  local configPath = config.getParameter("configPath", "/objects/workshop/workshop_auto_essenceextractor/config.config")
  self.craftingTime = root.assetJson(configPath).craftingTime or 1
  self.outputTime = root.assetJson(configPath).outputTime or 1
  self.cooldownTimer = self.craftingTime
  self.outputTimer = self.outputTime
  self.outputRate = root.assetJson(configPath).outputRate or 1
  self.recipes = root.assetJson(configPath).recipes or nil
  animator.setGlobalTag("directives", config.getParameter("directives", ""))
end

function tablelength(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

-- Item export
function output(state)
  for i=1, world.containerSize(entity.id()) do
    -- Export first avaliable item found
	if world.containerItemAt(entity.id(), i-1) ~= nil and i >= 2 then
	  transfer.output(entity.id(), self.outputRate, i-1)
	  return
	end
  end
end

function automation()
  
  local craftable = false
  local firstItem = world.containerItemAt(entity.id(), 0)
  local lastItem = world.containerItemAt(entity.id(), world.containerSize(entity.id()) - 1)
  
  for _, recipe in pairs(self.recipes) do
  
    -- Find craftable recipe
    if firstItem ~= nil and firstItem.name == recipe.input.name then
	  craftable = true
	end
	
	-- Craft recipe items, refund if there's not enough space
	if craftable then
	  local itemlist = {}
	  for _, output in pairs(recipe.output) do
	    -- Weight check
		if output.weight >= math.random() then
	      if world.containerItemsCanFit(entity.id(), output.item) ~= 0 then
	        world.containerAddItems(entity.id(), output.item)
		    table.insert(itemlist, output.item)
	      else
		    for _, deleteitem in pairs(itemlist) do
		      world.containerConsume(entity.id(), deleteitem)
		    end
	        animator.setAnimationState("switchState", "off")
	        return
	      end
		end
	  end
	  
	  -- Consume recipe input
	  world.containerConsume(entity.id(), recipe.input)
	  animator.setAnimationState("switchState", "on")
	  return
	end
	
  end
  animator.setAnimationState("switchState", "off")
  
end

function update(dt)
  if self.cooldownTimer > 0 then
    self.cooldownTimer = math.max(0, self.cooldownTimer - dt)
    if self.cooldownTimer == 0 then
      automation()
	  self.cooldownTimer = self.craftingTime
    end
  end
  if self.outputTimer > 0 then
    self.outputTimer = math.max(0, self.outputTimer - dt)
    if self.outputTimer == 0 then
	  output(true)
	  self.outputTimer = self.outputTime
    end
  end
end
