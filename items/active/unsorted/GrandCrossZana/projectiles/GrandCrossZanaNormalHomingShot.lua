--[[
This code is protected under a copyright with DMCA. Copyright #845f8969-02c1-4493-af09-37ab22253c76 Do not redistribute, steal, or otherwise use in your code with or without credit, or we will take legal action.
Create By FutaraDragon
]]

require "/scripts/vec2.lua"

function init()
	self.InitData = false
	
	self.InitShotDelay = 0.1
	self.BulletStack = {}

	self.ownerId = config.getParameter("ownerid", projectile.sourceEntity())
	
	self.SelfOwnerId = config.getParameter("SelfOwnerId", nil)
	
	self.lightColor = config.getParameter("lightColor", {0,0,0})
	self.baseColor = config.getParameter("baseColor", {0,0,0})
	
	self.processing = config.getParameter("processing", "")
	
	self.FacingDirection = config.getParameter("FacingDirection", 0)
	
	self.AimPosition = config.getParameter("AimPosition", {0,0})
	self.CombatAttackArea = 2.0
	
	self.CombatDamage = config.getParameter("power", 0)
	self.CombatDamageMultiplier = config.getParameter("powerMultiplier", 0)
	
	mcontroller.applyParameters({collisionEnabled=false})
	
	message.setHandler("projectileIds", projectileIds)
	message.setHandler("setTargetPosition", function(_, _, targetPosition)
		self.targetPosition = targetPosition
	end)
	
	message.setHandler("kill", projectile.die)
	
	self.BulletLightUp = {
		type = "ember",
		fullbright = true,
		destructionAction = "fade",
		destructionTime =  0.5,
		layer = "front",
		position = {0,0},
		size = 0.6, 
		color = self.baseColor,
		fade = 5.0,  
		approach = {2,2},
		initialVelocity = {0,0},
		finalVelocity = {0,0},
		angularVelocity = 0,                                   
		flippable = true,
		timeToLive = 0.1,
		light = self.lightColor,
		variance = {
			size = 0.5,  
			position = {0.2,0.2},
			initialVelocity = {1,1},
			finalVelocity = {5,5}
		}
	}
	self.LightUp = {
		type = "textured",
		animation = "/projectiles/light/glowerlight.png",
		fullbright = true,
		destructionAction = "shrink",
		destructionTime =  0.05,
		layer = "front",
		position = {0,0},
		size = 1.0,  
		fade = 0.5,  
		approach = {2,2},
		initialVelocity = {0,0},
		finalVelocity = {0,0},
		angularVelocity = 0,                                   
		flippable = true,
		timeToLive = 0.1,
		light = self.lightColor,
		variance = {
			size = 0.05,  
			position = {0.1,0.1}
		}
	}
end

function update(dt)
	if mcontroller ~= nil then
		mcontroller.setVelocity({0,0})
		
		if self.InitData == false then
			self.InitData = true

			local toTargetDistance = world.magnitude(mcontroller.position(), self.AimPosition)
			local CalculateRotate = world.distance(self.AimPosition, mcontroller.position())
			local AreaX = ((-self.CombatAttackArea / 2) + ((self.CombatAttackArea) * math.random())) * (math.min(1,(toTargetDistance/10)))
			local AreaY = ((-self.CombatAttackArea / 2) + ((self.CombatAttackArea) * math.random())) * (math.min(1,(toTargetDistance/10)))
			CalculateRotate = vec2.add(CalculateRotate, {AreaX,AreaY})

			world.spawnProjectile("GrandCrossZanaNormalBulletHomingShot" .. math.random(1,2), mcontroller.position(), entity.id(), CalculateRotate, true, 
				{
					processing = self.processing,
					
					timedActions = {
						{
							action = "particle",
							specification = self.LightUp
						}
					}
				}
			)
			
			local BulletObjTimer = {
				Delay = self.InitShotDelay
			}
			
			table.insert(self.BulletStack, BulletObjTimer)
		else
			for Idx,Bullet in pairs(self.BulletStack) do
				if Bullet.Delay <= 0 then
					
					local toTargetDistance = world.magnitude(mcontroller.position(), self.AimPosition)
					local CalculateRotate = world.distance(self.AimPosition, mcontroller.position())
					local AreaX = ((-self.CombatAttackArea / 2) + ((self.CombatAttackArea) * math.random())) * (math.min(1,(toTargetDistance/10)))
					local AreaY = ((-self.CombatAttackArea / 2) + ((self.CombatAttackArea) * math.random())) * (math.min(1,(toTargetDistance/10)))
					CalculateRotate = vec2.add(CalculateRotate, {AreaX,AreaY})
					
					world.spawnProjectile("GrandCrossZanaNormalBulletHoming", mcontroller.position(), entity.id(), CalculateRotate, false, 
						{
							power = self.CombatDamage * self.CombatDamageMultiplier,
							processing = self.processing,
							periodicActions = { 
								{
									action = "particle",
									["time"] = 0.005,
									["repeat"] = true,
									specification = self.BulletLightUp
								}
							},
							ownerid = self.ownerId,
							SelfOwnerId = self.SelfOwnerId or self.ownerId
						}
					)
					
					self.BulletStack[Idx] = nil
				else
					Bullet.Delay = math.max(0,Bullet.Delay - dt)
				end
			end
		end
	end
end

function hit(entityId)
end

function projectileIds()
  return {entity.id()}
end

function setTargetPosition(targetPosition)
  self.targetPosition = targetPosition
end
