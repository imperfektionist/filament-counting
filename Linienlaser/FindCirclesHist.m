% clear
close all

inPath = 'UserData/BU2281_WSS_2U_L.png';
% inPath = 'UserData/BU2281_WSS_2U_R.png';
% inPath = 'UserData/BU2265_WSS_2U_L.png';
% inPath = 'UserData/BU2265_WSS_2U_R.png';
% resolution = 50;
resolution = 100;

diameter = 112;  % The approximate diameter of the circles you want to detect
% diameter = 63;  % The approximate diameter of the circles you want to detect
erodeSize = 0;  % size of erosion disk
sensitivity = 0.98;  % Adjust this parameter to control circle detection sensitivity
radiiRange = [round(0.45 * diameter), round(0.63 * diameter)]; % Allowable range of radii
minDist = 0.8 * diameter;  % discard weaker circles if too close to stronger circles
stretch = 1;  % stretch image horizontally

% discardYBelow = 0;  % Set 0 for RIGHT side (50)
% discardYAbove = 800;  % Set 3200 for LEFT side

image = imread(inPath);

image_bin = imbinarize(image);
image_bin = imresize(image_bin, size(image) .* [1 stretch], "method", "bilinear");

% imwrite(double(image_bin), "tmp.png");
% winopen("tmp.png");

% se = strel('disk', erodeSize);
% image_bin = imerode(image_bin, se);

wb = waitbar(0, "Finding circles...");

[circleCenters, circleRadii, circleMetric] = imfindcircles(image_bin, radiiRange,...
    'Sensitivity', sensitivity,'ObjectPolarity','bright', 'Method', 'TwoStage');

centers = circleCenters;
radii = circleRadii;
metric = circleMetric;

% % Mark points with Y coordinates outside specified limits
% n = size(centers, 1);
% for i = 1:n
%     if centers(i,2) < discardYBelow || centers(i,2) > discardYAbove
%         centers(i,1) = NaN;
%         radii(i) = NaN;
%         metric(i,1) = NaN;
%     end
% end
% centers(any(isnan(centers), 2), :) = [];
% radii(any(isnan(radii), 2), :) = [];
% metric(any(isnan(metric), 2), :) = [];

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

%%

% Make histogram  of radii
radii_mm = (radii * 2 - 1) / resolution;
df_stdev = std(radii_mm);
num_bins = length(unique(radii));
[counts, edges] = histcounts(radii_mm, num_bins);
counts = counts / sum(counts);  % relative occurrence
 
figure;
bins = edges(1:end-1) + (edges(2)-edges(1)) / 2;
plot(bins, counts,"k","LineWidth",2);
title(sprintf("Filament diameter distribution (StdDev = %.4f)",df_stdev));
xlabel("Filament diameter [mm]");
ylabel("Relative Occurrence");

% Save filament diameter histogram as image
outputFileName = strrep(inPath,".png","_hough_radhist.png");
saveas(gcf, outputFileName);

% Save filament diameter histogram as text
outputFileName = strrep(outputFileName,".png",".txt");
writematrix(horzcat(bins',counts'), outputFileName, "Delimiter","\t");



centers(:,1) = centers(:,1) / stretch;  % unstretch image

outImage = strrep(inPath, ".png", "_hough.png");
outXY = strrep(outImage, ".png", ".txt");
writematrix(centers, outXY, 'Delimiter', 'tab');

% Create a new image and mark the detected circles
markedImage = image;
numCircles = size(centers, 1);
fprintf("Filaments found: %d\n", numCircles)

% for i = 1:numCircles
%     center = centers(i, :);
%     radius = radii(i);
%     markedImage = insertShape(markedImage, 'Circle', [center, radius], 'LineWidth', 4, 'Color', 'red');
%     %markedImage = insertMarker(markedImage, centers(i,:), '+', 'Color', 'red');
%     waitbar(i/numCircles, wb, sprintf("Marking circles %d%%", round(i/numCircles*100)));
% end
% 
% % Save the marked image as a new file
% imwrite(markedImage, outImage);
% winopen(outImage);

% imshow(image_bin);
% imwrite(image_bin, 'hough_image.png');
% winopen('hough_image.png');

close(wb)
disp("All done.")








