-- CODEREVIEW: This is good. I'd recommend using this script to setup all your default variables
-- However, make sure to put it at the very top of your package so it's the first script to load.
-- That ensures that the other scripts will all be able to find AshraelPackage

-- Persistent adventure mode state table
AshraelPackage = AshraelPackage or {}
AshraelPackage.AdventureMode = AshraelPackage.AdventureMode or {}
AshraelPackage.AdventureMode.State = AshraelPackage.AdventureMode.State or {
    IsAdventuring = false,
    IsRecovering = false,
    AdventureModeType = "solo",  -- Default mode is solo
    DebugMode = false  -- Tracks if debug mode is on
}

