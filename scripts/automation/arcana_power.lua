power = {}

function init()
  power.init()
end

-- Init
function power.init()
  storage.max = config.getParameter("maxPower", 0)
  storage.power = storage.power or config.getParameter("initPower", 0)
  storage.state = storage.state or true
  
  message.setHandler("getState", function(_, _, state)
    if state ~= nil then power.setState(state) end
    return power.getState(state)
  end)
end

-- Sends power to all connected objects for a set node.
function power.send(node, amount)
  local targets = object.getOutputNodeIds(node or 0)
  if not targets or power.tablelength(targets) == 0 then return end
  local dividedPower = math.floor(math.max(0, amount) / power.tablelength(targets))
    
  for target, _ in pairs(targets) do
    power.remove(dividedPower)
    local overflow = world.callScriptedEntity(target, "power.add", dividedPower)
    if overflow then power.add(overflow) end
  end
end

-- Adds power up to the max power amount.
function power.add(power)
  if storage.power + power > storage.max then storage.power = storage.max return storage.power + power - storage.max end
  storage.power = math.max(math.min(storage.max, storage.power + power), 0)
end

-- Removes power to a minimum of 0.
function power.remove(power)
  storage.power = math.max(storage.power - power, 0)
end

-- Sets power up to the max power amount.
function power.set(power)
  storage.power = math.max(math.min(storage.max, power), 0)
end

-- Returns current power amount.
function power.get()
  return storage.power
end

-- Returns current state for button use
function power.getState()
  return storage.state
end

-- Sets current state
function power.setState(s)
  storage.state = s
end

--http://lua-users.org/wiki/SimpleRound, for progress bar completion rounding.
function power.round(num, numDecimalPlaces)
  if num <= 0.97 then return num end
  local mult = 10^(numDecimalPlaces or 0)
  return math.ceil(num * mult + 0.5) / mult
end

--https://stackoverflow.com/questions/2705793/how-to-get-number-of-entries-in-a-lua-table
function power.tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end