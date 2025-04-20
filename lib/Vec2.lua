Vec2 = Object:extend();

function Vec2:init(x,y)
    self.x = x or 0
    self.y = y or 0
end

function Vec2:__tostring()
    return "Vec2 { "..self.x..", "..self.y.." }"
end

function Vec2:classname()
    return "Vec2"
end

function Vec2:cast_from(src)
    local res, cl = false, src:class();
    if cl == Object and type(src.x) == "number" and type(src.y) == "number" then
        res = true
    elseif cl == Vec3 then
        if src.z ~= 0 and src.z ~= 1 then
            src.x = src.x / src.z
            src.y = src.y / src.z
        end
        src.z = nil
        res = true
    end

    return res
end

function Vec2:to_vec2()
    return self
end

function Vec2:to_vec3()
    return Vec3(self.x, self.y, 1)
end

function Vec2:clone()
    return Vec2(self.x, self.y)
end

function Vec2:unpack()
    return self.x, self.y
end

local sum_disp = ObjectOp(Vec2,"+",{
        other_type = Vec2, 
        fn = function (a,b) return Vec2(a.x+b.x, a.y+b.y) end
    },{
        other_type = "number",
        fn = function (a,b) return Vec2(a.x+b, a.y+b) end,
        fn_com = function (a,b) return Vec2(a+b.x, a+b.y) end
    }
)

function Vec2.__add(lhs,rhs)
    return sum_disp:resolve(lhs,rhs)
end

local sub_disp = ObjectOp(Vec2,"-",{
        other_type = Vec2, 
        fn = function (a,b) return Vec2(a.x-b.x, a.y-b.y) end
    },{
        other_type = "number",
        fn = function (a,b) return Vec2(a.x-b, a.y-b) end,
        fn_com = function (a,b) return Vec2(a-b.x, a-b.y) end
    }
)

function Vec2.__sub(lhs,rhs)
    return sub_disp:resolve(lhs,rhs)
end

local mul_disp = ObjectOp(Vec2,"*",{
        other_type = Vec2, 
        fn = function (a,b) return a.x*b.x + a.y*b.y end
    },{
        other_type = "number",
        fn = function (a,b) return Vec2(a.x*b, a.y*b) end,
        fn_com = function (a,b) return Vec2(a*b.x, a*b.y) end
    }
)

function  Vec2.__mul(lhs,rhs)
    return mul_disp:resolve(lhs,rhs)
end

local div_disp = ObjectOp(Vec2,"/",
    {
        other_type = "number",
        fn = function (a,b) return Vec2(a.x/b, a.y/b) end,
    }
)

function  Vec2.__div(lhs,rhs)
    return div_disp:resolve(lhs,rhs)
end

local neg_disp = ObjectOp(Vec2,"-",{ fn = function (a) return Vec2(-a.x, -a.y) end })

function Vec2.__unm(v)
    return neg_disp:resolve(v)
end