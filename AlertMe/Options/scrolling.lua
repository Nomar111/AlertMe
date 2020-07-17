dprint(3, "container.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:ShowScrollingText(container)
	dprint(2, "O:ShowcontainerText")
		local db = P.scrolling
	local sliderWidth = 156
	local scrollingGroup = O:AttachGroup(container, _, _, 1, 1, "List")
	-- header
	O:AttachHeader(scrollingGroup, "Scrolling Text Settings")
	-- enable
	O:AttachCheckBox(scrollingGroup, "Enable Scrolling Text", db ,"enabled", 300)
	O:AttachSpacer(scrollingGroup, 10, "small")
	-- buttons
	local buttonGroup = O:AttachGroup(scrollingGroup, _, _, 1, _, "Flow")
	-- show
	local btnShow = O:AttachButton(buttonGroup, "Show frame", 120)
	btnShow:SetCallback("OnClick", function() A:ScrollingTextShow(true) end)
	-- hide
	O:AttachSpacer(buttonGroup, 20)
	local btnHide = O:AttachButton(buttonGroup, "Hide frame", 120)
	btnHide:SetCallback("OnClick", function() A:ScrollingTextHide() end)
	-- reset
	O:AttachSpacer(buttonGroup, 20)
	local btnReset = O:AttachButton(buttonGroup, "Reset position", 120)
	btnReset:SetCallback("OnClick", function() A:ScrollingTextSetPosition(true) end)
	O:AttachSpacer(scrollingGroup, 10, "small")
	-- width
	local width = O:AttachSlider(scrollingGroup, "Set width", db, "width", 300, 1000, 20, false, 317, true)
	O:AttachSpacer(scrollingGroup, _, "small")
	-- fading
	local cbFading = O:AttachCheckBox(scrollingGroup, "Enable fading", db, "fading", 200)
	cbFading:SetCallback("OnValueChanged", function(widget, event, value)
		db["fading"] = value
		A:ScrollingTextInitOrUpdate()
	end)
	O:AttachSpacer(scrollingGroup, 5)
	-- time visible
	O:AttachSlider(scrollingGroup, "Fade after (s)", db, "timeVisible", 1, 30, 1, false, sliderWidth, true)
	O:AttachSpacer(scrollingGroup, 1)
	-- background alpha
	local alpha = O:AttachSlider(scrollingGroup, "Background alpha", db, "alpha", 0, 1, 0.01, true, sliderWidth, true)
	O:AttachSpacer(scrollingGroup, 5)
	-- font size
	O:AttachSlider(scrollingGroup, "Font size", db, "fontSize", 8, 22, 1, false, sliderWidth, true)
	O:AttachSpacer(scrollingGroup, 5)
	-- visible lines
	O:AttachSlider(scrollingGroup, "Visible lines", db, "visibleLines", 1, 12, 1, false, sliderWidth, true)
	O:AttachSpacer(scrollingGroup, 5)
	-- max lines
	O:AttachSlider(scrollingGroup, "Max. lines (history)", db, "maxLines", 25, 500, 25, false, sliderWidth, true)
	-- align
	local list = {[1] = "CENTER", [2] = "LEFT", [3] = "RIGHT"}
	O:AttachDropdown(scrollingGroup, "Alignment", db, "align", list, sliderWidth)
	-- inline docu
	O:AttachLabel(scrollingGroup, " ", GameFontHighlightSmall, nil, 1)
	local text = "Shift + Left Click for moving the frame. Right Click for closing the frame. Mousewheel to scroll through the text."
	O:AttachLabel(scrollingGroup, text, GameFontHighlightSmall, nil, 1)
end
