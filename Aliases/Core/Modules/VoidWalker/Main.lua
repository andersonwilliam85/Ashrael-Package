-- Regex Triggers:
-- ^void(walk|gaze)(?:\s+(\w+)(?:\s+(.*))?)?$

-- Alias: ^void(walk|gaze)(?:\s+(\w+)(?:\s+(.*))?)?$
-- This alias uses regex to match various command structures for `voidwalk` and `voidgaze`

-- Set local references to the VoidWalker namespaces
local Characters = AshraelPackage.VoidWalker.Characters
local Inventory = AshraelPackage.VoidWalker.Inventory

local mainCommand = matches[2] -- 'walk' or 'gaze'
local subCommand = matches[3] -- primary argument like character name or 'list'
local option = matches[4] -- additional option like 'inventory', 'inv', 'add', 'remove', etc.

if mainCommand == "walk" then
    if subCommand == "add" then
        -- Split `option` into character name and password if both are provided
        local name, password = option:match("^(%S+)%s+(%S+)$")
        if name and password then
            -- Calls the AddCharacter function with user-provided name and password
            Characters.AddCharacter(name, password)
        else
            cecho("\n<red>Usage: voidwalk add <char> <password><reset>\n")
        end

    elseif subCommand == "remove" and option then
        -- Calls the RemoveCharacter function
        Characters.RemoveCharacter(option)

    elseif subCommand then
        -- Calls the SwitchCharacter function
        Characters.SwitchCharacter(subCommand)

    else
        cecho("\n<red>Usage: voidwalk <char> | voidwalk add <char> <password> | voidwalk remove <char><reset>\n")
    end

elseif mainCommand == "gaze" then
    if not subCommand or subCommand == "list" then
        -- Calls the ListCharacters function
        Characters.ListCharacters()

    elseif subCommand == "inventory" or subCommand == "inv" then
        -- Calls the ShowConsolidatedInventory function
        Inventory.ShowConsolidatedInventory()

    elseif subCommand == "search" and option then
        -- Calls the SearchItem function
        Inventory.SearchItem(option)

    elseif subCommand then
        -- Calls the GetCharacterDetails function
        Characters.GetCharacterDetails(subCommand)

    else
        cecho("\n<red>Usage: voidgaze [list | <char> | inventory | search <item>]<reset>\n")
    end

else
    cecho("\n<red>Usage: voidwalk | voidgaze<reset>\n")
end
