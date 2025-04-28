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
    if cond then
        self:onUpdate()
    end
    local t, prev_t = math.min(self.ctime / self.duration, 1), self.prev_t
    if prev_t ~= 0 and t == 0 then
        if not self.cycle then
            self:onRestart()
        else
            self.cycle = false
            self:onCycleEnd()
        end
    elseif prev_t ~= 1 and t == 1 then
        self.cycle = true
        self:onEnd()
    end
    self.prev_t = t
    return t
end
function AnimController:onUpdate() end
function AnimController:onCycleEnd() end
function AnimController:onRestart() end
function AnimController:onEnd() end

ms = 1/1000