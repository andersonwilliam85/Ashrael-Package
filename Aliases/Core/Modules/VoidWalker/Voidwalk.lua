-- Regex Triggers:
-- ^voidwalk(?:\s+(\w+)(?:\s+(.*))?)?$

AshraelPackage = AshraelPackage or {}
AshraelPackage.VoidWalker = AshraelPackage.VoidWalker or {}

local VoidWalker = AshraelPackage.VoidWalker
local Characters = AshraelPackage.VoidWalker.Managers.CharactersManager
local Inventory = AshraelPackage.VoidWalker.Managers.InventoryManager

-- `voidwalk` command handler
function VoidWalker.HandleVoidwalkCommand(subCommand, option)
    if subCommand == "help" then
        VoidWalker.DisplayHelp()
    elseif subCommand == "register" and option then
        local currentName = gmcp.Char.Status and gmcp.Char.Status.character_name
        if currentName then
            Characters.RegisterCharacter(currentName, option)
        else
            cecho("<red>Error: Unable to determine current character name.\n")
        end
    elseif subCommand == "add" then
        local name, password = option:match("^(%S+)%s+(%S+)$")
        if name and password then
            Characters.AddCharacter(name, password)
        else
            cecho("\n<red>Usage: voidwalk add <character> <password><reset>\n")
        end
    elseif subCommand == "remove" and option then
        Characters.RemoveCharacter(option)
    elseif subCommand then
        Characters.SwitchCharacter(subCommand)
    else
        cecho("<yellow>Type <green>voidwalk help<yellow> for a list of available commands.\n")
    end
end

-- Alias setup for `voidwalk` command
local voidwalkCommand = matches[2]
local voidwalkOption = matches[3]
VoidWalker.HandleVoidwalkCommand(voidwalkCommand, voidwalkOption)
