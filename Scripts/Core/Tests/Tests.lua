-- Automated Test for Settings
function AshraelPackage.RunAutomatedSettingsTest()
    cecho("Running automated settings test...\n")
    local packageName = "testPackage"

    -- Set up test values
    local testGlobalSetting1 = "test_global_setting_1"
    local testGlobalSetting2 = "test_global_setting_2"
    local testCharacterSetting1 = "test_character_setting_1"
    local testCharacterSetting2 = "test_character_setting_2"
    local testCharacterName = "TestCharacter1"

    -- Expected values
    local expectedGlobalValue1 = "value1"
    local expectedGlobalValue2 = "value2"
    local expectedCharacterValue1 = "value1"
    local expectedCharacterValue2 = "value2"

    -- Step 1: Set global settings
    AshraelPackage.SetGlobalSetting(packageName, testGlobalSetting1, expectedGlobalValue1)
    AshraelPackage.SetGlobalSetting(packageName, testGlobalSetting2, expectedGlobalValue2)

    -- Step 2: Get global settings and validate
    local retrievedGlobalValue1 = AshraelPackage.GetGlobalSetting(packageName, testGlobalSetting1)
    local retrievedGlobalValue2 = AshraelPackage.GetGlobalSetting(packageName, testGlobalSetting2)

    if retrievedGlobalValue1 ~= expectedGlobalValue1 then
        cecho(string.format("Failed: Expected '%s' but retrieved '%s' for global setting '%s'.\n", expectedGlobalValue1, retrievedGlobalValue1, testGlobalSetting1))
    else
        cecho(string.format("Passed: Retrieved global setting '%s' successfully.\n", testGlobalSetting1))
    end

    if retrievedGlobalValue2 ~= expectedGlobalValue2 then
        cecho(string.format("Failed: Expected '%s' but retrieved '%s' for global setting '%s'.\n", expectedGlobalValue2, retrievedGlobalValue2, testGlobalSetting2))
    else
        cecho(string.format("Passed: Retrieved global setting '%s' successfully.\n", testGlobalSetting2))
    end

    -- Step 3: Set character settings
    AshraelPackage.SetCharacterSetting(testCharacterName, packageName, testCharacterSetting1, expectedCharacterValue1)
    AshraelPackage.SetCharacterSetting(testCharacterName, packageName, testCharacterSetting2, expectedCharacterValue2)

    -- Step 4: Get character settings and validate
    local retrievedCharacterValue1 = AshraelPackage.GetCharacterSetting(testCharacterName, packageName, testCharacterSetting1)
    local retrievedCharacterValue2 = AshraelPackage.GetCharacterSetting(testCharacterName, packageName, testCharacterSetting2)

    if retrievedCharacterValue1 ~= expectedCharacterValue1 then
        cecho(string.format("Failed: Expected '%s' but retrieved '%s' for character setting '%s' of '%s'.\n", expectedCharacterValue1, retrievedCharacterValue1, testCharacterSetting1, testCharacterName))
    else
        cecho(string.format("Passed: Retrieved character setting '%s' for '%s' successfully.\n", testCharacterSetting1, testCharacterName))
    end

    if retrievedCharacterValue2 ~= expectedCharacterValue2 then
        cecho(string.format("Failed: Expected '%s' but retrieved '%s' for character setting '%s' of '%s'.\n", expectedCharacterValue2, retrievedCharacterValue2, testCharacterSetting2, testCharacterName))
    else
        cecho(string.format("Passed: Retrieved character setting '%s' for '%s' successfully.\n", testCharacterSetting2, testCharacterName))
    end

    -- Step 5: Get all setting definitions
    local definitions = AshraelPackage.GetAllSettingDefinitions()  -- Assuming this function fetches all setting definitions
    for _, definition in ipairs(definitions) do
        cecho(string.format("Setting Name: %s, Default Value: %s, Description: %s\n", definition.setting_name, definition.default_value, definition.description))
    end

    -- Step 6: Get all settings by character and module
    local characterSettings = AshraelPackage.GetCharacterSettings(testCharacterName, packageName)
    for _, setting in ipairs(characterSettings) do
        cecho(string.format("Character Setting: %s = %s\n", setting.setting_name, setting.value))
    end

    -- Step 7: Get all global settings by module
    local globalSettings = AshraelPackage.GetGlobalSettings(packageName)
    for _, setting in ipairs(globalSettings) do
        cecho(string.format("Global Setting: %s = %s\n", setting.setting_name, setting.value))
    end

    -- Cleanup: Remove test settings from the database
    AshraelPackage.RemoveGlobalSetting(packageName, testGlobalSetting1)
    AshraelPackage.RemoveGlobalSetting(packageName, testGlobalSetting2)
    AshraelPackage.RemoveCharacterSetting(testCharacterName, packageName, testCharacterSetting1)
    AshraelPackage.RemoveCharacterSetting(testCharacterName, packageName, testCharacterSetting2)

    cecho("Automated settings test completed and cleaned up.\n")
end

-- Run the automated settings test
AshraelPackage.RunAutomatedSettingsTest()