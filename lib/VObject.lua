VOjbect = Object:extend()

function VOjbect.concatenate(lhs,rhs)
    local a,b = type(lhs) == "table" and lhs.__is_class == false and lhs:class() == VOjbect, type(rhs) == "table" and rhs.__is_class == false and rhs:class() == VOjbect

    if a or b then
        if a and b then -- VOjbect .. VOjbect
            return lhs:merge_with(rhs)
        elseif a then -- VOjbect .. not VOjbect
            lhs[#lhs + 1] = rhs
            return lhs
        else -- not VOjbect .. VOjbect
            table.insert(rhs, 1, lhs)    
            return rhs
        end
    else
        return VOjbect({lhs,rhs})
    end
end

function VOjbect:__call(tbl)
    tbl = tbl or {}
    if not Object.is_class(self) then
        error("Cannot call constructor on instance.")
    end

    local obj = setmetatable(tbl, VOjbect)
    obj.__is_class = false
    return obj
end

-- coll assumed to be another VOjbect instance
function VOjbect:merge_with(coll)
    local ssize, osize = #self, #coll
    for i = 1, osize do
        self[ssize + i] = coll[i]
    end

    return self
end

local function Vectorize(lhs,rhs,fn)
    local res = VOjbect()
    local a,b = type(lhs) == "table" and lhs.__is_class == false and lhs:class() == VOjbect, type(rhs) == "table" and rhs.__is_class == false and rhs:class() == VOjbect

    if a and b then
        local l = #lhs
        if l ~= rhs.size then
            error("VOjbect size mismatch in Vectorized operation.")
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

local function __add(a,b) return a + b end
local function __sub(a,b) return a - b end
local function __mul(a,b) return a * b end
local function __div(a,b) return a / b end
local function __mod(a,b) return a % b end
local function __pow(a,b) return a ^ b end
local function __unm(a) return -a end
local function __eq(a,b) return a == b end
local function __lt(a,b) return a < b end
local function __le(a,b) return a <= b end
local function __tostring(a) return tostring(a) end

function VOjbect.__add(lhs,rhs)
    return Vectorize(lhs,rhs,__add)
end

function VOjbect.__sub(lhs,rhs)
    return Vectorize(lhs,rhs,__sub)
end

function VOjbect.__mul(lhs,rhs)
    return Vectorize(lhs,rhs,__mul)
end

function VOjbect.__div(lhs,rhs)
    return Vectorize(lhs,rhs,__div)
end

function VOjbect.__mod(lhs,rhs)
    return Vectorize(lhs,rhs,__mod)
end

function VOjbect.__pow(lhs,rhs)
    return Vectorize(lhs,rhs,__pow)
end

function VOjbect.__unm(v)
    return Vectorize(v,nil,__unm)
end

function VOjbect.__eq(lhs,rhs)
    return Vectorize(lhs,rhs,__eq)
end

function VOjbect.__lt(lhs,rhs)
    return Vectorize(lhs,rhs,__lt)
end

function VOjbect.__le(lhs,rhs)
    return Vectorize(lhs,rhs,__le)
end

function VOjbect.__tostring(v)
    local l = #v
    local str = Vectorize(v, nil, __tostring)
    local out = ""
    for i = 1,l do
        out = out .. i .. ": " .. str[i]
        if i+1 <= l then
            out = out .. "\n"
        end
    end
    return out
end

setmetatable(VOjbect, { __call = VOjbect.__call, __index = Object })