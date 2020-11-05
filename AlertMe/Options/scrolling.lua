-- set addon environment
setfenv(1, _G.AlertMe)

function O:ShowScrollingText(container)
	local db = P.scrolling
	local sliderWidth = 190
	-- local function
	local function resetPosition()
		A.SetScrollingPos(true)
	end
	local function centerX()
		P.scrolling.ofs_x = 0
		P.scrolling.point = "CENTER"
		A.SetScrollingPos()
	end
	-- add dummy messages for setup
	local function showScrollingTest()
		if A.ScrollingText:GetNumMessages() > 20 then
			A:ShowScrolling()
		else
			local size = P.scrolling.fontSize - 2.5
			size = size..":"..size
			local messages = {
				"|cFF27d942** |r |T135812:"..size..":0:0|t Playername starts to cast Fireball |T135812:"..size..":0:0|t |cFF27d942 **|r",
				"|cFF27d942** |r |T135843:"..size..":0:0|t Playername gained Frost Armor |T135843:"..size..":0:0|t |cFF27d942 **|r",
				"|cFFde4037** |r |T135807:"..size..":0:0|t Vampiric Duskbat resisted Playername's Fire Blast |T135807:"..size..":0:0|t |cFFde4037 **|r",
			}
			for i=1, 15 do
				for _, msg in pairs(messages) do
					A:PostInScrolling(msg)
				end
			end
		end
	end
	-- header
	O.attachHeader(container, "Scrolling Text Settings")
	-- enable
	local enableGroup = O.attachGroup(container, "simple", _, {fullWidth = true})
	O.attachCheckBox(enableGroup, "Enable Scrolling Text", db ,"enabled", 170)
	O.attachCheckBox(enableGroup, "Movable", db ,"interactive", 250, A.ToggleScrollingLocked)
	O.attachSpacer(container, _, "small")
	-- button row 1
	local width = 140
	local buttonGroup1 = O.attachGroup(container, "simple", _, {fullWidth = true})
	O.attachButton(buttonGroup1, "Show frame", width, showScrollingTest)
	O.attachSpacer(buttonGroup1, 20)
	O.attachButton(buttonGroup1, "Hide frame", width, A.HideScrolling)
	O.attachSpacer(container, _, "small")
	-- button row 2
	local buttonGroup2 = O.attachGroup(container, "simple", _, {fullWidth = true})
	O.attachGroup(container, "simple", _, {fullWidth = true})
	O.attachButton(buttonGroup2, "Reset position", width, resetPosition)
	O.attachSpacer(buttonGroup2, 20)
	O.attachButton(buttonGroup2, "Center horizontal", width, centerX)
	O.attachSpacer(container, _, "small")
	-- width
	O.attachSlider(container, "Set width", db, "width", 300, 1000, 20, false, 400, A.UpdateScrolling)
	O.attachSpacer(container, _, "small")
	-- fading
	local fadingGroup = O.attachGroup(container, "simple", _, {fullWidth = true})
	O.attachCheckBox(fadingGroup, "Enable fading", db, "fading", sliderWidth, A.UpdateScrolling)
	O.attachSpacer(fadingGroup, 20)
	-- time visible
	O.attachSlider(fadingGroup, "Fade after (s)", db, "timeVisible", 1, 30, 1, false, sliderWidth, A.UpdateScrolling)
	O.attachSpacer(container, _, "small")
	-- font size
	local alphaGroup = O.attachGroup(container, "simple", _, {fullWidth = true})
	O.attachSlider(alphaGroup, "Font size", db, "fontSize", 8, 22, 1, false, sliderWidth, A.UpdateScrolling)
	O.attachSpacer(alphaGroup, 20)
	-- background alpha
	O.attachSlider(alphaGroup, "Background alpha", db, "alpha", 0, 1, 0.01, true, sliderWidth, A.UpdateScrolling)
	O.attachSpacer(container, _, "small")
	-- visible & max lines
	local linesGroup = O.attachGroup(container, "simple", _, {fullWidth = true})
	O.attachSlider(linesGroup, "Visible lines", db, "visibleLines", 1, 12, 1, false, sliderWidth, A.UpdateScrolling)
	O.attachSpacer(linesGroup, 20)
	O.attachSlider(linesGroup, "Max. lines (history)", db, "maxLines", 25, 500, 25, false, sliderWidth, A.UpdateScrolling)
	O.attachSpacer(container, _, "small")
	-- align
	local alignGroup = O.attachGroup(container, "simple", _, {fullWidth = true})
	local list = {[1] = "CENTER", [2] = "LEFT", [3] = "RIGHT"}
	O.attachDropdown(alignGroup, "Alignment", db, "align", list, _, sliderWidth, A.UpdateScrolling)
	O.attachSpacer(alignGroup, 20)
	O.attachCheckBox(alignGroup, "Show spell icon", db, "showIcon", sliderWidth)
	O.attachSpacer(container, _, "large")
	-- inline docu
	local text1 = "Left-Click for moving the frame (if set to movable)."
	local text2 = "Right-Click for closing the frame (if set to movable)."
	local text3 = "Mousewheel to scroll through the text."
	O.attachLabel(container, text1, GameFontHighlight)
	O.attachSpacer(container, _, "small")
	O.attachLabel(container, text2, GameFontHighlight)
	O.attachSpacer(container, _, "small")
	O.attachLabel(container, text3, GameFontHighlight)
	O.attachSpacer(container, _, "small")
end
