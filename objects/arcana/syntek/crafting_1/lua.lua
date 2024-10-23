require "/scripts/util.lua"

function init()
  self.buyFactor = config.getParameter("buyFactor", root.assetJson("/merchant.config").defaultBuyFactor)

  object.setInteractive(true)
end

function onInteraction(args)
  local interactData = config.getParameter("interactData")

  interactData.recipes = {}
  local addRecipes = function(items, category)
    for i, item in ipairs(items) do
      interactData.recipes[#interactData.recipes + 1] = generateRecipe(item, category)
    end
  end

  local storeInventory = config.getParameter("storeInventory")
  addRecipes(storeInventory.deeds, "deeds")
  addRecipes(storeInventory.furniture, "furniture")

  -- statically shuffle featured collections
  local featureCycle = math.floor(os.time() / (config.getParameter("rotationTime") * #storeInventory.featured))
  math.randomseed(featureCycle)
  shuffle(storeInventory.featured)
  math.randomseed(util.seedTime())
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
end
