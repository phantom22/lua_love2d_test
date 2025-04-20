local Op = {};

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

function ObjectOp:init(root_class,op_symbol,...)
    self.ops = {}

    if not Object.is_class(root_class) then
        error("The first argument passed to ObjectOp must be of type class.")
    end

    if type(op_symbol) ~= "string" then
        error("The second argument passed to ObjectOp must be the string that represents the operator.")
    end

    self.op_symbol = op_symbol

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
        local op
        if root_class == other_type then
            op = Op.interclass
        elseif ot_type == "string" then
            op = fn_com and Op.class_primitive_comm or (invert_operands and Op.primitive_class or Op.class_primitive)
        elseif ot_type == "table" and Object.is_class(other_type) then
            op = fn_com and Op.class_class_comm or Op.class_class
        else
            error("Other type must be either a string or a class.")
        end

        self.ops[i] = { op = op, other_type = other_type, fn = fn, fn_com = fn_com }
    end
end

function ObjectOp:resolve(lhs,rhs)
    rhs = rhs or nil

    local nops, lt, rt, r = #self.ops, type(lhs), type(rhs), nil

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

    error("The "..(lt=="table" and lhs.classname and lhs:classname() or lt).." "..self.op_symbol.." "..(rt=="table" and rhs.classname and rhs:classname() or rt).." operation is not defined.")
end