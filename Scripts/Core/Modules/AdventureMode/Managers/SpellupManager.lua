-- Initialize AshraelPackage with AdventureMode and Spellup namespaces
AshraelPackage.AdventureMode.Managers.SpellupManager = AshraelPackage.AdventureMode.Managers.SpellupManager or {}
AshraelPackage.AdventureMode.Utils = AshraelPackage.AdventureMode.Utils or {}

local SpellupManager = AshraelPackage.AdventureMode.Managers.SpellupManager
local Utils = AshraelPackage.AdventureMode.Utils

-- Define the threshold for requesting a full or split spell-up if not already set
SpellupManager.SpellThreshold = SpellupManager.SpellThreshold or 5

-- Define spell-up command preferences based on the player's class and bot class if not already set
SpellupManager.ClassCommands = SpellupManager.ClassCommands or {
    mage = { priest = "full", druid = "split", psionicist = "split" },
    warrior = { priest = "split", druid = "full", psionicist = "split" },
    cleric = { priest = "full", druid = "split", psionicist = "split" },
    druid = { priest = "split", druid = "full", psionicist = "split" },
}

-- Define spells each class inherently cannot cast based on class limitations if not already set
SpellupManager.ClassUnknownSpells = SpellupManager.ClassUnknownSpells or {
    priest = { "Awen", "SteelSkeleton", "Barkskin" },
    druid = { "SteelSkeleton", "Aegis" },
    psionicist = { "Sanctuary", "Fortitude", "Invincibility", "Awen", "Barkskin", "Aegis" },
}

-- Define primary bots with their respective classes if not already set
SpellupManager.PrimaryBots = SpellupManager.PrimaryBots or {
    { name = "Logic", class = "priest" },
    { name = "Martyr", class = "priest" },
    { name = "FlutterFly", class = "druid" },
    { name = "Neodox", class = "psionicist" },
    { name = "Yorrick", class = "druid" },
    { name = "Eiri", class = "priest" },
}

-- Define the full list of spells with additional properties if not already set
SpellupManager.Spells = SpellupManager.Spells or {
    sanc = { key = "Sanctuary", command = "sanc", selfCastOnly = false, classExclusions = {} },
    fort = { key = "Fortitude", command = "fort", selfCastOnly = false, classExclusions = {} },
    invinc = { key = "Invincibility", command = "invinc", selfCastOnly = false, classExclusions = {} },
    iron = { key = "IronSkin", command = "iron", selfCastOnly = false, classExclusions = {} },
    foci = { key = "Foci", command = "foci", selfCastOnly = false, classExclusions = {} },
    water = { key = "WaterBreathing", command = "water", selfCastOnly = false, classExclusions = {} },
    awen = { key = "Awen", command = "awen", selfCastOnly = false, classExclusions = { "mage", "priest" } },
    aegis = { key = "Aegis", command = "aegis", selfCastOnly = false, classExclusions = {} },
    concentrate = { key = "Concentrate", command = "concentrate", selfCastOnly = true, classExclusions = {} },
    mystical = { key = "Mystical", command = "mystical", selfCastOnly = true, classExclusions = {} },
    savvy = { key = "Savvy", command = "savvy", selfCastOnly = true, classExclusions = {} },
    steel = { key = "SteelSkeleton", command = "steel", selfCastOnly = false, classExclusions = {} },
    bark = { key = "Barkskin", command = "bark", selfCastOnly = false, classExclusions = {} },
    protectionGood = { key = "ProtectionGood", command = "'protection good'", selfCastOnly = true, classExclusions = {} },
    protectionEvil = { key = "ProtectionEvil", command = "'protection evil'", selfCastOnly = true, classExclusions = {} },
    frenzy = { key = "Frenzy", command = "frenzy", selfCastOnly = false, classExclusions = { "mage", "priest" } },
}

-- Function to determine the player's class using StatTable and normalize to lowercase
local function GetPlayerClass()
    local playerClass = StatTable and StatTable.Class or "mage"
    return playerClass:lower()
end

-- Function to get player's alignment value and determine alignment type
local function GetPlayerAlignment()
    local alignment = StatTable and StatTable.Alignment or 0
    return alignment > 200 and "good" or (alignment < -200 and "evil" or "neutral")
end

-- Function to assign missing spells to each bot based on ClassUnknownSpells
local function AssignMissingSpellsToBots()
    for _, bot in ipairs(Spellup.PrimaryBots) do
        bot.missingSpells = {}
        for _, spell in pairs(Spellup.Spells) do
            if Spellup.ClassUnknownSpells[bot.class] and table.contains(Spellup.ClassUnknownSpells[bot.class], spell.key) then
                table.insert(bot.missingSpells, spell)
                Utils.DebugPrint("Adding spell %s to missing list for bot %s", spell.key, bot.name)
            end
        end
    end
end

-- Function to select the first available primary bot with preference for "full" or "split" spell-up
local function GetPreferredPrimaryBot(bots, playerClass)
    local fallbackBot = nil
    for _, bot in ipairs(bots) do
        if Utils.CheckBotPresence(bot.name) then
            local command = AshraelPackage.AdventureMode.Spellup.ClassCommands[playerClass] and AshraelPackage.AdventureMode.Spellup.ClassCommands[playerClass][bot.class]
            Utils.DebugPrint("Evaluating bot %s with class %s for player class %s", bot.name, bot.class, playerClass)
            if command == "full" then
                return bot, command
            elseif not fallbackBot then
                fallbackBot = bot
            end
        end
    end
    return fallbackBot, "split"
end

-- Function to check if the player's class is excluded for a given spell
local function IsClassExcluded(spell, playerClass)
    if spell.classExclusions and table.contains(spell.classExclusions, playerClass) then
        Utils.DebugPrint("Spell %s is excluded for class %s", spell.key, playerClass)
        return true
    end
    return false
end

-- Main function to handle the spell-up request
function SpellupManager.RequestSpellup()
    AssignMissingSpellsToBots()

    coroutine.wrap(function()
        local playerClass = GetPlayerClass()
        local playerAlignment = GetPlayerAlignment()
        local missingPrimary, missingSelf, totalMissing = {}, {}, 0

        for _, spell in pairs(Spellup.Spells) do
            if not StatTable[spell.key] then
                if spell.selfCastOnly then
                    if (playerAlignment == "good" and spell.key == "ProtectionEvil") or
                       (playerAlignment == "evil" and spell.key == "ProtectionGood") then
                        table.insert(missingSelf, spell.command)
                        Utils.DebugPrint("Added protection spell %s based on alignment", spell.command)
                    elseif not (spell.key == "ProtectionEvil" or spell.key == "ProtectionGood") then
                        table.insert(missingSelf, spell.command)
                        Utils.DebugPrint("Added %s to self-casting list", spell.command)
                    end
                else
                    if not IsClassExcluded(spell, playerClass) then
                        table.insert(missingPrimary, spell.command)
                        totalMissing = totalMissing + 1
                        Utils.DebugPrint("Added primary spell %s to missing list", spell.command)
                    end
                end
            end
        end

        if totalMissing < Spellup.SpellThreshold then
            for _, spellCommand in ipairs(missingPrimary) do
                for _, bot in ipairs(AdventureMode.Spellup.PrimaryBots) do
                    if Utils.CheckBotPresence(bot.name) and not table.contains(bot.missingSpells, AshraelPackage.AdventureMode.Spellup.Spells[spellCommand]) then
                        send("tell " .. bot.name:lower() .. " " .. spellCommand)
                        Utils.DebugPrint("Sent spell command %s to bot %s", spellCommand, bot.name)
                        break
                    end
                end
            end
        else
            local primaryBot, command = GetPreferredPrimaryBot(Spellup.PrimaryBots, playerClass)
            if primaryBot and command then
                send("tell " .. primaryBot.name:lower() .. " " .. command)
                Utils.DebugPrint("Issued %s spell-up command to %s", command, primaryBot.name)
                if command == "split" then
                    table.insert(missingSelf, playerAlignment == "good" and Spellup.Spells.protectionEvil.command or AshraelPackage.AdventureMode.Spellup.Spells.protectionGood.command)
                end

                -- Check if other bots can assist with primary bot's missing spells
                Utils.DebugPrint("Checking if other bots can assist with primary bot's missing spells.")
                for _, missingSpell in ipairs(primaryBot.missingSpells) do
                    if not IsClassExcluded(missingSpell, playerClass) and not StatTable[missingSpell.key] then
                        local spellFound = false
                        for _, bot in ipairs(Spellup.PrimaryBots) do
                            if bot ~= primaryBot and Utils.CheckBotPresence(bot.name) then
                                if not table.contains(bot.missingSpells, missingSpell) then
                                    send("tell " .. bot.name:lower() .. " " .. missingSpell.command)
                                    Utils.DebugPrint("Bot %s selected to cast %s", bot.name, missingSpell.command)
                                    spellFound = true
                                    break
                                else
                                    Utils.DebugPrint("Bot %s cannot cast %s - it is in missing spells", bot.name, missingSpell.command)
                                end
                            elseif bot == primaryBot then
                                Utils.DebugPrint("Skipping primary bot %s", bot.name)
                            else
                                Utils.DebugPrint("Bot %s is not present to cast %s", bot.name, missingSpell.command)
                            end
                        end
                        if not spellFound then
                            Utils.DebugPrint("No available bot could cast %s", missingSpell.command)
                        end
                    else
                        Utils.DebugPrint("Skipping spell %s as it is excluded for player class %s", missingSpell.command, playerClass)
                    end
                end
            end
        end

        if #missingSelf > 0 then
            if StatTable.Position and StatTable.Position:lower() == "sleep" then
                send("wake")
            end
            for _, spell in ipairs(missingSelf) do
                send("cast " .. spell)
                Utils.DebugPrint("Self-casting spell %s", spell)
            end
        end
    end)()
end