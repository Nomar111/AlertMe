-- get engine environment
local A, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:ShowScrollingText(container)
	local db = P.scrolling
	local sliderWidth = 190
	-- local function
	local function resetPosition()
		A:SetScrollingPosition(true)
	end
	local function centerX()
		P.scrolling.ofs_x = 0
		P.scrolling.point = "CENTER"
		A:SetScrollingPosition()
	end
	-- add dummy messages for setup
	local function showScrolling()
		A:ShowScrolling()
		A.ScrollingText:AddMessage("Adding some test messages")
		A.ScrollingText:AddMessage("Playername gains Blessing of Freedom")
		A.ScrollingText:AddMessage("Teammate is sapped")
		A.ScrollingText:AddMessage("Blessing of Protection is dispelled on Player (by Player)")
		A.ScrollingText:AddMessage("Warrior gains Recklessness")
		A.ScrollingText:AddMessage("Priest casts Mana Burn")
	end
	-- header
	O.AttachHeader(container, "Scrolling Text Settings")
	-- enable
	local enableGroup = O.AttachGroup(container, "simple", _, {fullWidth = true})
	O.AttachCheckBox(enableGroup, "Enable Scrolling Text", db ,"enabled", 170)
	O.AttachCheckBox(enableGroup, "Movable", db ,"interactive", 250, A.ToggleScrollingInteractive)
	O.AttachSpacer(container, _, "small")
	-- button row 1
	local width = 140
	local buttonGroup1 = O.AttachGroup(container, "simple", _, {fullWidth = true})
	O.AttachButton(buttonGroup1, "Show frame", width, showScrolling)
	O.AttachSpacer(buttonGroup1, 20)
	O.AttachButton(buttonGroup1, "Hide frame", width, A.HideScrolling)
	O.AttachSpacer(container, _, "small")
	-- button row 2
	O.AttachGroup(container, "simple", _, {fullWidth = true})
	O.AttachButton(buttonGroup2, "Reset position", width, resetPosition)
	O.AttachSpacer(buttonGroup2, 20)
	O.AttachButton(buttonGroup2, "Center horizontal", width, centerX)
	O.AttachSpacer(container, _, "small")
	-- width
	O.AttachSlider(container, "Set width", db, "width", 300, 1000, 20, false, 400, A.UpdateScrolling)
	O.AttachSpacer(container, _, "small")
	-- fading
	local fadingGroup = O.AttachGroup(container, "simple", _, {fullWidth = true})
	O.AttachCheckBox(fadingGroup, "Enable fading", db, "fading", sliderWidth, A.UpdateScrolling)
	O.AttachSpacer(fadingGroup, 20)
	-- time visible
	O.AttachSlider(fadingGroup, "Fade after (s)", db, "timeVisible", 1, 30, 1, false, sliderWidth, A.UpdateScrolling)
	O.AttachSpacer(container, _, "small")
	-- font size
	local alphaGroup = O.AttachGroup(container, "simple", _, {fullWidth = true})
	O.AttachSlider(alphaGroup, "Font size", db, "fontSize", 8, 22, 1, false, sliderWidth, A.UpdateScrolling)
	O.AttachSpacer(alphaGroup, 20)
	-- background alpha
	O.AttachSlider(alphaGroup, "Background alpha", db, "alpha", 0, 1, 0.01, true, sliderWidth, A.UpdateScrolling)
	O.AttachSpacer(container, _, "small")
	-- visible & max lines
	local linesGroup = O.AttachGroup(container, "simple", _, {fullWidth = true})
	O.AttachSlider(linesGroup, "Visible lines", db, "visibleLines", 1, 12, 1, false, sliderWidth, A.UpdateScrolling)
	O.AttachSpacer(linesGroup, 20)
	O.AttachSlider(linesGroup, "Max. lines (history)", db, "maxLines", 25, 500, 25, false, sliderWidth, A.UpdateScrolling)
	O.AttachSpacer(container, _, "small")
	-- align
	local alignGroup = O.AttachGroup(container, "simple", _, {fullWidth = true})
	local list = {[1] = "CENTER", [2] = "LEFT", [3] = "RIGHT"}
	O.AttachDropdown(alignGroup, "Alignment", db, "align", list, sliderWidth, A.UpdateScrolling)
	O.AttachSpacer(alignGroup, 20)
	O.AttachCheckBox(alignGroup, "Show spell icon", db, "showIcon", sliderWidth)
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
