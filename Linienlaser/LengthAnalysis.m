close all

par.userPath = "UserData";
par.dataPath = 'C:\Data\FilamentCounting\Linienlaser';

par.doImport = 1;
par.csvFileName = 'BU2281_WSS_2U_L.csv';  % [1195 15111], HS: 0.8435
% par.csvFileName = 'BU2281_WSS_2U_R.csv';  % [1016 14685], HS: 0.8282
% par.csvFileName = 'BU6981_2U_L.csv';  % [900 22165], HS: 1
% par.csvFileName = 'BU6981_2U_R.csv';  % [2634 21157], HS: 1
% par.csvFileName = 'BU2281_2U_L.csv';  % [2538 22213], HS: 1
% par.csvFileName = 'BU2281_2U_R.csv';  % [2965 22225], HS: 1

par.trimThresh = [1220 15111];  % 0.95 for WSS, -1 for clicking, [x1 x2] for known 
% par.trimThresh = [1016 14685];  % 0.95 for WSS, -1 for clicking, [x1 x2] for known 
% par.trimThresh = [900 22165];  % 0.95 for WSS, -1 for clicking, [x1 x2] for known 
% par.trimThresh = [2634 21157];  % 0.95 for WSS, -1 for clicking, [x1 x2] for known 
% par.trimThresh = [2538 22213];  % 0.95 for WSS, -1 for clicking, [x1 x2] for known 
% par.trimThresh = [2965 22225];  % 0.95 for WSS, -1 for clicking, [x1 x2] for known 

par.horzStretch = 0.8435;
% par.horzStretch = 0.8282;
% par.horzStretch = 1;

par.brushDiameter = 105;  % brush outer diameter [mm]
% par.brushDiameter = 150;  % brush outer diameter [mm]
par.analysisResolution = 200;  % 200 is maximum resolution
par.resolution = 50;  % image output resolution [px/mm] (sensor: 200)

par.heightCutoff = -3;  % set all depths NaN
par.measureLength = 50;  % length of measurement cross [px]
par.lengthHistCutoff = [-0.4 0.4];
par.histBinWidth = 0.01;

par.doMarginTrim = 1;  % cut of side filaments
par.doModifiedPoints = 1;  % import files with points to add or delete
par.plotInitialImage = 0;

par.doEccentricity = 1;
par.cellSizeTang = 800;
par.cellSizeAx = 800;
par.plotFilterMask = 0;
par.plotEccentricity = 1;

par.axEvalHeight = [0 16]; % discard points above or below [mm] (def: [0 16])
par.dupliDist = 10;  % maximum px for manual duplicate deletion
par.smoothSize = 1;  % smooth filament tip profiles

upSizeFactor = par.analysisResolution / par.resolution;

if par.doImport % Import raw laser data from csv file
    dataArray = importLaser(par);
end

image = dataArray';

% Stretch image to new resolution (equal axes)
circumference = par.brushDiameter * pi;
axDotsNeeded = 16 * par.analysisResolution;
tangDotsNeeded = circumference * par.analysisResolution;
image = imresize(image, [axDotsNeeded tangDotsNeeded], 'method', 'bilinear');

% Trim image to one circumference, marked by the highest point
par.trimThresh = par.trimThresh * upSizeFactor;
% par.trimThresh = [idxLeft idxRight] * upSizeFactor;
% trimThresh = 0.95;
% widthBeforeTrim = size(image,2);
[image, idxLeft, idxRight] = trimLaserImage(image, par.csvFileName, par.trimThresh);

if par.doEccentricity % detrend -> subtract bilinear median mask
    image = lengthMask(image, par);
end

image(image < par.heightCutoff) = NaN;

% Get filament center positions
fileXY = strrep(fullfile(par.userPath, par.csvFileName), ".csv", "_hough.txt");
centers0 = readmatrix(fileXY);
centers = centers0;

if par.doModifiedPoints  % add false negatives
        
    centers_del = readmatrix(strrep(fileXY,".","_delPoints."));

    for i = 1:size(centers,1)
        for j = 1:size(centers_del)
            if norm(centers(i,:) - centers_del(j,:)) <= par.dupliDist
                centers(i,1) = NaN;  % mark for deletion
            end
        end
    end
    centers(any(isnan(centers), 2), :) = [];

    centers_add = readmatrix(strrep(fileXY,".","_addPoints."));
    centers = vertcat(centers0, centers_add);

    % Calculate machine learning data
    fp = size(centers_del,1);  % false positives
    tp = size(centers0,1) - fp;  % true positives
    fn = size(centers_add,1);  % false negatives
    %tn is unknown!
    precision = tp / (tp + fp) * 100;  % Präzision
    recall = tp / (tp + fn) * 100;  % Sensitivität

    mldata = sprintf("fp: %d\ntp: %d\nfn: %d\nprecision: %.1f %%\nrecall: %.1f %%",...
        fp,tp,fn,precision,recall);
    disp(mldata)

    % Write machine learning data to text file
    outputFileName = fullfile(par.userPath, strrep(par.csvFileName,".csv","_mldata.txt"));
    fileID = fopen(outputFileName, 'w');    
    fprintf(fileID, '%s', mldata);
    fclose(fileID);
else
    centers = centers0;
end

centers = centers * upSizeFactor;
centers(:,1) = centers (:,1) * par.horzStretch;

if par.doMarginTrim % Delete margin filaments
    centers = centers(centers(:,1) > par.measureLength + 1, :);
    centers = centers(centers(:,1) < size(image,2) - par.measureLength - 1, :);
    centers = centers(centers(:,2) > par.measureLength + 1, :);
    centers = centers(centers(:,2) < size(image,1) - par.measureLength - 1, :);
end

if par.plotInitialImage
    figure;
    imshow(image)
    hold on
    plot(centers(:,1), centers(:,2), "g.", "Marker", "+", "MarkerSize", 3, "LineWidth", 1)
end

%%

par.axEvalHeight = par.axEvalHeight * par.analysisResolution;

z_max = NaN(size(centers,1),1);

for i = 1:size(centers,1)

    center = round(centers(i,:));

    if center(2) <= par.axEvalHeight(2) && center(2) >= par.axEvalHeight(1)
        within = 1;
    else
        within = 0;
    end

    x = center(1)-par.measureLength:center(1)+par.measureLength;
    y = center(2)-par.measureLength:center(2)+par.measureLength;
    z_tang = image(center(2),x)';
    z_ax = image(y,center(1));

    if within
        % Take lower value of ax and tang max (less outliers)
        z_max(i) = min([max(z_tang) max(z_ax)]);
    end
        
end

% Filament length deviation
z_max = z_max(z_max > par.heightCutoff);
z_max = z_max - median(z_max);

z_max = z_max(z_max >= par.lengthHistCutoff(1));
z_max = z_max(z_max <= par.lengthHistCutoff(2));

length_stdev = std(z_max);

par.histEdges = par.lengthHistCutoff(1):par.histBinWidth:par.lengthHistCutoff(2);

[counts, edges] = histcounts(z_max, par.histEdges);
counts = counts / sum(counts);

len_fig = figure;
bins = edges(1:end-1) + par.histBinWidth / 2;
plot(bins, counts,"k","LineWidth",2);
title(sprintf("Filament length (StdDev = %.4f)",length_stdev));
xlabel("Filament length deviation [mm]");
ylabel("Relative Occurrence");

% Save filament length histogram as image
outputFileName = fullfile(par.userPath, strrep(par.csvFileName,".csv","_length_hist.png"));
saveas(gcf, outputFileName);

% Save filament length histogram as text
outputFileName = strrep(outputFileName,".png",".txt");
writematrix(horzcat(bins',counts'), outputFileName, "Delimiter","\t");

% close(len_fig)

clear i j
