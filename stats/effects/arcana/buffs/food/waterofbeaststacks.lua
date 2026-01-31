function init()
  self.statName = "arcana_waterofbeaststack"
  self.stacks = status.statusProperty(self.statName, 0) + 1
  status.setStatusProperty(self.statName, self.stacks)
  status.addEphemeralEffect("arcana_waterofbeast")
end
