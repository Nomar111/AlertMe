dprint(2, "alerts.lua")
-- upvalues
local _G, dprint, type, unpack, pairs, time, tostring, xpcall = _G, dprint, type, unpack, pairs, time, tostring, xpcall
-- get engine environment
local A, _, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the general options tab
function O:DrawAlertsOptions(container, event)
	dprint(1, "O:DrawAlertsOptions", event)
	VDT_AddData(container, "alerts")
	container:ReleaseChildren()
	-- set path to db for this event
	local path = P.alerts_db[event]
	O.event = event
	-- header
	O:AttachHeader(container, "Alert settings - "..A:GetEventSettingByShort(event, "options_name"))
	-- alerts dropdown
	O:AttachAlertsDropdown(container, path, 270)
	-- spacer
	O:AttachSpacer(container, 10)
	-- add icon
	local icon_add = O:AttachIcon(container, path, "Interface\\AddOns\\AlertMe\\Media\\Textures\\add.tga", 18)
	icon_add:SetCallback("OnClick", function(widget, event, button) O:CreateAlert(widget, event, button) end)
	-- spacer
	O:AttachSpacer(container, 10)
	-- delete icon
	local icon_delete = O:AttachIcon(container, path, "Interface\\AddOns\\AlertMe\\Media\\Textures\\delete.tga", 18)
	icon_delete:SetCallback("OnClick", function(widget, event, button) O:DeleteAlert(widget, event, button) end)
	-- spacer
	O:AttachSpacer(container, 10)
	-- editbox for alertname
	O:AttachNameEdit(container, path, 250)
	-- spacer
	O:AttachSpacer(container, 10)
	-- active checkbox
	O:AttachAlertSettingCheckBox(container, "Active", path, "active", 70)
	-- create details group
	O.alert_details = O:AttachGroup(container, "", false)
	-- draw alert details
	O:DrawAlertDetails(O.alert_details, O.event)
end

function O:AttachDropdown(container, path, width)
	local dropdown = A.Libs.AceGUI:Create("Dropdown")
	dropdown:SetLabel("Alerts")
	dropdown:SetMultiselect(false)
	dropdown:SetWidth(width)
	-- get list of alerts and some valid entry
	local list, uid = O:GetAlertList(path)
	dropdown:SetList(list)
	dropdown:SetValue(uid)
	-- set currently selected alert (redundant info, but needed for the control to remember its last state)
	path["selected_alert"] = uid
	dropdown:SetUserData("path", path)
	dropdown:SetCallback("OnValueChanged", function(widget) O:AlertsDropDownOnChange(widget) end)
	O.alerts_dropdown = dropdown
	container:AddChild(dropdown)	--VDT_AddData(dropdown,"dropdown")
	return dropdown
end

function O:AttachAlertsDropdown(container, path, width)
	local dropdown = A.Libs.AceGUI:Create("Dropdown")
	dropdown:SetLabel("Alerts")
	dropdown:SetMultiselect(false)
	dropdown:SetWidth(width)
	-- get list of alerts and some valid entry
	local list, uid = O:GetAlertList(path)
	dropdown:SetList(list)
	dropdown:SetValue(uid)
	-- set currently selected alert (redundant info, but needed for the control to remember its last state)
	path["selected_alert"] = uid
	dropdown:SetUserData("path", path)
	dropdown:SetCallback("OnValueChanged", function(widget) O:AlertsDropDownOnChange(widget) end)
	O.alerts_dropdown = dropdown
	container:AddChild(dropdown)	--VDT_AddData(dropdown,"dropdown")
	return dropdown
end

function O:AlertsDropDownOnChange(widget, event)
	dprint(1,"AlertsDropDownOnChange")
	local path = widget:GetUserData("path")
	path["selected_alert"] = widget.value
	-- keep editbox and checkbox in synch
	O.name_edit:SetDisabled(false)
	O.name_edit:SetText(O.alerts_dropdown.text:GetText())
	O.alert_active:SetDisabled(false)
	O.alert_active:SetValue(path.alerts[widget.value].active)
	-- details
	O:DrawAlertDetails(O.alert_details, O.event)
end

function O:AttachIcon(container, path, image, size)
	local icon = A.Libs.AceGUI:Create("Icon")
	icon:SetImage(image)
	icon:SetImageSize(size, size)
	icon:SetUserData("path", path)
	icon:SetWidth(size)
	container:AddChild(icon)
	return icon
end

function O:CreateAlert(widget, event, button)
	--dprint(1, "CreateAlert", widget, event, button)
	-- get unique (time) id
	local uid = tostring(time())
	local path = widget:GetUserData("path")
	-- create new entry in the table
	path.alerts[uid].dummy = 1
	-- get updated alerts list and set it to dropdown
	local list = O:GetAlertList(path)
	O.alerts_dropdown:SetList(list)
	-- set dropdown to the new alert uid
	path["selected_alert"] = uid
	O.alerts_dropdown:SetValue(uid)
	-- keep editbox in synch
	O.name_edit:SetDisabled(false)
	O.name_edit:SetText(O.alerts_dropdown.text:GetText())
	O.alert_active:SetDisabled(false)
	O.alert_active:SetValue(path.alerts[uid].active)
	-- details
	O:DrawAlertDetails(O.alert_details, O.event)
end

function O:DeleteAlert(widget, event, button)
	--dprint(1,"O:DeleteAlert", widget, event, button)
	local path = widget:GetUserData("path")
	local uid = path["selected_alert"]
	-- delete uid from alerts table
	if path.alerts[uid] ~= nil then
		path.alerts[uid] = nil
		-- get and assign new alerts list and maybe some valid uid if there is one left
		local list, someuid = O:GetAlertList(path)
		O.alerts_dropdown:SetList(list)
		path["selected_alert"] = someuid
		O.alerts_dropdown:SetValue(someuid)
		if someuid ~= nil then
			-- keep editbox in synch
			O.name_edit:SetDisabled(false)
			O.name_edit:SetText(O.alerts_dropdown.text:GetText())
			O.alert_active:SetDisabled(false)
			O.alert_active:SetValue(path.alerts[someuid].active)
		else
			O.name_edit:SetDisabled(true)
			O.name_edit:SetText("")
			O.alert_active:SetValue(false)
			O.alert_active:SetDisabled(true)
		end
		-- details
		O:DrawAlertDetails(O.alert_details, O.event)
	end
end

function O:GetAlertList(path)
	local list = {}
	local last_uid = nil
	for uid, v in pairs(path.alerts) do
		list[uid] = v.name
		last_uid = uid
	end
	return list, last_uid
end

function O:AttachNameEdit(container, path, width)
	local edit = A.Libs.AceGUI:Create("EditBox")
	edit:SetText(O.alerts_dropdown.text:GetText())
	if O.alerts_dropdown.text:GetText() == nil or O.alerts_dropdown.text:GetText() == "" then
		edit:SetDisabled(true)
	end
	edit:SetLabel("Name of the selected alert")
	edit:SetUserData("path", path)
	edit:SetCallback("OnEnterPressed", function(widget, event, text) O:OnNameEditEnter(widget, event, text) end)
	edit:SetWidth(width)
	O.name_edit = edit
	container:AddChild(edit)
	return edit
end

function O:OnNameEditEnter(widget, event, text)
	local path = widget:GetUserData("path")
	local uid = path["selected_alert"]
	if path.alerts[uid] ~= nil then
		path.alerts[uid].name = text
		local list = O:GetAlertList(path)
		O.alerts_dropdown:SetList(list)
		O.alerts_dropdown:SetValue(uid)
	end
end

function O:AttachAlertSettingCheckBox(container, name, path, key, width)
	local control = A.Libs.AceGUI:Create("CheckBox")
	local uid = path["selected_alert"]
	if uid ~= nil then
		control:SetValue(path.alerts[uid][key])
	else
		control:SetDisabled(true)
	end
	control:SetUserData("path", path)
	control:SetUserData("key", key)
	control:SetCallback("OnValueChanged", function(widget, event) O:AlertSettingCheckBoxOnChange(widget, event) end)
	control:SetLabel(name)
	if width then control:SetWidth(width) end
	container:AddChild(control)
	O.alert_active = control
	return control
end

function O:AlertSettingCheckBoxOnChange(widget, event)
	local path = widget:GetUserData("path")
	local key = widget:GetUserData("key")
	local uid = path["selected_alert"]
	path.alerts[uid][key] = widget.checked
end
