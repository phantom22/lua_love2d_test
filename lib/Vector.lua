Vector = {}

function is_vector(x)
    return type(x) == "table" and rawget(x, "__is_vec") == true
end

local function __concat(lhs,rhs)
    local a,b = is_vector(lhs), is_vector(rhs)
    if a or b then
        if a and b then -- Vector .. Vector
            local ssize, osize = #lhs, #rhs
            for i = 1, osize do
                lhs[ssize + i] = rhs[i]
            end
            return lhs
        elseif a then -- Vector .. not Vector
            lhs[#lhs + 1] = rhs
            return lhs
        else -- not Vector .. Vector
            table.insert(rhs, 1, lhs)
            return rhs
        end
    else
        return Vector({lhs,rhs})
    end
end

local function vectorize_bin(lhs,rhs,fn)
    local res = Vector()
    local a,b = is_vector(lhs), is_vector(rhs)

    if a and b then
        local l = #lhs
        if l ~= #rhs then
            error("Vector size mismatch in Vectorized operation.")
        end

        for i = 1,l do
            res[i] = fn(lhs[i],rhs[i])
        end
    elseif a then
        local l = #lhs
        for i = 1,l do
            res[i] = fn(lhs[i],rhs)
        end
    else
        local l = #rhs
        for i = 1,l do
            res[i] = fn(lhs,rhs[i])
        end
    end

    return res
end

local function vectorize_un(v,fn)
    local res,l = Vector(), #v
    for i = 1,l do
        res[i] = fn(v[i])
    end
    return res
end

local function add(a,b) return a + b end
local function sub(a,b) return a - b end
local function mul(a,b) return a * b end
local function div(a,b) return a / b end
local function mod(a,b) return a % b end
local function pow(a,b) return a ^ b end
local function unm(a) return -a end
local function eq(a,b) return a == b end
local function lt(a,b) return a < b end
local function le(a,b) return a <= b end

local function __add(lhs,rhs)
    return vectorize_bin(lhs,rhs,add)
end

local function __sub(lhs,rhs)
    return vectorize_bin(lhs,rhs,sub)
end

local function __mul(lhs,rhs)
    return vectorize_bin(lhs,rhs,mul)
end

local function __div(lhs,rhs)
    return vectorize_bin(lhs,rhs,div)
end

local function __mod(lhs,rhs)
    return vectorize_bin(lhs,rhs,mod)
end

local function __pow(lhs,rhs)
    return vectorize_bin(lhs,rhs,pow)
end

local function __unm(v)
    return vectorize_un(v,unm)
end

local function __eq(lhs,rhs)
    return vectorize_bin(lhs,rhs,eq)
end

local function __lt(lhs,rhs)
    return vectorize_bin(lhs,rhs,lt)
end

local function __le(lhs,rhs)
    return vectorize_bin(lhs,rhs,le)
end

local function __tostring(v)
    if v.__is_vec == nil then
        return "Vector type"
    end

    local l = #v
    if l == 0 then
        return "{}"
    end

    local out = "{\n"
    for i = 1,l do
        out = out .. "  " .. i .. ": " .. tostring(v[i])
        if i+1 <= l then
            out = out .. "\n"
        end
    end
    out = out .. "\n}"
    return out
end

local function __index(t, k)
    -- take only the first element. Assumed to be a Vector of elements with same superclass
    local _first,f = rawget(t,1)
    if _first ~= nil then
        f = _first[k]
    end

    local o,l = Vector(), #t

    if type(f) ~= "function" then
        for i = 1,l do
            o[i] = t[i][k]
        end
        return o
    end

    return function(...)
        if select(1,...) == t then -- my_vec:my_method(...)
            for i = 1,l do
                local e = rawget(t,i)
                o[i] = e[k](e, ...)
            end
        else -- my_vec.my_method(...)
            for i = 1,l do
                local e = rawget(t,i)
                o[i] = e[k](...)
            end
        end
        return o
    end
end

Vector.__index = Vector

function Vector:__call(t)
    t = t or {}
    if is_vector(self) then
        error("Cannot call constructor on instance.")
    end

    local obj = setmetatable(t, {
        __index = __index,
        __add = __add,
        __sub = __sub,
        __mul = __mul,
        __div = __div,
        __mod = __mod,
        __pow = __pow,
        __unm = __unm,
        __eq = __eq,
        __lt = __lt,
        __le = __le,
        __tostring = __tostring,
        __concat = __concat
    })
    --obj.__index = Vector
    obj.__is_vec = true
    return obj
end

Object.__concat = __concat

setmetatable(Vector, {
    __call = Vector.__call,
    __tostring = function() return "Vector Type" end
})

local function vectorize_m_un(v,num_f,cl_f)
    local res,l = Vector(), #v
    if l == 0 then
        return res
    end

    if type(v[1]) == "number" then
        for i = 1,l do
            res[i] = num_f(v[i])
        end
    else
        for i = 1,l do
            res[i] = cl_f(v[i])
        end
    end
    return res
end

local function vectorize_m_bin(l,r,num_f,cl_f)
    local res = Vector()
    local a,b = is_vector(l), is_vector(r)

    if a and b then
        local n = #l
        if n ~= #r then
            error("Vector size mismatch in Vectorized operation.")
        end

        if n == 0 then
            return res
        end

        if type(l[1]) == "number" then
            for i = 1,n do
                res[i] = num_f(l[i],r[i])
            end
        else
            for i = 1,n do
                res[i] = cl_f(l[i],r[i])
            end
        end

        return res
    elseif a then
        local n = #l

        if n == 0 then
            return res
        end

        if type(l[1]) == "number" then
            for i = 1,n do
                res[i] = num_f(l[i],r)
            end
        else
            for i = 1,n do
                res[i] = cl_f(l[i],r)
            end
        end

        return res
    elseif b then
        local n = #r

        if n == 0 then
            return res
        end

        if type(r[1]) == "number" then
            for i = 1,n do
                res[i] = num_f(l,r[i])
            end
        else
            for i = 1,n do
                res[i] = cl_f(l,r[i])
            end
        end

        return res
    else
        return num_f(l,r)
    end
end

vmath = {}

function vmath.abs(v)
    return vectorize_m_un(v, math.abs, v.abs)
end

function vmath.acos(v)
    return vectorize_m_un(v, math.acos, v.acos)
end

function vmath.asin(v)
    return vectorize_m_un(v, math.asin, v.asin)
end

function vmath.ceil(v)
    return vectorize_m_un(v, math.ceil, v.ceil)
end

function vmath.floor(v)
    return vectorize_m_un(v, math.floor, v.floor)
end

function vmath.cos(v)
    return vectorize_m_un(v, math.cos, v.cos)
end

function vmath.cosh(v)
    return vectorize_m_un(v, math.cosh, v.cosh)
end

function vmath.sin(v)
    return vectorize_m_un(v, math.sin, v.sin)
end

function vmath.sinh(v)
    return vectorize_m_un(v, math.sinh, v.sinh)
end

function vmath.tan(v)
    return vectorize_m_un(v, math.tan, v.tan)
end

function vmath.tanh(v)
    return vectorize_m_un(v, math.tanh, v.tanh)
end

function vmath.sqrt(v)
    return vectorize_m_un(v, math.sqrt, v.sqrt)
end

function vmath.deg(v)
    return vectorize_m_un(v, math.deg, v.deg)
end

function vmath.rad(v)
    return vectorize_m_un(v, math.rad, v.rad)
end

function vmath.exp(v)
    return vectorize_m_un(v, math.exp, v.exp)
end

function vmath.log10(v)
    return vectorize_m_un(v, math.log10, v.log10)
end

function vmath.max(v)
    local res,l = -math.huge, #v
    if l == 0 then
        return res
    end

    local t
    for i = 1,l do
        t = v[i]
        if t > res then
            res = t
        end
    end

    return res
end

function vmath.min(v)
    local res,l = math.huge, #v
    if l == 0 then
        return res
    end

    local t
    for i = 1,l do
        t = v[i]
        if t < res then
            res = t
        end
    end

    return res
end

function vmath.type(v)
    return vectorize_m_un(v, math.type, nil)
end

function vmath.tointeger(v)
    return vectorize_m_un(v, math.tointeger, nil)
end

function vmath.log(v,base)
    local res,l = Vector(), #v
    if l == 0 then
        return res
    end

    for i = 1,l do
        res[i] = math.log(v[i], base)
    end

    return res
end

function vmath.modf(v)
    local a,b,l = Vector(), Vector(), #v
    if l == 0 then
        return a
    end

    for i = 1,l do
        a[i], b[i] = math.modf(v[i])
    end

    return a,b
end

function vmath.fmod(x,y)
    return vectorize_m_bin(x,y,math.fmod,x.fmod)
end

function vmath.atan(x,y)
    return vectorize_m_bin(x,y,math.atan,x.atan)
end

function vmath.atan2(x,y)
    return vectorize_m_bin(x,y,math.atan2,x.atan2)
end

function vmath.pow(x,y)
    return vectorize_m_bin(x,y,math.pow,x.pow)
end

function vmath.ult(x,y)
    return vectorize_m_bin(x,y,math.ult,x.ult)
end

function vmath.random(l,x,y)
    if l == nil then
        error("No expected random value count provided.")
    end

    local res,a,b = Vector(), x ~= nil, y ~= nil
    if a and b then
        for i = 1,l do
            res[i] = math.random(x,y)
        end
    elseif a then
        for i = 1,l do
            res[i] = math.random(x)
        end
    else
        for i = 1,l do
            res[i] = math.random()
        end
    end
    
    return res
end