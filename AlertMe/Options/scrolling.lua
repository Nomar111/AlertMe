dprint(3, "container.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:ShowScrollingText(container)
	dprint(2, "O:ShowcontainerText")
	local db = P.scrolling
	local sliderWidth = 190
	local scrollingGroup = O:AttachGroup(container, _, _, 1, 1, "List")

	-- header
	O:AttachHeader(scrollingGroup, "Scrolling Text Settings")

	-- enable
	O:AttachCheckBox(scrollingGroup, "Enable Scrolling Text", db ,"enabled", 300)
	O:AttachSpacer(scrollingGroup, _, "small")

	-- buttons
	local buttonGroup = O:AttachGroup(scrollingGroup, _, _, 1)
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
	O:AttachSpacer(scrollingGroup, _, "small")

	-- width
	local width = O:AttachSlider(scrollingGroup, "Set width", db, "width", 300, 1000, 20, false, 400, true)
	O:AttachSpacer(scrollingGroup, _, "small")

	-- fading
	local fadingGroup = O:AttachGroup(scrollingGroup, _, _, 1)
	local cbFading = O:AttachCheckBox(fadingGroup, "Enable fading", db, "fading", sliderWidth)
	cbFading:SetCallback("OnValueChanged", function(widget, event, value)
		db["fading"] = value
		A:ScrollingTextInitOrUpdate()
	end)
	O:AttachSpacer(fadingGroup, 20)
	-- time visible
	O:AttachSlider(fadingGroup, "Fade after (s)", db, "timeVisible", 1, 30, 1, false, sliderWidth, true)
	O:AttachSpacer(scrollingGroup, _, "small")

	-- font size
	local alphaGroup = O:AttachGroup(scrollingGroup, _, _, 1)
	O:AttachSlider(alphaGroup, "Font size", db, "fontSize", 8, 22, 1, false, sliderWidth, true)
	O:AttachSpacer(alphaGroup, 20)
	-- background alpha
	O:AttachSlider(alphaGroup, "Background alpha", db, "alpha", 0, 1, 0.01, true, sliderWidth, true)
	O:AttachSpacer(scrollingGroup, _, "small")

	local linesGroup = O:AttachGroup(scrollingGroup, _, _, 1)
	-- visible lines
	O:AttachSlider(linesGroup, "Visible lines", db, "visibleLines", 1, 12, 1, false, sliderWidth, true)
	O:AttachSpacer(linesGroup, 20)
	-- max lines
	O:AttachSlider(linesGroup, "Max. lines (history)", db, "maxLines", 25, 500, 25, false, sliderWidth, true)
	O:AttachSpacer(scrollingGroup, _, "small")

	-- align
	local list = {[1] = "CENTER", [2] = "LEFT", [3] = "RIGHT"}
	local ddAlign = O:AttachDropdown(scrollingGroup, "Alignment", db, "align", list, sliderWidth)
	ddAlign:SetCallback("OnValueChanged", function(_, _, value)
		db["align"] = value
		A:ScrollingTextInitOrUpdate()
	end)
	O:AttachSpacer(scrollingGroup, _, "large")
	O:AttachSpacer(scrollingGroup, _, "large")

	-- inline docu
	local text1 = "Shift + Left-Click for moving the frame."
	local text2 = "Right-Click for closing the frame."
	local text3 = "Mousewheel to scroll through the text."
	O:AttachLabel(scrollingGroup, text1, GameFontHighlight)
	O:AttachSpacer(scrollingGroup, _, "small")
	O:AttachLabel(scrollingGroup, text2, GameFontHighlight)
	O:AttachSpacer(scrollingGroup, _, "small")
	O:AttachLabel(scrollingGroup, text3, GameFontHighlight)
	O:AttachSpacer(scrollingGroup, _, "small")
end
