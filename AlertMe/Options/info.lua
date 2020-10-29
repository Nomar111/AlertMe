-- set addon environment
setfenv(1, _G.AlertMe)

-- creates the info tab
function O:ShowInfo(container)
	O.AttachHeader(container, "Addon Info")
	local text = "Addon: AlertMe"
	text = text.."\n\nCurrent Version: "..ADDON_VERSION
	text = text.."\n\nAuthor: "..ADDON_AUTHOR
	text = text.."\n\nEmail: NomarZT@gmx.net"
	text = text.."\n\nGithub: https://github.com/Nomar111/AlertMe"
	O.AttachLabel(container, text, GameFontNormal, _, 400)
end
