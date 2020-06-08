dprint(2, "events.lua")
-- upvalues
local _G = _G
local dprint, tinsert, pairs, uuid = dprint, table.insert, pairs, uuid
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
	O:AttachAlertControl(o.args, name)
end

function O:AttachAlertControl(o, name)
	o.header = O:CreateHeader(name)
	o.create_alert = {
		type = "input",
		name = "New alert",
		order = 2,
		width = 2,
		get = function(info) return "" end,
		set = "CreateAlert"
	}
	o.spacer = O:CreateSpacer(3, 1)
	o.select_alert = {
		type = "select",
		name = "Alert",
		style = "dropdown",
		order = 3,
		width = 2.1,
		values = "GetAlertList",
		set = "SetAlert",
	}
end

function O:SetAlert(info, key)
	-- save value standard
	O:SetOption(info, key)
	O:DrawAlertDetails(info, key)
end

function O:DrawAlertDetails(info, key)
	local path, key_ = O:GetInfoPath(info)
	VDT_AddData(path,"path")
	dprint(1, key, key_)
end

function O:CreateAlert(info, value)
	local path,_ = O:GetInfoPath(info)
	local uid = uuid()
	path.alerts[uid] = value
	path.select_alert = uid
end

function O:GetAlertList(info)
	local path,key = O:GetInfoPath(info)
	return path.alerts
end

function O:GetAlert(info)
	local path,key = O:GetInfoPath(info)
	return #path.alerts
end
