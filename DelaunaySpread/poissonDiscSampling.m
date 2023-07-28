function points = poissonDiscSampling(bounds_min, bounds_max, min_distance, num_points)
    % Initialize variables
    cell_size = min_distance / sqrt(2);
    cols = floor((bounds_max(1) - bounds_min(1)) / cell_size) + 1;
    rows = floor((bounds_max(2) - bounds_min(2)) / cell_size) + 1;
    grid = -ones(rows, cols);
    points = zeros(num_points, 2);
    queue = zeros(num_points * 10, 2);
    queue_size = 0;
    point_index = 1;
    max_attempts = 30; % Increase this value for more attempts

    % Randomly select the first point within the bounds
    first_point = rand(1, 2) .* (bounds_max - bounds_min) + bounds_min;
    queue_size = queue_size + 1;
    queue(queue_size, :) = first_point;
    points(point_index, :) = first_point;
    point_index = point_index + 1;
    gridIndex = floor((first_point - bounds_min) / cell_size) + 1;
    grid(gridIndex(2), gridIndex(1)) = point_index;

    while point_index <= num_points && queue_size > 0
        randomIndex = randi(queue_size);
        current_point = queue(randomIndex, :);
        queue(randomIndex, :) = queue(queue_size, :);
        queue_size = queue_size - 1;

        attempts = 0;
        while attempts < max_attempts
            theta = 2 * pi * rand();
            r = min_distance + min_distance * rand();
            new_point = current_point + [cos(theta), sin(theta)] * r;

            if new_point(1) >= bounds_min(1) && new_point(1) <= bounds_max(1) ...
                    && new_point(2) >= bounds_min(2) && new_point(2) <= bounds_max(2)
                gridIndex = floor((new_point - bounds_min) / cell_size) + 1;
                x = gridIndex(1);
                y = gridIndex(2);

                isValid = true;
                for dx = -2:2
                    for dy = -2:2
                        nx = x + dx;
                        ny = y + dy;
                        if nx >= 1 && nx <= cols && ny >= 1 && ny <= rows && grid(ny, nx) > 0
                            dist = norm(new_point - points(grid(ny, nx), :));
                            if dist < min_distance
                                isValid = false;
                                break;
                            end
                        end
                    end
                    if ~isValid
                        break;
                    end
                end

                if isValid
                    queue_size = queue_size + 1;
                    queue(queue_size, :) = new_point;
                    point_index = point_index + 1;
                    points(point_index, :) = new_point;
                    grid(gridIndex(2), gridIndex(1)) = point_index;
                    break;
                end
            end
            
            attempts = attempts + 1;
        end
    end

    points = points(1:min(point_index-1, num_points), :);
end
