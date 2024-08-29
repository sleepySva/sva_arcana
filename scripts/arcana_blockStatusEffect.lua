--Credit: Deg
require "/scripts/vec2.lua"

function init()
	
end

function update(dt)
	if mcontroller.isColliding() then
		local collisionBody = mcontroller.collisionBody()
		local collisionTiles = collectTiles(collisionBody)
		
		for _, tile in ipairs(collisionTiles) do
			local config = root.materialConfig(tile)
			if config and config.config and config.config.statusEffects then
				status.addEphemeralEffects(config.config.statusEffects)
			end
		end
	end
end

function collectTiles(poly)
	local tiles = {}
	
	for _, pos in ipairs(poly) do
		for x = -1, 1, 1 do
			for y = -1, 1, 1 do
				local testPos = vec2.add(pos, {x, y})
				local material = world.material(testPos, "foreground")
				if material then table.insert(tiles, material) end
			end
		end
	end
	return tiles
end