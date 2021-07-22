--[[
This code is protected under a copyright with DMCA. Copyright #845f8969-02c1-4493-af09-37ab22253c76 Do not redistribute, steal, or otherwise use in your code with or without credit, or we will take legal action.
Create By FutaraDragon
]]

require "/scripts/vec2.lua"

function init()
	self.ownerId = projectile.sourceEntity()
	
	self.timedActions = config.getParameter("timedActions", {})
  
	mcontroller.applyParameters({collisionEnabled=false})
	
	self.Position = mcontroller.position()
	self.Rotation = mcontroller.rotation()
	
	message.setHandler("projectileIds", projectileIds)
	
	message.setHandler("kill", projectile.die)
end

function update(dt)
	mcontroller.setVelocity({0,0})
end

function hit(entityId)
end

function projectileIds()
  return {entity.id()}
end
