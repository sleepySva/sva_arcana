
--[[--
  * distributor.lua
  * Augment status effect
  *
  * Friendlies and same-team monsters and NPCs within a radius from this
  * entity are applied armor/augment status effects, specified by the
  * allowListFile config.
  *
  * Created by Lyrthras#7199 on 01/27/21 9:59 PM
--]]--

--[[--
  === JSON fields ( * = required, - = optional ) ===
  * allowListFile - path: Config file for a list of allowed status effects to distribute.
  - radius        - int:  [def 5] effective distance in blocks from this entity
--]]--


function init()
  script.setUpdateDelta(20)
  self.radius = config.getParameter("radius", 5)
  self.statCategory = config.getParameter("statCategory", "armor")
  self.configFile = root.assetJson(config.getParameter("allowListFile"))

  local vTb, mTb = self.configFile.vanilla or {}, self.configFile.modded or {}
  self.wildcards = self.configFile.wildcards or {}
  self.wildcards.startsWith = self.wildcards.startsWith or {}
  self.wildcards.endsWith = self.wildcards.endsWith or {}

  self.allowed = {}
  for i = 1, #vTb do self.allowed[vTb[i]] = true end
  for i = 1, #mTb do self.allowed[mTb[i]] = true end

  self.queryOptions = {
    withoutEntityId = entity.id(),
    includedTypes = { "npc", "monster", "player" },
    boundMode = "metaboundbox",
  }

  self.rescanCounter = 10
  self.effects = {}
end

--- scan entity for effects to distribute
local function scan(ex, wc)
  local effects = status.getPersistentEffects(self.statCategory)    -- this includes armor stat effects and augments
  local sw, ew = wc.startsWith, wc.endsWith
  local matches = {}
  for i = 1, #effects do
    local itm = effects[i]
    if type(itm) ~= "string" then goto nm end
    if ex[itm] then
      goto m
    else
      for j = 1, #sw do if itm:sub( #sw[j]) == sw[j] then goto m end end
      for j = 1, #ew do if itm:sub(-#ew[j]) == ew[j] then goto m end end
    end
    goto nm
    ::m:: matches[# matches + 1] = itm
    ::nm::
  end
  return matches
end

local function tryApplyEffects(entityId, effects)
  local oDamageTeam = world.entityDamageTeam(entityId)
  if not (oDamageTeam and oDamageTeam.team == entity.damageTeam().team or oDamageTeam.type == "friendly" or oDamageTeam.type == "assistant") then return end   -- if not same team

  for _, name in ipairs(effects) do    -- we don't need speed here so use ipairs :eyes:
    -- this or projectile? hmm
    world.sendEntityMessage(entityId, "applyStatusEffect", name, 4  --[[ < completely random ]], entity.id())
  end
end

function update(dt)
  self.rescanCounter = self.rescanCounter + 1
  if self.rescanCounter > 10 then
    self.rescanCounter = 1
    self.effects = scan(self.allowed, self.wildcards)
  end

  local ids = world.entityQuery(entity.position(), self.radius, self.queryOptions)
  for _, id in ipairs(ids) do
    tryApplyEffects(id, self.effects)
  end
end