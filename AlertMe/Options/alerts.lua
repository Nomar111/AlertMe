dprint(2, "events.lua")
-- upvalues
local _G = _G
local dprint, tinsert, pairs = dprint, table.insert, pairs
-- get engine environment
local A, _, O = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the alerts options tab
function O:CreateAlertOptions(o)		--O.options.args.alerts.args
	-- loop over events that need to be displayed
	for _, tbl in pairs(A.Events) do
		if tbl.options_display ~= nil and tbl.options_display == true then
			O:DrawAlertOptions(o, tbl.handle, tbl.options_name, tbl.options_order)
		end
	end
end

function O:DrawAlertOptions(o, handle, name, order)
	o[handle] = O:CreateGroup(name, nil, order, "select")
	o[handle].args.alert_control =  O:GetAlertControl()
	o[handle].args.alert1 = O:CreateGroup("Alert1")
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
		--inline = true,
		order = 2,
		args = {
			description = {
				type = "description",
				name = "New Alert: ",
				order = 1,
				width = 0.4,
				fontSize = "medium",
			},
			create_alert = {
				type = "input",
				name = "",
				order = 2,
				width = 2,
				get = function(info) return "" end,
				set = "CreateAlert"
			},
			spacer = O:CreateSpacer(3,5),
			delete_alert = {
				type = "execute",
				name = "delete",
				width = 0.4,
				order = 9,
				func = function() return end
			},
			fullspacer = {
				type = "description",
				name = "M",
				width = "full",
				order = 99
			}
		}
	}
	return alert_control
end
