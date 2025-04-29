Transform = Object:extend()

function Transform:init(x,y,sx,sy,rot)
    x = x or 0
    y = y or 0
    sx = sx or 1
    sy = sy or 1
    rot = rot or 0

    self.x = x
    self.y = y
    self.sx = sx
    self.sy = sy
    self.rot = rot
    self.T = nil
    self.inv_T = nil

    self.d = {
        x = 0,
        y = 0,
        sx = 0,
        sy = 0,
        rot = 0
    }

    self:update()
end

function Transform:get_pos()
    return Vec2(self.x, self.y)
end

function Transform:update(dt)
    dt = dt or (1/60)

    self.x = self.x + self.d.x * dt
    self.y = self.y + self.d.y * dt
    self.sx = self.sx + self.d.sx * dt
    self.sy = self.sy + self.d.sy * dt
    self.rot = self.rot + self.d.rot * dt

    self.T = Mat3.scale_rot_transl(self.sx,self.sy,self.rot,self.x,self.y)
    self.inv_T = self.T:inv()
end

function Transform:set_scale(sx,sy)
    self.sx = sx
    self.sy = sy
end

function Transform:add_scale(sx,sy)
    self.sx = self.sx + sx
    self.sy = self.sy + sy
end

function Transform:set_dscale(sx,sy)
    self.d.sx = sx
    self.d.sy = sy
end

function Transform:set_pos(x,y)
    self.x = x
    self.y = y
end

function Transform:add_pos(dx,dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Transform:set_dpos(x,y)
    self.d.x = x
    self.d.y = y
end

function Transform:set_rot(rot)
    self.rot = rot
end

function Transform:add_rot(rot)
    self.rot = self.rot + rot
end

function Transform:set_drot(rot)
    self.d.rot = rot
end