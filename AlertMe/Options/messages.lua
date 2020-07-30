dprint(3, "messages.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- upvalues
local FCF_GetNumActiveChatFrames = FCF_GetNumActiveChatFrames
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:ShowMessages(container)
	dprint(2, "O:ShowMessages")
	local db = P.messages
	-- header
	O.AttachHeader(container, "Message Settings")
	-- chat frames
	local title = "Post addon messages in the following chat windows (only visible for you)"
	local chatFramesGroup = O.AttachGroup(container, "inline", title, {fullWidth = true})
	for name, frame in pairs(A.ChatFrames) do
			O.AttachCheckBox(chatFramesGroup, name, db.chatFrames, frame, 150)
	end
	-- event specific messages
	O.AttachHeader(container, "Event specific settings")
	O.AttachEditBox(container, "Message on aura gained/refreshed", db, "msgGain", 1)
	O.AttachEditBox(container, "Message on spell dispel", db, "msgDispel", 1)
	O.AttachEditBox(container, "Message on cast start", db, "msgStart", 1)
	O.AttachEditBox(container, "Message on cast success", db, "msgSuccess", 1)
	O.AttachEditBox(container, "Message on interrupt", db, "msgInterrupt", 1)
	O.AttachEditBox(container, "Message prefix", db, "msgPrefix", 200)
	O.AttachEditBox(container, "Message postfix", db, "msgPostfix", 200)
end
