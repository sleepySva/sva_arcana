function init()
  animator.setParticleEmitterOffsetRegion("numerals", mcontroller.boundBox())
  animator.setParticleEmitterActive("numerals", true)
  effect.setParentDirectives("fade=820600=0.7")
  animator.setAnimationRate(1)
  effect.addStatModifierGroup({
    {stat = "protection", amount = 0.5}
  })

  if status.isResource("stunned") then
    status.setResource("stunned", math.max(status.resource("stunned"), effect.duration()))
  end

  mcontroller.setVelocity({0, 0})
end

function update(dt)
  mcontroller.setVelocity({0, 0})
  mcontroller.controlModifiers({
      facingSuppressed = true,
      movementSuppressed = true
    })
end

function onExpire()
  animator.setAnimationRate(1)
end
