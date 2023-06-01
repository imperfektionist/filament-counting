screen_size = get(0, 'ScreenSize');

% Plot filament XY positions
if do.plotXY    
    fig = figure('Position', [0 0 screen_size(3) screen_size(4)]);
    plot(xy_true(:,1), xy_true(:,2), 'g.')
    hold on
    plot(xy_synth(:,1), xy_synth(:,2), 'r.')
    axis equal
    legend('True','Synth')
    title("Filament Positions")
end

% Plot true delaunay triangulation
if do.plotDelaunayTrue
    figure('Position', [0 0 screen_size(3) screen_size(4)]);
    triplot(DT_true, xy_true(:,1), xy_true(:,2), 'k');
    axis equal
    title("Delaunay Triangulation (True)")
end

% Plot synthetic delaunay triangulation
if do.plotDelaunaySynth
    figure('Position', [0 0 screen_size(3) screen_size(4)]);
    triplot(DT_synth, xy_synth(:,1), xy_synth(:,2), 'r');
    axis equal
    title("Delaunay Triangulation (Synth)")
end

% Calculate and display histogram data
if do.plotHistogram
    hist_true = HistogramCurve(EL_true, binWidth);
    hist_synth = HistogramCurve(EL_synth, hist_true.edges);
    m_true = median(EL_true);

    if do.smoothHistogram
        hist_true.counts = smooth(hist_true.counts);
        hist_synth.counts = smooth(hist_synth.counts);
    end

    figure;
    plot(hist_true.centers, hist_true.counts, 'k')
    hold on 
    plot(hist_synth.centers, hist_synth.counts, 'r') 
    plot([m_true m_true], [0 max(hist_true.counts)], 'b--')       
    legend('True','Synth','Median')
    r_squared = Rsq(hist_true, hist_synth);
    title(sprintf("Neighbor Distance Histogram (R^2 = %.3f)", r_squared))
    xlabel('Edge Length')
    ylabel('Relative Occurrence')
end
