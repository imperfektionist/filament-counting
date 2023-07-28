% clear

userPath = "UserData";
csvFiles = {'BU6981_2U_L_hough.txt', 'BU6981_2U_R_hough.txt'};
outFile = 'BU6981_2U_LR_stitched.txt';

vertSize = 800; % vertical image size [px]
sizeFac = 2;  % larger than 1 if image was shrunk during processing
vertShift = 690;  % robot shift between L and R [px]

cutoff_hi = 2190;  % discard all filaments above [px]
cutoff_lo = 70;  % discard all filaments below [px]

minDist = 40;  % minimum px between two filaments (otherwise interpolate)
xStretchHi = 1;
xStretchLo = 1.148;

diameterBody = 100;  % brush body [mm]
diameterOuter = 150;  % diameter of water jet circle [mm]

doDeletedPoints = 1;  % import file with points to delete
doAddedPoints = 1;  % import file with additional points
dupliDist = 15;  % maximum px for manual duplicate deletion

doInterpolate = 0;  % 1: overlap and interpolate both sides, 0: strict cut
plotSeparateFiles = 1;  % 1: plot overlap, 0: plot stitched

wb = waitbar(0, "Processing circles...");

inFile_hi = fullfile(userPath, csvFiles{1});
inFile_lo = fullfile(userPath, csvFiles{2});

XY_hi = readmatrix(inFile_hi);
XY_lo = readmatrix(inFile_lo);

if par.doModifiedPoints
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

    XY_hi = vertcat(XY_hi, readmatrix(strrep(inFile_hi,".","_addPoints.")));
    XY_lo = vertcat(XY_lo, readmatrix(strrep(inFile_lo,".","_addPoints.")));
end


XY_lo = [XY_lo(:,1), vertSize - XY_lo(:,2)] * sizeFac;
XY_hi = [XY_hi(:,1), vertSize - XY_hi(:,2)] * sizeFac;
XY_hi(:,2) = XY_hi(:,2) + vertShift;

XY_lo = XY_lo(XY_lo(:,2) > cutoff_lo, :);
XY_hi = XY_hi(XY_hi(:,2) < cutoff_hi, :);

XY_hi(:,1) = XY_hi(:,1) * xStretchHi;
XY_lo(:,1) = XY_lo(:,1) * xStretchLo;

if ~doInterpolate  % cut strictly into two halfs which do not overlap
    thresh = median(vertcat(XY_hi(:,2), XY_lo(:,2)));
    XY_lo = XY_lo(XY_lo(:,2) < thresh, :);
    XY_hi = XY_hi(XY_hi(:,2) >= thresh, :);
end

centers = vertcat(XY_hi, XY_lo);  % concatenate both halfs

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
    plot(XY_hi(:,1), XY_hi(:,2), 'r.')
    hold on
    plot(XY_lo(:,1), XY_lo(:,2), 'b.')
else
    plot(centers(:,1), centers(:,2), 'k.')
end

fprintf("Filamentanzahl: %d\n", size(centers,1))

