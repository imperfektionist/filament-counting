screen_size = get(0, 'ScreenSize');

% Plot filament XY positions and remove padding
if par.plotXY
    figure('Position', [0 0 screen_size(3) screen_size(4)]);
    plot(xy_true(:,1), xy_true(:,2), 'b.')
    hold on
    plot(xy_synth(:,1), xy_synth(:,2), 'g.')  % padded
    xy = RemovePadding(xy_synth, par);
    plot(xy(:,1), xy(:,2), 'r.')  % final distribution
    PlotTrueLimits(gcf, par.lim_true, 'b');
    PlotTrueLimits(gcf, par.lim_synth, 'r');
    axis equal
    legend(sprintf('True (%d)', size(xy_true,1)), ...
        sprintf('Synth (%d)', size(xy_synth,1)), ...
        sprintf('Final (%d)', size(xy,1)))
    title("Filament Positions")
end

% Plot true delaunay triangulation
if par.plotDelaunayTrue
    figure('Position', [0 0 screen_size(3) screen_size(4)]);
    triplot(DT_true, xy_true(:,1), xy_true(:,2), 'b');
    hold on
    PlotTrueLimits(gcf, par.lim_true, 'k');
    axis equal
    title("Delaunay Triangulation (True)")
end

% Plot synthetic delaunay triangulation
if par.plotDelaunaySynth
    figure('Position', [0 0 screen_size(3) screen_size(4)]);
    triplot(DT_synth, xy_synth(:,1), xy_synth(:,2), 'r');
    hold on
    PlotTrueLimits(gcf, par.lim_synth, 'k');
    axis equal
    title("Delaunay Triangulation (Synth)")
end

% % Plot true delaunay triangulation -> FORMATVORLAGE (SLOW!)
% if par.plotDelaunaySynth
%     figure('Position', [0 0 screen_size(3) screen_size(4)]);
%     radius = par.df_synth/2;
%     theta = linspace(0, 2*pi, 100);
%     rct = radius * cos(theta);
%     rst = radius * sin(theta);
%     hold on
%     for i = 1:size(xy_synth,1)
%         center = xy_synth(i, :);     
%         x = center(1) + rct;
%         y = center(2) + rst;
%         fill(x, y, [159 182 196]/255, 'EdgeColor', 'none');        
%     end    
%     hold on
%     triplot(DT_synth, xy_synth(:,1), xy_synth(:,2), 'k', 'LineWidth', 2);
%     axis equal
%     axis off
% end

% Normalize edge lengths by filament diameter
ELD_true = EL_true / par.df_true;
ELD_synth = EL_synth / par.df_synth;

% ELn_true = ELn_true(ELn_true < 2);
% ELn_synth = ELb_synth(ELb_synth < 2);
ELD_true = ELD_true(ELD_true >= par.histLimits(1));
ELD_synth = ELD_synth(ELD_synth >= par.histLimits(1));
ELD_true = ELD_true(ELD_true <= par.histLimits(2));
ELD_synth = ELD_synth(ELD_synth <= par.histLimits(2));

% Calculate edge length histograms and standard deviation
hist_true = HistogramCurve(ELD_true, par.binWidth, par);
hist_synth = HistogramCurve(ELD_synth, hist_true.edges, par);
below_one = HistBelowOne(hist_synth);
rsq = Rsquared(hist_true, hist_synth);
std_true = std(ELD_true);
std_synth = std(ELD_synth);

% Display edge length histogram data
if par.plotEdgeLengths
    figure;
    plot(hist_true.centers, hist_true.counts, 'k')
    hold on
    plot(hist_synth.centers, hist_synth.counts, 'r')
    plot([1 1], [0 max(hist_true.counts)], 'k--')
    xlim(par.histLimits);
    yl = ylim;
    text(par.histLimits(1)+0.05, yl(2)*0.9, sprintf("σ_t = %.3f\nσ_s = %.3f", ...
        std_true, std_synth));
    legend('True','Synth',sprintf('%.1f %%',below_one))    
    title(sprintf("Edge Length Histogram (R^2 = %.3f)", rsq))
    xlabel('Dimensionless Filament Spacing [-]')
    ylabel('Relative Occurrence [-]')
end

% Calculate angle histograms
angles_true = HistogramCurve(EA_true, 1:180, par);
angles_synth = HistogramCurve(EA_synth, 1:180, par);
rsq = Rsquared(angles_true, angles_synth);

% Display angle histogram data
if par.plotEdgeAngles
    figure;
    plot(angles_true.centers, angles_true.counts, 'k')
    hold on
    plot(angles_synth.centers, angles_synth.counts, 'r')
    xlim([0 180]);
    yl = ylim;
    legend('True','Synth')    
    title(sprintf("Angle Histogram (R^2 = %.3f)", rsq))
    xlabel('Filament Distance Angle [°]')
    ylabel('Relative Occurrence [-]')
end

% Calculate and display accumulated histogram data
if par.plotAccumulated
    figure;
    plot(hist_true.centers, hist_true.accum, 'k')
    hold on 
    plot(hist_synth.centers, hist_synth.accum, 'r')
    plot([1 1], [0 max(hist_true.counts)], 'k--')
    xlim(par.histLimits);
    yl = ylim;
    text(par.histLimits(1)+0.05, yl(2)*0.9, sprintf("σ_t = %.3f\nσ_s = %.3f", ...
        std_true, std_synth));
    legend('True','Synth',sprintf('%.1f %%',below_one)) 
    title(sprintf("Accum. Histogram (R^2 = %.3f)", rsq))
    xlabel('Dimensionless Filament Spacing [-]')
    ylabel('Relative Occurrence [-]')
end

% Plot Rsq over number of iterations and synth error exponent as height map 
if par.plotRsqMap
%     figure;
%     surf(0:par.num_iters, par.p_synth, log(par.rsq));
%     colormap('bone')  % parula, turbo, bone, hot
%     colorbar
%     view(0, 90);
%     xlim([0 50]);
%     ylim([0 5]);
%     [maxVal, linInd] = max(par.rsq(:));  % find maximum Rsq
%     [iterInd, pInd] = ind2sub(size(par.rsq), linInd);  % get indices
%     tit = sprintf('R^2: %.1f, i: %d, p_ε: %.2f', ...
%         maxVal*100, iterInd-1, par.p_synth(pInd));
%     title(tit)    
%     xlabel('Number of iterations')
%     ylabel('Synthetic error exponent')    
end
if par.exportRsqMap
    writematrix(par.rsq, "UserData\Rsq_Map.txt", 'Delimiter', '\t');
end

% Determine the ratio of histogram data below X = 1
% These are all filament spacings smaller than filament diameter
function ratio = HistBelowOne(hg)
    centers = hg.centers;  % normalize
    N = length(centers(centers < 1));  % number of points
    ratio = sum(hg.counts(1:N)) / sum(hg.counts) * 100;
end
