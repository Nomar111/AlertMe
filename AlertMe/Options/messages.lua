dprint(3, "messages.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- upvalues
local FCF_GetNumActiveChatFrames = FCF_GetNumActiveChatFrames
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:ShowMessages(container)
	dprint(2, "O:ShowMessages")
	-- header
	O:AttachHeader(container, "Message Settings")
	local db = P.messages
	-- chat frames
	local chatFramesGroup = O:AttachGroup(container, "Post addon messages in the following chat windows (only visible for you)", true)
	for i = 1, FCF_GetNumActiveChatFrames() do
		local name = _G["ChatFrame"..i.."Tab"]:GetText()
		if name ~= "Combat Log" then
			O:AttachCheckBox(chatFramesGroup, name, db.chatFrames, "ChatFrame"..i, 150)
		end
	end
	-- event specific messages
	O:AttachHeader(container, "Event specific settings")
	O:AttachEditBox(container, "Message on aura gained/refreshed", db, "msgGain", 660)
	O:AttachEditBox(container, "Message on spell dispel", db, "msgDispel", 660)
	O:AttachEditBox(container, "Message on cast start", db, "msgStart", 660)
	O:AttachEditBox(container, "Message on cast success", db, "msgSuccess", 660)
	O:AttachEditBox(container, "Message on interrupt", db, "msgInterrupt", 660)
	O:AttachEditBox(container, "Message prefix", db, "msgPrefix", 130)
	O:AttachSpacer(container, 30)
	O:AttachEditBox(container, "Message postfix", db, "msgPostfix", 130)
end
