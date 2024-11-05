AshraelPackage.AdventureMode.Gear = AshraelPackage.AdventureMode.Gear or {}

local AdventureMode = AshraelPackage.AdventureMode
local Gear = AdventureMode.Gear

function Gear.Equip(gearType)
  if gearType == "mana" then
      -- Equip mana items
      send("put all misc")
      send("remove all")
      send("put all gear")
      send("get all.mana gear")
      send("get 'bracer black managear' gear")
      send("get manawield gear")
      send("put 'unholy shroud' gear")
      send("put skirt gear")
      send("wield manawield")
      send("wear all.mana")
      send("wear all.managear")
  elseif gearType == "tank" then
      -- Equip tank items
      send("put all misc")
      send("remove all")
      send("put all gear")
      send("get all.tank gear")
      send("get 'mana unholy shroud' gear")
      send("get skirt gear")
      send("wear all")
  else
      cecho("\n<red>Invalid gear type. Use either 'mana' or 'tank'.<reset>")
  end
end
