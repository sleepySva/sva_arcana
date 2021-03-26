require "/scripts/stagehandutil.lua"

function init()
  self.players = {}
  self.music = config.getParameter("music", {})
  self.musicEnabled = false
  stagehand.die()
end

function update(dt)
  for playerId, _ in pairs(self.players) do
    if not world.entityExists(playerId) then
      -- Player died or left the mission
      self.players[playerId] = nil
	  stagehand.die()
    end
  end

  local newPlayers = broadcastAreaQuery({ includedTypes = {"player"} })
  for _, playerId in pairs(newPlayers) do
    if not self.players[playerId] then
      playerEnteredBattle(playerId)
      self.players[playerId] = true
	  stagehand.die()
    end
  end
end

function playerEnteredBattle(playerId)
  if self.musicEnabled then
    world.sendEntityMessage(playerId, "playAltMusic", self.music, config.getParameter("fadeInTime"))
	stagehand.die()
  else
    world.sendEntityMessage(playerId, "playAltMusic", jarray(), config.getParameter("startFadeOutTime"))
	stagehand.die()
  end
end

function startMusic()
  for playerId, _ in pairs(self.players) do
    world.sendEntityMessage(playerId, "playAltMusic", self.music, config.getParameter("fadeInTime"))
	stagehand.die()
  end
end

function stopMusic()
  for playerId, _ in pairs(self.players) do
    world.sendEntityMessage(playerId, "playAltMusic", jarray(), config.getParameter("endFadeOutTime"))
	stagehand.die()
  end
end

function setMusicEnabled(state)
  if self.musicEnabled ~= state then
    if state then
      stagehand.die()
    else
      stagehand.die()
    end
    stagehand.die()
  end
end
