% clear
clc
close all

userPath = "UserData";
dataPath = 'C:\Data\FilamentCounting\Linienlaser';

% csvFiles = {'BU2281_WSS_4U_L.csv', 'BU2281_WSS_4U_R.csv'};
csvFiles = {'BU2281_WSS_2U_L.csv'};

trimThresh = 0.95;  % 1.0 = maximum value of image
filterSize = 200;

resolution = 50;       % image resolution [px/mm] (sensor: 200)
brushDiameter = 105;    % brush outer diameter [mm]

doDetrend = 1;

for f = 1:length(csvFiles)
    csvFileName = csvFiles{f};
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
    
    image = dataArray';  % transpose because image needs to be horizontal
    
    % Trim image to one circumference, marked by the heighest point
    image = TrimLaserImage(image, csvFileName, trimThresh);
    
    if doDetrend
        image = detrend2D(image, filterSize);  %
%         image = image - medfilt2(image, [30 30]);       

    end
    
    minVal = -0.5;
    maxVal = 0.5;
    
    image(image < minVal) = minVal;
    image(image > maxVal) = maxVal;
    
    image = (image - minVal) / (maxVal - minVal);        
    
    histogram(image(:), 100)

    lowerThreshold = 0.35; % Set values below this threshold to 0
    upperThreshold = 0.6; % Set values above this threshold to 0    
    image(image < lowerThreshold) = 0;
    image(image > upperThreshold) = 0;

    maxVal = max(image(:));
    minVal = min(image(:));
    image = (image - minVal) / (maxVal - minVal);

    circumference = brushDiameter * pi;    
    axDotsNeeded = 16 * resolution;
    tangDotsNeeded = circumference * resolution;
    
    % dataNorm = imbinarize(image);
    
    % Stretch image to new resolution (equal axes)
    image = imresize(image, [axDotsNeeded tangDotsNeeded]);
    % dataNorm = histeq(image);
        
    % dataNorm = imresize(image, [1600 10000]);
    
    outputFileName = fullfile(userPath, strrep(csvFileName,".csv",".png"));
    imwrite(image, outputFileName);
    winopen(outputFileName);

end

% close all

disp("All done!")



