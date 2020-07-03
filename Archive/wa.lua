aura_env.initTriggerInfo = function(allstates, waevent, ts, event, ...)
	-- set spells
	local spellName1 = "Mark of the Wild"
	local spellName2 = "Thorns"
	local timer = 9
    -- set common args
    local arg = {...}
    local srcGUID, spellName = arg[2], arg[11]
    -- abort if not cast by self
    if srcGUID ~= UnitGUID("player") then return end

    if spellName == spellName1 then
        -- check if icon for spell1 is shown, if so hide
        if allstates[spellName1] ~= nil and allstates[spellName1].show == true then
            allstates[spellName1] = {
                show = false,
                changed = true,
            }
        end
        -- start timer to show icon for spell1 again after x seconds
        aura_env.countdown = C_Timer.After(timer, function()
                local _, _, icon = GetSpellInfo(spellName1)
                allstates[spellName1] = {
                    show = true,
                    changed = true,
                    name = name,
                    icon = icon,
                    progressType = "static",
                }
                return true
        end)
        -- show icon for spell2
        local _, _, icon = GetSpellInfo(spellName2)
        allstates[spellName2] = {
            show = true,
            changed = true,
            name = name,
            icon = icon,
            progressType = "static",
        }
        return true
    end
    -- if spell2 is cast, hide icon
    if spellName == spellName2 then
        if allstates[spellName2] ~= nil and allstates[spellName2].show == true then
            allstates[spellName2] = {
                show = false,
                changed = true,
            }
        end
        return true
    end
end
