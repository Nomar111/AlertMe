-- set addon environment
setfenv(1, _G.AlertMe)

function O:ShowGlow(container)
	-- clear container so it can call itself
	container:ReleaseChildren()
	local function refresh()
		O:ShowGlow(container)
	end
	local ttFrequency = { header = "Frequency", lines = { "Negative = inverse direction", "Default = 0.25" }, wrap = false }
	local ttLines = { header = "Number of lines", lines = { "Default = 8" }, wrap = false }
	local ttBGT = { header = "BGTC Support", lines = { "Deactivate if you experience performance issues" },	wrap = false }
	local ttThickness = { header = "Thickness", lines = { "Default = 2" }, wrap = false	}
	local db = P.glow[P.glow.selectedGlow]
	-- header
	O.attachHeader(container, "Glow Settings")
	O.attachCheckBox(container, "Enable glow on unit frames", P.glow, "enabled", 300, _)
	O.attachSpacer(container, _, "small")
	O.attachCheckBox(container, "Enable support for BattlegroundTargets Classic", P.glow, "bgtEnabled", 400, _, ttBGT)
	O.attachSpacer(container, _, "small")
	--local group = O.attachGroup(container, "simple", _, {fullWidth = true})
	local glowList = {[1]="Glow Preset 1",[2]="Glow Preset 2",[3]="Glow Preset 3",[4]="Glow Preset 4",[5]="Glow Preset 5",[6]="Glow Preset 6",[7]="Glow Preset 7",[8]="Glow Preset 8"}
	local topGroup = O.attachGroup(container, "simple", _, {fullWidth = true})
	local sliderWidth = 200
	-- Glow Selector
	O.attachDropdown(topGroup, "Glow Preset", P.glow, "selectedGlow", glowList, sliderWidth, refresh)
	O.attachSpacer(topGroup, 20)
	-- attach color picker
	O.attachColorPicker(topGroup, " Glow Color", db, "color", true)
	O.attachSpacer(container, _, "medium")

	local sliderGroup1 = O.attachGroup(container, "simple", _, {fullWidth = true})
	-- attach number slider
	O.attachSlider(sliderGroup1, "No. of lines", db, "number", 1, 20, 1, false, sliderWidth, _, ttLines)
	O.attachSpacer(sliderGroup1, 20)
	-- attach fequency slider
	O.attachSlider(sliderGroup1, "Frequency", db, "frequency", -1, 1, 0.005, false, sliderWidth, _, ttFrequency)
	O.attachSpacer(sliderGroup1, _, "medium")
	-- attach thickness/scale for pixelglow
	O.attachSlider(container, "Thickness. Default = 2", db, "thickness", 0, 5, 1, false, sliderWidth, _, ttThickness)
	O.attachSpacer(container, _, "medium")
	-- attach offset sliders
	local sliderGroup2 = O.attachGroup(container, "simple", _, {fullWidth = true})
	O.attachSlider(sliderGroup2, "Offset X", db, "ofs_x", -5, 5, 0.5, false, sliderWidth)
	O.attachSpacer(sliderGroup2, 20)
	O.attachSlider(sliderGroup2, "Offset Y", db, "ofs_y", -5, 5, 0.5, false, sliderWidth)
end
