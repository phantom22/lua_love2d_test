local inf = math.huge

Polygon = Object:extend()

function Polygon:init(x,y,w,h,sx,sy,rot,crnrs)
    self.og_corners = Vector()
    self.corners = Vector()
    self.bbox = nil
    self.og_w = 0
    self.og_h = 0
    self.w = w
    self.h = h
    self.transform = Transform(x,y,sx,sy,rot)

    local nargs = #crnrs

    if nargs < 3 then
        error("A polygon must consist of at least 3 corners")
    end

    for i = 1,nargs do
        local c = crnrs[i]

        if not Object.is_class(c) or not c:is(Vec2) then
            error("All the corners of a polygon must be of type Vec2.")
        end

        self.og_corners[i] = c
    end

    self:update_corners()
end

function Polygon:update_corners()
    local nargs = #self.og_corners
    local min_w, max_w = inf, -inf
    local min_h, max_h = inf, -inf

    for i = 1,nargs do
        local x,y = self.og_corners[i].x, self.og_corners[i].y

        if x > max_w then
            max_w = x
        end

        if x < min_w then
            min_w = x
        end

        if y > max_h then
            max_h = y
        end

        if y < min_h then
            min_h = y
        end
    end

    self.og_w = max_w - min_w
    self.og_h = max_h - min_h

    local wf, hw = self.og_w / self.w, self.og_h /self.h

    for i = 1,nargs do
        local c = self.og_corners[i]
        self.corners[i] = Vec2(c.x*wf, c.y*hw)
    end
end

function Polygon:get_corners()
    local cs, nargs = Vector(), #self.corners
    local min_x, max_x = inf, -inf
    local min_y, max_y = inf, -inf

    local T = self.transform.T
    for i = 1,nargs do
        local p = (T * self.corners[i]:to_vec3()):to_vec2()

        local x,y = p.x, p.y

        if x > max_x then
            max_x = x
        end

        if x < min_x then
            min_x = x
        end

        if y > max_y then
            max_y = y
        end

        if y < min_y then
            min_y = y
        end

        cs[(i-1)*2+1] = x
        cs[i*2] = y
    end

    self.bbox = { min_x, max_x, min_y, max_y }

    return cs
end

function Polygon:mouse_over_bbox(m)
    return self.bbox ~= nil and m.x >= self.bbox[1] and m.x <= self.bbox[2] and m.y >= self.bbox[3] and m.y <= self.bbox[4]
end

function Polygon:mouse_hover()
    return false
end

function Polygon:get_T()
    return self.transform.T
end

function Polygon:get_inv_T()
    return self.transform.inv_T
end