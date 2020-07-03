dprint(2, "alert_settings.lua")
-- upvalues
local _G = _G
local dprint, tinsert, pairs, GetTime, time, tostring = dprint, table.insert, pairs, GetTime, time, tostring
local type, unpack = type, unpack
-- get engine environment
local A, _, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:AttachAlertSettings(o)	-- O.options.args.alerts_main.args.handle.args.alert_settings.args
	o.units = O:CreateGroup("Unit selection", nil, 1)
	-- unit selection
	local units = {[1] = "All players", [2] = "Friendly players", [3] = "Hostile players", [4] = "Target", [5] = "Myself"}
	local excluding = {[1] = "---------", [2] = "Myself", [3] = "Target"}
	o.units.args.src_units = O:CreateSelection("Source units", 1, units)
	--o.units.args.spacer1 = O:CreateSpacer(2, 1)
	o.units.args.src_units_excluding = O:CreateSelection("excluding", 3, excluding, 0.6)
	o.units.args.spacer2 = O:CreateSpacer(5, 5)
	o.units.args.dst_units = O:CreateSelection("Destination units", 7, units)
	--o.units.args.spacer3 = O:CreateSpacer(8, 1)
	o.units.args.dst_units_excluding = O:CreateSelection("excluding", 10, excluding, 0.6)
end

function O:CreateSelection(name, order, values, width)
	return {
		type = "select",
		name = name,
		style = "dropdown",
		order = order,
		width = width,
		values = values,
	}
end

function O:GetAlertSetting(info)
	dprint(1, "GetAlertSetting", unpack(info))
	local event = info[O.elvl]
	local uid = P.alerts_db[event].select_alert
	if uid ~= nil then
		return P.alerts_db[event].alerts[uid][info[#info]]
	end
end

function O:SetAlertSetting(info, value)
	dprint(1, "SetAlertSetting", unpack(info))
	local event = info[O.elvl]
	local uid = P.alerts_db[event].select_alert
	-- if select is set to an item, set the new text ** text is not directly set to select, but to its feeder table
	if uid ~= nil then
		P.alerts_db[event].alerts[uid][info[#info]] = value
	end
end

function O:DisableAlertSettings(info)
	local event = info[O.elvl]
	return (P.alerts_db[event].select_alert == nil)
end
