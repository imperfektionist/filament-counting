% Step 1: Read the grayscale image
% Replace 'your_image_file.png' with the filename of your grayscale image
image = imread('UserData/BU2281_WSS_4U_L.png');

% Step 2: Find circles with a specified approximate diameter
diameter = 55; % The approximate diameter of the circles you want to detect
sensitivity = 0.95; % Adjust this parameter to control circle detection sensitivity
radiiRange = [round(0.4 * diameter), round(0.6 * diameter)]; % Allowable range of radii
% radiiRange = [20, 200];

image_bin = imbinarize(image);

se = strel('disk',5);
image_bin = imerode(image_bin, se);

% [circleCenters, circleRadii] = imfindcircles(image_bin, radiiRange,...
%     'Sensitivity', sensitivity,'ObjectPolarity','bright');
% 
% % Step 3: Create a new image and mark the detected circles
% markedImage = image;
% numCircles = size(circleCenters, 1);
% for i = 1:numCircles
%     center = circleCenters(i, :);
%     radius = circleRadii(i);
%     markedImage = insertShape(markedImage, 'Circle', [center, radius], 'LineWidth', 2, 'Color', 'red');
% end
% 
% % Step 4: Save the marked image as a new file
% % Replace 'marked_image_file.png' with the desired filename for the marked image
% imwrite(markedImage, 'hough_image.png');
% winopen('hough_image.png');

% imshow(image_bin);
imwrite(image_bin, 'hough_image.png');
winopen('hough_image.png');



disp("All done.")








