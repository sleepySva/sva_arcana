require "/scripts/keybinds.lua"

function init()

end

function uninit()
  tech.setParentDirectives()
  status.removeEphemeralEffect("arcana_status_jungleVest")
end

function update(args)
  status.addEphemeralEffect("arcana_status_jungleVest", 1)
end
