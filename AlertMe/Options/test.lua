dprint(2, "test.lua")
-- upvalues
local _G, dprint, type, unpack, pairs, time, tostring, xpcall, tinsert = _G, dprint, type, unpack, pairs, time, tostring, xpcall, table.insert
local GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall = GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:DrawTest(container)
	O.test = {}
	local path = P.events
local dropdown = A.Libs.AceGUI:Create("Dropdown")
O.test.dropdown = dropdown
dropdown:SetLabel("Label")
dropdown:SetMultiselect(false)
dropdown:SetWidth(200)
dropdown:SetList(path.dd_items)
dropdown:SetValue(1)
dropdown:SetCallback("OnValueChanged", function(self, callback, val) path.dd_value = val end);
-- local subItem = A.Libs.A.Libs.AceGUI:Create("Dropdown-Item-Toggle")
-- subItem:SetText("SubItem 1")
VDT_AddData(dropdown, "dd")
-- 	local menu = A.Libs.A.Libs.AceGUI:Create("Dropdown-Item-Menu")
-- 	menu:SetText("Menu 123")
--

-- 	VDT_AddData(menu, "menu")


	local dropdown_pull = A.Libs.AceGUI:Create("Dropdown-Pullout")
	local header = A.Libs.AceGUI:Create("Dropdown-Item-Header")
	header:SetText("Some header text")
	dropdown_pull:AddItem(header)
	--dropdown.pullout:AddItem(header)

	local btn1 = A.Libs.AceGUI:Create("Dropdown-Item-Execute")
	btn1:SetText("Button1")
	btn1:SetCallback("OnClick", function() print("Button1 clicked") end)
	dropdown_pull:AddItem(btn1)

	-- create submenu
	local submenu = A.Libs.AceGUI:Create("Dropdown-Pullout")

	local subCheck = A.Libs.AceGUI:Create("Dropdown-Item-Toggle")
	subCheck:SetText("A checkbutton")
	subCheck:SetCallback("OnValueChanged", function(checked) dprint(1, "Checkbox is", checked and "checked" or "not checked") end)
	subCheck:SetValue(false) -- not checked
	submenu:AddItem(subCheck)

	local sep = A.Libs.AceGUI:Create("Dropdown-Item-Separator")
	submenu:AddItem(sep)

	local subBtn = A.Libs.AceGUI:Create("Dropdown-Item-Execute")
	subBtn:SetText("Another button")
	submenu:AddItem(subBtn)

	local menuItem = A.Libs.AceGUI:Create("Dropdown-Item-Menu")
	menuItem:SetText("A Submenu")
	menuItem:SetMenu(submenu)
	dropdown_pull:AddItem(menuItem)

	-- later in your code
	-- show the pullout at the center of the screen
	dropdown_pull:Open("CENTER", UIParent, "CENTER", 0, 0)


	--dropdown.pullout:AddItem(subItem)

	container:AddChild(dropdown)
	-- subItem = A.Libs.A.Libs.AceGUI:Create("Dropdown-Item-Toggle")
	-- subItem:SetText("SubItem 2")
	-- menu.pullout:AddItem(subItem)

	-- menu = A.Libs.A.Libs.AceGUI:Create("Dropdown-Item-Menu")
	-- menu:SetText("Menu 2")
	-- dropdown.pullout:AddItem(menu)
	--
	-- subItem = A.Libs.A.Libs.AceGUI:Create("Dropdown-Item-Toggle")
	-- subItem:SetText("SubItem 1")
	-- menu.submenu:AddItem(subItem)
	--
	-- menu = A.Libs.A.Libs.AceGUI:Create("Dropdown-Item-Menu")
	-- menu:SetText("Menu 3")
	-- dropdown.pullout:AddItem(menu)
	--
	-- subItem = A.Libs.A.Libs.AceGUI:Create("Dropdown-Item-Toggle")
	-- subItem:SetText("SubItem 1")
	-- menu.submenu:AddItem(subItem)



	function O:IconClick(widget, event, button)
		P.events.dd_value = 1
		--O.test.dropdown:AddItem(5,"Fünf")
		--O.test.dropdown:SetValue(5)
		--O.test.dropdown:Fire("OnValueChanged", 5)

	end



	local icon = A.Libs.AceGUI:Create("Icon")
	icon:SetImage("Interface\\AddOns\\AlertMe\\Media\\Textures\\add.tga")
	icon:SetImageSize(18, 18)
	icon:SetUserData("path", path)
	icon:SetWidth(18)
	container:AddChild(icon)
	icon:SetCallback("OnClick", function(widget, event, button) O:IconClick(widget, event, button) end)

end







	-- APIs
	-- SetValue(key) - Set the value to an item in the List.
	-- SetList(table [, order]) - Set the list of values for the dropdown (key => value pairs). The order is a optional second table, that contains the order in which the entrys should be displayed (Array table with the data tables keys as values). Behaviour is undefined if you provide a order table that contains not the exact same keys as in the data table.
	-- SetText(text) - Set the text displayed in the box.
	-- SetLabel(text) - Set the text for the label.
	-- AddItem(key, value) - Add an item to the list.
	-- SetMultiselect(flag) - Toggle multi-selecting.
	-- GetMultiselect() - Query the multi-select flag.
	-- SetItemValue(key, value) - Set the value of a item in the list.
	-- SetItemDisabled(key, flag) - Disable one item in the list.
	-- SetDisabled(flag) - Disable the widget.
	-- Callbacks
	-- OnValueChanged(key [,checked]) - Fires when the selection changes. The second argument is send for multi-select dropdowns to indicate a change in one option.
	-- OnEnter() - Fires when the cursor enters the widget.
	-- OnLeave() - Fires when the cursor leaves the widget.
