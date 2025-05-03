AnimController = Object:extend()
local function update_fn(ac,cond,dt)
    if cond then
        ac.ctime = math.min(ac.ctime + dt, ac.duration)
    elseif ac.ctime > 0 then
        ac.ctime = math.max(ac.ctime - dt, 0)
    end
end
function AnimController:init(duration,fn)
    self.prev_t = 0
    self.duration = duration
    self.ctime = 0
    self.update_fn = fn or update_fn
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

ms = 1/1000