close all

par.userPath = "UserData";
par.dataPath = 'C:\Data\FilamentCounting\Linienlaser';

par.csvFileName = 'BU2281_WSS_2U_L.csv';  % [1195 15111], HS: 0.8435
% par.csvFileName = 'BU2281_WSS_2U_R.csv';  % [1016 14685]
% par.csvFileName = 'BU6981_2U_L.csv';  % [900 22165]
% par.csvFileName = 'BU6981_2U_R.csv';  % [2634 21157]

par.trimThresh = [1195 15111];  % 0.95 for WSS, -1 for clicking, [x1 x2] for known 
% par.trimThresh = [1016 14685];  % 0.95 for WSS, -1 for clicking, [x1 x2] for known 
% par.trimThresh = [900 22165];  % 0.95 for WSS, -1 for clicking, [x1 x2] for known 
% par.trimThresh = [2634 21157];  % 0.95 for WSS, -1 for clicking, [x1 x2] for known 

par.brushDiameter = 105;  % brush outer diameter [mm]
par.analysisResolution = 200;  % 200 is maximum resolution
par.resolution = 50;  % image output resolution [px/mm] (sensor: 200)
par.horzStretch = 0.8435;

par.heightCutoff = -3;  % set all depths NaN
par.measureLength = 150;  % length of measurement cross [px]

par.doImport = 1;
par.doModifiedPoints = 1;  % import files with points to add or delete

par.plotInitialImage = 0;

par.doEccentricity = 1;
par.cellSizeVert = 50;
par.cellStretchFactor = 20;  % cell width to cell height ratio
par.plotFilterMask = 0;

par.autoClicking = 1;
par.plotTipAnalysis = 0;
par.plotLengthAnalysis = 0;
par.doExportHiRes = 0;

par.saveSubImages = -1;  % make negative to disable

par.axEvalHeight = [0 16]; % discard points above or below [mm] (def: [0 16])
par.dupliDist = 10;  % maximum px for manual duplicate deletion
par.smoothSize = 10;  % smooth filament tip profiles
par.binWidth = 0.02;  % filament length histogram step

upSizeFactor = par.analysisResolution / par.resolution;

% wb = waitbar(0, "Correlating...");

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

if ~par.autoClicking
    image(image < par.heightCutoff) = NaN;
end

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

% Delete margin filaments
centers = centers(centers(:,1) > par.measureLength, :);
centers = centers(centers(:,1) < size(image,2) - par.measureLength, :);
centers = centers(centers(:,2) > par.measureLength, :);
centers = centers(centers(:,2) < size(image,1) - par.measureLength, :);

if par.plotInitialImage
    figure;
    imshow(image)
    hold on
    plot(centers(:,1), centers(:,2), "g.", "Marker", "+", "MarkerSize", 3, "LineWidth", 1)
end

%%


profile_fig = figure;
sub_fig = figure;

i = 1;

mm = -par.measureLength:par.measureLength;  % px to mm
mm = mm / par.analysisResolution;
par.axEvalHeight = par.axEvalHeight * par.analysisResolution;

z_max = NaN(size(centers,1),1);
z_tang_mat = NaN(length(mm),size(centers,1));
z_ax_mat = NaN(length(mm),size(centers,1));

while true

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

    % Save image of filament tip
    if ismember(i, par.saveSubImages)
        subimage = image(y,x) - median(image(y,x)) + 0.7;%+ 0.1 + rand * 0.8;
        subPath = strrep(par.csvFileName,".csv",sprintf("_%d.png",i));
        subPath = fullfile("UserData","Subs",subPath);
        imwrite(subimage, subPath);

%         ans = horzcat(mm', z_tang, z_ax);
    end


    if par.autoClicking  % auto compute all filaments

        if within
            % Take lower value of ax and tang max (less outliers)
            z_max(i) = min([max(z_tang) max(z_ax)]);
    
            % Auto-zero maximum
            z_tang_mat(:,i) = z_tang - max(z_tang);
            z_ax_mat(:,i) = z_ax - max(z_ax);
        end

        i = i + 1;
        if i > size(centers,1)
            break;
        end

    else  % manual analysis
        figure(profile_fig);
        hold off
        plot(mm,z_tang,"k","LineWidth",2);
        hold on
        plot(mm,z_ax,"b","LineWidth",2);
        title(sprintf("Filament %d: tip profile",i));
        legend(["tangential","axial"],'Location','Best')
        
        figure(sub_fig);
        hold off
        imshow(image(y,x))
        title(sprintf("Filament %d: (%d,%d)", i, center(1), center(2)));
        hold on
        
        click = winput(1);
        if isempty(click)
            break;
        end
        if click(1) >= par.measureLength  % click right half
            i = i + 1;  % go foward
        else  % click left half
            i = i - 1;  % go backward
        end        
    end

    i = mod(i, size(centers,1));  % roll around
    if i == 0
        i = size(centers,1);
        if par.autoClicking
            click = [];
        end
    end
end

if par.autoClicking

    z_tang_mean = nanmean(z_tang_mat,2);
    z_ax_mean = nanmean(z_ax_mat,2);

    z_tang_mean = smooth(z_tang_mean, par.smoothSize) - max(z_tang_mean);
    z_ax_mean = smooth(z_ax_mean, par.smoothSize) - max(z_ax_mean);

    z_tang = z_tang_mean;  % to save as file later
    z_ax = z_ax_mean;

    z_tang_mean(z_tang_mean < par.heightCutoff) = NaN;
    z_ax_mean(z_ax_mean < par.heightCutoff) = NaN;

    figure(profile_fig);
    hold off
    plot(mm,z_tang_mean,"k","LineWidth",2);
    hold on
    plot(mm,z_ax_mean,"b","LineWidth",2);
    legend(["tangential","axial"],'Location','Best')
    title(sprintf("Tip profiles"));
    xlabel("Width [mm]");
    ylabel("Height [mm]");
    axis([mm(1) mm(end) par.heightCutoff 0])

    % Save tip profiles as image
    outputFileName = fullfile(par.userPath, strrep(par.csvFileName,".csv","_tip_shape.png"));
    saveas(gcf, outputFileName);

    % Save tip profiles as text
    outputFileName = strrep(outputFileName,".png",".txt");
    writematrix(horzcat(mm',z_tang,z_ax), outputFileName, "Delimiter","\t");

    % Filament length deviation
    z_max = z_max(z_max > par.heightCutoff);
    z_max = z_max - median(z_max);
    length_stdev = std(z_max);

    [counts, edges] = histcounts(z_max, 'BinWidth', par.binWidth);
    counts = counts / sum(counts);

    length_fig = figure;
    bins = edges(1:end-1) + par.binWidth / 2;
    plot(bins, counts,"k","LineWidth",2);
    title(sprintf("Filament length (StdDev = %.4f)",length_stdev));
    xlabel("Filament length deviation [mm]");
    ylabel("Relative Occurrence");

    % Save filament length histogram as image
    outputFileName = fullfile(par.userPath, strrep(par.csvFileName,".csv","_tip_hist.png"));
    saveas(gcf, outputFileName);

    % Save filament length histogram as text
    outputFileName = strrep(outputFileName,".png",".txt");
    writematrix(horzcat(bins',counts'), outputFileName, "Delimiter","\t");

        
end

if par.doExportHiRes  % Export final image and show    
    outputFileName = fullfile(par.userPath, strrep(par.csvFileName,".csv","_hiRes.png"));
    imwrite(image, outputFileName);
    if plotImageFinal
        winopen(outputFileName);
    end
end

% close(wb)

clear i j
