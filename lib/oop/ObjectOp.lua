local Op = {};
local name2sym = {
    __add = "+",
    __sub = "-",
    __mul = "*",
    __div = "/",
    __mod = "%",
    __pow = "^",
    __unm = "-",
    __eq = "==",
    __lt = "<",
    __le = "<=",
}

-- exp is assumed to be a class.
function Op.interclass(lhs,rhs,lt,rt,_,fn,_)
    if lt ~= rt or lt ~= "table" or not lhs.class or not rhs.class then
        return nil
    end

    if lhs:class() == rhs:class() then
        return fn(lhs, rhs)
    end

    return nil
end

function Op.class_primitive(lhs,rhs,_,rt,rexp,fn,_)
    if rt == rexp then
        return fn(lhs,rhs)
    end
    return nil
end

function Op.primitive_class(lhs,rhs,lt,_,lexp,fn,_)
    if lt == lexp then
        return fn(lhs,rhs)
    end
    return nil
end

function Op.class_primitive_comm(lhs,rhs,lt,rt,exppr,fn_cl_pr,fn_pr_cl)
    if rt == exppr then
        return fn_cl_pr(lhs,rhs)
    elseif lt == exppr then
        return fn_pr_cl(lhs,rhs)
    end
    return nil
end

function Op.class_class(lhs,rhs,_,rt,expcl,fn,_)
    if rt ~= "table" or not rhs.class then
        return nil
    end

    if rhs:class() == expcl then
        return fn(lhs, rhs)
    end

    return nil
end

function Op.class_class_comm(lhs,rhs,lt,rt,expcl,fn_l_r,fn_r_l)
    if lt ~= rt or lt ~= "table" or not lhs.class or not rhs.class then
        return nil
    end

    local a,b = lhs:class(), rhs:class()
    if b == expcl then
        return fn_l_r(lhs, rhs)
    elseif a == expcl then
        return fn_r_l(lhs, rhs)
    end
    return nil
end

ObjectOp = Object:extend()

-- ObjectOp(Object, <key of an arithmetic meta method>, { othertype = <one of type(x)> or a class, fn:(root_class,othertype), fn_com:(othertype,root_class), invert_operands:boolean }, ...)
-- note that
function ObjectOp:init(root_class,op_key,...)
    self.ops = {}

    if not is_class(root_class) then
        error("The first argument passed to ObjectOp must be of type class.")
    end

    if type(op_key) ~= "string" or name2sym[op_key] == nil then
        error("The second argument passed to ObjectOp must a meta method key of an arithmetic operation. (eg. \"__add\",\"__sub\",...)")
    end

    self.op_key = op_key

    local args = {...}
    local nargs = #args

    for i = 1,nargs do
        local op = args[i]

        if type(op) ~= "table" then
            error("From the third argument, all the passed values to ObjectOp must be of type table.")
        end

        local other_type, fn, fn_com, invert_operands = op.other_type, op.fn, op.fn_com, op.invert_operands

        if fn == nil then
            error("From the third argument, all the passed tables must at least be defined as { other_type, fn }")
        end

        other_type = other_type or "nil" -- this is needed for unary operators, those assume that ObjectOp:resolve receives rhs = nil.

        local ot_type = type(other_type)
        local o
        if root_class == other_type then
            o = Op.interclass
        elseif ot_type == "string" then
            o = fn_com and Op.class_primitive_comm or (invert_operands and Op.primitive_class or Op.class_primitive)
        elseif ot_type == "table" and is_class(other_type) then
            o = fn_com and Op.class_class_comm or Op.class_class
        else
            error("Other type must be either a string or a class.")
        end

        self.ops[i] = { op = o, other_type = other_type, fn = fn, fn_com = fn_com }
    end
end

local function format_type(x)
    local r
    if is_inst(x) then
        r = x:classname()
    elseif is_vector(x) then
        if is_inst(x[1]) then
            r = "Vector<"..x[1]:classname()..">" 
        else
            r = "Vector<"..type(x[1])..">"
        end
    else
        r = type(x)
    end
    return r
end

function ObjectOp:resolve(lhs,rhs)
    rhs = rhs or nil

    local nops, lt, rt, r = #self.ops, type(lhs), type(rhs), nil
    local k = self.op_key

    -- if either lhs or rhs are a Vector, then retrieve their arithmetic meta method and use it instead
    if is_vector(lhs) then
        return getmetatable(lhs)[k](lhs,rhs)
    elseif is_vector(rhs) then
        return getmetatable(rhs)[k](lhs,rhs)
    end

    -- optimization for ObjectOps with only one operation
    if nops == 1 then
        return self.ops[1].op(lhs,rhs,lt,rt,self.ops[1].other_type,self.ops[1].fn,self.ops[1].fn_com)
    end

    for i = 1,nops do
        local o = self.ops[i]
        local op, other_type, fn, fn_com = o.op, o.other_type, o.fn, o.fn_com

        r = op(lhs,rhs,lt,rt,other_type,fn,fn_com)

        if r ~= nil then
            break
        end
    end

    if r ~= nil then
        return r
    end

    error("The "..format_type(lhs).." "..name2sym[k].." "..format_type(rhs).." operation is not defined.")
end