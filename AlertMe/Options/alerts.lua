dprint(2, "alerts.lua")
-- upvalues
local _G, dprint, type, unpack, pairs, time, tostring, xpcall = _G, dprint, type, unpack, pairs, time, tostring, xpcall
-- get engine environment
local A, _, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the general options tab
function O:DrawAlertsOptions(container, event_short)
	dprint(1, "O:DrawAlertsOptions", event_short)
	VDT_AddData(container, "alerts")
	container:ReleaseChildren()
	-- set db to db for this event
	local db = P.alerts[event_short]
	-- alerts dropdown
	local label = "Alerts - "..A:GetEventSettingByShort(event_short, "options_name")
	O.alert_dropdown = O:AttachDropdown(container, label, db, "alert_dd_value", db.alert_dd_list, 270)
	O.alert_dropdown:SetCallback("OnValueChanged", function(widget, event, value)
		db["alert_dd_value"] = value
		O.alert_name:SetText(O.alert_dropdown.list[value])
		if value == "" then O.alert_name:SetDisabled(true) else O.alert_name:SetDisabled(false) end
		-- Draw Alert Options !!!!!!!!
	end)
	-- spacer
	O:AttachSpacer(container, 10)
	-- add alert
	local icon_add = O:AttachIcon(container, "Interface\\AddOns\\AlertMe\\Media\\Textures\\add.tga", 18)
	icon_add:SetCallback("OnClick", function(widget, event, value)
		local uid = tostring(time()) -- create uid (time)
		O.alert_dropdown:AddItem(uid, "New alert") -- add new entry to the dropdown list (automatically saved in db)
		O.alert_dropdown:SetList(O.alert_dropdown.list)
		O.alert_dropdown:SetValue(uid) -- set dropdown to new value
		O.alert_dropdown:Fire("OnValueChanged", uid) -- fire changed event to save the value in the db
		O.alert_name:SetText("New alert")
		db.alert_details[uid].dummy = 5 -- create entry in alert_details db
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
	end)
	-- spacer
	O:AttachSpacer(container, 10)
	-- editbox for alertname
	O.alert_name = O:AttachEditBox(container, "Name of the selected alert", O.alert_dropdown.list, O.alert_dropdown.value, 250)
	O.alert_name:SetCallback("OnEnterPressed", function(widget, event, text)
		O.alert_dropdown.list[O.alert_dropdown.value] = text
		O.alert_dropdown:SetList(O.alert_dropdown.list)
		O.alert_dropdown:SetText(text)
	end)
	if O.alert_dropdown.value == nil or O.alert_dropdown.value == "" then O.alert_name:SetDisabled(true) else O.alert_name:SetDisabled(false) end
	-- spacer
	O:AttachSpacer(container, 10)
	-- active checkbox
	--O:AttachAlertSettingCheckBox(container, "Active", db, "active", 70)
	-- create details group
	--O.alert_details = O:AttachGroup(container, "", false)
	-- draw alert details
	--O:DrawAlertDetails(O.alert_details, O.event)
end

function O:GetLastAlert(list)
	local last_uid = ""
	for uid, v in pairs(list) do
		last_uid = uid
	end
	return last_uid
end

function O:AttachEditBox(container, label, path, key, width)
	local edit = A.Libs.AceGUI:Create("EditBox")
	edit:SetLabel(label)
	if width ~= nil then edit:SetWidth(width) end
	edit:SetText(path[key])
	edit:SetCallback("OnEnterPressed", function(widget, event, text) path[key] = text end)
	container:AddChild(edit)
	return edit
end

function O:EditBoxOnEnter(widget, event, text)
	dprint(1, "EditBoxOnEnter", widget, event, text)
	--if S.cache[text] == nil then dprint(1, "No such spellname found") end
	local path = widget:GetUserData("path")
	local key = widget:GetUserData("key")
	dprint(1, key)
	if key == "spell_add" then
		O:UpdateSpellNames(text, path)
		widget:SetText("")
	else
		path[key] = text
	end
end









function O:AttachNameEdit(container, db, width)
	local edit = A.Libs.AceGUI:Create("EditBox")
	edit:SetText(O.alerts_dropdown.text:GetText())
	if O.alerts_dropdown.text:GetText() == nil or O.alerts_dropdown.text:GetText() == "" then
		edit:SetDisabled(true)
	end
	edit:SetLabel("Name of the selected alert")
	edit:SetUserData("db", db)
	edit:SetCallback("OnEnterPressed", function(widget, event, text) O:OnNameEditEnter(widget, event, text) end)
	edit:SetWidth(width)
	O.name_edit = edit
	container:AddChild(edit)
	return edit
end

function O:OnNameEditEnter(widget, event, text)
	local db = widget:GetUserData("db")
	local uid = db["selected_alert"]
	if db.alerts[uid] ~= nil then
		db.alerts[uid].name = text
		local list = O:GetAlertList(db)
		O.alerts_dropdown:SetList(list)
		O.alerts_dropdown:SetValue(uid)
	end
end

function O:AttachAlertSettingCheckBox(container, name, db, key, width)
	local control = A.Libs.AceGUI:Create("CheckBox")
	local uid = db["selected_alert"]
	if uid ~= nil then
		control:SetValue(db.alerts[uid][key])
	else
		control:SetDisabled(true)
	end
	control:SetUserData("db", db)
	control:SetUserData("key", key)
	control:SetCallback("OnValueChanged", function(widget, event) O:AlertSettingCheckBoxOnChange(widget, event) end)
	control:SetLabel(name)
	if width then control:SetWidth(width) end
	container:AddChild(control)
	O.alert_active = control
	return control
end

function O:AlertSettingCheckBoxOnChange(widget, event)
	local db = widget:GetUserData("db")
	local key = widget:GetUserData("key")
	local uid = db["selected_alert"]
	db.alerts[uid][key] = widget.checked
end
