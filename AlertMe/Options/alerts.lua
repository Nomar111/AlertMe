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
	local list, uid = O:GetAlertList(path)
	dropdown:SetList(list)
	dropdown:SetValue(uid)
	path["select_alert"] = uid
	dropdown:SetUserData("path", path)
	dropdown:SetCallback("OnValueChanged", function(widget) O:DropDownOnChange(widget) end)
	dropdown:SetWidth(250)
	path.dropdown = dropdown
	container:AddChild(dropdown)
	VDT_AddData(dropdown,"dropdown")
	-- spacer
	O:AttachSpacer(container, 10)
	-- icon
	local icon = A.Libs.AceGUI:Create("Icon")
	icon:SetImage("Interface\\AddOns\\AlertMe\\Media\\Textures\\add.tga")
	icon:SetImageSize(18,18)
	icon:SetUserData("path", path)
	icon:SetCallback("OnClick", function(widget) O:CreateAlert(widget) end)
	icon:SetWidth(18)
	container:AddChild(icon)

	O:AttachSpacer(container, 10)

	icon = A.Libs.AceGUI:Create("Icon")
	icon:SetImage("Interface\\AddOns\\AlertMe\\Media\\Textures\\delete.tga")
	icon:SetImageSize(18,18)
	icon:SetUserData("path", path)
	icon:SetCallback("OnClick", function(widget) O:DeleteAlert(widget) end)
	icon:SetWidth(18)
	container:AddChild(icon)

	O:AttachSpacer(container, 10)

	local edit = A.Libs.AceGUI:Create("EditBox")
	edit:SetText(path.dropdown.text:GetText())
	edit:SetLabel("Name of the alert")
	edit:SetUserData("path", path)
	edit:SetCallback("OnEnterPressed", function(widget, event, text) O:OnEnter(widget, event, text) end)
	edit:SetWidth(240)
	path.edit = edit
	container:AddChild(edit)
	--GetText() - Get the text in the edit box.

--SetDisabled(flag) - Disable the widget.
--DisableButton(flag) - True to disable the "Okay" button, false to enable it again.
--SetMaxLetters(num) - Set the maximum number of letters that can be entered (0 for unlimited).
--SetFocus() - Set the focus to the editbox.
--HighlightText(start, end) - Highlight the text in the editbox (see Blizzard EditBox Widget documentation for details)
-- OnTextChanged(text) - Fires on every text change.
-- OnEnterPressed(text) - Fires when the new text was confirmed and should be saved.
-- OnEnter() - Fires when the cursor enters the widget.
-- OnLeave() - Fires when the cursor leaves the widget.
end

function O:OnEnter(widget, event, text)
	local path = widget:GetUserData("path")
	local uid = path["select_alert"]
	if path.alerts[uid] ~= nil then
		path.alerts[uid].name = text
		local list = O:GetAlertList(path)
		path.dropdown:SetList(list)
		path.dropdown:SetValue(uid)
	end
end

function O:CreateAlert(widget, event)
	local uid = tostring(time())
	local path = widget:GetUserData("path")
	path.alerts[uid] = {name="New alert"}
	local list = O:GetAlertList(path)
	path.dropdown:SetList(list)
	path["select_alert"] = uid
	path.dropdown:SetValue(uid)
	path.edit:SetText(path.dropdown.text:GetText())
end

function O:DeleteAlert(widget, event)
	dprint(1,"O:DeleteAlert")
	local path = widget:GetUserData("path")
	local uid = path["select_alert"]
	--dprint(1,"uidtodlete", uid)
	if path.alerts[uid] ~= nil then
		path.alerts[uid] = nil
		local list, newuid = O:GetAlertList(path)
		path.dropdown:SetList(list)
		path["select_alert"] = newuid
		path.dropdown:SetValue(newuid)
		path.edit:SetText(path.dropdown.text:GetText())
	end
end

function O:DropDownOnChange(widget, event)
	dprint(1,"ddonchange")
	local path = widget:GetUserData("path")
	path["select_alert"] = widget.value
	path.edit:SetText(path.dropdown.text:GetText())
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
