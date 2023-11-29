require "/scripts/keybinds.lua"

function init()

end

function uninit()
  tech.setParentDirectives()
  status.removeEphemeralEffect("arcana_status_nobleWalkers")
end

function update(args)
  status.addEphemeralEffect("arcana_status_nobleWalkers", 1)
end
