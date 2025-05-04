AnimController = Object:extend()
local function update_fn(ac,cond,dt)
    if cond then
        ac.ctime = math.min(ac.ctime + dt, ac.duration)
    elseif ac.ctime > 0 then
        ac.ctime = math.max(ac.ctime - dt * ac.out_scale, 0)
    end
end

-- args = {duration,fn?} or {duration_in,duration_out,fn?}
function AnimController:init(args)
    args = args or {}
    if args.duration then
        self.duration = args.duration / 2
        self.out_scale = 1
    else
        self.duration = args.duration_in
        self.out_scale = self.duration / args.duration_out
    end
    self.prev_t = 0
    self.ctime = 0
    self.update_fn = args.fn or update_fn
    self.cycle = false
end
function AnimController:get_t(cond, dt)
    self:update_fn(cond, dt)
    self:onUpdate()
    if cond then
        self:onTrue()
    else
        self:onFalse()
    end

    local t, prev_t = math.min(self.ctime / self.duration, 1), self.prev_t
    if t == 0 then
        if prev_t ~= 0 then
            if not self.cycle then
                self:onCycleRestart()
            else
                self.cycle = false
                self:onCycleEnd()
            end
        else
            self:onCycleStart()
        end
    elseif t == 1 then
        if prev_t ~= 1 then
            self.cycle = true
            self:onCycleHalf()
        else
            self:onCycleHalfContinue()
        end
    end
    self.prev_t = t
    return t
end
function AnimController:onTrue() end
function AnimController:onFalse() end
function AnimController:onUpdate() end
function AnimController:onCycleStart() end
function AnimController:onCycleHalf() end
function AnimController:onCycleEnd() end
function AnimController:onCycleRestart() end
function AnimController:onCycleHalfContinue() end

function ms(n)
    return n / 1000
end