do
    local m = Mat3(math.pi/2, -math.pi/2, -math.pi/3, math.pi/4, -math.pi/5, math.pi/6, -math.pi/7, math.pi/8, -math.pi/9)

    assert_eq(tostring(Mat3), "Mat3 type", "Mat3.__tostring()")
    assert_true(
        _eq(m[1],math.pi/2) and _eq(m[2],-math.pi/2) and _eq(m[3],-math.pi/3) and
        _eq(m[4],math.pi/4) and _eq(m[5],-math.pi/5) and _eq(m[6],math.pi/6) and
        _eq(m[7],-math.pi/7) and _eq(m[8],math.pi/8) and _eq(m[9],-math.pi/9), "Mat3:init()")
    assert_eq(m:classname(),"Mat3","Mat3:classname()")
    assert_true(m:class() == Mat3,"Mat3:class()")
end

do
    local m1 = Mat3(13,25,-13,-25,2,3,4,5,11)
    local m2 = m1:clone()

    m2[2] = 5

    assert_true(m1 ~= m2 and _eq(m1,Mat3(13,25,-13,-25,2,3,4,5,11)) and _eq(m2,Mat3(13,5,-13,-25,2,3,4,5,11)),"Mat3:clone()")
end

do
    local m = Mat3(1,2,3,4,5,12,7,8,9)
    local m_tr = Mat3(1,4,7,2,5,8,3,12,9)
    local m_inv = Mat3(-17/12, 1/6, 1/4, 4/3, -1/3, 0, -1/12, 1/6, -1/12)

    local n = m:tr()
    local o = m:inv()

    local det = m:det()
    local id = Mat3.id()

    local m_prod_a,m_prod_b = o*m,m*o

    assert_eq(n,m_tr,"Mat3:tr()")
    assert_true(_eq(det,n:det()) and _eq(det,36), "Mat3:det()")
    assert_true(_eq(o,m_inv) and _eq(m_prod_a,m_prod_b) and _eq(m_prod_b,id),"Mat3:inv()")
end

do
    local m1 = Mat3(1,2,3,4,5,6,7,8,9)
    local m2 = Mat3(10,11,12,13,14,15,16,17,18)
    local v1 = Vec3(5,-1,3)
    local v2 = Vec3(0,0,0)
    local v3 = Vec3(-15,15,-3)

    local id = Mat3.id()
    local zero = Mat3.zero()

    assert_true(_eq(m1+m2, m2+m1) and _eq(m1+m2,Mat3(11,13,15,17,19,21,23,25,27)),"Mat3+Mat3")
    assert_true(_eq(5+m1,m1+5) and _eq(m1+5,Mat3(6,7,8,9,10,11,12,13,14)),"Mat3+number & number+Mat3")

    assert_true(_eq(m1-m2,Mat3(-9,-9,-9,-9,-9,-9,-9,-9,-9)) and _eq(m2-m1,Mat3(9,9,9,9,9,9,9,9,9)),"Mat3-Mat3")
    assert_true(_eq(m1-2,Mat3(-1,0,1,2,3,4,5,6,7)) and _eq(2-m1,Mat3(1,0,-1,-2,-3,-4,-5,-6,-7)),"Mat3-number & number-Mat3")

    assert_true(
        _eq(m1*id,id*m1) and _eq(m1*id,m1) and 
        _eq(m1*zero,zero*m1) and _eq(m1*zero,zero) and 
        _eq(m1*m2,Mat3(138,171,204,174,216,258,210,261,312)) and _eq(m2*m1,Mat3(84,90,96,201,216,231,318,342,366)),
    "Mat3*Mat3")

    assert_true(
        _eq(m1*v1,Vec3(22,29,36)) and
        _eq(m1*v3,Vec3(24,21,18)) and
        _eq(m2*v1,Vec3(85,92,99)) and
        _eq(m2*v3,Vec3(-3,-6,-9)) and
        _eq(m1*v2,m2*v2) and _eq(m1*v2,v2),
        "Mat3*Vec3"
    )

    assert_true(_eq(m2*2,2*m2) and _eq(m2*2,Mat3(20,22,24,26,28,30,32,34,36)),"Mat3*number & number*Mat3")

    assert_true(_eq(m1/5,Mat3(1/5,2/5,3/5,4/5,1,6/5,7/5,8/5,9/5)) and _eq(m2/3,Mat3(10/3,11/3,4,13/3,14/3,5,16/3,17/3,6)), "Mat3/number")

    assert_true(_eq(-m1,Mat3(-1,-2,-3,-4,-5,-6,-7,-8,-9)) and _eq(-m2,Mat3(-10,-11,-12,-13,-14,-15,-16,-17,-18)), "-Mat3")

    assert_true(
        _eq(m1^m2,Mat3(1,2048,531441,67108864,6103515625,470184984576,33232930569601,2251799813685248,150094635296999140)) and
        _eq(m2^m1,Mat3(10,121,1728,28561,537824,11390625,268435456,6975757441,198359290368)),
    "Mat3^Mat3")

    assert_true(_eq(m1^3,Mat3(1,8,27,64,125,216,343,512,729)) and _eq(m2^2,Mat3(100,121,144,169,196,225,256,289,324)), "Mat3^number")
end

assert_summary("Mat3")