% Step 1: Load and Prepare Data
xy_true = readmatrix("UserData/BU2281_LR_COLL.txt");

% plot(xy_true(:,1), xy_true(:,2), 'k.')

% Define the desired number of points in the new set
desired_num_points = 4000;  % Change this as needed



% Calculate the distance matrix between all pairs of points
distances = pdist(xy_true);

% Create a cumulative distribution function (CDF) based on the distance matrix
cdf = cumsum(1./distances);
cdf = cdf / cdf(end);

% Generate a random set of distances using the CDF
rand_distances = interp1(cdf, distances, rand(desired_num_points, 1), 'linear', 'extrap');

% Select a subset of points from xy_true to act as reference points
num_reference_points = min(desired_num_points, 100);  % You can adjust this number
reference_indices = randperm(size(xy_true, 1), num_reference_points);
reference_points = xy_true(reference_indices, :);

% Preallocate new_points for speed
new_points = zeros(desired_num_points, 2);

% Generate new points around the reference points using random distances
idx = 1;
for i = 1:num_reference_points
    num_new_points = sum(rand_distances > 0 & rand_distances <= rand_distances(reference_indices(i)));
    if num_new_points > 0
        if idx + num_new_points - 1 > desired_num_points
            num_new_points = desired_num_points - idx + 1;  % Adjust num_new_points to fit the desired size
        end
        angles = 2 * pi * rand(num_new_points, 1);
        new_points(idx:idx+num_new_points-1, :) = repmat(reference_points(i, :), num_new_points, 1) + [cos(angles), sin(angles)] * rand_distances(reference_indices(i));
        idx = idx + num_new_points;
        if idx > desired_num_points
            break;  % Exit the loop once we have enough points
        end
    end
end

% Display the new pointset
scatter(new_points(:, 1), new_points(:, 2), 'filled');
