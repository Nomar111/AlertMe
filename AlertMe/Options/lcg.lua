-- get engine environment
local A, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:ShowGlow(container)
	dprint(3, "O:ShowGlow")
	-- clear container so it can call itself
	container:ReleaseChildren()
	local function refresh()
		dprint(3, "refreshGlow")
		O:ShowGlow(container)
	end
	-- header
	O.AttachHeader(container, "Custom Glow Settings")
	O.AttachCheckBox(container, "Enable support for BattlegroundTargetsClassic", P.glow, "bgtEnabled", 400)
	--local group = O.AttachGroup(container, "simple", _, {fullWidth = true})
	-- Glow Selector
	local glowList = {[1]="Glow Preset 1",[2]="Glow Preset 2",[3]="Glow Preset 3",[4]="Glow Preset 4",[5]="Glow Preset 5",[6]="Glow Preset 6",[7]="Glow Preset 7",[8]="Glow Preset 8"}
	local dd = O.AttachDropdown(container, "Glow Preset", P.glow, "selectedGlow", glowList, 200, refresh)
	-- set db and type according to selection
	local db = P.glow[P.glow.selectedGlow]
	local labelNumber = "Number of lines. Default = 8"
	local labelFrequency = "Frequency. Negative = inverse direction. Default = 0.25"
	-- attach color picker
	O.AttachColorPicker(container, "Color", db, "color", true)
	-- attach number slider
	O.AttachSlider(container, labelNumber, db, "number", 1, 20, 1, false, 400)
	-- attach fequency slider
	O.AttachSlider(container, labelFrequency, db, "frequency", -1, 1, 0.005, false, 400)
	-- attach thickness/scale for pixelglow
	O.AttachSlider(container, "Thickness. Default = 2", db, "thickness", 0, 5, 1, false, 400)
	-- attach offset sliders
	O.AttachSlider(container, "Offset X", db, "ofs_x", -5, 5, 0.5, false, 400)
	O.AttachSlider(container, "Offset Y", db, "ofs_y", -5, 5, 0.5, false, 400)
end
