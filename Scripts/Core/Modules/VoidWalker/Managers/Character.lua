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

-- Ensure the current player is registered; if not, prompt for registration
function Characters.EnsureCurrentPlayerRegistered()
    local currentName = gmcp.Char.Status and gmcp.Char.Status.character_name:lower()
    if not currentName then
        cecho("<red>Error: Could not determine character name from GMCP data.\n")
        return false
    end

    if not Characters.CharacterData[currentName] or not Characters.CharacterData[currentName].IsRegistered then
        cecho(string.format("<yellow>You are not registered in the Voidwalker system as %s.\n", currentName))
        cecho("<yellow>Please use 'voidwalk register <password>' to complete registration.\n")
        return false
    end

    return true
end

-- Register a character for voidwalking with a provided password
function Characters.RegisterCharacter(name, password)
    cecho(string.format("<cyan>Registering character %s for Voidwalker...\n", name))

    Characters.CharacterData[name:lower()] = {
        Password = password,
        Stats = {},
        ProperName = name,
        Title = gmcp.Room.Players and gmcp.Room.Players[name] and gmcp.Room.Players[name].fullname or "",
        LastLocation = gmcp.Room.Info and gmcp.Room.Info.name or "Unknown",
        RoomExits = gmcp.Room.Info and gmcp.Room.Info.exits or {},
        Inventory = {},
        IsRegistered = true
    }

    if Characters.CharacterData[name:lower()] and Characters.CharacterData[name:lower()].IsRegistered then
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
        Password = password,
        Stats = {},
        ProperName = name,
        Title = "",
        LastLocation = "Unknown",
        RoomExits = {},
        Inventory = {},
        IsRegistered = true
    }

    if Characters.CharacterData[name:lower()] and Characters.CharacterData[name:lower()].IsRegistered then
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
        local primaryStatus = char.isPrimary and "<green>[Active]<reset> " or ""
        cecho(string.format("<blue>%s%s - Title: %s, Last Location: %s\n", 
              primaryStatus, (char.ProperName or name), (char.Title or "No title"), (char.LastLocation or "Unknown")))
    end
end

-- Set the primary (active) character in CharacterData
function Characters.UpdatePrimaryStatus(currentName)
    for name, charData in pairs(Characters.CharacterData) do
        charData.isPrimary = (name == currentName:lower())
    end
    cecho(string.format("<cyan>Character %s set as primary.\n", currentName))
end

-- Function to be called after successful login
function Characters.HandleLogin(name)
    Characters.UpdatePrimaryStatus(name)
    Characters.IsSwitching = false
    Characters.DisplayVoidwalkingMessage()  -- Display immersive login message
    cecho(string.format("<green>Successfully logged in as %s and set as primary.\n", name))
end

-- Display immersive voidwalking message with periods and dashes
function Characters.DisplayVoidwalkingMessage()
    checho("\n")
    cecho("<magenta>------------------------------------------------------\n")
    cecho("<cyan>   .................................................\n")
    cecho("<cyan>   ..       You step into the void...             ..\n")
    cecho("<cyan>   ..       Time and space slip away.             ..\n")
    cecho("<cyan>   ..     Re-emerging in another form.            ..\n")
    cecho("<cyan>   .................................................\n")
    cecho("<magenta>------------------------------------------------------\n\n")
    checho("\n")
end


-- Switch to a specified character by name
function Characters.SwitchCharacter(name)
    local currentName = gmcp.Char.Status and gmcp.Char.Status.character_name:lower()
    if not currentName then
        cecho("<red>Error: Could not determine current character name from GMCP data.\n")
        return
    end

    if Characters.CharacterData[currentName] then
        Characters.UpdateCharacterData(currentName)
        cecho(string.format("<cyan>Updated data for current character: %s.\n", currentName))
    else
        cecho(string.format("<yellow>Current character %s is not registered in Voidwalker.\n", currentName))
        return
    end

    local char = Characters.CharacterData[name:lower()]
    if char and char.IsRegistered then
        if not Characters.IsSwitching then
            Characters.IsSwitching = true
            cecho(string.format("<magenta>Switching to character: %s...\n", name))

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
    local charName = name:lower()
    local char = Characters.CharacterData[charName]
    if not char then
        cecho(string.format("<yellow>[DEBUG] Character '%s' not found in CharacterData. Aborting update.\n", charName))
        return
    end

    cecho(string.format("<cyan>[DEBUG] Updating GMCP data for character '%s'...\n", charName))

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
        char.RoomExits = gmcp.Room.Info.exits or char.RoomExits
    end

    if gmcp.Char.Items.List and gmcp.Char.Items.List.items then
        char.Inventory = {}
        for _, item in ipairs(gmcp.Char.Items.List.items) do
            table.insert(char.Inventory, item.name)
        end
    end

    if gmcp.Char.Status then
        char.ProperName = gmcp.Char.Status.character_name or char.ProperName
        char.Title = gmcp.Room.Players[charName] and gmcp.Room.Players[charName].fullname or char.Title
    end
end
