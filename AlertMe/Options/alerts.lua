dprint(2, "events.lua")
-- upvalues
local _G = _G
local dprint, tinsert, pairs = dprint, table.insert, pairs
-- get engine environment
local A, D, O = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the alerts options tab
function O:CreateAlertOptions(o)
	-- loop over events that need to be displayed
	for event_id, tbl in pairs(A.Events) do
		if tbl.options_display ~= nil and tbl.options_display == true then
			O:DrawAlertOptions(o, tbl.handle, tbl.options_name, tbl.options_order)
		end
	end
end

function O:DrawAlertOptions(o, handle, name, order)
	--  create group
	o[handle] = O:CreateGroup(name, nil, order)
	-- create header
	o[handle].args.header = O:CreateHeader(name)
	-- attach to options
	o[handle].args.alert_control = O:GetAlertControl()
end

function O:CreateAlert(info, value)
	local i = 1
	local path = A.db.profile
	while info[i] ~= nil and info[i] ~= "create_alert" do
		path = path[info[i]]
		i = i + 1
	end
	-- save last input
	path.create_alert = value
	tinsert(path["alerts"], value)
end

function O:GetAlertList(info)
	return A.db.profile.alerts[info[2]].alert_control.alerts
end

function O:GetLastEntry(info)
	return #A.db.profile.alerts[info[2]].alert_control.alerts
end

-- provides a standard control for adding, selecting and deleting alerts
function O:GetAlertControl()
	local alert_control = {
		type = "group",
		name = "",
		inline = true,
		order = 2,
		args = {
			select_alert = {
				type = "select",
				style = "dropdown",
				name = "Alert",
				order = 1,
				width = 2,
				values = "GetAlertList",
				get = "GetLastEntry"
			},
			create_alert = {
				type = "input",
				name = "New alert",
				desc = "Name of new alert",
				order = 2,
				width = 2,
				get = function(info) return "" end,
				set = "CreateAlert"
			},

		}
	}
	return alert_control
end
