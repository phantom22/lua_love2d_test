Scene = Object:extend()

local function is_visible(scene,i)
    local clip = scene.clip
    local obj = scene.objects[i]
    local corners = obj:get_corners()
    local bbox = obj.bbox

    if (clip[2] >= bbox[1] and bbox[2] >= clip[1]) and (clip[4] >= bbox[3] and bbox[4] >= clip[3]) then
        return corners
    end
    return nil
end

function Scene:init(args)
    args = args or {}
    self.offset = args.offset
    self.dim = args.dim
    self.scale = args.scale or Vec2(1,1)
    self.rot = args.rot or 0

    self.clip = nil
    self.T = nil
    self.inv_T = nil

    self.objects = args.objects or {}
end

function Scene:get_inv_T()
    local s, c = math.sin(self.rot), math.cos(self.rot)

    local w, h = self.dim.x, self.dim.y
    local dx, dy = self.offset.x-w/2, self.offset.y-h/2
    local sx, sy = self.scale.x, self.scale.y
    local isx, isy = 1 / sx, 1 / sy

    local inv_T = Mat3(c*isx, -s*isy, 0, s*isx, c*isy, 0, -(dx*c+dy*s)*isx, -(dy*c-s*dx)*isy, 1)
    self.inv_T = inv_T
    self.T = Mat3(sx*c, sx*s, 0, -sy*s, sy*c, 0, dx, dy, 1)

    self.clip = { dx, dx+w*sx, dy, dy+h*sy }

    return inv_T
end

function Scene:draw()
    local l = #self.objects
    for i = 1,l do
        local corners = is_visible(self, i)
        if corners ~= nil then
            love.graphics.polygon("fill", corners)
        end
    end
end