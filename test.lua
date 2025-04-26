require "lib.lib"

local T = Mat2(2,2,2,2)
local points = Vector({Vec2(1,0), Vec2(0,1), Vec2(-1,0), Vec2(0,-1)})

print(is_class(T))
print(points * points:to_vec3())