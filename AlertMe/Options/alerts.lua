dprint(2, "alerts.lua")
-- upvalues
local _G, dprint, type, unpack, pairs, time, tostring = _G, dprint, type, unpack, pairs, time, tostring
-- get engine environment
local A, _, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the general options tab
function O:DrawAlertsOptions(container, event)
	dprint(1, "O:DrawAlertsOptions", event)
	VDT_AddData(container, "alerts")
	-- header
	O:AttachHeader(container, "Alert settings "..event)
	-- set path to profile db for this event
	local path = P.alerts_db[event]

	local dropdown = A.Libs.AceGUI:Create("Dropdown")
	dropdown:SetLabel("Alerts")
	dropdown:SetMultiselect(false)
	dropdown:SetList(O:GetAlertList(path))
	dropdown:SetValue(path["select_alert"])
	dropdown:SetUserData("path", path)
	dropdown:SetCallback("OnValueChanged", function(widget) O:DropDownOnChange(widget) end)
	dropdown:SetCallback("OnEnter", function(widget) O:DropDownOnEnter(widget) end)
	path.dropdown = dropdown
	container:AddChild(dropdown)
	VDT_AddData(dropdown,"dropdown")
	-- icon
	local icon = A.Libs.AceGUI:Create("Icon")
	icon:SetImage("Interface\\AddOns\\AlertMe\\Media\\Textures\\add.tga")
	icon:SetImageSize(18,18)
	icon:SetUserData("path", path)
	icon:SetCallback("OnClick", function(widget) O:CreateAlert(widget) end)
	container:AddChild(icon)
end

function O:CreateAlert(widget, event)
	local uid = tostring(time())
	local path = widget:GetUserData("path")
	path.alerts[uid] = {name = "New alert "..uid, active = true}
	path.select_alert = uid
	path.dropdown:SetValue(path["select_alert"])
	path.dropdown:SetText("New alert "..uid)
end

function O:DropDownOnChange(widget, event)
	local path = widget:GetUserData("path")
	path["select_alert"] = widget.value
end

function O:DropDownOnEnter(widget)
	local path = widget:GetUserData("path")
	widget:SetList(O:GetAlertList(path))
end

function O:GetAlertList(path)
	local list = {}
	for uid, v in pairs(path.alerts) do
		list[uid] = v.name
	end
	return list
end
