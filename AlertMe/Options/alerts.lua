dprint(2, "alerts.lua")
-- upvalues
local _G, dprint, type, unpack, pairs, time, tostring, xpcall = _G, dprint, type, unpack, pairs, time, tostring, xpcall
-- get engine environment
local A, _, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the general options tab
function O:ShowAlerts(container, event_short)
	dprint(2, "O:DrawAlertsOptions", event_short)
	VDT_AddData(container, "alerts")
	container:ReleaseChildren()
	-- set db to db for this event
	local db = P.alerts[event_short]
	-- alerts dropdown
	local label = "Alerts - "..A:GetEventSettingByShort(event_short, "options_name")
	O.alert_dropdown = O:AttachDropdown(container, label, db, "alert_dd_value", db.alert_dd_list, 270)
	-- spacer
	O:AttachSpacer(container, 10)
	-- add alert
	local icon_add = O:AttachIcon(container, "Interface\\AddOns\\AlertMe\\Media\\Textures\\add.tga", 18)
	icon_add:SetCallback("OnClick", function(widget, event, value)
		local uid = tostring(time()) -- create uid (time)
		O.alert_dropdown:AddItem(uid, "New alert") -- add new entry to the dropdown list (automatically saved in db)
		O.alert_dropdown:SetList(O.alert_dropdown.list)
		O.alert_dropdown:SetValue(uid) -- set dropdown to new value
		db.alert_details[uid].dummy = 5 -- create entry in alert_details db
		O.alert_dropdown:Fire("OnValueChanged", uid) -- fire changed event to save the value in the db
		-- alert details
		O:ShowAlertDetails(O.alert_details, event_short, db)
	end)
	-- spacer
	O:AttachSpacer(container, 10)
	-- delete alert
	local icon_delete = O:AttachIcon(container, "Interface\\AddOns\\AlertMe\\Media\\Textures\\delete.tga", 18)
	icon_delete:SetCallback("OnClick", function()
		--dprint(1,"O:DeleteAlert", widget, event, button)
		local uid = db["alert_dd_value"]
		if O.alert_dropdown.list[uid] ~= nil and O.alert_dropdown.list[uid] ~= "" then
			O.alert_dropdown.list[uid] = nil
			O.alert_dropdown:SetList(O.alert_dropdown.list)
			local new_uid = O:GetLastAlert(O.alert_dropdown.list) -- get another uid
			O.alert_dropdown:SetValue(new_uid) -- and set it in dd
			O.alert_dropdown:Fire("OnValueChanged", new_uid) -- fire onchanged to save in db
		end
		if db.alert_details[uid] ~= nil then db.alert_details[uid] = nil end -- delete alert details also
		-- alert details
		O:ShowAlertDetails(O.alert_details, event_short, db)
	end)
	-- spacer
	O:AttachSpacer(container, 10)
	-- editbox for alertname
	O.alert_name = O:AttachEditBox(container, "Name of the selected alert", O.alert_dropdown.list, O.alert_dropdown.value, 250)
	-- spacer
	O:AttachSpacer(container, 10)
	-- active checkbox
	O.alert_active = O:AttachAlertSettingCheckBox(container, "Active", db, "active", 70)
	-- set callbacks for dropdown now that all controls exist
	O.alert_dropdown:SetCallback("OnValueChanged", function(widget, event, value)
		local uid = value
		db["alert_dd_value"] = uid
		O.alert_name:SetText(O.alert_dropdown.list[uid])
		O.alert_active:SetValue(db.alert_details[uid].active)
		if uid == "" then
			O.alert_name:SetDisabled(true)
			O.alert_active:SetDisabled(true)
		else
			O.alert_name:SetDisabled(false)
			O.alert_active:SetDisabled(false)
		end
		-- alert details
		O:ShowAlertDetails(O.alert_details, event_short, db)
	end)
	-- callback for editbox
	O.alert_name:SetCallback("OnEnterPressed", function(widget, event, text)
		O.alert_dropdown.list[O.alert_dropdown.value] = text
		O.alert_dropdown:SetList(O.alert_dropdown.list)
		O.alert_dropdown:SetText(text)
	end)
	if O.alert_dropdown.value == nil or O.alert_dropdown.value == "" then
		O.alert_name:SetDisabled(true)
		O.alert_active:SetDisabled(true)
	else
		O.alert_name:SetDisabled(false)
		O.alert_active:SetDisabled(false)
	end
	-- create details group
	O.alert_details = O:AttachGroup(container, "", false)
	-- draw alert details
	O:ShowAlertDetails(O.alert_details, event_short, db)
end

function O:GetLastAlert(list)
	local last_uid = ""
	for uid, v in pairs(list) do
		last_uid = uid
	end
	return last_uid
end

function O:AttachAlertSettingCheckBox(container, name, db, key, width)
	local control = A.Libs.AceGUI:Create("CheckBox")
	local uid = db["alert_dd_value"]
	if uid ~= nil then
		control:SetValue(db.alert_details[uid][key])
		control:SetDisabled(false)
	else
		control:SetDisabled(true)
	end
	control:SetUserData("db", db)
	control:SetUserData("key", key)
	control:SetCallback("OnValueChanged", function(widget, event) O:AlertSettingCheckBoxOnChange(widget, event) end)
	control:SetLabel(name)
	if width then control:SetWidth(width) end
	container:AddChild(control)
	return control

end

function O:AlertSettingCheckBoxOnChange(widget, event)
	local db = widget:GetUserData("db")
	local key = widget:GetUserData("key")
	local uid = db["alert_dd_value"]
	db.alert_details[uid][key] = widget.checked
end
