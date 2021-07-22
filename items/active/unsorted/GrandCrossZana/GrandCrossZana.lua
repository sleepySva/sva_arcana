--[[
This code is protected under a copyright with DMCA. Copyright #845f8969-02c1-4493-af09-37ab22253c76 Do not redistribute, steal, or otherwise use in your code with or without credit, or we will take legal action.
Create By FutaraDragon
]]

require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/status.lua"
require "/scripts/activeitem/stances.lua"

local ShotTime = 0.0
local ShotTimeDef = 0.35

local BulletSubCountCal = 0
local BulletSubCount = 4

local BulletSubCountStack = 0
local BulletSubCountStackSetShot = 0
local BulletSubCountStackSwitch = 1

local BulletSubDelay = 0.0
local BulletSubDelayDef = 0.10

local BaseDamage = 10

local EnergyUse = 2
	
local CombatAttackArea = 0.2
local CombatAttackHomingArea = 10.0

local FirstInit = false
local ReadySound = false

local CodeExtended = nil

function try(f, catch_f)
	local status, exception = pcall(f)
	if not status then
		catch_f(exception)
	end
end

function prequire(...)
    local status, lib = pcall(require, ...)
    if(status) then return lib end
    return nil
end

function InitExtendedCode()
	local Versioning = root.assetJson("/versioning.config")
	if Versioning["FutaraDragonRace"] ~= nil then
		CodeExtended = prequire("/coopmod/items/active/weapons/gunblade/GrandCrossZana/GrandCrossZana_Extended.lua")
	end
end

function init()
	InitExtendedCode()
	
	if ReadySound == false then
		ReadySound = true
		animator.playSound("WeaponReady", 0)
	end
	
	activeItem.setCursor("/cursors/reticle0.cursor")
	self.Setting = config.getParameter("skillSetting")
	
	message.setHandler("GrandCrossPlaySound", function(_, _, SoundName, Position)
		animator.playSound(SoundName, 0)
		animator.setSoundPosition(SoundName, Position)
	end)
	
	initStances()
	
	activeItem.setHoldingItem(true)
end

function update(dt, fireMode, shiftHeld, args)
	if mcontroller ~= nil then
		setStance("fire")
		if FirstInit == false then
			FirstInit = true
			animator.setAnimationRate(1.0)
			animator.setAnimationState("Gun","firemain",true)
			animator.playSound("Shoot", 0)
		end
		if ShotTime <= 0 then
			if fireMode == "primary" then
				if status.resource("energy") >= EnergyUse then
					status.consumeResource("energy", EnergyUse)
			
					ShotTime = ShotTimeDef
					
					local BasePosition = vec2.add(mcontroller.position(),activeItem.handPosition({2.5,0.7}))
					local AimPosition = activeItem.ownerAimPosition()
					local CalculateRotate = world.distance(AimPosition, BasePosition)
					local toTargetDistance = world.magnitude(BasePosition, AimPosition)
					local AreaX = ((-CombatAttackArea / 2) + ((CombatAttackArea) * math.random())) * (math.min(1,(toTargetDistance/10)))
					local AreaY = ((-CombatAttackArea / 2) + ((CombatAttackArea) * math.random())) * (math.min(1,(toTargetDistance/10)))
					CalculateRotate = vec2.add(CalculateRotate, {AreaX,AreaY})
					local TargetCurrentPosition = vec2.add(AimPosition, {AreaX,AreaY})
					
					world.spawnProjectile("GrandCrossZanaNormalShot",BasePosition,activeItem.ownerEntityId(),CalculateRotate,true, 
						{
							processing = "?scale=0.25",
							power = BaseDamage,
							powerMultiplier = status.stat("powerMultiplier"),
							baseColor = {255,126,0},
							lightColor = {255,126,0},
							AimPosition = TargetCurrentPosition,
							ownerid = activeItem.ownerEntityId(),
							SelfOwnerId = activeItem.ownerEntityId()
						}
					)
					
					BulletSubCountCal = BulletSubCountCal + 1
			
					animator.setAnimationRate(1.0)
					animator.setAnimationState("Gun","firemain",true)
					animator.playSound("Shoot", 0)
				end
			end
		else
			animator.setAnimationRate(1.0)
			animator.setAnimationState("Gun","idle",true)
			ShotTime = math.max(0,ShotTime - dt)
		end
		
		if BulletSubCountCal >= BulletSubCount then
			BulletSubCountCal = BulletSubCountCal - BulletSubCount
			if BulletSubCountStack == 0 then
				BulletSubDelay = BulletSubDelayDef
			end
			BulletSubCountStack = BulletSubCountStack + 1
		end
		
		if BulletSubDelay <= 0 then 
			if BulletSubCountStack > 0 and BulletSubCountStackSetShot <= 0 then
				BulletSubCountStackSetShot = BulletSubCountStackSetShot + 2
				BulletSubCountStack = BulletSubCountStack - 1
				if BulletSubCountStackSwitch == 1 then
					BulletSubCountStackSwitch = 2
				elseif BulletSubCountStackSwitch == 2 then
					BulletSubCountStackSwitch = 1
				end
			end
			
			if BulletSubCountStackSetShot > 0 then
				local BasePosition = nil
				
				if BulletSubCountStackSwitch == 1 then
					BasePosition = vec2.add(mcontroller.position(),activeItem.handPosition({1.0,1.2}))
				elseif BulletSubCountStackSwitch == 2 then
					BasePosition = vec2.add(mcontroller.position(),activeItem.handPosition({1.0,0.1}))
				end
				
				local AimPosition = activeItem.ownerAimPosition()
				local CalculateRotate = world.distance(AimPosition, BasePosition)
				local toTargetDistance = world.magnitude(BasePosition, AimPosition)
				local AreaX = ((-CombatAttackHomingArea / 2) + ((CombatAttackHomingArea) * math.random())) * (math.min(1,(toTargetDistance/10)))
				local AreaY = ((-CombatAttackHomingArea / 2) + ((CombatAttackHomingArea) * math.random())) * (math.min(1,(toTargetDistance/10)))
				CalculateRotate = vec2.add(CalculateRotate, {AreaX,AreaY})
				local TargetCurrentPosition = vec2.add(AimPosition, {AreaX,AreaY})
				
				world.spawnProjectile("GrandCrossZanaNormalHomingShot",BasePosition,activeItem.ownerEntityId(),CalculateRotate,true, 
					{
						processing = "?scale=0.25",
						power = BaseDamage / 2,
						powerMultiplier = status.stat("powerMultiplier"),
						baseColor = {0,168,255},
						lightColor = {0,168,255},
						AimPosition = TargetCurrentPosition,
						ownerid = activeItem.ownerEntityId(),
						SelfOwnerId = activeItem.ownerEntityId()
					}
				)
				
				BulletSubDelay = BulletSubDelayDef
		
				animator.setAnimationRate(1.0)
				animator.setAnimationState("Gun","firemain",true)
				animator.playSound("HomingShoot", 0)
				
				BulletSubCountStackSetShot = BulletSubCountStackSetShot - 1
			end
		else
			BulletSubDelay = math.max(0,BulletSubDelay - dt)
		end
		
		updateStance(dt)
	end
end

function uninit()

end