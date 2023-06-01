function bin = HistogramCurve(EL, argin)

% Make and plot histograms
% h = histogram(EL, 'BinWidth', binWidth);
% bin.centers = h.BinEdges(1:end-1) - binWidth / 2;
% bin.counts = h.Values / sum(EL);

if length(argin) == 1  % argin is bin width
    [counts, edges] = histcounts(EL, 'BinWidth', argin);
else  % argin is bin edges
    [counts, edges] = histcounts(EL, 'BinEdges', argin);
end
binWidth = edges(2) - edges(1);
bin.centers = edges(1:end-1) - binWidth / 2;
bin.counts = counts / sum(EL);
bin.edges = edges;