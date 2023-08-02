function [xy_synth, DT_synth, EL_synth] = IterateSpread(xy_synth, EL_true, par)

if par.importSynth
    EL_thresh_synth = par.edgeThresh;  % max edge lengths should be the same
else
    EL_thresh_synth = [0, 5];  % allow broad range for first few iterations
end

% Histogram of true edge lengths only calculated once
hist_true = HistogramCurve(EL_true, par.binWidth, par);
num_bins = length(hist_true.centers);
EL_min = hist_true.centers(1);  % shortest edge length
EL_max = hist_true.centers(end);  % longest edge length
m = median(EL_true);

% Initial triangulation (also for zero iterations)
[DT_synth, EL_synth] = DelaunayTriangulation(xy_synth, EL_thresh_synth);


% Histogram of synthetc edge lengths different every iteration
hist_synth = HistogramCurve(EL_synth, hist_true.edges, par);
% Output progress and current residue
rsq = Rsquared(hist_true, hist_synth);
% Plot frame evolution if enabled
FramePlot(0, xy_synth, DT_synth, rsq, par);

% Iterative algorithm with decreasing step width 1/i
for iter = 1:par.num_iters

    % Histogram of synthetc edge lengths different every iteration
    hist_synth = HistogramCurve(EL_synth, hist_true.edges, par);

    % Output progress and current residue
    rsq = Rsquared(hist_true, hist_synth);
    fprintf("Iteration: %d/%d (R² = %.3f)\n", iter, par.num_iters, rsq)

    %fileID = fopen('rsq_opt.txt', 'a');
    %fprintf(fileID, '%f\n', rsq);
    %fclose(fileID);

    % Get neighbors of each point
    N = size(xy_synth, 1);
    neighbors = cell(N, 1);
    for d = 1:size(DT_synth, 1)
        edges = nchoosek(DT_synth(d,:),2);
        for j = 1:3
            pt1 = edges(j, 1);
            pt2 = edges(j, 2);
            neighbors{pt1}(end+1) = pt2;
            neighbors{pt2}(end+1) = pt1;
        end
    end

    % Move each point towards equal spacing
    xy_next = xy_synth;
    for p = 1:N
        neighs = unique(neighbors{p});  % remove duplicates

        for n = 1:length(neighs)
            % Position vectors
            a = xy_synth(p,:);  % absolute center vector
            b = xy_synth(neighs(n),:);  % absolute neighbor vector
            c = b - a;  % relative vector
            d = norm(c);  % relative vector magnitude

            % Based on edge length median -> simple but inaccurate
            %s = c * (1 - m / d);  % shift vector
            %xy_next(p,:) = xy_next(p,:) + s / iter;  % absolute shift

            % Based on accummulated edge length histogram -> more accurate
            idx = LinearMap(d, EL_min, EL_max, 1, num_bins);  % bin number
            epsilon = hist_true.accum(idx) - hist_synth.accum(idx);  % residue
            s = c * (1 - m * (1 - epsilon) / d) / iter;  % shift vector
            xy_next(p,:) = xy_next(p,:) + s;  % absolute shift
        end
    end
    xy_synth = xy_next;

    [DT_synth, EL_synth] = DelaunayTriangulation(xy_synth, EL_thresh_synth);
    FramePlot(iter, xy_synth, DT_synth, rsq, par);
end
end

function FramePlot(iter, xy, DT, rsq, par)
% Plot true delaunay triangulation -> FORMATVORLAGE (SLOW!)
if par.plotSynthEvolution && (iter < 25 || mod(iter,25) == 0)
    lims = [10 22 -6 6];

    screen_size = get(0, 'ScreenSize');
    figure('Position', [0 0 screen_size(4) screen_size(4)]);
    radius = par.df_synth/2;
    theta = linspace(0, 2*pi, 100);
    rct = radius * cos(theta);
    rst = radius * sin(theta);
    hold on
    for i = 1:size(xy,1)
        center = xy(i, :);
        %         if center(1) < lims(1) || center(1) > lims(2) || ...
        %             center(2) < lims(3) || center(2) > lims(4)
        %             continue;
        %         end
        x = center(1) + rct;
        y = center(2) + rst;
        fill(x, y, [159 182 196]/255, 'EdgeColor', 'none');
    end
    triplot(DT, xy(:,1), xy(:,2), 'k', 'LineWidth', 2);
    axis(lims);
    axis equal
    axis off
    outPath = sprintf("Userdata/Figures/Evolution/%s_iter_%d_Rsq%.3f.png", ...
        strrep(par.inFileTrue, '.txt', ''), iter, rsq);
    saveas(gcf, outPath);
    close(gcf)
end
end

% Map linear x to linear y by specifying two fixed points each
function y = LinearMap(x, xmin, xmax, ymin, ymax)
y = round((ymax-ymin) * (x-xmin) / (xmax-xmin) + ymin);
if y < ymin  % clamp low
    y = ymin;
elseif y > ymax  % clamp high
    y = ymax;
end
end