do
    local v = Vec3(math.pi/2, -math.pi/2, 1/math.pi)

    assert_eq(tostring(Vec3), "Vec3 type", "Vec3.__tostring()")
    assert_true(_eq(v.x,math.pi/2) and _eq(v.y,-math.pi/2) and _eq(v.z,1/math.pi), "Vec3:init()")
    assert_eq(v:classname(),"Vec3","Vec3:classname()")
    assert_true(v:class() == Vec3,"Vec3:class()")
end

do
    local v1 = Vec3(13,25,5)
    local v2 = v1:clone()

    v2.x = 5

    assert_neq(v1,v2,"Vec3:clone()")
end

do
    local v = Vec3(12,math.pi,12)

    assert_true(v == v:to_vec3(),"Vec3:to_vec3()")
end

do
    local v1 = Vec3(12,math.pi,12)
    local v2 = v1:to_vec2()

    assert_true(v1 ~= v2 and _eq(v2,Vec2(1,math.pi/12)), "Vec3:to_vec2()")
end

do
    local v1 = Vec3(13,-13,1)
    local v2 = v1:cast(Vec2)

    assert_true(v1 == v2 and _eq(v1,Vec2(13,-13)) and _eq(v2:cast(Vec3),Vec3(13,-13,1)) and _throws_err(v2.cast,v2,Vec3), "Vec3:cast()")
end

do
    local v1 = Vec3(math.pi,-math.pi,math.pi/2)
    local t1 = {v1:unpack()}
    assert_true(_eq(v1.x,t1[1]) and _eq(v1.y,t1[2]) and _eq(v1.z,t1[3]),"Vec3:unpack()")
end

do
    local v1 = Vec3(99,-13,-2)
    local v2 = Vec3(-98,12,1)
    local v3 = Vec3(-4,4,4)


    assert_true(_eq(v3/4+2*v1/2-15*(-v2 * 1)/15,Vec3(0,0,0)) and _eq(v1*v2,-9860) and _eq(v3^2,Vec3(16,16,16)) and _eq(v3^Vec3(0,1,2),Vec3(1,4,16)),"Vec3 arithmetic")
end

assert_summary("Vec3")