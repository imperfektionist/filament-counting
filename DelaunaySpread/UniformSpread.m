function xy_synth = UniformSpread(xy_true, lim_true, lim_synth)

N_true = size(xy_true, 1);  % true filament number

area_true = (lim_true.xmax - lim_true.xmin) * (lim_true.ymax - lim_true.ymin);
area_synth = (lim_synth.xmax - lim_synth.xmin) * (lim_synth.ymax - lim_synth.ymin);

rho = N_true / area_true;  % filament density

N_synth = round(rho * area_synth);  % synthetic number of filaments

xy_synth = zeros(N_synth, 2);  % init

% Generate random X and Y values
xy_synth(:,1) = rand(N_synth,1) * (lim_synth.xmax - lim_synth.xmin) + lim_synth.xmin;
xy_synth(:,2) = rand(N_synth,1) * (lim_synth.ymax - lim_synth.ymin) + lim_synth.ymin;