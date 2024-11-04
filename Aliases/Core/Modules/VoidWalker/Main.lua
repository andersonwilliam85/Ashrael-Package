-- Regex Triggers:
-- ^void(walk|gaze)(?:\s+(\w+)(?:\s+(.*))?)?$

AshraelPackage = AshraelPackage or {}
AshraelPackage.VoidWalker = AshraelPackage.VoidWalker or {}

local VoidWalker = AshraelPackage.VoidWalker

-- Set local references to the VoidWalker namespaces
local Characters = AshraelPackage.VoidWalker.Characters
local Inventory = AshraelPackage.VoidWalker.Inventory

-- Detailed help for the VoidWalker module, including voidwalk and voidgaze commands
function VoidWalker.DisplayHelp()
    cecho("<cyan>VoidWalker Module Commands:\n")
    
    -- voidwalk commands
    cecho("<green>voidwalk<reset>: Manage and switch between registered characters.\n")
    cecho(" - <green>voidwalk <character><reset>: Switch to a specified character.\n")
    cecho(" - <green>voidwalk register <password><reset>: Register the current character with a password to enable VoidWalker features.\n")
    cecho(" - <green>voidwalk add <character> <password><reset>: Add a new character to VoidWalker with a specified password.\n")
    cecho(" - <green>voidwalk remove <character><reset>: Remove a character from VoidWalker.\n\n")

    -- voidgaze commands
    cecho("<green>voidgaze<reset>: View details and inventory for all registered characters.\n")
    cecho(" - <green>voidgaze<reset> or <green>voidgaze list<reset>: List all registered characters and their statuses.\n")
    cecho(" - <green>voidgaze <character><reset>: Display detailed information for a specific character.\n")
    cecho(" - <green>voidgaze inventory<reset> or <green>voidgaze inv<reset>: Show a consolidated inventory across all characters.\n")
    cecho(" - <green>voidgaze search <item><reset>: Search for a specific item in all characters' inventories.\n\n")

    -- Usage example
    cecho("<cyan>Example Usage:\n")
    cecho(" - <green>voidwalk register hunter123<reset>: Register the current character with password 'hunter123'.\n")
    cecho(" - <green>voidwalk add Warrior mage456<reset>: Add 'Warrior' with password 'mage456' to VoidWalker.\n")
    cecho(" - <green>voidgaze search sword<reset>: Search for 'sword' in all characters' inventories.\n")
end

-- Main command handler for voidwalk and voidgaze
local mainCommand = matches[2]  -- 'walk' or 'gaze'
local subCommand = matches[3]    -- primary argument like character name, 'register', 'add', etc.
local option = matches[4]        -- additional option, e.g., password or item name

if mainCommand == "walk" then
    -- Show help for voidwalk commands if "help" is specified
    if subCommand == "help" then
        VoidWalker.DisplayHelp()

    -- Register command: `voidwalk register <password>`
    elseif subCommand == "register" and option then
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

    -- No argument provided, display a helpful message
    else
        cecho("<yellow>Type <green>voidwalk help<yellow> for a list of available commands.\n")
    end

elseif mainCommand == "gaze" then
    -- Show help for voidgaze commands if "help" is specified
    if subCommand == "help" then
        VoidWalker.DisplayHelp()

    -- List command: `voidgaze` or `voidgaze list`
    elseif not subCommand or subCommand == "list" then
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

    -- No argument provided, display a helpful message
    else
        cecho("<yellow>Type <green>voidgaze help<yellow> for a list of available commands.\n")
    end

else
    cecho("\n<red>Usage: voidwalk | voidgaze<reset>\n")
end