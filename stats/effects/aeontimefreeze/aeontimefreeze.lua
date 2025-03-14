function init()
    local elementaltypes=root.assetJson("/damage/elementaltypes.config")
    local buffer={}
    local resists={}

    for _,data in pairs(elementaltypes) do
        if data.resistanceStat then
            buffer[data.resistanceStat]=true
        end
    end

    table.insert(resists,{stat = "protection", amount = 10000.0})
    table.insert(resists,{stat = "powerMultiplier", amount = 0.0})

    for resist,_ in pairs(buffer) do
        table.insert(resists,{stat = resist, amount = 100.0})
    end
    cultistshieldhandler=effect.addStatModifierGroup(resists)
    animator.setParticleEmitterOffsetRegion("numerals", mcontroller.boundBox())
    animator.setParticleEmitterActive("numerals", true)
    effect.setParentDirectives("fade=6a2284=0.4")
    animator.playSound("timefreeze_start")
    animator.playSound("timefreeze_loop", -1)
    animator.setAnimationRate(1)
    if status.isResource("stunned") then
        status.setResource("stunned", math.min(status.resourceMax("stunned"), effect.duration()))
    end
    mcontroller.setVelocity({0, 0})
end

    function update(dt)
        mcontroller.setVelocity({0, 0})
        mcontroller.controlModifiers({
            facingSuppressed = true,
            movementSuppressed = true
        })
    if status.isResource("stunned") then
        status.setResource("stunned", math.min(status.resourceMax("stunned"), effect.duration()))
    end
    end

function uninit()
    effect.removeStatModifierGroup(cultistshieldhandler)
end

function onExpire()
    animator.setAnimationRate(1)
end