Vector = {}
Vector.__index = Vector

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

Vector.__concat = __concat
Object.__concat = __concat

local function vectorize_bin(lhs,rhs,fn)
    local res
    local a,b = is_vector(lhs), is_vector(rhs)

    if a and b then
        res = getmetatable(lhs)()
        local l = #lhs
        if l ~= #rhs then
            error("Vector size mismatch in Vectorized operation.")
        end

        for i = 1,l do
            res[i] = fn(lhs[i],rhs[i])
        end
    elseif a then
        res = getmetatable(lhs)()
        local l = #lhs
        for i = 1,l do
            res[i] = fn(lhs[i],rhs)
        end
    else
        res = getmetatable(rhs)()
        local l = #rhs
        for i = 1,l do
            res[i] = fn(lhs,rhs[i])
        end
    end

    return res
end

local function vectorize_un(v,fn)
    local res,l = getmetatable(v)(), #v
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

function Vector.__add(lhs,rhs)
    return vectorize_bin(lhs,rhs,add)
end

function Vector.__sub(lhs,rhs)
    return vectorize_bin(lhs,rhs,sub)
end

function Vector.__mul(lhs,rhs)
    return vectorize_bin(lhs,rhs,mul)
end

function Vector.__div(lhs,rhs)
    return vectorize_bin(lhs,rhs,div)
end

function Vector.__mod(lhs,rhs)
    return vectorize_bin(lhs,rhs,mod)
end

function Vector.__pow(lhs,rhs)
    return vectorize_bin(lhs,rhs,pow)
end

function Vector.__unm(v)
    return vectorize_un(v,unm)
end

function Vector.__eq(lhs,rhs)
    return vectorize_bin(lhs,rhs,eq)
end

function Vector.__lt(lhs,rhs)
    return vectorize_bin(lhs,rhs,lt)
end

function Vector.__le(lhs,rhs)
    return vectorize_bin(lhs,rhs,le)
end

function Vector.__tostring(v)
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

function Vector.__index(t, k)
    -- constructor
    local constr = getmetatable(t)
    -- super vector "class"
    local sv, o = constr, nil
    while sv ~= Vector do
        o = rawget(sv,k)
        if o ~= nil then
            return o
        end
        sv = getmetatable(sv)
    end

    -- take only the first element. Assumed to be a Vector of elements with same superclass
    local _first,f = rawget(t,1),nil
    -- if vector contains (assumed) same type tables, access first table to resolve indexed k
    if type(_first) == "table" then
        f = _first[k]
    else
        return nil
    end

    o = constr()
    local l = #t
    -- if retrieved value from first entry is not a function, resolve k for each entry and return a new vector
    if type(f) ~= "function" then
        o[1] = f
        for i = 2,l do
            o[i] = rawget(t,i)[k]
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

function Vector:extend()
    local cls = {}

    for k, v in pairs(self) do
        -- for now, k == "extend" is a work around for Vector.__index to retrieve correctly Vector:extend
        if k == "extend" or k:find("__") == 1 then cls[k] = v end
    end

    cls.__index = Vector.__index
    cls.super = self
    setmetatable(cls, self)
    return cls
end

function Vector:__call(t,...)
    if is_vector(self) then
        error("Cannot call constructor on instance.")
    end

    local v
    local args = {...}
    if #args ~= 0 then
        v = {t,...}
    else
        v = t or {}
    end

    local obj = setmetatable(v, self)
    obj.__is_vec = true
    return obj
end

setmetatable(Vector, {
    __call = Vector.__call,
    __tostring = Vector.__tostring
})