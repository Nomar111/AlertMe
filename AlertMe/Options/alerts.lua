dprint(2, "alerts.lua")
-- upvalues
local _G = _G
local dprint, tinsert, pairs, GetTime, time, tostring = dprint, table.insert, pairs, GetTime, time, tostring
local type, unpack = type, unpack
-- get engine environment
local A, _, O = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the alerts options tab
function O:CreateAlertOptions(o)
	-- loop over events that need to be displayed
	for _, tbl in pairs(A.Events) do
		if tbl.options_display ~= nil and tbl.options_display == true then
			O:DrawAlertOptions(o, tbl.handle, tbl.options_name, tbl.options_order)
		end
	end
end

function O:DrawAlertOptions(o, handle, name, order)	--O.options.args.alerts_main.args
	-- create groups for each display event * handle = gain, dispel....
	o[handle] = O:CreateGroup(name, nil, order)
	o[handle].set = nil
	o[handle].set = nil
	-- add alert control widgets
	o[handle].args = O:CreateAlertControl(name)
end

function O:CreateAlertControl(name)
	local alert_control = {
		header = O:CreateHeader(name),
		select_alert = {
			type = "select",
			name = "Alert",
			desc = "Select alert",
			style = "dropdown",
			order = 2,
			width = 1.9,
			values = "GetAlerts",
			--values = {[1]="Test1", [2]="Test2"},
			-- get = function() dprint(1, "GetInlineFunc"); return "" end,
			-- set = function() dprint(1, "SetInlineFunc") end,
		},
		spacer1 = O:CreateSpacer(3, 0.7),
		reset_alert = {
			type = "execute",
			name = "Reset",
			desc = "current selection",
			image = "Interface\\AddOns\\AlertMe\\Media\\Textures\\reset.tga",
			imageWidth = 18,
			imageHeight = 18,
			width = O:GetWidth(18),
			func = function(info) print("reset") end,
			order = 4,
			confirm = true,
			confirmText = "Do you really want to reset this alert?",
			dialogControl = "WeakAurasIcon",
		},
		spacer2 = O:CreateSpacer(5, 0.5),
		add_alert = {
			type = "execute",
			name = "Create",
			desc = "a new alert",
			image = "Interface\\AddOns\\AlertMe\\Media\\Textures\\add.tga",
			imageWidth = 18,
			imageHeight = 18,
			width = O:GetWidth(18),
			func = "CreateAlert",
			order = 6,
			dialogControl = "WeakAurasIcon",
		},
		spacer3 = O:CreateSpacer(7, 0.4),
		delete_alert = {
			type = "execute",
			name = "Delete",
			desc = "current selection",
			image = "Interface\\AddOns\\AlertMe\\Media\\Textures\\delete.tga",
			imageWidth = 18,
			imageHeight = 18,
			width = O:GetWidth(18),
			func = "DeleteAlert",
			order = 8,
			confirm = true,
			confirmText = "Do you really want to delete this alert?",
			dialogControl = "WeakAurasIcon",
		},
		spacer4 = O:CreateSpacer(9, 0.4),
		alert_name = {
			type = "input",
			name = "Alert name",
			order = 10,
			width = 1.7,
			get = "GetAlertName",
			set = "SetAlertName",
			disabled = "DisableAlertName",
		},
	}
	return alert_control
end


function O:CreateAlert(info)
	local path,_ = O:GetInfoPath(info)
	local key = time()
	path.alerts[key] = "New Alert"
	path.select_alert = key
end

function O:DeleteAlert(info)
	local path,_ = O:GetInfoPath(info)
	local key = path.select_alert
	if key == nil then return end
	-- delete entry from "alert_name".alerts{}
	if path.alerts[key] ~= nil then
		path.alerts[key] = nil
	end
	-- -- and don't forget about alert_settings
	-- if info[2] ~= nil and O.options.args.alerts.args[info[2]] ~= nil then
	-- 	O.options.args.alerts.args[info[2]].args.alert_settings = nil
	-- end
	-- but also delete group in details container in db
	-- if path.alert_settings.args[key] ~= nil then
	-- 	path.alert_settings.args[key] = nil
	-- end

	-- -- now just set something in the alert selector (if possible)
	-- for id,_ in pairs(path.alerts) do
	-- 	if id ~= nil then
	-- 		-- set select to first found id
	-- 		path.select_alert = id
	-- 		return
	-- 	end
	-- end
	-- -- nothing found - set empty
	-- path.select_alert = ""
end

function O:GetAlerts(info)
	local path,key = O:GetInfoPath(info)
	return path.alerts
end

function O:GetAlertName(info)
	dprint(1, "GetAlertName", unpack(info))
	local path,_ = O:GetInfoPath(info)
	local name = ""
	local key = path.select_alert
	-- if select is set to an item, get the name from the feeder table
	if key ~= nil then
		name = path.alerts[key]
	end
	return name
end

function O:SetAlertName(info, value)
	dprint(1, "SetAlertName", unpack(info))
	local path,_ = O:GetInfoPath(info)
	local key = path.select_alert
	-- if select is set to an item, set the new text ** text is not directly set to select, but to its feeder table
	if key ~= nil then
		path.alerts[key] = value
	end
end

function O:DisableAlertName(info)
	local path,_ = O:GetInfoPath(info)
	local key = path.select_alert
	-- if select has no valid selection then disable name widget
	if key == nil then
		return true
	end
	return false
end

function O:GetWidth(pixel)
	return (1/170*pixel)
end



-- function O:DisableAlertDetails(info)
-- 	local key = A.db.profile.alerts[info[2]].select_alert
-- 	if key == nil then
-- 		return true
-- 	end
-- 	return false
-- end
--
-- -- callbacks
-- function O:GetAlert(info, value)
-- 	dprint(1, "GetAlert")
-- 	--VDT_AddData(info,"getinfo")
-- 	local path,_ = O:GetInfoPath(info)
-- 	--VDT_AddData(path, "path")
-- 	--dprint(1, "GetAlert info", info, value)
-- 	if info[2] ~= nil and O.options.args.alerts.args[info[2]] ~= nil then
-- 		O:DrawAlertDetails(O.options.args.alerts.args[info[2]],  path["select_alert"])
-- 	end
-- 	if path["select_alert"] ~= nil then
-- 		return path["select_alert"]
-- 	else
-- 		return ""
-- 	end
-- end
--
-- function O:SetAlert(info, key)
-- 	-- save value standard
-- 	dprint(1, "SetAlert")
-- 	O:SetOption(info, key)
-- 	--if info[2] ~= nil and O.options.args.alerts.args[info[2]] ~= nil then
-- 		O:DrawAlertDetails(O.options.args.alerts.args[info[2]], key)
-- 	--end
-- end
