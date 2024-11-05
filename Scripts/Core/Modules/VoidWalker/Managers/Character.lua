local Characters = AshraelPackage.VoidWalker.Characters
local Inventory = AshraelPackage.VoidWalker.Inventory

Characters.CharacterData = Characters.CharacterData or {}

-- Flags for managing the state of processes
Characters.isSwitching = false
Inventory.isUpdating = false
Characters.SuppressTrigger = nil
Characters.SuppressStopTrigger = nil

-- Helper function to proper case names
local function properCase(name)
    return name:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)
end

-- Function to start suppressing output while voidwalking
function Characters.StartSuppressingOutput()
    deleteFull()
    Characters.SuppressTrigger = tempLineTrigger(1, 1000, function()
        deleteLine()
    end)
    cecho("<cyan>The mists of the void conceal all...\n")

    Characters.SuppressStopTrigger = tempRegexTrigger("Last logged in from .+ on .+", function()
        Characters.StopSuppressingOutput()
    end)
end

-- Function to stop suppressing output after voidwalking completes
function Characters.StopSuppressingOutput()
    if Characters.SuppressTrigger then
        killTrigger(Characters.SuppressTrigger)
        Characters.SuppressTrigger = nil
    end
    if Characters.SuppressStopTrigger then
        killTrigger(Characters.SuppressStopTrigger)
        Characters.SuppressStopTrigger = nil
    end
    deleteFull()
end

-- Ensure the current player is registered; if not, prompt for registration
function Characters.EnsureCurrentPlayerRegistered()
    local currentName = gmcp.Char.Status and gmcp.Char.Status.character_name
    if not currentName then
        cecho("<red>Your presence cannot be detected. The void denies access.\n")
        return false
    end

    currentName = properCase(currentName)

    if not Characters.CharacterData[currentName] or not Characters.CharacterData[currentName].IsRegistered then
        cecho(string.format("<yellow>You have yet to be bound to the Voidwalker system as %s.\n", currentName))
        cecho("<yellow>Enter 'voidwalk register <password>' to seal your connection.\n")
        return false
    end

    return true
end

-- Register a character for voidwalking with a provided password
function Characters.RegisterCharacter(name, password)
    name = properCase(name)
    Characters.CharacterData[name] = {
        Password = password,
        Stats = {
            Health = gmcp.Char.Vitals and gmcp.Char.Vitals.hp or 0,
            Health_Max = gmcp.Char.Vitals and gmcp.Char.Vitals.maxhp or 0,
            Mana = gmcp.Char.Vitals and gmcp.Char.Vitals.mp or 0,
            Mana_Max = gmcp.Char.Vitals and gmcp.Char.Vitals.maxmp or 0,
            Movement = gmcp.Char.Vitals and gmcp.Char.Vitals.mv or 0,
            Movement_Max = gmcp.Char.Vitals and gmcp.Char.Vitals.maxmv or 0,
            TNL = gmcp.Char.Vitals and gmcp.Char.Vitals.tnl or 0,
            MaxTNL = gmcp.Char.Vitals and gmcp.Char.Vitals.maxtnl or 0,
        },
        ProperName = name,
        LastLocation = gmcp.Room.Info and gmcp.Room.Info.name or "Unknown",
        IsRegistered = true,
        IsActive = true
    }

    -- Initialize inventory for the character and perform an initial scan
    Inventory.InitializeInventory(name)
    Inventory.UpdateInventory(name, "inv")

    cecho(string.format("<cyan>Your essence, %s, is now etched into the void.\n", name))
end

-- Add a character to the system
function Characters.AddCharacter(name, password)
    if not Characters.EnsureCurrentPlayerRegistered() then
        cecho("<red>The veil of the void requires your registration before adding others.\n")
        return
    end

    name = properCase(name)
    Characters.CharacterData[name] = {
        Password = password,
        Stats = {
            Health = 0,
            Health_Max = 0,
            Mana = 0,
            Mana_Max = 0,
            Movement = 0,
            Movement_Max = 0,
            TNL = 0,
            MaxTNL = 0,
        },
        ProperName = name,
        LastLocation = "Unknown",
        IsRegistered = true,
        IsActive = false
    }

    -- Initialize inventory for the character and perform an initial scan
    Inventory.InitializeInventory(name)
    Inventory.UpdateInventory(name, "inv")

    cecho(string.format("<cyan>%s has been inscribed upon the void.\n", name))
end

-- Remove a character from the system
function Characters.RemoveCharacter(name)
    name = properCase(name)

    if Characters.CharacterData[name] then
        Characters.CharacterData[name] = nil
        Inventory.ClearInventory(name)
        cecho(string.format("<red>%s has been erased from the void.\n", name))
    else
        cecho(string.format("<yellow>No trace of %s exists within the void.\n", name))
    end
end

-- Set the active character in CharacterData
function Characters.UpdateActiveStatus(currentName)
    currentName = properCase(currentName)
    
    for name, charData in pairs(Characters.CharacterData) do
        charData.IsActive = (name == currentName)
    end
    cecho(string.format("<cyan>Your presence as %s resonates within the void.\n", currentName))
end

-- Function to be called after successful login, updating inventory and stats
function Characters.HandleLogin(name)
    name = properCase(name)
    Characters.UpdateActiveStatus(name)
    Characters.isSwitching = false
    Characters.DisplayVoidwalkingMessage()

    -- Update character stats and inventory immediately upon login
    Characters.UpdateCharacterData(name)
end

-- Display immersive voidwalking message with expanded format
function Characters.DisplayVoidwalkingMessage()
    cecho("<magenta>=====================================================================================\n")
    cecho("<cyan>   .................................................\n")
    cecho("<cyan>   ..                                               ..\n")
    cecho("<cyan>   ..      You are enveloped in a swirling void...  ..\n")
    cecho("<cyan>   ..       Time and space blur around you...       ..\n")
    cecho("<cyan>   ..        You feel your essence shift...         ..\n")
    cecho("<cyan>   ..       Re-emerging in a new form, anew.        ..\n")
    cecho("<cyan>   ..                                               ..\n")
    cecho("<cyan>   .................................................\n")
    cecho("<magenta>=====================================================================================\n\n")
end

-- Safe function to switch characters with a check for inventory updates
function Characters.SafeSwitchCharacter(name)
    if Inventory.isUpdating then
        tempTimer(0.5, function() Characters.SafeSwitchCharacter(name) end)
    else
        Characters.SwitchCharacter(name)
    end
end

-- Switch to a specified character by name, ensuring inventory updates are complete
function Characters.SwitchCharacter(name)
    -- Delay switch if inventory update is ongoing
    if Inventory.isUpdating then
        Characters.SafeSwitchCharacter(name)
        return
    end

    Characters.isSwitching = true

    local currentName = gmcp.Char.Status and gmcp.Char.Status.character_name
    if not currentName then
        cecho("<red>Your essence cannot be discerned. The void denies access.\n")
        Characters.isSwitching = false
        return
    end

    currentName = properCase(currentName)
    name = properCase(name)

    if currentName == name then
        cecho("<magenta>The void shudders. You cannot voidwalk into your own reflection.\n")
        Characters.isSwitching = false
        return
    end

    if Characters.CharacterData[currentName] then
        Characters.UpdateCharacterData(currentName)
    else
        cecho(string.format("<yellow>No trace of %s exists within the void.\n", currentName))
        Characters.isSwitching = false
        return
    end

    local char = Characters.CharacterData[name]
    if char and char.IsRegistered then
        cecho(string.format("<magenta>Reaching across the void to manifest as %s...\n", name))
        Characters.StartSuppressingOutput()
        send("quit")
        local nameTrigger, passwordTrigger

        tempTimer(2, function()
            connectToServer("avatar.outland.org", 3000)

            nameTrigger = tempTrigger("What name shall you be known by, adventurer?", function()
                send(name)

                passwordTrigger = tempTrigger("Your Password:", function()
                    send(char.Password)
                    Characters.HandleLogin(name)

                    if nameTrigger then killTrigger(nameTrigger) end
                    if passwordTrigger then killTrigger(passwordTrigger) end
                end)
            end)
        end)
    else
        cecho(string.format("<yellow>The void does not recognize %s.\n", name))
        Characters.isSwitching = false
    end
end

-- Utility to update character data from GMCP and refresh inventory
function Characters.UpdateCharacterData(name)
    local charName = properCase(name)
    local char = Characters.CharacterData[charName]
    if not char then
        cecho(string.format("<yellow>No trace of %s exists within the void.\n", charName))
        return
    end

    if gmcp.Char.Vitals then
        char.Stats = {
            Health = gmcp.Char.Vitals.hp or char.Stats.Health,
            Health_Max = gmcp.Char.Vitals.maxhp or char.Stats.Health_Max,
            Mana = gmcp.Char.Vitals.mp or char.Stats.Mana,
            Mana_Max = gmcp.Char.Vitals.maxmp or char.Stats.Mana_Max,
            Movement = gmcp.Char.Vitals.mv or char.Stats.Movement,
            Movement_Max = gmcp.Char.Vitals.maxmv or char.Stats.Movement_Max,
            TNL = gmcp.Char.Vitals.tnl or char.Stats.TNL,
            MaxTNL = gmcp.Char.Vitals.maxtnl or char.Stats.MaxTNL
        }
    end

    if gmcp.Room.Info then
        char.LastLocation = gmcp.Room.Info.name or char.LastLocation
    end

    -- Update inventory using the Inventory API for the specific character
    Inventory.UpdateInventory(charName, "inv")
end

-- List all characters in the system
function Characters.ListCharacters()
    cecho("<magenta>===== VOIDWALKER GAZE =====\n")
    if next(Characters.CharacterData) == nil then
        cecho("<yellow>The void is empty. No characters have been bound.\n")
        return
    end

    for name, char in pairs(Characters.CharacterData) do
        local status = char.IsActive and "<green>[Active]" or "<yellow>[Inactive]"
        cecho(string.format("<cyan>%s %s - Last Location: %s\n", status, char.ProperName, char.LastLocation or "Unknown"))
    end
    cecho("<magenta>===========================\n")
end

-- Get detailed character information including inventory
function Characters.GetCharacterDetails(name)
    name = properCase(name)
    local char = Characters.CharacterData[name]
    
    if not char then
        cecho(string.format("<yellow>The void reveals no knowledge of %s.\n", name))
        return
    end
    
    cecho(string.format("<cyan>Character: %s\n", char.ProperName))
    cecho(string.format("  Health: %s/%s, Mana: %s/%s\n", char.Stats.Health or "N/A", char.Stats.Health_Max or "N/A",
                         char.Stats.Mana or "N/A", char.Stats.Mana_Max or "N/A"))
    cecho(string.format("  Last Location: %s\n", char.LastLocation or "Unknown"))
    
    -- Display inventory using Inventory API
    cecho("  Inventory:\n")
    Inventory.ShowCharacterInventory(name)
end
