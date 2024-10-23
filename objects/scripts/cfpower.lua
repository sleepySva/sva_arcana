--https://github.com/Emmaker/CommunityFramework/blob/main/scripts/cfpower.lua
require "/scripts/util.lua"
cfpower = {}

function init()
  storage.maxPower = config.getParameter("maxPower", 0)
  storage.voltage = config.getParameter("voltage", 0)
  storage.power = storage.power or config.getParameter("startPower", 0)

  message.setHandler("cfpower", function(_, _, message)
    if message.voltage and message.voltage > storage.voltage then
      storage.power = 0
      message.power = 0
    end

    change = cfpower.createPower(message.power)
    if message.alternating then
      message.power = message.power - change
      message.voltage = storage.voltage
    else
      message.power = 0
      message.voltage = 0
    end

    return message
  end)
end

-- int cfpower.getMaxPower()
function cfpower.getMaxPower()
  return storage.maxPower
end

-- void cfpower.setMaxPower(int power)
function cfpower.setMaxPower(power)
  storage.maxPower = power
  cfpower.setPower(storage.power)
end

-- int cfpower.getPower()
function cfpower.getPower()
  return storage.power
end

-- int cfpower.setPower(int power)
function cfpower.setPower(power)
  pPower = storage.power
  storage.power = util.clamp(power, 0, storage.maxPower)

  return storage.power - pPower
end

-- int cfpower.createPower(int power)
function cfpower.createPower(power)
  return cfpower.setPower(storage.power + power)
end

-- bool cfpower.consumePower(int power)
function cfpower.consumePower(power)
  if storage.power >= power then
    cfpower.setPower(storage.power - power)
    return storage.power
  end

  return storage.power - power
end

-- int, int cfpower.pushPower(int nodeID, int power, [bool alternating], [int voltage])
function cfpower.pushPower(nodeID, power, alternating, voltage)
  local outputTable = object.getOutputNodeIds(nodeID)
  local outputTableSize = util.tableSize(outputTable)
  if outputTableSize < 1 or storage.power < power then
    return 0
  end

  power = power / outputTableSize
  local successes = 0

  for i, _ in pairs(outputTable) do
    local message = {
      power = power,
      voltage = voltage or storage.voltage,
      alternating = alternating or false
    }

    cfpower.consumePower(power)
    promise = world.sendEntityMessage(i, "cfpower", message)

    while not promise do end
    if promise:result() and type(promise:result()) == "table" then
      message = promise:result()
      if message.voltage and message.voltage > storage.voltage then
        storage.power = 0
        object.setOutputNodeLevel(nodeID, false)
        return -1
      end

      cfpower.createPower(promise:result().power)
      object.setOutputNodeLevel(nodeID, true)
      successes = successes + 1
    else
      cfpower.createPower(power)
      object.setOutputNodeLevel(nodeID, false)
    end
  end

  return successes
end