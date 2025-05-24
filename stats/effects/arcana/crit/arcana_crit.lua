function init()
  animator.burstParticleEmitter("name")
  animator.setSoundVolume("crit", 0.6, 0)
  local pitch = math.random(5,7)/10
  animator.setSoundPitch("crit", pitch, 0)
  animator.playSound("crit", 0)
end

function update(dt)
end

function uninit()
end
