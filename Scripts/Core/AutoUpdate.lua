AshraelPackage = AshraelPackage or {}
AshraelPackage.Utils = AshraelPackage.Utils or {}
AshraelPackage.Utils.AutoUpdate = AshraelPackage.Utils.AutoUpdate or {}

-- Define constants and paths
AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath = getMudletHomeDir() .. "/ashrael-package-data/"
AshraelPackage.Utils.AutoUpdate.OnlineVersionFile = "https://raw.githubusercontent.com/andersonwilliam85/Ashrael-Package/main/versions.lua"
AshraelPackage.Utils.AutoUpdate.OnlinePackageFile = "https://github.com/andersonwilliam85/Ashrael-Package/releases/download/"
AshraelPackage.Utils.AutoUpdate.DownloadHandler = nil
AshraelPackage.Utils.AutoUpdate.CurrentVersionFile = AshraelPackage.Utils.AutoUpdate.PersistentDownloadPath .. "current_version.lua"
AshraelPackage.Utils.AutoUpdate.MinimumSupportedVersion = "v1.1.2-beta"
AshraelPackage.Utils.AutoUpdate.DefaultVersion = "v1.1.2-beta"
local packageName = "Ashrael-Package"

-- Load current version from file, Mudlet package metadata, or initialize with default
function AshraelPackage.Utils.AutoUpdate.LoadCurrentVersion()
    cecho("<cyan>[DEBUG] Attempting to load current version...\n")

    -- Attempt to read the version from the current_version.lua file
    if io.exists(AshraelPackage.Utils.AutoUpdate.CurrentVersionFile) then
        local status, version = pcall(function() return dofile(AshraelPackage.Utils.AutoUpdate.CurrentVersionFile) end)
        if status and version then
            AshraelPackage.Utils.AutoUpdate.Version = version
            cecho("<cyan>[DEBUG] Loaded current version from file: " .. version .. "\n")
            return
        else
            cecho("<yellow>[WARNING] Could not load current version from file. Attempting to use package metadata.\n")
        end
    end

    -- If file read failed, try to retrieve version from Mudlet package metadata
    local packageVersion = getPackageInfo(packageName).version
    if packageVersion then
        AshraelPackage.Utils.AutoUpdate.Version = packageVersion
        cecho("<cyan>[DEBUG] Loaded current version from Mudlet package metadata: " .. packageVersion .. "\n")
        AshraelPackage.Utils.AutoUpdate.SaveCurrentVersion(packageVersion)
    else
        -- If both file and metadata retrieval fail, initialize with the default version
        cecho("<yellow>[WARNING] Could not retrieve version from package metadata. Initializing with default version.\n")
        AshraelPackage.Utils.AutoUpdate.Version = AshraelPackage.Utils.AutoUpdate.DefaultVersion
        AshraelPackage.Utils.AutoUpdate.SaveCurrentVersion(AshraelPackage.Utils.AutoUpdate.Version)
    end
end

-- Save the current version to file
function AshraelPackage.Utils.AutoUpdate.SaveCurrentVersion(version)
    cecho("<cyan>[DEBUG] Saving current version to file at: " .. AshraelPackage.Utils.AutoUpdate.CurrentVersionFile .. "\n")
    local file = io.open(AshraelPackage.Utils.AutoUpdate.CurrentVersionFile, "w")
    if file then
        file:write('return "' .. version .. '"')
        file:close()
        AshraelPackage.Utils.AutoUpdate.Version = version
        cecho("<cyan>Current version updated to: " .. version .. "\n")
    else
        cecho("<red>[ERROR] Failed to save current version to file.\n")
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
                AshraelPackage.Utils.AutoUpdate.SaveCurrentVersion(version)
                cecho("<green>Package installed successfully!\n")
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

-- Load current version from file, package metadata, or initialize with default
AshraelPackage.Utils.AutoUpdate.LoadCurrentVersion()
