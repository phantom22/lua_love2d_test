do
    local v = Vec2(math.pi/2, -math.pi/2)

    assert_eq(tostring(Vec2), "Vec2 type", "Vec2.__tostring()")
    assert_true(_eq(v.x,math.pi/2) and _eq(v.y,-math.pi/2), "Vec2:init()")
    assert_eq(v:classname(),"Vec2","Vec2:classname()")
    assert_true(v:class() == Vec2,"Vec2:class()")
end

do
    local v1 = Vec2(13,25)
    local v2 = v1:clone()

    v2.x = 5

    assert_neq(v1,v2,"Vec2:clone()")
end

do
    local v = Vec2(12,math.pi)

    assert_true(v == v:to_vec2(),"Vec2:to_vec2()")
end

do
    local v1 = Vec2(12,math.pi)
    local v2 = v1:to_vec3()

    assert_true(v1 ~= v2 and _eq(v2,Vec3(12,math.pi,1)), "Vec2:to_vec3()")
end

do
    local v1 = Vec2(13,-13)
    local v2 = v1:cast(Vec3)

    assert_true(v1 == v2 and _eq(v1,Vec3(13,-13,1)) and _eq(v2:cast(Vec2),Vec2(13,-13)) and _throws_err(v2.cast,v2,Vec2), "Vec2:cast()")
end

do
    local v1 = Vec2(math.pi,-math.pi)
    local t1 = {v1:unpack()}
    assert_true(_eq(v1.x,t1[1]) and _eq(v1.y,t1[2]),"Vec2:unpack()")
end

do
    local v1 = Vec2(99,-13)
    local v2 = Vec2(-98,12)
    local v3 = Vec2(-4,4)

    assert_true(_eq(v3/4+2*v1/2-15*(-v2 * 1)/15,Vec2(0,0)) and _eq(v1*v2,-9858) and _eq(v3^2,Vec2(16,16)) and _eq(v3^Vec2(0,1),Vec2(1,4)),"Vec2 arithmetic")
end

assert_summary("Vec2")