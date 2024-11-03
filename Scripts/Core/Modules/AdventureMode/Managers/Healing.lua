-- Initialize AshraelPackage with AdventureMode and Healing namespaces
AshraelPackage = AshraelPackage or {}
AshraelPackage.AdventureMode = AshraelPackage.AdventureMode or {}
AshraelPackage.AdventureMode.Healing = AshraelPackage.AdventureMode.Healing or {}
AshraelPackage.AdventureMode.Utils = AshraelPackage.AdventureMode.Utils or {}

local AdventureMode = AshraelPackage.AdventureMode
local Utils = AshraelPackage.AdventureMode.Utils
local Healing = AdventureMode.Healing

-- Define each bot with their name and healing command if not already set
Healing.Bots = Healing.Bots or {
    { name = "Logic", healCommand = "div" },
    { name = "Martyr", healCommand = "div" },
    { name = "FlutterFly", healCommand = "div" },
    { name = "Yorrick", healCommand = "div" },
    { name = "Eiri", healCommand = "div" }
}

-- Constant defining HP gained per div spell if not already set
Healing.DivHealAmount = Healing.DivHealAmount or 250

-- Function to handle healing requests
function Healing.RequestHealing()
    coroutine.wrap(function()
        if StatTable.current_health and StatTable.max_health then
            local missingHealth = StatTable.max_health - StatTable.current_health
            local totalDivsNeeded = math.ceil(missingHealth / Healing.DivHealAmount)
            Utils.DebugPrint("Missing health = %d, Total divs needed = %d", missingHealth, totalDivsNeeded)

            -- Filter available bots in priority order
            local availableBots = {}
            for _, bot in ipairs(Healing.Bots) do
                if AdventureMode.Utils.CheckBotPresence(bot.name) then
                    table.insert(availableBots, bot)
                    Utils.DebugPrint("Bot available for healing: %s", bot.name)
                else
                    Utils.DebugPrint("Bot not available: %s", bot.name)
                end
            end

            if #availableBots > 0 then
                local i = 1
                -- Distribute initial div requests across available bots in round-robin
                for j = 1, totalDivsNeeded do
                    local currentBot = availableBots[(j - 1) % #availableBots + 1]
                    send("tell " .. currentBot.name:lower() .. " " .. currentBot.healCommand)
                    Utils.DebugPrint("Sent div request to %s", currentBot.name)
                    wait(1)
                end

                -- Fallback to monitor health and continue div requests if needed
                wait(15)
                repeat
                    local currentHealth = tonumber(gmcp.Char.Vitals.hp)
                    Utils.DebugPrint("Current health = %d", currentHealth)

                    if currentHealth < StatTable.max_health then
                        local currentBot = availableBots[(i - 1) % #availableBots + 1]
                        send("tell " .. currentBot.name:lower() .. " " .. currentBot.healCommand)
                        Utils.DebugPrint("Sent fallback div request to %s", currentBot.name)
                        wait(15)
                        i = i + 1
                    end
                until currentHealth >= StatTable.max_health
            else
                cecho("<red>No bots available for healing.<reset>")
                Utils.DebugPrint("No bots available for healing.")
            end
        else
            Utils.DebugPrint("Health data missing - could not execute healing.")
        end
    end)()
end