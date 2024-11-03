-- Regex Triggers:
-- This ground is cursed, you cannot seek Sanctum!
-- No way!  You are still fighting!
-- The Sanctum
-- You need to stand up to recall!
-- You can't do that in your sleep.
-- ^You flee .*! What a COWARD!

local Recall = AshraelPackage.AdventureMode.Recall
local Utils = AshraelPackage.AdventureMode.Utils

if line:find("This ground is cursed, you cannot seek Sanctum!") then
    Recall.RecallStatus = "cursed"
    Utils.DebugPrint("Trigger detected curse. Resuming TryRecallCoroutine.")  -- Replaced with DebugPrint
    coroutine.resume(Recall.TryRecallCoroutine)
elseif line:find("No way!  You are still fighting!") then
    Recall.RecallStatus = "fighting"
    Utils.DebugPrint("Trigger detected fighting. Resuming TryRecallCoroutine.")  -- Replaced with DebugPrint
    coroutine.resume(Recall.TryRecallCoroutine)
elseif line:find("You need to stand up to recall!") then
    Recall.RecallStatus = "sleeping"
    Utils.DebugPrint("Trigger detected sleeping. Resuming TryRecallCoroutine.")  -- Replaced with DebugPrint
    coroutine.resume(Recall.TryRecallCoroutine)
elseif line:find("You can't do that in your sleep.") then
    Recall.RecallStatus = "sleeping"
    Utils.DebugPrint("Trigger detected sleeping. Resuming TryRecallCoroutine.")  -- Replaced with DebugPrint
    coroutine.resume(Recall.TryRecallCoroutine)
elseif line:find("The Sanctum") then
    Recall.RecallStatus = "at_sanctum"
    Utils.DebugPrint("Trigger detected arrival at Sanctum. Resuming TryRecallCoroutine.")  -- Replaced with DebugPrint
    coroutine.resume(Recall.TryRecallCoroutine)
elseif line:match("^You flee .*! What a COWARD!") then
    Recall.RecallStatus = "safe"
    Utils.DebugPrint("Trigger detected safe status after fleeing. Resuming TryRecallCoroutine.")  -- Replaced with DebugPrint
    coroutine.resume(Recall.TryRecallCoroutine)
end
