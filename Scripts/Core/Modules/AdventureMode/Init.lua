-- Persistent adventure mode state table
AshraelPackage = AshraelPackage or {}
AshraelPackage.AdventureMode = AshraelPackage.AdventureMode or {}
AshraelPackage.AdventureMode.State = AshraelPackage.AdventureMode.State or {
    IsAdventuring = false,
    IsRecovering = false,
    AdventureModeType = "solo",  -- Default mode is solo
    DebugMode = false  -- Tracks if debug mode is on
}

