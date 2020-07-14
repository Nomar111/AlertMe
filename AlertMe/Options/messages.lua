dprint(3, "messages.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:ShowMessages(container)
	dprint(2, "O:ShowMessages")
	-- header
	O:AttachHeader(container, "Message Settings")
	-- chat frames
	local chat_frames = O:AttachGroup(container, "Post addon messages in the following chat windows (only visible for you)", true)
	for i = 1, FCF_GetNumActiveChatFrames() do
		local name = _G["ChatFrame"..i.."Tab"]:GetText()
		if name ~= "Combat Log" then
			O:AttachCheckBox(chat_frames, name, P.general.chat_frames, "ChatFrame"..i, 150)
		end
	end
	-- event specific messages
	O:AttachHeader(container, "Event specific settings")
	O:AttachEditBox(container, "Message on aura gained/refreshed", P.events, "msg_gain", 660)
	O:AttachEditBox(container, "Message on spell dispel", P.events, "msg_dispel", 660)
	O:AttachEditBox(container, "Message on cast start", P.events, "msg_start", 660)
	O:AttachEditBox(container, "Message on cast success", P.events, "msg_success", 660)
	O:AttachEditBox(container, "Message on interrupt", P.events, "msg_interrupt", 660)
	O:AttachEditBox(container, "Message prefix", P.events, "chatPrefix", 130)
	O:AttachSpacer(container, 30)
	O:AttachEditBox(container, "Message postfix", P.events, "chatPostfix", 130)
end
