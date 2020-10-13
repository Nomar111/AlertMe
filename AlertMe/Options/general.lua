--dprint(3, "general.lua")
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
		local function deleteLog()
			P.log = nil
			P.log = {}
		end
		O.AttachSlider(container, "Debug level", P.general, "debugLevel", 1, 3, 1, false, 200)
		O.AttachSlider(container, "Debug level logging", P.general, "debugLevelLog", 1, 3, 1, false, 200)
		O.AttachCheckBox(container, "Debug logging", P.general, "debugLog", 180)
		local btnDeleteLog = O.AttachButton(container, "Delete log table", 200)
		btnDeleteLog:SetCallback("OnClick", deleteLog)
	end
end
