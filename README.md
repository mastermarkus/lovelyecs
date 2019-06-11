# lovely-ecs

# What is lovely-ecs?

**lovely-ecs** is simple to use entity component system for Lua scripting language. Have you tried to find easy to use Lua ECS library that doesn't force you to install some third party libraries, isn't already tied to some other framework or isn't lacking some essential features. Well, **lovely-ecs** is the answer. lovely-ecs is single file library that works with Lua 5.1 and up.

## Basic overview
**lovely-ecs** has 4 main types: Entities, Worlds, Systems and Prefabs. Both Worlds and Entities are just simple integer numbers, Systems that are simply functions and finally Prefabs that are just group of components. We will look into it more down below how it all works and comes togheter to give you better idea.


### Entity
Entity is just collection of components and to access these components lovely-ecs gives you unique id when you create new entity. On top of that lovely-ecs gives you 4 powerful iterator functions that systems could use to iterate over entities with specfic components.


### World
World is container where entities live and die, but also where systems act and interact on with entities.


### System
In lovely-ecs system is just simple LUA function, there's nothing special about systems they are not built into the library, which make's it much more flexible. Don't worry if you didn't understad, we have few good examples down below.


### Prefab
Prefab allow you to group togheter different components, that could be added to entity.


### Iterators
Iterators are brains of the library. They are all knowing and know exactly which entities have specific components and which don't. There are 4 iterators: withNeither(), withOnly(), withAll() and withAny().

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
  "health" = 100;
  "speed" = {x=50,y=50};
  "sprite"= "player.png"
})

local world = ecs.newWorld()
--we can pass prefab directly to ecs.newEntity as second argument or add it later
local player = ecs.newEntity(world, "player_prefab")
ecs.addPrefab(world, player, "player_prefab")
```

### Now that we have covered the basics, let's make this all work togheter
```lua
local ecs = require("lovelyecs")
--prefab has to be registered before adding it to entity
ecs.registerPrefab("player_prefab", {
  health = 100;
  speed = {x=50,y=50};
  sprite= "player.png";
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
