-- by Darkcraft8
arcana_power = {}
function init()
    storage.maxPower = config.getParameter("maxPower", 404)
    storage.power = storage.power or config.getParameter("initPower", 0)
end

function arcana_power:setPower(value) -- Simply set the power to the value
    if value then
        storage.power = value
    end
end

function arcana_power:addPower(value) -- Simply add the value to the power
    local surplusPower = 0
    if value then
        if storage.power + value > storage.maxPower then
            surplusPower = (storage.power + value) - storage.maxPower
            storage.power = storage.maxPower
        else
            storage.power = storage.power + value
        end
    end
    return surplusPower
end

function arcana_power:removePower(value, removePartial) -- Simply remove/consume the value to the power
    local amountLeft = 0
    if removePartial and storage.power < value then return amountLeft, false end
    if storage.power > 0 then 
        storage.power = storage.power - value
        amountLeft = storage.power
        return amountLeft, true
    else
        amountLeft = storage.power - value
        return amountLeft, false
    end
end

function arcana_power:getPower()
    return storage.power
end

function arcana_power:sendPower(nodeId, power)
    local nodeId = nodeId
    if not nodeId then nodeId = config.getParameter("outputPowerNode", 0) end
    local targetObject = object.getOutputNodeIds(nodeId)
    local targetAmount = arcana_power:getTargetAmount(targetObject)
    if targetAmount <= 0 then return end
    local sentPowerAmount = arcana_power:getPower(targetObject) / targetAmount
    
    for targetEntityId, _ in pairs(targetObject) do
        arcana_power:removePower(sentPowerAmount)
        -- the script is for object, they ALL run server-side meaning that we can use this function to call specific function
        local responce = world.callScriptedEntity(targetEntityId, "arcana_power.addPower", nil, sentPowerAmount )
        if responce then
            arcana_power:addPower(responce)
        end
    end

    return arcana_power:getPower(targetObject)
end

function arcana_power:getIncomingPower(nodeId) -- Get the amount of power produced by object's that are connected to the inputs 
    local nodeId = nodeId
    if not nodeId then nodeId = config.getParameter("inputPowerNode", 0) end
    local targetObject = object.getInputNodeIds(nodeId)
    local targetAmount = arcana_power:getTargetAmount(targetObject)
    if targetAmount <= 0 then return end

    local finalResult = 0
    for targetEntityId, _ in pairs(targetObject) do 
        local responce = world.callScriptedEntity(targetEntityId , "arcana_power.sentPowerAmount")
        if responce then
            finalResult = finalResult + responce
        end
    end

    return finalResult
end

function arcana_power:sentPowerAmount()
    if storage.targetAmount and storage.power then
        if storage.power / storage.targetAmount > 0 then
            return storage.power / storage.targetAmount
        else
            return 0
        end
    else
        return 0
    end
end

function arcana_power:getTargetAmount(nodeIdTable)
    local indexAmount = 0
    for index, _ in pairs(nodeIdTable) do 
        indexAmount = indexAmount + 1
    end
    storage.targetAmount = indexAmount
    return indexAmount
end

function arcana_power:productionAmount()
    return config.getParameter("maxPower", 404)
end

function arcana_power:getTargetPowerProduction(targetEntityId)
    local responce = world.callScriptedEntity(targetEntityId , "arcana_power.productionAmount")
    if responce then
        return responce
    else
        return 0
    end
end