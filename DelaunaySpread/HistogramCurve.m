% Calculate normalized and accumulated histograms
% scalar argin is BinWidth, vector argin is BinEdges
function bin = HistogramCurve(EL, argin, par)

if length(argin) == 1  % argin is bin width
    [counts, edges] = histcounts(EL(:), 'BinWidth', argin);
else  % argin is bin edges
    [counts, edges] = histcounts(EL(:), 'BinEdges', argin);
end

if par.smoothHistogram
    %counts = smoothdata(counts, 'SmoothingFactor', par.smoothWidth)';
    counts = smoothdata(counts, 'SmoothingFactor', par.smoothWidth);
end

binWidth = edges(2) - edges(1);  % works for all argins
bin.edges = edges';
bin.centers = edges(1:end-1) - binWidth / 2;  % centers between edges
bin.counts = counts' / sum(counts);  % normalized histogram
bin.accum = cumsum(bin.counts);  % accumulated histogram

