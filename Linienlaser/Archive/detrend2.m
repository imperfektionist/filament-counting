function data = detrend2(data, direction, degree)
% tangential detrend direction == 1
% axial detrend direction == 2

wb = waitbar(0, "Detrending...");

% Tangential detrend: cycle through rows
if direction == 1
    n = size(data,2);
    y = zeros(1,n);
    for i = 1:n
        y(i) = median(data(:,i));
        waitbar(i/n, wb, sprintf("Tangential detrend %d%%", round(i/n*100)));
    end
    
    x = 1:n;
    coefficients = polyfit(x, y, degree);
    y = polyval(coefficients, x);
    data = data - y;

    close(wb)

% Axial detrend: cycle through columns
elseif direction == 2
    n = size(data,1);
    y = zeros(n,1);
    for i = 1:n
        y(i) = median(data(i,:));
        waitbar(i/n, wb, sprintf("Axial detrend %d%%", round(i/n*100)));
    end

    x = 1:n;
    coefficients = polyfit(x, y, degree);
    y = polyval(coefficients, x)';
    data = data - y;

    close(wb)

else
    disp("Wrong detrend direction.")
end

