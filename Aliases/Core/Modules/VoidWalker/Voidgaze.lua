-- Regex Triggers:
-- ^voidgaze(?:\s+(\w+)(?:\s+(.*))?)?$

local VoidWalker = AshraelPackage.VoidWalker
local CharactersManager = AshraelPackage.VoidWalker.Managers.CharactersManager
local InventoryManager = AshraelPackage.VoidWalker.Managers.InventoryManager

-- `voidgaze` command handler
function VoidWalker.HandleVoidgazeCommand(subCommand, option)
    if subCommand == "help" then
        VoidWalker.DisplayHelp()
    elseif not subCommand or subCommand == "list" then
        CharactersManager.GetAllCharacters()
    elseif subCommand == "inventory" or subCommand == "inv" then
        InventoryManager.ShowConsolidatedInventory()
    elseif subCommand == "search" and option then
        InventoryManager.SearchItem(option)
    elseif subCommand then
        CharactersManager.GetCharacterDetails(subCommand)
    else
        cecho("<yellow>Type <green>voidgaze help<yellow> for a list of available commands.\n")
    end
end

-- Alias setup for `voidgaze` command
local voidgazeCommand = matches[2]
local voidgazeOption = matches[3]
VoidWalker.HandleVoidgazeCommand(voidgazeCommand, voidgazeOption)