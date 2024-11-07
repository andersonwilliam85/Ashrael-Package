-- Define the Package
AshraelPackage = AshraelPackage or {}

local packageName = "Ashrael-Package"

-- Variable for the database name
local databaseName = "ashraeldb"

AshraelPackage.Database = {}

-- Module-level variable to track the intended action after download
AshraelPackage.DownloadAction = nil

-- Function to create and initialize the database
function AshraelPackage.InitializeDatabase()
    -- Create the database
    AshraelPackage.Database = db:create(databaseName, {
        character_settings = {
            module = "",
            setting_name = "",
            value = "",
            character_name = "",
        },
        global_settings = {
            module = "",
            setting_name = "",
            value = "",
        },
        setting_definitions = {
            setting_name = "",
            default_value = "",
            scope = "package",
            description = "",
            module_name = packageName,
        }
    })

    if not AshraelPackage.Database then
        return
    end

    -- Initialize default values for setting definitions
    local defaultSettings = {
        {setting_name = "persistent_download_path", default_value = getMudletHomeDir() .. "/ashrael-package-data/", scope = "package", description = "Path for persistent downloads.", module = packageName},
        {setting_name = "online_version_file", default_value = "https://raw.githubusercontent.com/andersonwilliam85/Ashrael-Package/main/versions.lua", scope = "package", description = "URL for online version file.", module = packageName},
        {setting_name = "online_package_file", default_value = "https://github.com/andersonwilliam85/Ashrael-Package/releases/download/", scope = "package", description = "URL for online package file.", module = packageName},
        {setting_name = "minimum_supported_version", default_value = "v1.4.3", scope = "package", description = "Minimum supported version.", module = packageName},
        {setting_name = "current_version", default_value = getPackageInfo(packageName).version, scope = "package", description = "Current version of the AshraelPackage.", module = packageName},
        {setting_name = "auto_update", default_value = true, scope = "package", description = "Determines if the package auto updates on startup.", module = packageName}
    }

    for _, setting in ipairs(defaultSettings) do
        AshraelPackage.AddSettingDefinition(setting.setting_name, setting.default_value, setting.scope, setting.description, setting.module)
    end
    
    -- Initialize all global settings
    AshraelPackage.InitializeGlobalSettings(defaultSettings)
end

function AshraelPackage.InitializeGlobalSettings(defaultSettings)
    for _, setting in ipairs(defaultSettings) do
        -- Always update the setting to the default value from the package
        AshraelPackage.SetGlobalSetting(setting.module, setting.setting_name, setting.default_value)
    end

    -- Additionally, ensure the current version is always updated
    local currentVersion = getPackageInfo(packageName).version
    AshraelPackage.SetGlobalSetting(packageName, "current_version", currentVersion)
end

-- Function to add a setting definition
function AshraelPackage.AddSettingDefinition(settingName, defaultValue, scope, description, moduleName)
    -- Check for existing definition
    local existingDefinition = AshraelPackage.GetSettingDefinition(settingName)
    if existingDefinition then
        AshraelPackage.UpdateSettingDefinition(settingName, defaultValue, scope, description, moduleName)
        return
    end

    local result, err = db:add(AshraelPackage.Database.setting_definitions, {
        setting_name = settingName,
        default_value = defaultValue,
        scope = scope or 'package',
        description = description,
        module_name = moduleName or packageName
    })
    
    if not result then
        -- Error handling
    end
end

-- Function to get all setting definitions with descriptions
function AshraelPackage.GetAllSettingDefinitions()
    local results = db:fetch(AshraelPackage.Database.setting_definitions)
    local settings = {}
    for _, entry in ipairs(results) do
        table.insert(settings, {
            setting_name = entry.setting_name,
            default_value = entry.default_value,
            scope = entry.scope,
            description = entry.description,
            module_name = entry.module_name
        })
    end
    return settings
end

-- Function to retrieve a setting definition
function AshraelPackage.GetSettingDefinition(settingName)
    local result = db:fetch(AshraelPackage.Database.setting_definitions, db:eq(AshraelPackage.Database.setting_definitions.setting_name, settingName))
    if result and #result > 0 then
        return result[1]  -- Return the first matching record
    else
        return nil
    end
end

-- Function to update a setting definition
function AshraelPackage.UpdateSettingDefinition(settingName, defaultValue, scope, description, moduleName)
    local result = AshraelPackage.GetSettingDefinition(settingName)
    if result and result._row_id then
        local updateResult, updateErr = db:update(AshraelPackage.Database.setting_definitions, {
            _row_id = result._row_id,
            setting_name = settingName,
            default_value = defaultValue,
            scope = scope or 'package',
            description = description,
            module_name = moduleName or packageName
        })
        
        if not updateResult then
            -- Error handling
        end
    else
        -- Error handling
    end
end

-- Function to get all character settings for a specific character and module
function AshraelPackage.GetCharacterSettings(characterName, module)
    local results = db:fetch(AshraelPackage.Database.character_settings, 
        db:AND(
            db:eq(AshraelPackage.Database.character_settings.character_name, characterName),
            db:eq(AshraelPackage.Database.character_settings.module, module)
        )
    )
    return results
end

-- Function to set a character setting, ensuring uniqueness
function AshraelPackage.SetCharacterSetting(characterName, module, settingName, value)
    local existing = db:fetch(AshraelPackage.Database.character_settings, 
        db:AND(
            db:eq(AshraelPackage.Database.character_settings.character_name, characterName),
            db:eq(AshraelPackage.Database.character_settings.module, module),
            db:eq(AshraelPackage.Database.character_settings.setting_name, settingName)
        )
    )
    
    if existing and #existing > 0 then
        -- Update existing setting
        local updateResult, updateErr = db:update(AshraelPackage.Database.character_settings, {
            _row_id = existing[1]._row_id,
            value = value
        })
        
        if not updateResult then
            -- Error handling
        end
    else
        -- Insert new setting
        local result, err = db:add(AshraelPackage.Database.character_settings, {
            module = module,
            character_name = characterName,
            setting_name = settingName,
            value = value
        })
        
        if not result then
            -- Error handling
        end
    end
end

-- Function to retrieve a character setting
function AshraelPackage.GetCharacterSetting(characterName, module, settingName)
    local result = db:fetch(AshraelPackage.Database.character_settings, 
        db:AND(
            db:eq(AshraelPackage.Database.character_settings.character_name, characterName),
            db:eq(AshraelPackage.Database.character_settings.module, module),
            db:eq(AshraelPackage.Database.character_settings.setting_name, settingName)
        )
    )

    if result and #result > 0 then
        return result[1].value
    else
        return nil
    end
end

-- Function to remove a character setting
function AshraelPackage.RemoveCharacterSetting(characterName, module, settingName)
    db:delete(AshraelPackage.Database.character_settings, 
        db:AND(
            db:eq(AshraelPackage.Database.character_settings.character_name, characterName),
            db:eq(AshraelPackage.Database.character_settings.module, module),
            db:eq(AshraelPackage.Database.character_settings.setting_name, settingName)
        )
    )
end

-- Function to get all global settings for a specific module
function AshraelPackage.GetGlobalSettings(module)
    local results = db:fetch(AshraelPackage.Database.global_settings, 
        db:eq(AshraelPackage.Database.global_settings.module, module)
    )
    return results
end

-- Function to set a global setting, ensuring uniqueness
function AshraelPackage.SetGlobalSetting(module, settingName, value)
    -- Check if the setting already exists
    local existing = db:fetch(AshraelPackage.Database.global_settings, 
        db:AND(
            db:eq(AshraelPackage.Database.global_settings.module, module),
            db:eq(AshraelPackage.Database.global_settings.setting_name, settingName)
        )
    )
    
    if existing and #existing > 0 then
        -- Update existing setting
        local updateResult, updateErr = db:update(AshraelPackage.Database.global_settings, {
            _row_id = existing[1]._row_id,
            value = value
        })
        
        if not updateResult then
            -- Error handling
        end
    else
        -- Insert new setting
        local result, err = db:add(AshraelPackage.Database.global_settings, {
            module = module,
            setting_name = settingName,
            value = value
        })
        
        if not result then
            -- Error handling
        end
    end
end

-- Function to retrieve a global setting
function AshraelPackage.GetGlobalSetting(module, settingName)
    local result = db:fetch(AshraelPackage.Database.global_settings, 
        db:AND(
            db:eq(AshraelPackage.Database.global_settings.module, module),
            db:eq(AshraelPackage.Database.global_settings.setting_name, settingName)
        )
    )

    if result and #result > 0 then
        return result[1].value
    else
        return nil
    end
end

-- Function to remove a global setting
function AshraelPackage.RemoveGlobalSetting(module, settingName)
    db:delete(AshraelPackage.Database.global_settings, 
        db:AND(
            db:eq(AshraelPackage.Database.global_settings.module, module),
            db:eq(AshraelPackage.Database.global_settings.setting_name, settingName)
        )
    )
end

-- Version Management Functions

-- Initialize current version from Mudlet package metadata or default
function AshraelPackage.InitializeVersion()
    local packageVersion = getPackageInfo(packageName).version
    AshraelPackage.Version = packageVersion
end

-- Function to ensure the persistent download path exists
function AshraelPackage.EnsurePersistentDownloadPathExists()
    local persistentDownloadPath = AshraelPackage.GetGlobalSetting(packageName, "persistent_download_path")
    if not io.exists(persistentDownloadPath) then
        os.execute("mkdir \"" .. persistentDownloadPath .. "\"")  -- Create the directory
    end
end

-- Function to download the versions file
function AshraelPackage.DownloadVersionsFile()
    local onlineVersionFile = AshraelPackage.GetGlobalSetting(packageName, "online_version_file")
    local persistentDownloadPath = AshraelPackage.GetGlobalSetting(packageName, "persistent_download_path")
    local versionsPath = persistentDownloadPath .. "versions.lua"

    cecho("Downloading versions.lua from " .. onlineVersionFile .. "\n")
    
    -- Attempt to download the file
    downloadFile(versionsPath, onlineVersionFile)  -- This starts the download asynchronously
end

-- Function to list available versions
function AshraelPackage.ListAvailableVersions()
    local path = AshraelPackage.GetGlobalSetting(packageName, "persistent_download_path") .. "versions.lua"
    local availableVersions

    -- Attempt to load available versions
    local status, err = pcall(function() 
        availableVersions = dofile(path) 
    end)

    if not status then
        cecho("<red>Error loading versions from " .. path .. ": " .. tostring(err) .. "<reset>\n")
        return
    end

    -- Display available versions
    cecho("Available versions:\n")
    
    -- Track the maximum version for comparison later
    local maxVersion = nil

    for _, version in ipairs(availableVersions) do
        if not maxVersion or version > maxVersion then
            maxVersion = version  -- Update maxVersion if a higher version is found
        end
        
        if version < AshraelPackage.GetGlobalSetting(packageName, "minimum_supported_version") then
            cecho(string.format(" - <red>%s (unsupported)<reset>\n", version))
        elseif version == AshraelPackage.Version then
            cecho(string.format(" - <green>%s (current version)<reset>\n", version))
        else
            cecho(string.format(" - %s\n", version))
        end
    end

    -- If the current version is greater than the highest version in the list, list it as development
    if AshraelPackage.Version > maxVersion then
        cecho(string.format(" - <yellow>%s (development)<reset>\n", AshraelPackage.Version))
    end
end

-- Function to download the versions file and then list the available versions
function AshraelPackage.DownloadAndListVersions()
    AshraelPackage.DownloadAction = "list"  -- Set the action to list
    AshraelPackage.DownloadVersionsFile()  -- Initiate the download
end

-- Function to check for updates and download the latest versions file
function AshraelPackage.CheckForUpdates()
    local onlineVersionFile = AshraelPackage.GetGlobalSetting(packageName, "online_version_file")
    local persistentDownloadPath = AshraelPackage.GetGlobalSetting(packageName, "persistent_download_path")
    local versionsPath = persistentDownloadPath .. "versions.lua"

    -- Set the action to update
    AshraelPackage.DownloadAction = "update"

    -- Always download the latest versions.lua file
    cecho("Downloading versions.lua from " .. onlineVersionFile .. "\n")
    downloadFile(versionsPath, onlineVersionFile)  -- Start the download
end


-- Switch to a specific version
function AshraelPackage.SwitchToVersion(version)
    local path = AshraelPackage.GetGlobalSetting(packageName, "persistent_download_path") .. "versions.lua"

    -- Load available versions
    local availableVersions
    local status, err = pcall(function() 
        availableVersions = dofile(path) 
    end)

    if not status then
        return  -- If there's an error, do not proceed further
    end

    -- Check for minimum supported version
    if version < AshraelPackage.GetGlobalSetting(packageName, "minimum_supported_version") then
        cecho("<red>Error: Version " .. version .. " is below the minimum supported version.<reset>\n")
        return
    end

    -- Check if the version is in the available versions list
    if table.contains(availableVersions, version) then
        cecho("Switching to version " .. version .. "\n")
        AshraelPackage.UpdateToVersion(version)
    else
        cecho("<red>Version " .. version .. " is not available.<reset>\n")
    end
end

-- Update to a specified version
function AshraelPackage.UpdateToVersion(version)
    local packageURL = AshraelPackage.GetGlobalSetting(packageName, "online_package_file") .. version .. "/Ashrael-Package.mpackage"
    downloadFile(AshraelPackage.GetGlobalSetting(packageName, "persistent_download_path") .. "Ashrael-Package.mpackage", packageURL)
end

-- Handle file download completion event
function AshraelPackage.OnFileDownloaded(event, filename)
    if filename == AshraelPackage.GetGlobalSetting(packageName, "persistent_download_path") .. "versions.lua" then
        cecho("<green>Successfully downloaded versions.lua!<reset>\n")
        
        -- Now, depending on the action, either list versions or check for updates
        if AshraelPackage.DownloadAction == "list" then
            AshraelPackage.ListAvailableVersions()  -- Call to list the versions
        elseif AshraelPackage.DownloadAction == "update" then
            -- Proceed to check for updates
            local availableVersions
            local status, err = pcall(function()
                availableVersions = dofile(filename)
            end)

            if not status then
                cecho("<red>Error loading versions from " .. filename .. ": " .. tostring(err) .. "<reset>\n")
                return
            end

            local latestVersion = availableVersions[#availableVersions]
            if latestVersion > AshraelPackage.Version then
                cecho("Updating to version: " .. latestVersion .. "\n")
                AshraelPackage.UpdateToVersion(latestVersion)
            elseif latestVersion == AshraelPackage.Version then
                cecho("<yellow>You are already using: " .. AshraelPackage.Version .. "<reset>\n")
            else
                cecho("<yellow>You appear to be on a development version: " .. AshraelPackage.Version .. 
                      ". Autoupdate has been disabled. Please use the switch command to update.<reset>\n")
            end
        end
        
        -- Reset the action back to nil
        AshraelPackage.DownloadAction = nil
    elseif filename == AshraelPackage.GetGlobalSetting(packageName, "persistent_download_path") .. "Ashrael-Package.mpackage" then
        -- Handle package installation logic
        if io.exists(filename) then
            if table.contains(getPackages(), packageName) then
                uninstallPackage(packageName)
            end
            local success, err = pcall(function() installPackage(filename) end)
            if success then
                AshraelPackage.Version = getPackageInfo(packageName).version or "v1.1.2-beta"
            end
        end
    end
end

-- Function to display help information
function AshraelPackage.DisplayHelp()
    cecho("<cyan>Welcome to Ashrael Package 1.4.2!<reset>\n")
    cecho("<cyan>This package can manage settings efficiently and enhance your gameplay experience.<reset>\n")
    cecho("You can set and retrieve global and character-specific settings using the following functions:<reset>\n\n")

    cecho("<green>Global Settings:<reset>\n")
    cecho(" - Set a global setting: <green>AshraelPackage.SetGlobalSetting(module, settingName, value)<reset>\n")
    cecho(" - Get a global setting: <green>AshraelPackage.GetGlobalSetting(module, settingName)<reset>\n")
    cecho(" - Remove a global setting: <green>AshraelPackage.RemoveGlobalSetting(module, settingName)<reset>\n")
    
    cecho("\n<green>Character Settings:<reset>\n")
    cecho(" - Set a character setting: <green>AshraelPackage.SetCharacterSetting(characterName, module, settingName, value)<reset>\n")
    cecho(" - Get a character setting: <green>AshraelPackage.GetCharacterSetting(characterName, module, settingName)<reset>\n")
    cecho(" - Remove a character setting: <green>AshraelPackage.RemoveCharacterSetting(characterName, module, settingName)<reset>\n")

    cecho("\n<green>Get all settings:<reset>\n")
    cecho(" - Get all global settings for a module: <green>AshraelPackage.GetGlobalSettings(module)<reset>\n")
    cecho(" - Get all character settings for a character: <green>AshraelPackage.GetCharacterSettings(characterName, module)<reset>\n")
    cecho(" - Get all setting definitions: <green>AshraelPackage.GetAllSettingDefinitions()<reset>\n")

    cecho("\n<green>Package Management:<reset>\n")
    cecho(" - Update the package to the latest version: <green>ashpkg update<reset>\n")
    cecho(" - List all available versions: <green>ashpkg versions<reset>\n")
    cecho(" - Switch to a specific version: <green>ashpkg switch <version><reset>\n")

    cecho("\nEnjoy using Ashrael Package to simplify your MUD experience!<reset>\n")
end
  
-- Set up aliases for package commands
if not AshraelPackage.AliasCreated then
    tempAlias("^ashpkg$", [[AshraelPackage.DisplayHelp()]])  -- Updated to trigger help on blank command
    tempAlias("^ashpkg update$", [[AshraelPackage.CheckForUpdates()]])
    tempAlias("^ashpkg versions$", [[AshraelPackage.DownloadAndListVersions()]])
    tempAlias("^ashpkg switch (.+)$", [[AshraelPackage.SwitchToVersion(matches[2])]])
    AshraelPackage.AliasCreated = true
end

-- Register download completion event handler
if AshraelPackage.DownloadHandler then
    killAnonymousEventHandler(AshraelPackage.DownloadHandler)
end

AshraelPackage.DownloadHandler = registerAnonymousEventHandler("sysDownloadDone", "AshraelPackage.OnFileDownloaded")

-- Call the initialization function
AshraelPackage.InitializeDatabase()
AshraelPackage.InitializeVersion()
AshraelPackage.EnsurePersistentDownloadPathExists()
