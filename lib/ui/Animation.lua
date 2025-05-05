Timing = {
    timing_in = function (ac,dt)
        ac.ctime = math.min(ac.ctime + dt, ac.duration)
    end,
    timing_out = function (ac,dt)
        ac.ctime = math.max(ac.ctime - dt * ac.out_scale, 0)
    end
}

Easing = {
    linear = function (t)
        return t
    end,
    in_quad = function (t)
        return t * t
    end,
    out_quad = function (t)
        return t * (2 - t)
    end,
    in_out_cubic = function (t)
        return t < 0.5 and 4 * t * t * t or 1 - math.pow(-2 * t + 2, 3) / 2
    end,
    out_elastic = function (t)
        local p = 0.3
        return math.pow(2, -10 * t) * math.sin((t - p/4) * (2 * math.pi) / p) + 1
    end
}

Animation = Object:extend()

--- specify EITHER duration OR duration_in AND duration_out:
--- 
---  * if duration is specified, it will be treated as the duration for BOTH the in AND out animations;
---  * all durations are assumed to be in milliseconds.
--- 
--- for custom ease functions, specify EITHER ease OR ease_in AND/OR ease_out:
--- 
---  * if ease is specified, it will be treated as the ease function for BOTH the ease_in AND ease_out animations.
--- 
--- for custom timing functions, specify timing_in AND/OR timing_out
function Animation:init(args)
    args = args or {}

    if args.duration then
        self.duration = args.duration / 2000
        self.out_scale = 1
    else
        self.duration = args.duration_in / 1000
        self.out_scale = args.duration_in / args.duration_out
    end

    if args.ease then
        self.ease_in = args.ease
        self.ease_out = args.ease
    else
        self.ease_in = args.ease_in or Easing.linear
        self.ease_out = args.ease_out or Easing.linear
    end

    self.prev_t = 0
    self.ctime = 0

    self.timing_in = args.timing_in or Timing.timing_in
    self.timing_out = args.timing_out or Timing.timing_out

    self.cycle = false
end

function Animation:get_t(anim_in, dt)
    if anim_in then
        self:timing_in(dt)
        self:onEaseIn()
    else
        self:timing_out(dt)
        self:onEaseOut()
    end
    self:onUpdate()

    local t, prev_t = math.max(math.min(self.ctime / self.duration, 1), 0), self.prev_t

    if anim_in then
        t = self.ease_in(t)
    else
        t = 1-self.ease_out(1-t)
    end

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

function Animation:onEaseIn() end
function Animation:onEaseOut() end
function Animation:onUpdate() end
function Animation:onCycleStart() end
function Animation:onCycleHalf() end
function Animation:onCycleEnd() end
function Animation:onCycleRestart() end
function Animation:onCycleHalfContinue() end