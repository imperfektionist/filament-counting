% DEPRECATE!!! USE importLaserBrush.m IF POSSIBLE!!!

% clear
clc
close all

userPath = "UserData";
dataPath = 'C:\Data\FilamentCounting\Linienlaser';

csvFileName = 'BU2281_WSS_2U_L.csv';
% csvFileName = 'BU2281_WSS_2U_R.csv';
% csvFileName = 'BU2265_WSS_2U_L.csv';
% csvFileName = 'BU2265_WSS_2U_R.csv';

brushDiameter = 105;  % brush outer diameter [mm]
resolution = 50;  % image output resolution [px/mm] (sensor: 200)
% resolution = 100;  % image output resolution [px/mm] (sensor: 200)

trimThresh = 0.95;  % 1.0 => maximum value of initial image
filterSize = 150;  % median filter cell height

initialCutoff = -5;  % set all depths NaN
initialHeighten = 0;  % add to all datapoints to make positive
cutoffHeight = 0.45; % Symmetrical cutoff, values outside are set to this
lowerThreshold = 0.2; % Set values below this threshold to 0
upperThreshold = 0.7; % Set values above this threshold to 0

doImport = 1;
doDetrend = 1;
plotHistogram = 0;
plotFilterMask = 0;
plotImageInitial = 0;
plotImageFinal = 0;

if doImport
    fullPathDP = fullfile(userPath, ['DP_' csvFileName]);

    if ~exist(fullPathDP, "file")  % decimal point file does not exist yet
        fprintf("Importing %s\n", csvFileName)

        fullFilePath = fullfile(dataPath, csvFileName);  % full path
        fileContent = fileread(fullFilePath);  % import CSV file
        fileContent = strrep(fileContent, ',', '.');  % replace commas

        % Write the modified content to a new file (decimal point)
        newFileName = ['UserData/DP_' csvFileName];
        newFile = fopen(newFileName, 'w');
        fprintf(newFile, '%s', fileContent);
        fclose(newFile);
        dataArray = readmatrix(newFileName);  % import as matrix

    else  % decimal point file already exists
        fprintf("Importing %s\n", fullPathDP)
        dataArray = readmatrix(fullPathDP);  % import as matrix
    end
end

image = dataArray';  % transpose because image needs to be horizontal

% Centerize data around median
%image = image - median(image,"all");

image0 = image;  % to save later

% Stretch image to new resolution (equal axes)
circumference = brushDiameter * pi;
axDotsNeeded = 16 * resolution;
tangDotsNeeded = circumference * resolution;
image = imresize(image, [axDotsNeeded tangDotsNeeded], 'method', 'bilinear');
%image0 = imresize(image0, [axDotsNeeded tangDotsNeeded], 'method', 'bilinear');

% Trim image to one circumference, marked by the highest point
[image, idxLeft, idxRight] = trimLaserImage(image, csvFileName, trimThresh);

% Delete all values below cutoff
image(image < initialCutoff) = NaN;

% Add certain height before proceeding
image = image + initialHeighten;

if doDetrend % detrend -> subtract bilinear median mask
    image = detrend2D(image, filterSize, plotFilterMask, fullfile(userPath, csvFileName));
end

% Clamp image to cutoff heights
minVal = -cutoffHeight;
maxVal = cutoffHeight;
image(image < minVal) = minVal;
image(image > maxVal) = maxVal;

% Normalize image
image = (image - minVal) / (maxVal - minVal);

% Plot histogram -> should be centered around 0.5
if plotHistogram
    histogram(image(:), 100)
end

% Make everything outside thresholds black
image(image < lowerThreshold) = 0;
image(image > upperThreshold) = 0;

% Normalize to new extrema
image = image / upperThreshold;

% Export initial image and show
outputFileName = fullfile(userPath, strrep(csvFileName,".csv","_image0.png"));
imwrite(image0, outputFileName);
if plotImageInitial
    winopen(outputFileName);
end

% Export final image and show
outputFileName = fullfile(userPath, strrep(csvFileName,".csv",".png"));
imwrite(image, outputFileName);
if plotImageFinal
    winopen(outputFileName);
end

% close all

disp("All done!")

clear f

