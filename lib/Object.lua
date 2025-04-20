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
    if not Object.is_class(self) then
        error("Cannot call constructor on instance.")
    end
    local obj = setmetatable({}, self)
    obj.__is_class = false
    obj:init(...)
    return obj
end

function Object:classname()
    return "Object"
end

function Object:class()
    return self.__is_class and self or getmetatable(self)
end

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

function Object.is_class(x)
    return type(x) == "table" and rawget(x, "__is_class") == true
end

function Object.__concat(lhs,rhs)
    return VOjbect.concatenate(lhs,rhs)
end

setmetatable(Object, { __call = Object.__call })