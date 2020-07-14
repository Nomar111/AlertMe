dprint(3, "container.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:ShowScrollingText(container)
	dprint(2, "O:ShowcontainerText")
	-- header
	O:AttachHeader(container, "Scrolling Text Settings")
	local db = P.scrolling
	-- enable
	O:AttachCheckBox(container, "Enable Scrolling Text", db ,"enabled", 600)
	-- show
	local btnShow = O:AttachButton(container, "Show frame", 120)
	btnShow:SetCallback("OnClick", function() A:ScrollingTextShow(true) end)
	-- hide
	O:AttachSpacer(container, 10)
	local btnHide = O:AttachButton(container, "Hide frame", 120)
	btnHide:SetCallback("OnClick", function() A:ScrollingTextHide() end)
	-- reset
	O:AttachSpacer(container, 10)
	local btnReset = O:AttachButton(container, "Reset position", 120)
	btnReset:SetCallback("OnClick", function() A:ScrollingTextSetPosition(true) end)
	O:AttachSpacer(container, 50)
	-- width
	local width = O:AttachSlider(container, "Set width", db, "width", 300, 1000, 20, false, 317, true)
	O:AttachSpacer(container, 200)
	local sliderWidth = 156
	-- background alpha
	local alpha = O:AttachSlider(container, "Background alpha", db, "alpha", 0, 1, 0.01, true, sliderWidth, true)
	O:AttachSpacer(container, 5)
	-- font size
	O:AttachSlider(container, "Font size", db, "fontSize", 8, 22, 1, false, sliderWidth, true)
	O:AttachSpacer(container, 5)
	-- visible lines
	O:AttachSlider(container, "Visible lines", db, "visibleLines", 1, 12, 1, false, sliderWidth, true)
	O:AttachSpacer(container, 5)
	-- max lines
	O:AttachSlider(container, "Max. lines (history)", db, "maxLines", 25, 500, 25, false, sliderWidth, true)
	-- fading
	local cbFading = O:AttachCheckBox(container, "Enable fading", db, "fading", sliderWidth)
	cbFading:SetCallback("OnValueChanged", function(widget, event, value)
		db["fading"] = value
		A:ScrollingTextInitOrUpdate()
	end)
	O:AttachSpacer(container, 5)
	-- time visible
	O:AttachSlider(container, "Fade after (s)", db, "timeVisible", 1, 30, 1, false, sliderWidth, true)
	O:AttachSpacer(container, 250)
	-- align
	local list = {[1] = "CENTER", [2] = "LEFT", [3] = "RIGHT"}
	O:AttachDropdown(container, "Alignment", db, "align", list, sliderWidth)
	-- inline docu
	O:AttachLabel(container, " ", GameFontHighlightSmall, nil, 1)
	local text = "Shift + Left Click for moving the frame. Right Click for closing the frame. Mousewheel to scroll through the text."
	O:AttachLabel(container, text, GameFontHighlightSmall, nil, 1)
end
