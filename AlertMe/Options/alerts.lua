dprint(2, "events.lua")
-- upvalues
local _G = _G
local dprint, tinsert, pairs, uuid, GetTime, time = dprint, table.insert, pairs, uuid, GetTime, time
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
	O:DrawAlertDetails(o.args, name)
end

function O:DrawAlertDetails(o, name)
	o.alert_details = O:CreateGroup("", nil, 50)
	o.alert_details.inline = true
	o.alert_details.disabled = "DisableAlertDetails"
	o.alert_details.args = {
		test = {
			type = "toggle",
			name = "test",
			--desc = "Please test this",
			--descStyle = "inline"
		}
	}
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
	}
	o.spacer1 = O:CreateSpacer(3, 0.7)
	o.reset_alert = {
		type = "execute",
		name = "",
		desc = "Reset selected alert",
		image = "Interface\\AddOns\\AlertMe\\Media\\Textures\\reset.tga",
		imageWidth = 18,
		imageHeight = 18,
		width = O:GetWidth(18),
		func = function(info) return "" end,
		order = 4,
		confirm = true,
		confirmText = "Do you really want to reset this alert?",
		dialogControl = "WeakAurasIcon",
		control = "WeakAurasIcon"
	}
	o.spacer2 = O:CreateSpacer(5, 0.5)
	o.add_alert = {
		type = "execute",
		name = "",
		image = "Interface\\AddOns\\AlertMe\\Media\\Textures\\add.tga",
		imageWidth = 18,
		imageHeight = 18,
		width = O:GetWidth(18),
		func = "CreateAlert",
		order = 6
	}
	o.spacer3 = O:CreateSpacer(7, 0.4)
	o.delete_alert = {
		type = "execute",
		name = "",
		image = "Interface\\AddOns\\AlertMe\\Media\\Textures\\delete.tga",
		imageWidth = 18,
		imageHeight = 18,
		width = O:GetWidth(18),
		func = "DeleteAlert",
		order = 8,
		confirm = true,
		confirmText = "Do you really want to delete this alert?"
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
	O:SetOption(info, key)
end

-- function O:DrawAlertDetails(info, key)
-- 	local path, key_ = O:GetInfoPath(info)
-- 	VDT_AddData(path,"path")
-- 	dprint(1, key, key_)
-- end

function O:CreateAlert(info)
	local path,_ = O:GetInfoPath(info)
	local uid = time()
	path.alerts[uid] = "New Alert"
	path.select_alert = uid
end

function O:DeleteAlert(info)
	local path,_ = O:GetInfoPath(info)
	if path.alerts[path.select_alert] ~= nil then
		path.alerts[path.select_alert] = nil
		for uid,_ in pairs(path.alerts) do
			if uid ~= nil then
				path.select_alert = uid
				return
			end
		end
		path.select_alert = nil
	end
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
	VDT_AddData(info,"info")
	local uid = path.select_alert
	if uid == nil then
		return true
	end
	return false
end

function O:DisableAlertDetails(info)
	local uid = A.db.profile.alerts[info[2]].select_alert
	VDT_AddData(info,"info")
	if uid == nil then
		return true
	end
	return false
end

function O:GetWidth(pixel)
	return (1/170*pixel)
end
