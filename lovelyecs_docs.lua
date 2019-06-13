
--This file is used to generate HTML documentation using LDoc https://github.com/stevedonovan/LDoc

--- Entity component system for Lua scripting language.
-- @module lovelyecs.lua
-- @author Markus Septer
-- @copyright 2019
-- @license MIT

local lovelyecs = {}


-- WORLD FUNCTIONS
----------------------------------


--- World functions
-- @section World

--- Creates new world and returns it's id.
-- @return world_id
function lovelyecs.newWorld()
end

--- Creates new entity into specified world and returns it's id.
-- @param world_id
-- @param optional_prefab_name
-- @return entity_id
function lovelyecs.newEntity()
end

--- Removes entity entity from world and returns it's id.
-- @param world_id
-- @param entity_id
-- @return entity_id
function lovelyecs.removeEntity()
end

---Removes all entities from given world.
-- @param world_id
function lovelyecs.removeAllEntities()
end

--- Returns number of entities in given world.
-- @param world_id
function lovelyecs.getEntityCount()
end

--- Retuns the number of world's that exist.
function lovelyecs.getWorldCount()
end





--ENTITY FUNCTIONS
----------------------------

--- Entity functions
-- @section Entity

--- Adds component to entity, if it didn't exist previously.
-- @param world_id
-- @param entity_id
-- @param name
-- @param value
function lovelyecs.addComponent()
end


--- Changes existing component value.
-- @param world_id
-- @param entity_id
-- @param name
-- @param value
function lovelyecs.changeComponent()
end


--- If component doesn't exist creates it with specified value.
-- @param world_id
-- @param entity_id
-- @param name
-- @param value
function lovelyecs.setComponent()
end


--- Returns component value.
-- @param world_id
-- @param entity_id
-- @param component_name
function lovelyecs.getComponent()
end

--- Returns multiple component values.
-- @param world_id
-- @param entity_id
-- @param component_table
function lovelyecs.getComponents()
end

--- Removes component from entity.
-- @param world_id
-- @param entity_id
-- @param name
function lovelyecs.removeComponent()
end

--- Removes all components from entity.
-- @param world_id
-- @param entity_id
function lovelyecs.removeAllComponents()
end





--COMPONENT FUNCTIONS
-------------------------------

--- Component functions
-- @section Component

-- @param world_id
-- @param entity_id
-- @param component_name
-- @param value
function lovelyecs.setComponent()
end







--PREFAB FUNCTIONS
------------------------------

--- Prefab functions
-- @section Prefab

--- Packs components into prefab
-- @param prefab_name
-- @param table_of_components
function lovelyecs.registerPrefab()
end

--- Adds prefab with packed components to entity.
-- @param world_id
-- @param entity_id
-- @param prefab_name
-- @param is_forceful
function lovelyecs.addPrefab()
end







--QUERY FUNCTIONS
-------------------------------------

--- Query functions
-- @section Query

--- Returns entities with neither components
-- @param world_id
-- @param entity_id
-- @param filter
-- @param return_components
function lovelyecs.withNeither()
end

--- Returns entities with only components
-- @param world_id
-- @param entity_id
-- @param filter
-- @param return_components
function lovelyecs.withOnly()
end

--- Returns entities with all components
-- @param world_id
-- @param entity_id
-- @param filter
-- @param return_components
function lovelyecs.withAll()
end

--- Returns entities with any components
-- @param world_id
-- @param entity_id
-- @param filter
-- @param return_components
function lovelyecs.withAny()
end







--  VALIDATION FUNCTIONS
---------------------------------------

--- Validation functions
-- @section Validation



--- Has neither components.
-- @param world_id
-- @param entity_id
-- @param components_table
-- @return true or false
function lovelyecs.hasNeitherComponents()
end

--- Has only components.
-- @param world_id
-- @param entity_id
-- @param components_table
-- @return true or false
function lovelyecs.hasOnlyComponents()
end

--- Has all components.
-- @param world_id
-- @param entity_id
-- @param components_table
-- @return true or false
function lovelyecs.hasAllComponents()
end

--- Has any components.
-- @param world_id
-- @param entity_id
-- @param components_table
-- @return true or false
function lovelyecs.hasAnyComponents()
end



--STORAGE FUNCTIONS
------------------------

--- Storage functions
-- @section Storage

---NOTE: use with caution, used mostly for testing purposes.
function lovelyecs.eraseStorage()
end