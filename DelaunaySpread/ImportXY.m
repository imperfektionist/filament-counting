% IMPORT AND TRIM UNCOILED XY FILAMENT POSITIONS
function [xy, par] = ImportXY(csvFileName, par)

% Read the CSV file using the readmatrix function
data = readmatrix(fullfile('UserData', csvFileName));

% Extract the X and Y coordinates from the data
x = data(:,1);
y = data(:,2);
xy = horzcat(x, y);  % make one matrix

% Step 1: Sort the points by y-value
[~, y_idx] = sort(xy(:,2));
points_sorted_y = xy(y_idx,:);

% Remove the top and bottom 20% of points by y-value
num_points_y = size(xy,1);
num_remove_y = round(num_points_y * par.skimPercentY);
points_sorted_y = points_sorted_y(num_remove_y+1:end-num_remove_y,:);

% Sort the remaining points by x-value
[~, x_idx] = sort(points_sorted_y(:,1));
points_sorted_x = points_sorted_y(x_idx,:);

% Remove the top and bottom 10% of points by x-value
num_points_x = size(points_sorted_x,1);
num_remove_x = round(num_points_x * par.skimPercentX);
xy = points_sorted_x(num_remove_x+1:end-num_remove_x,:);

% Align with x = 0
%xy(:,1) = xy(:,1) - min(xy(:,1));

% True limits
lim.xmin = min(xy(:,1));
lim.xmax = max(xy(:,1));
lim.ymin = min(xy(:,2));
lim.ymax = max(xy(:,2));
par.lim_true = lim;

if par.exportXY
    writematrix(xy, fullfile('UserData', par.outFile)) %#ok<*UNRCH> 
end