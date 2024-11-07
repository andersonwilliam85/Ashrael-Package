--Register all relevant namespaces
AshraelPackage = AshraelPackage or {}
AshraelPackage.VoidWalker = AshraelPackage.VoidWalker or {}

AshraelPackage.VoidWalker.DataAccessors = AshraelPackage.VoidWalker.DataAccessors or {}

AshraelPackage.VoidWalker.DataAccessors.CharactersDA = AshraelPackage.VoidWalker.DataAccessors.CharactersDA or {}
AshraelPackage.VoidWalker.DataAccessors.InventoryDA = AshraelPackage.VoidWalker.DataAccessors.InventoryDA or {}

AshraelPackage.VoidWalker.Managers = AshraelPackage.VoidWalker.Managers or {}
AshraelPackage.VoidWalker.Managers.InventoryManager = AshraelPackage.VoidWalker.Managers.InventoryManager or {}
AshraelPackage.VoidWalker.Managers.CharactersManager = AshraelPackage.VoidWalker.Managers.CharactersManager or {}
AshraelPackage.VoidWalker.Managers.ConfigManager = AshraelPackage.VoidWalker.Managers.ConfigManager or {}
AshraelPackage.VoidWalker.Managers.EventManager = AshraelPackage.VoidWalker.Managers.EventManager or {}

AshraelPackage.VoidWalker.Databases = AshraelPackage.VoidWalker.Databases or {}

-- Create the VoidWalkerDB with characters and inventory tables
AshraelPackage.VoidWalker.Databases.VoidWalkerDB = db:create("voidwalker", {
    characters = {
        name = "",  -- Unique identifier for each character
        health = 0,
        mana = 0,
        movement = 0,
        tnl = 0,
        last_location = "",
        is_registered = 0,  -- 1 for true, 0 for false
        is_active = 0,      -- 1 for active, 0 for inactive
        password = "",
        _unique = { "name" }
    },
    inventory = {
        character_name = "",  -- Foreign key linking item to character
        item_id = 0,          -- Unique identifier for each item
        name = "",            -- Item name
        type = "",            -- Item type (e.g., weapon, container)
        state = "",           -- Item state (e.g., open, closed)
        container = "",       -- Container name if inside another item
        _index = { "character_name", "item_id" }  -- Index for efficient lookups
    }
})

-- Confirmation message for successful initialization
if AshraelPackage.VoidWalker.Databases.VoidWalkerDB then
    cecho("<green>VoidWalkerDB initialized successfully with characters and inventory tables.\n")
else
    cecho("<red>Error initializing VoidWalkerDB. Please check configuration.\n")
end


-- Display help for the voidwalk and voidgaze commands
function AshraelPackage.VoidWalker.DisplayHelp()
    cecho("<cyan>VoidWalker Module Commands:\n")
    
    cecho("<green>voidwalk<reset>: Manage and switch between registered characters.\n")
    cecho(" - <green>voidwalk <character><reset>: Switch to a specified character.\n")
    cecho(" - <green>voidwalk register <password><reset>: Register the current character with a password to enable VoidWalker features.\n")
    cecho(" - <green>voidwalk add <character> <password><reset>: Add a new character to VoidWalker with a specified password.\n")
    cecho(" - <green>voidwalk remove <character><reset>: Remove a character from VoidWalker.\n\n")

    cecho("<green>voidgaze<reset>: View details and inventory for all registered characters.\n")
    cecho(" - <green>voidgaze<reset> or <green>voidgaze list<reset>: List all registered characters and their statuses.\n")
    cecho(" - <green>voidgaze <character><reset>: Display detailed information for a specific character.\n")
    cecho(" - <green>voidgaze inventory<reset> or <green>voidgaze inv<reset>: Show a consolidated inventory across all characters.\n")
    cecho(" - <green>voidgaze search <item><reset>: Search for a specific item in all characters' inventories.\n\n")
end