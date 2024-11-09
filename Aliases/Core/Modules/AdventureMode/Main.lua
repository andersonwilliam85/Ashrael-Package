-- Regex Triggers:
-- ^(adv)(?:\s+(solo|group|help|recover|resume|status|reset))?(?:\s+(--debug))?$

-- Initialize AshraelPackage with AdventureMode namespace and State table if not already set
AshraelPackage = AshraelPackage or {}
AshraelPackage.AdventureMode = AshraelPackage.AdventureMode or {}
AshraelPackage.AdventureMode.State = AshraelPackage.AdventureMode.State or {
    IsAdventuring = false,
    AdventureModeType = "solo",  -- Default mode is solo
    DebugMode = false  -- Tracks if debug mode is on
}

local AdventureMode = AshraelPackage.AdventureMode
local State = AdventureMode.State

-- Utils namespace for utility functions
AdventureMode.Utils = AdventureMode.Utils or {}

-- Main command processor function to handle various commands
local function ProcessCommand(command, mode)
    if command == "adv" then
        AdventureMode.ToggleAdventure(mode)  -- Use mode ("solo" or "group") from State
    elseif command == "adv resume" then
        AdventureMode.ResumeAdventure()  -- Resume adventure directly, preparing for battle
    elseif command == "adv recover" then
        AdventureMode.Recover()  -- Initiate the recovery process directly
    elseif command == "adv status" then
        AdventureMode.DisplayStatus()  -- Show current status
    elseif command == "adv reset" then
        AdventureMode.ResetModes()  -- Reset modes
    elseif command == "adv help" then
        AdventureMode.DisplayHelp()  -- Display help information
    elseif command == "heals" then
        AdventureMode.Managers.HealingManager.RequestHealing()  -- Call healing handler
    else
        cecho("\n<red>Unknown command. Type 'adv help' or 'heals' for available commands.<reset>\n")
    end
end

-- Parse command and options from matches
local command = matches[2] or "adv"       -- Base command is "adv"
local option = matches[3]                  -- Option like "solo", "group", "resume", etc.
local debugOption = matches[4]             -- Captures "--debug" if present

-- Set mode and DebugMode in State based on options provided
local mode = (option == "solo" or option == "group") and option or nil
State.DebugMode = (debugOption == "--debug")  -- Set debug mode directly in State

-- Call the main command processor with parsed options
if option == "resume" or option == "recover" or option == "reset" or 
   option == "status" or option == "help" then
    ProcessCommand("adv " .. option, nil)
elseif mode then
    ProcessCommand("adv", mode)  -- Call ToggleAdventure in specified mode
else
    ProcessCommand(command, nil)  -- Default to base command without additional options
end
