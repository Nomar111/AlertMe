dprint(3, "container.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:ShowScrollingText(container)
	dprint(2, "O:ShowcontainerText")
	local db = P.scrolling
	local sliderWidth = 190
	-- local function
	local function updateScrolling()
		A:UpdateScrolling()
	end
	local function toggleInteractive()
		A:ToggleScrollingInteractive()
	end

	-- header
	O.AttachHeader(container, "Scrolling Text Settings")

	-- enable
	local enableGroup = O.AttachGroup(container, "simple", _, {fullWidth = true})
	O.AttachCheckBox(enableGroup, "Enable Scrolling Text", db ,"enabled", 170)
	O.AttachCheckBox(enableGroup, "Movable", db ,"interactive", 250, toggleInteractive)
	O.AttachSpacer(container, _, "small")

	-- buttons
	local buttonGroup = O.AttachGroup(container, "simple", _, {fullWidth = true})
	local btnShow = O.AttachButton(buttonGroup, "Show frame", 120)
	btnShow:SetCallback("OnClick", function() A:ShowScrolling(true) end)
	O.AttachSpacer(buttonGroup, 20)
	local btnHide = O.AttachButton(buttonGroup, "Hide frame", 120)
	btnHide:SetCallback("OnClick", function() A:HideScrolling() end)
	O.AttachSpacer(buttonGroup, 20)
	local btnReset = O.AttachButton(buttonGroup, "Reset position", 120)
	btnReset:SetCallback("OnClick", function() A:SetScrollingPosition(true) end)
	O.AttachSpacer(container, _, "small")

	-- width
	local width = O.AttachSlider(container, "Set width", db, "width", 300, 1000, 20, false, 400, updateScrolling)
	O.AttachSpacer(container, _, "small")

	-- fading
	local fadingGroup = O.AttachGroup(container, "simple", _, {fullWidth = true})
	local cbFading = O.AttachCheckBox(fadingGroup, "Enable fading", db, "fading", sliderWidth, updateScrolling)
	O.AttachSpacer(fadingGroup, 20)
	-- time visible
	O.AttachSlider(fadingGroup, "Fade after (s)", db, "timeVisible", 1, 30, 1, false, sliderWidth, updateScrolling)
	O.AttachSpacer(container, _, "small")

	-- font size
	local alphaGroup = O.AttachGroup(container, "simple", _, {fullWidth = true})
	O.AttachSlider(alphaGroup, "Font size", db, "fontSize", 8, 22, 1, false, sliderWidth, updateScrolling)
	O.AttachSpacer(alphaGroup, 20)
	-- background alpha
	O.AttachSlider(alphaGroup, "Background alpha", db, "alpha", 0, 1, 0.01, true, sliderWidth, updateScrolling)
	O.AttachSpacer(container, _, "small")

	local linesGroup = O.AttachGroup(container, "simple", _, {fullWidth = true})
	-- visible lines
	O.AttachSlider(linesGroup, "Visible lines", db, "visibleLines", 1, 12, 1, false, sliderWidth, updateScrolling)
	O.AttachSpacer(linesGroup, 20)
	-- max lines
	O.AttachSlider(linesGroup, "Max. lines (history)", db, "maxLines", 25, 500, 25, false, sliderWidth, updateScrolling)
	O.AttachSpacer(container, _, "small")

	-- align
	local list = {[1] = "CENTER", [2] = "LEFT", [3] = "RIGHT"}
	local ddAlign = O.AttachDropdown(container, "Alignment", db, "align", list, sliderWidth, updateScrolling)
	O.AttachSpacer(container, _, "large")

	-- inline docu
	local text1 = "Left-Click for moving the frame (if set to movable)."
	local text2 = "Right-Click for closing the frame (if set to movable)."
	local text3 = "Mousewheel to scroll through the text."
	O.AttachLabel(container, text1, GameFontHighlight)
	O.AttachSpacer(container, _, "small")
	O.AttachLabel(container, text2, GameFontHighlight)
	O.AttachSpacer(container, _, "small")
	O.AttachLabel(container, text3, GameFontHighlight)
	O.AttachSpacer(container, _, "small")
end
