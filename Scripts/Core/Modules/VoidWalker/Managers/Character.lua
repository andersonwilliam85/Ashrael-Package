-- AshraelPackage.VoidWalker.Characters
AshraelPackage.VoidWalker = AshraelPackage.VoidWalker or {}
AshraelPackage.VoidWalker.Characters = AshraelPackage.VoidWalker.Characters or {}

local Characters = AshraelPackage.VoidWalker.Characters

-- Internal storage for characters
Characters.characterData = {}

-- Add a character
function Characters.AddCharacter(name, password)
    Characters.characterData[name] = { 
        password = password,
        stats = { health = 100, mana = 100 }, -- Placeholder stats
        lastLocation = "Unknown",
        inventory = {}
    }
    cecho("<green>Character " .. name .. " has been added.\n")
end

-- Remove a character
function Characters.RemoveCharacter(name)
    if Characters.characterData[name] then
        Characters.characterData[name] = nil
        cecho("<red>Character " .. name .. " has been removed.\n")
    else
        cecho("<yellow>Character " .. name .. " does not exist.\n")
    end
end

-- Get character details
function Characters.GetCharacterDetails(name)
    local char = Characters.characterData[name]
    if char then
        cecho("<cyan>Character: " .. name .. "\n")
        cecho("  Health: " .. char.stats.health .. ", Mana: " .. char.stats.mana .. "\n")
        cecho("  Last Location: " .. char.lastLocation .. "\n")
        cecho("  Inventory: " .. table.concat(char.inventory, ", ") .. "\n")
    else
        cecho("<yellow>Character " .. name .. " not found.\n")
    end
end

-- List all characters
function Characters.ListCharacters()
    for name, char in pairs(Characters.characterData) do
        cecho("<blue>" .. name .. " - Last Location: " .. char.lastLocation .. "\n")
    end
end

-- Placeholder for future character functionality
function Characters.SwitchCharacter(name)
    -- Placeholder for actual switch behavior
    cecho("<magenta>Switching to character " .. name .. " (not yet implemented).\n")
end
