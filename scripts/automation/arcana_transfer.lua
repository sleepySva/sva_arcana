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
	  if world.containerSize(key) == nil then goto end_loop end
	  if world.containerItemsFitWhere(key, item)["leftover"] ~= 0 then goto end_loop end
	  local settings = world.getObjectParameter(key, "containerSettings")
	  
	  -- transfers through settings
	  if settings and settings.allowed then
		if settings.allowedInputSlots then
		  local attempt = world.containerTakeNumItemsAt(id, s, item.count)
	      --put into allowed slots
	      for _, pos in pairs(settings.allowedInputSlots) do
	        attempt = world.containerPutItemsAt(key, attempt, pos-1)
		    if attempt == nil or attempt == {} then goto end_loop end
	      end
		  --refund leftovers to input container
		  if attempt ~= nil and attempt ~= {} then
		    world.containerPutItemsAt(id, attempt, s)
		  end
		  
		end
	  elseif not (settings and not settings.allowed) then
	    -- transfers freely by default
	    local attempt = world.containerTakeNumItemsAt(id, s, item.count)
		world.containerAddItems(key, attempt)
	  end
	end
	::end_loop::
  end
end