function init()
  activeItem.setHoldingItem(true)
end
function activate()
  animator.playSound("activate")
  activeItem.interact("scriptPane", "/interface/scripted/itemBlacklist/itemBlacklist.config")
end