% Determine R-squared value
function r_squared = Rsq(hist_true, hist_synth)

ssd = sum((hist_true.counts - hist_synth.counts).^2);
mean_true = mean(hist_true.counts);
sst = sum((hist_true.counts - mean_true).^2);
ssr = sst - ssd;
r_squared = 1 - (ssr / sst);
