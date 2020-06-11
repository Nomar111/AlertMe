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
	-- o.testbox = {
	-- 	type = "toggle",
	-- 	name ="test",
	-- 	order = 1,
	-- 	set = function() end,
	-- 	get = function() return true end,
	-- 	disabled = "DisableAlertSettings"
	-- }
end

function O:GetAlertSetting(info)
	-- dprint(1, "GetAlert", unpack(info))
	-- local path = O:GetInfoPath(info)
	-- local key = path.select_alert
	-- -- if select is set to an item, get the name from the feeder table
	-- if key ~= nil then
	-- 	return path[info[#info]]
	-- end
end

function O:SetAlertSetting(info, value)
	-- dprint(1, "SetAlertSetting", unpack(info))
	-- local path = O:GetInfoPath(info)
	-- local key = path.select_alert
	-- -- if select is set to an item, set the new text ** text is not directly set to select, but to its feeder table
	-- if key ~= nil then
	-- 	path[info[#info]] = value
	-- end
end

function O:DisableAlertSettings (info)
	-- local path, key, event = O:GetInfoPath(info)
	-- dprint(1, "pathkeyinfo", path, key, info, "unpackinfo", unpack(info))
end
