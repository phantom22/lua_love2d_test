Color = {}
function Color.unpack(c)
    if #c == 4 then
        return c[1], c[2], c[3], c[4]
    else
        return c[1], c[2], c[3], 1
    end
end