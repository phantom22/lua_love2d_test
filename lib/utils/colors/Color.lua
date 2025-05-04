local function rgb2hsl(self)
    local r,g,b = self[1],self[2],self[3]
    local max = math.max(r,g,b)
    local min = math.min(r,g,b)
    local h,s,l

    local mmm,mpm = max - min, max + min

    -- Calculate lightness
    l = mpm / 2

    -- Calculate saturation
    if max == min then
        s = 0
    else
        if l <= 0.5 then
            s = mmm / mpm
        else
            s = mmm / (2 - mmm)
        end
    end

    -- Calculate hue
    if max == min then
        h = 0 -- achromatic (gray)
    else
        if max == r then
            h = (g - b) / mmm
        elseif max == g then
            h = 2 + (b - r) / mmm
        else -- max == b
            h = 4 + (r - g) / mmm
        end

        h = h / 6 -- convert to degrees
        if h < 0 then
            h = h + 1
        end
    end

    return h, s, l
end

local function hsv2rgb(self)
    local h,s,v = self[1], self[2], self[3]
    local c, h_ = s*v, h*6
    local x = c * (1-math.abs(math.fmod(h_,2) - 1))
    local r,g,b = 0,0,0
    if h_ < 1 then
        r,g = c,x
    elseif h_ < 2 then
        r,g = x,c
    elseif h_ < 3 then
        g,b = c,x
    elseif h_ < 4 then
        g,b = x,c
    elseif h_ < 5 then
        r,b = x,c
    else -- h_ < 6
        r,b = c,x
    end
    local m = v - c

    return r+m, g+m, b+m
end

local function hueToRgb(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 0.16666 then return p + (q - p) * 6 * t end
    if t < 0.5 then return q end
    if t < 0.66666 then return p + (q - p) * (0.66666 - t) * 6 end
    return p
end

local function hsl2rgb(self)
    local h,s,l = self[1], self[2], self[3]

    if s == 0 then
        -- Achromatic (gray)
        return l, l, l
    else
        local q = l < 0.5 and l*(1+s) or l*(1-s)+s
        local p = 2 * l - q

        return hueToRgb(p,q,h+0.33333), hueToRgb(p,q,h), hueToRgb(p,q,h-0.33333)
    end
end

Color = Vector:extend()
function Color:set(x,y,z,w)
    self[1] = x
    self[2] = y
    self[3] = z
    self[4] = w
end
function Color:setLoveColor()
    love.graphics.setColor(self:unpack())
end

RGB = Color:extend()
function RGB:unpack()
    return self[1], self[2], self[3], 1
end
function RGB:to_hsl()
    return HSL(rgb2hsl(self))
end
function RGB:__tostring()
    return "RGB("..self[1]..","..self[2]..","..self[3]..")"
end

RGBa = RGB:extend()
function RGBa:unpack()
    return self[1], self[2], self[3], self[4]
end
function RGBa:__tostring()
    return "RGBa("..self[1]..","..self[2]..","..self[3]..","..self[4]..")"
end

HSL = Color:extend()
function HSL:unpack()
    return hsl2rgb(self)
end
function HSL:to_rgb()
    return RGB(hsl2rgb(self))
end
function HSL:__tostring()
    return "HSL("..self[1]..","..self[2]..","..self[3]..")"
end

HSV = Color:extend()
function HSV:unpack()
    return hsv2rgb(self)
end
function HSV:to_rgb()
    return RGB(hsv2rgb(self))
end
function HSV:__tostring()
    return "HSV("..self[1]..","..self[2]..","..self[3]..")"
end