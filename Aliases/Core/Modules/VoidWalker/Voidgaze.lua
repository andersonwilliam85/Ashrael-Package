-- Regex Triggers:
-- ^voidgaze(?:\s+(\w+)(?:\s+(.*))?)?$

buAshraelPackage = AshraelPackage or {}
AshraelPackage.VoidWalker = AshraelPackage.VoidWalker or {}

local VoidWalker = AshraelPackage.VoidWalker
local Characters = AshraelPackage.VoidWalker.Managers.CharactersManager
local Inventory = AshraelPackage.VoidWalker.Managers.InventoryManager

-- `voidgaze` command handler
function VoidWalker.HandleVoidgazeCommand(subCommand, option)
    if subCommand == "help" then
        VoidWalker.DisplayHelp()
    elseif not subCommand or subCommand == "list" then
        Characters.GetAllCharacters()
    elseif subCommand == "inventory" or subCommand == "inv" then
        Inventory.ShowConsolidatedInventory()
    elseif subCommand == "search" and option then
        Inventory.SearchItem(option)
    elseif subCommand then
        Characters.GetCharacterDetails(subCommand)
    else
        cecho("<yellow>Type <green>voidgaze help<yellow> for a list of available commands.\n")
    end
end

-- Alias setup for `voidgaze` command
local voidgazeCommand = matches[2]
local voidgazeOption = matches[3]
VoidWalker.HandleVoidgazeCommand(voidgazeCommand, voidgazeOption)