local acinit = init or function() end
local acupdate = update or function() end

function init()
  acinit()
end

function seekerleveleffect()
  local effect = "arcana_status_seekerlevel"
  local seekerlevel = player.currency("arcana_seekerlevel")
  status.removeEphemeralEffect(effect)
  if seekerlevel > 0 then status.addEphemeralEffect(effect,seekerlevel) end
end

function update(dt)
  acupdate(dt)
  seekerleveleffect()
end