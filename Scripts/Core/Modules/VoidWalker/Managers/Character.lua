-- Define namespaces for Voidwalker characters
AshraelPackage = AshraelPackage or {}
AshraelPackage.VoidWalker = AshraelPackage.VoidWalker or {}
AshraelPackage.VoidWalker.Characters = AshraelPackage.VoidWalker.Characters or {}

-- Set up a local reference for easier use
local Characters = AshraelPackage.VoidWalker.Characters

-- Global storage for all character data in the Voidwalker system
Characters.CharacterData = Characters.CharacterData or {}

-- Ensure the current player is registered; if not, prompt for registration
function Characters.EnsureCurrentPlayerRegistered()
    local currentName = gmcp.Char.Status and gmcp.Char.Status.character_name:lower()
    if not currentName then
        cecho("<red>Error: Could not determine character name from GMCP data.\n")
        return false
    end

    if not Characters.CharacterData[currentName] or not Characters.CharacterData[currentName].isRegistered then
        cecho(string.format("<yellow>You are not registered in the Voidwalker system as %s.\n", currentName))
        cecho("<yellow>Please use 'voidwalk register <password>' to complete registration.\n")
        return false
    end

    return true
end

-- Register a character for voidwalking with a provided password
function Characters.RegisterCharacter(name, password)
    cecho(string.format("<cyan>Registering character %s for Voidwalker...\n", name))

    -- Save character data with password
    Characters.CharacterData[name:lower()] = {
        password = password,
        Stats = {},
        ProperName = name,
        Title = gmcp.Room.Players and gmcp.Room.Players[name] and gmcp.Room.Players[name].fullname or "",
        LastLocation = gmcp.Room.Info and gmcp.Room.Info.name or "Unknown",
        RoomExits = gmcp.Room.Info and gmcp.Room.Info.exits or {},
        Inventory = {},
        isRegistered = true
    }

    -- Confirm data was saved
    if Characters.CharacterData[name:lower()] and Characters.CharacterData[name:lower()].isRegistered then
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

    Characters.CharacterData[name:lower()] = {
        password = password,
        Stats = {},
        ProperName = name,
        Title = "",
        LastLocation = "Unknown",
        RoomExits = {},
        Inventory = {},
        isRegistered = true
    }

    if Characters.CharacterData[name:lower()] and Characters.CharacterData[name:lower()].isRegistered then
        cecho(string.format("<green>Character %s has been added and registered.\n", name))
    else
        cecho("<red>[ERROR] Failed to save data for character " .. name .. "\n")
    end
end

-- Remove a character from the system
function Characters.RemoveCharacter(name)
    if Characters.CharacterData[name:lower()] then
        Characters.CharacterData[name:lower()] = nil
        cecho(string.format("<red>Character %s has been removed.\n", name))
    else
        cecho(string.format("<yellow>Character %s does not exist.\n", name))
    end
end

-- Get character details
function Characters.GetCharacterDetails(name)
    local char = Characters.CharacterData[name:lower()]
    if char then
        cecho("<cyan>Character: " .. (char.ProperName or name) .. "\n")
        cecho("  Title: " .. (char.Title or "No title available") .. "\n")
        cecho("  Health: " .. (char.Stats.Health or "N/A") .. "/" .. (char.Stats.Health_Max or "N/A") ..
              ", Mana: " .. (char.Stats.Mana or "N/A") .. "/" .. (char.Stats.Mana_Max or "N/A") .. "\n")
        cecho("  Last Location: " .. char.LastLocation .. "\n")
        cecho("  Inventory: " .. (char.Inventory and table.concat(char.Inventory, ", ") or "None") .. "\n")
    else
        cecho(string.format("<yellow>Character %s not found.\n", name))
    end
end

-- List all characters in the system
function Characters.ListCharacters()
    if next(Characters.CharacterData) == nil then
        cecho("<yellow>No characters added yet.\n")
        return
    end

    for name, char in pairs(Characters.CharacterData) do
        cecho("<blue>" .. (char.ProperName or name) .. " - Title: " .. (char.Title or "No title") ..
              ", Last Location: " .. (char.LastLocation or "Unknown") .. "\n")
    end
end

-- Switch to a specified character by name
function Characters.SwitchCharacter(name)
    -- Retrieve current character's name from GMCP
    local currentName = gmcp.Char.Status and gmcp.Char.Status.character_name:lower()
    if not currentName then
        cecho("<red>Error: Could not determine current character name from GMCP data.\n")
        return
    end

    -- Update the data for the currently logged-in character before switching
    if Characters.CharacterData[currentName] then
        Characters.UpdateCharacterData(currentName)
        cecho(string.format("<cyan>Updated data for current character: %s.\n", currentName))
    else
        cecho(string.format("<yellow>Current character %s is not registered in Voidwalker.\n", currentName))
        return
    end

    -- Begin switching to the specified character
    local char = Characters.CharacterData[name:lower()]
    if char and char.isRegistered then
        cecho(string.format("<magenta>Switching to character: %s...\n", name))

        -- Log out of the current session and reconnect
        send("quit")

        -- Declare variables to hold trigger IDs
        local nameTrigger, passwordTrigger

        tempTimer(2, function()
            connectToServer("avatar.outland.org", 3000)

            -- Set up the login name trigger and assign it to the nameTrigger variable
            nameTrigger = tempTrigger("What name shall you be known by, adventurer?", function()
                send(name)

                -- Set up the password trigger and assign it to the passwordTrigger variable
                passwordTrigger = tempTrigger("Your Password:", function()
                    send(char.password)
                    cecho(string.format("<green>Logged in as %s.\n", name))

                    -- Clean up the triggers
                    if nameTrigger then killTrigger(nameTrigger) end
                    if passwordTrigger then killTrigger(passwordTrigger) end
                end)
            end)
        end)
    else
        cecho(string.format("<yellow>Character %s is not registered or was not found.\n", name))
    end
end

function Characters.UpdateCharacterData(name)
    local charName = name:lower()
    local char = Characters.CharacterData[charName]
    if not char then
        cecho(string.format("<yellow>[DEBUG] Character '%s' not found in CharacterData. Aborting update.\n", charName))
        return
    end

    cecho(string.format("<cyan>[DEBUG] Updating GMCP data for character '%s'...\n", charName))

    -- Update Stats
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
        cecho(string.format("<cyan>[DEBUG] Updated character stats for %s: HP=%s/%s, Mana=%s/%s\n",
            charName, char.Stats.Health, char.Stats.Health_Max, char.Stats.Mana, char.Stats.Mana_Max))
    end

    -- Update Room Information
    if gmcp.Room.Info then
        char.LastLocation = gmcp.Room.Info.name or char.LastLocation
        char.RoomExits = gmcp.Room.Info.exits or char.RoomExits
        cecho(string.format("<cyan>[DEBUG] Updated LastLocation to '%s' for %s.\n", char.LastLocation, charName))
    end

    -- Update Inventory
    if gmcp.Char.Items.List and gmcp.Char.Items.List.items then
        char.Inventory = {}
        for _, item in ipairs(gmcp.Char.Items.List.items) do
            table.insert(char.Inventory, item.name)
        end
        cecho(string.format("<cyan>[DEBUG] Updated Inventory for %s with %d items.\n", charName, #char.Inventory))
    end

    -- Update Proper Name and Title
    if gmcp.Char.Status then
        char.ProperName = gmcp.Char.Status.character_name or char.ProperName
        char.Title = gmcp.Room.Players[charName] and gmcp.Room.Players[charName].fullname or char.Title
        cecho(string.format("<cyan>[DEBUG] Updated ProperName to '%s' and Title to '%s' for %s.\n",
            char.ProperName, char.Title, charName))
    end
end

