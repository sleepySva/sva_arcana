function init() activeItem.setHoldingItem(false)
end
function uninit()
end
function activate()
  animator.playSound("activate")
  activeItem.interact("scriptPane", "/interface/scripted/arcana_byos/arcana_byos.config")
end