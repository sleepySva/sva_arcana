require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rect.lua"

function init()
  self.list = "scrollArea.collectionList"

  self.iconSize = config.getParameter("iconSize")

  self.currentCollectables = {}
  self.playerCollectables = {}

  populateList()
end

function update(dt)
  if self.collectionName and self.collectionName ~= selected then
    local selected = widget.getSelectedData("collectionTabs")
    if self.collectionName ~= selected then
      populateList()
    else
      for _,collectable in pairs(player.collectables(self.collectionName)) do
        if not self.playerCollectables[collectable] then
          populateList()
          break
        end
      end
    end
  end
end

function populateList(collectionName)
  widget.clearListItems(self.list)
  self.collectionName = widget.getSelectedData("collectionTabs")

  if self.collectionName then
    local collection = root.collection(self.collectionName)
    widget.setText("selectLabel", collection.title);
    widget.setVisible("emptyLabel", false)

    self.currentCollectables = {}

    self.playerCollectables = {}
    for _,collectable in pairs(player.collectables(self.collectionName)) do
      self.playerCollectables[collectable] = true
    end

    local collectables = root.collectables(self.collectionName)
    table.sort(collectables, function(a, b) return a.order < b.order end)
    for _,collectable in pairs(collectables) do
      local item = widget.addListItem(self.list)
      
      if collectable.icon ~= "" then
        local imageSize = rect.size(root.nonEmptyRegion(collectable.icon))
        local scaleDown = math.max(math.ceil(imageSize[1] / self.iconSize[1]), math.ceil(imageSize[2] / self.iconSize[2]))

        if not self.playerCollectables[collectable.name] then
          collectable.icon = string.format("%s?multiply=000000", collectable.icon)
        end
        widget.setImage(string.format("%s.%s.icon", self.list, item), collectable.icon)
        widget.setImageScale(string.format("%s.%s.icon", self.list, item), 1 / scaleDown)
      end
      widget.setText(string.format("%s.%s.index", self.list, item), collectable.order)

      self.currentCollectables[string.format("%s.%s", self.list, item)] = collectable;
    end
  else
    widget.setVisible("emptyLabel", true)
    widget.setText("selectLabel", "Collection")
  end
end

function createTooltip(screenPosition)
  for widgetName, collectable in pairs(self.currentCollectables) do
    if widget.inMember(widgetName, screenPosition) and self.playerCollectables[collectable.name] then
      local tooltip = config.getParameter("tooltipLayout")
      tooltip.title.value = collectable.title
      tooltip.description.value = collectable.description
      return tooltip
    end
  end
end

function selectCollection(index, data)
  populateList()
end