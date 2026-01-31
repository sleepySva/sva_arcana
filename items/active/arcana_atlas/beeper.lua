function init() activeItem.setHoldingItem(false)
end
function uninit()
end
function activate()
  animator.playSound("activate")
  status.setResourcePercentage("health", 0.5)
end