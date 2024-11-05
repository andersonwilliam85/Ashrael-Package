-- Initialize the main AdventureMode module and set up persistent state
AshraelPackage = AshraelPackage or {}
AshraelPackage.AdventureMode = AshraelPackage.AdventureMode or {}

local AdventureMode = AshraelPackage.AdventureMode
AdventureMode.State = AdventureMode.State or {
    IsAdventuring = false,
    IsRecovering = false,
    AdventureModeType = "solo",  -- Default mode is solo
    DebugMode = false  -- Tracks if debug mode is on
}

-- Full namespace qualification for managers
AshraelPackage.AdventureMode.Managers = AshraelPackage.AdventureMode.Managers or {}
AshraelPackage.AdventureMode.Managers.RecallManager = AshraelPackage.AdventureMode.Managers.RecallManager or {}
AshraelPackage.AdventureMode.Managers.UtilsManager = AshraelPackage.AdventureMode.Managers.UtilsManager or {}
AshraelPackage.AdventureMode.Managers.GearManager = AshraelPackage.AdventureMode.Managers.GearManager or {}
AshraelPackage.AdventureMode.Managers.SpellupManager = AshraelPackage.AdventureMode.Managers.SpellupManager or {}
AshraelPackage.AdventureMode.Managers.HealingManager = AshraelPackage.AdventureMode.Managers.HealingManager or {}

-- Local references to AdventureMode managers
local Recall = AshraelPackage.AdventureMode.Managers.RecallManager
local Utils = AshraelPackage.AdventureMode.Managers.UtilsManager
local Gear = AshraelPackage.AdventureMode.Managers.GearManager
local Spellup = AshraelPackage.AdventureMode.Managers.SpellupManager
local Healing = AshraelPackage.AdventureMode.Managers.HealingManager
local State = AdventureMode.State

-- Function to initiate recall and recovery process
function AdventureMode.InitiateRecallAndRecovery()
    Utils.DebugPrint("Initiating recall and recovery process.")

    local recoveryCoroutine = coroutine.create(function()
        while not Recall.TryRecallComplete do
            Utils.DebugPrint("Waiting for TryRecall to complete.")
            coroutine.yield() -- Yield until TryRecall completes
        end

        Utils.DebugPrint("TryRecall complete. Proceeding with recovery actions.")
        send("d")
        send("w")

        tempTimer(5, function()
            Utils.DebugPrint("Equipping mana gear, initiating healing, and preparing spells.")
            Gear.Equip("mana")
            Spellup.RequestSpellup()
            Healing.RequestHealing()

            if StatTable.Position and StatTable.Position:lower() ~= "sleep" then
                Utils.DebugPrint("Entering sleep mode to complete recovery.")
                send("sleep")
            else
                Utils.DebugPrint("Already in sleep mode or no need to sleep.")
            end

            Utils.DebugPrint("Recovery actions completed.")
        end)
    end)

    Recall.TryRecallComplete = false
    Recall.TryRecallCoroutine = coroutine.create(function()
        Utils.DebugPrint("Starting TryRecall coroutine.")
        Recall.TryRecall(recoveryCoroutine)
    end)

    local status, err = coroutine.resume(Recall.TryRecallCoroutine)
    if not status then
        Utils.DebugPrint("Failed to start TryRecall coroutine: " .. tostring(err), true)
    else
        Utils.DebugPrint("TryRecall coroutine started successfully.")
    end
end

-- Toggle Adventure Mode ON/OFF and manage recovery initiation
function AdventureMode.ToggleAdventure(mode)
    State.IsAdventuring = not State.IsAdventuring
    State.IsRecovering = false

    if State.IsAdventuring then
        State.AdventureModeType = mode or "solo"
        Utils.DebugPrint("Adventure mode ON in " .. State.AdventureModeType .. " mode.")
        if StatTable.Position and StatTable.Position:lower() == "sleep" then
            send("wake")
        end
        Utils.DebugPrint("Equipping tank gear and surveying surroundings.")
        Gear.Equip("tank")
        send("look")
    else
        Utils.DebugPrint("Adventure mode OFF.")
        State.AdventureModeType = "solo"
        Utils.DebugPrint("Equipping mana gear and attempting recall to sanctum.")
        AdventureMode.InitiateRecallAndRecovery()
    end
end

-- Toggle Recovery Mode ON/OFF and initiate recovery
function AdventureMode.ToggleRecovery()
    coroutine.wrap(function()
        if not State.IsAdventuring then
            Utils.DebugPrint("Cannot enter Recovery mode without Adventure mode enabled.", true)
            return
        end

        State.IsRecovering = not State.IsRecovering
        if State.IsRecovering then
            if State.AdventureModeType == "solo" then
                Utils.DebugPrint("Solo Recovery mode ON: Prioritizing self-healing and buffs.")
                send("recall set")
                AdventureMode.InitiateRecallAndRecovery()
            elseif State.AdventureModeType == "group" then
                Utils.DebugPrint("Group Recovery mode ON: Preparing group recovery actions.")
            end
        else
            Utils.DebugPrint("Recovery mode OFF.")
            if StatTable.Position and StatTable.Position:lower() == "sleep" then
                send("wake")
            end
        end
    end)()
end

-- Resume Adventure Mode from Recovery Mode
function AdventureMode.ResumeAdventure()
    if not State.IsRecovering then
        Utils.DebugPrint("Not in recovery mode. No adventure to resume.", true)
        return
    end
    State.IsRecovering = false

    if State.AdventureModeType == "solo" then
        Utils.DebugPrint("Resuming Solo Adventure mode.")
        if StatTable.Position and StatTable.Position:lower() == "sleep" then
            send("wake")
        end
        Gear.Equip("tank")
        send("recall")
        send("look")
        Utils.DebugPrint("Solo Adventure mode resumed successfully.")
    elseif State.AdventureModeType == "group" then
        Utils.DebugPrint("Resuming Group Adventure mode.")
        send("cast group_ready")
    end
end

-- Display current Adventure Mode status
function AdventureMode.DisplayStatus()
    Utils.DebugPrint("Displaying current status of Adventure Mode.")
    cecho("\n<blue>Status:<reset> Adventure Mode: <green>" .. (State.IsAdventuring and "ON" or "OFF") .. 
          "<reset>, Mode Type: <yellow>" .. State.AdventureModeType .. 
          "<reset>, Recovery Mode: <yellow>" .. (State.IsRecovering and "YES" or "NO") .. "<reset>\n")
end

-- Reset Adventure and Recovery Modes to OFF
function AdventureMode.ResetModes()
    State.IsAdventuring = false
    State.IsRecovering = false
    State.DebugMode = false
    State.AdventureModeType = "solo"
    Utils.DebugPrint("Adventure and Recovery modes have been reset.", true)
end

-- Display help for Adventure Mode commands
function AdventureMode.DisplayHelp()
    Utils.DebugPrint("Displaying help for Adventure Mode commands.")
    cecho("\n<blue>Adventure Mode Help<reset>\n" ..
          "<green>adv<reset> - Toggles Adventure mode ON or OFF.\n" ..
          "<green>adv solo<reset> - Toggles Adventure mode ON in Solo mode.\n" ..
          "<green>adv group<reset> - Toggles Adventure mode ON in Group mode.\n" ..
          "<green>adv resume<reset> - Resumes Adventure mode from Recovery mode.\n" ..
          "<green>adv recover<reset> - Toggles Recovery mode ON or OFF if Adventure mode is ON.\n" ..
          "<green>adv status<reset> - Displays current status of Adventure and Recovery modes.\n" ..
          "<green>adv reset<reset> - Resets Adventure and Recovery modes to OFF.\n" ..
          "<green>adv <cmd> --debug <reset> - Set DebugMode to true to ON and provides additional logging.\n")
end

-- Confirm successful initialization of Adventure Mode
if AdventureMode then
    cecho("<green>Adventure Mode initialized successfully.\n")
else
    cecho("<red>Error initializing Adventure Mode. Please check configuration.\n")
end
