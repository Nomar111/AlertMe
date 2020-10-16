--dprint(3, "messages.lua")
-- get engine environment
local A, O = unpack(select(2, ...))
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
	O.AttachEditBox(container, "Message on aura gained/refreshed", db, "gain", 1)
	O.AttachEditBox(container, "Message on spell dispel", db, "dispel", 1)
	O.AttachEditBox(container, "Message on cast start", db, "start", 1)
	O.AttachEditBox(container, "Message on cast success", db, "success", 1)
	O.AttachEditBox(container, "Message on interrupt", db, "interrupt", 1)
	O.AttachEditBox(container, "Message prefix", db, "prefix", 200)
	O.AttachEditBox(container, "Message postfix", db, "postfix", 200)
end
