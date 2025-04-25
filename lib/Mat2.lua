-- local sin, cos = math.sin, math.cos

Mat2 = Object:extend();

function Mat2:init(m11, m12, m21, m22)
    self[1] = m11 or 0
    self[2] = m21 or 0
    self[3] = m12 or 0
    self[4] = m22 or 0
end

function Mat2:classname()
    return "Mat2"
end

function Mat2:__tostring()
    return "Mat2 {\n  "..self[1]..", "..self[3]..",\n  "..self[2]..", "..self[4].."\n}"
end

function Mat2:cast_from(src)
    local res, cl = false, src:class();
    if cl == Object and #src >= 4 then
        res = true
        for i = 1,4 do
            res = res and type(src[i]) == "number"
            if not res then
                break
            end
        end
    elseif cl == Mat3 then
        src[3] = src[4]
        src[4] = src[5]
        src[5] = nil
        src[6] = nil
        src[7] = nil
        src[8] = nil
        src[9] = nil
        res = true
    end

    return res
end

function Mat2:clone()
    return Mat2(self[1], self[3], self[2], self[4])
end

function Mat2:tr()
    return Mat2(self[1], self[2], self[3], self[4])
end

function Mat2:det()
    return self[1] * self[4] - self[3] * self[2]
end

function Mat2:inv()
    local d = self:det()

    if d == 0 then
        return Mat2(0, 0, 0, 0)
    end

    local t = 1 / d
    return Mat2(self[4] * t, -self[2] * t, -self[3] * t, self[1] * t)
end

function Mat2.rot(theta)
    local c, s = math.cos(theta), math.sin(theta)
    return Mat2(c, -s, s, c)
end

function Mat2:scale(sx,sy)
    return Mat2(sx, 0, 0, sy)
end

function Mat2:scale_rot(sx,sy,theta)
    local c, s = math.cos(theta), math.sin(theta)
    return Mat2(sx*c, -sy*s, sx*s, sy*c)
end

function Mat2.id()
    return Mat2(1, 0, 0, 1)
end

function Mat2.zero()
    return Mat2(0, 0, 0, 0)
end

local sum_disp = ObjectOp(Mat2,"+",{
        other_type = Mat2, 
        fn = function (a,b) return Mat2(a[1]+b[1], a[3]+b[3], a[2]+b[2], a[4]+b[4]) end
    },{
        other_type = "number",
        fn = function (a,b) return Mat2(a[1]+b, a[3]+b, a[2]+b, a[4]+b) end,
        fn_com = function (a,b) return Mat2(a+b[1], a+b[3], a+b[2], a+b[4]) end
    }
)

function Mat2.__add(lhs,rhs)
    return sum_disp:resolve(lhs,rhs)
end

local sub_disp = ObjectOp(Mat2,"-",{
        other_type = Mat2, 
        fn = function (a,b) return Mat2(a[1]-b[1], a[3]-b[3], a[2]-b[2], a[4]-b[4]) end
    },{
        other_type = "number",
        fn = function (a,b) return Mat2(a[1]-b, a[3]-b, a[2]-b, a[4]-b) end,
        fn_com = function (a,b) return Mat2(a-b[1], a-b[3], a-b[2], a-b[4]) end
    }
)

function Mat2.__sub(lhs,rhs)
    return sub_disp:resolve(lhs,rhs)
end

local mul_disp = ObjectOp(Mat2,"*",{
        other_type = Mat2, 
        fn = function (a,b) return Mat2(a[1]*b[1]+a[3]*b[2], a[1]*b[3]+a[3]*b[4], a[2]*b[1]+a[4]*b[2], a[2]*b[3]+a[4]*b[4]) end
    },{
        other_type = Vec2,
        fn = function (a,b) return Vec2(a[1]*b.x+a[3]*b.y, a[2]*b.x+a[4]*b.y) end
    },{
        other_type = "number",
        fn = function (a,b) return Mat2(a[1]*b, a[3]*b, a[2]*b, a[4]*b) end,
        fn_com = function (a,b) return Mat2(a*b[1], a*b[3], a*b[2], a*b[4]) end
    }
)

function Mat2.__mul(lhs,rhs)
    return mul_disp:resolve(lhs,rhs)
end

local div_disp = ObjectOp(Mat2,"/", {
        other_type = "number",
        fn = function (a,b) local t = 1/b; return Mat2(a[1]*t, a[3]*t, a[2]*t, a[4]*t) end,
    }
)

function Mat2.__div(lhs,rhs)
    return div_disp:resolve(lhs,rhs)
end

local neg_disp = ObjectOp(Mat2,"-",{ fn = function (a) return Mat2(-a[1], -a[3], -a[2], -a[4]) end })

function Mat2.__unm(v)
    return neg_disp:resolve(v)
end

local pow_disp = ObjectOp(Mat2,"^",{
        other_type = Mat2, 
        fn = function (a,b) return Mat2(a[1]^b[1], a[3]^b[3], a[2]^b[2], a[4]^b[4]) end
    },{
        other_type = "number",
        fn = function (a,b) return Mat2(a[1]^b, a[3]^b, a[2]^b, a[4]^b) end,
    }
)

function Mat2.__pow(lhs,rhs)
    return pow_disp:resolve(lhs,rhs)
end