require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rect.lua"

function init()
end
function update(dt)
end
function level()
  player.interact("scriptPane", "/interface/scripted/arcana_seekerLevel/arcana_seekerLevel.config")
  pane.dismiss()
end
function tech()
  player.interact("scriptPane", "/interface/scripted/techupgrade/techupgradegui.config")
end
function mech()
  player.interact("scriptPane", "/interface/scripted/mechassembly/mechassemblygui.config")
end
function itemBlacklist()
  player.interact("scriptPane", "/interface/scripted/itemBlacklist/itemBlacklist.config")
end
function map()
  player.interact("scriptPane", "/interface/scripted/arcana_galacticAtlas/arcana_galacticAtlas.config")
  pane.dismiss()
end
