require "/scripts/util.lua"

function init()
  local configPath = "/interface/scripted/arcana_musicbox/music.config"
  self.songs = root.assetJson(configPath).music
  self.list = "songs.list"
  self.selected = ""
  self.isPlaying = false
  populateList()
end

function update(dt)

end

function populateList()
  widget.clearListItems(self.list)

  for _, song in pairs(self.songs) do
    local item = widget.addListItem(self.list)
	local songName = string.format("/music/%s.ogg", song.filename)
    widget.setText(string.format("%s.%s.songName", self.list, item), song.name)
	widget.setData(string.format("%s.%s", self.list, item), songName)
  end
end

function play()
  if self.selected ~= "" then
    world.sendEntityMessage(player.id(), "playAltMusic", {self.selected}, 1)
	self.isPlaying = true
  end
end

function stop()
  world.sendEntityMessage(player.id(), "stopAltMusic")
  self.isPlaying = false
end

function select()
  local selected = widget.getListSelected(self.list)
  self.selected = widget.getData(string.format("%s.%s", self.list, selected))
end