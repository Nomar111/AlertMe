dprint(2, "events.lua")
-- upvalues
local _G = _G
local dprint, tinsert, pairs, uuid, GetTime, time, tostring = dprint, table.insert, pairs, uuid, GetTime, time, tostring
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

function O:DrawAlertOptions(o, handle, name, order)	--O.options.args.alerts.args
	o[handle] = O:CreateGroup(name, nil, order)
	o = o[handle]
	-- attach alert controls
	O:AttachAlertControl(o.args, name)
	o.args.details_container = O:CreateGroup("Alert Settings", nil, 50)
	o.args.details_container.inline = true
end

function O:DrawAlertDetails(o, uid)
	-- get current alert selection
	VDT_AddData(o, "o")
	dprint(1, "DrawAlertDetails")
	if uid == nil or type(uid) ~= "number" then return end
	dprint(1, "uid gültig es wird gezeichnet")
	-- delete old group if there was any
	-- create container for details

	uid = tostring(uid)
	o.args.details_container = {
		type = "group",
		name = "Alert Settings",
		order = 50,
		inline = true,
		args = {
			uid = {
				type = "group",
				name = "Set",
				order = 1,
				inline = true,
				args = {
					test = {
						type = "toggle",
						name = "test",
					},
				},
			},
		},
	}
	-- o.args.details_container.args[uid].inline = true
	-- o.args.details_container.args[uid].args = {
	-- 	test = {
	-- 		type = "toggle",
	-- 		name = "test",
	-- 	}
	-- }
	local info = {"alerts","gain","details_container",uid}
	dprint(1,"SelectGroup")
	local status = A.Libs.AceConfigDialog:GetStatusTable("AlertMeOptions", {"alerts","gain","details_container"})
	VDT_AddData(status, "status")
	A.Libs.AceConfigDialog:SelectGroup("AlertMeOptions", "alerts","gain")
	-- o[uid].disabled = "DisableAlertDetails"
end

function O:AttachAlertControl(o, name)
	o.header = O:CreateHeader(name)
	o.select_alert = {
		type = "select",
		name = "Alert",
		desc = "Select alert",
		style = "dropdown",
		order = 2,
		width = 1.9,
		values = "GetAlertList",
		set = "SetAlert",
		get = "GetAlert"
	}
	--o.select_alert:SetCallback("OnValueChanged", function() print("value changes") end)
	o.spacer1 = O:CreateSpacer(3, 0.7)
	o.reset_alert = {
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

function O:SetAlert(info, key)
	-- save value standard
	dprint(1, "SetAlert")
	O:SetOption(info, key)
	--if info[2] ~= nil and O.options.args.alerts.args[info[2]] ~= nil then
		O:DrawAlertDetails(O.options.args.alerts.args[info[2]], key)
	--end
end

function O:CreateAlert(info)
	local path,_ = O:GetInfoPath(info)
	local uid = time()
	path.alerts[uid] = "New Alert"
	path.select_alert = uid
end

function O:DeleteAlert(info)
	local path,_ = O:GetInfoPath(info)
	local uid = path.select_alert
	if uid == nil then return end
	-- delete entry from "alert_name".alerts{}
	if path.alerts[uid] ~= nil then
		path.alerts[uid] = nil
	end
	-- -- and don't forget about details_container
	-- if info[2] ~= nil and O.options.args.alerts.args[info[2]] ~= nil then
	-- 	O.options.args.alerts.args[info[2]].args.details_container = nil
	-- end
	-- but also delete group in details container in db
	-- if path.details_container.args[uid] ~= nil then
	-- 	path.details_container.args[uid] = nil
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

function O:GetAlertList(info)
	local path,key = O:GetInfoPath(info)
	return path.alerts
end

function O:GetAlertName(info)
	local path,_ = O:GetInfoPath(info)
	local name = ""
	local uid = path.select_alert
	if uid ~= nil then
		name = path.alerts[uid]
	else
		name = ""
	end
	return name
end

function O:SetAlertName(info, value)
	local path,_ = O:GetInfoPath(info)
	local uid = path.select_alert
	if uid ~= nil then
		path.alerts[uid] = value
	end
end

function O:DisableAlertName(info)
	local path,_ = O:GetInfoPath(info)
	local uid = path.select_alert
	if uid == nil then
		return true
	end
	return false
end

function O:DisableAlertDetails(info)
	local uid = A.db.profile.alerts[info[2]].select_alert
	if uid == nil then
		return true
	end
	return false
end

function O:GetWidth(pixel)
	return (1/170*pixel)
end

function O:GetAlert(info, value)
	dprint(1, "GetAlert")
	--VDT_AddData(info,"getinfo")
	local path,_ = O:GetInfoPath(info)
	--VDT_AddData(path, "path")
	--dprint(1, "GetAlert info", info, value)
	if info[2] ~= nil and O.options.args.alerts.args[info[2]] ~= nil then
		O:DrawAlertDetails(O.options.args.alerts.args[info[2]],  path["select_alert"])
	end
	if path["select_alert"] ~= nil then
		return path["select_alert"]
	else
		return ""
	end
end
