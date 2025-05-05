Timing = {
    timing_in = function (ac,dt)
        ac.ctime = math.min(ac.ctime + dt, ac.duration)
    end,
    timing_out = function (ac,dt)
        ac.ctime = math.max(ac.ctime - dt * ac.out_scale, 0)
    end
}

Easing = {
    no_ease = function (t)
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

-- args = {duration,timing_in?,timing_out?,ease_in?,ease_out?} or {duration_in,duration_out,timing_in?,timing_out?,ease_in?,ease_out?}
-- self.duration stands for duration_in
-- self.out_scale just rescales the passed dt to update_fn
function Animation:init(args)
    args = args or {}

    if args.duration then
        self.duration = args.duration / 2
        self.out_scale = 1
    else
        self.duration = args.duration_in
        self.out_scale = self.duration / args.duration_out
    end

    if args.ease then
        self.ease_in = args.ease
        self.ease_out = args.ease
    else
        self.ease_in = args.ease_in or Easing.no_ease
        self.ease_out = args.ease_out or Easing.no_ease
    end

    self.prev_t = 0
    self.ctime = 0

    self.timing_in = Timing.timing_in
    self.timing_out = Timing.timing_out

    self.cycle = false
end

function Animation:get_t(anim_in, dt)
    self:onUpdate()

    if anim_in then
        self:timing_in(dt)
        self:onTrue()
    else
        self:timing_out(dt)
        self:onFalse()
    end

    local t, prev_t = math.min(self.ctime / self.duration, 1), self.prev_t

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

function Animation:onTrue() end
function Animation:onFalse() end
function Animation:onUpdate() end
function Animation:onCycleStart() end
function Animation:onCycleHalf() end
function Animation:onCycleEnd() end
function Animation:onCycleRestart() end
function Animation:onCycleHalfContinue() end

function ms(n)
    return n / 1000
end