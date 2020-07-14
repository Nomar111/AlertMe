dprint(2, "alerts.lua")
-- upvalues
local _G = _G
local dprint, tinsert, pairs, GetTime, time, date, tostring = dprint, table.insert, pairs, GetTime, time, date, tostring
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
	o[event].args.alert_settings.disabled = "DisableAlertSettings"
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
		get = "GetSelectedAlert",
		set = "SetSelectedAlert"

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
		get = "GetAlertSetting",
		set = "SetAlertSetting",
		disabled = "DisableAlertSettings",
	}
	o.active = {
		type = "toggle",
		name = "Active?",
		width = 0.5,
		order = 11,
		get = "GetAlertSetting",
		set = "SetAlertSetting",
		disabled = "DisableAlertSettings",
	}
end

function O:GetAlerts(info)
	local event = info[O.elvl]
	local values = {}
	-- loop over events table
	for uid, set in pairs(P.alerts_db[event].alerts) do
		values[uid] = set.name
	end
	return values
end

function O:CreateAlert(info)
	local event = info[O.elvl]
	-- create new entry in alert_settings
	local uid = tostring(time())
	P.alerts_db[event].alerts[uid] = {}--name = "New Alert", active = true} --..date("%m/%d/%y %H:%M:%S")
	-- set the dropwdown to the new element
	P.alerts_db[event].select_alert = uid
end

function O:DeleteAlert(info)
	dprint(1, "delete", unpack(info))
	local event = info[O.elvl]
	local uid = P.alerts_db[event].select_alert
	-- if nothing is selected in dropwdown, abort
	if uid == nil then return end
	P.alerts_db[event].select_alert = nil
	P.alerts_db[event].alerts[uid] = nil
	local someuid = O:GetAnyValidAlert(P.alerts_db[event].alerts)
	if someuid ~= nil then
		P.alerts_db[event].select_alert = someuid
	end
end

function O:GetSelectedAlert(info)
	--dprint(1,unpack(info))
	local event = info[O.elvl]
	local selection = P.alerts_db[event].select_alert
	-- if selection is nil or doesnt exists in the alerts table try to get another one
	if selection == nil or P.alerts_db[event].alerts[selection] == nil then
		return O:GetAnyValidAlert(P.alerts_db[event].alerts)
	else
		return selection
	end
end

function O:SetSelectedAlert(info, val)
	local event = info[O.elvl]
	P.alerts_db[event].select_alert = val
end

function O:GetAnyValidAlert(alerts)
	-- set the dropdown to the first found alert (if there is one left)
	n, t = pairs(alerts)
	local someuid,_ = n(t)
	return someuid
end

function O:GetWidth(pixel)
	return (1/170*pixel)
end
