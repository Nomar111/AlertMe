dprint(2, "alerts.lua")
-- upvalues
local _G, time, tostring = _G, time, tostring
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the general options tab
function O:ShowAlerts(container, eventShort)
	dprint(2, "O:ShowAlerts", eventShort)
	-- clear container so it can call itself
	container:ReleaseChildren()
	-- some local variables
	local iconAdd = A.LSM:HashTable("background")["Add"]
	local iconDelete = A.LSM:HashTable("background")["Delete"]
	local db = P.alerts[eventShort]
	local uid = db.selectedAlert
	local function refresh()
		O:ShowAlerts(container, eventShort)
	end

	-- top group
	local topGroup = O:AttachGroup(container, _, _, 1)

	-- alert dropdown
	local label = "Alerts - "..A:GetEventSettingByShort(eventShort, "optionsText")
	local ddAlert = O:AttachDropdown(topGroup, label, db, "selectedAlert", O:CreateAlertList(eventShort), 230, refresh)
	if uid ~= "" then ddAlert:SetValue(db.selectedAlert) end
	O:AttachSpacer(topGroup, 10)

	-- add alert
	local btnAdd = O:AttachIcon(topGroup, iconAdd, 18)
	btnAdd:SetCallback("OnClick", function(widget, event, value)
		local _uid = tostring(time()) -- create uid (time)
		db.alertDetails[_uid].created = true -- create entry in alert details
		db.selectedAlert = _uid
		refresh()
	end)
	O:AttachSpacer(topGroup, 10)

	-- delete alert
	local btnDelete = O:AttachIcon(topGroup, iconDelete, 18)
	btnDelete:SetCallback("OnClick", function()
		--dprint(1,"O:DeleteAlert", widget, event, button)
		local _uid = db.selectedAlert
		if db.alertDetails[_uid] ~= nil then
			db.alertDetails[_uid] = nil
		end
		db.selectedAlert = O:GetSomeAlert(eventShort) -- get another uid
		refresh()
	end)
	O:AttachSpacer(topGroup, 10)

	-- editbox for alertname
	local editBox = O:AttachEditBox(topGroup, "Name of the selected alert", db.alertDetails[uid], "name", 210, refresh)
	if db.alertDetails[uid].created == true then
		editBox:SetText(db.alertDetails[uid].name)
	else
		editBox:SetText("")
		editBox:SetDisabled(true)
	end
	O:AttachSpacer(topGroup, 10)

	-- active checkbox
	local cbActive = O:AttachCheckBox(topGroup, "Active", db.alertDetails[uid] ,"active", 70)
	if db.alertDetails[uid].created == true then
		cbActive:SetValue(db.alertDetails[uid].active)
	else
		cbActive:SetValue(nil)
		cbActive:SetDisabled(true)
	end
	--O:AttachCheckBox(container, "Active", db, "active", 70)
	-- -- create details group
	-- O.Alert.DetailsGroup = O:AttachGroup(container, "", false)
	-- -- draw alert details
	-- O:ShowAlertDetails(O.Alert.DetailsGroup, eventShort, db)
end

function O:GetSomeAlert(eventShort)
	dprint(2, "O:GetSomeAlert", eventShort)
	local _uid = ""
	for uid, details in pairs(P.alerts[eventShort].alertDetails) do
		if details.created == true then
			_uid = uid
		end
	end
	return _uid
end

function O:CreateAlertList(eventShort)
	dprint(2, "O:CreateAlertList", eventShort)
	local list = {}
	for uid, details in pairs(P.alerts[eventShort].alertDetails) do
		if details.created == true then
			list[uid] = details.name
		end
	end
	return list
end
