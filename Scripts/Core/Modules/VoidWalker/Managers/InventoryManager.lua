local InventoryManager = AshraelPackage.VoidWalker.Managers.InventoryManager
local CharactersDA = AshraelPackage.VoidWalker.DataAccessors.CharactersDA
local InventoryDA = AshraelPackage.VoidWalker.DataAccessors.InventoryDA

-- Flags to manage blocking between Inventory and Voidwalking processes
InventoryManager.isUpdating = false

-- Retrieve and format the character name
function InventoryManager.GetCharName()
    local char_name = string.lower(gmcp.Char.Status.character_name):gsub("^%l", string.upper)
    return char_name ~= "" and char_name or "Unknown"
end

-- Checks if a character is registered in the VoidWalker system
function InventoryManager.IsCharacterRegistered(char_name)
    return CharactersDA.GetCharacter(char_name) ~= nil
end

-- Initialize the inventory for a character by name
function InventoryManager.InitializeInventory(characterName)
    characterName = characterName:gsub("^%l", string.upper)
    if not InventoryManager.IsCharacterRegistered(characterName) then
        cecho(string.format("<yellow>Cannot initialize inventory: %s not found in Voidwalker system.\n", characterName))
        return
    end
    InventoryDA.ClearInventory(characterName)
    cecho(string.format("<cyan>The void embraces the belongings of %s...\n", characterName))
end

-- Clear Inventory for a Character in the database
function InventoryManager.ClearInventory(character_name)
    InventoryDA.ClearInventory(character_name)
end

-- Main function to start inventory update by calling the DA
function InventoryManager.UpdateInventory(char_name, initial_location, depth, clearInventory)
    if InventoryManager.isUpdating then return end
    InventoryManager.isUpdating = true

    if not InventoryManager.IsCharacterRegistered(char_name) then
        InventoryManager.isUpdating = false
        return
    end

    -- Clear inventory if this is a fresh update
    if clearInventory then
        InventoryManager.ClearInventory(char_name)
    end

    InventoryDA.UpdateInventoryFromGMCP(char_name, initial_location, depth)
    InventoryManager.isUpdating = false
end

-- Show inventory details for a specific character
function InventoryManager.ShowCharacterInventory(character_name)
    local inventoryItems = InventoryDA.GetInventory(character_name)
    cecho(string.format("<cyan>Inventory for %s:\n", character_name))
    for _, item in ipairs(inventoryItems) do
        cecho(string.format("<green>%s<reset>: %s (Type: %s, Container: %s)\n",
            character_name, item.name, item.type or "N/A", item.container or "main inventory"))
    end
end

-- Display a consolidated inventory view of all items across all characters
function InventoryManager.ShowConsolidatedInventory()
    cecho("<cyan>The void reveals all treasures scattered across your essence...\n")
    for _, charData in ipairs(CharactersDA.GetAllCharacters()) do
        local inventoryItems = InventoryDA.GetInventory(charData.name)
        for _, item in ipairs(inventoryItems) do
            cecho(string.format("<green>%s<reset>: %s (Container: %s)\n",
                charData.name, item.name, item.container or "main inventory"))
        end
    end
    cecho("<magenta>The echoes of the void fade, inventory list complete.\n")
end

-- Search for an item across all characters' inventories
function InventoryManager.SearchItem(item_name)
    cecho("<cyan>Reaching into the depths of the void for '" .. item_name .. "'...\n")
    local found_items = {}
    item_name = string.lower(item_name)

    for _, charData in ipairs(CharactersDA.GetAllCharacters()) do
        for _, item in ipairs(InventoryDA.GetInventory(charData.name)) do
            if string.find(string.lower(item.name), item_name) then
                table.insert(found_items, {
                    character = charData.name,
                    name = item.name,
                    type = item.type,
                    state = item.state,
                    container = item.container
                })
            end
        end
    end

    if #found_items > 0 then
        cecho("<magenta>The void reveals the following items:\n")
        for _, item in ipairs(found_items) do
            cecho(string.format("<green>%s<reset>: %s (Type: %s, State: %s, Container: %s)\n",
                item.character, item.name, item.type or "N/A", item.state or "N/A", item.container or "main inventory"))
        end
    else
        cecho("<yellow>The void remains silent; no items found matching '" .. item_name .. "'.\n")
    end
end

AshraelPackage.VoidWalker.Managers.InventoryManager = InventoryManager
return InventoryManager