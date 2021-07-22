--[[
This code is protected under a copyright with DMCA. Copyright #845f8969-02c1-4493-af09-37ab22253c76 Do not redistribute, steal, or otherwise use in your code with or without credit, or we will take legal action.
Create By FutaraDragon
]]

require "/scripts/vec2.lua"
require "/scripts/util.lua"

local SyncSkip = 0
local SyncSkipDef = 3

function init()
	self.ownerId = config.getParameter("ownerid",projectile.sourceEntity())
	
	self.SelfOwnerId = config.getParameter("SelfOwnerId", projectile.sourceEntity())

	self.updateActions = config.getParameter("updateActions", {})
  
	self.processing = config.getParameter("processing", "")

	self.approach = vec2.norm(mcontroller.velocity())
	self.positionRecord = vec2.add(mcontroller.position(),mcontroller.velocity())
	self.positionNow = mcontroller.position()
end

function update(dt)
	if SyncSkip <= 0 then
		dt = dt * SyncSkipDef
		SyncSkip = SyncSkipDef
	else
		SyncSkip = SyncSkip - 1
	end
	if mcontroller ~= nil then
		local VelocityMem = mcontroller.velocity()
		if VelocityMem[1] ~= 0 and VelocityMem[2] ~= 0 then
			self.positionRecord = vec2.add(mcontroller.position(),VelocityMem)
		end
		self.positionNow = mcontroller.position()
	end
end

function uninit()
	if world.entityExists(self.SelfOwnerId or self.ownerId) == true and self.positionNow ~= nil then
		world.spawnProjectile("GrandCrossZanaNormalBulletHit" .. math.random(1,2),self.positionNow , nil, world.distance(self.positionRecord, self.positionNow) , false, 
			{
				processing = self.processing
			}
		)
		if world.entityExists(self.ownerId) == true then
			world.sendEntityMessage(self.ownerId, "GrandCrossPlaySound","Hit",world.distance(self.positionNow,world.entityPosition(self.ownerId)))
		end
	end
end
