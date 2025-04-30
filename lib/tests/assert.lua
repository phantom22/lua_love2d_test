local tol = 1e-3

local function num_eq(a,b)
    return math.abs(a-b) <= tol
end

local function eq(a,b)
    local t = type(a)
    if t ~= type(b) then
        return false
    end
    
    if t == "nil" or t == "string" or t =="boolean" or t == "function" then
        return a == b
    elseif t == "number" then
        return num_eq(a,b)
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
                if not eq(a[i],b[i]) then
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
                local j = eq(v,b[k])
                if not j then
                    r = false
                    break
                end
            end
            return r
        else
            local r = true
            for k,v in ipairs(a) do
                if not eq(v,b[k]) then
                    r = false
                    break
                end
            end
            return r
        end
    else
        error("eq: UNSUPPORTED TYPE '"..t.."'")
    end
end

local data = {}
local failed = false
function assert_eq(a,b,name)
    local r = eq(a,b)
    failed = failed or not r
    table.insert(data, {res=r, name=name})
end

function assert_neq(a,b,name)
    local r = eq(a,b)
    failed = failed or r
    table.insert(data, {res=not r, name=name})
end

function assert_summary(file_name)
    local l = #data

    if failed then
        print("["..file_name.."] result: failed")
    else
        print("["..file_name.."] result: passed")
    end
    for i = 1,l do
        local entry = data[i]
        if entry.res then
            print("("..i.."/"..l..") "..entry.name.."  PASSED")
        else
            print("("..i.."/"..l..") "..entry.name.."  FAILED")
        end
    end
    data = {}
    failed = false
end