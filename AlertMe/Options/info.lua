--dprint(3, "info.lua")
-- upvalues
local _G = _G
-- get engine environment
local A, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the info tab
function O:ShowInfo(container)
	-- header
	O.AttachHeader(container, "Addon Info")
	-- info
	local text = "Addon: AlertMe"
	text = text.."\n\nCurrent Version: "..ADDON_VERSION
	text = text.."\n\nAuthor: "..ADDON_AUTHOR
	text = text.."\n\nEmail: NomarZT@gmx.net"
	text = text.."\n\nGithub: https://github.com/Nomar111/AlertMe"
	O.AttachLabel(container, text, GameFontNormal, _, 400)
end
