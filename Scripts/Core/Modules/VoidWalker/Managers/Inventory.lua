-- Define the AshraelPackage.VoidWalker.Inventory namespace
AshraelPackage.VoidWalker = AshraelPackage.VoidWalker or {}
AshraelPackage.VoidWalker.Inventory = AshraelPackage.VoidWalker.Inventory or {}

local Inventory = AshraelPackage.VoidWalker.Inventory
local Characters = AshraelPackage.VoidWalker.Characters  -- Access to character data

-- Consolidate and display the inventory of all characters with a note on who is carrying each item
function Inventory.ShowConsolidatedInventory()
    cecho("<magenta>The void stirs, consolidating possessions across all bound souls...\n")
    local consolidatedInventory = {}

    -- Gather items from each character's inventory, noting who is carrying each
    for name, char in pairs(Characters.CharacterData) do
        for _, item in ipairs(char.Inventory) do
            consolidatedInventory[item] = consolidatedInventory[item] or {}
            table.insert(consolidatedInventory[item], char.ProperName)
        end
    end

    -- Display the consolidated inventory with immersive messaging
    if next(consolidatedInventory) then
        cecho("<cyan>The essence of all items manifests within the void:\n")
        for item, carriers in pairs(consolidatedInventory) do
            local carrierList = table.concat(carriers, ", ")
            cecho(string.format("  - %s: carried by %s\n", item, carrierList))
        end
    else
        cecho("<yellow>The void reveals no belongings; it lies empty and waiting.\n")
    end
end

-- Search for an item across all character inventories with fuzzy matching
function Inventory.SearchItem(itemName)
    cecho("<magenta>The void whispers, seeking the presence of '" .. itemName .. "'...\n")
    local foundItems = false
    local lowerItemName = itemName:lower()

    -- Search each character's inventory for items that include the specified name
    for name, char in pairs(Characters.CharacterData) do
        for _, item in ipairs(char.Inventory) do
            if item:lower():find(lowerItemName, 1, true) then  -- Case-insensitive fuzzy match
                cecho(string.format("<green>The essence of '%s' lingers in %s's possession as '%s'.\n", itemName, char.ProperName, item))
                foundItems = true
            end
        end
    end

    -- Display message if item is not found in any inventory
    if not foundItems then
        cecho("<red>The void offers no trace of '" .. itemName .. "' among any soul's belongings.\n")
    end
end

-- Placeholder for future functionality to add items to a character's inventory
function Inventory.AddItemToCharacter(name, item)
    cecho(string.format("<cyan>The void hums as '%s' is offered to %s's essence.\n", item, properCase(name)))
    -- Placeholder for the actual item addition logic, if implemented in the future
    cecho("<magenta>The offering has been noted, but the power to bestow it is not yet unlocked.\n")
end
