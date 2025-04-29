require "lib.lib"
require "helpers"

frame = 0

local color_hover, color_normal = HSV(0,1,1), HSV(0,0,1)
local color_curr = HSV(0,0,1)

local p, hover
local ac = AnimController(1500 * ms)

ac.onUpdate = function(self)
   color_hover.hsv[1] = self.prev_t
end
ac.onCycleEnd = function()
    color_hover = HSV(0,1,1)
end
local hframe
ac.onCycleHalf = function()
    hframe = frame
end
ac.onCycleHalfContinue = function(self)
    color_hover.hsv[1] = ((frame - hframe) / (self.duration * 60) % 1)
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

    color_curr.hsv = color_normal.hsv * (1-t) + color_hover.hsv * t

    if not hover then
        p.transform:update(dt)
    end
end


function love.draw()
    love.graphics.setColor(color_curr:unpack())

    love.graphics.polygon("fill", p:get_corners())

    frame = frame + 1
end