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
  if not config.getParameter("hideBorder") then effect.setParentDirectives("border=1;f1af25;00000000") end
  animator.setAnimationState("shield", "on")
end

function removeVisualEffect()
  animator.setAnimationState("shield", "off")
  effect.setParentDirectives("")
end
