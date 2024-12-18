local CharactersManager = AshraelPackage.VoidWalker.Managers.CharactersManager
local CharactersDA = AshraelPackage.VoidWalker.DataAccessors.CharactersDA
local InventoryDA = AshraelPackage.VoidWalker.DataAccessors.InventoryDA

-- Flags and intervals
CharactersManager.isSwitching = false
CharactersManager.statusCooldownActive = false
CharactersManager.isUpdating = false
local statusCooldownDuration = 60  -- seconds
local activeCharacterUpdateInterval = 60 -- seconds

-- Format names to proper case
local function properCase(name)
    return name:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)
end

-- Register login event to set active character
function CharactersManager.RegisterLoginEvent()
    registerAnonymousEventHandler("AshraelPackage.VoidWalker.Managers.CharactersManager.CharacterActive", "AshraelPackage.VoidWalker.Managers.CharactersManager.OnCharacterStatusActive")
end

CharactersManager.periodicUpdateTimer = nil

-- Periodic update function for active character stats and inventory
local function PeriodicUpdateActiveCharacter()
    local activeCharacter = CharactersDA.GetActiveCharacter()
    local currentCharacterName = properCase(gmcp.Char.Status.character_name or "")

    -- Check if the current character is registered
    if currentCharacterName ~= "" then
        local currentCharacter = CharactersDA.GetCharacter(currentCharacterName)

        if not currentCharacter then
            -- If the character is not registered, show a thematic message
            cecho("<cyan>The void stirs with whispers: \"Who is this unknown soul, wandering the realms?\"\n")
            cecho("<yellow>Please register " .. currentCharacterName .. " before stepping into the void.\n")
            return  -- Exit the function, as there's no active character to update
        end

        -- If there's an active character and we're not switching, update stats
        if activeCharacter and not CharactersManager.isSwitching then
            CharactersManager.isUpdating = true

            -- Update active character's stats
            if gmcp.Char.Vitals then
                activeCharacter.health = gmcp.Char.Vitals.hp
                activeCharacter.mana = gmcp.Char.Vitals.mp
                activeCharacter.movement = gmcp.Char.Vitals.mv
                activeCharacter.tnl = gmcp.Char.Vitals.tnl
                activeCharacter.last_location = gmcp.Room.Info and gmcp.Room.Info.name or activeCharacter.last_location
                CharactersDA.UpdateCharacter(activeCharacter)
            end

            InventoryDA.UpdateInventoryFromGMCP(activeCharacter.name, "inv")
            CharactersManager.isUpdating = false
        else
            -- If there's no active character set it as active
            if not activeCharacter then
                cecho("<cyan>The void whispers, \"Recognizing you, " .. currentCharacterName .. ", and setting you as active.\"\n")
                CharactersDA.SetActiveCharacter(currentCharacterName)  -- Set the current character as active
                activeCharacter = CharactersDA.GetActiveCharacter()  -- Refresh active character

                -- Initialize character stats if needed
                if gmcp.Char.Vitals then
                    local health = gmcp.Char.Vitals.hp or 0
                    local mana = gmcp.Char.Vitals.mp or 0
                    local movement = gmcp.Char.Vitals.mv or 0
                    local tnl = gmcp.Char.Vitals.tnl or 0
                    local lastLocation = gmcp.Room.Info and gmcp.Room.Info.name or "Unknown"

                    -- Set character data
                    activeCharacter.health = health
                    activeCharacter.mana = mana
                    activeCharacter.movement = movement
                    activeCharacter.tnl = tnl
                    activeCharacter.last_location = lastLocation

                    -- Update the character in the database
                    CharactersDA.UpdateCharacter(activeCharacter)
                end

                -- Initialize inventory for the new character
                InventoryDA.ClearInventory(currentCharacterName)  -- Ensure inventory is cleared for a fresh start
                InventoryDA.UpdateInventoryFromGMCP(currentCharacterName, "inv")  -- Populate inventory from GMCP data
            end
        end
    end

    -- Reset the periodic update timer
    if CharactersManager.periodicUpdateTimer then
        killTimer(CharactersManager.periodicUpdateTimer)
    end
    CharactersManager.periodicUpdateTimer = tempTimer(activeCharacterUpdateInterval, PeriodicUpdateActiveCharacter)
end

CharactersManager.periodicUpdateTimer = tempTimer(activeCharacterUpdateInterval, PeriodicUpdateActiveCharacter)
CharactersManager.lastActiveCharacter = nil

function CharactersManager.OnCharacterStatusActive(event)
    if CharactersManager.statusCooldownActive then
        return
    end

    local function checkStatus()
        if gmcp.Char.Status and gmcp.Char.Status.character_name then
            local characterName = properCase(gmcp.Char.Status.character_name)
            local currentActiveCharacter = CharactersDA.GetActiveCharacter()

            if currentActiveCharacter and currentActiveCharacter.name == characterName then
                --cecho("<cyan>The void whispers, \"You are already here.\"\n")
                return
            end

            CharactersDA.SetActiveCharacter(characterName)
            CharactersManager.lastActiveCharacter = characterName

            InventoryDA.ClearInventory(characterName)
            InventoryDA.UpdateInventoryFromGMCP(characterName, "inv")

            local updateVitals = (function(activeCharacter)
                if gmcp.Char.Status and properCase(gmcp.Char.Status.character_name) == activeCharacter then
                    local character = CharactersDA.GetCharacter(activeCharacter)
                    if character and gmcp.Char.Vitals then
                        character.health = gmcp.Char.Vitals.hp
                        character.mana = gmcp.Char.Vitals.mp
                        character.movement = gmcp.Char.Vitals.mv
                        character.tnl = gmcp.Char.Vitals.tnl
                        character.last_location = gmcp.Room.Info and gmcp.Room.Info.name or character.last_location
                        CharactersDA.UpdateCharacter(character)
                    end
                else
                    cecho("<cyan>The void sighs, \"Patience...\"\n")
                    tempTimer(statusCooldownDuration, checkStatus)
                end
            end)(characterName)

            CharactersManager.statusCooldownActive = true
            tempTimer(statusCooldownDuration, function()
                CharactersManager.statusCooldownActive = false
            end)
        else
            tempTimer(statusCooldownDuration, checkStatus)
        end
    end

    tempTimer(30, checkStatus)
end

function CharactersManager.DisposeTriggers()
    if CharactersManager.nameTrigger then
        killTrigger(CharactersManager.nameTrigger)
        CharactersManager.nameTrigger = nil
    end
    if CharactersManager.passwordTrigger then
        killTrigger(CharactersManager.passwordTrigger)
        CharactersManager.passwordTrigger = nil
    end
    if CharactersManager.fallbackTimer then
        killTimer(CharactersManager.fallbackTimer)
        CharactersManager.fallbackTimer = nil
    end
end

function CharactersManager.StartSuppressingOutput()
    CharactersManager.DisposeTriggers()
    CharactersManager.SuppressTrigger = tempLineTrigger(1, 1000, function() deleteLine() end)
    cecho("<cyan>The mists of the void conceal all...\n")
    CharactersManager.SuppressFallbackTimer = tempTimer(5, CharactersManager.StopSuppressingOutput)
end

function CharactersManager.StopSuppressingOutput()
    if CharactersManager.SuppressTrigger then 
        killTrigger(CharactersManager.SuppressTrigger) 
        CharactersManager.SuppressTrigger = nil
    end
    if CharactersManager.SuppressFallbackTimer then 
        killTimer(CharactersManager.SuppressFallbackTimer) 
        CharactersManager.SuppressFallbackTimer = nil
    end
    deleteFull()
end

function CharactersManager.DisplayVoidwalkingMessage()
    cecho("\n\n\n")
    cecho("<magenta>══════════════════════════════════════════════════════════════════════════════\n")
    cecho("<white>                     .            .             .           .\n")
    cecho("<white>                  :::::.        :::::.       ::::.        ::::\n")
    cecho("<gray>               ::::::::::::.  ::::::::::::.  ::::::::::::.  ::::::::::::. \n")
    cecho("<gray>           :::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n")
    cecho("<gray>        ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n")
    cecho("<cyan>                   ╔═════════════════════════════════════════════╗\n")
    cecho("<cyan>                   ║ <yellow>    As you step forward, the <white>Void<yellow> unravels, <cyan>║\n")
    cecho("<cyan>                   ║ <yellow>         drawing you <green>deeper<yellow>...              <cyan>║\n")
    cecho("<cyan>                   ║ <yellow>   You transcend into the <green>Void's Embrace<yellow>.   <cyan>║\n")
    cecho("<cyan>                   ╚═════════════════════════════════════════════╝\n")
    cecho("<gray>        ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n")
    cecho("<gray>           :::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n")
    cecho("<white>               ::::::::::::.  ::::::::::::.  ::::::::::::.  ::::::::::::. \n")
    cecho("<white>                  :::::.        :::::.       ::::.        ::::\n")
    cecho("<white>                     .            .             .           .\n")
    cecho("<magenta>══════════════════════════════════════════════════════════════════════════════\n")
    cecho("<cyan>... Reality blurs as the <yellow>shadows embrace<cyan> you, <green>weaving<cyan> around your form ...\n")
    cecho("<magenta>══════════════════════════════════════════════════════════════════════════════\n")
    cecho("\n\n\n")
end

function CharactersManager.HandleLogin(name)
    name = properCase(name)

    CharactersDA.SetActiveCharacter(name)
    CharactersManager.isSwitching = false

    CharactersManager.DisplayVoidwalkingMessage()

    local char = CharactersDA.GetCharacter(name)
    if char and gmcp.Char.Vitals then
        char.health = gmcp.Char.Vitals.hp
        char.mana = gmcp.Char.Vitals.mp
        char.movement = gmcp.Char.Vitals.mv
        char.tnl = gmcp.Char.Vitals.tnl
        char.last_location = gmcp.Room.Info and gmcp.Room.Info.name or char.last_location
    end

    raiseEvent("AshraelPackage.VoidWalker.Managers.CharactersManager.CharacterActive", { characterName = char.name })
    
    CharactersManager.statusCooldownActive = false
end

function CharactersManager.RegisterCharacter(name, password)
    name = properCase(name)

    -- Check if the character already exists
    if CharactersDA.GetCharacter(name) then
        cecho("<yellow>Character " .. name .. " is already registered in the void.\n")
        return
    end

    -- Initialize character with GMCP values
    local health = gmcp.Char.Vitals and gmcp.Char.Vitals.hp or 0
    local mana = gmcp.Char.Vitals and gmcp.Char.Vitals.mp or 0
    local movement = gmcp.Char.Vitals and gmcp.Char.Vitals.mv or 0
    local tnl = gmcp.Char.Vitals and gmcp.Char.Vitals.tnl or 0
    local lastLocation = gmcp.Room.Info and gmcp.Room.Info.name or "Unknown"

    -- Register the new character
    CharactersDA.AddCharacter({
        name = name,
        password = password,
        health = health,
        mana = mana,
        movement = movement,
        tnl = tnl,
        last_location = lastLocation,
        is_active = 1,  -- Set as active upon registration
        is_registered = 1
    })
    
    CharactersDA.SetActiveCharacter(name)
    -- Update inventory for the new character (initialize as empty)
    InventoryDA.ClearInventory(name)  -- Ensure inventory is cleared for a fresh start
    InventoryDA.UpdateInventoryFromGMCP(name, "inv")  -- Populate inventory from GMCP data

    -- Immersive messaging for character registration
    cecho("<cyan>As you weave the threads of fate, <yellow>" .. name .. "<cyan> emerges from the shadows of the void...\n")
    cecho("<magenta>The air shimmers as the essence of <yellow>" .. name .. "<magenta> is solidified into existence.\n")
    cecho("<green>Character " .. name .. " has been registered successfully, ready to embark on their journey!\n")
    cecho("<cyan>They stand poised at the edge of the void, awaiting adventures untold...\n")
end

function CharactersManager.AddCharacter(name, password)
    -- Format the name to proper case
    name = properCase(name)

    -- Check if the character already exists
    local existingCharacter = CharactersDA.GetCharacter(name)
    if existingCharacter then
        cecho("<red>Error: Character " .. name .. " already exists in the void.<reset>\n")
        return false
    end

    -- Create a new character entry
    local newCharacter = {
        name = name,
        password = password,
        health = 100,  -- Set default values as needed
        mana = 100,
        movement = 100,
        tnl = 0,
        last_location = "Unknown",
        is_active = false,
        is_registered = true
    }

    -- Add the new character to the database
    CharactersDA.AddCharacter(newCharacter)

    -- Immersive messaging for character creation
    cecho("<cyan>The void stirs as you conjure the essence of <yellow>" .. name .. "<cyan>...\n")
    cecho("<magenta>A swirling mist envelops you, weaving the threads of existence...\n")
    cecho("<green>Character " .. name .. " has been successfully forged from the fabric of the void!<reset>\n")
    cecho("<cyan>You sense a new presence in the realm of shadows, ready to embark on adventures unseen...\n")

    return true
end

function CharactersManager.RemoveCharacter(name)
    name = properCase(name)

    -- Check if the character exists
    local character = CharactersDA.GetCharacter(name)
    if not character then
        cecho("<yellow>Character " .. name .. " is not registered in the void.\n")
        return
    end

    -- Immersive messaging for character removal
    cecho("<magenta>The void stirs as you prepare to release <yellow>" .. name .. "<magenta> back into its depths...\n")
    cecho("<cyan>As you utter the farewell, shadows envelop <yellow>" .. name .. "<cyan>, and they begin to fade...\n")
    
    -- Remove the character
    CharactersDA.DeleteCharacter(name)
    InventoryDA.ClearInventory(name)  -- Clear the character's inventory

    cecho("<green>Character " .. name .. " has been removed from the void, their essence dissipating into the ether.\n")
end

function CharactersManager.GetCharacterDetails(name)
    name = properCase(name)
    local char = CharactersDA.GetCharacter(name)
    
    if char then
        cecho(string.format("<magenta>═══════════════════════════════════════════════════════════════════════\n"))
        cecho(string.format("<cyan>    You reach through the swirling depths of the void and gaze upon <yellow>%s<cyan>...\n", char.name))
        cecho(string.format("<magenta>═══════════════════════════════════════════════════════════════════════\n"))
        
        local inventory = InventoryDA.GetInventory(name)
        
        cecho(string.format("<cyan>Character: %s\n  Health: %s, Mana: %s\n  Movement: %s, TNL: %s\n  Last Location: %s\n\n  Inventory:\n",
            char.name, char.health, char.mana, char.movement, char.tnl, char.last_location or "Unknown"))
        
        for _, item in ipairs(inventory) do
            cecho(string.format("    -%s (Type: %s, Container: %s)\n",
                item.name, item.type or "N/A", item.container or "main inventory"))
        end
    else
        cecho("<magenta>The void remains silent, as if the name whispered vanishes into the shadows...\n")
        cecho(string.format("<yellow>No knowledge of <cyan>%s<yellow> lingers within the void’s grasp.\n", name))
        cecho("<magenta>Perhaps they drift in realms beyond reach, beyond memory...\n")
    end
end

function CharactersManager.GetAllCharacters()
    local characters = CharactersDA.GetAllCharacters()
    if not characters or #characters == 0 then
        cecho("<yellow>No characters are currently registered in the void.\n")
        return {}
    end

    cecho("<magenta>===== ALL REGISTERED CHARACTERS =====\n")
    for _, char in ipairs(characters) do
        local status = (char.is_active == 1) and "<green>[Active]" or "<yellow>[Inactive]"
        cecho(string.format("<cyan>%s %s - Last Location: %s\n", status, char.name, char.last_location or "Unknown"))
    end
    cecho("<magenta>====================================\n")
    
    return characters
end

function CharactersManager.SwitchCharacter(name)
    if CharactersManager.isSwitching then
        cecho("<cyan>The void whispers, \"You must wait...\"\n")
        return
    end

    if CharactersManager.isUpdating then
        cecho("<cyan>The void shivers... try again later.\n")
        return
    end

    CharactersManager.isSwitching = true
    
    local currentName = properCase(gmcp.Char.Status.character_name or "")
    name = properCase(name)

    if currentName == name then
        cecho("<magenta>You cannot voidwalk into your own reflection.\n")
        CharactersManager.isSwitching = false
        return
    end

    local currentChar = CharactersDA.GetCharacter(currentName)
    if currentChar and gmcp.Char.Vitals then
        currentChar.health = gmcp.Char.Vitals.hp
        currentChar.mana = gmcp.Char.Vitals.mp
        currentChar.movement = gmcp.Char.Vitals.mv
        currentChar.tnl = gmcp.Char.Vitals.tnl
        currentChar.last_location = gmcp.Room.Info and gmcp.Room.Info.name or currentChar.last_location
        currentChar.is_active = false
        CharactersDA.UpdateCharacter(currentChar)
    else
        CharactersManager.isSwitching = false
        return
    end

    local char = CharactersDA.GetCharacter(name)
    if not (char and char.is_registered) then
        cecho("<yellow>The void does not recognize " .. name .. ".\n")
        CharactersManager.isSwitching = false
        return
    end

    cecho("<magenta>Voidwalking to " .. name .. "...\n")
    CharactersManager.StartSuppressingOutput()
    send("quit")

    tempTimer(2, function()
        connectToServer("avatar.outland.org", 3000)
        CharactersManager.nameTrigger = tempTrigger("What name shall you be known by", function()
            send(name)
            CharactersManager.passwordTrigger = tempTrigger("Your Password:", function()
                send(char.password)
                CharactersManager.HandleLogin(name)
                CharactersManager.DisposeTriggers()
            end)
        end)
    end)

    CharactersManager.fallbackTimer = tempTimer(10, function()
        if CharactersManager.isSwitching then
            cecho("<yellow>Switch timeout or failure occurred, resetting switch status.\n")
            CharactersManager.isSwitching = false
            CharactersManager.DisposeTriggers()
        end
    end)
end

CharactersManager.RegisterLoginEvent()

AshraelPackage.VoidWalker.Managers.CharactersManager = CharactersManager
return CharactersManager