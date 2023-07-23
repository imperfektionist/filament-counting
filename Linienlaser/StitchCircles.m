

userPath = "UserData";
csvFiles = {'BU2281_WSS_2U_L_hough.txt', 'BU2281_WSS_2U_R_hough.txt'};
outFile = 'BU2281_WSS_2U_LR_stitched.txt';

sizeFac = 2;  % larger than 1 if image was shrunk during processing
vertShift = 785;  % robot shift px
vertSize = 800; % vertical image size px

cutoff_hi = 2240;
cutoff_lo = 325;

minDist = 60;

wb = waitbar(0, "Processing circles...");

XY_hi = readmatrix(fullfile(userPath, csvFiles{1}));
XY_lo = readmatrix(fullfile(userPath, csvFiles{2}));

XY_lo = [XY_lo(:,1), vertSize - XY_lo(:,2)] * sizeFac;
XY_hi = [XY_hi(:,1), vertSize - XY_hi(:,2)] * sizeFac;
XY_hi(:,2) = XY_hi(:,2) + vertShift;

XY_hi = XY_hi(XY_hi(:,2) < cutoff_hi, :);
XY_lo = XY_lo(XY_lo(:,2) > cutoff_lo, :);

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
    waitbar(c/n, wb, sprintf("Deleting circles %d%%", round(c/n*100)));
end

centers(any(isnan(centers), 2), :) = [];  % remove weak close

close(wb)

% Centerize around axial center and convert px to mm
centers(:,2) = centers(:,2) - median(centers(:,2));
centers = centers / 100;

outXY = fullfile(userPath, outFile);
writematrix(centers, outXY, 'Delimiter', 'comma');

figure;
% plot(XY_hi(:,1), XY_hi(:,2), 'ro')
% hold on
% plot(XY_lo(:,1), XY_lo(:,2), 'bo')

plot(centers(:,1), centers(:,2), "ko")