% Determine the ratio of histogram data below X = 1
% These are all filament spacings smaller than filament diameter
function ratio = HistBelowOne(hg, par)

centers = hg.centers / par.df;  % normalize
N = length(centers(centers < 1));  % number of points
ratio = sum(hg.counts(1:N)) / sum(hg.counts) * 100;
