-- Initialize AshraelPackage with AdventureMode and Utils namespaces
AshraelPackage = AshraelPackage or {}
AshraelPackage.AdventureMode = AshraelPackage.AdventureMode or {}
AshraelPackage.AdventureMode.Recall = AshraelPackage.AdventureMode.Recall or {}
AshraelPackage.AdventureMode.Utils = AshraelPackage.AdventureMode.Utils or {}

local AdventureMode = AshraelPackage.AdventureMode
local Recall = AdventureMode.Recall
local Utils = AdventureMode.Utils

-- Define global variables if not already set
Recall.TryRecallCoroutine = Recall.TryRecallCoroutine or nil
Recall.TryRecallComplete = Recall.TryRecallComplete or false
Recall.RecallStatus = Recall.RecallStatus or nil

-- Attempt to recall to Sanctum, handling obstacles with added debugging
function Recall.TryRecall(callback)
    Utils.DebugPrint("Starting TryRecall function.")  -- Updated debug print

    -- Initialize the TryRecallCoroutine if not already started
    if not Recall.TryRecallCoroutine then
        Utils.DebugPrint("Initializing TryRecallCoroutine.")  -- Updated debug print
        Recall.TryRecallCoroutine = coroutine.create(function() 
            Recall.TryRecall(nil) 
        end)

        local status, err = coroutine.resume(Recall.TryRecallCoroutine)
        if not status then
            Utils.DebugPrint("Failed to start TryRecallCoroutine: " .. tostring(err), true)  -- Updated debug print
        else
            Utils.DebugPrint("TryRecallCoroutine started successfully.")  -- Updated debug print
        end
    end
    
    local attempts, maxAttempts = 0, 10
    Utils.DebugPrint("Sending initial recall command ('sanc').")  -- Updated debug print
    send("sanc")
    coroutine.yield()  -- Yield to allow triggers to update RecallStatus
    
    while attempts < maxAttempts do
        attempts = attempts + 1
        local status = tostring(Recall.RecallStatus)
        Utils.DebugPrint("Attempt " .. attempts .. " inside TryRecall loop. RecallStatus: " .. status)  -- Updated debug print

        if Recall.RecallStatus == "cursed" then
            Utils.DebugPrint("Recall failed due to curse. Attempting teleport.", true)  -- Updated debug print
            send("cast 'teleport' sol")
            Recall.RecallStatus = nil
            send("sanc")
            coroutine.yield()

        elseif Recall.RecallStatus == "sleeping" then
            Utils.DebugPrint("Recall failed due to sleeping. Waking up.", true)  -- Updated debug print
            send("wake")
            Recall.RecallStatus = nil
            send("sanc")
            coroutine.yield()

        elseif Recall.RecallStatus == "fighting" then
            Utils.DebugPrint("Recall failed due to fighting. Attempting to flee.", true)  -- Updated debug print
            while Recall.RecallStatus == "fighting" do
                send("flee")
                Recall.RecallStatus = nil
                send("sanc")
                coroutine.yield()
            end

        elseif Recall.RecallStatus == "at_sanctum" then
            Utils.DebugPrint("Recall successful. Now at Sanctum.")  -- Updated debug print
            break

        else
            Utils.DebugPrint("Unknown or cleared RecallStatus; exiting attempts.", true)  -- Updated debug print
            break
        end
    end

    if attempts >= maxAttempts then
        Utils.DebugPrint("Maximum recall attempts reached. Ending recall process.", true)  -- Updated debug print
    end

    Utils.DebugPrint("Exiting TryRecall function after " .. attempts .. " attempts.")  -- Updated debug print
    Recall.TryRecallComplete = true
    Utils.ResumeCallback(callback)
end