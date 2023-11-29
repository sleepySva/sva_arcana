require "/scripts/util.lua"

function init()
  self.tech = config.getParameter("tech")
  self.swingTime = 0.2
  activeItem.setArmAngle(-math.pi / 2)
end

function update(dt, fireMode, shiftHeld)
  updateAim()

  if not self.swingTimer and fireMode == "primary" and player then
    self.swingTimer = self.swingTime
  end

  if self.swingTimer then
    self.swingTimer = math.max(0, self.swingTimer - dt)

    activeItem.setArmAngle((-math.pi / 2) * (self.swingTimer / self.swingTime))

    if self.swingTimer == 0 then
      learnBlueprint()
    end
  end
end

function learnBlueprint()

  if not contains(player.enabledTechs(), self.tech) then 
      player.makeTechAvailable(self.tech)
	  player.enableTech(self.tech)
	  player.radioMessage("arcana_radiomessage_tech_new", 0)
	  animator.playSound("learnBlueprint")
  else
      player.radioMessage("arcana_radiomessage_tech_duplicate", 0)
  end

end

function updateAim()
  self.aimAngle, self.aimDirection = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
  activeItem.setFacingDirection(self.aimDirection)
end
