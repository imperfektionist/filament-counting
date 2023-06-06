% IMPORT AND TRIM UNCOILED XY FILAMENT POSITIONS
function [xy, par] = ImportSynthXY(par)

[inFile, inPath] = uigetfile('UserData\SynthPacking\*.txt');

% Read the CSV file using the readmatrix function
data = readmatrix(fullfile(inPath, inFile));

% Extract the X and Y coordinates from the data
x = data(:,1);
y = data(:,2);
xy = horzcat(x, y);  % make one matrix

% True limits
lim.xmin = min(xy(:,1));
lim.xmax = max(xy(:,1));
lim.ymin = min(xy(:,2));
lim.ymax = max(xy(:,2));
par.lim_synth = lim;
