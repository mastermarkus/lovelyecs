# lovely-ecs

# What is Entity component system in the first place?
If you are new to ECS, take a look at Wikipedia page: https://en.wikipedia.org/wiki/Entity_component_system. If you still didn't understand what it is, i recommend to keep reading and there are code snippets down below. Also there's ***examples/*** folder in the repository.

# What is lovely-ecs?

**lovely-ecs** is simple to use entity component system for Lua scripting language. Have you tried to find easy to use Lua ECS library that doesn't force you to install some third party libraries, isn't already tied to some other framework or isn't lacking some essential features. Well, **lovely-ecs** is the answer. lovely-ecs is single file library that works with Lua 5.1 and up.

## Basic overview
**lovely-ecs** has 4 main types: Entities, Components, Worlds and Systems.


### Entity
In game Entity could really be anything; Animal, Monster, NPC and also Player controlled by Human or AI. What makes up entity and give's it logic, graphics, physics etc... are components, these are the building block's of entity.


### Components
Component is just variable with value that's part of entity. You are free to create any components with any name and value you like. ***lovely-ecs*** also allows you to group components together and create prefabs. Example components: Position, Velocity, Health etc...


### World
World is container where entities live in. You can create multiple worlds.


### System
System is piece of code or function that goes through all the entities in world and components using what's called **Iterator(s)**, it's very important because it's what give's life to your entitity. Systems checks entities what components they have and acts accordingly. For example you could have system called "player_movement", this system would be responsible for getting all the entities with components named "keyboard_input", "position" and "velocity" and moveing the player everytime they press some arrow-key on keyboard. Remember you have full control what you want to name your component's, these were just made up component names.


### Iterators
Iterators are functions that give back entities with specific components There are 4 iterators: ***withNeither()***, ***withOnly()***, ***withAll()*** and ***withAny()***. Looking back at system description, let's say you want to get all entities that have all the following components: ***"position"***, ***"velocity"*** and  ***"keyboard_input"*** you would do something like this:
```lua
local return_components = true
local filter = {"position", "velocity", "keyboard_input"}
for entity_id, position, velocity, keyboard_input in ecs.withAll(world_id, filter, return_components) do
  
end
```

## Few Examples

### Creating Entity and adding components
```lua
local ecs = require("lovelyecs")
local world = ecs.newWorld()
--to create new entity you must have already created world before
local player = ecs.newEntity(world)
ecs.addComponent(world, player, "health", 100)
ecs.addComponent(world, player, "speed", {x=50,y=50})
ecs.addComponent(world, player, "sprite", "player.png")
```

### Now imagine your entity had over 20 or more components, adding all these components manually would be very tedious and time consuming. Luckily there's better way, this is where the prefabs come in.
```lua
local ecs = require("lovelyecs")
--prefab has to be registered before adding it to entity
ecs.registerPrefab("player_prefab", {
  health = 100;
  speed = {x=50,y=50};
  sprite = "player.png"
})

local world = ecs.newWorld()
--we can pass prefab directly to ecs.newEntity as second argument or add it later
local player = ecs.newEntity(world, "player_prefab")
ecs.addPrefab(world, player, "player_prefab")
```

### Now that we have covered the basics, let's make this all work together
```lua
local ecs = require("lovelyecs")
--prefab has to be registered before adding it to entity
ecs.registerPrefab("player_prefab", {
  health = 100;
  speed = {x=50,y=50};
  sprite = "player.png";
  can_move = true
})

--system is just function, i recommend to move each of the systems to different module files
local function movement_system(world_id)
  local return_components = true
  --components get returned in the order, whicht hey were specified in filter table
  for entity_id, speed, can_move in ecs.withAll(world_id, {"speed", "can_move"}, return_components)do
      if speed.x > 30 then
        ecs.setComponent(world_id, entity_id, "can_move", false)
      end
  end
end

local world = ecs.newWorld()
local player = ecs.newEntity(world, "player_prefab")

--this would be your update/render or some other loop or event
for i = 1, 307 do
  movement_system(world)
end
```

### Installation
Just clone or download this repository as .zip file and extract the "lovelyecs.lua" file to location you want.
