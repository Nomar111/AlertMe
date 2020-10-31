-- upvalues
local _G, time, tostring = _G, time, tostring
-- set addon environment
setfenv(1, _G.AlertMe)

local function getSomeAlert(eventShort)
	local _uid = ""
	for uid, details in pairs(P.alerts[eventShort].alertDetails) do
		if details.created == true then
			_uid = uid
		end
	end
	return _uid
end

local function createAlertList(eventShort)
	local list = {}
	for uid, details in pairs(P.alerts[eventShort].alertDetails) do
		if details.created == true then
			list[uid] = details.name
		end
	end
	return list
end

-- creates the general options tab
function O:showAlerts(container, eventShort)
	-- clear container so it can call itself
	container:ReleaseChildren()
	-- some local variables
	local db = P.alerts[eventShort]
	local uid = db.selectedAlert
	-- local functions
	local function refresh()
		O:showAlerts(container, eventShort)
	end
	local add = function()
		local _uid = tostring(time()) -- create uid (time)
		db.alertDetails[_uid].created = true -- create entry in alert details
		db.selectedAlert = _uid
		refresh()
	end
	local delete = function()
		local _uid = db.selectedAlert
		if db.alertDetails[_uid] then
			db.alertDetails[_uid] = nil
		end
		db.selectedAlert = getSomeAlert(eventShort) -- get another uid
		refresh()
	end
	-- *************************************************************************************
	-- Top of page
	local topGroup = O.attachGroup(container, "simple", _, {fullWidth = true})
	-- alert dropdown
	local label = "Alerts - "..A.EventsShort[eventShort].optionsText
	local ddAlert = O.attachDropdown(topGroup, label, db, "selectedAlert", createAlertList(eventShort), 230, refresh)
	if uid and uid ~= "" then ddAlert:SetValue(db.selectedAlert) end
	O.attachSpacer(topGroup, 20)
	-- editbox for alertname
	if db.alertDetails[uid].created == true then
		local editBox = O.attachEditBox(topGroup, "Name of the selected alert", db.alertDetails[uid], "name", 210, refresh)
		editBox:SetText(db.alertDetails[uid].name)
	else
		local editBox = O.attachEditBox(topGroup, "Name of the selected alert", P.dummy, "name", 210, refresh)
		editBox:SetText("")
		editBox:SetDisabled(true)
	end
	O.attachSpacer(topGroup, 10)
	-- add alert
	local texture, tooltip = A.backgrounds["AlertMe_Add"],  { lines = {"Add new alert"} }
	O.attachIcon(topGroup, texture, 18, add, tooltip)
	O.attachSpacer(topGroup, 10)
	-- delete alert
	texture, tooltip = A.backgrounds["AlertMe_Delete"],  { lines = {"Delete selected alert"} }
	O.attachIcon(topGroup, texture, 18, delete, tooltip)
	O.attachSpacer(topGroup, 8)
	-- active checkbox
	if db.alertDetails[uid].created == true then
		local cbActive = O.attachCheckBox(topGroup, "Active", db.alertDetails[uid] ,"active", 65)
		cbActive:SetValue(db.alertDetails[uid].active)
	end
	-- show alert details
	if uid and uid ~= "" then
		O:showAlertDetails(container, eventShort, uid)
	end
end
