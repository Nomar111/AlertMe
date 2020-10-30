-- set addon environment
setfenv(1, _G.AlertMe)

-- creates the general options tab
function O:ShowGeneral(container)
	-- header
	O.attachHeader(container, "General Settings")
	-- addon
	local addonGroup = O.attachGroup(container, "inline", "Addon settings", {fullWidth = true})
	O.attachCheckBox(addonGroup, "Enable addon", P.general, "enabled", 180, A.ToggleAddon)
	O.attachCheckBox(addonGroup, "Hide minimap", P.general.minimap, "hide", 180, A.ToggleMinimap)
	-- zones
	local zonesGroup = O.attachGroup(container, "inline", "Addon is enabled in", {fullWidth = true})
	O.attachCheckBox(zonesGroup, "Battlegrounds", P.general.zones, "bg", 180, A.registerCLEU)
	O.attachCheckBox(zonesGroup, "World", P.general.zones, "world", 180, A.registerCLEU)
	O.attachCheckBox(zonesGroup, "PvE Instances", P.general.zones, "instance", 180, A.registerCLEU)
	-- debug level
	if PLAYER_NAME == "Nomar" or PLAYER_NAME == "Devmage" then
		O.attachSpacer(container, _, "small")
		local function deleteLog()
			P.log = nil
			P.log = {}
		end
		O.attachSlider(container, "Debug level", P.general, "debugLevel", 0, 3, 1, false, 200)
		O.attachSpacer(container, _, "small")
		O.attachSlider(container, "Debug level logging", P.general, "debugLevelLog", 0, 3, 1, false, 200)
		O.attachSpacer(container, _, "small")
		O.attachCheckBox(container, "Debug logging", P.general, "debugLog", 180)
		O.attachSpacer(container, _, "small")
		O.attachButton(container, "Delete log table", 200, deleteLog)
	end
end
