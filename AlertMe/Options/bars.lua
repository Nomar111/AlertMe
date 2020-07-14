dprint(3, "bars.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the general options tab
function O:ShowBars(container)
	dprint(2, "O:ShowBars")
	-- header
	O:AttachHeader(container, "Bar Setup")
end
