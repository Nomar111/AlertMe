dprint(2, "events.lua")
-- upvalues
local _G = _G
local dprint, tinsert = dprint, table.insert
-- get engine environment
local A, D, O = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the alerts options tab
function O:CreateAlerts(o)
	--  event control
		o.gain = O:CreateGroup("On aura gain", _, true)
	o.dispel = O:CreateGroup("On spell dispel")
	o.start = O:CreateGroup("On cast start")
	o.success = O:CreateGroup("On cast success")
	o.interrupt = O:CreateGroup("On interrupt")
	o.gain.args.header = O:CreateHeader("On aura gain & refresh")
	o.dispel.args.header = O:CreateHeader("On spell dispel")
	o.start.args.header = O:CreateHeader("On spell cast start")
	o.success.args.header = O:CreateHeader("On spell cast success")
	o.interrupt.args.header = O:CreateHeader("On interrupt")
	-- attach to options
	local event_control = {
		type = "group",
		name = "",
		inline = true,
		order = 2,
		args = {
			create_alert = {
				type = "input",
				name = "New alert",
				desc = "Name of new alert",
				order = 1,
				width = "double",
				get = function(info) return "" end,
				set = "CreateAlert"
			},
			select_alert = {
				type = "select",
				name = "Alert",
				values = "GetAlertList",
				style = "dropdown",
				get = "GetLastEntry"
			}
		}
	}
	o.gain.args.event_control = event_control
	o.dispel.args.event_control = event_control
	o.start.args.event_control = event_control
	o.success.args.event_control = event_control
	o.interrupt.args.event_control = event_control
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
	return A.db.profile.alerts[info[2]].event_control.alerts
end

function O:GetLastEntry(info)
	return #A.db.profile.alerts[info[2]].event_control.alerts
end
