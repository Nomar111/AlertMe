dprint(2, "test.lua")
-- upvalues
local _G, dprint, type, unpack, pairs, time, tostring, xpcall, tinsert = _G, dprint, type, unpack, pairs, time, tostring, xpcall, table.insert
local GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall, CreateFrame = GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall, CreateFrame
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:DrawTest(container)
	container:ReleaseChildren()
	-- prepare table with spellnames
	local editgroup = O:AttachGroup(container, "Put in spellnames", false)
	editgroup:SetRelativeWidth(0.4)
	editgroup:SetAutoAdjustHeight(false)
	editgroup:SetHeight(100)
	local spellNames = {}
	for spellName,_ in pairs(S.cache) do
		tinsert(spellNames, spellName)
	end
	local spellList = {}
	local edit = A.Libs.AceGUI:Create('EditBox-AutoComplete')
	edit:SetValueList(spellNames)
	edit:SetButtonCount(20)
	edit:SetLabel("Type in spell name")
	edit:SetCallback("OnEnterPressed", function(widget, event, text)
			local grp = O:AttachGroup(O.scroll, _, false)
			grp:SetAutoAdjustHeight(false)
			grp:SetHeight(18)
			local icon_delete = O:AttachIcon(grp, "Interface\\AddOns\\AlertMe\\Media\\Textures\\delete.tga", 18)
			local label = O:AttachLabel(grp, text, GameFontHighlight, nil, 0.8)
			icon_delete:SetUserData("icon", icon_delete)
			icon_delete:SetUserData("label", label)
			icon_delete:SetUserData("group", grp)
			icon_delete:SetCallback("OnClick", function(widget, event, value)
			local grrp = widget:GetUserData("group")
			grrp:ReleaseChildren()
			grrp:Release()
								-- lbl:Release()
				-- local lbl = widget:GetUserData("label")
				-- lbl:Release()
				-- local ic = widget:GetUserData("icon")
				-- ic:Release()
			end)
		edit:SetText("")
	end)
	editgroup:AddChild(edit)
	-- scrollcontainer
	local scrollcontainer = O:AttachGroup(container, "Spells", false)
	--scrollcontainer = A.Libs.AceGUI:Create("InlineGroup") -- "InlineGroup" is also good
	scrollcontainer:SetRelativeWidth(0.6)
	scrollcontainer:SetAutoAdjustHeight(false)
	scrollcontainer:SetHeight(130.0) -- probably?
	scrollcontainer:SetLayout("Fill") -- important!
	-- create scrollframe
	O.scroll = A.Libs.AceGUI:Create("ScrollFrame")
	O.scroll:SetLayout("List")

	scrollcontainer:AddChild(O.scroll)
	VDT_AddData(O.scroll,"scroll")
	VDT_AddData(container,"container")
end
