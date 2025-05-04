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

    assert_true(v1 ~= v2 and _eq(v1,Vec3(13,25,5)) and _eq(v2,Vec3(5,25,5)),"Vec3:clone()")
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
    local v1 = Vec3(99,-13,5)
    local v2 = Vec3(-98,12,4)
    local v3 = Vec3(15,-3,3)
    local v4 = Vec3(4,16,2)

    assert_true(_eq(v1+v2, v2+v1) and _eq(v1+v2,Vec3(1,-1,9)),"Vec3+Vec3")
    assert_true(_eq(5+v1,v1+5) and _eq(v1+5,Vec3(104,-8,10)),"Vec3+number & number+Vec3")

    assert_true(_eq(v1-v2,Vec3(197,-25,1)) and _eq(v2-v1,Vec3(-197,25,-1)),"Vec3-Vec3")
    assert_true(_eq(v1-2,Vec3(97,-15,3)) and _eq(2-v1,Vec3(-97,15,-3)),"Vec3-number & number-Vec3")

    assert_true(
        _eq(v1*v2,v2*v1) and
        _eq(v1*v2,-9838),
    "Vec3*Vec3")

    assert_true(
        _eq(v2*2,2*v2) and _eq(v2*2,Vec3(-196,24,8)) and
        _eq(v1*3,3*v1) and _eq(v1*3,Vec3(297,-39,15)),
    "Vec3*number & number*Vec3")

    assert_true(_eq(v1/5,Vec3(99/5,-13/5,1)) and _eq(v2/3,Vec3(-98/3,4,4/3)), "Vec3/number")

    assert_true(_eq(-v1,Vec3(-99,13,-5)) and _eq(-v2,Vec3(98,-12,-4)), "-Vec3")

    assert_true(_eq(v3^v4,Vec3(50625,43046721,9)) and _eq(v4^v3,Vec3(1073741824,0.000244,8)), "Vec3^Vec3")

    assert_true(
        _eq(v1^3,Vec3(970299,-2197,125)) and
        _eq(v2^2,Vec3(9604,144,16)) and
        _eq(v3^4,Vec3(50625,81,81)) and
        _eq(v4^5,Vec3(1024,1048576,32)),
    "Vec3^number")
end

assert_summary("Vec3")