local Inventory = AshraelPackage.VoidWalker.Inventory
local Characters = AshraelPackage.VoidWalker.Characters  -- Access to character data

Characters.CharacterData = Characters.CharacterData or {}

-- Flags to manage blocking between Inventory and Voidwalking processes
Inventory.isUpdating = false
Characters.isSwitching = false

-- Helper function to retrieve and format the character name
function Inventory.GetCharName()
    local char_name = string.lower(gmcp.Char.Status.character_name):gsub("^%l", string.upper)
    return char_name ~= "" and char_name or "Unknown"
end

-- Helper to remove color codes from item names
local function RemoveColourCodes(name)
    name = string.gsub(name, "\27%[%d+;%d+m", "")
    name = string.gsub(name, "\27", "")
    name = string.gsub(name, "|%w+|", "")
    return name
end

-- Checks if a character is registered in the VoidWalker system
function Inventory.IsCharacterRegistered(char_name)
    return Characters.CharacterData[char_name] ~= nil
end

-- Initialize the inventory for a character by name
function Inventory.InitializeInventory(characterName)
    characterName = characterName:gsub("^%l", string.upper)
    if not Characters.CharacterData[characterName] then
        cecho(string.format("<yellow>Cannot initialize inventory: %s not found in Voidwalker system.\n", characterName))
        return
    end
    Characters.CharacterData[characterName].Inventory = {}
    cecho(string.format("<cyan>The void embraces the belongings of %s...\n", characterName))
end

-- Safe function to update inventory with a check for ongoing voidwalking
function Inventory.SafeUpdateInventory(char_name, initial_location, depth, clearInventory)
    if Characters.isSwitching then
        tempTimer(0.5, function() Inventory.SafeUpdateInventory(char_name, initial_location, depth, clearInventory) end)
    else
        Inventory.UpdateInventory(char_name, initial_location, depth, clearInventory)
    end
end

-- Main function to start inventory update using a queue-based traversal
function Inventory.UpdateInventory(char_name, initial_location, depth, clearInventory)
    if Characters.isSwitching then
        Inventory.SafeUpdateInventory(char_name, initial_location, depth, clearInventory)
        return
    end

    Inventory.isUpdating = true

    if not Inventory.IsCharacterRegistered(char_name) then
        Inventory.isUpdating = false
        return
    end

    -- Clear inventory only if this is a fresh update (e.g., not during a switch)
    if clearInventory then
        Characters.CharacterData[char_name].Inventory = {}
    end

    depth = depth or 1
    if depth > 5 then
        Inventory.isUpdating = false
        return
    end

    Inventory.processedContainers = {}
    Inventory.containerQueue = { { location = initial_location or "inv", containerName = "main inventory" } }

    local function ProcessNextContainer()
        if #Inventory.containerQueue == 0 then
            Inventory.isUpdating = false
            return
        end

        local container = table.remove(Inventory.containerQueue, 1)
        local location = container.location
        local containerName = container.containerName

        if Inventory.processedContainers[location] then
            ProcessNextContainer()
            return
        end

        Inventory.processedContainers[location] = true
        sendGMCP("Char.Items.Contents " .. location)

        tempTimer(1, function()
            local gmcpData = gmcp.Char.Items
            if not gmcpData or not gmcpData.List or gmcpData.List.location ~= location then
                ProcessNextContainer()
                return
            end

            for _, item in ipairs(gmcpData.List.items) do
                item.name = RemoveColourCodes(item.name)

                table.insert(Characters.CharacterData[char_name].Inventory, {
                    id = item.id,
                    name = item.name,
                    type = item.type,
                    state = item.state,
                    container = containerName
                })

                if item.type == "container" and item.state == "open" and not Inventory.processedContainers[item.id] then
                    table.insert(Inventory.containerQueue, { location = item.id, containerName = item.name })
                end
            end

            ProcessNextContainer()
        end)
    end

    if depth == 1 then
        sendGMCP("Char.Items.Inv")
        tempTimer(1, ProcessNextContainer)
    else
        ProcessNextContainer()
    end
end

-- Show inventory details for a specific character
function Inventory.ShowCharacterInventory(character_name)
    local char_data = Characters.CharacterData[character_name]
    if not char_data then
        cecho("<red>Error: Character '" .. character_name .. "' is not registered.\n")
        return
    end

    cecho(string.format("<cyan>Inventory for %s:\n", character_name))
    for _, item in ipairs(char_data.Inventory or {}) do
        cecho(string.format("<green>%s<reset>: %s (Type: %s, Container: %s)\n",
            character_name, item.name, item.type or "N/A", item.container or "main inventory"))
    end
end

-- Display a consolidated inventory view of all items across all characters
function Inventory.ShowConsolidatedInventory()
    cecho("<cyan>The void reveals all treasures scattered across your essence...\n")
    for char_name, char_data in pairs(Characters.CharacterData) do
        for _, item in ipairs(char_data.Inventory or {}) do
            cecho(string.format("<green>%s<reset>: %s (Container: %s)\n",
                char_name, item.name, item.container or "main inventory"))
        end
    end
    cecho("<magenta>The echoes of the void fade, inventory list complete.\n")
end

-- Search for an item across all characters' inventories with immersive void-themed messaging
function Inventory.SearchItem(item_name)
    cecho("<cyan>Reaching into the depths of the void for '" .. item_name .. "'...\n")
    local found_items = {}
    item_name = string.lower(item_name)

    for char_name, char_data in pairs(Characters.CharacterData) do
        for _, item in ipairs(char_data.Inventory or {}) do
            if string.find(string.lower(item.name), item_name) then
                table.insert(found_items, {
                    character = char_name,
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
