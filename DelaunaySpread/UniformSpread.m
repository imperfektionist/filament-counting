function [xy_synth, par] = UniformSpread(xy_true, par)

% Border points are missing
lim_true = par.lim_true;

% Synthetic brush dimensions
lim_synth.xmin = 0;
lim_synth.xmax = par.brushDiameter * pi;
lim_synth.ymin = -par.brushWidth / 2;
lim_synth.ymax = par.brushWidth / 2;

par.lim_synth = lim_synth;  % save before padding

% Add padding margin around synthetic distribution
lim_synth.xmin = lim_synth.xmin - par.padWidth;
lim_synth.xmax = lim_synth.xmax + par.padWidth;
lim_synth.ymin = lim_synth.ymin - par.padWidth;
lim_synth.ymax = lim_synth.ymax + par.padWidth;

N_true = size(xy_true, 1);  % true filament number

area_true = (lim_true.xmax - lim_true.xmin) * (lim_true.ymax - lim_true.ymin);
area_synth = (lim_synth.xmax - lim_synth.xmin) * (lim_synth.ymax - lim_synth.ymin);

rho = N_true / area_true;  % filament density

N_synth = round(rho * area_synth);  % synthetic number of filaments

xy_synth = zeros(N_synth, 2);  % init

% Generate random X and Y values
xy_synth(:,1) = rand(N_synth,1) * (lim_synth.xmax - lim_synth.xmin) + lim_synth.xmin;
xy_synth(:,2) = rand(N_synth,1) * (lim_synth.ymax - lim_synth.ymin) + lim_synth.ymin;