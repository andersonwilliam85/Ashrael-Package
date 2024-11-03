local AdventureMode = AshraelPackage.AdventureMode
local Recall = AdventureMode.Recall
local Utils = AdventureMode.Utils  -- Access to utility functions
local Gear = AdventureMode.Gear      -- Lifted Gear to outer scope
local Spellup = AdventureMode.Spellup -- Lifted Spellup to outer scope
local Healing = AdventureMode.Healing -- Lifted Healing to outer scope
local State = AdventureMode.State      -- Lifted State to outer scope

-- Initiates recall and recovery process with added debugging
function AdventureMode.InitiateRecallAndRecovery()
    Utils.DebugPrint("Initiating recall and recovery process.")  -- Updated debug print

    local recoveryCoroutine = coroutine.create(function()
        while not Recall.TryRecallComplete do
            Utils.DebugPrint("Waiting for TryRecall to complete.")  -- Updated debug print
            coroutine.yield() -- Yield until TryRecall completes
        end
        
        Utils.DebugPrint("TryRecall complete. Proceeding with recovery actions.")  -- Updated debug print
        send("d")
        send("w")

        tempTimer(5, function()
            Utils.DebugPrint("Equipping mana gear, initiating healing, and preparing spells.")  -- Updated debug print
            
            -- Attempt to equip mana gear
            Utils.DebugPrint("Attempting to equip mana gear.")  -- Updated debug print
            Gear.Equip("mana")  -- Using Gear namespace for equipping mana gear

            -- Request spell-up
            Utils.DebugPrint("Requesting spell-up.")  -- Updated debug print
            Spellup.RequestSpellup()  -- Using Spellup namespace directly

            -- Request healing
            Utils.DebugPrint("Requesting healing.")  -- Updated debug print
            Healing.RequestHealing()  -- Using Healing namespace directly

            -- Check if player needs to sleep
            if StatTable.Position and StatTable.Position:lower() ~= "sleep" then
                Utils.DebugPrint("Entering sleep mode to complete recovery.")  -- Updated debug print
                send("sleep")
            else
                Utils.DebugPrint("Already in sleep mode or no need to sleep.")  -- Updated debug print
            end

            Utils.DebugPrint("Recovery actions completed.")  -- Updated debug print
        end)
    end)

    -- Reset TryRecallComplete and initiate TryRecallCoroutine
    Recall.TryRecallComplete = false
    Recall.TryRecallCoroutine = coroutine.create(function()
        Utils.DebugPrint("Starting TryRecall coroutine.")  -- Updated debug print
        Recall.TryRecall(recoveryCoroutine)
    end)

    -- Resume the TryRecallCoroutine
    local status, err = coroutine.resume(Recall.TryRecallCoroutine)
    if not status then
        Utils.DebugPrint("Failed to start TryRecall coroutine: " .. tostring(err), true)  -- Updated debug print
    else
        Utils.DebugPrint("TryRecall coroutine started successfully.")  -- Updated debug print
    end
end

-- Toggles Adventure Mode ON/OFF and handles recovery initiation
function AdventureMode.ToggleAdventure(mode)
    State.IsAdventuring = not State.IsAdventuring
    State.IsRecovering = false

    if State.IsAdventuring then
        State.AdventureModeType = mode or "solo"
        Utils.DebugPrint("Adventure mode ON in " .. State.AdventureModeType .. " mode.")  -- Updated debug print

        if StatTable.Position and StatTable.Position:lower() == "sleep" then
            send("wake")
        end

        Utils.DebugPrint("Equipping tank gear and surveying surroundings.")  -- Updated debug print
        Gear.Equip("tank")  -- Using Gear namespace for equipping tank gear
        send("look")
    else
        Utils.DebugPrint("Adventure mode OFF.")  -- Updated debug print
        State.AdventureModeType = "solo"
        Utils.DebugPrint("Equipping mana gear and attempting recall to sanctum.")  -- Updated debug print
        AdventureMode.InitiateRecallAndRecovery()
    end
end

-- Toggles Recovery Mode ON/OFF and initiates recovery
function AdventureMode.ToggleRecovery()
    coroutine.wrap(function()
        if not State.IsAdventuring then
            Utils.DebugPrint("Cannot enter Recovery mode without Adventure mode enabled.", true)  -- Updated debug print
            return
        end

        State.IsRecovering = not State.IsRecovering
        if State.IsRecovering then
            if State.AdventureModeType == "solo" then
                Utils.DebugPrint("Solo Recovery mode ON: Prioritizing self-healing and buffs.")  -- Updated debug print
                send("recall set")
                AdventureMode.InitiateRecallAndRecovery()
            elseif State.AdventureModeType == "group" then
                Utils.DebugPrint("Group Recovery mode ON: Preparing group recovery actions.")  -- Updated debug print
            end
        else
            Utils.DebugPrint("Recovery mode OFF.")  -- Updated debug print
            if StatTable.Position and StatTable.Position:lower() == "sleep" then
                send("wake")
            end
        end
    end)()
end

-- Resumes Adventure Mode from Recovery Mode
function AdventureMode.ResumeAdventure()
    if not State.IsRecovering then
        Utils.DebugPrint("Not in recovery mode. No adventure to resume.", true)  -- Updated debug print
        return
    end
    State.IsRecovering = false

    if State.AdventureModeType == "solo" then
        Utils.DebugPrint("Resuming Solo Adventure mode.")  -- Updated debug print
        if StatTable.Position and StatTable.Position:lower() == "sleep" then
            send("wake")
        end
        Gear.Equip("tank")  -- Using Gear namespace for equipping tank gear
        send("recall")
        send("look")
        Utils.DebugPrint("Solo Adventure mode resumed successfully.")  -- Updated debug print
    elseif State.AdventureModeType == "group" then
        Utils.DebugPrint("Resuming Group Adventure mode.")  -- Updated debug print
        send("cast group_ready")
    end
end

-- Display current Adventure Mode status
function AdventureMode.DisplayStatus()
    Utils.DebugPrint("Displaying current status of Adventure Mode.")  -- Updated debug print
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
    Utils.DebugPrint("Adventure and Recovery modes have been reset.", true)  -- Updated debug print
end

-- Display help for Adventure Mode commands
function AdventureMode.DisplayHelp()
    Utils.DebugPrint("Displaying help for Adventure Mode commands.")  -- Updated debug print
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