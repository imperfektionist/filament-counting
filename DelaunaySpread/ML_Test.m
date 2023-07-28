% Define study region dimensions
width = 100;
height = 100;

% Set the number of iterations
numIterations = 1000;

% Set the interaction range (distance)
interactionRange = 5;

% Initialize the point pattern with random points
numPoints = 50;
pointsX = rand(numPoints, 1) * width;
pointsY = rand(numPoints, 1) * height;

% Preallocate arrays for updated points
newPointsX = zeros(numPoints, 1);
newPointsY = zeros(numPoints, 1);

% Main Gibbs sampling loop
for iter = 1:numIterations
    % Create a random permutation of point indices
    permIndices = randperm(numPoints);
    
    % For each point, update its position
    for i = 1:numPoints
        % Get the current index from the permutation
        currentIndex = permIndices(i);
        
        % Remove point at the current index from the point pattern
        currentX = pointsX(currentIndex);
        currentY = pointsY(currentIndex);
        pointsX(currentIndex) = [];
        pointsY(currentIndex) = [];
        
        % Calculate the conditional intensity at the current location
        % based on other points
        conditionalIntensity = calculateConditionalIntensity(currentX, currentY, pointsX, pointsY, interactionRange);
        
        % Sample new position for the point from the conditional intensity
        newX = rand * width;
        newY = rand * height;
        
        % Add the point back to the point pattern
        newPointsX(currentIndex) = newX;
        newPointsY(currentIndex) = newY;
        
        % Append the newly sampled points back to the point pattern
        pointsX = [pointsX; newX];
        pointsY = [pointsY; newY];
    end
    
    % Update the point pattern with the newly sampled points
    pointsX = newPointsX;
    pointsY = newPointsY;
end

% Visualize the final point pattern after the loop
figure;
scatter(pointsX, pointsY, 'b', 'filled');
xlim([0, width]);
ylim([0, height]);
title('Final Point Pattern');


% Function to calculate the conditional intensity at a specific location
function conditionalIntensity = calculateConditionalIntensity(x, y, pointsX, pointsY, interactionRange)
    % In this simple example, we assume a constant intensity within the interaction range
    distances = sqrt((x - pointsX).^2 + (y - pointsY).^2);
    numPointsWithinRange = sum(distances <= interactionRange);
    conditionalIntensity = numPointsWithinRange / (pi * interactionRange^2);
end
