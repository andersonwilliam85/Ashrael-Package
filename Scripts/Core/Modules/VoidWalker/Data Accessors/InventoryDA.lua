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

-- **Update Inventory for a Character**
function InventoryDA.UpdateInventory(character_name, inventory)
    -- Clear existing inventory for this character
    InventoryDA.ClearInventory(character_name)

    -- Add updated inventory items
    for _, item in ipairs(inventory) do
        InventoryDA.AddItem(character_name, item)
    end
end

-- **Clear Inventory for a Character**
function InventoryDA.ClearInventory(character_name)
    return db:delete(VoidWalkerDB.inventory, db:eq(VoidWalkerDB.inventory.character_name, character_name))
end

AshraelPackage.VoidWalker.DataAccessors.InventoryDA = InventoryDA
return InventoryDA
