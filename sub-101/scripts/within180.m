function degree = within180(input) %requires input be within -360 to 360
    for k = 1:length(input)
        if input(k) > 180 
            degree(k) = input(k)-360;
        elseif input(k) < -180
            degree(k) = input(k) + 360;
        else
            degree(k) = input(k);
        end
        if degree(k) > 180 
            degree(k) = degree(k)-360;
        elseif degree(k) < -180
            degree(k) = degree(k) + 360;
        else
            degree(k) = degree(k);
        end
    end
end
