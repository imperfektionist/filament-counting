% Clamp value to interval a and b
function val = Clamp(val, a, b)
    
    for i = 1:length(val)
        if val(i) < a
            val(i) = a;
        elseif val(i) > b
            val(i) = b;
        end
    end
end