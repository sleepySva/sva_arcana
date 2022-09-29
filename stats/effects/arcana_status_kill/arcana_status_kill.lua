function init()
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives("fade=FF8800=0.05")

  script.setUpdateDelta(5)
end

function update(dt)
end

function onExpire()
  status.setResource("health", 0)
end
