AshraelPackage = AshraelPackage or {}
AshraelPackage.Utils = AshraelPackage.Utils or {}
AshraelPackage.Utils.AutoUpdate = AshraelPackage.Utils.AutoUpdate or {}

-- Define constants and paths
AshraelPackage.Utils.AutoUpdate.Version = "v1.0"  -- Current version
AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath = getMudletHomeDir() .. "/ashrael-package-data/"  -- Persisted folder for updates
AshraelPackage.Utils.AutoUpdate.OnlineVersionFile = "https://raw.githubusercontent.com/andersonwilliam85/Ashrael-Package/main/versions.lua"
AshraelPackage.Utils.AutoUpdate.OnlinePackageFile = "https://github.com/andersonwilliam85/Ashrael-Package/releases/download/"
AshraelPackage.Utils.AutoUpdate.DownloadHandler = nil

-- Ensure the aliases only get created once
if not AshraelPackage.Utils.AutoUpdate.AliasCreated then
    -- Main alias for displaying help
    tempAlias("^ashrael-pkg$", [[AshraelPackage.Utils.AutoUpdate.DisplayHelp()]])

    -- Alias for checking updates
    tempAlias("^ashrael-pkg update$", [[AshraelPackage.Utils.AutoUpdate.CheckForUpdates()]])

    -- Alias for listing available versions
    tempAlias("^ashrael-pkg versions$", [[AshraelPackage.Utils.AutoUpdate.ListAvailableVersions()]])

    -- Alias for switching to a specific version
    tempAlias("^ashrael-pkg switch (.+)$", [[AshraelPackage.Utils.AutoUpdate.SwitchToVersion(matches[2])]])

    -- Flag to prevent recreating aliases
    AshraelPackage.Utils.AutoUpdate.AliasCreated = true
end

-- Display help information
function AshraelPackage.Utils.AutoUpdate.DisplayHelp()
    cecho("<cyan>Available commands for Ashrael-Package:\n")
    cecho(" - <green>ashrael-pkg update<reset>: Check for and install updates.\n")
    cecho(" - <green>ashrael-pkg versions<reset>: List available versions.\n")
    cecho(" - <green>ashrael-pkg switch <version><reset>: Switch to a specific version.\n")
end

-- Check for updates
function AshraelPackage.Utils.AutoUpdate.CheckForUpdates()
    cecho("<green>Initiating Ashrael-Package update check...\n")

    -- Ensure persistent download directory exists
    if not io.exists(AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath) then
        lfs.mkdir(AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath)
        cecho(string.format("<cyan>[DEBUG] Created download directory at %s\n", AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath))
    end

    -- Download version information file
    downloadFile(AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath .. "versions.lua", AshraelPackage.Utils.AutoUpdate.OnlineVersionFile)
    cecho("<cyan>[DEBUG] Downloading version information from " .. AshraelPackage.Utils.AutoUpdate.OnlineVersionFile .. "\n")
end

-- List available versions
function AshraelPackage.Utils.AutoUpdate.ListAvailableVersions()
    local path = AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath .. "versions.lua"
    local availableVersions
    local status, err = pcall(function() availableVersions = dofile(path) end)

    if not status then
        cecho("<red>[ERROR] Failed to load versions from versions.lua: " .. tostring(err) .. "\n")
        return
    end

    cecho("<green>Available versions:\n")
    for _, version in ipairs(availableVersions) do
        cecho(string.format(" - %s\n", version))
    end
end

-- Switch to a specific version
function AshraelPackage.Utils.AutoUpdate.SwitchToVersion(version)
    local path = AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath .. "versions.lua"
    local availableVersions
    local status, err = pcall(function() availableVersions = dofile(path) end)

    if not status then
        cecho("<red>[ERROR] Failed to load versions from versions.lua: " .. tostring(err) .. "\n")
        return
    end

    -- Check if the requested version exists
    if not table.contains(availableVersions, version) then
        cecho(string.format("<yellow>Version %s is not available.\n", version))
        return
    end

    -- Start the update process
    AshraelPackage.Utils.AutoUpdate.UpdateToVersion(version)
end

-- Update to a specified version
function AshraelPackage.Utils.AutoUpdate.UpdateToVersion(version)
    local packageURL = AshraelPackage.Utils.AutoUpdate.OnlinePackageFile .. version .. "/Ashrael-Package.mpackage"
    cecho(string.format("<cyan>[DEBUG] Downloading package from %s\n", packageURL))
    downloadFile(AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath .. "Ashrael-Package.mpackage", packageURL)
end

-- Handle file download completion event
function AshraelPackage.Utils.AutoUpdate.OnFileDownloaded(event, filename)
    if filename == AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath .. "versions.lua" then
        cecho("<green>[DEBUG] Version information file downloaded successfully.\n")
        AshraelPackage.Utils.AutoUpdate.ListAvailableVersions()
    elseif filename == AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath .. "Ashrael-Package.mpackage" then
        cecho("<green>[DEBUG] Package downloaded. Preparing for installation...\n")

        -- Verify the package file exists before attempting to install
        if io.exists(filename) then
            cecho("<cyan>[DEBUG] Confirmed package file at: " .. filename .. "\n")

            -- Uninstall existing package if it’s installed
            if table.contains(getPackages(), "Ashrael-Package") then
                cecho("<cyan>[DEBUG] Uninstalling existing Ashrael-Package before update...\n")
                uninstallPackage("Ashrael-Package")
            end

            -- Try installing the package
            local success, err = pcall(function() installPackage(filename) end)
            if success then
                cecho("<green>Package installed successfully!\n")
            else
                cecho("<red>[ERROR] Failed to install package: " .. tostring(err) .. "\n")
            end
        else
            cecho("<red>[ERROR] Package file not found at: " .. filename .. "\n")
        end
    end
end

-- Register download completion event handler
if AshraelPackage.Utils.AutoUpdate.DownloadHandler then
    killAnonymousEventHandler(AshraelPackage.Utils.AutoUpdate.DownloadHandler)
end

AshraelPackage.Utils.AutoUpdate.DownloadHandler = registerAnonymousEventHandler("sysDownloadDone", "AshraelPackage.Utils.AutoUpdate.OnFileDownloaded")
