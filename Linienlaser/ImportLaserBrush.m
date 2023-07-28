% clear
clc
close all

par.userPath = "UserData";
par.dataPath = 'C:\Data\FilamentCounting\Linienlaser';

% par.csvFileName = {'BU6981_2U_L.csv'};  % [900 22165]
par.csvFileName = {'BU6981_2U_R.csv'};  % [2634 21157]

par.brushDiameter = 150;  % brush outer diameter [mm]
par.resolution = 50;  % image output resolution [px/mm] (sensor: 200)

par.trimThresh = [2634 21157];  % 0.95 for WSS, -1 for clicking, [x1 x2] for known 
par.filterSize = 50;  % median filter cell height

par.initialCutoff = -3;  % set all depths NaN
par.initialHeighten = 1;  % add to all datapoints to make positive
par.cutoffHeight = 0.6; % Symmetrical cutoff, values outside are set to this
par.lowerThreshold = 0.25; % Set values below this threshold to 0
par.upperThreshold = 0.85; % Set values above this threshold to 0  

par.doImport = 1;
par.doDetrend = 1;
par.plotHistogram = 1;
par.plotFilterMask = 0;
par.plotImageInitial = 0;
par.plotImageFinal = 1;

if par.doImport % Import raw laser data from csv file
    dataArray = importLaser(par);
end

image = dataArray';  % transpose because image needs to be horizontal

image0 = image;  % to save later

% Stretch image to new resolution (equal axes)
circumference = par.brushDiameter * pi;
axDotsNeeded = 16 * par.resolution;
tangDotsNeeded = circumference * par.resolution;
image = imresize(image, [axDotsNeeded tangDotsNeeded], 'method', 'bilinear');
image0 = imresize(image0, [axDotsNeeded tangDotsNeeded], 'method', 'bilinear');

% Delete all values below cutoff
image(image < par.initialCutoff) = NaN;

% Add certain height before proceeding
image = image + par.initialHeighten;

if par.doDetrend % detrend -> subtract bilinear median mask
    image = detrend2D(image, par.filterSize, par.plotFilterMask, fullfile(par.userPath, par.csvFileName));
end

% Clamp image to cutoff heights
minVal = -par.cutoffHeight;
maxVal = par.cutoffHeight;
image(image < minVal) = minVal;
image(image > maxVal) = maxVal;

% Normalize image
image = (image - minVal) / (maxVal - minVal);

% Plot histogram -> should be centered around 0.5
if par.plotHistogram
    histogram(image(:), 100)
end

% Make everything outside thresholds black
image(image < par.lowerThreshold) = 0;
image(image > par.upperThreshold) = 0;
image(isnan(image)) = 0;

% Normalize to new extrema
image = image / par.upperThreshold;

% Trim image to one circumference, marked by the highest point
[image, idxLeft, idxRight] = trimLaserImage(image, par.csvFileName, par.trimThresh);

% Export initial image and show
outputFileName = fullfile(par.userPath, strrep(par.csvFileName,".csv","_image0.png"));
imwrite(image0, outputFileName);
if par.plotImageInitial
    winopen(outputFileName);
end

% Export final image and show
outputFileName = fullfile(par.userPath, strrep(par.csvFileName,".csv",".png"));
imwrite(image, outputFileName);
if par.plotImageFinal
    winopen(outputFileName);
end


% close all

disp("All done!")



