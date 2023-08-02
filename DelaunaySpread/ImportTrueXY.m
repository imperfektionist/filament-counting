% IMPORT AND TRIM UNCOILED XY FILAMENT POSITIONS
function [xy, par] = ImportTrueXY(par)

% Read the CSV file using the readmatrix function
data = readmatrix(fullfile('UserData', par.inFileTrue));

% Extract the X and Y coordinates from the data
x = data(:,1);
y = data(:,2);
xy = horzcat(x, y) * par.scaleFactor;  % make one matrix

% Trim a few percent off on each side
xy = TrimXY(xy, par);

% Align with x = 0
%xy(:,1) = xy(:,1) - min(xy(:,1));

% True limits
lim.xmin = min(xy(:,1));
lim.xmax = max(xy(:,1));
lim.ymin = min(xy(:,2));
lim.ymax = max(xy(:,2));
par.lim_true = lim;
