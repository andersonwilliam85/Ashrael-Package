-- Regex Triggers:
-- ^(resume|recover)$

-- Check if the first capture is "resume" or "recover"
if matches[2] == "resume" then
    AshraelPackage.AdventureMode.ResumeAdventure()
elseif matches[2] == "recover" then
    AshraelPackage.AdventureMode.Recover()
end
