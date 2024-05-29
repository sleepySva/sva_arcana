--By Silver Sokolova
local ini = init or function() end
function init() ini()
  local interface = root.assetJson("/interface/scripted/arcana_updates/arcana_updates_gui.config")
  local currentVersion = interface.version
  if player.introComplete() then
    local yv = player.getProperty("arcana_version")
    if yv == nil then
      player.setProperty("arcana_version", currentVersion)
      yv = currentVersion
    end
    if yv < currentVersion then
      sb.logInfo(string.format("[Arcana] Updating this character from %s to %s!", yv, currentVersion))
      player.interact("scriptPane", interface)
      player.setProperty("arcana_version", currentVersion)
    end
  end
  interface = nil
end