require "lib.lib"
require "helpers"

frame = 0

local color_hover, color_normal = HSL(0,1,0.5), HSL(0,0,1)
local color_curr = HSL(0,0,1)

local p, hover
local ac = AnimController(1500 * ms)

ac.onUpdate = function(self)
    color_hover[1] = self.prev_t
end
ac.onCycleEnd = function()
    color_hover:set(0,1,0.5)
end
local hframe = 0
ac.onCycleHalf = function()
    hframe = frame
end
ac.onFalse = function ()
    hframe = hframe + 1
end
ac.onCycleHalfContinue = function(self)
    color_hover[1] = (((frame - hframe) / (self.duration * 1000)) % 1)
end

function love.load()
    p = Rect(300,300,100,300,1,1,0)
    p.transform:set_drot(math.pi/16)
    p.transform:set_dpos(15,15)
end

function love.update(dt)
    local m = Vec2(love.mouse.getPosition())

    hover = p:mouse_hover(m)

    local t =  ac:get_t(hover, dt)

    color_curr = vmath.lerp(color_normal,color_hover,t)

    if not hover then
        p.transform:update(dt)
    end
end


function love.draw()
    love.graphics.setColor(color_curr:unpack())

    love.graphics.polygon("fill", p:get_corners())

    frame = frame + 1
end