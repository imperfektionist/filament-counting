% Specify the CSV file name
csvFileName = 'XY_105x0x0,6_SiC_N10377_df.txt';
outFile = 'BU2265_X96_Y90_df0.615.csv';
skimPercentX = 0.02;  % both left and right X
skimPercentY = 0.05;  % both top and bottom Y

exportXY = 0;

% Read the CSV file using the readmatrix function
data = readmatrix(fullfile('UserData', csvFileName));

% Extract the X and Y coordinates from the data
x = data(:,1);
y = data(:,2);
xy = horzcat(x, y);  % make one matrix

% Step 1: Sort the points by y-value
[~, y_idx] = sort(xy(:,2));
points_sorted_y = xy(y_idx,:);

% Step 2: Remove the top and bottom 20% of points by y-value
num_points_y = size(xy,1);
num_remove_y = round(num_points_y * skimPercentY);
points_sorted_y = points_sorted_y(num_remove_y+1:end-num_remove_y,:);

% Step 3: Sort the remaining points by x-value
[~, x_idx] = sort(points_sorted_y(:,1));
points_sorted_x = points_sorted_y(x_idx,:);

% Step 4: Remove the top and bottom 10% of points by x-value
num_points_x = size(points_sorted_x,1);
num_remove_x = round(num_points_x * skimPercentX);
xy = points_sorted_x(num_remove_x+1:end-num_remove_x,:);

% Now, "points_final" contains the final set of points with the top and bottom
% 20% of points removed by y-value and the top and bottom 10% of points
% removed by x-value.

if exportXY
    writematrix(xy,outFile) %#ok<*UNRCH> 
end

% Compute Delaunay triangulation
DT = delaunay(xy(:,1), xy(:,2));

% Pre-initialize edge lengths matrix
edgeLengths = zeros(size(DT,1)*3, 1);

% Compute edge lengths
idx = 1;
for i = 1:size(DT,1)
    triangle = DT(i,:);
    edges = nchoosek(triangle,2);
    edgeLengths(idx:idx+2) = sqrt(sum((xy(edges(:,1),:) - xy(edges(:,2),:)).^2, 2));
    idx = idx + 3;
end
edgeLengths(idx:end) = []; % Remove excess zeros
medianLength = median(edgeLengths);

lengThresh = 3;
maxLength = medianLength * lengThresh;
minLength = 0.2;
outsideLength = zeros(size(DT,1)*3, 1);
idx = 1;
for i = 1:size(DT,1)
    triangle = DT(i,:);
    edges = nchoosek(triangle,2);
    edgeLength = sqrt(sum((xy(edges(:,1),:) - xy(edges(:,2),:)).^2, 2));
    
    if any(edgeLength > maxLength | edgeLength < minLength)
        outsideLength(idx:idx+2) = triangle;
        idx = idx + 3;
    end
end
outsideLength = unique(outsideLength);
rowsToDelete = any(ismember(DT, outsideLength), 2);
DT(rowsToDelete, :) = [];

n = size(xy,1);
countNeighbors = zeros(n,1);
for i = 1:n
    countNeighbors(i) = sum(DT(:) == i);
end
countNeighbors(countNeighbors == 0) = [];
% histogram(countNeighbors)

screen_size = get(0, 'ScreenSize');
fig = figure('Position', [0 0 screen_size(3) screen_size(4)]);
triplot(DT, xy(:,1), xy(:,2), 'k');
axis equal

figure;
edgeLengths = edgeLengths(edgeLengths < 2);
histogram(edgeLengths)







