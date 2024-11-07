local CharactersDA = AshraelPackage.VoidWalker.DataAccessors.CharactersDA or {}
local VoidWalkerDB = AshraelPackage.VoidWalker.Databases.VoidWalkerDB

-- Helper function to format names in proper case
local function properCase(name)
    return name:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)
end

function CharactersDA.AddCharacter(character)
    local success, err = db:add(VoidWalkerDB.characters, {
        name = character.name,
        health = character.health or 0,
        mana = character.mana or 0,
        movement = character.movement or 0,
        tnl = character.tnl or 0,
        last_location = character.last_location or "Unknown",
        is_registered = character.is_registered and 1 or 0,  -- Store as integer
        is_active = character.is_active and 1 or 0,
        password = character.password or ""
    })
    
    -- Log and return error if insertion fails
    if not success then
        cecho(string.format("<red>Error adding character to database: %s\n", err))
    else
        cecho(string.format("<green>Character %s successfully added to the database.\n", character.name))
    end
    
    return success, err
end


-- **Get Character**
function CharactersDA.GetCharacter(name)
    name = properCase(name)
    local result = db:fetch(VoidWalkerDB.characters, db:eq(VoidWalkerDB.characters.name, name))
    if #result > 0 then
        local character = result[1]
        character.is_registered = character.is_registered == 1  -- Convert to boolean
        return character
    end
    return nil
end

-- **Get All Characters**
function CharactersDA.GetAllCharacters()
    local characters = {}
    local results = db:fetch(VoidWalkerDB.characters)
    for _, char in ipairs(results) do
        char.is_registered = char.is_registered == 1  -- Convert to boolean
        table.insert(characters, char)
    end
    return characters
end

-- **Retrieve the Currently Active Character**
function CharactersDA.GetActiveCharacter()
    -- Fetch the character with 'is_active' set to 1
    local activeCharacter = db:fetch(VoidWalkerDB.characters, db:eq(VoidWalkerDB.characters.is_active, 1))
    
    if #activeCharacter > 0 then
        -- Assuming only one active character, return the first result
        return activeCharacter[1]
    else
        return nil
    end
end


-- **Update Character**
function CharactersDA.UpdateCharacter(character)
    local data = db:fetch(VoidWalkerDB.characters, db:eq(VoidWalkerDB.characters.name, character.name))
    if #data > 0 then
        local updatedData = data[1]
        updatedData.health = character.health
        updatedData.mana = character.mana
        updatedData.movement = character.movement
        updatedData.tnl = character.tnl
        updatedData.last_location = character.last_location
        updatedData.is_registered = character.is_registered and 1 or 0  -- Store as integer
        updatedData.password = character.password
        return db:update(VoidWalkerDB.characters, updatedData)
    end
    return nil, "Character not found."
end

function CharactersDA.SetActiveCharacter(name)
    name = properCase(name)

    -- Deactivate all characters
    db:set(VoidWalkerDB.characters.is_active, 0)

    -- Activate only the specified character
    db:set(VoidWalkerDB.characters.is_active, 1, db:eq(VoidWalkerDB.characters.name, name))
end


-- **Delete Character**
function CharactersDA.DeleteCharacter(name)
    local result, err = db:delete(VoidWalkerDB.characters, db:eq(VoidWalkerDB.characters.name, name))
    -- Log the result and error
    debugc(string.format("DeleteCharacter result: %s, error: %s", tostring(result), tostring(err)))
    return result, err
end

AshraelPackage.VoidWalker.DataAccessors.CharactersDA = CharactersDA

return CharactersDA
