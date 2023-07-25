
inPath = 'UserData/BU6981_2U_L.png';

diameter = 64/2;  % The approximate diameter of the circles you want to detect
erodeSize = 0.0;  % ratio of diameter
sensitivity = 0.995;  % Adjust this parameter to control circle detection sensitivity
radiiRange = [round(0.45 * diameter), round(0.6 * diameter)]; % Allowable range of radii
minDist = 0.8 * diameter;

discardYBelow = 0;  % Set 0 for RIGHT side (50)
discardYAbove = 660;  % Set 3200 for LEFT side

image = imread(inPath);
image_bin = imbinarize(image);

% erodeDiameter = round(diameter * erodeSize);
% se = strel('disk', erodeDiameter);
% image_bin = imerode(image_bin, se);

wb = waitbar(0, "Finding circles...");

[circleCenters, circleRadii, circleMetric] = imfindcircles(image_bin, radiiRange,...
    'Sensitivity', sensitivity,'ObjectPolarity','bright', 'Method', 'TwoStage');

centers = circleCenters;
radii = circleRadii;
metric = circleMetric;

% Mark points with Y coordinates outside specified limits
n = size(centers, 1);
for i = 1:n
    if centers(i,2) < discardYBelow || centers(i,2) > discardYAbove
        centers(i,1) = NaN;
        radii(i) = NaN;
        metric(i,1) = NaN;
    end
end
centers(any(isnan(centers), 2), :) = [];
radii(any(isnan(radii), 2), :) = [];
metric(any(isnan(metric), 2), :) = [];

% Mark weaker one of two close centers
distMatrix = squareform(pdist(centers));
n = size(centers, 1);
for c = 1:n
    for d = c+1:n
        if distMatrix(c, d) <= minDist
            if metric(c) >= metric(d)
                centers(d,1) = NaN;
                radii(d) = NaN;
            else
                centers(c,1) = NaN;
                radii(c) = NaN;
            end
        end
    end
    waitbar(c/n, wb, sprintf("Deleting circles %d%%", round(c/n*100)));
end

centers(any(isnan(centers), 2), :) = [];  % remove weak close
radii(any(isnan(radii), 2), :) = [];  % remove weak close

histogram(radii)

outImage = strrep(inPath, ".png", "_hough.png");
outXY = strrep(outImage, ".png", ".txt");
writematrix(centers, outXY, 'Delimiter', 'tab');

% Create a new image and mark the detected circles
markedImage = image;
numCircles = size(centers, 1);
for i = 1:numCircles
    center = centers(i, :);
    radius = radii(i);
    markedImage = insertShape(markedImage, 'Circle', [center, radius], 'LineWidth', 4, 'Color', 'red');
    %markedImage = insertMarker(markedImage, centers(i,:), '+', 'Color', 'red');
    waitbar(i/numCircles, wb, sprintf("Marking circles %d%%", round(i/numCircles*100)));
end

% Save the marked image as a new file
imwrite(markedImage, outImage);
winopen(outImage);

% imshow(image_bin);
% imwrite(image_bin, 'hough_image.png');
% winopen('hough_image.png');

close(wb)
disp("All done.")








