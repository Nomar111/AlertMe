-- upvalues
local _G, time, tostring = _G, time, tostring
-- set addon environment
setfenv(1, _G.AlertMe)

local function getSomeAlert(eventShort)
	local _uid = ""
	for uid, details in pairs(P.alerts[eventShort].alertDetails) do
		if details.created then
			_uid = uid
		end
	end
	return _uid
end

local function createAlertList(eventShort)
	local list = {}
	for uid, details in pairs(P.alerts[eventShort].alertDetails) do
		if details.created then
			list[uid] = details.name
		end
	end
	return list
end

-- creates the general options tab
function O:ShowAlerts(container, eventShort)
	-- clear container so it can call itself
	container:ReleaseChildren()
	-- some local variables
	local db = P.alerts[eventShort]
	local uid = db.selectedAlert
	local iconAdd = A.Backgrounds["AlertMe_Add"]
	local iconDel = A.Backgrounds["AlertMe_Delete"]
	local btnAddToolTip = {lines = {"Add new alert"}}
	local btnDelToolTip = {lines = {"Delete selected alert"}}
	-- local functions
	local function refresh()
		O:ShowAlerts(container, eventShort)
	end
	local function btnAddOnClick()
		local _uid = tostring(time()) -- create uid (time)
		db.alertDetails[_uid].created = true -- create entry in alert details
		db.selectedAlert = _uid
		refresh()
	end
	local function btnDelOnClick()
		local _uid = db.selectedAlert
		if db.alertDetails[_uid] then
			db.alertDetails[_uid] = nil
		end
		db.selectedAlert = getSomeAlert(eventShort) -- get another uid
		refresh()
	end
	-- *************************************************************************************
	-- Top of page
	local topGroup = O.AttachGroup(container, "simple", _, {fullWidth = true})
	-- alert dropdown
	local label = "Alerts - "..A.EventsShort[eventShort].optionsText
	local ddAlert = O.AttachDropdown(topGroup, label, db, "selectedAlert", createAlertList(eventShort), 230, refresh)
	if uid ~= "" then ddAlert:SetValue(db.selectedAlert) end
	O.AttachSpacer(topGroup, 20)
	-- editbox for alertname
	local editBox = O.AttachEditBox(topGroup, "Name of the selected alert", db.alertDetails[uid], "name", 210, refresh)
	if db.alertDetails[uid].created == true then
		editBox:SetText(db.alertDetails[uid].name)
	else
		editBox:SetText("")
		editBox:SetDisabled(true)
	end
	O.AttachSpacer(topGroup, 10)
	-- add alert
	O.AttachIcon(topGroup, iconAdd, 18, btnAddOnClick, btnAddToolTip)
	O.AttachSpacer(topGroup, 10)
	-- delete alert
	O.AttachIcon(topGroup, iconDel, 18, btnDelOnClick, btnDelToolTip)
	O.AttachSpacer(topGroup, 10)
	-- active checkbox
	local cbActive = O.AttachCheckBox(topGroup, "Active", db.alertDetails[uid] ,"active", 70)
	if db.alertDetails[uid].created == true then
		cbActive:SetValue(db.alertDetails[uid].active)
	else
		cbActive:SetValue(nil)
		cbActive:SetDisabled(true)
	end
	-- show alert details
	if uid and uid ~= "" then
		O:ShowAlertDetails(container, eventShort, uid)
	end
end
