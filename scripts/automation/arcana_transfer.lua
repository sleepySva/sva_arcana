transfer = {}
-- Output
function transfer.output(id, rate, slot)
  local entityTable = object.getOutputNodeIds(0)
  local count = 0
  for _ in pairs(entityTable) do count = count + 1 end
  -- defaults to last slot
  local s = world.containerSize(id) - 1
  if slot then s = slot end
  item = world.containerItemAt(id, s)
  if object.isOutputNodeConnected(0) and count >= 1 and item then
	for key, _ in pairs(entityTable) do
	  if world.containerSize(key) == nil then return end
	  if world.containerItemsFitWhere(key, item)["leftover"] ~= 0 then return end
	  
	  local settings = world.getObjectParameter(key, "containerSettings")
	  local attempt = world.containerTakeNumItemsAt(id, s, item.count)
	  
	  -- transfers through settings
	  if settings then
	    if not settings.allowed then return end
		if settings.allowedInputSlots then
		  
	      --put into allowed slots
	      for _, pos in pairs(settings.allowedInputSlots) do
	        attempt = world.containerPutItemsAt(key, attempt, pos-1)
		    if attempt == nil or attempt == {} then break end
	      end
		  --refund leftovers to input container
		  if attempt ~= nil and attempt ~= {} then
		    world.containerPutItemsAt(id, attempt, s)
		  end
		  
		end
	  end
	  
	  -- transfers freely by default
	  world.containerAddItems(key, attempt)
	end
  end
end