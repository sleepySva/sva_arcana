require "/interface/scripted/xrc_arcana_bag/LAJ_slot.lua"

function init()
  s = config.getParameter("bagSfx","/assetmissing.wav")
  widget.playSound(s)
  bagType = config.getParameter("bagType",0)
  ish, osh = false, false
  ii, oi = root.assetJson("/interface/scripted/xrc_arcana_bag/i.json"), root.assetJson("/interface/scripted/xrc_arcana_bag/o.json")
  local h = config.getParameter("grid",{7,76,18,5,7})
  slots = config.getParameter("slots",20)
  if config.getParameter("a") then title = config.getParameter("bagTitles") h[2]=h[2]+config.getParameter("multiBagOffset",5) end
    for i = 1, slots+2 do
    widget.setPosition(string.format("_%s",i), {h[1],h[2]})
	h[1]=h[1]+h[3]
	    if i == h[4] then
	    h[1]=7
	    h[2]=h[2]-h[3]
	    h[4]=h[4]+6
	end
    end

  local tabData = config.getParameter("tabData")
  if tabData then
    for i = 0, tabData[3] do
      local tab = string.format("tab%s",i)
      local tabImage = string.format("/interface/scripted/xrc_arcana_bag/i%s.png",i)
      widget.setPosition(tab,tabData[1])
      tabData[1][1] = tabData[1][1] + tabData[2]
      widget.setButtonImages(tab,{hover=tabImage,pressed=tabImage,base=tabImage})
      widget.setData(tab,i)
    end
  end

  updateShift()
  init2(bagType)
end

function init2(b)
  bagType = b
  AI = root.assetJson(string.format("/arcana_bags.config:%s",b)) or {"a","a"}
  if player.getProperty("arcana_bag_"..bagType) == nil then player.setProperty("arcana_bag_"..bagType,{}) end

  for i = 1, slots do widget.setItemSlotItem(string.format("_%s",i), player.getProperty("arcana_bag_"..bagType)["_"..i] or nil) end
end
function changeTab(_,a) widget.setText("title",string.format("^#ff0,shadow;%s",title[a+1])) init2(a) end
function setBagSlot(data,key)
  local pos = player.getProperty(string.format("arcana_bag_%s",bagType))
  pos[key] = data
  player.setProperty(string.format("arcana_bag_%s",bagType), pos)
end

function updateShift()
  ii, oi = root.assetJson("/interface/scripted/xrc_arcana_bag/i.json"), root.assetJson("/interface/scripted/xrc_arcana_bag/o.json")
  local newI = ii newI.parameters.inventoryIcon = ish and newI.parameters.inventoryIcon.."?brightness=-30" or newI.parameters.inventoryIcon widget.setItemSlotItem("_"..slots+1,newI)
  local newO = oi newO.parameters.inventoryIcon = osh and newO.parameters.inventoryIcon.."?brightness=-30" or newO.parameters.inventoryIcon widget.setItemSlotItem("_"..slots+2,newO)
end

function update(dt)
	if player.swapSlotItem() then
		local s = player.swapSlotItem()
		if has_value() then
			for i = 1, slots do if player.swapSlotItem() and (widget.itemSlotItem("_"..i) == nil) then leftClickSlot("_"..i,s) return end end
		end
	end
end

function uninit() widget.playSound(s) end
function i() ish = not ish updateShift() end
function o() osh = not osh script.setUpdateDelta(osh and 1 or 0) updateShift() end
