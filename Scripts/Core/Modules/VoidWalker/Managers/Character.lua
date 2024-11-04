-- Define namespaces for Voidwalker characters
AshraelPackage = AshraelPackage or {}
AshraelPackage.VoidWalker = AshraelPackage.VoidWalker or {}
AshraelPackage.VoidWalker.Characters = AshraelPackage.VoidWalker.Characters or {}

-- Set up a local reference for easier use
local Characters = AshraelPackage.VoidWalker.Characters

-- Global storage for all character data in the Voidwalker system
Characters.CharacterData = Characters.CharacterData or {}

-- Flag to track if a character switch is in progress
Characters.IsSwitching = false
Characters.SuppressTrigger = nil
Characters.SuppressStopTrigger = nil

-- Helper function to proper case names
local function properCase(name)
    return name:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)
end

-- Function to start suppressing output while voidwalking
function Characters.StartSuppressingOutput()
    deleteFull()  -- Clear the screen initially
    Characters.SuppressTrigger = tempLineTrigger(1, 1000, function()
        deleteLine()  -- Hide each incoming line
    end)
    cecho("<cyan>Hiding output during voidwalk transition...\n")

    -- Set a trigger to detect the specific line that ends suppression
    Characters.SuppressStopTrigger = tempRegexTrigger("Last logged in from .+ on .+", function()
        Characters.StopSuppressingOutput()  -- Stop suppression once the line is matched
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
    deleteFull()  -- Clear the screen once more to ensure a fresh view
end

-- Ensure the current player is registered; if not, prompt for registration
function Characters.EnsureCurrentPlayerRegistered()
    local currentName = gmcp.Char.Status and gmcp.Char.Status.character_name
    if not currentName then
        cecho("<red>Error: Could not determine character name from GMCP data.\n")
        return false
    end

    currentName = properCase(currentName)

    if not Characters.CharacterData[currentName] or not Characters.CharacterData[currentName].IsRegistered then
        cecho(string.format("<yellow>You are not registered in the Voidwalker system as %s.\n", currentName))
        cecho("<yellow>Please use 'voidwalk register <password>' to complete registration.\n")
        return false
    end

    return true
end

-- Register a character for voidwalking with a provided password
function Characters.RegisterCharacter(name, password)
    name = properCase(name)
    cecho(string.format("<cyan>Registering character %s for Voidwalker...\n", name))

    Characters.CharacterData[name] = {
        Password = password,
        Stats = {},
        ProperName = name,
        LastLocation = gmcp.Room.Info and gmcp.Room.Info.name or "Unknown",
        Inventory = {},
        IsRegistered = true
    }

    if Characters.CharacterData[name] and Characters.CharacterData[name].IsRegistered then
        cecho(string.format("<green>Character %s has been registered successfully.\n", name))
    else
        cecho("<red>[ERROR] Registration failed to save for character " .. name .. "\n")
    end
end

-- Add a character to the system
function Characters.AddCharacter(name, password)
    if not Characters.EnsureCurrentPlayerRegistered() then
        cecho("<red>You must register your current character before adding others.\n")
        return
    end

    name = properCase(name)

    Characters.CharacterData[name] = {
        Password = password,
        Stats = {},
        ProperName = name,
        LastLocation = "Unknown",
        Inventory = {},
        IsRegistered = true
    }

    if Characters.CharacterData[name] and Characters.CharacterData[name].IsRegistered then
        cecho(string.format("<green>Character %s has been added and registered.\n", name))
    else
        cecho("<red>[ERROR] Failed to save data for character " .. name .. "\n")
    end
end

-- Remove a character from the system
function Characters.RemoveCharacter(name)
    name = properCase(name)

    if Characters.CharacterData[name] then
        Characters.CharacterData[name] = nil
        cecho(string.format("<red>Character %s has been removed.\n", name))
    else
        cecho(string.format("<yellow>Character %s does not exist.\n", name))
    end
end

-- Set the active character in CharacterData
function Characters.UpdateActiveStatus(currentName)
    currentName = properCase(currentName)
    
    for name, charData in pairs(Characters.CharacterData) do
        charData.IsActive = (name == currentName)
    end
    cecho(string.format("<cyan>Character %s set as active.\n", currentName))
end

-- Function to be called after successful login
function Characters.HandleLogin(name)
    name = properCase(name)
    Characters.UpdateActiveStatus(name)
    Characters.IsSwitching = false
    Characters.DisplayVoidwalkingMessage()  -- Show immersive message upon login
    cecho(string.format("<green>Successfully logged in as %s and set as active.\n", name))
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

-- Switch to a specified character by name
function Characters.SwitchCharacter(name)
    local currentName = gmcp.Char.Status and gmcp.Char.Status.character_name
    if not currentName then
        cecho("<red>Error: Could not determine character name from GMCP data.\n")
        return
    end

    currentName = properCase(currentName)
    name = properCase(name)

    if Characters.CharacterData[currentName] then
        Characters.UpdateCharacterData(currentName)
        cecho(string.format("<cyan>Updated data for current character: %s.\n", currentName))
    else
        cecho(string.format("<yellow>Current character %s is not registered in Voidwalker.\n", currentName))
        return
    end

    local char = Characters.CharacterData[name]
    if char and char.IsRegistered then
        if not Characters.IsSwitching then
            Characters.IsSwitching = true
            cecho(string.format("<magenta>Switching to character: %s...\n", name))
            
            Characters.StartSuppressingOutput()  -- Start suppressing output
            send("quit")
            local nameTrigger, passwordTrigger

            tempTimer(2, function()
                connectToServer("avatar.outland.org", 3000)

                nameTrigger = tempTrigger("What name shall you be known by, adventurer?", function()
                    send(name)

                    passwordTrigger = tempTrigger("Your Password:", function()
                        send(char.Password)
                        Characters.HandleLogin(name)

                        cecho(string.format("<green>Logged in as %s.\n", name))

                        if nameTrigger then killTrigger(nameTrigger) end
                        if passwordTrigger then killTrigger(passwordTrigger) end
                    end)
                end)
            end)
        else
            cecho("<yellow>Character switch is already in progress. Please wait.\n")
        end
    else
        cecho(string.format("<yellow>Character %s is not registered or was not found.\n", name))
    end
end

-- Utility to update character data from GMCP
function Characters.UpdateCharacterData(name)
    local charName = properCase(name)
    local char = Characters.CharacterData[charName]
    if not char then
        cecho(string.format("<yellow>Character '%s' not found in CharacterData. Aborting update.\n", charName))
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

    if gmcp.Char.Items.List and gmcp.Char.Items.List.items then
        char.Inventory = {}
        for _, item in ipairs(gmcp.Char.Items.List.items) do
            table.insert(char.Inventory, item.name)
        end
    end

    if gmcp.Char.Status then
        char.ProperName = gmcp.Char.Status.character_name or char.ProperName
    end
end

-- List all characters in the system (VoidGaze function)
function Characters.ListCharacters()
    cecho("<magenta>===== VOIDWALKER GAZE =====\n")
    if next(Characters.CharacterData) == nil then
        cecho("<yellow>No characters have been registered yet.\n")
        return
    end

    for name, char in pairs(Characters.CharacterData) do
        local status = char.IsActive and "<green>[Active]" or "<yellow>[Inactive]"
        cecho(string.format("<cyan>%s %s - Last Location: %s\n", status, char.ProperName, char.LastLocation or "Unknown"))
    end
    cecho("<magenta>===========================\n")
end

-- Get detailed character information
function Characters.GetCharacterDetails(name)
    name = properCase(name)
    local char = Characters.CharacterData[name]
    
    if not char then
        cecho(string.format("<yellow>Character %s not found.\n", name))
        return
    end
    
    cecho(string.format("<cyan>Character: %s\n", char.ProperName))
    cecho(string.format("  Health: %s/%s, Mana: %s/%s\n", char.Stats.Health or "N/A", char.Stats.Health_Max or "N/A",
                         char.Stats.Mana or "N/A", char.Stats.Mana_Max or "N/A"))
    cecho(string.format("  Last Location: %s\n", char.LastLocation or "Unknown"))
    cecho(string.format("  Inventory: %s\n", char.Inventory and table.concat(char.Inventory, ", ") or "None"))
end
