% clear
close all

% par.inFileTrue = 'XY_105x0x1,1_SiC_N4026_df1,126.txt';  % experimental input XY
% par.inFileTrue = 'XY_105x0x0,6_SiC_N10377_df0,613.txt';  % experimental input XY
par.inFileTrue = 'BU2281_LR_NOCOLL.txt';
par.importSynth = 1;  % import synthetic distribution instead of making it
par.useVectorIterate = 1;  % use vector iteration (1) or ML (0)

par.df = 1.114;             % filament diameter [mm] (set 1 for dependent)
% par.df = 0.628;             % filament diameter [mm] (set 1 for dependent)
par.scaleFactor = 1;      % scaling factor for all dimensions
par.skimPercentX = 0.02;    % both left and right X
par.skimPercentY = 0.05;    % both top and bottom Y

par.edgeThresh = [0.1 3];   % min and max triangle edge length [times median]
par.padWidth = 5;           % padding margin later removed [mm]
par.brushWidth = 20.00;      % width of brush tool [mm]
par.brushDiameter = 100;    % diameter of brush tool [mm]

par.num_iters = 5;         % number of spread iterations
par.binWidth = 0.01;        % edge length bin width
par.smoothHistogram = 0;    % do smooth histogram for calculation and plots
par.smoothWidth = 0.01;      % moving average filter width
par.histLimits = [0 3.2];   % histogram x axis limits 

par.plotXY = 0;             % figure for XY filament positions
par.plotDelaunayTrue = 0;   % figure for triangulation of actual distribution
par.plotDelaunaySynth = 0;  % figure for triangulation of synthetic distribution
par.plotSynthEvolution = 0; % plot partial frame for every iteration (slow)
par.plotHistogram = 1;      % figure for histogram of filament distances
par.plotAccumulated = 0;    % figure for cumsum histogram of filament distances

par.exportXY = 0;           % export XY filament positions as textfile
par.exportHist = 0;         % export histogram as textfile

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

if par.useVectorIterate  % Iteratively spread out synthetic distribution
    [xy_synth, DT_synth, EL_synth] = IterateSpread(xy_synth, EL_true, par);
else  % Machine learning approach
    [xy_synth, DT_synth, EL_synth] = MachineLearning(xy_synth, DT_true, EL_true, par);
end

% Plot distributions for visual analysis
PlotAnalysis;

% Export synthetic distribution and histograms
ExportFiles(xy_synth, hist_true, hist_synth, par);





