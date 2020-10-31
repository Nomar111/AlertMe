-- upvalues
local InCombatLockdown, strsplit = InCombatLockdown, strsplit
-- set addon environment
setfenv(1, _G.AlertMe)
-- (re)set some variables
O.config = {}

-- *************************************************************************************
-- creates navigation tree
local function createNavTree(container)
	-- function to draw the groupd
	local treeStructure = {}
	treeStructure[1] = {value = "general", text = "General"}
	treeStructure[2] = {value = "scrolling", text = "Scrolling Text"}
	treeStructure[3] = {value = "bars", text = "Bar Setup"}
	treeStructure[4] = {value = "messages", text = "Messages"}
	treeStructure[5] = {value = "glow", text = "Glow"}
	treeStructure[6] = {value = "alerts", text = "Alerts", children = {}}
	treeStructure[7] = {value = "profiles", text = "Profiles"}
	treeStructure[8] = {value = "info", text = "Info"}
	-- loop over events and add them as children of alerts
	for _, tbl in pairs(A.Events) do
		if tbl.optionsDisplay then
			treeStructure[6].children[tbl.optionsOrder]  = {value = tbl.short, text = tbl.optionsText }
		end
	end
	-- create the tree group
	local tree = A.Libs.AceGUI:Create("TreeGroup")
	tree:EnableButtonTooltips(false)
	tree.width = "fill"
	tree.height = "fill"
	tree:SetTree(treeStructure)
	-- callbacks
	local function GroupSelected(widget, event, uniqueValue)
		-- release content
		widget:ReleaseChildren()
		-- create new content container
		local contentGroup =  O.attachGroup(widget, "simple", _,  {fullWidth = true, fullHeight = true , layout = "none"})
		local scrollGroup = A.Libs.AceGUI:Create("ScrollFrame")
		scrollGroup:SetLayout("List")
		scrollGroup:SetFullHeight(true)
		scrollGroup:SetFullWidth(true)
		contentGroup:AddChild(scrollGroup)
		O:showOptions(scrollGroup, uniqueValue)
	end
	tree:SetCallback("OnGroupSelected", GroupSelected)
	tree:SelectByPath(strsplit("\001", P.options.lastMenu))
	container:AddChild(tree)
end

-- *************************************************************************************
-- open the options window
function O:openOptions()
	-- check if in combat
	if InCombatLockdown() then
		print("Can't open AlertMe options because of ongoing combat.")
		return
	end
	-- close
	local function close()
		A:initSpellOptions()
		A.Libs.AceGUI:Release(O.options)
		O.options = nil
		A:hideAllGUIs()
	end
	-- check if already open
	if O.options ~= nil then
		close()
		return
	end
	-- create main frame for options
	local f = A.Libs.AceGUI:Create("Frame")
	f:SetTitle("AlertMe Options")
	f:EnableResize(true)
	f:SetLayout("Flow")
	f:SetCallback("OnClose", close)
	f:SetWidth(840)
	f:SetHeight(670)
	O.options = f
	-- create navigation
	createNavTree(f)
end

function O:showOptions(container, uniqueValue)
	P.options.lastMenu = uniqueValue
	local lvl1, lvl2 = strsplit("\001", uniqueValue)
	if lvl1 == "general" then O:showGeneral(container)
	elseif lvl1 == "scrolling" then O:showScrollingText(container)
	elseif lvl1 == "bars" then O:showBars(container)
	elseif lvl1 == "messages" then O:showMessages(container)
	elseif lvl1 == "glow" then O:showGlow(container)
	elseif lvl1 == "profiles" then O:showProfiles(container)
	elseif lvl1 == "info" then O:showInfo(container)
	elseif lvl1 == "alerts" and lvl2 ~= nil then O:showAlerts(container, lvl2)
	end
end
