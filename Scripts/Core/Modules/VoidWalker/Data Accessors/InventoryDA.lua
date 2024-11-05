local InventoryDA = AshraelPackage.VoidWalker.DataAccessors.InventoryDA or {}
local VoidWalkerDB = AshraelPackage.VoidWalker.Databases.VoidWalkerDB

-- **Add Item to Character's Inventory**
function InventoryDA.AddItem(character_name, item)
    return db:add(VoidWalkerDB.inventory, {
        character_name = character_name,
        item_id = item.id,
        name = item.name,
        type = item.type or "",
        state = item.state or "",
        container = item.container or "main inventory"
    })
end

-- **Get Inventory for a Character**
function InventoryDA.GetInventory(character_name)
    local inventory = {}
    local items = db:fetch(VoidWalkerDB.inventory, db:eq(VoidWalkerDB.inventory.character_name, character_name))
    for _, item in ipairs(items) do
        table.insert(inventory, {
            id = item.item_id,
            name = item.name,
            type = item.type,
            state = item.state,
            container = item.container
        })
    end
    return inventory
end

-- **Update Inventory for a Character by Traversing GMCP Data**
function InventoryDA.UpdateInventoryFromGMCP(char_name, initial_location, depth)
    InventoryDA.ClearInventory(char_name)  -- Clear current inventory before updating

    depth = depth or 1
    if depth > 5 then return end  -- Prevent excessive depth

    -- Queue-based container processing for inventory traversal
    local containerQueue = { { location = initial_location or "inv", containerName = "main inventory" } }
    local processedContainers = {}

    local function ProcessNextContainer()
        if #containerQueue == 0 then return end

        local container = table.remove(containerQueue, 1)
        local location = container.location
        local containerName = container.containerName

        if processedContainers[location] then
            ProcessNextContainer()
            return
        end

        processedContainers[location] = true
        sendGMCP("Char.Items.Contents " .. location)

        tempTimer(1, function()
            local gmcpData = gmcp.Char.Items
            if not gmcpData or not gmcpData.List or gmcpData.List.location ~= location then
                ProcessNextContainer()
                return
            end

            for _, item in ipairs(gmcpData.List.items) do
                item.name = InventoryDA.RemoveColourCodes(item.name)

                -- Add item directly to the database
                InventoryDA.AddItem(char_name, {
                    id = item.id,
                    name = item.name,
                    type = item.type,
                    state = item.state,
                    container = containerName
                })

                if item.type == "container" and item.state == "open" and not processedContainers[item.id] then
                    table.insert(containerQueue, { location = item.id, containerName = item.name })
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

-- **Clear Inventory for a Character**
function InventoryDA.ClearInventory(character_name)
    return db:delete(VoidWalkerDB.inventory, db:eq(VoidWalkerDB.inventory.character_name, character_name))
end

-- **Helper to Remove Colour Codes from Item Names**
function InventoryDA.RemoveColourCodes(name)
    name = string.gsub(name, "\27%[%d+;%d+m", "")
    name = string.gsub(name, "\27", "")
    name = string.gsub(name, "|%w+|", "")
    return name
end

AshraelPackage.VoidWalker.DataAccessors.InventoryDA = InventoryDA
return InventoryDA
