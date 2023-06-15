clear
% close all

par.inFileTrue = 'XY_105x0x1,1_SiC_N4026_df1,126.txt';  % experimental input XY
% par.inFileTrue = 'XY_105x0x0,6_SiC_N10377_df0,613.txt';  % experimental input XY
par.importSynth = 1;  % import synthetic distribution instead of making it

par.df = 1.114;             % filament diameter [mm] (set 1 for dependent)
% par.df = 0.628;             % filament diameter [mm] (set 1 for dependent)
par.scaleFactor = 1.0;      % scaling factor for all dimensions
par.skimPercentX = 0.02;    % both left and right X
par.skimPercentY = 0.05;    % both top and bottom Y

par.edgeThresh = [0.1 3];   % min and max triangle edge length [times median]
par.padWidth = 5;           % padding margin later removed [mm]
par.brushWidth = 19.64;      % width of brush tool [mm]
par.brushDiameter = 100;    % diameter of brush tool [mm]

par.num_iters = 25;         % number of spread iterations
par.binWidth = 0.01;        % edge length bin width
par.smoothHistogram = 1;    % smooth histogram for calculation and plots
par.smoothWidth = 0.01;      % moving average filter width
par.histLimits = [0 3.2];   % histogram x axis limits 

par.plotXY = 0;
par.plotDelaunayTrue = 0;
par.plotDelaunaySynth = 0;
par.plotHistogram = 1;
par.plotAccumulated = 0;

par.exportXY = 0;
par.exportHist = 1;

% Import true filament distribution
[xy_true, par] = ImportTrueXY(par);

% Delaunay triangulation of true filament distribution
[DT_true, EL_true] = DelaunayTriangulation(xy_true, par.edgeThresh);

if par.importSynth
    [xy_synth, par] = ImportSynthXY(par);
    par.num_iters = 0;
else
    % Initialize synthetic uniform distribution
    [xy_synth, par] = UniformSpread(xy_true, par);  % initially uniform
end

% Iteratively spread out synthetic distribution
[xy_synth, DT_synth, EL_synth] = IterateSpread(xy_synth, EL_true, par);

% Plot distributions for visual analysis
PlotAnalysis;

% Export synthetic distribution and histograms
ExportFiles(xy_synth, hist_true, hist_synth, par);





