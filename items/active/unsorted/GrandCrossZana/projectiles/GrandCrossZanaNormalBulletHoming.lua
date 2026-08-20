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
	self.speed = config.getParameter("speed", 140)

	self.lightColor = config.getParameter("lightColor", {0,0,0})
	self.baseColor = config.getParameter("baseColor", {0,0,0})

	self.approach = vec2.norm(mcontroller.velocity())
	self.positionRecord = vec2.add(mcontroller.position(),mcontroller.velocity())
	self.positionNow = mcontroller.position()
	
	self.CombatDamage = config.getParameter("power", 0)
	self.CombatDamageMultiplier = config.getParameter("powerMultiplier", 0)
	
	self.CurrentPosition = nil
	
	self.HomingSearchArea = 30.0
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
		
		local EnemyTarget = SearchEntiryArea("Enemy",self.HomingSearchArea,mcontroller.position(),nil,{LineOfSight = true})
		if EnemyTarget ~= nil and world.entityExists(EnemyTarget) == true then
			self.CurrentPosition = world.entityPosition(EnemyTarget)
			local toDistance = world.magnitude(self.CurrentPosition, mcontroller.position())
			local toTarget = world.distance(self.CurrentPosition, mcontroller.position())
			mcontroller.approachVelocity(vec2.mul(vec2.norm(toTarget), self.speed), 200)
		end
	end
end

function uninit()
	if world.entityExists(self.SelfOwnerId or self.ownerId) == true and self.positionNow ~= nil then
		world.spawnProjectile("GrandCrossZanaNormalBulletHomingHit1",self.positionNow , nil, world.distance(self.positionRecord, self.positionNow) , false, 
			{
				processing = self.processing
			}
		)
		if world.entityExists(self.ownerId) == true then
			world.sendEntityMessage(self.ownerId, "GrandCrossPlaySound","HomingHit",world.distance(self.positionNow,world.entityPosition(self.ownerId)))
		end
	end
end

function SearchEntiryArea(TeamTarget,Radius,Position,TypeTarget,Optional)
	local entityid = 0
	if entity ~= nil then
		entityid = entity.id()
	elseif player ~= nil then
		entityid = player.id()
	end
	local QueryList = world.entityQuery(Position or mcontroller.position(), Radius, {
		includedTypes = TypeTarget or {"npc", "monster", "player"},
		order = "nearest"
	})
	QueryList = util.filter(QueryList, function(EntityId)
		if Optional == nil or Optional.LineOfSight == nil or Optional.LineOfSight ~= false then
			if world.lineTileCollision(Position or mcontroller.position(), world.entityPosition(EntityId)) then
				return false
			end
		end
		
		if Optional ~= nil and Optional.HealthPercentLower ~= nil then
			local EntityHealth = world.entityHealth(EntityId)
			if EntityHealth[1] / EntityHealth[2] >= Optional.HealthPercentLower then
				return false
			end
		end
		
		if Optional ~= nil and Optional.Aggressive ~= nil then
			if world.entityType(EntityId) ~= "player" and world.entityType(EntityId) ~= "projectile" and not world.entityAggressive(EntityId) then
				return false
			end
		end
		
		if TeamTarget == "Enemy" then
			if not world.entityCanDamage(entityid, EntityId) then
			  return false
			end
		elseif TeamTarget == "Ally" then
			if Optional == nil or Optional.SelfLock == nil or Optional.SelfLock ~= true then
				if EntityId == entityid then
					return false
				end
			end
			if world.entityCanDamage(entityid, EntityId) then
			  return false
			end
		end

		return true
	end)
	if Optional ~= nil and Optional.NearestPointerAim == true then
		local AimPosition = Position or mcontroller.position()
		local CurrentDistance = nil
		local CurrentTarget = nil
		if AimPosition ~= nil then
			for _,EntityId in pairs(QueryList) do
				local CalDistance = world.magnitude(AimPosition,world.entityPosition(EntityId))
				if CurrentDistance == nil then
					CurrentDistance = CalDistance
					CurrentTarget = EntityId
				end
				if CalDistance < CurrentDistance then
					CurrentDistance = CalDistance
					CurrentTarget = EntityId
				end
			end
		end
		return CurrentTarget
	end
	if #QueryList >= 1 then
		return QueryList[1]
	else
		return nil
	end
end
