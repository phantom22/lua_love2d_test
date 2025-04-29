RGBa = Object:extend()
function RGBa:init(r,g,b,a)
    self.v = Vector({r,g,b,a})
end
function RGBa:unpack()
    return self.v[1], self.v[2], self.v[3], self.v[4]
end

RGB = Object:extend()
function RGB:init(r,g,b)
    self.v = Vector({r,g,b})
end
function RGB:unpack()
    return self.v[1], self.v[2], self.v[3], 1
end

HSV = Object:extend()
function HSV:init(h,s,v)
    self.hsv = Vector({h,s,v})
    self.v = Vector({})
end
function HSV:update_v()
    local h,s,v = self.hsv[1], self.hsv[2], self.hsv[3]
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

    self.v[1],self.v[2],self.v[3] = r+m,g+m,b+m
end
function HSV:unpack()
    self:update_v()
    return self.v[1], self.v[2], self.v[3], 1
end