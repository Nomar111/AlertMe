--dprint(3, "info.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the info tab
function O:ShowInfo(container)
	-- header
	O.AttachHeader(container, "Addon Info")
	-- info
	local text = "Addon Name: AlertMe"
	text = text.."\n\nCurrently installed Version: "..ADDON_VERSION
	text = text.."\n\nCreated by: "..ADDON_AUTHOR
	text = text.."\n\nEmail: NomarZT@gmx.net"
	text = text.."\n\nGithub page: https://github.com/Nomar111/AlertMe"
	O.AttachLabel(container, text, GameFontHighlight)
end
