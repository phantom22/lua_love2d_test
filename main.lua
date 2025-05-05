require "lib.lib"
require "helpers"

frame = 0

local color_hover, color_normal = RGB(1,1,1), HSL(0,1,0.5)

local p, hover
local ac = Animation({duration_in=ms(150),duration_out=ms(150),ease_out=Easing.out_quad})

function love.load()
    p = Rect(300,300,100,300,1,1,0)
    p.transform:set_drot(math.pi/16)
    p.transform:set_dpos(15,15)
end

local t = 0
local hover_t = 0

function love.update(dt)
    local m = Vec2(love.mouse.getPosition())

    hover = p:mouse_hover(m)
    hover_t = ac:get_t(hover, dt)

    if hover_t <= 0.1 then
        t = (t + dt/10) % 1
        color_normal[1] = t
    end

    if not hover then
        p.transform:update(dt)
    end
end

function love.draw()
    vmath.lerp(color_normal:to_rgb(), color_hover, hover_t):setLoveColor()

    p:draw()

    frame = frame + 1
end