AshraelPackage = AshraelPackage or {}
AshraelPackage.Utils = AshraelPackage.Utils or {}
AshraelPackage.Utils.AutoUpdate = AshraelPackage.Utils.AutoUpdate or {}

-- Define constants and paths
AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath = getMudletHomeDir() .. "/ashrael-package-data/"
AshraelPackage.Utils.AutoUpdate.OnlineVersionFile = "https://raw.githubusercontent.com/andersonwilliam85/Ashrael-Package/main/versions.lua"
AshraelPackage.Utils.AutoUpdate.OnlinePackageFile = "https://github.com/andersonwilliam85/Ashrael-Package/releases/download/"
AshraelPackage.Utils.AutoUpdate.DownloadHandler = nil
AshraelPackage.Utils.AutoUpdate.MinimumSupportedVersion = "v1.1.2-beta"
AshraelPackage.Utils.AutoUpdate.DefaultVersion = "v1.1.2-beta"
local packageName = "Ashrael-Package"

-- Initialize current version from Mudlet package metadata or default
function AshraelPackage.Utils.AutoUpdate.InitializeVersion()
    cecho("<cyan>[DEBUG] Initializing current version...\n")

    -- Attempt to retrieve version from Mudlet package metadata
    local packageVersion = getPackageInfo(packageName).version
    if packageVersion then
        AshraelPackage.Utils.AutoUpdate.Version = packageVersion
        cecho("<cyan>[DEBUG] Loaded current version from Mudlet package metadata: " .. packageVersion .. "\n")
    else
        -- If metadata retrieval fails, initialize with the default version
        AshraelPackage.Utils.AutoUpdate.Version = AshraelPackage.Utils.AutoUpdate.DefaultVersion
        cecho("<yellow>[WARNING] Could not retrieve version from package metadata. Initializing with default version.\n")
    end
end

-- Ensure the aliases only get created once
if not AshraelPackage.Utils.AutoUpdate.AliasCreated then
    tempAlias("^ashrael-pkg$", [[AshraelPackage.Utils.AutoUpdate.DisplayHelp()]])
    tempAlias("^ashrael-pkg update$", [[AshraelPackage.Utils.AutoUpdate.CheckAndUpdateToLatestVersion()]])
    tempAlias("^ashrael-pkg versions$", [[AshraelPackage.Utils.AutoUpdate.DownloadAndListVersions()]])
    tempAlias("^ashrael-pkg switch (.+)$", [[AshraelPackage.Utils.AutoUpdate.SwitchToVersion(matches[2])]])
    AshraelPackage.Utils.AutoUpdate.AliasCreated = true
end

-- Display help information
function AshraelPackage.Utils.AutoUpdate.DisplayHelp()
    cecho("<cyan>Available commands for Ashrael-Package:\n")
    cecho(" - <green>ashrael-pkg update<reset>: Check for and install updates.\n")
    cecho(" - <green>ashrael-pkg versions<reset>: List available versions.\n")
    cecho(" - <green>ashrael-pkg switch <version><reset>: Switch to a specific version.\n")
end

-- Download and list available versions
function AshraelPackage.Utils.AutoUpdate.DownloadAndListVersions()
    cecho("<cyan>[DEBUG] Fetching the latest version information...\n")
    downloadFile(AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath .. "versions.lua", AshraelPackage.Utils.AutoUpdate.OnlineVersionFile)
end

-- Automatically update to the latest version if newer
function AshraelPackage.Utils.AutoUpdate.CheckAndUpdateToLatestVersion()
    local path = AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath .. "versions.lua"
    local availableVersions
    local status, err = pcall(function() availableVersions = dofile(path) end)

    if not status then
        cecho("<red>[ERROR] Failed to load versions from versions.lua: " .. tostring(err) .. "\n")
        return
    end

    local latestVersion = availableVersions[#availableVersions]
    if latestVersion ~= AshraelPackage.Utils.AutoUpdate.Version then
        cecho("<yellow>New version available: " .. latestVersion .. " (current: " .. AshraelPackage.Utils.AutoUpdate.Version .. "). Updating...\n")
        AshraelPackage.Utils.AutoUpdate.UpdateToVersion(latestVersion)
    else
        cecho("<green>You are already on the latest version.\n")
    end
end

-- Switch to a specific version
function AshraelPackage.Utils.AutoUpdate.SwitchToVersion(version)
    cecho("<cyan>[DEBUG] Attempting to switch to version: " .. version .. "\n")
    local path = AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath .. "versions.lua"
    local availableVersions
    local status, err = pcall(function() availableVersions = dofile(path) end)

    if not status then
        cecho("<red>[ERROR] Failed to load versions from versions.lua: " .. tostring(err) .. "\n")
        return
    end

    -- Check if version is supported
    if version < AshraelPackage.Utils.AutoUpdate.MinimumSupportedVersion then
        cecho("<red>Version " .. version .. " is not supported. Please choose a version >= " .. AshraelPackage.Utils.AutoUpdate.MinimumSupportedVersion .. ".\n")
        return
    end

    if not table.contains(availableVersions, version) then
        cecho("<yellow>Version " .. version .. " is not available.\n")
        return
    end

    AshraelPackage.Utils.AutoUpdate.UpdateToVersion(version)
end

-- Update to a specified version
function AshraelPackage.Utils.AutoUpdate.UpdateToVersion(version)
    local packageURL = AshraelPackage.Utils.AutoUpdate.OnlinePackageFile .. version .. "/Ashrael-Package.mpackage"
    cecho("<cyan>[DEBUG] Downloading package from " .. packageURL .. "\n")
    downloadFile(AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath .. "Ashrael-Package.mpackage", packageURL)
end

-- Handle file download completion event
function AshraelPackage.Utils.AutoUpdate.OnFileDownloaded(event, filename)
    if filename == AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath .. "versions.lua" then
        cecho("<green>[DEBUG] Version information file downloaded successfully.\n")
        AshraelPackage.Utils.AutoUpdate.DisplayDownloadedVersions()
    elseif filename == AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath .. "Ashrael-Package.mpackage" then
        cecho("<green>[DEBUG] Package downloaded. Preparing for installation...\n")

        if io.exists(filename) then
            cecho("<cyan>[DEBUG] Confirmed package file at: " .. filename .. "\n")
            if table.contains(getPackages(), "Ashrael-Package") then
                cecho("<cyan>[DEBUG] Uninstalling existing Ashrael-Package before update...\n")
                uninstallPackage("Ashrael-Package")
            end
            local success, err = pcall(function() installPackage(filename) end)
            if success then
                -- Retrieve and display the new package version after installation
                AshraelPackage.Utils.AutoUpdate.Version = getPackageInfo(packageName).version or AshraelPackage.Utils.AutoUpdate.DefaultVersion
                cecho("<green>Package installed successfully with version: " .. AshraelPackage.Utils.AutoUpdate.Version .. "\n")
            else
                cecho("<red>[ERROR] Failed to install package: " .. tostring(err) .. "\n")
            end
        else
            cecho("<red>[ERROR] Package file not found at: " .. filename .. "\n")
        end
    end
end

-- Display the versions after they are downloaded, with current version indicator
function AshraelPackage.Utils.AutoUpdate.DisplayDownloadedVersions()
    local path = AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath .. "versions.lua"
    local availableVersions
    local status, err = pcall(function() availableVersions = dofile(path) end)

    if not status then
        cecho("<red>[ERROR] Failed to load versions from versions.lua: " .. tostring(err) .. "\n")
        return
    end

    cecho("<green>Available versions:\n")
    for _, version in ipairs(availableVersions) do
        if version < AshraelPackage.Utils.AutoUpdate.MinimumSupportedVersion then
            cecho(string.format(" - <red>%s (unsupported)<reset>\n", version))
        elseif version == AshraelPackage.Utils.AutoUpdate.Version then
            cecho(string.format(" - <green>%s (current version)<reset>\n", version))
        else
            cecho(string.format(" - %s\n", version))
        end
    end
end

-- Register download completion event handler
if AshraelPackage.Utils.AutoUpdate.DownloadHandler then
    killAnonymousEventHandler(AshraelPackage.Utils.AutoUpdate.DownloadHandler)
end
AshraelPackage.Utils.AutoUpdate.DownloadHandler = registerAnonymousEventHandler("sysDownloadDone", "AshraelPackage.Utils.AutoUpdate.OnFileDownloaded")

-- Initialize the current version from package metadata or default
AshraelPackage.Utils.AutoUpdate.InitializeVersion()
