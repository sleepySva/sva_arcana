require "/interface/scripted/xrc_arcana_bag/LAJ_slot.lua"

function init()
    s = config.getParameter("bagSfx","/assetmissing.wav")
    widget.playSound(s)
    bagType = config.getParameter("bagType",0)
    local h = config.getParameter("grid",{7,76,18,5,7})
    slots = config.getParameter("slots",20)

    if config.getParameter("bagTitles") then
	title = config.getParameter("bagTitles")
	h[2]=h[2]+config.getParameter("multiBagOffset",5)
        widget.setText("title","^#ff0,shadow;"..title[bagType+1])
    end

    for n = 1, slots do
    widget.setPosition("_"..n, {h[1],h[2]})
	h[1]=h[1]+h[3]
	    if n == h[4] then
	    h[1]=7
	    h[2]=h[2]-h[3]
	    h[4]=h[4]+5
	end
    end
  init2(bagType)
end

function init2(b)
  bagType = b
  AI = root.assetJson("/arcana_bags.config:"..b) or {"a","a"}
  if status.statusProperty("arcana_bag_"..bagType) == nil then status.setStatusProperty("arcana_bag_"..bagType,{}) end

  for foo = 1, slots do
    widget.setItemSlotItem("_"..foo, status.statusProperty("arcana_bag_"..bagType)["_"..foo] or nil)
  end
end
function changeTab(_,a) widget.setText("title","^#ff0,shadow;"..title[a+1]) init2(a) end
function setBagSlot(data,key)
local pos = status.statusProperty("arcana_bag_"..bagType)
pos[key] = data
status.setStatusProperty("arcana_bag_"..bagType, pos)
end

function uninit() widget.playSound(s) end