

--Author: Markus Septer
--Github: https://github.com/mastermarkus/lovelyecs
-- For bug reports or feature requests go to link above

--- @module lovely-ecs
-- @author Markus Septer
-- @license MIT
-- @copyright 2019

--[[
MIT License

Copyright (c) 2019 mastermarkus

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

--in some lua versions and and some lua frameworks like Löve2D unpack is not in global scope
local _unpack = unpack or nil
if _unpack == nil then _unpack = table.unpack end
if _unpack == nil then error("Can't find unpack() or table.unpack() in Lua standard library! ") end

local str_format = string.format or nil
if str_format == nil then error("Unable to find string.format in lua standard library") end

--since we can't just set entity/world to be reused to nil, cause it creates hole in array, we have to set it to magic key
local REUSABLE_ENTITY = {}
local REUSABLE_WORLD = {}

local worlds = {}
local components = {}
local total_world_count = 0
local active_world_count = 0
local entity_prefabs = {}


--ECS API FUNCTIONS---
local ecs = {}


--UTILITY FUNCTIONS--
local utils_assertf
local utils_worldExists
local utils_ensureWorldExists
local utils_entityExists
local utils_ensureEntityExists
local utils_ensureComponentIsRightType
local utils_prefabExists
local utils_ensureEntityPrefabExists
local utils_incrementTotalEntityCount
local utils_decrementTotalEntityCount
local utils_getTotalEntityCount
local utils_incrementTotalWorldCount
local utils_decrementTotalWorldCount
local utils_getTotalWorldCount


function utils_assertf(condition, error_msg, ...)
    if not condition then
      error(error_msg:format(...))
    end
end


function utils_worldExists(world_id)
    if "number" ~= type(world_id) then error("You must pass in world_id type that's number, but passed in type is " .. type(world_id)) end
    local world_exists = false
    local world = worlds[world_id] or nil
    if world_id > 0 and world_id <= utils_getTotalWorldCount() then
        if "table" == type(world) and REUSABLE_WORLD ~= world then
            world_exists = true
        end
    end
    return world_exists
end


function utils_ensureWorldExists(world_id)
    assert(type(world_id)=="number", 'World must be of type "number"!')
    if not utils_worldExists(world_id) then error( "Trying to index world, that doesn't exist" ) end
end


function utils_entityExists(world_id, entity_id)
    utils_ensureWorldExists(world_id)
    if ( not type(entity_id) == "number" ) then error("Passed in entity must be of type number!") end
    local entity_exists = false
    if entity_id > 0 and entity_id <= utils_getTotalEntityCount(world_id) then
        local entity = worlds[world_id].entities[entity_id]
        if nil ~= entity and "number" == type(entity) then
            entity_exists = true
        end
    end
    return entity_exists
end


function utils_ensureEntityExists(world_id, entity_id, error_msg)
    utils_ensureWorldExists(world_id)
    utils_assertf(utils_entityExists(world_id, entity_id), error_msg, entity_id)
end


function utils_ensureComponentIsRightType(component_name)
    if type(component_name) ~= "string" then
        return false
    else
        return true
    end
end


function utils_prefabExists(prefab_name)
    return (prefab_name ~= nil and entity_prefabs[prefab_name] ~= nil)
end


function utils_ensureEntityPrefabExists(prefab_name, error_msg)
    if not utils_prefabExists(prefab_name) then
        error( type(error_msg) == "string" and error_msg or "Can't find prefab template you specified, did you forget to register it with ecs:registerPrefab() method?" )
    end
end


function utils_incrementTotalEntityCount(world_id)
    worlds[world_id].total_entity_count = 1 + worlds[world_id].total_entity_count
end


function utils_decrementTotalEntityCount(world_id)
    worlds[world_id].total_entity_count = worlds[world_id].total_entity_count - 1
end


function utils_getTotalEntityCount(world_id)
    return worlds[world_id].total_entity_count
end


function utils_incrementTotalWorldCount()
    total_world_count = 1 + total_world_count
end


function utils_decrementTotalWorldCount()
    total_world_count = total_world_count - 1
end


function utils_getTotalWorldCount()
    return total_world_count
end


function ecs.withNeither(world_id, forbidden_components)
utils_ensureWorldExists(world_id)
    local world_entities = worlds[world_id].entities
    local index = 0
    local entities_count = #world_entities
    local iter = function ()
        while index < entities_count do
            index = index + 1
            local entity_id = world_entities[index]
                if ecs.hasNeitherComponents(world_id, entity_id, forbidden_components) then
                    return entity_id
                end
            end
    end
    return iter
end


function ecs.withOnly(world_id, allowed_components, return_components)
    utils_ensureWorldExists(world_id)
    local world_entities = worlds[world_id].entities
    return coroutine.wrap(function()
        for entity_id = 1, #world_entities do
            local entity = world_entities[entity_id]
            if "number" == type(entity) then
                if ecs.hasOnlyComponents(world_id, entity_id, allowed_components) then
                    if return_components then
                         coroutine.yield(entity_id, ecs.getComponents(world_id, entity_id, allowed_components))
                    else
                        coroutine.yield(entity_id)
                    end
                end
            end
        end
    end)
end


function ecs.withAll(world_id, required_components, return_components)
    utils_ensureWorldExists(world_id)
    local world_entities = worlds[world_id].entities
    return coroutine.wrap(function()
        for entity_id = 1, #world_entities do
            local entity = world_entities[entity_id]
            if "number" == type(entity) then
                if ecs.hasAllComponents(world_id, entity_id, required_components) then
                    if return_components then
                         coroutine.yield(entity_id, ecs.getComponents(world_id, entity_id, required_components))
                    else
                        coroutine.yield(entity_id)
                    end
                end
            end
        end
    end)
end


function ecs.withAny(world_id, required_components, return_components)
    utils_ensureWorldExists(world_id)
    if nil == required_components[1] then error("ecs.withAny() requires atleast one component to be specified!") end
    local world_entities = worlds[world_id].entities

    return coroutine.wrap(function()
        for entity_id = 1, #world_entities do
            local entity = world_entities[entity_id]
            if "number" == type(entity) then
                if ecs.hasAnyComponents(world_id, entity_id, required_components) then
                    if return_components then
                        coroutine.yield(entity_id, ecs.getComponents(world_id, entity_id, required_components))
                    else
                        coroutine.yield(entity_id)
                    end
                end
            end
        end
    end)
end


function ecs.addComponent(world_id, entity_id, component_name, component_value)
    utils_ensureEntityExists(world_id, entity_id, "Trying to add component to entity that doesn't exist!")
    if nil == components[world_id]                 then components[world_id] = {}                 end
    if nil == components[world_id][component_name] then components[world_id][component_name] = {} end

    local success

    if not ecs.hasComponent(world_id, entity_id, component_name) then
        components[world_id][component_name][entity_id] = component_value
        worlds[world_id].entities_data.components[entity_id][component_name] = component_value
        worlds[world_id].entities_data.componentCount[entity_id] = 1 + worlds[world_id].entities_data.componentCount[entity_id]
        success = true
    else
        error(str_format("Trying to overwrite already existing component named -> %s!", component_name))
        --if you just want to change value of component use "ecs.setComponent()"
        success = false
    end
    return success
end


function ecs.addPrefab(world_id, entity_id, prefab_name, forceful)
    utils_ensureEntityExists(world_id, entity_id, "Trying to add prefab to entity that doesn't exist!")
    utils_ensureEntityPrefabExists(prefab_name)
    --NOTE: if component is table, for more complex components, deepcopy might be required
    for component_name, component_value in pairs(entity_prefabs[prefab_name]) do
        --print("      "..component_name, component_value)
        --default components that are taken from entity template, that is registered using ecs.registerPrefab()
        if nil == components[world_id]                 then components[world_id] = {}                 end
        if nil == components[world_id][component_name] then components[world_id][component_name] = {} end

        --NOTE: this check has to be done after ensuring componenet fields exist, otherwise ecs.hasComponent() tries to access nil field
        if not ecs.hasComponent(world_id, entity_id, component_name) then
            ecs.addComponent(world_id, entity_id, component_name, component_value)
        --if component already exists make sure that user is aware and want's to override existing component value
        else
            if forceful == nil or false == forceful then
                error( str_format("You are trying to override existing component called %s! Use forceful=true to overide without error!", component_name) )
            end
        end
    end
end


function ecs.setComponent(world_id, entity_id, component_name, component_value)
    utils_ensureEntityExists(world_id, entity_id, "Trying to set component value on entity that doesn't exist!")
    local success = false
    if ecs.hasComponent(world_id, entity_id, component_name) then
        if nil ~= components[world_id][component_name] then
            if nil ~= components[world_id][component_name][entity_id] then
                components[world_id][component_name][entity_id] = component_value
                success = true
            end
        end
    end
    if not success then
        error( str_format("Trying to set value to component named %s, that doesn't exist!", component_name))
    end
end


function ecs.hasComponent(world_id, entity_id, component_name)
    utils_assertf(utils_ensureComponentIsRightType(component_name), "Component type must be string but is type of %s!", type(component_name))
    return nil ~= ecs.getComponent(world_id, entity_id, component_name)
end


function ecs.hasNeitherComponents(world_id, entity_id, forbidden_components)
    utils_ensureEntityExists(world_id, entity_id)

    local found_components_count = 0

    for _,forbidden_component_name in pairs(forbidden_components) do
        if ecs.hasComponent(world_id, entity_id, forbidden_component_name) then
            found_components_count = found_components_count + 1
        end
    end

    --entity has forbidden components
    if found_components_count > 0 then
        return false
    --entity doesn't have any forbidden components
    else
        return true
    end
end


function ecs.hasOnlyComponents(world_id, entity_id, allowed_components)
    utils_ensureEntityExists(world_id, entity_id, "Trying to check if 'only components' exist on entity that doesn't exist!")
    local entity_component_count = ecs.getComponentCount(world_id, entity_id)
    if ecs.hasAllComponents(world_id, entity_id, allowed_components) and entity_component_count == #allowed_components then
        return true
    else
        return false
    end
end


function ecs.hasAllComponents(world_id, entity_id, required_components)
    utils_ensureEntityExists(world_id, entity_id, "Trying to check if 'all' components exist on entity that doesn't exist!")
    local num_of_found_components = 0

    for i = 1, #required_components do
        local required_component_name = required_components[i]
        if ecs.hasComponent(world_id, entity_id, required_component_name) then
            num_of_found_components = num_of_found_components + 1
        end
    end

    if num_of_found_components == #required_components or nil == required_components[1] then
        return true
    else
        return false
    end
end


function ecs.hasAnyComponents(world_id, entity_id, required_components)
    utils_assertf(utils_entityExists(world_id, entity_id), "Trying to check if non existant entity hasAnyComponents!")

    if nil == required_components[1] then error("ecs.hasAnyComponents() requires atleast one component to be specified!") end

    local num_of_found_components = 0

    for i = 1, #required_components do
        local required_component = required_components[i]
        if ecs.hasComponent(world_id, entity_id, required_component) then
            num_of_found_components = num_of_found_components + 1
        end
    end

    if num_of_found_components >= 1 then
       return true
    else
        return false
    end
end


function ecs.getComponent(world_id, entity_id, component_name)
    utils_assertf(utils_ensureComponentIsRightType(component_name), "Component type must be string but is type of %s!", type(component_name))
    utils_assertf(utils_entityExists(world_id, entity_id), "Trying to get component %s from entity that doesn't exist!", component_name)

    local component = nil
        if nil ~= components[world_id][component_name] then
            if nil ~= components[world_id][component_name][entity_id] then
                component = components[world_id][component_name][entity_id]
            end
        end
    return component
end


function ecs.getComponents(world_id, entity_id, required_components)
    local return_components = {}
    for index, requested_component in pairs(required_components) do
        if ecs.hasComponent(world_id, entity_id, requested_component) then
            return_components[index] = ecs.getComponent(world_id, entity_id, requested_component)
        end
    end
    return _unpack(return_components)
end


function ecs.getComponentCount(world_id, entity_id)
    utils_ensureEntityExists(world_id, entity_id, "Attempting to get component count of entity that doesn't exist!")
    return worlds[world_id].entities_data.componentCount[entity_id]
end


function ecs.removeComponent(world_id, entity_id, component_name)
    utils_assertf(utils_ensureComponentIsRightType(component_name), "ecs.removeComponent() -> component_name must be of type string but is of type %s", type(component_name))
    utils_assertf(utils_entityExists(world_id, entity_id), "Attempting to remove component %s from entity that doesn't exist!", component_name)

    local success = false
    if ecs.hasComponent(world_id, entity_id, component_name) then
        if nil ~= components[world_id][component_name][entity_id] then
            components[world_id][component_name][entity_id] = nil
            success = true
        end
    end

    if success then
        worlds[world_id].entities_data.componentCount[entity_id] = worlds[world_id].entities_data.componentCount[entity_id] - 1
    end
    return success
end


function ecs.removeAllComponents(world_id, entity_id)
    utils_assertf(utils_entityExists(world_id, entity_id), "Trying to remove all components from entity %s that doesn't exist!", entity_id)
    local initial_entity_component_count = ecs.getComponentCount(world_id, entity_id)
    local removed_components_count = 0

    for _, component_array in pairs(worlds[world_id].entities_data.components) do
        for component_name, _ in pairs(component_array) do
            if ecs.hasComponent(world_id, entity_id, component_name) then
                local success = ecs.removeComponent(world_id, entity_id, component_name)
                if success then
                    removed_components_count = removed_components_count + 1
                end
            end
        end
    end

    if initial_entity_component_count == removed_components_count then
        --print("removed all components successfully")
        return true
    else
        return false
    end
end


function ecs.registerPrefab(prefab_name, props)
    if prefab_name == nil then error("Trying to register prefab that doesn't have prefab name specified!") end
    utils_assertf(not (nil ~= entity_prefabs[prefab_name]), "Trying to register prefab named %s, that already exists!", prefab_name)

    entity_prefabs[prefab_name] = {}
    for key, val in pairs(props) do
        --print("REGISTERING_COMPONENT_WITH_VALUE. " ..tostring(val))
        entity_prefabs[prefab_name][key] = val
    end
end


function ecs.newEntity(world_id, prefab_name)
    utils_ensureWorldExists(world_id)
    --prefab_name is optional
    if "string" == type(prefab_name) then
        utils_assertf( utils_prefabExists(prefab_name, "Trying to get entity with prefab named %s, that doesn't exists!(NOTE: use registerPrefab())"), prefab_name)
    end

    local world_entities = worlds[world_id].entities

    local new_entity_id = nil

    --try to find re-usable id first
    for entity_id = 1, utils_getTotalEntityCount(world_id) do
        local entity = world_entities[entity_id]
        if nil ~= entity and entity == REUSABLE_ENTITY then
            new_entity_id = entity_id
            world_entities[entity_id] = entity_id
        end
    end

    --if no re-usable entities available create new one
    if nil == new_entity_id then
        utils_incrementTotalEntityCount(world_id)
        new_entity_id = utils_getTotalEntityCount(world_id)
    end

    worlds[world_id].active_entities_count = 1 + worlds[world_id].active_entities_count
    worlds[world_id].entities[new_entity_id] = new_entity_id
    --print("     COMPONENTS:")
    if nil == worlds[world_id].entities_data.components[new_entity_id] then
        worlds[world_id].entities_data.components[new_entity_id] = {}
    end

    if nil == worlds[world_id].entities_data.componentCount[new_entity_id] then
        worlds[world_id].entities_data.componentCount[new_entity_id] = 0
    end

    if "string" == type(prefab_name) then
        ecs.addPrefab(world_id, new_entity_id, prefab_name)
    end
    return new_entity_id
end


function ecs.newWorld()
    local world = {
        reusable_ids = {},
        total_entity_count = 0,--needs to be "0" if we want first entity to start at "1"
        active_entities_count = 0, -- should start at 0 too
        entities = {},
        entities_data = {
            components = {},
            componentCount = {}
        }
    }
    local new_world_id = nil

    for world_id = 1, #worlds do
        local world_obj = worlds[world_id]
        if "table" == type(world_obj) and REUSABLE_WORLD == world_obj then
            new_world_id = world_id
        end
    end

    if nil == new_world_id  then
        utils_incrementTotalWorldCount()
        new_world_id = utils_getTotalWorldCount()
    end
    active_world_count = 1 + active_world_count
    worlds[new_world_id] = world
    return new_world_id
end


function ecs.getWorldCount()
    return active_world_count
end


function ecs.destroyWorld(world_id)
    utils_assertf( utils_worldExists(world_id), "You are trying to destroy world with id %s, that doesn't exist!", world_id)
    ecs.removeAllEntities(world_id)
    local total_world_count = utils_getTotalWorldCount()
    if world_id == total_world_count and total_world_count > 1 then
        worlds[world_id] = nil
        utils_decrementTotalWorldCount()
    elseif world_id < total_world_count then
        worlds[world_id] = REUSABLE_WORLD
    end

    active_world_count = active_world_count - 1
end


function ecs.getEntityCount(world_id)
    utils_ensureWorldExists(world_id)
    return worlds[world_id].active_entities_count
end


function ecs.removeEntity(world_id, entity_id)
    utils_assertf(utils_entityExists(world_id, entity_id), "Trying to remove entity with id %s that doesn't exist!", entity_id)
    ecs.removeAllComponents(world_id, entity_id)
    local world_entities = worlds[world_id].entities

    if world_entities[entity_id] == REUSABLE_ENTITY then
        error("Entity is marked as RE-USABLE, while it shouldn't be!")
    end

    local world_total_entity_count = utils_getTotalEntityCount(world_id)

    --NOTE: only decrement if it's last entity in array
    if entity_id == world_total_entity_count then
        world_entities[entity_id] = nil
        utils_decrementTotalEntityCount(world_id)
        --we have to mark entity as re-usable, otherwise it would live in hole
    elseif entity_id < world_total_entity_count then
        world_entities[entity_id] = REUSABLE_ENTITY
    end

    worlds[world_id].active_entities_count = worlds[world_id].active_entities_count - 1
    return entity_id
end


function ecs.removeAllEntities(world_id)
    utils_ensureWorldExists(world_id, "Attempting to remove all entities from world, that doesn't exist!")
    local world_entities = worlds[world_id].entities
    for entity_id = 1, #world_entities do
        local entity = world_entities[entity_id]
        if "number" == type(entity) then
           ecs.removeEntity(world_id, entity_id)
        end
    end
end


function ecs.eraseStorage()
    worlds = {}
    components = {}
    total_world_count = 0
    active_world_count = 0
    entity_prefabs = {}
end


return ecs