[![Build Status](https://travis-ci.org/mastermarkus/lovelyecs.png?branch=master)](https://travis-ci.org/mastermarkus/lovelyecs)
![Image description](http://img.shields.io/badge/Licence-MIT-brightgreen.svg)

# lovelyecs

# What is Entity component system in the first place?
If you are new to ECS, take a look at Wikipedia page: https://en.wikipedia.org/wiki/Entity_component_system. If you still didn't understand what it is, i recommend to keep reading and there are code snippets down below. Also there's ***examples/*** folder in the repository.

# What is lovelyecs?

**lovelyecs** is simple to use entity component system for Lua scripting language. Have you tried to find easy to use Lua ECS library that doesn't force you to install some third party libraries, isn't already tied to some other framework or isn't lacking some essential features. Well, **lovelyecs** is the answer. lovelyecs is single file library that works with Lua 5.1 and up.

## Basic overview
**lovelyecs** has 4 main types: Entities, Components, Worlds and Systems.


### Entity
In game Entity could really be anything; Animal, Monster, NPC and also Player controlled by Human or AI. What makes up entity and give's it logic, graphics, physics etc... are components, these are the building block's of entity.


### Components
Component is just variable with value that's part of entity. You are free to create any components with any name and value you like. ***lovelyecs*** also allows you to group components together and create prefabs. Example components: Position, Velocity, Health etc...


### World
World is container where entities live in. You can create multiple worlds.


### System
System is piece of code or function that goes through all the entities in world and components using what's called **Iterator(s)**. System(s) checks entities what components they have and acts accordingly. For example you could have system called ***"player_movement"***. This system would be responsible for getting all the entities with components named ***"keyboard_input"***, ***"position"*** and ***"velocity"*** and moving the player everytime they press some arrow-key on keyboard. Remember you have full control what you want to name your component's, these were just made up component names.


### Iterators
Iterators are functions that give back entities with specific components. There are 4 iterators: ***withNeither()***, ***withOnly()***, ***withAll()*** and ***withAny()***. Looking back at system description, let's say you want to get all entities that have all the following components: ***"position"***, ***"velocity"*** and  ***"keyboard_input"*** you would do something like this:
```lua
local ecs = require("loveleyecs")

--you can add new component to entity with ecs.addComponent()
--let's create prefab, that way we don't have to manually add each component one by one
ecs.registerPrefab("player_prefab", {
  position = {x = 50, y = 50};
  velocity = {x = 0, y = 0};
  keyboard_input = {
      keys_down = {
      arrow_up = false,
      arrow_down = true,
      arrow_left = false,
      arrow_right = false
    }
  }
})

--let's create world where entities live in
local world= ecs.newWorld()

--let's add some entities to world
local entity_1 = ecs.newEntity(world, "player_prefab")
local entity_2 = ecs.newEntity(world, "player_prefab")

--now we created 2 entities that both have: position, velocity and keyboard_input components
--what if we want to change one component a little bit, we can do it using ecs.changeComponent() function
--let's make entity_2 a little bit faster than entity_1
ecs.changeComponent(world, entity_2, "velocity", {x =3200, y = 3300})

--if return_component's is true it's gonna directly return entity_id + (the components) specified in filter
local return_components = true
local filter = {"position", "velocity", "keyboard_input"}

local function movement_system(world_id)
  for entity_id, position, velocity, keyboard_input in ecs.withAll(world_id, filter, return_components) do  
   if true == keyboard_input.keys_down.arrow_down then
    velocity.y = velocity.y + 20}
   end
  end
end

--pseudo game loop code
while gameIsRunning() do
  movement_system(world)
end
```

### Installation
Just clone or download this repository as .zip file and extract the "lovelyecs.lua" file to location you want.

### Documentation can be found here
https://mastermarkus.github.io/lovelyecs/doc/

### Testing
lovelyecs uses [luaunit](https://github.com/bluebird75/luaunit) for testing. To run the tests, download Lua and [luaunit](https://github.com/bluebird75/luaunit), copy or take out the "luaunit.lua" file. Now run the lua command inside you project root folder followed by path to "test_lovelyecs.lua". For example if your project root folder name is "game" and both luaunit.lua and lovelyecs.lua are under folder called "thirdparty", run the following command -> "lua .\thirdparty\lovelyecs\test_lovelyecs.lua"
