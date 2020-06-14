dprint(2, "alerts.lua")
-- upvalues
local _G, dprint, type, unpack, pairs = _G, dprint, type, unpack, pairs
-- get engine environment
local A, _, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the general options tab
function O:DrawAlertsOptions(container)
	dprint(2, "O:DrawAlertsOptions")
	VDT_AddData(container, "alerts")
	-- header
	O:AttachHeader(container, "Alert settings")
	local dd = {[1]="First",[2]="Second"}
	local path = P.alerts
	local key = "dropdown_selected"
	-- alerts dropdown
	local dropdown = A.Libs.AceGUI:Create("Dropdown")
	dropdown:SetLabel("Alerts")
	dropdown:SetList(dd)
	dropdown:SetValue(path[key])
	dropdown:SetUserData("path", path)
	dropdown:SetUserData("key", key)
	dropdown:SetCallback("OnValueChanged", function(widget, key, event) O:OnChange(widget, key, event) end)
	--dropdown:SetText("Select an alert")
	--AddItem(key, value) - Add an item to the list.
	dropdown:SetMultiselect(false)
--GetMultiselect() - Query the multi-select flag.
--SetItemValue(key, value) - Set the value of a item in the list.
--SetItemDisabled(key, flag) - Disable one item in the list.
--SetDisabled(flag) - Disable the widget.
	--select:SetDropdownWidth("full")
	--SetStatusTable(table) - Set an external status table.
	--OnGroupSelected(group) - Fires when a new group selection occurs.
	container:AddChild(dropdown)
	VDT_AddData(dropdown,"dropdown")
end

function O:OnChange(widget, event)
	local path = widget:GetUserData("path")
	local key = widget:GetUserData("key")
	dprint(1, widget, event, path, key)
	path[key] = widget.value
end
