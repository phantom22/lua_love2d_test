Vector = {}

function is_vector(x)
    return type(x) == "table" and rawget(x, "__is_vec") == true
end

function Vector.vectorize(lhs,rhs)
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

local function vectorize(lhs,rhs,fn)
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
local function _tostring(a) return tostring(a) end

local function __add(lhs,rhs)
    return vectorize(lhs,rhs,add)
end

local function __sub(lhs,rhs)
    return vectorize(lhs,rhs,sub)
end

local function __mul(lhs,rhs)
    return vectorize(lhs,rhs,mul)
end

local function __div(lhs,rhs)
    return vectorize(lhs,rhs,div)
end

local function __mod(lhs,rhs)
    return vectorize(lhs,rhs,mod)
end

local function __pow(lhs,rhs)
    return vectorize(lhs,rhs,pow)
end

local function __unm(v)
    return vectorize(v,nil,unm)
end

local function __eq(lhs,rhs)
    return vectorize(lhs,rhs,eq)
end

local function __lt(lhs,rhs)
    return vectorize(lhs,rhs,lt)
end

local function __le(lhs,rhs)
    return vectorize(lhs,rhs,le)
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

    if f == nil then
        return nil
    elseif type(f) ~= "function" then
        return f
    end

    return function(s, ...)
        local o,l = Vector(), #s

        for i = 1,l do
            o[i] = f(rawget(s,i), ...)
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
        __tostring = __tostring
    })
    --obj.__index = Vector
    obj.__is_vec = true
    return obj
end

setmetatable(Vector, {
    __call = Vector.__call,
    __tostring = function() return "Vector Type" end
})