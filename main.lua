--package.path = package.path .. ";./lib/?.lua" --specifies to love where to find lib/ files.. workaround
require "lib.lib"
io.stdout:setvbuf("no") -- workaround for enabling prints to console

frame = 0

local p, hover, prev_hover
function love.load() -- (x,y,w,h,sx,sy,rot)
    p = Rect(300,300,100,15,1,1,0)
    p.transform:set_drot(math.pi/16*8)
    p.transform:set_dpos(15,15)
end

function love.update(dt)
    if not hover then
        p.transform:update(dt)
    end

    local m = Vec2(love.mouse.getPosition())

    hover = p:mouse_hover(m)
end

local color_hover, color_normal = {1,0,0,1}, {1,1,1,1}
function love.draw()
    if hover ~= prev_hover then
        if hover then
            love.graphics.setColor(unpack(color_hover))
        else
            love.graphics.setColor(unpack(color_normal))
        end
        prev_hover = hover
    end

    love.graphics.polygon("fill", p:get_corners())

    frame = frame + 1
end