-- Initialize AshraelPackage with AdventureMode and Utils namespaces
AshraelPackage = AshraelPackage or {}
AshraelPackage.AdventureMode = AshraelPackage.AdventureMode or {}
AshraelPackage.AdventureMode.Managers.RecallManager = AshraelPackage.AdventureMode.Managers.RecallManager or {}
AshraelPackage.AdventureMode.Utils = AshraelPackage.AdventureMode.Utils or {}

local AdventureMode = AshraelPackage.AdventureMode
local RecallManager = AshraelPackage.AdventureMode.Managers.RecallManager
local Utils = AdventureMode.Utils

-- Define global variables if not already set
RecallManager.TryRecallCoroutine = RecallManager.TryRecallCoroutine or nil
RecallManager.TryRecallComplete = RecallManager.TryRecallComplete or false
RecallManager.RecallStatus = RecallManager.RecallStatus or nil

-- Attempt to recall to Sanctum, handling obstacles with added debugging
function RecallManager.TryRecall(callback)
    Utils.DebugPrint("Starting TryRecall function.")  -- Updated debug print

    -- Initialize the TryRecallCoroutine if not already started
    if not RecallManager.TryRecallCoroutine then
        Utils.DebugPrint("Initializing TryRecallCoroutine.")  -- Updated debug print
        RecallManager.TryRecallCoroutine = coroutine.create(function() 
            RecallManager.TryRecall(nil) 
        end)

        local status, err = coroutine.resume(RecallManager.TryRecallCoroutine)
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
        local status = tostring(RecallManager.RecallStatus)
        Utils.DebugPrint("Attempt " .. attempts .. " inside TryRecall loop. RecallStatus: " .. status)  -- Updated debug print

        if RecallManager.RecallStatus == "cursed" then
            Utils.DebugPrint("Recall failed due to curse. Attempting teleport.", true)  -- Updated debug print
            send("cast 'teleport' sol")
            RecallManager.RecallStatus = nil
            send("sanc")
            coroutine.yield()

        elseif RecallManager.RecallStatus == "sleeping" then
            Utils.DebugPrint("Recall failed due to sleeping. Waking up.", true)  -- Updated debug print
            send("wake")
            RecallManager.RecallStatus = nil
            send("sanc")
            coroutine.yield()

        elseif RecallManager.RecallStatus == "fighting" then
            Utils.DebugPrint("Recall failed due to fighting. Attempting to flee.", true)  -- Updated debug print
            while RecallManager.RecallStatus == "fighting" do
                send("flee")
                RecallManager.RecallStatus = nil
                send("sanc")
                coroutine.yield()
            end

        elseif RecallManager.RecallStatus == "at_sanctum" then
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
    RecallManager.TryRecallComplete = true
    Utils.ResumeCallback(callback)
end