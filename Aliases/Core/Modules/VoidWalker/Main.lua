-- Regex Triggers:
-- ^void(walk|gaze)(?:\s+(\w+)(?:\s+(.*))?)?$

-- Alias: ^void(walk|gaze)(?:\s+(\w+)(?:\s+(.*))?)?$
-- This alias uses regex to match various command structures for `voidwalk` and `voidgaze`

local mainCommand = matches[2] -- 'walk' or 'gaze'
local subCommand = matches[3] -- primary argument like character name or 'list'
local option = matches[4] -- additional option like 'inventory', 'inv', 'add', 'remove', etc.

if mainCommand == "walk" then
    if subCommand == "add" then
        -- Commented-out actual function call, replaced with test output
        -- AshraelPackage.VoidWalker.AddCharacterDialogue()
        cecho("\n<cyan>Adding a new character... Prompting for name and password.<reset>\n")

    elseif subCommand == "remove" and option then
        -- Commented-out actual function call, replaced with test output
        -- AshraelPackage.VoidWalker.RemoveCharacter(option)
        cecho(string.format("\n<cyan>Removing character: %s<reset>\n", option))

    elseif subCommand then
        -- Commented-out actual function call, replaced with test output
        -- AshraelPackage.VoidWalker.SwitchCharacter(subCommand)
        cecho(string.format("\n<cyan>Switching to character: %s<reset>\n", subCommand))

    else
        cecho("\n<red>Usage: voidwalk <char> | voidwalk add | voidwalk remove <char><reset>\n")
    end

elseif mainCommand == "gaze" then
    if not subCommand or subCommand == "list" then
        -- Commented-out actual function call, replaced with test output
        -- AshraelPackage.VoidWalker.ListCharacters()
        cecho("\n<cyan>Listing all characters and their statuses.<reset>\n")

    elseif subCommand == "inventory" or subCommand == "inv" then
        -- Commented-out actual function call, replaced with test output
        -- AshraelPackage.VoidWalker.ShowConsolidatedInventory()
        cecho("\n<cyan>Showing consolidated inventory across all characters.<reset>\n")

    elseif subCommand == "search" and option then
        -- Commented-out actual function call, replaced with test output
        -- AshraelPackage.VoidWalker.SearchItemAcrossCharacters(option)
        cecho(string.format("\n<cyan>Searching for item '%s' across all characters.<reset>\n", option))

    elseif subCommand then
        -- Commented-out actual function call, replaced with test output
        -- AshraelPackage.VoidWalker.ShowCharacterDetails(subCommand)
        cecho(string.format("\n<cyan>Showing details for character: %s<reset>\n", subCommand))

    else
        cecho("\n<red>Usage: voidgaze [list | <char> | inventory | search <item>]<reset>\n")
    end

else
    cecho("\n<red>Usage: voidwalk | voidgaze<reset>\n")
end