Rect = Polygon:extend()

function Rect:init(x,y,w,h,sx,sy,rot)
    local w2, h2 = w/2, h/2
    self.og_corners = Vector({ Vec2(-w2,-h2), Vec2(-w2,h2), Vec2(w2,h2), Vec2(w2,-h2) }) -- tl, bl, br, tr
    self.corners = Vector({ Vec2(-w2,-h2), Vec2(-w2,h2), Vec2(w2,h2), Vec2(w2,-h2) })
    self.bbox = nil
    self.og_w = w
    self.og_h = h
    self.w = w
    self.h = h
    self.transform = Transform(x,y,sx,sy,rot)
end

function Rect:mouse_hover(m)
    if self:mouse_over_bbox(m) then
        local w2, h2 = self.w/2, self.h/2

        local im = (self.transform.inv_T * m:to_vec3()):to_vec2()

        return -w2 <= im.x and im.x <= w2 and -h2 <= im.y and im.y <= h2
    else
        return false
    end
end


--Rect = setmetatable(Rect, { init = Rect.init, __call = Object.__call, __index = Polygon })