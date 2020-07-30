dprint(3, "info.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the info tab
function O:ShowInfo(container)
	-- header
	O.AttachHeader(container, "Addon Info")
	-- info
	local text = "Addon Name: AlertMe\n\n".."installed Version: "..ADDON_VERSION.."\n\nCreated by: "..ADDON_AUTHOR
	O:AttachLabel(container, text, GameFontHighlight)
end
