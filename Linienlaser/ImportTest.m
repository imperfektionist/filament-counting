% clear
clc
close all

userPath = "UserData";
dataPath = 'C:\Data\FilamentCounting\Linienlaser';

% csvFiles = {'BU2281_WSS_4U_L.csv', 'BU2281_WSS_4U_R.csv'};
csvFiles = {'BU2281_WSS_2U_R.csv'};

brushDiameter = 105;    % brush outer diameter [mm]
resolution = 50;       % image output resolution [px/mm] (sensor: 200)

trimThresh = 0.95;  % 1.0 => maximum value of initial image
filterSize = 150;

cutoffHeight = 0.25; % Symmetrical cutoff, values outside are set to
lowerThreshold = 0.25; % Set values below this threshold to 0
upperThreshold = 0.7; % Set values above this threshold to 0  

doImport = 1;
doDetrend = 1;
plotHistogram = 1;
plotFilterMask = 1;

for f = 1:length(csvFiles)

    if doImport
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
    end
    
    image = dataArray';  % transpose because image needs to be horizontal
    
    % Centerize data around median
    image = image - median(image,"all");

    % Trim image to one circumference, marked by the heighest point
    image = TrimLaserImage(image, csvFileName, trimThresh);
    
    if doDetrend % detrend -> subtract bilinear median mask
        image = detrend2D(image, filterSize, plotFilterMask);
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
        
    % Stretch image to new resolution (equal axes)
    circumference = brushDiameter * pi;
    axDotsNeeded = 16 * resolution;
    tangDotsNeeded = circumference * resolution;
    image = imresize(image, [axDotsNeeded tangDotsNeeded]);

    % Export image and show
    outputFileName = fullfile(userPath, strrep(csvFileName,".csv",".png"));
    imwrite(image, outputFileName);
    winopen(outputFileName);

end

% close all

disp("All done!")



