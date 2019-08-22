function degree = within360(input) %requires that input is never > 720 or < -360, note that 0 degrees becomes 360 degrees
    for k = 1:length(input)
        if input(k) <= 0 
            degree(k) = input(k)+360;
        elseif input(k) > 360
            degree(k) = input(k)-360;
        else
            degree(k) = input(k);
        end
        if input(k) <= 0 
            degree(k) = input(k)+360;
        elseif input(k) > 360
            degree(k) = input(k)-360;
        else
            degree(k) = input(k);
        end
    end
end
