% clear
clc
close all

folderName = 'C:\Data\FilamentCounting\Linienlaser';
csvFileName = 'BU2281_WSS_2U_L.csv';

doImport = 1;  % import file or use workspace
doTangentialDetrend = 1;
doAxialDetrend = 0;

if doImport
    fprintf("Importing %s\n", csvFileName)
    
    % Create the full file path using 'fullfile'
    fullFilePath = fullfile(folderName, csvFileName);
    
    if strcmp(csvFileName(1:3), 'DP_')  % contains decimal points
        dataArray = readmatrix(csvFileName);
    
    else % contains decimal commas
    
        % Read the CSV file as text
        fileContent = fileread(fullFilePath);
        
        % Replace decimal commas with decimal points
        fileContent = strrep(fileContent, ',', '.');
        
        % Write the modified content to a temporary file
        tempFileName = ['DP_' csvFileName];
        tempFile = fopen(tempFileName, 'w');
        fprintf(tempFile, '%s', fileContent);
        fclose(tempFile);  
    
        % Read the modified CSV file using 'readmatrix'
        dataArray = readmatrix(tempFileName);
    
        % Delete the temporary file
        %delete(tempFileName);
    end
end

% disp("Calculating...")
% disp(max(dataArray(:)))
% disp(median(dataArray(:)))

dataNorm = dataArray';

maxVal = max(dataNorm(:));
minVal = min(dataNorm(:));

maxThresh = 0.95 * maxVal;
idxLeft = find(max(dataNorm) >= maxThresh, 1, 'first') + 200;
idxRight = find(max(dataNorm) >= maxThresh, 1, 'last') - 100;

dataNorm = dataNorm(:,idxLeft:idxRight);  % strip to one circumference

if doTangentialDetrend
    dataNorm = detrend2(dataNorm, 1, 2);  % tangential (squared)
end
if doAxialDetrend
    dataNorm = detrend2(dataNorm, 2, 1);  % axial (linear)
end

minVal = -0.5;
maxVal = 0.5;

dataNorm(dataNorm < minVal) = minVal;
dataNorm(dataNorm > maxVal) = maxVal;

dataNorm = (dataNorm - minVal) / (maxVal - minVal);

% dataNorm(dataNorm > 0.95) = 0;

% idxUpper = find(any(dataNorm,2), 1, 'first')
% idxLower = find(any(dataNorm,2), 1, 'last')

% histogram(dataNorm(:), 100)

maxVal = max(dataNorm(:));
minVal = min(dataNorm(:));
dataNorm = (dataNorm - minVal) / (maxVal - minVal);

resolution = 100;  % in px/mm
brushDiameter = 105;
circumference = brushDiameter * pi;

axDotsNeeded = 16 * 200;
tangDotsNeeded = circumference * resolution * 1.5;

% dataNorm = imbinarize(dataNorm);

% Stretch image to new resolution (equal axes)
dataNorm = imresize(dataNorm, [axDotsNeeded tangDotsNeeded]);
% dataNorm = histeq(dataNorm);


% % Plot the normalized data as a grayscale image
% imshow(dataNorm, 'InitialMagnification', 'fit');
% 
% colormap(gray);  % Use a grayscale colormap
% 
% % Add a colorbar to show the scale (optional)
% colorbar;
% axis on

% xlim([2000, 2500]);

outputFileName = 'laser_test.png';  % Replace with your desired filename
imwrite(dataNorm, outputFileName);
winopen(outputFileName);

% close all

disp("All done!")

% Feature Based Panoramic Image Stitching
% https://de.mathworks.com/help/vision/ug/feature-based-panoramic-image-stitching.html

% % Load images.
% buildingDir = "UnstitchedData";
% buildingScene = imageDatastore(buildingDir);
% 
% % Display images to be stitched.
% % montage(buildingScene.Files)
% 
% % Read the first image from the image set.
% I = readimage(buildingScene,1);
% 
% % Initialize features for I(1)
% grayImage = im2gray(I);
% points = detectSURFFeatures(grayImage);
% [features, points] = extractFeatures(grayImage,points);
% 
% % Initialize all the transformations to the identity matrix. Note that the
% % projective transformation is used here because the building images are fairly
% % close to the camera. For scenes captured from a further distance, you can use
% % affine transformations.
% numImages = numel(buildingScene.Files);
% tforms(numImages) = projtform2d;
% 
% % Initialize variable to hold image sizes.
% imageSize = zeros(numImages,2);
% 
% % Iterate over remaining image pairs
% for n = 2:numImages
%     % Store points and features for I(n-1).
%     pointsPrevious = points;
%     featuresPrevious = features;
%         
%     % Read I(n).
%     I = readimage(buildingScene, n);
%     
%     % Convert image to grayscale.
%     grayImage = im2gray(I);    
%     
%     % Save image size.
%     imageSize(n,:) = size(grayImage);
%     
%     % Detect and extract SURF features for I(n).
%     points = detectSURFFeatures(grayImage);    
%     [features, points] = extractFeatures(grayImage, points);
%   
%     % Find correspondences between I(n) and I(n-1).
%     indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
%        
%     matchedPoints = points(indexPairs(:,1), :);
%     matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);        
%     
%     % Estimate the transformation between I(n) and I(n-1).
%     tforms(n) = estgeotform2d(matchedPoints, matchedPointsPrev,...
%         'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
%     
%     % Compute T(1) * T(2) * ... * T(n-1) * T(n).
%     tforms(n).A = tforms(n-1).A * tforms(n).A; 
% end
% 
% % Compute the output limits for each transformation.
% for i = 1:numel(tforms)           
%     [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);    %#ok<*SAGROW> 
% end
% 
% % Compute the average X limits for each transformation and find the image 
% % that is in the center. Only the X limits are used here because the scene 
% % is known to be horizontal. If another set of images are used, both the 
% % X and Y limits may need to be used to find the center image.
% avgXLim = mean(xlim, 2);
% [~,idx] = sort(avgXLim);
% centerIdx = floor((numel(tforms)+1)/2);
% centerImageIdx = idx(centerIdx);
% 
% % Apply the center image's inverse transformation to all the others.
% Tinv = invert(tforms(centerImageIdx));
% for i = 1:numel(tforms)    
%     tforms(i).A = Tinv.A * tforms(i).A;
% end
% 
% % Create an initial, empty, panorama into which all the images are mapped.
% % Use the outputLimits method to compute the minimum and maximum output
% % limits over all transformations. These values are used to automatically
% % compute the size of the panorama.
% for i = 1:numel(tforms)           
%     [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);
% end
% 
% maxImageSize = max(imageSize);
% 
% % Find the minimum and maximum output limits. 
% xMin = min([1; xlim(:)]);
% xMax = max([maxImageSize(2); xlim(:)]);
% 
% yMin = min([1; ylim(:)]);
% yMax = max([maxImageSize(1); ylim(:)]);
% 
% % Width and height of panorama.
% width  = round(xMax - xMin);
% height = round(yMax - yMin);
% 
% % Initialize the "empty" panorama.
% panorama = zeros([height width 3], 'like', I);
% 
% % Use imwarp to map images into the panorama and use vision.
% % AlphaBlender to overlay the images together.
% blender = vision.AlphaBlender('Operation', 'Binary mask', ...
%     'MaskSource', 'Input port');  
% 
% % Create a 2-D spatial reference object defining the size of the panorama.
% xLimits = [xMin xMax];
% yLimits = [yMin yMax];
% panoramaView = imref2d([height width], xLimits, yLimits);
% 
% % Create the panorama.
% for i = 1:numImages
%     
%     I = readimage(buildingScene, i);
%    
%     % Transform I into the panorama.
%     warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
%                   
%     % Generate a binary mask.    
%     mask = imwarp(true(size(I,1),size(I,2)), tforms(i), 'OutputView', panoramaView);
%     
%     % Overlay the warpedImage onto the panorama.
%     panorama = step(blender, panorama, warpedImage, mask);
% end
% 
% % figure
% % imshow(panorama)
% 
% panorama_gray = CropToROI(panorama);
% 
% % figure
% % imshow(panorama_gray)
% 
% panorama_dewarped = DeWarpTest(panorama_gray);
% 
% figure
% imshow(panorama_dewarped)
% 
% % imwrite(panorama_dewarped, 'StitchedData\stitched.png');
