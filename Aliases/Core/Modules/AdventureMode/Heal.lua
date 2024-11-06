-- Regex Triggers:
-- ^healme(?:\s+(--debug))?$

-- Check if --debug flag is passed and set it in State
AshraelPackage.AdventureMode.State.DebugMode = matches[2] ~= nil

-- Call RequestHealing without passing debugEnabled
AshraelPackage.AdventureMode.Managers.HealingManager.RequestHealing()
