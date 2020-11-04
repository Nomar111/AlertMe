-- set addon environment
setfenv(1, _G.AlertMe)

-- deDE
local L = A.Libs.AceLocale:NewLocale("AlertMe", "deDE")
--***************************************************************************
-- general
L["Alerts"] = "Alarme"
L["Hostile player"] = "Feindlicher Spieler"
L["Friendly player"] = "Verbündeter Spieler"
L["Friendly players"] = "Feindliche Spieler"
L["Hostile players"] = "Verbündete Spieler"
L["Target"] = "Ziel"
L["Myself"] = "Ich"
L["All entities"] = "Alle Enheiten"
L["Hostile NPCs"] = "Feindlicher NPC"
L["Enable"] = "Einschalten"
L["Scrolling Text"] = "Scroll Text"
L["Show"] = "Anzeigen"
L["aura bars"] = "Aurabalken"
L["cast bars"] = "Zauberbalken"
L["Default"] = "Standard"
--***************************************************************************
-- options/options
L["General"] = "Allgemein"
L["Bar Setup"] = "Balken Setup"
L["Messages"] = "Nachrichten"
L["Glow"] = "Glow"
L["Profiles"] = "Profile"
L["Info"] = "Info"
L["Can't open AlertMe options because of ongoing combat."] = "Kann AlertMe Optionen nicht öffnen, da im Kampf."
--***************************************************************************
-- options/alerts
L["Name of the selected alert"] = "Name des gewählten Alarms"
L["Add new alert"] = "Füge einen Alarm hinzu"
L["Delete selected alert"] = "Lösche gewählten Alarm"
L["Active"] = "Aktiv"
--***************************************************************************
-- options / bars
L["Greater Heal"] = true
L["Resurrection"] = true
L["Unlock bars"] = true
L["Show test bars"] = true
L["Reset position"] = true
L["Hide test bars"] = true
L["Bar texture"] = true
L["Set height"] = true
L["Set width"] = true
L["Show icon"] = true
L["Fill up"] = true
L["Time visible"] = true
L["Bar color (good)"] = true
L["Bar color (harm)"] = true
L["Background color"] = true
L["Text color"] = true
L["Text shadow"] = true
L["Aura bars"] = true
L["Cast bars"] = true
--***************************************************************************
-- options / details
L["Delete item from spell table"] = true
L["Set an individual sound alert"] = true
L["Spell/Aura settings"] = true
L["Add"] = true
L["Set sound alert per spell"] = true
L["Unit selection"] = true
L["Source units"] = true
L["excluding"] = true
L["Target units"] = true
L["Display settings"] = true
L["Enable glow on unitframes"] = true
L["Works for friendly unitframes by default"] = true
L["Also works for enemy uniframes if using BGTC*"] = true
L["*BattlegrounndTargets Classic"] = true
L["Text alerts"] = true
L["Don't announce"] = true
L["Party"] = true
L["BG > Raid > Party"] = true
L["Say"] = true
L["Announce in channel"] = true
L["Always"] = true
L["Never"] = true
L["If chan not available"] = true
L["Addon messages"] = true
L["Addon messages are only visible to yourself"] = true
L["Chat windows are setup in 'Messages'"] = true
L["Post addon messages"] = true
L["Don't whisper"] = true
L["Whisper"] = true
L["Whisper if cast by me"] = true
L["Whisper dest. unit"] = true
L["Post messages to Scrolling Text"] = true
L["Post in Scrolling Text"] = true
L["Message override"] = true
L["Set an alternative chat message"] = true
L["Chat message override"] = true
L["If empty, (event) standard will be used"] = true
L["Sound alerts"] = true
L["No sound alerts"] = true
L["Play one sound"] = true
L["Play individual sounds"] = true
L["Set alerts in the spell table"] = true
L["Sound alert"] = true
--***************************************************************************
-- options / general
L["General Settings"] = true
L["Enable addon"] = true
L["Addon settings"] = true
L["Hide minimap"] = true
L["Addon is enabled in"] = true
L["Battlegrounds"] = true
L["World"] = true
L["PvE Instances"] = true
--***************************************************************************
-- options / info
L["Current Version"] = true
L["Author"] = true
L["Email"] = true
--***************************************************************************
-- options / lcg
L["Frequency"] = true
L["Negative = inverse direction"] = true
L["Number of lines"] = true
L["BGTC Support"] = true
L["Deactivate if you experience performance issues"] = true
L["Thickness"] = true
L["Glow Settings"] = true
L["Enable glow on unit frames"] = true
L["Enable support for BattlegroundTargets Classic"] = true
L["Glow Preset"] = true
L[" Glow Color"] = true
L["No. of lines"] = true
L["Offset Y"] = true
L["Offset X"] = true
--***************************************************************************
-- options / messages
L["Message Settings"] = true
L["enable/disable addon messages"] = true
L["Enable addon messages"] = true
L["which are only visible for you"] = true
L["enable/disable chat announcements in:"] = true
L["/raid /bg /party /say"] = true
L["Enable chat announcements"] = true
L["Post addon messages (only visible for you) in:"] = true
L["Reset to default"] = true
L["Event specific settings"] = true
L["Useful replacements:"] = true
L["Message on aura gained/refreshed"] = true
L["Message on spell dispel"] = true
L["Message on cast start"] = true
L["Message on cast success"] = true
L["Message on spell missed"] = true
L["Message on interrupt"] = true
L["Message prefix"] = true
L["Message postfix"] = true
--***************************************************************************
-- options / scrolling
L["Adding some test messages"] = true
L["Playername gains Blessing of Freedom"] = true
L["Teammate is sapped"] = true
L["Warrior gains Recklessness"] = true
L["Blessing of Protection is dispelled on Player (by Player)"] = true
L["Priest casts Mana Burn"] = true
L["Scrolling Text Settings"] = true
L["Enable Scrolling Text"] = true
L["Movable"] = true
L["Hide frame"] = true
L["Show frame"] = true
L["Reset position"] = true
L["Center horizontal"] = true
L["Set width"] = true
L["Fade after (s)"] = true
L["Enable fading"] = true
L["Background alpha"] = true
L["Visible lines"] = true
L["CENTER"] = true
L["Max. lines (history)"] = true
L["LEFT"] = true
L["Alignment"] = true
L["RIGHT"] = true
L["Show spell icon"] = true
L["Left-Click for moving the frame (if set to movable)."] = true
L["Mousewheel to scroll through the text."] = true
L["Right-Click for closing the frame (if set to movable)."] = true
--***************************************************************************
-- core / bars
L["Drag here"] = true
--***************************************************************************
-- core / ldb
L["Left-Click: Show/Hide options"] = true
L["Shift-Left-Click: Enable/Disable addon"] = true
L["Middle-Click: Show/Hide minimap"] = true
L["|cffFF0000ADDON IS DISABLED"] = true
--***************************************************************************
-- settings
L["On aura gain/refresh"] = true
L["On dispel"] = true
L["On cast success"] = true
L["On cast start"] = true
L["On spell missed"] = true
L["On interrupt"] = true
L["%dstName gained %spellName"] = true
L["%extraSpellName dispelled on %dstName -- by %srcName"] = true
L["%srcName starts to cast %spellName"] = true
L["%srcName casted %spellName on %dstName"] = true
L["%srcName's %spellName missed on %dstName (%missType)"] = true
L["%srcName interrupted %dstName -- %extraSchool locked for %lockout s"] = true
L["absorbed"] = true
L["blocked"] = true
L["dodged"] = true
L["deflected"] = true
L["evaded"] = true
L["immune"] = true
L["missed"] = true
L["parried"] = true
L["reflected"] = true
L["resisted"] = true
