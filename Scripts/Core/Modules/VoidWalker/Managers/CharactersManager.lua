local CharactersManager = AshraelPackage.VoidWalker.Managers.CharactersManager
local CharactersDA = AshraelPackage.VoidWalker.DataAccessors.CharactersDA
local InventoryDA = AshraelPackage.VoidWalker.DataAccessors.InventoryDA

-- Flags and intervals
CharactersManager.isSwitching = false
CharactersManager.statusCooldownActive = false
CharactersManager.isUpdating = false
local statusCooldownDuration = 30  -- seconds
local activeCharacterUpdateInterval = 30 -- seconds

-- Format names to proper case
local function properCase(name)
    return name:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)
end

-- Register login event to set active character
function CharactersManager.RegisterLoginEvent()
    registerAnonymousEventHandler("AshraelPackage.VoidWalker.Managers.CharactersManager.CharacterActive", "AshraelPackage.VoidWalker.Managers.CharactersManager.OnCharacterStatusActive")
    cecho("<green>DEBUG: Registered for CharacterActive event to handle character status updates.\n")
end

CharactersManager.periodicUpdateTimer = nil

-- Periodic update function for active character stats and inventory
local function PeriodicUpdateActiveCharacter()
    local activeCharacter = CharactersDA.GetActiveCharacter()  -- Retrieve active character from database
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")  -- Generate timestamp

    if activeCharacter and not CharactersManager.isSwitching then
        CharactersManager.isUpdating = true  -- Block switching while updating
        
        -- Debug: Starting periodic update with timestamp
        cecho(string.format("<green>[%s] DEBUG: Starting periodic update for active character '%s'.\n", timestamp, activeCharacter.name))
        
        -- Update character vitals if GMCP data is available
        if gmcp.Char.Vitals then
            activeCharacter.health = gmcp.Char.Vitals.hp
            activeCharacter.mana = gmcp.Char.Vitals.mp
            activeCharacter.movement = gmcp.Char.Vitals.mv
            activeCharacter.tnl = gmcp.Char.Vitals.tnl
            activeCharacter.last_location = gmcp.Room.Info and gmcp.Room.Info.name or activeCharacter.last_location
            CharactersDA.UpdateCharacter(activeCharacter)
            
            -- Debug: Character stats updated with timestamp
            cecho(string.format("<cyan>[%s] DEBUG: %s's stats updated successfully in the database.\n", timestamp, activeCharacter.name))
        end

        InventoryDA.UpdateInventoryFromGMCP(activeCharacter.name, "inv")
        
        -- Debug: Inventory refreshed with timestamp
        cecho(string.format("<cyan>[%s] DEBUG: Periodic inventory refresh for '%s' completed.\n", timestamp, activeCharacter.name))

        CharactersManager.isUpdating = false  -- Unblock switching after update completes
    else
        -- Debug: No active character or switching in progress
        cecho(string.format("<yellow>[%s] DEBUG: Periodic update skipped - no active character or switching in progress.\n", timestamp))
    end

    -- Schedule the next update, clearing the old timer if it exists
    if CharactersManager.periodicUpdateTimer then
        killTimer(CharactersManager.periodicUpdateTimer)
    end
    CharactersManager.periodicUpdateTimer = tempTimer(activeCharacterUpdateInterval, PeriodicUpdateActiveCharacter)
end

-- Start the periodic update timer
CharactersManager.periodicUpdateTimer = tempTimer(activeCharacterUpdateInterval, PeriodicUpdateActiveCharacter)

-- Track last successfully set active character
CharactersManager.lastActiveCharacter = nil

-- Event handler for character status updates, processed only when cooldown is inactive
function CharactersManager.OnCharacterStatusActive(event)
    if CharactersManager.statusCooldownActive then
        cecho("<yellow>DEBUG: Status cooldown active. Skipping character status update.\n")
        return
    end

    local function checkStatus()
        if gmcp.Char.Status and gmcp.Char.Status.character_name then
            local characterName = properCase(gmcp.Char.Status.character_name)
            local currentActiveCharacter = CharactersDA.GetActiveCharacter()  -- Fetch current active character from the database

            -- Skip inventory update if character is already active
            if currentActiveCharacter and currentActiveCharacter.name == characterName then
                cecho("<cyan>The void whispers, \"You are already here.\"\n")
                cecho(string.format("<green>DEBUG: Character '%s' is already active. No switch needed.\n", characterName))
                return
            end

            -- Only set a new active character and update inventory if a switch is confirmed
            CharactersDA.SetActiveCharacter(characterName)
            CharactersManager.lastActiveCharacter = characterName
            cecho(string.format("<green>DEBUG: Set '%s' as the new active character in the database.\n", characterName))

            -- Clear and update inventory only when switching to a new character
            InventoryDA.ClearInventory(characterName)
            InventoryDA.UpdateInventoryFromGMCP(characterName, "inv")
            cecho(string.format("<cyan>DEBUG: Inventory for '%s' has been refreshed upon activation.\n", characterName))

            -- Update character vitals in-line for the active character
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
                        cecho(string.format("<cyan>DEBUG: %s's vitals updated successfully in the database.\n", activeCharacter))
                    end
                else
                    cecho("<cyan>The void sighs, \"Patience...\"\n")
                    cecho(string.format("<yellow>DEBUG: Active character '%s' does not match GMCP character '%s'. Retrying...\n", activeCharacter, gmcp.Char.Status.character_name or "N/A"))
                    tempTimer(30, checkStatus)  -- Retry after a delay if vitals don’t match
                end
            end)(characterName)

            -- Activate cooldown to prevent frequent processing
            CharactersManager.statusCooldownActive = true
            tempTimer(statusCooldownDuration, function()
                CharactersManager.statusCooldownActive = false
                cecho("<green>DEBUG: Status cooldown reset.\n")
            end)
        else
            cecho("<yellow>DEBUG: No character data in GMCP. Retrying in 30 seconds.\n")
            tempTimer(30, checkStatus)  -- Retry if character status data is incomplete
        end
    end

    -- Schedule the first status check after a delay to control frequency
    tempTimer(30, checkStatus)
end

-- Dispose of triggers and timers related to the switching process
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
    cecho("<yellow>DEBUG: Disposed of any residual triggers and timers.\n")
end

-- Start suppressing output during voidwalking
function CharactersManager.StartSuppressingOutput()
    CharactersManager.DisposeTriggers()
    CharactersManager.SuppressTrigger = tempLineTrigger(1, 1000, function() deleteLine() end)
    cecho("<cyan>The mists of the void conceal all...\n")
    CharactersManager.SuppressFallbackTimer = tempTimer(5, CharactersManager.StopSuppressingOutput)
    cecho("<yellow>DEBUG: Output suppression started for voidwalking.\n")
end

-- Stop suppressing output
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
    cecho("<yellow>DEBUG: Output suppression ended.\n")
end

-- Display Voidwalking Message with Immersive Visuals
function CharactersManager.DisplayVoidwalkingMessage()
    cecho("\n\n\n")
    cecho("<magenta>══════════════════════════════════════════════════════════════════════════════\n")
    cecho("<cyan>                      .          .\n")
    cecho("<cyan>                     :::.       :::.\n")
    cecho("<cyan>                     ::::::..   :::::.\n")
    cecho("<cyan>                     ::::::::.. ::::::::.\n")
    cecho("<cyan>                     :::::::::::::::::::::.\n")
    cecho("<cyan>                   ╔═════════════════════════════════════════════╗\n")
    cecho("<cyan>                   ║ <yellow>As you step forward, the <white>Void<cyan>              ║\n")
    cecho("<cyan>                   ║ <yellow>unravels, drawing you <green>deeper<yellow>...<cyan>             ║\n")
    cecho("<cyan>                   ║ <yellow>You transcend into the <green>Void's Embrace<yellow>.<cyan>      ║\n")
    cecho("<cyan>                   ╚═════════════════════════════════════════════╝\n")
    cecho("<cyan>                      .          .\n")
    cecho("<cyan>                     :::.       :::.\n")
    cecho("<cyan>                     ::::::..   :::::.\n")
    cecho("<cyan>                     ::::::::.. ::::::::.\n")
    cecho("<cyan>                     :::::::::::::::::::::.\n")
    cecho("<magenta>══════════════════════════════════════════════════════════════════════════════\n")
    cecho("<cyan>... Reality blurs as the <yellow>shadows embrace<cyan> you, <green>weaving<cyan> around your form ...\n")
    cecho("<magenta>══════════════════════════════════════════════════════════════════════════════\n")
    cecho("\n\n\n")
    cecho("<yellow>DEBUG: Voidwalking message displayed.\n")
end

-- Handles post-login actions after voidwalking
function CharactersManager.HandleLogin(name)
    name = properCase(name)
    cecho(string.format("<green>DEBUG: Handling post-login for '%s'. Setting as active.\n", name))

    -- Set specified character as active in the database
    CharactersDA.SetActiveCharacter(name)
    CharactersManager.isSwitching = false

    -- Display voidwalking message to indicate successful switch
    CharactersManager.DisplayVoidwalkingMessage()

    -- Retrieve character data to update stats and location
    local char = CharactersDA.GetCharacter(name)
    if char and gmcp.Char.Vitals then
        char.health = gmcp.Char.Vitals.hp
        char.mana = gmcp.Char.Vitals.mp
        char.movement = gmcp.Char.Vitals.mv
        char.tnl = gmcp.Char.Vitals.tnl
        char.last_location = gmcp.Room.Info and gmcp.Room.Info.name or char.last_location
        --CharactersDA.UpdateCharacter(char)
        cecho(string.format("<cyan>DEBUG: %s's data saved post-login.\n", name))
        raiseEvent("AshraelPackage.VoidWalker.Managers.CharactersManager.CharacterActive", { characterName = char.name })
    end
    
    CharactersManager.statusCooldownActive = false
end

-- Retrieve and display detailed information for a character
function CharactersManager.GetCharacterDetails(name)
    name = properCase(name)
    local char = CharactersDA.GetCharacter(name)
    
    if char then
        -- Debug: Character found
        cecho(string.format("<green>DEBUG: Successfully retrieved character details for '%s'.\n", char.name))
        
        -- Immersive header before character stats
        cecho(string.format("<magenta>═══════════════════════════════════════════════════════════════════════\n"))
        cecho(string.format("<cyan>    You reach through the swirling depths of the void and gaze upon <yellow>%s<cyan>...\n", char.name))
        cecho(string.format("<magenta>═══════════════════════════════════════════════════════════════════════\n"))
        
        local inventory = InventoryDA.GetInventory(name)
        
        -- Display character stats with debug information
        cecho(string.format("<cyan>Character: %s\n  Health: %s, Mana: %s\n  Movement: %s, TNL: %s\n  Last Location: %s\n\n  Inventory:\n",
            char.name, char.health, char.mana, char.movement, char.tnl, char.last_location or "Unknown"))
        
        cecho(string.format("<green>DEBUG: Inventory for '%s' retrieved with %d items.\n", name, #inventory))

        for _, item in ipairs(inventory) do
            cecho(string.format("    -%s (Type: %s, Container: %s)\n",
                item.name, item.type or "N/A", item.container or "main inventory"))
        end
    else
        -- Debug: Character not found
        cecho(string.format("<red>DEBUG: No character found with the name '%s'.\n", name))
        
        -- Message if character is not found
        cecho("<magenta>The void remains silent, as if the name whispered vanishes into the shadows...\n")
        cecho(string.format("<yellow>No knowledge of <cyan>%s<yellow> lingers within the void’s grasp.\n", name))
        cecho("<magenta>Perhaps they drift in realms beyond reach, beyond memory...\n")
    end
end


-- Retrieve and display all registered characters
function CharactersManager.GetAllCharacters()
    local characters = CharactersDA.GetAllCharacters()
    if not characters or #characters == 0 then
        cecho("<yellow>No characters are currently registered in the void.\n")
        cecho("<green>DEBUG: GetAllCharacters called, but no registered characters were found.\n")
        return {}
    end

    cecho("<magenta>===== ALL REGISTERED CHARACTERS =====\n")
    for _, char in ipairs(characters) do
        local status = (char.is_active == 1) and "<green>[Active]" or "<yellow>[Inactive]"
        cecho(string.format("<cyan>%s %s - Last Location: %s\n", status, char.name, char.last_location or "Unknown"))
        cecho(string.format("<green>DEBUG: Character '%s' listed with status: %s.\n", char.name, status))
    end
    cecho("<magenta>====================================\n")
    
    return characters
end


-- Switch character, handling login and trigger cleanup
function CharactersManager.SwitchCharacter(name)
    if CharactersManager.isSwitching then
        cecho("<cyan>The void whispers, \"You must wait...\"\n")
        cecho("<yellow>DEBUG: Switch in progress. Cannot initiate a new switch.\n")
        return
    end

    if CharactersManager.isUpdating then
        cecho("<cyan>The void shivers... try again later.\n")
        cecho("<yellow>DEBUG: Update in progress. Switch temporarily blocked.\n")
        return
    end

    CharactersManager.isSwitching = true
    local currentName = properCase(gmcp.Char.Status.character_name or "")
    name = properCase(name)

    if currentName == name then
        cecho("<magenta>You cannot voidwalk into your own reflection.\n")
        CharactersManager.isSwitching = false
        cecho("<yellow>DEBUG: Switch canceled. Already logged in as requested character.\n")
        return
    end

    -- Update the current character's data before switching
    local currentChar = CharactersDA.GetCharacter(currentName)
    if currentChar and gmcp.Char.Vitals then
        currentChar.health = gmcp.Char.Vitals.hp
        currentChar.mana = gmcp.Char.Vitals.mp
        currentChar.movement = gmcp.Char.Vitals.mv
        currentChar.tnl = gmcp.Char.Vitals.tnl
        currentChar.last_location = gmcp.Room.Info and gmcp.Room.Info.name or currentChar.last_location
        currentChar.is_active = false
        CharactersDA.UpdateCharacter(currentChar)
        cecho(string.format("<yellow>DEBUG: %s's data updated in database before switching.\n", currentName))
    else
        CharactersManager.isSwitching = false
        cecho("<yellow>DEBUG: No current character data found. Canceling switch.\n")
        return
    end

    -- Check if the target character exists and is registered
    local char = CharactersDA.GetCharacter(name)
    if not (char and char.is_registered) then
        cecho("<yellow>The void does not recognize " .. name .. ".\n")
        CharactersManager.isSwitching = false
        cecho("<yellow>DEBUG: Switch failed. Target character not registered.\n")
        return
    end

    -- Set up voidwalking process
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

    -- Safety fallback timer to reset switching state and dispose triggers in case of failure
    CharactersManager.fallbackTimer = tempTimer(10, function()
        if CharactersManager.isSwitching then
            cecho("<yellow>Switch timeout or failure occurred, resetting switch status.\n")
            CharactersManager.isSwitching = false
            CharactersManager.DisposeTriggers()
        end
    end)
end

-- Initialize event registration
CharactersManager.RegisterLoginEvent()

AshraelPackage.VoidWalker.Managers.CharactersManager = CharactersManager
return CharactersManager
