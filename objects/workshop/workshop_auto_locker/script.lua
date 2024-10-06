function init()
  self.craftingTime = config.getParameter("craftingTime", 1.0)
  self.cooldownTimer = self.craftingTime
  self.outputRate = config.getParameter("outputRate", 4)
  animator.setGlobalTag("directives", config.getParameter("directives", ""))
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
  local itemTable = world.containerItems(entity.id())
  local invertedItemTable = {}
  local adjustedRate = 0
  
  for k, v in pairs(itemTable) do 
  if object.isOutputNodeConnected(0) and tablelength(entityTable) >= 1 and tablelength(itemTable) > 0 then
    adjustedRate = math.ceil(self.outputRate / tablelength(entityTable))
    local item = world.containerItemAt(entity.id(), k - 1)
	for key, value in pairs(entityTable) do
	  if world.containerSize(key) == nil then return end
	  if world.containerItemsFitWhere(key, item)["leftover"] ~= 0 then return end
	  local isAssembler = (world.containerSize(key) < 9)

	  if isAssembler and world.containerItemsFitWhere(key, item)["slots"][1] == world.containerSize(key) - 1 then return end
	  item = world.containerTakeNumItemsAt(entity.id(), k - 1, adjustedRate)
	  world.containerAddItems(key, item)
	end
  end
  return
  end
end

function update(dt)
  if self.cooldownTimer > 0 then
    self.cooldownTimer = math.max(0, self.cooldownTimer - dt)
    if self.cooldownTimer == 0 then
	  output(true)
	  self.cooldownTimer = self.craftingTime
    end
  end
end
