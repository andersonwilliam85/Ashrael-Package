-- Initialize the main AdventureMode module and set up persistent state
AshraelPackage = AshraelPackage or {}
AshraelPackage.AdventureMode = AshraelPackage.AdventureMode or {}

AshraelPackage.AdventureMode.State = AshraelPackage.AdventureMode.State or {
    IsAdventuring = false,
    AdventureModeType = "solo",  -- Default mode is solo
    DebugMode = false  -- Tracks if debug mode is on
}

-- Full namespace qualification for managers
AshraelPackage.AdventureMode.Managers = AshraelPackage.AdventureMode.Managers or {}
AshraelPackage.AdventureMode.Managers.RecallManager = AshraelPackage.AdventureMode.Managers.RecallManager or {}
AshraelPackage.AdventureMode.Managers.EquipmentManager = AshraelPackage.AdventureMode.Managers.EquipmentManager or {}
AshraelPackage.AdventureMode.Managers.SpellupManager = AshraelPackage.AdventureMode.Managers.SpellupManager or {}
AshraelPackage.AdventureMode.Managers.HealingManager = AshraelPackage.AdventureMode.Managers.HealingManager or {}
AshraelPackage.AdventureMode.Utils = AshraelPackage.AdventureMode.Utils or {}

-- Local references to AdventureMode managers
local RecallManager = AshraelPackage.AdventureMode.Managers.RecallManager
local EquipmentManager = AshraelPackage.AdventureMode.Managers.EquipmentManager
local SpellupManager = AshraelPackage.AdventureMode.Managers.SpellupManager
local HealingManager = AshraelPackage.AdventureMode.Managers.HealingManager
local State = AshraelPackage.AdventureMode.State
local Utils = AshraelPackage.AdventureMode.Utils

-- Function to initiate recall and recovery process
function AshraelPackage.AdventureMode.InitiateRecovery()
    Utils.DebugPrint("Initiating recall and recovery process.")

    local recoveryCoroutine = coroutine.create(function()
        while not RecallManager.TryRecallComplete do
            Utils.DebugPrint("Waiting for TryRecall to complete.")
            coroutine.yield() -- Yield until TryRecall completes
        end

        Utils.DebugPrint("TryRecall complete. Proceeding with recovery actions.")
        send("d")
        send("w")

        tempTimer(5, function()
            Utils.DebugPrint("Equipping mana gear, initiating healing, and preparing spells.")
            EquipmentManager.Equip("mana")
            SpellupManager.RequestSpellup()
            HealingManager.RequestHealing()

            if StatTable.Position and StatTable.Position:lower() ~= "sleep" then
                Utils.DebugPrint("Entering sleep mode to complete recovery.")
                send("sleep")
            else
                Utils.DebugPrint("Already in sleep mode or no need to sleep.")
            end

            Utils.DebugPrint("Recovery actions completed.")
        end)
    end)

    RecallManager.TryRecallComplete = false
    RecallManager.TryRecallCoroutine = coroutine.create(function()
        Utils.DebugPrint("Starting TryRecall coroutine.")
        RecallManager.TryRecall(recoveryCoroutine)
    end)

    local status, err = coroutine.resume(RecallManager.TryRecallCoroutine)
    if not status then
        Utils.DebugPrint("Failed to start TryRecall coroutine: " .. tostring(err), true)
    else
        Utils.DebugPrint("TryRecall coroutine started successfully.")
    end
end

-- Toggle Adventure Mode ON/OFF and manage recovery initiation
function AshraelPackage.AdventureMode.ToggleAdventure(mode)
    State.IsAdventuring = not State.IsAdventuring

    if State.IsAdventuring then
        State.AdventureModeType = mode or "solo"
        Utils.DebugPrint("Adventure mode ON in " .. State.AdventureModeType .. " mode.")
        if StatTable.Position and StatTable.Position:lower() == "sleep" then
            send("wake")
        end
        Utils.DebugPrint("Equipping tank gear and surveying surroundings.")
        EquipmentManager.Equip("tank")
        send("look")
    else
        Utils.DebugPrint("Adventure mode OFF.")
        State.AdventureModeType = "solo"
        Utils.DebugPrint("Equipping mana gear and attempting recall to sanctum.")
        AshraelPackage.AdventureMode.InitiateRecovery()
    end
end

-- Command to initiate recovery directly
function AshraelPackage.AdventureMode.Recover()
    Utils.DebugPrint("Starting recovery process.")
    send("recall set")
    AshraelPackage.AdventureMode.InitiateRecovery()
end

-- Resume Adventure Mode after a pause
function AshraelPackage.AdventureMode.ResumeAdventure()
    Utils.DebugPrint("Recalling and preparing for battle.")
    send("wake")
    EquipmentManager.Equip("tank")
    send("recall")
    send("look")
end

-- Display current Adventure Mode status
function AshraelPackage.AdventureMode.DisplayStatus()
    Utils.DebugPrint("Displaying current status of Adventure Mode.")
    cecho("\n<blue>Status:<reset> Adventure Mode: <green>" .. (State.IsAdventuring and "ON" or "OFF") .. 
          "<reset>, Mode Type: <yellow>" .. State.AdventureModeType .. "<reset>\n")
end

-- Reset Adventure Mode to OFF
function AshraelPackage.AdventureMode.ResetModes()
    State.IsAdventuring = false
    State.DebugMode = false
    State.AdventureModeType = "solo"
    Utils.DebugPrint("Adventure mode has been reset.", true)
end

-- Display help for Adventure Mode commands
function AshraelPackage.AdventureMode.DisplayHelp()
    Utils.DebugPrint("Displaying help for Adventure Mode commands.")
    cecho("\n<blue>Adventure Mode Help<reset>\n" ..
          "<green>adv<reset> - Toggles Adventure mode ON or OFF.\n" ..
          "<green>adv solo<reset> - Toggles Adventure mode ON in Solo mode.\n" ..
          "<green>adv group<reset> - Toggles Adventure mode ON in Group mode.\n" ..
          "<green>adv resume<reset> - Recalls and prepares you for battle.\n" ..
          "<green>adv recover<reset> - Directly initiates the recall and recovery process.\n" ..
          "<green>adv status<reset> - Displays the current status of Adventure mode.\n" ..
          "<green>adv reset<reset> - Resets Adventure mode to OFF.\n" ..
          "<green>adv <cmd> --debug<reset> - Sets DebugMode ON, providing additional logging.\n")
end

-- Confirm successful initialization of Adventure Mode
if AshraelPackage.AdventureMode then
    cecho("<green>Adventure Mode initialized successfully.\n")
else
    cecho("<red>Error initializing Adventure Mode. Please check configuration.\n")
end