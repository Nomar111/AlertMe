-- upvalues
local InCombatLockdown, strsplit = InCombatLockdown, strsplit
-- set addon environment
setfenv(1, _G.AlertMe)
-- (re)set some variables
O.config = {}

-- *************************************************************************************
-- open the options window
function O:OpenOptions()
	-- check if in combat
	if InCombatLockdown() then
		print("Can't open AlertMe options because of ongoing combat.")
		return
	end
	-- close
	local function close()
		A:InitSpellOptions()
		A.Libs.AceGUI:Release(O.OptionsFrame)
		O.OptionsFrame = nil
		A:HideAllGUIs()
	end
	-- check if already open
	if O.OptionsFrame ~= nil then
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
	O.OptionsFrame = f
	-- create navigation
	O:CreateNavTree(f)
end

-- *************************************************************************************
-- creates navigation tree
function O:CreateNavTree(container)
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
		O:ShowOptions(scrollGroup, uniqueValue)
	end
	tree:SetCallback("OnGroupSelected", GroupSelected)
	tree:SelectByPath(strsplit("\001", P.options.lastMenu))
	container:AddChild(tree)
	--tree:SelectByPath("alerts","gain")
end

function O:ShowOptions(container, uniqueValue)
	P.options.lastMenu = uniqueValue
	local lvl1, lvl2 = strsplit("\001", uniqueValue)
	if lvl1 == "general" then O:ShowGeneral(container)
	elseif lvl1 == "scrolling" then O:ShowScrollingText(container)
	elseif lvl1 == "bars" then O:ShowBars(container)
	elseif lvl1 == "messages" then O:ShowMessages(container)
	elseif lvl1 == "glow" then O:ShowGlow(container)
	elseif lvl1 == "profiles" then O:ShowProfiles(container)
	elseif lvl1 == "info" then O:ShowInfo(container)
	elseif lvl1 == "alerts" and lvl2 ~= nil then O:ShowAlerts(container, lvl2)
	end
end
