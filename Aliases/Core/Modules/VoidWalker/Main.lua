-- Regex Triggers:
-- ^void(walk|gaze)(?:\s+(\w+)(?:\s+(.*))?)?$

-- Regex Triggers:
-- ^void(walk|gaze)(?:\s+(\w+)(?:\s+(.*))?)?$

-- Set local references to the VoidWalker namespaces
local Characters = AshraelPackage.VoidWalker.Characters
local Inventory = AshraelPackage.VoidWalker.Inventory

local mainCommand = matches[2]  -- 'walk' or 'gaze'
local subCommand = matches[3]  -- primary argument like character name, 'register', 'add', etc.
local option = matches[4]  -- additional option, e.g., password or item name

if mainCommand == "walk" then
    -- Register command: `voidwalk register <password>`
    if subCommand == "register" and option then
        -- Register the current character with the provided password
        local currentName = gmcp.Char.Status and gmcp.Char.Status.character_name
        if currentName then
            Characters.RegisterCharacter(currentName, option)
        else
            cecho("<red>Error: Unable to determine current character name.\n")
        end

    -- Add command: `voidwalk add <character> <password>`
    elseif subCommand == "add" then
        -- Split `option` to get character name and password if provided
        local name, password = option:match("^(%S+)%s+(%S+)$")
        if name and password then
            Characters.AddCharacter(name, password)
        else
            cecho("\n<red>Usage: voidwalk add <character> <password><reset>\n")
        end

    -- Remove command: `voidwalk remove <character>`
    elseif subCommand == "remove" and option then
        Characters.RemoveCharacter(option)

    -- Switch command: `voidwalk <character>`
    elseif subCommand then
        Characters.SwitchCharacter(subCommand)

    else
        cecho("\n<red>Usage: voidwalk <character> | voidwalk register <password> | voidwalk add <character> <password> | voidwalk remove <character><reset>\n")
    end

elseif mainCommand == "gaze" then
    -- List command: `voidgaze` or `voidgaze list`
    if not subCommand or subCommand == "list" then
        Characters.ListCharacters()

    -- Inventory command: `voidgaze inventory` or `voidgaze inv`
    elseif subCommand == "inventory" or subCommand == "inv" then
        Inventory.ShowConsolidatedInventory()

    -- Search command: `voidgaze search <item>`
    elseif subCommand == "search" and option then
        Inventory.SearchItem(option)

    -- Character details command: `voidgaze <character>`
    elseif subCommand then
        Characters.GetCharacterDetails(subCommand)

    else
        cecho("\n<red>Usage: voidgaze [list | <character> | inventory | search <item>]<reset>\n")
    end

else
    cecho("\n<red>Usage: voidwalk | voidgaze<reset>\n")
end