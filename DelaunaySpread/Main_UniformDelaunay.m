clear;

%csvFileName = 'XY_105x0x0,6_SiC_N10377_df.txt';  % experimental input XY
csvFileName = 'XY_105x0x1,1_SiC_N4026_df.txt';  % experimental input XY

outFile = 'BU2265_X96_Y90_df0.615.csv';
skimPercentX = 0.02;    % both left and right X
skimPercentY = 0.05;    % both top and bottom Y
edgeThresh = [0.1, 4];  % min and max triangle edge length [times df]
num_iters = 40;          % number of spread iterations
binWidth = 0.01;        % edge length bin width

do.exportXY = 0;
do.plotXY = 0;
do.plotDelaunayTrue = 0;
do.plotDelaunaySynth = 0;
do.plotHistogram = 1;
do.smoothHistogram = 1;

% Import true filament distribution
[xy_true, lim_true] = ImportXY(csvFileName, skimPercentX, skimPercentY, do);

% Delaunay triangulation of true filament distribution
[DT_true, EL_true] = DelaunayTriangulation(xy_true, edgeThresh);

% Initialize synthetic uniform distribution
lim_synth = lim_true;  % synthetic distribution of same dimensions
xy_synth = UniformSpread(xy_true, lim_true, lim_synth);  % initially uniform

% Iteratively spread out synthetic distribution
[xy_synth, DT_synth, EL_synth] = IterateSpread(xy_synth, EL_true, num_iters, binWidth);

% Plot distributions for visual analysis
PlotAnalysis;






