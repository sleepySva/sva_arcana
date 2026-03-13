function init()
  self.blinkOut = config.getParameter("blinkOut")
  self.blinkIn = config.getParameter("blinkIn")

  if self.blinkOut then
    animator.setAnimationState("blink", "blinkout")
    effect.setParentDirectives("?multiply=ffffff00")
    animator.playSound("activate")
  elseif self.blinkIn then
    animator.setAnimationState("blink", "blinkin")
  end
end

function update(dt)
  if animator.animationState("blink") == "none" then
    if self.blinkOut and self.blinkIn then
      effect.setParentDirectives("")
      animator.setAnimationState("blink", "blinkin")
    else
      effect.expire()
    end
  end
end

function uninit()
end
