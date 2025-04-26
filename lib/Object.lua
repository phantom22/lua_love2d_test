Object = { __is_class = true }
Object.__index = Object

function Object:init(...) end

function Object:extend()
    -- child class
    local cls = {}
    cls.__is_class = true

    for k, v in pairs(self) do
        if k:find("__") == 1 then cls[k] = v end
    end

    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
end

function Object:is(T)
    local mt = getmetatable(self)
    while mt do
        if mt == T then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end

function Object:__call(...)
    if not is_class(self) then
        error("Cannot call constructor on instance.")
    end
    local obj = setmetatable({}, self)
    obj.__is_class = nil
    obj.__is_inst = true
    obj:init(...)
    return obj
end

function Object:classname()
    return "Object"
end

function class(x)
    return type(x) == "table" and rawget(x, "__is_class") == true and x or getmetatable(x)
end
Object.class = class

function Object:cast_from(src)
    return src:is(self) -- Only allow upcasts by default
end

-- this permanently changes the metatable of a table.
function Object:cast(to)
    if type(to) ~= "table" or not to.__is_class then
        error("Couldn't cast '"..self:classname().."' because the target type is invalid!")
    end
    if not to:cast_from(self) then
        error("Casting '"..self:classname().."' to '"..to:classname().."' is not allowed!")
    end
    setmetatable(self, to);
    return self
end

function is_class(x)
    return type(x) == "table" and rawget(x, "__is_class") == true
end
Object.is_class = is_class

function is_inst(x)
    return type(x) == "table" and rawget(x, "__is_inst") == true
end
Object.is_inst = is_inst

function Object.__tostring(v)
    return rawget(v, "__is_class") == true and v.classname().." type" or "Object instance"
end

setmetatable(Object, { 
    __call = Object.__call,
})