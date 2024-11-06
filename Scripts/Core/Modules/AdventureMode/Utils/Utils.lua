-- Initialize AshraelPackage with AdventureMode and Utils namespaces
AshraelPackage = AshraelPackage or {}
AshraelPackage.AdventureMode.Utils = AshraelPackage.AdventureMode.Utils or {}
Utils = AshraelPackage.AdventureMode.Utils

Utils.IsInSanctum = Utils.IsInSanctum or false
Utils.IsInSanctumInfirmary = Utils.IsInSanctumInfirmary or false

-- Utils function to check for a bot's presence in the room
function Utils.CheckBotPresence(botName)
    if gmcp.Room and gmcp.Room.Players then
        for _, player in pairs(gmcp.Room.Players) do
            if player.name:lower() == botName:lower() then
                return true
            end
        end
    end
    return false
end

-- Update Sanctum status based on the room name
function Utils.UpdateSanctumStatus()
    if gmcp.Room and gmcp.Room.Info and gmcp.Room.Info.name then
        local roomName = gmcp.Room.Info.name:lower()
        Utils.IsInSanctum = (roomName == "the sanctum")
        Utils.IsInSanctumInfirmary = (roomName == "avatar's sanctum infirmary")
    else
        Utils.IsInSanctum, Utils.IsInSanctumInfirmary = false, false
    end
end

-- Resume the callback coroutine if needed
function Utils.ResumeCallback(callback)
    if callback then
        Utils.DebugPrint("Resuming callback coroutine.")  -- Updated debug print
        if coroutine.status(callback) == "suspended" then
            coroutine.resume(callback)
        else
            Utils.DebugPrint("Callback is not suspended. Status: " .. coroutine.status(callback), true)  -- Updated debug print
        end
    else
        Utils.DebugPrint("No callback provided.", true)  -- Updated debug print
    end
end

-- Debug print function using Ashrael_Package.AdventureMode.State for debug mode
function Utils.DebugPrint(message, ...)
    if AshraelPackage.AdventureMode.State.DebugMode then
        local formattedMessage = string.format(message, ...)
        cecho("<cyan>[DEBUG] " .. formattedMessage .. "<reset>\n")
    end
end


-- Register event handler for updating Sanctum status
registerAnonymousEventHandler("gmcp.Room.Info", "AshraelPackage.AdventureMode.Utils.UpdateSanctumStatus")
