do
    local v1 = Vec2(13,25)
    local v2 = v1:clone()

    v2.x = 5

    assert_neq(v1,v2,"Vec2:clone()")
end

do
    local v1 = Vec2(12,math.pi)
    local v2 = v1:to_vec2()

    assert_eq(v1,v2,"Vec2:to_vec2()")
end

do
    local v1 = Vec2(12,math.pi)
    local v2 = v1:to_vec3()
    local v3 = Vec3(12,math.pi,1)

    assert_eq(v2,v3,"Vec2:to_vec3()")
end

assert_summary("Vec2")