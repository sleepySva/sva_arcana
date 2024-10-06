function init() activeItem.setHoldingItem(false)
end
function uninit()
end
function activate()
  animator.playSound("activate")
  activeItem.interact("scriptPane", "/interface/scripted/arcana_books/arcana_guideBook.config")
end