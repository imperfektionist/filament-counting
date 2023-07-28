% Run ImportLaserBrush.m first!
close all

analysisResolution = 200;
measureLength = 150;

heightCutoff = -1;  % set all depths NaN

doModifiedPoints = 1;  % import files with points to add or delete
dupliDist = 10;  % maximum px for manual duplicate deletion

smoothSize = 10;  % smooth filament tip profiles
binWidth = 0.02;  % filament length histogram step

plotInitialImage = 0;
autoClicking = 1;
doExportHiRes = 0;

upSizeFactor = analysisResolution / resolution;

% wb = waitbar(0, "Correlating...");

image = dataArray';

% Stretch image to new resolution (equal axes)
circumference = brushDiameter * pi;
axDotsNeeded = 16 * analysisResolution;
tangDotsNeeded = circumference * analysisResolution;
image = imresize(image, [axDotsNeeded tangDotsNeeded], 'method', 'bilinear');

% Trim image to one circumference, marked by the highest point
trimThresh = [idxLeft idxRight] * upSizeFactor;
% trimThresh = 0.95;
% widthBeforeTrim = size(image,2);
[image, ~, ~] = trimLaserImage(image, csvFileName, trimThresh);

if ~autoClicking
    image(image < heightCutoff) = NaN;
end

% Get filament center positions
fileXY = strrep(fullfile(userPath, csvFileName), ".csv", "_hough.txt");
centers0 = readmatrix(fileXY);
centers = centers0;

if doModifiedPoints  % add false negatives
        
    centers_del = readmatrix(strrep(fileXY,".","_delPoints."));

    for i = 1:size(centers,1)
        for j = 1:size(centers_del)
            if norm(centers(i,:) - centers_del(j,:)) <= dupliDist
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
    outputFileName = fullfile(userPath, strrep(csvFileName,".csv","_mldata.txt"));
    fileID = fopen(outputFileName, 'w');    
    fprintf(fileID, '%s', mldata);
    fclose(fileID);
else
    centers = centers0;
end

centers = centers * upSizeFactor;
% centers(:,1) = centers (:,1) / widthBeforeTrim * size(image,2);  % new resolution

% Delete margin filaments
centers = centers(centers(:,1) > measureLength, :);
centers = centers(centers(:,1) < size(image,2) - measureLength, :);
centers = centers(centers(:,2) > measureLength, :);
centers = centers(centers(:,2) < size(image,1) - measureLength, :);

if plotInitialImage
    figure;
%     imshow(image)
    hold on
%     plot(centers(:,1), centers(:,2), "g.", "Marker", "+", "MarkerSize", 5, "LineWidth", 1)
    plot(centers(:,1), centers(:,2), "k.")
end

profile_fig = figure;
sub_fig = figure;

i = 1;

mm = -measureLength:measureLength;  % px to mm
mm = mm / analysisResolution;

z_tang_total = zeros(length(mm),1);
z_ax_total = zeros(length(mm),1);
z_max = zeros(size(centers,1),1);

while true

    center = round(centers(i,:));
    x = center(1)-measureLength:center(1)+measureLength;
    y = center(2)-measureLength:center(2)+measureLength;
    z_tang = image(center(2),x)';
    z_ax = image(y,center(1));


    if autoClicking  % auto compute all filaments

        z_max(i) = min([max(z_tang) max(z_ax)]);

        % Auto-zero maximum
        z_tang_total = z_tang_total + z_tang - max(z_tang);
        z_ax_total = z_ax_total + z_ax - max(z_ax);

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
        if click(1) >= measureLength  % click right half
            i = i + 1;  % go foward
        else  % click left half
            i = i - 1;  % go backward
        end        
    end

    i = mod(i, size(centers,1));  % roll around
    if i == 0
        i = size(centers,1);
        if autoClicking
            click = [];
        end
    end
end

if autoClicking
    close(sub_fig)
    z_tang_total = z_tang_total / size(centers,1);
    z_ax_total = z_ax_total / size(centers,1);

    z_tang_total = smooth(z_tang_total, smoothSize) - max(z_tang_total);
    z_ax_total = smooth(z_ax_total, smoothSize) - max(z_ax_total);

    z_tang = z_tang_total;  % to save as file later
    z_ax = z_ax_total;

    z_tang_total(z_tang_total < heightCutoff) = NaN;
    z_ax_total(z_ax_total < heightCutoff) = NaN;

    figure(profile_fig);
    hold off
    plot(mm,z_tang_total,"k","LineWidth",2);
    hold on
    plot(mm,z_ax_total,"b","LineWidth",2);
    legend(["tangential","axial"],'Location','Best')
    title(sprintf("Tip profiles"));
    xlabel("Width [mm]");
    ylabel("Height [mm]");
    axis([mm(1) mm(end) heightCutoff 0])

    % Save tip profiles as image
    outputFileName = fullfile(userPath, strrep(csvFileName,".csv","_tip_shape.png"));
    saveas(gcf, outputFileName);

    % Save tip profiles as text
    outputFileName = strrep(outputFileName,".png",".txt");
    writematrix(horzcat(mm',z_tang,z_ax), outputFileName, "Delimiter","\t");

    % Filament length deviation
    z_max = z_max(z_max > heightCutoff);
    z_max = z_max - median(z_max);
    length_stdev = std(z_max);

    [counts, edges] = histcounts(z_max, 'BinWidth', binWidth);
    counts = counts / sum(counts);

    figure;
    bins = edges(1:end-1) + binWidth / 2;
    plot(bins, counts,"k","LineWidth",2);
    title(sprintf("Filament length (StdDev = %.4f)",length_stdev));
    xlabel("Filament length deviation [mm]");
    ylabel("Relative Occurrence");

    % Save filament length histogram as image
    outputFileName = fullfile(userPath, strrep(csvFileName,".csv","_tip_hist.png"));
    saveas(gcf, outputFileName);

    % Save filament length histogram as text
    outputFileName = strrep(outputFileName,".png",".txt");
    writematrix(horzcat(bins',counts'), outputFileName, "Delimiter","\t");

        
end

if doExportHiRes  % Export final image and show    
    outputFileName = fullfile(userPath, strrep(csvFileName,".csv","_hiRes.png"));
    imwrite(image, outputFileName);
    if plotImageFinal
        winopen(outputFileName);
    end
end

% close(wb)

clear i j
