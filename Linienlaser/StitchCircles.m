

userPath = "UserData";
csvFiles = {'BU2281_WSS_2U_L_hough.txt', 'BU2281_WSS_2U_R_hough.txt'};
outFile = 'BU2281_WSS_2U_LR_stitched.txt';

vertSize = 800; % vertical image size [px]
sizeFac = 2;  % larger than 1 if image was shrunk during processing
vertShift = 785;  % robot shift between L and R [px]

cutoff_hi = 2280;  % discard all filaments above [px]
cutoff_lo = 300;  % discard all filaments below [px]

minDist = 60;  % minimum px between two filaments (otherwise interpolate)

diameterBody = 100;  % brush body [mm]
diameterOuter = 105;  % diameter of water jet circle [mm]

doDeletedPoints = 1;  % import file with points to delete
doAddedPoints = 1;  % import file with additional points
dupliDist = 30;  % maximum px for manual duplicate deletion

plotSeparateFiles = 0;  % 1: plot overlap, 0: plot stitched

wb = waitbar(0, "Processing circles...");

inFile_hi = fullfile(userPath, csvFiles{1});
inFile_lo = fullfile(userPath, csvFiles{2});

XY_hi = readmatrix(inFile_hi);
XY_lo = readmatrix(inFile_lo);

if doAddedPoints
    XY_hi = vertcat(XY_hi, readmatrix(strrep(inFile_hi,".","_addPoints.")));
    XY_lo = vertcat(XY_lo, readmatrix(strrep(inFile_lo,".","_addPoints.")));
end

if doDeletedPoints
    del_hi = readmatrix(strrep(inFile_hi,".","_delPoints."));
    del_lo = readmatrix(strrep(inFile_lo,".","_delPoints."));
    
    for i = 1:size(XY_hi,1)
        for j = 1:size(del_hi)
            if norm(XY_hi(i,:) - del_hi(j,:)) <= dupliDist
                XY_hi(i,1) = NaN;  % mark for deletion
            end
        end
    end
    XY_hi(any(isnan(XY_hi), 2), :) = [];

    for i = 1:size(XY_lo,1)
        for j = 1:size(del_lo)
            if norm(XY_lo(i,:) - del_lo(j,:)) <= dupliDist
                XY_lo(i,1) = NaN;  % mark for deletion
            end
        end
    end
    XY_lo(any(isnan(XY_lo), 2), :) = [];
end

XY_lo = [XY_lo(:,1), vertSize - XY_lo(:,2)] * sizeFac;
XY_hi = [XY_hi(:,1), vertSize - XY_hi(:,2)] * sizeFac;
XY_hi(:,2) = XY_hi(:,2) + vertShift;

XY_lo = XY_lo(XY_lo(:,2) > cutoff_lo, :);
XY_hi = XY_hi(XY_hi(:,2) < cutoff_hi, :);

centers = vertcat(XY_hi, XY_lo);  % concatenate upper and lower half

distMatrix = squareform(pdist(centers));
n = size(centers, 1);
for c = 1:n
    for d = c+1:n
        if distMatrix(c, d) <= minDist
            centers(c,:) = (centers(c,:) + centers(d,:)) / 2;  % average
            centers(d,1) = NaN;  % mark for deletion
        end
    end
    waitbar(c/n, wb, sprintf("Stitching circles %d%%", round(c/n*100)));
end

centers(any(isnan(centers), 2), :) = [];  % remove weak close

close(wb)

% Transform filament positions for export
centers(:,2) = centers(:,2) - median(centers(:,2));  % centerize around axial center
centers = centers / 100;  % convert px to mm
centers(:,1) = centers(:,1) / diameterOuter * diameterBody;  % project onto body

outXY = fullfile(userPath, outFile);

% Loop through each row and write to the file with three decimal places
fileID = fopen(outXY, 'w');
for i = 1:size(centers, 1)
    fprintf(fileID, '%0.3f,%0.3f\n', centers(i, :));
end
fclose(fileID);

figure;
if plotSeparateFiles
    plot(XY_hi(:,1), XY_hi(:,2), 'ro')
    hold on
    plot(XY_lo(:,1), XY_lo(:,2), 'bo')
else
    plot(centers(:,1), centers(:,2), 'ko')
end


