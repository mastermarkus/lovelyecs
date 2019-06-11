--print("ecs init called")
local lib_root = (...)

local ecs_lib = require(lib_root.. ".lovelyecs")
return ecs_lib