%clear
%close all

% csvFileName = 'XY_105x0x0,6_SiC_N10377_df.txt';  % experimental input XY
csvFileName = 'XY_105x0x1,1_SiC_N4026_df.txt';  % experimental input XY

par.scaleFactor = 1.0;      % scaling factor for all dimensions
par.skimPercentX = 0.02;    % both left and right X
par.skimPercentY = 0.05;    % both top and bottom Y
par.outFile = 'output.csv';
par.exportXY = 0;

par.edgeThresh = [0.1 3];   % min and max triangle edge length [times median]
par.padWidth = 5;           % padding margin later removed [mm]
par.brushWidth = 19.5;      % width of brush tool [mm]
par.brushDiameter = 100;    % diameter of brush tool [mm]

par.num_iters = 25;         % number of spread iterations
par.binWidth = 0.01;        % edge length bin width
par.smoothHistogram = 1;    % smooth histogram for calculation and plots

par.plotXY = 1;
par.plotDelaunayTrue = 1;
par.plotDelaunaySynth = 1;
par.plotHistogram = 1;
par.plotAccumulated = 1;

% Import true filament distribution
[xy_true, par] = ImportXY(csvFileName, par);

% Delaunay triangulation of true filament distribution
[DT_true, EL_true] = DelaunayTriangulation(xy_true, par.edgeThresh);

% Initialize synthetic uniform distribution
[xy_synth, par] = UniformSpread(xy_true, par);  % initially uniform

% Iteratively spread out synthetic distribution
[xy_synth, DT_synth, EL_synth] = IterateSpread(xy_synth, EL_true, par);

% Plot distributions for visual analysis
PlotAnalysis;






