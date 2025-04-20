local function print_on_frame(msg,int)
    int = int or 60
    if frame % int == 0 then
        print(tostring(msg))
    end
end