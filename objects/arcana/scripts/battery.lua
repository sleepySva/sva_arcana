require "/scripts/automation/arcana_power.lua"
pInit = init

function init()
  if pInit then pInit() end
  self.description = root.itemConfig(object.name()).config.description
  self.maxPower = config.getParameter("maxPower", 10)
  self.outputPower = config.getParameter("outputPower", 10)
  self.productionTime = 1
  self.productionTimer = self.productionTime
  self.isPowered = false
  animator.setGlobalTag("directives", config.getParameter("directives", ""))
  
  self.meter = config.getParameter("meter", {min = 12, max = 29, width = 31})
  
  message.setHandler("getData", function()
    local data = {status = "", progress = 0}
	if self.isPowered  then
	  data.status = string.format("^white;Stored Power: ^orange;%s^reset;/%skw", power.get(), power.max())
      data.progress = power.round((power.get() / power.max()), 1)
	else
	  data.status = "^red;Machine offline. Awaiting power!^reset;"
	end
    return data
  end)
end


function uninit()
    
end

function tablelength(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

function update(dt)
  if power.get() > 0 then
    object.setConfigParameter("initPower", power.get())
	object.setConfigParameter("description", string.format("%s Stored Power: ^orange;%s^reset;kw", self.description, power.get()))
    self.isPowered = true
    setAnimation(true)
  else
    self.isPowered = false
    setAnimation(false)
  end
  if power.getState() == true then
    if self.productionTimer > 0 then
      self.productionTimer = math.max(0, self.productionTimer - dt)
	  if self.productionTimer == 0 then
	    if self.isPowered == true then
	      object.setOutputNodeLevel(0, true)
	    else
	      object.setOutputNodeLevel(0, false)
	    end 
		local min = math.min(power.get(), self.outputPower)
        power.send(0, min)
	    self.productionTimer = self.productionTime
	  end
    end
  end
end

function setAnimation(state)
  setMeter("charge", power.get() / power.max(), self.meter.min, self.meter.max, self.meter.width)
  if state == true then 
    animator.setAnimationState("switchState", "on")
  else
    animator.setAnimationState("switchState", "off")
  end
end

function setMeter(tagName, percent, min, max, width)
  local offset = min + math.floor((max - min) * percent)
  local tag = string.format("?crop=0;0;%s;%s", width, offset)
  animator.setGlobalTag(tagName, tag)
end