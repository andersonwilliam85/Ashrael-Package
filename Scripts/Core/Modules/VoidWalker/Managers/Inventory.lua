-- AshraelPackage.VoidWalker.Inventory
AshraelPackage.VoidWalker = AshraelPackage.VoidWalker or {}
AshraelPackage.VoidWalker.Inventory = AshraelPackage.VoidWalker.Inventory or {}

local Inventory = AshraelPackage.VoidWalker.Inventory

-- Consolidate and display the inventory of all characters
function Inventory.ShowConsolidatedInventory()
    cecho("<cyan>Function Call: ShowConsolidatedInventory\n")
    local consolidatedInventory = {}
    for name, char in pairs(Characters.characterData) do
        for _, item in ipairs(char.inventory) do
            consolidatedInventory[item] = (consolidatedInventory[item] or 0) + 1
        end
    end

    cecho("<cyan>Consolidated Inventory:\n")
    for item, count in pairs(consolidatedInventory) do
        cecho("  " .. item .. ": " .. count .. "\n")
    end
end

-- Search for an item across all character inventories
function Inventory.SearchItem(itemName)
    cecho("<cyan>Function Call: SearchItem - Searching for item: " .. itemName .. "\n")
    local foundItems = false
    for name, char in pairs(Characters.characterData) do
        if table.contains(char.inventory, itemName) then
            cecho("<green>" .. itemName .. " found in character " .. name .. "'s inventory.\n")
            foundItems = true
        end
    end
    if not foundItems then
        cecho("<red>Item " .. itemName .. " not found in any character's inventory.\n")
    end
end

-- Placeholder for future inventory functionality
function Inventory.AddItemToCharacter(name, item)
    cecho("<cyan>Function Call: AddItemToCharacter - Adding item " .. item .. " to character " .. name .. "\n")
    -- Placeholder for actual add item behavior
    cecho("<magenta>Adding item " .. item .. " to character " .. name .. " (not yet implemented).\n")
end
