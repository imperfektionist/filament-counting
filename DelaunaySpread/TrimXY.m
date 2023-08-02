function xy = TrimXY(xy, par)

% Sort the points by y-value
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