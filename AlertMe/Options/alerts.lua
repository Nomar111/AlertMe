dprint(2, "alerts.lua")
-- upvalues
local _G = _G
local dprint, tinsert, pairs, GetTime, time, date = dprint, table.insert, pairs, GetTime, time, date
local type, unpack = type, unpack
-- get engine environment
local A, _, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates sub-entries for each event ** alerts - dispel
function O:CreateAlertOptions(o)
	-- loop over events that need to be displayed
	for _, tbl in pairs(A.Events) do
		if tbl.options_display ~= nil and tbl.options_display == true then
			O:DrawAlertOptions(o, tbl.short, tbl.options_name, tbl.options_order)
		end
	end
end

function O:DrawAlertOptions(o, event, name, order)	--O.options.args.alerts_main.args
	-- create groups for each display event * handle = gain, dispel....
	o[event] = O:CreateGroup(name, nil, order)
	-- add alert control widgets
	O:AttachAlertControl(o[event].args, name)
	-- create group for alert settings
	o[event].args.alert_settings = O:CreateGroup("", nil, 50)
	o[event].args.alert_settings.inline = true
	o[event].args.alert_settings.get = "GetAlertSetting"
	o[event].args.alert_settings.set = "SetAlertSetting"
	O:AttachAlertSettings(o[event].args.alert_settings.args)
end

function O:AttachAlertControl(o, name)	-- O.options.args.alerts_main.args.handle.args
	o.header = O:CreateHeader(name, nil, order)
	o.select_alert = {
		type = "select",
		name = "Alert",
		desc = "Select alert",
		style = "dropdown",
		order = 2,
		width = 1.7,
		values = "GetAlerts",
	}
	o.spacer1 = O:CreateSpacer(3, 0.7)
	o.reset_alert = {
		type = "execute",
		name = "Reset",
		desc = "current selection",
		image = "Interface\\AddOns\\AlertMe\\Media\\Textures\\reset.tga",
		imageWidth = 18,
		imageHeight = 18,
		width = O:GetWidth(18),
		func = function(info) dprint(1, "reset") end,
		order = 4,
		confirm = true,
		confirmText = "Do you really want to reset this alert?",
		dialogControl = "WeakAurasIcon",
	}
	o.spacer2 = O:CreateSpacer(5, 0.5)
	o.add_alert = {
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
	}
	o.spacer3 = O:CreateSpacer(7, 0.4)
	o.delete_alert = {
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
	}
	o.spacer4 = O:CreateSpacer(9, 0.4)
	o.name = {
		type = "input",
		name = "Alert name",
		order = 10,
		width = 1.5,
		get = "GetAlertSettingTop",
		set = "SetAlertSettingTop",
		disabled = "DisableAlertName",
	}
	o.active = {
		type = "toggle",
		name = "Active?",
		width = 0.5,
		order = 11,
		get = "GetAlertSettingTop",
		set = "SetAlertSettingTop",
		disabled = "DisableAlertName",
	}
end

function O:GetAlerts(info)
	local event = info[O.ilvl]
	local values = {}
	-- loop over events table
	for uid, set in pairs(	P.alerts_db[event]) do
		values[uid] = set.name
	end
	return values
end

function O:CreateAlert(info)
	-- local path = O:GetInfoPath(info)
	-- -- create new entry in alert_settings
	-- local uid = time()
	-- path.alert_settings[uid] = {name = "New Alert", active = true} --..date("%m/%d/%y %H:%M:%S")
	-- -- set the dropwdown to the new element
	-- path.select_alert = uid
end

function O:DeleteAlert(info)
	-- -- delete entry from the alerts table of this event handle
	-- local path = O:GetInfoPath(info)
	-- local uid = path.select_alert
	-- -- if nothing is selected in dropwdown, abort
	-- if uid == nil then return end
	-- -- delete key, the check is probably overkill
	-- path.alert_settings[uid] = nil
	-- -- set the dropdown to the first found alert (if there is one left)
	-- n, t = pairs(path.alert_settings)
	-- local someuid,_ = n(t)
	-- if someuid ~= nil then path.select_alert = someuid end
end

function O:GetAlertSettingTop(info)
	-- --dprint(1, "GetAlertSettingSameLevel", unpack(info))
	-- local path, key = O:GetInfoPath(info)
	-- local uid = path.select_alert
	-- -- if select is set to an item, get the name from the feeder table
	-- if uid ~= nil then
	-- 	return path.alert_settings[uid][key]
	-- end
end

function O:SetAlertSettingTop(info, value)
	-- --dprint(1, "SetAlertSettingSameLevel", unpack(info))
	-- local path, key = O:GetInfoPath(info)
	-- local uid = path.select_alert
	-- -- if select is set to an item, set the new text ** text is not directly set to select, but to its feeder table
	-- if key ~= uid then
	-- 	path.alert_settings[uid][key] = value
	-- end
end

function O:DisableAlertName(info)
	-- local path = O:GetInfoPath(info)
	-- return (path.select_alert == nil)
end

function O:GetWidth(pixel)
	return (1/170*pixel)
end
