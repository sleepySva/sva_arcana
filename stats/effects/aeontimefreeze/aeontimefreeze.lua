function init()
  animator.setParticleEmitterOffsetRegion("numerals", mcontroller.boundBox())
  animator.setParticleEmitterActive("numerals", true)
  effect.setParentDirectives("fade=6a2284=0.4")
  animator.playSound("timefreeze_start")
  animator.playSound("timefreeze_loop", -1)
  animator.setAnimationRate(1)
  effect.addStatModifierGroup({
    {stat = "protection", amount = 999999},
    {stat = "fireStatusImmunity", amount = 1},
    {stat = "iceStatusImmunity", amount = 1},
    {stat = "electricStatusImmunity", amount = 1},
    {stat = "poisonStatusImmunity", amount = 1},
	{stat = "physicalResistance", amount = 999999},
	{stat = "fireResistance", amount = 999999},
	{stat = "iceResistance", amount = 999999},
	{stat = "electricResistance", amount = 999999},
	{stat = "poisonResistance", amount = 999999},
    {stat = "powerMultiplier", effectiveMultiplier = 0}
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
