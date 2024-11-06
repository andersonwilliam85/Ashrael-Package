-- Regex Triggers:
-- ^(mana|tank)(equip|eq)$

-- Capture the command from the alias (either "equipmana", "equiptank", "eqmana", or "eqtank")
local equipType = matches[2]  -- matches[2] will be "mana" or "tank"

-- Call the Equip function with the specified gear type
AshraelPackage.AdventureMode.Managers.EquipmentManager.Equip(equipType)
