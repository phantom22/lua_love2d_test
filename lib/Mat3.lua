-- local sin, cos = math.sin, math.cos

Mat3 = Object:extend();

function Mat3:init(m11, m12, m13, m21, m22, m23, m31, m32, m33)
    self[1] = m11 or 0
    self[2] = m21 or 0
    self[3] = m31 or 0
    self[4] = m12 or 0
    self[5] = m22 or 0
    self[6] = m32 or 0
    self[7] = m13 or 0
    self[8] = m23 or 0
    self[9] = m33 or 0
end

function Mat3:classname()
    return "Mat3"
end

function Mat3:__tostring()
    return "Mat3 {\n  "..self[1]..", "..self[4]..", "..self[7]..",\n  "..self[2]..", "..self[5]..", "..self[8]..",\n  "..self[3]..", "..self[6]..", "..self[9].."\n}"
end

function Mat3:cast_from(src)
    local res, cl = false, src:class();
    if cl == Object and #src >= 9 then
        res = true
        for i = 1,9 do
            res = res and type(src[i]) == "number"
            if not res then
                break
            end
        end
    elseif cl == Mat2 then
        src[5] = src[4]
        src[4] = src[3]
        src[3] = 0
        src[6] = 0
        src[7] = 0
        src[8] = 0
        src[9] = 1
        res = true
    end

    return res
end

function Mat3:clone()
    return Mat3(self[1], self[4], self[7], self[2], self[5], self[8], self[3], self[6], self[9])
end

function Mat3:tr()
    return Mat3(self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], self[9])
end

function Mat3:det()
    return self[1] * (self[5] * self[9] - self[6] * self[8]) - self[4] * (self[2] * self[9] - self[3] * self[8]) + self[7] * (self[2] * self[6] - self[3] * self[5])
end

function Mat3:inv()
    local _d = self:det()

    if _d == 0 then
        return Mat3(0, 0, 0, 0, 0, 0, 0, 0, 0)
    end

    local t,a,b,c,d,e,f,g,h,i = 1 / _d, self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], self[9]
    return Mat3((e*i-f*h)*t, (f*g-d*i)*t, (d*h-e*g)*t, (c*h-b*i)*t, (a*i-c*g)*t, (b*g-a*h)*t, (b*f-c*e)*t, (c*d-a*f)*t, (a*e-b*d)*t)
end

function Mat3.rot(theta)
    local c, s = math.cos(theta), math.sin(theta)
    return Mat3(c, -s, 0, s, c, 0, 0, 0, 1)
end

function Mat3.scale(sx,sy)
    return Mat3(sx, 0, 0, 0, sy, 0, 0, 0, 1)
end

function Mat3.transl(dx,dy)
    return Mat3(1, 0, dx, 0, 1, dy, 0, 0, 1)
end

function Mat3.scale_rot(sx,sy,theta)
    local c, s = math.cos(theta), math.sin(theta)
    return Mat3(sx*c, -sy*s, 0, sx*s, sy*c, 0, 0, 0, 1)
end

function Mat3.scale_rot_transl(sx,sy,theta,dx,dy)
    local c, s = math.cos(theta), math.sin(theta)
    return Mat3(sx*c, -sy*s, dx, sx*s, sy*c, dy, 0, 0, 1)
end

function Mat3.scale_transl(sx,sy,dx,dy)
    return Mat3(sx, 0, dx, 0, sy, dy, 0, 0, 1)
end

function Mat3.rot_transl(theta,dx,dy)
    local c, s = math.cos(theta), math.sin(theta)
    return Mat3(c, -s, dx, s, c, dy, 0, 0, 1)
end

function Mat3.id()
    return Mat3(1, 0, 0, 0, 1, 0, 0, 0, 1)
end

function Mat3.zero()
    return Mat3(0, 0, 0, 0, 0, 0, 0, 0, 0)
end

local sum_disp = ObjectOp(Mat3,"+",{
        other_type = Mat3, 
        fn = function (a,b) return Mat3(a[1]+b[1], a[4]+b[4], a[7]+b[7], a[2]+b[2], a[5]+b[5], a[8]+b[8], a[3]+b[3], a[6]+b[6], a[9]+b[9]) end
    },{
        other_type = "number",
        fn = function (a,b) return Mat3(a[1]+b, a[4]+b, a[7]+b, a[2]+b, a[5]+b, a[8]+b, a[3]+b, a[6]+b, a[9]+b) end,
        fn_com = function (a,b) return Mat3(a+b[1], a+b[4], a+b[7], a+b[2], a+b[5], a+b[8], a+b[3], a+b[6], a+b[9]) end
    }
)

function Mat3.__add(lhs,rhs)
    return sum_disp:resolve(lhs,rhs)
end

local sub_disp = ObjectOp(Mat3,"-",{
        other_type = Mat3, 
        fn = function (a,b) return Mat3(a[1]-b[1], a[4]-b[4], a[7]-b[7], a[2]-b[2], a[5]-b[5], a[8]-b[8], a[3]-b[3], a[6]-b[6], a[9]-b[9]) end
    },{
        other_type = "number",
        fn = function (a,b) return Mat3(a[1]-b, a[4]-b, a[7]-b, a[2]-b, a[5]-b, a[8]-b, a[3]-b, a[6]-b, a[9]-b) end,
        fn_com = function (a,b) return Mat3(a-b[1], a-b[4], a-b[7], a-b[2], a-b[5], a-b[8], a-b[3], a-b[6], a-b[9]) end
    }
)

function Mat3.__sub(lhs,rhs)
    return sub_disp:resolve(lhs,rhs)
end

local mul_disp = ObjectOp(Mat3,"*",{
        other_type = Mat3, 
        fn = function (a,b) return Mat3(a[1]*b[1]+a[4]*b[2]+a[7]*b[3], a[1]*b[4]+a[4]*b[5]+a[7]*b[6], a[1]*b[7]+a[4]*b[8]+a[7]*b[9], 
                                        a[2]*b[1]+a[5]*b[2]+a[8]*b[3], a[2]*b[4]+a[5]*b[5]+a[8]*b[6], a[2]*b[7]+a[5]*b[8]+a[8]*b[9],
                                        a[3]*b[1]+a[6]*b[2]+a[9]*b[3], a[3]*b[4]+a[6]*b[5]+a[9]*b[6], a[3]*b[7]+a[6]*b[8]+a[9]*b[9]) end
    },{
        other_type = Vec3,
        fn = function (a,b) return Vec3(a[1]*b.x+a[4]*b.y+a[7]*b.z, a[2]*b.x+a[5]*b.y+a[8]*b.z, a[3]*b.x+a[6]*b.y+a[9]*b.z) end
    },{
        other_type = "number",
        fn = function (a,b) return Mat3(a[1]*b, a[4]*b, a[7]*b, a[2]*b, a[5]*b, a[8]*b, a[3]*b, a[6]*b, a[9]*b) end,
        fn_com = function (a,b) return Mat3(a*b[1], a*b[4], a*b[7], a*b[2], a*b[5], a*b[8], a*b[3], a*b[6], a*b[9]) end
    }
)

function Mat3.__mul(lhs,rhs)
    return mul_disp:resolve(lhs,rhs)
end

local div_disp = ObjectOp(Mat3,"/", {
        other_type = "number",
        fn = function (a,b) local t = 1/b; return Mat3(a[1]*t, a[4]*t, a[7]*t, a[2]*t, a[5]*t, a[8]*t, a[3]*t, a[6]*t, a[9]*t) end,
    }
)

function Mat3.__div(lhs,rhs)
    return div_disp:resolve(lhs,rhs)
end

local neg_disp = ObjectOp(Mat3,"-",{ fn = function (a) return Mat3(-a[1], -a[4], -a[7], -a[2], -a[5], -a[8], -a[3], -a[6], -a[9]) end })

function Mat3.__unm(v)
    return neg_disp:resolve(v)
end

local pow_disp = ObjectOp(Mat3,"^",{
        other_type = Mat3,
        fn = function (a,b) return Mat3(a[1]^b[1], a[4]^b[4], a[7]^b[7], a[2]^b[2], a[5]^b[5], a[8]^b[8], a[3]^b[3], a[6]^b[6], a[9]^b[9]) end
    },{
        other_type = "number",
        fn = function (a,b) return Mat3(a[1]^b, a[4]^b, a[7]^b, a[2]^b, a[5]^b, a[8]^b, a[3]^b, a[6]^b, a[9]^b) end,
    }
)

function Mat3.__pow(lhs,rhs)
    return pow_disp:resolve(lhs,rhs)
end