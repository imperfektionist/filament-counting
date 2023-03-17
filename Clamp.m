% Clamp value to interval a and b
function val = Clamp(val, a, b)
    if val < a
        val = 1;
    elseif val > b
        val = b;
    end
end