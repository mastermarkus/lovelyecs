local ecs = require("lovelyecs")
local lu = require("luaunit")


TestComponentCount = {}

    --creates entity out of prefab that should have 3 components
    function TestComponentCount:test1()
        ecs.eraseStorage()
        ecs.registerPrefab("npc", {vel = 100; pos = {x=100, y=200};speed = 40;})
        local world = ecs.newWorld()
        local entity = ecs.newEntity(world, "npc")
        lu.assertEquals( ecs.getComponentCount(world, entity), 3)
    end


    --create empty entity and then add's prefab tht contains 3 components
    function TestComponentCount:test2()
        ecs.eraseStorage()
        ecs.registerPrefab("npc", {vel = 100; pos = {x=100, y=200};speed = 40;})
        local world = ecs.newWorld()
        local entity = ecs.newEntity(world)
        ecs.addPrefab(world, entity, "npc")
        lu.assertEquals( ecs.getComponentCount(world, entity), 3)
    end


    --creates empty entity and then add's prefab that contains 3 components two times over
    function TestComponentCount:test3()
        ecs.eraseStorage()
        ecs.registerPrefab("npc", {vel = 100; pos = {x=100, y=200};speed = 40;})
        local world = ecs.newWorld()
        local entity = ecs.newEntity(world)
        ecs.addPrefab(world, entity, "npc")
        ecs.addPrefab(world, entity, "npc", true)
        lu.assertEquals( ecs.getComponentCount(world, entity), 3)
    end


    --component count after removing entity
    function TestComponentCount:test4()
        ecs.eraseStorage()
        ecs.registerPrefab("npc", {vel = 100; pos = {x=100, y=200}; speed = 40;})
        local world = ecs.newWorld()
        local entity = ecs.newEntity(world)
        ecs.removeEntity(world, entity)
        --error_status should be false, which means it threw error
        local error_status = pcall(ecs.getComponentCount, world, entity)
        lu.assertEquals(error_status, false)
    end


    --component count after removeAllComponents()
    function TestComponentCount:test5()
        ecs.eraseStorage()
        ecs.registerPrefab("npc", {vel = 100; pos = {x=100, y=200};speed = 40;})
        local world = ecs.newWorld()
        local entity = ecs.newEntity(world)
        ecs.addPrefab(world, entity, "npc")
        ecs.removeAllComponents(world, entity)
        lu.assertEquals( ecs.getComponentCount(world, entity), 0)
    end

    --componentcount after adding sinlge component
    function TestComponentCount:test6()
        ecs.eraseStorage()
        ecs.registerPrefab("npc", {vel = 100; pos = {x=100, y=200};speed = 40;})
        local world = ecs.newWorld()
        local entity = ecs.newEntity(world)
        ecs.addComponent(world, entity, "speed", 365)
        lu.assertEquals( ecs.getComponentCount(world, entity), 1)
    end

    --component count of entity with no components
    function TestComponentCount:test7()
        ecs.eraseStorage()
        local world = ecs.newWorld()
        local entity = ecs.newEntity(world)
        lu.assertEquals( ecs.getComponentCount(world, entity), 0)
    end

TestGetComponent = {}

    --make sure ecs.getComponent() works and entities have these components
    function TestGetComponent:test1()
        ecs.eraseStorage()
        local world = ecs.newWorld()
        local prefabs = {
            [1] = {firstname = "mark", lastname = "zuck", age = 33},
            [2] = {class = "apache", speed = 365, hovering = true},
            [3] = {animal = true, attacking = false, cute = true, lastname = "no-name"},
            [4] = {lastname = "berg", cute = true}
        }
    
        ecs.registerPrefab("e1", prefabs[1])
        ecs.registerPrefab("e2", prefabs[2])
        ecs.registerPrefab("e3", prefabs[3])
        ecs.registerPrefab("e4", prefabs[4])
    
        local e1 = ecs.newEntity(world, "e1")
        local e2 = ecs.newEntity(world, "e2")
        local e3 = ecs.newEntity(world, "e3")
        local e4 = ecs.newEntity(world, "e4")
    
        lu.assertEquals(ecs.getComponentCount(world, e1), 3)
        lu.assertEquals(ecs.getComponentCount(world, e2), 3)
        lu.assertEquals(ecs.getComponentCount(world, e3), 4)
        lu.assertEquals(ecs.getComponentCount(world, e4), 2)
    
        --e1
        lu.assertNotNil(ecs.getComponent(world, e1, "firstname"), true)
        lu.assertNotNil(ecs.getComponent(world, e1, "lastname"), true)
        lu.assertNotNil(ecs.getComponent(world, e1, "age"), true)
    
        --e2
        lu.assertNotNil(ecs.getComponent(world, e2, "class"), true)
        lu.assertNotNil(ecs.getComponent(world, e2, "speed"), true)
        lu.assertNotNil(ecs.getComponent(world, e2, "hovering"), true)
    
        --e3
        lu.assertNotNil(ecs.getComponent(world, e3, "animal"), true)
        lu.assertNotNil(ecs.getComponent(world, e3, "attacking"), true)
        lu.assertNotNil(ecs.getComponent(world, e3, "cute"), true)
        lu.assertNotNil(ecs.getComponent(world, e3, "lastname"), true)
    
        --e4
        lu.assertNotNil(ecs.getComponent(world, e4, "lastname"), true)
        lu.assertNotNil(ecs.getComponent(world, e4, "cute"), true)
    end


TestHasComponent = {}

    function TestHasComponent:test1()
        ecs.eraseStorage()
        local world = ecs.newWorld()
        local prefabs = {
            [1] = {firstname = "mark", lastname = "zuck", age = 33},
            [2] = {class = "apache", speed = 365, hovering = true},
            [3] = {animal = true, attacking = false, cute = true, lastname = "no-name"},
            [4] = {lastname = "berg", cute = true}
        }
    
        ecs.registerPrefab("e1", prefabs[1])
        ecs.registerPrefab("e2", prefabs[2])
        ecs.registerPrefab("e3", prefabs[3])
        ecs.registerPrefab("e4", prefabs[4])
    
        local e1 = ecs.newEntity(world, "e1")
        local e2 = ecs.newEntity(world, "e2")
        local e3 = ecs.newEntity(world, "e3")
        local e4 = ecs.newEntity(world, "e4")
    
        lu.assertEquals(ecs.getComponentCount(world, e1) ,3)
        lu.assertEquals(ecs.getComponentCount(world, e2) ,3)
        lu.assertEquals(ecs.getComponentCount(world, e3) ,4)
        lu.assertEquals(ecs.getComponentCount(world, e4) ,2)
    
        --e1
        lu.assertTrue(ecs.hasComponent(world, e1, "firstname"), true)
        lu.assertTrue(ecs.hasComponent(world, e1, "lastname"), true)
        lu.assertTrue(ecs.hasComponent(world, e1, "age"), true)
    
        --e2
        lu.assertTrue(ecs.hasComponent(world, e2, "class"), true)
        lu.assertTrue(ecs.hasComponent(world, e2, "speed"), true)
        lu.assertTrue(ecs.hasComponent(world, e2, "hovering"), true)
    
        --e3
        lu.assertTrue(ecs.hasComponent(world, e3, "animal"), true)
        lu.assertTrue(ecs.hasComponent(world, e3, "attacking"), true)
        lu.assertTrue(ecs.hasComponent(world, e3, "cute"), true)
        lu.assertTrue(ecs.hasComponent(world, e3, "lastname"), true)
    
        --e4
        lu.assertNotNil(ecs.hasComponent(world, e4, "lastname"), true)
        lu.assertNotNil(ecs.hasComponent(world, e4, "cute"), true)
    end


    Test_NoReturnIterators = {}


    function Test_NoReturnIterators:test_withNeither()
        ecs.eraseStorage()
    
        local world = ecs.newWorld()
        local prefabs = {
            [1] = {firstname = "mark", lastname = "zuck", age = 33},
            [2] = {class = "apache", speed = 365, hovering = true},
            [3] = {animal = true, attacking = false, cute = true, lastname = "no-name"},
            [4] = {lastname = "berg", cute = true}
        }
    
        ecs.registerPrefab("e1", prefabs[1])
        ecs.registerPrefab("e2", prefabs[2])
        ecs.registerPrefab("e3", prefabs[3])
        ecs.registerPrefab("e4", prefabs[4])
    
        local e1 = ecs.newEntity(world, "e1")
        local e2 = ecs.newEntity(world, "e2")
        local e3 = ecs.newEntity(world, "e3")
        local e4 = ecs.newEntity(world, "e4")
    
        local iterations = 0
        local entities_with = {}
    
        for entity_id in ecs.withNeither(world, {"cute", "lastname"}) do
            entities_with[entity_id] = entity_id
            iterations = iterations + 1
        end
    
        --1 entities with these components, it should iterate 1x
        lu.assertEquals(iterations, 1)
    
        lu.assertEquals(entities_with[1], nil)
        lu.assertEquals(entities_with[2], 2)
        lu.assertEquals(entities_with[3], nil)
        lu.assertEquals(entities_with[4], nil)
    end
    
    
    --ecs.withOnly
    function Test_NoReturnIterators:test_withOnly()
        ecs.eraseStorage()
    
        local world = ecs.newWorld()
        local prefabs = {
            [1] = {firstname = "mark", lastname = "zuck", age = 33},
            [2] = {class = "apache", speed = 365, hovering = true},
            [3] = {animal = true, attacking = false, cute = true}
        }
    
        ecs.registerPrefab("e1", prefabs[1])
        ecs.registerPrefab("e2", prefabs[2])
        ecs.registerPrefab("e3", prefabs[3])
    
        local e1 = ecs.newEntity(world, "e1")
        local e2 = ecs.newEntity(world, "e2")
        local e3 = ecs.newEntity(world, "e3")
    
        local iterations = 0
        for entity_id in ecs.withOnly(world, {"class", "speed", "hovering"}) do
            lu.assertEquals(entity_id, 2)
            iterations = iterations + 1
        end
        --since there only one entity with these components, it should iterate once
        lu.assertEquals(iterations, 1)
    end
    
    
    function Test_NoReturnIterators:test_withAll()
        ecs.eraseStorage()
    
        local world = ecs.newWorld()
        local prefabs = {
            [1] = {firstname = "mark", lastname = "zuck", age = 33},
            [2] = {class = "apache", speed = 365, hovering = true},
            [3] = {animal = true, attacking = false, cute = true, lastname = "no-name"},
            [4] = {lastname = "berg", cute = true}
        }
    
        ecs.registerPrefab("e1", prefabs[1])
        ecs.registerPrefab("e2", prefabs[2])
        ecs.registerPrefab("e3", prefabs[3])
        ecs.registerPrefab("e4", prefabs[4])
    
        local e1 = ecs.newEntity(world, "e1")
        local e2 = ecs.newEntity(world, "e2")
        local e3 = ecs.newEntity(world, "e3")
        local e4 = ecs.newEntity(world, "e4")
    
        local iterations = 0
        local entities_with = {}
    
        for entity_id in ecs.withAll(world, {"cute", "lastname"}) do
            entities_with[entity_id] = entity_id
            iterations = iterations + 1
        end
    
        --2 entities with these components, it should iterate 2x
        lu.assertEquals(iterations, 2)
    
        lu.assertEquals(entities_with[1], nil)
        lu.assertEquals(entities_with[2], nil)
        lu.assertEquals(entities_with[3], 3)
        lu.assertEquals(entities_with[4], 4)
    end
    
    
    function Test_NoReturnIterators:test_withAny()
        ecs.eraseStorage()
    
        local world = ecs.newWorld()
        local prefabs = {
            [1] = {firstname = "mark", lastname = "zuck", age = 33},
            [2] = {class = "apache", speed = 365, hovering = true},
            [3] = {animal = true, attacking = false, cute = true, lastname = "no-name"},
            [4] = {lastname = "berg", cute = true}
        }
    
        ecs.registerPrefab("e1", prefabs[1])
        ecs.registerPrefab("e2", prefabs[2])
        ecs.registerPrefab("e3", prefabs[3])
        ecs.registerPrefab("e4", prefabs[4])
    
        local e1 = ecs.newEntity(world, "e1")
        local e2 = ecs.newEntity(world, "e2")
        local e3 = ecs.newEntity(world, "e3")
        local e4 = ecs.newEntity(world, "e4")
    
        local iterations = 0
        local entities_with = {}
    
        for entity_id in ecs.withAny(world, {"class", "cute", "lastname"}) do
            entities_with[entity_id] = entity_id
            iterations = iterations + 1
        end
    
        --4 entities with these components, it should iterate 4x
        lu.assertEquals(iterations, 4)
    
        lu.assertEquals(entities_with[1], 1)
        lu.assertEquals(entities_with[2], 2)
        lu.assertEquals(entities_with[3], 3)
        lu.assertEquals(entities_with[4], 4)
    end

Test_ReturnIterators = {}

    --NOTE: ecs.withNeither() doesn't return component's, no need to test it
    
    --ecs.withOnly
    function Test_ReturnIterators:test_withOnly()
        ecs.eraseStorage()
    
        local world = ecs.newWorld()
        local prefabs = {
            [1] = {firstname = "mark", lastname = "zuck", age = 33},
            [2] = {class = "apache", speed = 365, hovering = true},
            [3] = {animal = true, attacking = false, cute = true}
        }
    
        ecs.registerPrefab("e1", prefabs[1])
        ecs.registerPrefab("e2", prefabs[2])
        ecs.registerPrefab("e3", prefabs[3])
    
        local e1 = ecs.newEntity(world, "e1")
        local e2 = ecs.newEntity(world, "e2")
        local e3 = ecs.newEntity(world, "e3")
    
        local iterations = 0
        for entity_id, class, speed, hovering in ecs.withOnly(world, {"class", "speed", "hovering"}, true) do
            lu.assertEquals(entity_id, 2)
            lu.assertEquals(class, "apache")
            lu.assertEquals(speed, 365)
            lu.assertEquals(hovering, true)
            iterations = iterations + 1
        end
        --since there only one entity with these components, it should iterate once
        lu.assertEquals(iterations, 1)
    end
    
    
    function Test_ReturnIterators:test_withAll()
        ecs.eraseStorage()
    
        local world = ecs.newWorld()
        local prefabs = {
            [1] = {firstname = "mark", lastname = "zuck", age = 33},
            [2] = {class = "apache", speed = 365, hovering = true},
            [3] = {animal = true, attacking = false, cute = true, lastname = "no-name"},
            [4] = {lastname = "berg", cute = false}
        }
    
        ecs.registerPrefab("e1", prefabs[1])
        ecs.registerPrefab("e2", prefabs[2])
        ecs.registerPrefab("e3", prefabs[3])
        ecs.registerPrefab("e4", prefabs[4])
    
        local e1 = ecs.newEntity(world, "e1")
        local e2 = ecs.newEntity(world, "e2")
        local e3 = ecs.newEntity(world, "e3")
        local e4 = ecs.newEntity(world, "e4")
    
        local iterations = 0
        local entities_with = {}
    
        for entity_id, cute, lastname in ecs.withAll(world, {"cute", "lastname"}, true) do
            entities_with[entity_id] = entity_id
            iterations = iterations + 1
            if entity_id == 3 then
                lu.assertEquals(cute, true)
                lu.assertEquals(lastname, "no-name")
            elseif entity_id == 4 then
                lu.assertEquals(cute, false)
                lu.assertEquals(lastname, "berg")
            end
        end
        --2 entities with these components, it should iterate 2x
        lu.assertEquals(iterations, 2)
    
        lu.assertEquals(entities_with[1], nil)
        lu.assertEquals(entities_with[2], nil)
        lu.assertEquals(entities_with[3], 3)
        lu.assertEquals(entities_with[4], 4)
    end
    
    
    function Test_ReturnIterators:test_withAny()
        ecs.eraseStorage()
    
        local world = ecs.newWorld()
        local prefabs = {
            [1] = {firstname = "mark", lastname = "zuck", age = 33},
            [2] = {class = "apache", speed = 365, hovering = true},
            [3] = {animal = true, attacking = false, cute = true, lastname = "no-name"},
            [4] = {lastname = "berg", cute = true}
        }
    
        ecs.registerPrefab("e1", prefabs[1])
        ecs.registerPrefab("e2", prefabs[2])
        ecs.registerPrefab("e3", prefabs[3])
        ecs.registerPrefab("e4", prefabs[4])
    
        local e1 = ecs.newEntity(world, "e1")
        local e2 = ecs.newEntity(world, "e2")
        local e3 = ecs.newEntity(world, "e3")
        local e4 = ecs.newEntity(world, "e4")
    
        local iterations = 0
        local entities_with = {}
    
        for entity_id in ecs.withAny(world, {"class", "cute", "lastname"}, true) do
            entities_with[entity_id] = entity_id
            iterations = iterations + 1
        end
    
        --4 entities with these components, it should iterate 4x
        lu.assertEquals(iterations, 4)
    
        lu.assertEquals(entities_with[1], 1)
        lu.assertEquals(entities_with[2], 2)
        lu.assertEquals(entities_with[3], 3)
        lu.assertEquals(entities_with[4], 4)
    end
    
Test_EntityIdReuse = {} 

    function Test_EntityIdReuse:test1()
        ecs.eraseStorage()
        local world = ecs.newWorld()
        local e1 = ecs.newEntity(world)
        lu.assertEquals(e1, 1)
        ecs.removeEntity(world, e1)
        local e1 = ecs.newEntity(world)
        lu.assertEquals(e1, 1)
        local e2 = ecs.newEntity(world)
        lu.assertEquals(e2, 2)
    end


    function Test_EntityIdReuse:test2()
        ecs.eraseStorage()
        local world = ecs.newWorld()
        local num_of_entities_to_create = 100
        local num_of_entities_to_remove = 99

        for i = 1, num_of_entities_to_create do
            ecs.newEntity(world)
        end

        lu.assertEquals(ecs.getEntityCount(world), num_of_entities_to_create)

        for entity_id = 1, num_of_entities_to_remove do
            ecs.removeEntity(world, entity_id)
        end

        --there should be 1 entity remaining
        lu.assertEquals(ecs.getEntityCount(world), 1)
    end

Test_getWorlCount = {}

    function Test_getWorlCount:test()
        ecs.eraseStorage()
        local w1 = ecs.newWorld()
        lu.assertEquals(ecs.getWorldCount(), 1)
        local w2 = ecs.newWorld()
        lu.assertEquals(ecs.getWorldCount(), 2)

        ecs.destroyWorld(w1)
        lu.assertEquals(ecs.getWorldCount(), 1)
        ecs.destroyWorld(w2)
        lu.assertEquals(ecs.getWorldCount(), 0)
    end

    function Test_getWorlCount:test2()
        ecs.eraseStorage()
        local num_of_worlds_to_create = 100
        local num_of_worlds_to_destroy = 99

        for i = 1, num_of_worlds_to_create do
            ecs.newWorld()
        end

        lu.assertEquals(ecs.getWorldCount(), 100)

        for world_id = 1, num_of_worlds_to_destroy do
            ecs.destroyWorld(world_id)
        end

        lu.assertEquals(ecs.getWorldCount(), 1)
    end

local Test_removeAllEntities = {}
    function Test_removeAllEntities:test1()
        ecs.eraseStorage()
        local num_of_entities_to_create = 69
        local world = ecs.newWorld()

        for entity_id = 1, num_of_entities_to_create do
            ecs.newEntity(world)
        end
        lu.assertEquals(ecs.getEntityCount(), 69)
        ecs.removeAllEntities(world)
        lu.assertEquals(ecs.getEntityCount(), 0)
    end

local runner = lu.LuaUnit.new()
runner:setOutputType("tap")
os.exit( runner:runSuite() )