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
	-- paint the alert seetings
	--o[event]
end

function O:AttachAlertControl(o, name)	--0 = --O.options.args.alerts_main.args.handle
	o.header = O:CreateHeader(name)
	o.select_alert = {
		type = "select",
		name = "Alert",
		desc = "Select alert",
		style = "dropdown",
		order = 2,
		width = 1.9,
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
	o.alert_name = {
		type = "input",
		name = "Alert name",
		order = 10,
		width = 1.7,
		get = "GetAlertName",
		set = "SetAlertName",
		disabled = "DisableAlertName",
	}
end

function O:GetAlerts(info)
	local path = O:GetInfoPath(info)
	local values = {}
	-- loop over events table
	for key, set in pairs(path.alerts_db) do
		values[key] = set.name
	end
	return values
end

function O:CreateAlert(info)
	local path = O:GetInfoPath(info)
	-- create new entry in alerts_db
	local key = time()
	path.alerts_db[key] = {name = "New Alert", active = true} --..date("%m/%d/%y %H:%M:%S")
	-- set the dropwdown to the new element
	path.select_alert = key
end

function O:DeleteAlert(info)
	-- delete entry from the alerts table of this event handle
	local path = O:GetInfoPath(info)
	local key = path.select_alert
	-- if nothing is selected in dropwdown, abort
	if key == nil then return end
	-- delete key, the check is probably overkill
	path.alerts_db[key] = nil
	-- set the dropdown to the first found alert (if there is one left)
	n, t = pairs(path.alerts_db)
	local somekey,_ = n(t)
	if somekey ~= nil then path.select_alert = somekey end
end

function O:GetAlertName(info)
	--dprint(1, "GetAlertName", unpack(info))
	local path = O:GetInfoPath(info)
	local key = path.select_alert
	-- if select is set to an item, get the name from the feeder table
	if key ~= nil then
		return path.alerts_db[key].name
	end
end

function O:SetAlertName(info, value)
	--dprint(1, "SetAlertName", unpack(info))
	local path = O:GetInfoPath(info)
	local key = path.select_alert
	-- if select is set to an item, set the new text ** text is not directly set to select, but to its feeder table
	if key ~= nil then
		path.alerts_db[key].name = value
	end
end

function O:DisableAlertName(info)
	local path = O:GetInfoPath(info)
	return (path.select_alert == nil)
end

function O:GetWidth(pixel)
	return (1/170*pixel)
end
