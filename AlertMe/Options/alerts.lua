-- upvalues
local _G, time, tostring = _G, time, tostring
-- set addon environment
setfenv(1, _G.AlertMe)

local function getSomeAlert(handle)
	for uid, details in pairs(P.alerts[handle].alertDetails) do
		if details.created == true then
			return uid
		end
	end
end

local function createAlertList(handle)
	local list = {}
	if not P.alerts[handle] or not P.alerts[handle].alertDetails then
		return list -- no alert yet available? return empty table
	end
	for uid, details in pairs(P.alerts[handle].alertDetails) do
		if details.created == true then
			list[uid] = details.name
		end
	end
	return list
end

-- creates the general options tab
function O:showAlerts(container, handle)
	-- clear container so it can be called repeatedly
	container:ReleaseChildren()
	-- get last selected alert uid
	local db = P.alerts[handle]
	local uid = db.selectedAlert
	-- prepare functions for user interaction
	local function refresh()
		O:showAlerts(container, handle)
	end
	local add = function()
		local _uid = tostring(time())			-- create uid (time)
		db.alertDetails[_uid].created = true 	-- create entry in alert details
		db.selectedAlert = _uid
		refresh()
	end
	local delete = function()
		local _uid = db.selectedAlert
		if db.alertDetails[_uid] then
			db.alertDetails[_uid] = nil
		end
		db.selectedAlert = getSomeAlert(handle)	-- get another alert's uid, or set it to nil (=default if there is no alert)
		refresh()
	end
	-- *************************************************************************************
	-- Top of page
	local topGroup = O.attachGroup(container, "simple", _, {fullWidth = true})
	-- tries to set the saved vars for the currently seletected alert uid.
	-- if there is none (and selected == nil) then redirect to dummy
	local path = db.alertDetails[uid] or P.dummy
	-- alert dropdown
	local text = menus[handle].text or ""
	local label = "Alerts - "..text
	local widget = O.attachDropdown(topGroup, label, db, "selectedAlert", createAlertList(handle), 230, refresh)
	if uid then widget:SetValue(db.selectedAlert) end
	O.attachSpacer(topGroup, 20)
	-- editbox for alertname
	local edit = O.attachEditBox(topGroup, "Name of the selected alert", path, "name", 210, refresh)
	edit:SetText(path.name)
	-- disable if there is no aliert uid
	if not path.created then edit:SetDisabled(true)	end
	O.attachSpacer(topGroup, 10)
	-- icon for adding alert
	local texture, tooltip = A.backgrounds["AlertMe_Add"], { lines = {"Add new alert"} }
	O.attachIcon(topGroup, texture, 18, add, tooltip)
	O.attachSpacer(topGroup, 10)
	-- delete alert
	texture, tooltip = A.backgrounds["AlertMe_Delete"], { lines = {"Delete selected alert"} }
	O.attachIcon(topGroup, texture, 18, delete, tooltip)
	O.attachSpacer(topGroup, 8)
	-- active checkbox
	if path.created then
		local active = O.attachCheckBox(topGroup, "Active", path, "active", 65)
		active:SetValue(path.active)
	end
	-- show alert details
	if uid and uid ~= "" then
		O:showAlertDetails(container, handle, uid)
	end
end
