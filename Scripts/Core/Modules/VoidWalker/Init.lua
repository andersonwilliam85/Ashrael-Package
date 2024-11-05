AshraelPackage.VoidWalker = AshraelPackage.VoidWalker or {}
AshraelPackage.VoidWalker.Inventory = AshraelPackage.VoidWalker.Inventory or {}
AshraelPackage.VoidWalker.Characters = AshraelPackage.VoidWalker.Characters or {}
AshraelPackage.VoidWalker.Config = AshraelPackage.VoidWalker.Config or {}
AshraelPackage.VoidWalker.Event = AshraelPackage.VoidWalker.Event or {}


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