local CharactersManager = AshraelPackage.VoidWalker.Managers.CharactersManager
local CharactersDA = AshraelPackage.VoidWalker.DataAccessors.CharactersDA
local InventoryManager = AshraelPackage.VoidWalker.Managers.InventoryManager

-- Flag to control switching state
CharactersManager.isSwitching = false

-- Format names to proper case
local function properCase(name)
    return name:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)
end

CharactersManager.statusCooldownActive = false
local statusCooldownDuration = 60  -- seconds

-- Register login event to set active character
function CharactersManager.RegisterLoginEvent()
    registerAnonymousEventHandler("gmcp.Char", "AshraelPackage.VoidWalker.Managers.CharactersManager.OnCharacterStatusActive")
end

-- Event handler for character status updates, processed only when cooldown is inactive
function CharactersManager.OnCharacterStatusActive(event)
    -- Only proceed if cooldown is not active
    cecho("StatusCooldownActive: " .. tostring(CharactersManager.statusCooldownActive))
    if CharactersManager.statusCooldownActive then
        return
    end

    local function checkStatus()
        if gmcp.Char.Status and gmcp.Char.Status.character_name then
            -- Debug output for event details
            local characterName = gmcp.Char.Status.character_name
            --cecho(string.format("<yellow>DEBUG: Event '%s' received with character name '%s'\n", event, characterName))

            -- Set active character and update inventory
            local name = properCase(characterName)
            CharactersDA.SetActiveCharacter(name)
            InventoryManager.ClearInventory(name)
            InventoryManager.UpdateInventory(name, "inv")
            --cecho(string.format("<cyan>%s's inventory has been updated and is now active.\n", name))

            -- Activate cooldown to prevent frequent processing
            CharactersManager.statusCooldownActive = true
            tempTimer(statusCooldownDuration, function()
                CharactersManager.statusCooldownActive = false
            end)
        else
            -- Schedule another check if status is not yet available
            tempTimer(1, checkStatus)
        end
    end

    -- Start the first check immediately
    checkStatus()
end

-- Register character
function CharactersManager.RegisterCharacter(name, password)
    name = properCase(name)
    CharactersDA.AddCharacter({
        name = name,
        health = gmcp.Char.Vitals and gmcp.Char.Vitals.hp or 0,
        mana = gmcp.Char.Vitals and gmcp.Char.Vitals.mp or 0,
        movement = gmcp.Char.Vitals and gmcp.Char.Vitals.mv or 0,
        tnl = gmcp.Char.Vitals and gmcp.Char.Vitals.tnl or 0,
        last_location = gmcp.Room.Info and gmcp.Room.Info.name or "Unknown",
        is_registered = true,
        is_active = true,
        password = password,
        inventory = {}
    })
    InventoryManager.InitializeInventory(name)
    InventoryManager.UpdateInventory(name, "inv")
    cecho(string.format("<cyan>%s has been registered in the void.\n", name))
end

-- Adds a new character to the Voidwalker system
function CharactersManager.AddCharacter(name, password)
    name = properCase(name)
    
    -- Check if character already exists
    local existingChar = CharactersDA.GetCharacter(name)
    if existingChar then
        cecho(string.format("<yellow>%s is already registered in the void.\n", name))
        return
    end

    -- Create and add new character details
    local newChar = {
        name = name,
        health = 0,
        mana = 0,
        movement = 0,
        tnl = 0,
        last_location = "Unknown",
        is_registered = true,
        is_active = false, -- New characters are inactive by default
        password = password,
        inventory = {}
    }

    -- Add the character to the database
    CharactersDA.AddCharacter(newChar)

    -- Initialize inventory for the new character
    InventoryManager.InitializeInventory(name)
    cecho(string.format("<cyan>%s has been added to the void.\n", name))
end

-- Removes a character from the Voidwalker system
function CharactersManager.RemoveCharacter(name)
    name = properCase(name)

    -- Retrieve the character to ensure it exists
    local char = CharactersDA.GetCharacter(name)
    if not char then
        cecho(string.format("<yellow>No record of %s found in the void.\n", name))
        return
    end

    -- Delete the character from the database
    CharactersDA.DeleteCharacter(name)

    -- Clear the character's inventory
    InventoryManager.ClearInventory(name)
    cecho(string.format("<red>%s has been erased from the void.\n", name))
end


-- Retrieves and displays all registered characters
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


-- Get detailed information for a character
function CharactersManager.GetCharacterDetails(name)
    name = properCase(name)
    local char = CharactersDA.GetCharacter(name)
    if char then
        cecho(string.format("<cyan>Character: %s\n  Health: %s, Mana: %s\n  Movement: %s, TNL: %s\n  Last Location: %s\n  Inventory:\n",
            char.name, char.health, char.mana, char.movement, char.tnl, char.last_location or "Unknown"))
        InventoryManager.ShowCharacterInventory(name)
    else
        cecho(string.format("<yellow>The void reveals no knowledge of %s.\n", name))
    end
end

-- Switch character, handling login and trigger cleanup
function CharactersManager.SwitchCharacter(name)
    if CharactersManager.isSwitching then
        cecho("<yellow>Switch already in progress. Please wait.\n")
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
    else
        cecho(string.format("<yellow>No trace of %s exists within the void.\n", currentName))
        CharactersManager.isSwitching = false
        return
    end

    -- Check if the target character exists and is registered
    local char = CharactersDA.GetCharacter(name)
    if not (char and char.is_registered) then
        cecho(string.format("<yellow>The void does not recognize %s.\n", name))
        CharactersManager.isSwitching = false
        return
    end

    -- Set up voidwalking process
    cecho(string.format("<magenta>Voidwalking to %s...\n", name))
    CharactersManager.StartSuppressingOutput()
    send("quit")

    tempTimer(2, function()
        connectToServer("avatar.outland.org", 3000)
        CharactersManager.nameTrigger = tempTrigger("What name shall you be known by", function()
            send(name)
            CharactersManager.passwordTrigger = tempTrigger("Your Password:", function()
                send(char.password)
                CharactersManager.HandleLogin(name)
                CharactersManager.DisposeTriggers()  -- Explicitly dispose triggers
            end)
        end)
    end)

    -- Safety fallback timer to reset switching state and dispose triggers in case of failure
    CharactersManager.fallbackTimer = tempTimer(10, function()
        if CharactersManager.isSwitching then
            cecho("<yellow>Switch timeout or failure occurred, resetting switch status.\n")
            CharactersManager.isSwitching = false
            CharactersManager.DisposeTriggers()  -- Ensure any triggers are removed
        end
    end)
end

-- Handles post-login actions after voidwalking
function CharactersManager.HandleLogin(name)
    name = properCase(name)

    -- Reset switching status
    CharactersManager.isSwitching = false

    -- Display voidwalking message
    CharactersManager.DisplayVoidwalkingMessage()

    -- Update character data and start inventory timer directly via DA
    CharactersDA.UpdateCharacterData(name, {
        health = gmcp.Char.Vitals and gmcp.Char.Vitals.hp or 0,
        mana = gmcp.Char.Vitals and gmcp.Char.Vitals.mp or 0,
        movement = gmcp.Char.Vitals and gmcp.Char.Vitals.mv or 0,
        tnl = gmcp.Char.Vitals and gmcp.Char.Vitals.tnl or 0,
        last_location = gmcp.Room.Info and gmcp.Room.Info.name or "Unknown"
    })
end


-- Display a message for successful voidwalking
function CharactersManager.DisplayVoidwalkingMessage()
    cecho("\n\n\n")
    cecho("<magenta>============================================================\n")
    cecho("<cyan>... You feel your essence shift, reforming in a new form ...\n")
    cecho("<magenta>============================================================\n")
    cecho("\n\n\n")
end

-- Start suppressing output during voidwalking
function CharactersManager.StartSuppressingOutput()
    CharactersManager.DisposeTriggers()  -- Clear any previous suppression
    CharactersManager.SuppressTrigger = tempLineTrigger(1, 1000, function() deleteLine() end)
    cecho("<cyan>The mists of the void conceal all...\n")
    CharactersManager.SuppressFallbackTimer = tempTimer(5, CharactersManager.StopSuppressingOutput)
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
end

-- Dispose of triggers and timers
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

-- Initialize event registration
CharactersManager.RegisterLoginEvent()

AshraelPackage.VoidWalker.Managers.CharactersManager = CharactersManager
return CharactersManager