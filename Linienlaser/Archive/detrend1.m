function data = detrend2(data, direction, degree)
% tangential detrend direction == 1
% axial detrend direction == 2

wb = waitbar(0, "Detrending...");

% Tangential detrend: cycle through rows
if direction == 1
    n = size(data,1);
    for i = 1:n
        data(i,:) = detrend(data(i,:), degree);
        waitbar(i/n, wb, sprintf("Tangential Detrend %d%%", round(i/n*100)));
    end
    close(wb)

% Axial detrend: cycle through columns
elseif direction == 2
    n = size(data,2);
    for i = 1:n
        data(:,i) = detrend(data(:,i), degree);
        waitbar(i/n, wb, sprintf("Axial Detrend %d%%", round(i/n*100)));
    end
    close(wb)

else
    disp("Wrong detrend direction.")
end

