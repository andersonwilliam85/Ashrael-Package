-- Regex Triggers:
-- ^spellup(?:\s+(--debug))?$

-- Check if --debug flag is passed and set in State
AshraelPackage.AdventureMode.State.DebugMode = matches[2] ~= nil

-- Call RequestSpellup without passing debugEnabled
AshraelPackage.AdventureMode.Managers.SpellupManager.RequestSpellup()
