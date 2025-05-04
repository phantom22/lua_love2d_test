do
    local m = Mat2(math.pi/2, -math.pi/2, -math.pi/3, math.pi/4)

    assert_eq(tostring(Mat2), "Mat2 type", "Mat2.__tostring()")
    assert_true(_eq(m[1],math.pi/2) and _eq(m[2],-math.pi/2) and _eq(m[3],-math.pi/3) and _eq(m[4],math.pi/4), "Mat2:init()")
    assert_eq(m:classname(),"Mat2","Mat2:classname()")
    assert_true(m:class() == Mat2,"Mat2:class()")
end

do
    local m1 = Mat2(13,25,-13,-25)
    local m2 = m1:clone()

    m2[2] = 5

    assert_true(m1 ~= m2 and _eq(m1,Mat2(13,25,-13,-25)) and _eq(m2,Mat2(13,5,-13,-25)),"Mat2:clone()")
end

do
    local m = Mat2(1,2,3,4)
    local m_tr = Mat2(1,3,2,4)
    local m_inv = Mat2(-2,1,3/2,-1/2)

    local n = m:tr()
    local o = m:inv()

    local det = m:det()
    local id = Mat2.id()

    local m_prod_a,m_prod_b = o*m,m*o

    assert_eq(n,m_tr, "Mat2:tr()")
    assert_true(_eq(det,n:det()) and _eq(det,-2), "Mat2:det()")
    assert_true(_eq(o,m_inv) and _eq(m_prod_a,m_prod_b) and _eq(m_prod_b,id),"Mat2:inv()")
end

do
    local m1 = Mat2(1,2,3,4)
    local m2 = Mat2(10,11,12,13)
    local v1 = Vec2(5,-1)
    local v2 = Vec2(0,0)
    local v3 = Vec2(-15,15)

    local id = Mat2.id()
    local zero = Mat2.zero()

    assert_true(_eq(m1+m2, m2+m1) and _eq(m1+m2,Mat2(11,13,15,17)),"Mat2+Mat2")
    assert_true(_eq(5+m1,m1+5) and _eq(m1+5,Mat2(6,7,8,9)),"Mat2+number & number+Mat2")

    assert_true(_eq(m1-m2,Mat2(-9,-9,-9,-9)) and _eq(m2-m1,Mat2(9,9,9,9)),"Mat2-Mat2")
    assert_true(_eq(m1-2,Mat2(-1,0,1,2)) and _eq(2-m1,Mat2(1,0,-1,-2)),"Mat2-number & number-Mat2")

    assert_true(
        _eq(m1*id,id*m1) and _eq(m1*id,m1) and 
        _eq(m1*zero,zero*m1) and _eq(m1*zero,zero) and 
        _eq(m1*m2,Mat2(43,64,51,76)) and _eq(m2*m1,Mat2(34,37,78,85)),
    "Mat2*Mat2")

    assert_true(
        _eq(m1*v1,Vec2(2,6)) and
        _eq(m1*v3,Vec2(30,30)) and
        _eq(m2*v1,Vec2(38,42)) and
        _eq(m2*v3,Vec2(30,30)) and
        _eq(m1*v2,m2*v2) and _eq(m1*v2,v2),
        "Mat2*Vec2"
    )

    assert_true(_eq(m2*2,2*m2) and _eq(m2*2,Mat2(20,22,24,26)),"Mat2*number & number*Mat2")

    assert_true(_eq(m1/5,Mat2(1/5,2/5,3/5,4/5)) and _eq(m2/3,Mat2(10/3,11/3,4,13/3)), "Mat2/number")

    assert_true(_eq(-m1,Mat2(-1,-2,-3,-4)) and _eq(-m2,Mat2(-10,-11,-12,-13)), "-Mat2")

    assert_true(_eq(m1^m2,Mat2(1,2048,531441,67108864)) and _eq(m2^m1,Mat2(10,121,1728,28561)), "Mat2^Mat2")

    assert_true(_eq(m1^3,Mat2(1,8,27,64)) and _eq(m2^2,Mat2(100,121,144,169)), "Mat2^number")
end

assert_summary("Mat2")