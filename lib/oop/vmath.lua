local function vectorize_m_un(v,num_f,cl_f)
    local res,l = getmetatable(v)(), #v
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
    local res = nil
    local a,b = is_vector(l), is_vector(r)

    if a and b then
        local n = #l
        res = getmetatable(l)()
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
        res = getmetatable(l)()

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
        res = getmetatable(r)()

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
    local res,l = getmetatable(v)(), #v
    if l == 0 then
        return res
    end

    for i = 1,l do
        res[i] = math.log(v[i], base)
    end

    return res
end

function vmath.modf(v)
    local constr = getmetatable(v)
    local a,b,l = constr(), constr(), #v
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

function vmath.clamp(v,m,M)
    local o,l = getmetatable(v)(), #v
    if l == 0 then
        return o
    end

    for i = 1,l do
        local t = v[i]
        if t > M then
            t = M
        elseif t < m then
            t = m
        end
        o[i] = t
    end

    return o
end

function vmath.lerp(v,w,t)
    local o,l = getmetatable(v)(), #v

    if l == 0 then
        return o
    end

    for i = 1,l do
        o[i] = v[i] * (1-t) + w[i] * t
    end

    return o
end