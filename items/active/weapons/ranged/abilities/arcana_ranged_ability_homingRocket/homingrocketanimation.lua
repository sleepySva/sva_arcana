function update()
  localAnimator.clearDrawables()

  local targets = animationConfig.animationParameter("targets")
  local drawables = {}
  if targets then
    for _,targetId in ipairs(targets) do
      local position = world.entityPosition(targetId)

      localAnimator.addDrawable({
        image = "/items/active/weapons/ranged/abilities/homingrocket/targetoverlay.png",
        position = world.entityPosition(targetId)
      })
    end
  end
end
