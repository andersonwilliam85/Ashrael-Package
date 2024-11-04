local Inventory = AshraelPackage.VoidWalker.Inventory
local Characters = AshraelPackage.VoidWalker.Characters  -- Access to character data

Characters.CharacterData = Characters.CharacterData or {}

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
    Characters.CharacterData[characterName].Inventory = Characters.CharacterData[characterName].Inventory or {}
end

-- Main function to start inventory update using a queue-based traversal
function Inventory.UpdateInventory(char_name, initial_location, depth)
    depth = depth or 1

    -- Only proceed if the character is registered
    if not Inventory.IsCharacterRegistered(char_name) then
        return
    end

    -- Initialize inventory only if it doesn't exist
    Characters.CharacterData[char_name].Inventory = Characters.CharacterData[char_name].Inventory or {}

    -- Avoid going too deep in recursion
    if depth > 5 then
        return
    end

    -- Reset processed containers and queue for a fresh inventory update
    Inventory.processedContainers = {}
    Inventory.containerQueue = { { location = initial_location or "inv", containerName = "main inventory" } }

    -- Function to process next container in queue
    local function ProcessNextContainer()
        if #Inventory.containerQueue == 0 then
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

        -- Timer to wait for GMCP data to populate and then process it
        tempTimer(1, function()
            local gmcpData = gmcp.Char.Items
            if not gmcpData or not gmcpData.List or gmcpData.List.location ~= location then
                ProcessNextContainer()
                return
            end

            -- Process items in the container
            for _, item in ipairs(gmcpData.List.items) do
                item.name = RemoveColourCodes(item.name)

                -- Save item to character inventory, with additional `container` field
                table.insert(Characters.CharacterData[char_name].Inventory, {
                    id = item.id,
                    name = item.name,
                    type = item.type,
                    state = item.state,
                    container = containerName
                })

                -- Add containers to the queue if they are open and haven't been processed
                if item.type == "container" and item.state == "open" and not Inventory.processedContainers[item.id] then
                    table.insert(Inventory.containerQueue, { location = item.id, containerName = item.name })
                end
            end

            -- Proceed to next container in the queue
            ProcessNextContainer()
        end)
    end

    -- Initial attempt to fetch inventory using Char.Items.Inv
    if depth == 1 then
        sendGMCP("Char.Items.Inv")
        tempTimer(1, ProcessNextContainer)  -- Start processing with the initial location in the queue
    else
        ProcessNextContainer()
    end
end

-- Show consolidated inventory across all registered characters
function Inventory.ShowConsolidatedInventory()
    cecho("<cyan>Consolidated Inventory for All Characters:\n")
    for char_name, char_data in pairs(Characters.CharacterData) do
        for _, item in ipairs(char_data.Inventory or {}) do
            cecho(string.format("<green>%s<reset>: %s (Type: %s, Container: %s)\n",
                char_name, item.name, item.type or "N/A", item.container or "main inventory"))
        end
    end
end

-- Show inventory details for a specific character
function Inventory.ShowCharacterInventory(character_name)
    local char_data = Characters.CharacterData[character_name]
    if not char_data then
        cecho("<red>Error: Character '" .. character_name .. "' is not registered.\n")
        return
    end

    cecho("<cyan>Inventory for " .. character_name .. ":\n")
    for _, item in ipairs(char_data.Inventory or {}) do
        cecho(string.format("<green>%s<reset>: %s (Type: %s, Container: %s)\n",
            character_name, item.name, item.type or "N/A", item.container or "main inventory"))
    end
end

-- Search for an item across all characters' inventories
function Inventory.SearchItem(item_name)
    cecho("<cyan>Searching for '" .. item_name .. "' across all character inventories:\n")

    for char_name, char_data in pairs(Characters.CharacterData) do
        for _, item in ipairs(char_data.Inventory or {}) do
            if string.find(string.lower(item.name), string.lower(item_name)) then
                cecho(string.format("<green>%s<reset>: %s (Type: %s, State: %s, Container: %s)\n",
                    char_name, item.name, item.type or "N/A", item.state or "N/A", item.container or "main inventory"))
            end
        end
    end
end

-- Start an auto-update timer to refresh inventory periodically
function Inventory.StartAutoUpdate(interval)
    interval = interval or 30
    if Inventory.autoUpdateTimer then
        killTimer(Inventory.autoUpdateTimer)
    end
    Inventory.autoUpdateTimer = tempTimer(interval, function()
        if Connected() then
            local char_name = Inventory.GetCharName()
            Inventory.processedContainers = {}
            Inventory.UpdateInventory(char_name, "inv")
        end
    end, true)
end

-- Stops the auto-update timer
function Inventory.StopAutoUpdate()
    if Inventory.autoUpdateTimer then
        killTimer(Inventory.autoUpdateTimer)
        Inventory.autoUpdateTimer = nil
    end
end

-- Start the auto-update timer for inventory updates
Inventory.StartAutoUpdate(30)