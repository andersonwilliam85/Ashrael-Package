AshraelPackage = AshraelPackage or {}
AshraelPackage.PackageManager = AshraelPackage.PackageManager or {}

-- Define constants and paths
AshraelPackage.PersistentDownloadPath = getMudletHomeDir() .. "/ashrael-package-data/"
AshraelPackage.OnlineVersionFile = "https://raw.githubusercontent.com/andersonwilliam85/Ashrael-Package/main/versions.lua"
AshraelPackage.OnlinePackageFile = "https://github.com/andersonwilliam85/Ashrael-Package/releases/download/"
AshraelPackage.MinimumSupportedVersion = "v1.1.2-beta"
AshraelPackage.DefaultVersion = "v1.1.2-beta"
AshraelPackage.Version = AshraelPackage.DefaultVersion  -- Initialize with default

local packageName = "Ashrael-Package"

-- Initialize current version from Mudlet package metadata or default
function AshraelPackage.PackageManager.InitializeVersion()
    cecho("<cyan>[DEBUG] Initializing current version...\n")

    local packageVersion = getPackageInfo(packageName).version
    if packageVersion then
        AshraelPackage.Version = packageVersion
        cecho("<cyan>[DEBUG] Loaded current version from Mudlet package metadata: " .. packageVersion .. "\n")
    else
        AshraelPackage.Version = AshraelPackage.DefaultVersion
        cecho("<yellow>[WARNING] Could not retrieve version from package metadata. Initializing with default version.\n")
    end
end

-- Download and list available versions
function AshraelPackage.PackageManager.DownloadAndListVersions()
    cecho("<cyan>[DEBUG] Fetching the latest version information...\n")
    downloadFile(AshraelPackage.PersistentDownloadPath .. "versions.lua", AshraelPackage.OnlineVersionFile)
end

-- Automatically update to the latest version if newer
function AshraelPackage.PackageManager.CheckAndUpdateToLatestVersion()
    local path = AshraelPackage.PersistentDownloadPath .. "versions.lua"
    local availableVersions
    local status, err = pcall(function() availableVersions = dofile(path) end)

    if not status then
        cecho("<red>[ERROR] Failed to load versions from versions.lua: " .. tostring(err) .. "\n")
        return
    end

    local latestVersion = availableVersions[#availableVersions]
    if latestVersion ~= AshraelPackage.Version then
        cecho("<yellow>New version available: " .. latestVersion .. " (current: " .. AshraelPackage.Version .. "). Updating...\n")
        AshraelPackage.PackageManager.UpdateToVersion(latestVersion)
    else
        cecho("<green>You are already on the latest version.\n")
    end
end

-- Switch to a specific version
function AshraelPackage.PackageManager.SwitchToVersion(version)
    cecho("<cyan>[DEBUG] Attempting to switch to version: " .. version .. "\n")
    local path = AshraelPackage.PersistentDownloadPath .. "versions.lua"
    local availableVersions
    local status, err = pcall(function() availableVersions = dofile(path) end)

    if not status then
        cecho("<red>[ERROR] Failed to load versions from versions.lua: " .. tostring(err) .. "\n")
        return
    end

    if version < AshraelPackage.MinimumSupportedVersion then
        cecho("<red>Version " .. version .. " is not supported. Please choose a version >= " .. AshraelPackage.MinimumSupportedVersion .. ".\n")
        return
    end

    if not table.contains(availableVersions, version) then
        cecho("<yellow>Version " .. version .. " is not available.\n")
        return
    end

    AshraelPackage.PackageManager.UpdateToVersion(version)
end

-- Update to a specified version
function AshraelPackage.PackageManager.UpdateToVersion(version)
    local packageURL = AshraelPackage.OnlinePackageFile .. version .. "/Ashrael-Package.mpackage"
    cecho("<cyan>[DEBUG] Downloading package from " .. packageURL .. "\n")
    downloadFile(AshraelPackage.PersistentDownloadPath .. "Ashrael-Package.mpackage", packageURL)
end

-- Handle file download completion event
function AshraelPackage.PackageManager.OnFileDownloaded(event, filename)
    if filename == AshraelPackage.PersistentDownloadPath .. "versions.lua" then
        cecho("<green>[DEBUG] Version information file downloaded successfully.\n")
        AshraelPackage.PackageManager.DisplayDownloadedVersions()
    elseif filename == AshraelPackage.PersistentDownloadPath .. "Ashrael-Package.mpackage" then
        cecho("<green>[DEBUG] Package downloaded. Preparing for installation...\n")

        if io.exists(filename) then
            cecho("<cyan>[DEBUG] Confirmed package file at: " .. filename .. "\n")
            if table.contains(getPackages(), "Ashrael-Package") then
                cecho("<cyan>[DEBUG] Uninstalling existing Ashrael-Package before update...\n")
                uninstallPackage("Ashrael-Package")
            end
            local success, err = pcall(function() installPackage(filename) end)
            if success then
                AshraelPackage.Version = getPackageInfo(packageName).version or AshraelPackage.DefaultVersion
                cecho("<green>Package installed successfully with version: " .. AshraelPackage.Version .. "\n")
            else
                cecho("<red>[ERROR] Failed to install package: " .. tostring(err) .. "\n")
            end
        else
            cecho("<red>[ERROR] Package file not found at: " .. filename .. "\n")
        end
    end
end

-- Display the versions after they are downloaded, with current version indicator
function AshraelPackage.PackageManager.DisplayDownloadedVersions()
    local path = AshraelPackage.PersistentDownloadPath .. "versions.lua"
    local availableVersions
    local status, err = pcall(function() availableVersions = dofile(path) end)

    if not status then
        cecho("<red>[ERROR] Failed to load versions from versions.lua: " .. tostring(err) .. "\n")
        return
    end

    cecho("<green>Available versions:\n")
    for _, version in ipairs(availableVersions) do
        if version < AshraelPackage.MinimumSupportedVersion then
            cecho(string.format(" - <red>%s (unsupported)<reset>\n", version))
        elseif version == AshraelPackage.Version then
            cecho(string.format(" - <green>%s (current version)<reset>\n", version))
        else
            cecho(string.format(" - %s\n", version))
        end
    end
end

-- Register download completion event handler
if AshraelPackage.PackageManager.DownloadHandler then
    killAnonymousEventHandler(AshraelPackage.PackageManager.DownloadHandler)
end
AshraelPackage.PackageManager.DownloadHandler = registerAnonymousEventHandler("sysDownloadDone", "AshraelPackage.PackageManager.OnFileDownloaded")

-- Initialize the current version from package metadata or default
AshraelPackage.PackageManager.InitializeVersion()