-- set addon environment
setfenv(1, _G.AlertMe)

local function getGlowList()
	local ret = {}
	for i=1, 8 do
		if P.glow[i].name == "Glow Preset" then
			P.glow[i].name = "Glow Preset "..i
		end
		ret[i] = P.glow[i].name
	end
	return ret
end

function O:ShowGlow(container)
	-- refresh function
	local function refresh()
		O:ShowGlow(container)
	end
	-- clear container so it can call itself
	container:ReleaseChildren()
	local db, tooltip = P.glow[P.glow.selectedGlow]
	local width = 200
	-- header
	O.attachHeader(container, "Glow Settings")
	-- checkboxes enable/disable
	O.attachCheckBox(container, "Enable glow on unit frames", P.glow, "enabled", 300, _)
	O.attachSpacer(container, _, "small")
	tooltip = { header = "BGTC Support", lines = { "Deactivate if you experience performance issues" } }
	O.attachCheckBox(container, "Enable support for BattlegroundTargets Classic", P.glow, "bgtEnabled", 400, _, tooltip)
	O.attachSpacer(container, _, "small")
	-- Glow Preset Selector
	local glowGroup = O.attachGroup(container, "simple", _, {fullWidth = true})
	O.attachDropdown(glowGroup, "Glow Preset", P.glow, "selectedGlow", getGlowList(), _, width-3, refresh)
	O.attachSpacer(glowGroup, 20)
	O.attachEditBox(glowGroup, "Name of the Glow Preset", db, "name", width, refresh)
	O.attachSpacer(container, _, "small")
	-- attach color picker
	O.attachColorPicker(container, " ".."Glow Color", db, "color", true)
	O.attachSpacer(container, _, "medium")
	-- number & frequency slider
	local sliderGroup1 = O.attachGroup(container, "simple", _, {fullWidth = true})
	tooltip = { header = "Number of lines", lines = { "Default = 10" } }
	O.attachSlider(sliderGroup1, "No. of lines", db, "number", 1, 26, 1, false, width, _, tooltip)
	O.attachSpacer(sliderGroup1, 20)
	tooltip = { header = "Frequency", lines = { "Negative = inverse direction", "Default = 0.25" } }
	O.attachSlider(sliderGroup1, "Frequency", db, "frequency", -1, 1, 0.005, false, width, _, tooltip)
	O.attachSpacer(sliderGroup1, _, "medium")
	-- thickness slider
	tooltip = { header = "Thickness", lines = { "Default = 2" } }
	O.attachSlider(container, "Thickness. Default = 2", db, "thickness", 0, 5, 1, false, width, _, tooltip)
	O.attachSpacer(container, _, "medium")
	-- offset sliders
	local sliderGroup2 = O.attachGroup(container, "simple", _, {fullWidth = true})
	O.attachSlider(sliderGroup2, "Offset X", db, "ofs_x", -5, 5, 0.5, false, width)
	O.attachSpacer(sliderGroup2, 20)
	O.attachSlider(sliderGroup2, "Offset Y", db, "ofs_y", -5, 5, 0.5, false, width)
end
