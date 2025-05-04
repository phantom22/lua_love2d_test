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

    assert_true(v1 ~= v2 and _eq(v1,Vec2(13,25)) and _eq(v2,Vec2(5,25)),"Vec2:clone()")
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
    local v3 = Vec2(15,-3)
    local v4 = Vec2(4,16)

    assert_true(_eq(v1+v2, v2+v1) and _eq(v1+v2,Vec2(1,-1)),"Vec2+Vec2")
    assert_true(_eq(5+v1,v1+5) and _eq(v1+5,Vec2(104,-8)),"Vec2+number & number+Vec2")

    assert_true(_eq(v1-v2,Vec2(197,-25)) and _eq(v2-v1,Vec2(-197,25)),"Vec2-Vec2")
    assert_true(_eq(v1-2,Vec2(97,-15)) and _eq(2-v1,Vec2(-97,15)),"Vec2-number & number-Vec2")

    assert_true(
        _eq(v1*v2,v2*v1) and
        _eq(v1*v2,-9858),
    "Vec2*Vec2")

    assert_true(
        _eq(v2*2,2*v2) and _eq(v2*2,Vec2(-196,24)) and
        _eq(v1*3,3*v1) and _eq(v1*3,Vec2(297,-39)),
    "Vec2*number & number*Vec2")

    assert_true(_eq(v1/5,Vec2(99/5,-13/5)) and _eq(v2/3,Vec2(-98/3,4)), "Vec2/number")

    assert_true(_eq(-v1,Vec2(-99,13)) and _eq(-v2,Vec2(98,-12)), "-Vec2")

    assert_true(_eq(v3^v4,Vec2(50625,43046721)) and _eq(v4^v3,Vec2(1073741824,0.000244)), "Vec2^Vec2")

    assert_true(
        _eq(v1^3,Vec2(970299,-2197)) and
        _eq(v2^2,Vec2(9604,144)) and
        _eq(v3^4,Vec2(50625,81)) and
        _eq(v4^5,Vec2(1024,1048576)),
    "Vec2^number")
end

assert_summary("Vec2")