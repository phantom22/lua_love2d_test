function print_on_frame(msg,int)
    int = int or 60
    if frame % int == 0 then
        print(tostring(msg))
    end
end

function clamp(x,m,M)
    if x > M then
        return M
    end
    if x < m then
        return m
    end
    return x
end