AshraelPackage = AshraelPackage or {}

-- Main help display function for the Ashrael-Package
function AshraelPackage.DisplayHelp()
    cecho("<cyan>Welcome to Ashrael-Package!\n")
    cecho("This package provides tools and enhancements to streamline your experience.\n\n")

    -- PackageManager section
    cecho("<cyan>PackageManager Module:\n")
    cecho(" - <green>ashpkg update<reset>: Check for and install updates.\n")
    cecho(" - <green>ashpkg versions<reset>: List available versions.\n")
    cecho(" - <green>ashpkg switch <version><reset>: Switch to a specific version.\n\n")
    
    -- VoidWalker module description and help
    cecho("<cyan>VoidWalker Module:\n")
    cecho("The VoidWalker module allows for fast-switching between characters, tracking inventory, "
          .. "and viewing character status across alts. Use VoidWalker to efficiently manage multiple characters.\n")
    cecho(" - <green>voidwalk<reset>: Access VoidWalker commands for managing characters.\n")
    cecho(" - <green>voidgaze<reset>: View consolidated character inventory and search across items.\n")
    cecho("   Type <green>voidgaze help<reset> for a list of specific voidgaze commands.\n\n")

    -- Adventure Mode module description and help
    cecho("<cyan>Adventure Mode Module:\n")
    cecho("The Adventure Mode module streamlines exploration and combat with toggles for solo, group, and recovery modes.\n")
    cecho(" - <green>adv help<reset>: Access detailed commands for Adventure Mode, including solo/group mode toggling, "
          .. "recovery, and more.\n\n")

    -- Usage examples
    cecho("<cyan>Example Commands:\n")
    cecho(" - <green>ashpkg update<reset>: Update the package to the latest version.\n")
    cecho(" - <green>voidwalk add Warrior hunter123<reset>: Add the 'Warrior' character to VoidWalker.\n")
    cecho(" - <green>adv solo<reset>: Toggle Adventure mode to Solo.\n")
end

-- Set up a root alias to display help and other commands
if not AshraelPackage.AliasCreated then
    tempAlias("^ashpkg$", [[AshraelPackage.DisplayHelp()]])
    tempAlias("^ashpkg update$", [[AshraelPackage.PackageManager.CheckAndUpdateToLatestVersion()]])
    tempAlias("^ashpkg versions$", [[AshraelPackage.PackageManager.DownloadAndListVersions()]])
    tempAlias("^ashpkg switch (.+)$", [[AshraelPackage.PackageManager.SwitchToVersion(matches[2])]])
    AshraelPackage.AliasCreated = true
end
