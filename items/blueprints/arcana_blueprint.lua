require "/scripts/util.lua"

function init()
  self.recipes = config.getParameter("recipes")
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
  
  for i, recipe in ipairs(self.recipes)
  do
	  if not player.blueprintKnown(recipe) then 
		  player.giveBlueprint(recipe)
	  end
	  animator.playSound("learnBlueprint")
	  item.consume(1)
  end
  
end

function updateAim()
  self.aimAngle, self.aimDirection = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
  activeItem.setFacingDirection(self.aimDirection)
end
