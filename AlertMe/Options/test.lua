dprint(2, "test.lua")
-- upvalues
local _G, dprint, type, unpack, pairs, time, tostring, xpcall, tinsert = _G, dprint, type, unpack, pairs, time, tostring, xpcall, table.insert
local GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall, CreateFrame = GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall, CreateFrame
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:DrawTest(container)
	local spellNames = {}
	for spellName,_ in pairs(S.cache) do
		tinsert(spellNames, spellName)
	end
	VDT_AddData(spellNames, "spellNames")
	--local valueList = {"Suggestion 1", "Suggestion 2","Another Suggestion","One More Suggestion"}
	local maxButtonCount = 20
	local text = A.Libs.AceGUI:Create('EditBox-AutoComplete')
	text:SetValueList(spellNames)
	text:SetButtonCount(maxButtonCount)
	container:AddChild(text)

	scrollcontainer = A.Libs.AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
	scrollcontainer:SetFullWidth(true)
	scrollcontainer:SetHeight(60) -- probably?
	scrollcontainer:SetLayout("Fill") -- important!

	container:AddChild(scrollcontainer)

	scroll = A.Libs.AceGUI:Create("ScrollFrame")
	scroll:SetLayout("Flow") -- probably?
	scrollcontainer:AddChild(scroll)


	O:AttachLabel(scroll, "TEXTdgpjfdigjfdog", GameFontHighlight)
	O:AttachLabel(scroll, "TEXTdgpjfdigjfdog", GameFontHighlight)
	O:AttachLabel(scroll, "TEXTdgpjfdigjfdog", GameFontHighlight)
	O:AttachLabel(scroll, "TEXTdgpjfdigjfdog", GameFontHighlight)
	O:AttachLabel(scroll, "TEXTdgpjfdigjfdog", GameFontHighlight)
	O:AttachLabel(scroll, "TEXTdgpjfdigjfdog", GameFontHighlight)
	O:AttachLabel(scroll, "TEXTdgpjfdigjfdog", GameFontHighlight)
		O:AttachLabel(scroll, "TEXTdgpjfdigjfdog", GameFontHighlight)
			O:AttachLabel(scroll, "TEXTdgpjfdigjfdog", GameFontHighlight)

				O:AttachLabel(scroll, "TEXTdgpjfdigjfdog", GameFontHighlight)
					O:AttachLabel(scroll, "TEXTdgpjfdigjfdog", GameFontHighlight)
						O:AttachLabel(scroll, "TEXTdgpjfdigjfdog", GameFontHighlight)
							O:AttachLabel(scroll, "TEXTdgpjfdigjfdog", GameFontHighlight)
								O:AttachLabel(scroll, "TEXTdgpjfdigjfdog", GameFontHighlight)

--add widgets to scroll now instead of directly to f, if they overflow the size of f the will be scrolled.
	VDT_AddData(scroll,"scroll")
	VDT_AddData(container,"container")
end
