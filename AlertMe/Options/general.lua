-- get engine environment
local A, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the general options tab
function O:ShowGeneral(container)
	-- header
	O.AttachHeader(container, "General Settings")
	-- addon
	local addonGroup = O.AttachGroup(container, "inline", "Addon settings", {fullWidth = true})
	O.AttachCheckBox(addonGroup, "Enable addon", P.general, "enabled", 180, A.ToggleAddon)
	O.AttachCheckBox(addonGroup, "Hide minimap", P.general.minimap, "hide", 180, A.ToggleMinimap)
	-- zones
	local zonesGroup = O.AttachGroup(container, "inline", "Addon is enabled in", {fullWidth = true})
	O.AttachCheckBox(zonesGroup, "Battlegrounds", P.general.zones, "bg", 180)
	O.AttachCheckBox(zonesGroup, "World", P.general.zones, "world", 180)
	O.AttachCheckBox(zonesGroup, "PvE Instances", P.general.zones, "instance", 180)
	-- debug level
	if PLAYER_NAME == "Nomar" or PLAYER_NAME == "Devmage" then
		O.AttachSpacer(container, _, "small")
		local function deleteLog()
			P.log = nil
			P.log = {}
		end
		O.AttachSlider(container, "Debug level", P.general, "debugLevel", 0, 3, 1, false, 200)
		O.AttachSpacer(container, _, "small")
		O.AttachSlider(container, "Debug level logging", P.general, "debugLevelLog", 0, 3, 1, false, 200)
		O.AttachSpacer(container, _, "small")
		O.AttachCheckBox(container, "Debug logging", P.general, "debugLog", 180)
		O.AttachSpacer(container, _, "small")
		O.AttachButton(container, "Delete log table", 200, deleteLog)
	end
end
