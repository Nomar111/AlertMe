dprint(3, "general.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the general options tab
function O:ShowGeneral(container)
	--VDT_AddData(container,"cnt")
	dprint(2, "O:ShowGeneral")
	-- header
	O.AttachHeader(container, "General Settings")
	-- zones
	local zonesGroup = O.AttachGroup(container, "inline", "Addon is enabled in", {fullWidth = true})
	O.AttachCheckBox(zonesGroup, "Battlegrounds", P.general.zones, "bg", 150)
	O.AttachCheckBox(zonesGroup, "World", P.general.zones, "world")
end
