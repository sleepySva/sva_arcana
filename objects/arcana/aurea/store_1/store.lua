require "/scripts/util.lua"

function init()
  self.buyFactor = config.getParameter("buyFactor", root.assetJson("/merchant.config").defaultBuyFactor)
  self.itemCount = config.getParameter("itemCount", 2)
  object.setInteractive(true)
end

function onInteraction(args)
  local interactData = config.getParameter("interactData")

  interactData.recipes = {}
  local addRecipes = function(items, category)
    createSeed()
    local shuffled = shuffle(items)
	local selector = {}
	for i = 1, self.itemCount do
	  selector[i] = shuffled[i]
	end
    for i, item in ipairs(selector) do
      interactData.recipes[#interactData.recipes + 1] = generateRecipe(item, category)
    end
  end
  
  local storeInventory = config.getParameter("storeInventory")

  -- statically shuffle featured collections
  shuffle(storeInventory.featured)
  local currentFeature = math.floor(os.time() / config.getParameter("rotationTime")) % #storeInventory.featured + 1
  addRecipes(storeInventory.featured[currentFeature], "featured")

  return { "OpenCraftingInterface", interactData }
end

function generateRecipe(itemName, category)
  return {
    input = { {"money", math.floor(self.buyFactor * (root.itemConfig(itemName).config.price or root.assetJson("/merchant.config").defaultItemPrice))} },
    output = itemName,
    groups = { category }
  }
end

function shuffle(list)
  for i=1,#list do
    local swapIndex = math.random(1,#list)
    list[i], list[swapIndex] = list[swapIndex], list[i]
  end
  return list
end

function createSeed()
  local time = math.floor(os.time() / config.getParameter("rotationTime"))
  math.randomseed(time)
end

