local tol = 1e-3

function _throws_err(f,...)
    return not pcall(f,...)
end

function _num_eq(a,b)
    return math.abs(a-b) <= tol
end

function _eq(a,b)
    local t = type(a)
    if t ~= type(b) then
        return false
    end
    
    if t == "nil" or t == "string" or t =="boolean" or t == "function" then
        return a == b
    elseif t == "number" then
        return _num_eq(a,b)
    elseif t == "table" then
        local ca,cb = is_class(a),is_class(b)
        local va,vb = is_vector(a),is_vector(b)
        local ia,ib = is_inst(a),is_inst(b)

        if (ca and not cb) or (not ca and cb) or (va and not vb) or (not va and vb) or (ia and not ib) or (not ia and ib) then
            return false
        end

        if ca then
            return a == b
        elseif va then
            local la = #a
            if la ~= #b then
                return false
            end

            local r = true
            for i=1,la do
                if not _eq(a[i],b[i]) then
                    r = false
                    break
                end
            end
            return r
        elseif ia then
            if a:class() ~= b:class() then
                return false
            end

            local r = true
            for k,v in pairs(a) do
                local j = _eq(v,b[k])
                if not j then
                    r = false
                    break
                end
            end
            return r
        else
            local r = true
            for k,v in ipairs(a) do
                if not _eq(v,b[k]) then
                    r = false
                    break
                end
            end
            return r
        end
    else
        error("_eq: UNSUPPORTED TYPE '"..t.."'")
    end
end

local data = {}
local failed = 0
function assert_eq(a,b,name)
    local r = _eq(a,b)
    if not r then
        failed = failed + 1
    end
    table.insert(data, {res=r, name=name})
end

function assert_neq(a,b,name)
    local r = _eq(a,b)
    if r then
        failed = failed + 1
    end
    table.insert(data, {res=not r, name=name})
end

function assert_true(c,name)
    if not c then
        failed = failed + 1
    end
    table.insert(data, {res=c, name=name})
end

function assert_false(c,name)
    if c then
        failed = failed + 1
    end
    table.insert(data, {res=not c, name=name})
end

function assert_error(f,args,name)
    local r = pcall(f,unpack(args))
    if r then
        failed = failed + 1
    end
    table.insert(data, {res=not r, name=name})
end

function assert_summary(file_name)
    local l = #data

    print("["..file_name.."] "..l-failed.."/"..l.." tests passed")

    for i = 1,l do
        local entry = data[i]
        if not entry.res then
            print("test #"..i..": "..entry.name.." FAILED")
        end
    end
    data = {}
    failed = 0
end
