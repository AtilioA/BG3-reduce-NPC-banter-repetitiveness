-- Adapted from FocusBG3: https://www.nexusmods.com/baldursgate3/mods/5972

---@param object any
---@return EntityHandle | nil
function GetHolder(object)
    local entity = GetEntity(object)
    if entity ~= nil and entity.InventoryMember ~= nil then
        return entity.InventoryMember.Inventory.InventoryIsOwned.Owner
    end

    return nil
end

---@param object any
---@return EntityHandle | nil
function GetEntity(object)
    return GetCharacter(object) or GetItem(object)
end

function IsCharacter(object)
    local objectType = type(object)
    if objectType == "userdata" then
        local mt = getmetatable(object)
        local userdataType = Ext.Types.GetObjectType(object)
        if mt == "EntityProxy" and object.IsCharacter ~= nil then
            return true
        elseif userdataType == "esv::CharacterComponent"
            or userdataType == "ecl::CharacterComponent"
            or userdataType == "esv::Character"
            or userdataType == "ecl::Character" then
            return true
        end
    elseif objectType == "string" or objectType == "number" then
        local entity = Ext.Entity.Get(object)
        return entity ~= nil and entity.IsCharacter ~= nil
    end
    return false
end

function GetCharacter(object)
    local objectType = type(object)
    if objectType == "userdata" then
        local mt = getmetatable(object)
        local userdataType = Ext.Types.GetObjectType(object)
        if mt == "EntityProxy" and object.IsCharacter ~= nil then
            return object
        elseif userdataType == "esv::CharacterComponent" or userdataType == "ecl::CharacterComponent" then
            return object.Character.MyHandle
        elseif userdataType == "esv::Character" or userdataType == "ecl::Character" then
            return object.MyHandle
        end
    elseif objectType == "string" or objectType == "number" then
        local entity = Ext.Entity.Get(object)
        if entity ~= nil and IsCharacter(entity) then
            return entity
        end
    end
end

function GetCharacterObject(object)
    local entity = GetCharacter(object)
    if entity ~= nil then
        return entity.ServerCharacter
    end
end

function IsItem(object)
    local objectType = type(object)
    if objectType == "userdata" then
        local mt = getmetatable(object)
        local userdataType = Ext.Types.GetObjectType(object)
        if mt == "EntityProxy" and object.IsItem ~= nil then
            return true
        elseif userdataType == "esv::ItemComponent"
            or userdataType == "ecl::ItemComponent"
            or userdataType == "esv::Item"
            or userdataType == "ecl::Item" then
            return true
        end
    elseif objectType == "string" or objectType == "number" then
        local entity = Ext.Entity.Get(object)
        return entity ~= nil and entity.IsItem ~= nil
    end
    return false
end

function GetItem(object)
    local objectType = type(object)
    if objectType == "userdata" then
        local userdataType = Ext.Types.GetObjectType(object)
        local mt = getmetatable(object)
        if mt == "EntityProxy" and object.IsItem ~= nil then
            return object
        elseif userdataType == "esv::ItemComponent" or userdataType == "ecl::ItemComponent" then
            return object.Item.MyHandle
        elseif userdataType == "esv::Item" or userdataType == "ecl::Item" then
            return object.MyHandle
        elseif userdataType == "CDivinityStats_Item" then
            return object.GameObject
        end
    elseif objectType == "string" or objectType == "number" then
        local entity = Ext.Entity.Get(object)
        if entity ~= nil and IsItem(object) then
            return entity
        end
    end
end

function GetItemObject(object)
    local entity = GetItem(object)
    if entity ~= nil then
        return entity.ServerItem
    end
end

function GetObject(object)
    return GetCharacterObject(object) or GetItemObject(object)
end
