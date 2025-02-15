require "/scripts/util.lua"
require "/scripts/status.lua"

function init()
  script.setUpdateDelta(0)
  addVisualEffect()
end

function update(dt)
end

function uninit()
  removeVisualEffect()
end

function addVisualEffect()
  animator.setAnimationState("shield", "on")
end

function removeVisualEffect()
  animator.setAnimationState("shield", "off")
  effect.setParentDirectives("")
end
