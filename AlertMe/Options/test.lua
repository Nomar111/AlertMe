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
	
end
