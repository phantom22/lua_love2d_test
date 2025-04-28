require "lib.lib"

frame = 0

local color_hover, color_normal = Vector({1,0,0}), Vector({1,1,1})
local color_curr = color_normal

local p, hover
local ac = AnimController(150 * ms)

ac.onUpdate = function()
    color_hover = vmath.clamp(color_hover + vmath.random(3,-255,255) / (255 * 100), 0, 1)

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
    color_curr = color_normal * (1-t) + color_hover * t

    if not hover then
        p.transform:update(dt)
    end
end


function love.draw()
    love.graphics.setColor(Color.unpack(color_curr))

    love.graphics.polygon("fill", p:get_corners())

    frame = frame + 1
end