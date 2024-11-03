-- Debug print function using Ashrael_Package.AdventureMode.State for debug mode
function AshraelPackage.AdventureMode.Utils.DebugPrint(message, ...)
    if AshraelPackage.AdventureMode.State.DebugMode then
        local formattedMessage = string.format(message, ...)
        cecho("<cyan>[DEBUG] " .. formattedMessage .. "<reset>\n")
    end
end

