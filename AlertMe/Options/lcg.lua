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
	local type = ""
	local labelNumber = ""
	local labelFrequency = ""
	local db = P.glow
	-- header
	O.AttachHeader(container, "Custom Glow Settings")
	--local group = O.AttachGroup(container, "simple", _, {fullWidth = true})
	-- Glow Selector
	local glowList = {[1]="Pixel Glow 1",[2]="Pixel Glow 2",[3]="Pixel Glow 3",[4]="Pixel Glow 4",[5]="Particle Glow 1",[6]="Particle Glow 2",[7]="Particle Glow 3",[8]="Particle Glow 4"}
	local dd = O.AttachDropdown(container, "Glow Preset", P.glow, "selectedGlow", glowList, 200, refresh)
	-- set db and type according to selection
	if P.glow.selectedGlow <= 4 then
		type = "pixel"
		db = P.glow.pixel[P.glow.selectedGlow]
		labelNumber = "Number of lines. Default = 8"
		labelFrequency = "Frequency. Negative = inverse direction. Default = 0.25"
	else
		type = "particle"
		db = P.glow.particle[P.glow.selectedGlow-4]
		labelNumber = "Number of particle groups. Default = 4"
		labelFrequency = "Frequency. Negative = inverse direction. Default = 0.125"
	end
	-- attach color picker
	O.AttachColorPicker(container, "Color", db, "color", true)
	-- attach number slider
	O.AttachSlider(container, labelNumber, db, "number", 1, 20, 1, false, 400)
	-- attach fequency slider
	O.AttachSlider(container, labelFrequency, db, "frequency", -1, 1, 0.005, false, 400)
	-- attach thickness/scale for pixelglow
	if type == "pixel" then
		O.AttachSlider(container, "Thickness. Default = 2", db, "thickness", 0, 5, 1, false, 400)
	else
		O.AttachSlider(container, "Scale. Default = 1", db, "scale", 0, 5, 0.01, false, 400)
	end
	-- attach offset sliders
	O.AttachSlider(container, "Offset X", db, "ofs_x", -5, 5, 0.5, false, 400)
	O.AttachSlider(container, "Offset Y", db, "ofs_y", -5, 5, 0.5, false, 400)
end
