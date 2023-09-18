% clear
% close all

% par.inFileTrue = 'XY_105x0x1,1_SiC_N4026_df1,126.txt';  % experimental input XY
% par.inFileTrue = 'XY_105x0x0,6_SiC_N10377_df0,613.txt';  % experimental input XY
par.inFileTrue = 'BU2281_LR_NOCOLL.txt';
% par.inFileSynth = 'BU2281_POISSON_COLL.txt';
par.inFileSynth = 'SYNTH_BU2281_LR_COLL.txt';
par.importSynth = 0;  % import synthetic distribution instead of making it
par.useVectorIterate = 1;  % use vector iteration (1) or ML (0)

par.df_true = 1.114;             % filament diameter [mm] (set 1 for dependent)
% par.df_true = 0.628;             % filament diameter [mm] (set 1 for dependent)
par.df_synth = 1.114;             % filament diameter [mm] (set 1 for dependent)
% par.df_synth = 0.628;             % filament diameter [mm] (set 1 for dependent)
par.scaleFactor = 1;      % scaling factor for all dimensions
par.skimPercentX = 0.02;    % both left and right X
par.skimPercentY = 0.05;    % both top and bottom Y

par.edgeThresh = [0.1 3];   % min and max triangle edge length [times median]
par.padWidth = 5;           % padding margin later removed [mm]
par.brushWidth = 20.155;      % width of brush tool [mm]
% par.brushWidth = 20;      % width of brush tool [mm]
par.brushDiameter = 100;    % diameter of brush tool [mm]

par.num_iters = 50;         % number of spread iterations 
par.p_synth = 1;            % synthetic error exponent 0:0.1:10;
par.binWidth = 0.01;        % edge length bin width (0.01)
par.smoothHistogram = 1;    % do smooth histogram for calculation and plots
par.smoothWidth = 0.01;      % moving average filter width
% par.histLimits = [0.8 1.8];   % histogram x axis limits 
par.histLimits = [1 1.6];   % histogram x axis limits 

par.plotXY = 1;             % figure for XY filament positions
par.plotDelaunayTrue = 0;   % figure for triangulation of actual distribution
par.plotDelaunaySynth = 0;  % figure for triangulation of synthetic distribution
par.plotSynthEvolution = 0; % plot partial frame for every iteration (slow)
par.plotEdgeLengths = 0;    % figure for histogram of filament distances
par.plotEdgeAngles = 0;     % figure for histogram of filament dist angles
par.plotAccumulated = 0;    % figure for cumsum histogram of filament distances
par.plotRsqMap = 0;         % figure for Rsq over num_iters x p_synth

par.exportXY = 1;           % export XY filament positions as textfile
par.exportHist = 0;         % export histogram as textfile
par.exportRsqMap = 0;       % export Rsq over num_iters x p_synth

% Import true filament distribution
[xy_true, par] = ImportTrueXY(par);

% Setup Rsq map
par.rsq = zeros(par.num_iters+1, numel(par.p_synth));  % 0th is no iteration

% Delaunay triangulation of true filament distribution
[DT_true, EL_true, EA_true] = DelaunayTriangulation(xy_true, par.edgeThresh);

wb = waitbar(0, 'Iterating... 0%%');
for p_synth = 1:numel(par.p_synth)

    prog = p_synth/numel(par.p_synth);
    waitbar(prog, wb, sprintf('Iterating... %d%%', round(prog*100)));
    fprintf('Synthetic error exponent %d: %.1f\n', p_synth, par.p_synth(p_synth));

    if par.importSynth
        [xy_synth, par] = ImportSynthXY(par);
        par.num_iters = 0;
    else
        % Initialize synthetic uniform distribution
        [xy_synth, par] = UniformSpread(xy_true, par);  % initially uniform
    end
    
    if par.useVectorIterate  % Iteratively spread out synthetic distribution
        [xy_synth, DT_synth, EL_synth, EA_synth, par] = IterateSpread(xy_synth, EL_true, p_synth, par);
    else  % Machine learning approach
        [xy_synth, DT_synth, EL_synth] = MachineLearning(xy_synth, DT_true, EL_true, par);
    end
end
close(wb);

% Plot distributions for visual analysis
PlotAnalysis;

% Export synthetic distribution and histograms
ExportFiles(xy_synth, hist_true, hist_synth, angles_true, angles_synth, par);





