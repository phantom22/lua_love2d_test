Vec3 = Object:extend();

function Vec3:init(x,y,z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
end

function Vec3:__tostring()
    return "Vec3 { "..self.x..", "..self.y..", "..self.z.." }"
end

function Vec3:classname()
    return "Vec3"
end

function Vec3:cast_from(src)
    local res, cl = false, src:class();
    if cl == Object and type(src.x) == "number" and type(src.y) == "number" and type(src.z) == "number" then
        res = true
    elseif cl == Vec2 then
        src.z = 1
        res = true
    end

    return res
end

function Vec3:to_vec2()
    if self.z == 1 then
        return Vec2(self.x, self.y)
    elseif self.z == 0 then
        return Vec2(0, 0)
    else
        local t = 1 / self.z
        return Vec2(self.x * t, self.y * t)
    end
end

function Vec3:to_vec3()
    return self
end

function Vec3:unpack()
    return self.x, self.y, self.z
end

function Vec3:clone()
    return Vec3(self.x, self.y, self.z)
end

local sum_disp = ObjectOp(Vec3,"__add",{
        other_type = Vec3, 
        fn = function (a,b) return Vec3(a.x+b.x, a.y+b.y, a.z+b.z) end
    },{
        other_type = "number",
        fn = function (a,b) return Vec3(a.x+b, a.y+b, a.z+b) end,
        fn_com = function (a,b) return Vec3(a+b.x, a+b.y, a+b.z) end
    }
)

function Vec3.__add(lhs,rhs)
    return sum_disp:resolve(lhs,rhs)
end

local sub_disp = ObjectOp(Vec3,"__sub",{
        other_type = Vec3, 
        fn = function (a,b) return Vec3(a.x-b.x, a.y-b.y, a.z-b.z) end
    },{
        other_type = "number",
        fn = function (a,b) return Vec3(a.x-b, a.y-b, a.z-b) end,
        fn_com = function (a,b) return Vec3(a-b.x, a-b.y, a-b.z) end
    }
)

function Vec3.__sub(lhs,rhs)
    return sub_disp:resolve(lhs,rhs)
end

local mul_disp = ObjectOp(Vec3,"__mul",{
        other_type = Vec3, 
        fn = function (a,b) return a.x*b.x + a.y*b.y + a.z*b.z end
    },{
        other_type = "number",
        fn = function (a,b) return Vec3(a.x*b, a.y*b, a.z*b) end,
        fn_com = function (a,b) return Vec3(a*b.x, a*b.y, a*b.z) end
    }
)

function  Vec3.__mul(lhs,rhs)
    return mul_disp:resolve(lhs,rhs)
end

local div_disp = ObjectOp(Vec3,"__div",
    {
        other_type = "number",
        fn = function (a,b) return Vec3(a.x/b, a.y/b, a.z/b) end,
    }
)

function  Vec3.__div(lhs,rhs)
    return div_disp:resolve(lhs,rhs)
end

local neg_disp = ObjectOp(Vec3,"__unm",{ fn = function (a) return Vec3(-a.x, -a.y, -a.z) end })

function Vec3.__unm(v)
    return neg_disp:resolve(v)
end

local pow_disp = ObjectOp(Vec3,"__pow",{
        other_type = Vec3, 
        fn = function (a,b) return Vec3(a.x^b.x,a.y^b.y,a.z^b.z) end
    },{
        other_type = "number",
        fn = function (a,b) return Vec3(a.x^b, a.y^b, a.z^b) end,
        fn_com = function (a,b) return Vec3(a^b.x, a^b.y, a^b.z) end
    }
)

function Vec3.__pow(lhs,rhs)
    return pow_disp:resolve(lhs,rhs)
end