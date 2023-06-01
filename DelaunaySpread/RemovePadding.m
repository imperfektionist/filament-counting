function xy = RemovePadding(xy_synth, par)

% Copy xy_synth to xy
xy = xy_synth;
lim = par.lim_synth;

% Find the indices of lines that fall outside the intervals
outsidePadding = (xy(:, 1) < lim.xmin | xy(:, 1) > lim.xmax | xy(:, 2) < lim.ymin | xy(:, 2) > lim.ymax);

% Remove the lines outside the intervals
xy(outsidePadding, :) = [];