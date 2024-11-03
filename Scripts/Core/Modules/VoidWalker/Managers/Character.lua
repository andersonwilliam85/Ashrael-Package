-- AshraelPackage.VoidWalker.Characters
AshraelPackage.VoidWalker = AshraelPackage.VoidWalker or {}
AshraelPackage.VoidWalker.Characters = AshraelPackage.VoidWalker.Characters or {}

local Characters = AshraelPackage.VoidWalker.Characters

-- Global storage for all character data in Voidwalker system
Characters.CharacterData = Characters.CharacterData or {}

-- Add a character to the system
function Characters.AddCharacter(name, password)
    Characters.CharacterData[name:lower()] = { 
        password = password,
        stats = { health = 100, mana = 100 }, -- Placeholder stats
        lastLocation = "Unknown",
        inventory = {}
    }
    cecho("<green>Character " .. name .. " has been added.\n")
end

-- Remove a character from the system
function Characters.RemoveCharacter(name)
    if Characters.CharacterData[name:lower()] then
        Characters.CharacterData[name:lower()] = nil
        cecho("<red>Character " .. name .. " has been removed.\n")
    else
        cecho("<yellow>Character " .. name .. " does not exist.\n")
    end
end

-- Get character details
function Characters.GetCharacterDetails(name)
    local char = Characters.CharacterData[name:lower()]
    if char then
        cecho("<cyan>Character: " .. name .. "\n")
        cecho("  Health: " .. char.stats.health .. ", Mana: " .. char.stats.mana .. "\n")
        cecho("  Last Location: " .. char.lastLocation .. "\n")
        cecho("  Inventory: " .. table.concat(char.inventory, ", ") .. "\n")
    else
        cecho("<yellow>Character " .. name .. " not found.\n")
    end
end

-- List all characters in the system
function Characters.ListCharacters()
    if next(Characters.CharacterData) == nil then
        cecho("<yellow>No characters added yet.\n")
        return
    end
    
    for name, char in pairs(Characters.CharacterData) do
        cecho("<blue>" .. name .. " - Last Location: " .. char.lastLocation .. "\n")
    end
end

-- Temporary variables for managing triggers to avoid overlap
local nameTrigger, passwordTrigger

-- Switch to a specified character by name
function Characters.SwitchCharacter(name)
    local char = Characters.CharacterData[name:lower()]
    if char then
        cecho(string.format("<magenta>Attempting to switch to character: %s...\n", name))
        
        -- Log out of current session and reconnect to MUD with provided credentials
        send("quit")
        cecho("<cyan>Sent quit command. Waiting to reconnect...\n")

        tempTimer(2, function() 
            connectToServer("avatar.outland.org", 3000)  -- Reconnect to the MUD
            cecho(string.format("<cyan>Reconnected to server for character: %s\n", name))
            
            -- Clean up any existing triggers to prevent overlaps
            if nameTrigger then killTrigger(nameTrigger) end
            if passwordTrigger then killTrigger(passwordTrigger) end

            -- Set up a temporary trigger for the login prompt
            nameTrigger = tempTrigger("What name shall you be known by, adventurer?", function()
                cecho(string.format("<cyan>Login prompt detected. Sending character name: %s\n", name))
                send(name)  -- Send the character name

                -- Clean up name trigger to ensure no duplicates
                if nameTrigger then
                    killTrigger(nameTrigger)
                    nameTrigger = nil
                    cecho("<cyan>Name trigger cleaned up.\n")
                end

                -- Set up a secondary temporary trigger for the password prompt
                passwordTrigger = tempTrigger("Your Password:", function()
                    cecho("<cyan>Password prompt detected. Sending password...\n")
                    send(char.password)  -- Send the character's password
                    cecho(string.format("<green>Logged in as %s.\n", name))

                    -- Clean up the password trigger after use
                    if passwordTrigger then
                        killTrigger(passwordTrigger)
                        passwordTrigger = nil
                        cecho("<cyan>Password trigger cleaned up.\n")
                    end
                end)
            end)
        end)
    else
        cecho(string.format("<yellow>Character %s not found in system.\n", name))
    end
end
